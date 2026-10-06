:- encoding(utf8).

% Capítulo 82 - Versión 5: firmar la entrega.
%
% El manifiesto de la versión 1 detecta un archivo cambiado, pero quien
% cambia el archivo puede cambiar también el manifiesto. Firmado con la
% clave privada del autor, el manifiesto ya no se puede cambiar sin que la
% firma deje de verificar, y la verificación necesita solo la clave
% pública, que se publica. La firma la calcula rsa_sign/4 de
% library(crypto), sobre el resumen SHA-256 del manifiesto y con el
% relleno de PKCS #1 v1.5; la clave sale de dos primos de
% crypto_generate_prime/3, armada en el formato que espera la biblioteca.
% Las claves se guardan en un llavero, con un nombre: el autor tiene su
% par completo, y quien verifica importa solo la clave pública. La entrega
% publicada son dos archivos, SHA256SUMS y SHA256SUMS.firma, junto al
% directorio del pack.
%
% solo-local: lee y escribe archivos.
%
%?- generar(autor, 1024), huella(autor, H).

:- module(firmas,
          [ clave_rsa/3,
            clave_desde_primos/4,
            publica/2,
            generar/2,
            exportar/2,
            importar/2,
            compartir/2,
            privada/2,
            huella/2,
            firmar_texto/3,
            verificar_texto/3,
            bloque_firmado/3,
            relleno_pkcs1/2,
            publicar/3,
            comprobar_entrega/4
          ]).

:- use_module(library(crypto)).
:- use_module(library(lists)).
:- use_module(library(apply)).
:- use_module(library(readutil)).
:- use_module(resumenes).
:- use_module(rsa, [inverso/3]).
:- use_module(library(filesex), [make_directory_path/1]).

%   entregas(Dir): el alias de un directorio para las entregas, dentro del
%   directorio temporal del sistema.
:- multifile user:file_search_path/2.
user:file_search_path(entregas, Dir) :-
    current_prolog_flag(tmp_dir, Tmp),
    directory_file_path(Tmp, 'curso-capitulo-82', Dir).

%!  clave_rsa(+Bits:integer, -Privada, -Publica) is det.
%
%   Privada y Publica son un par de claves RSA nuevo, con un módulo de
%   Bits bits, hecho con dos primos de crypto_generate_prime/3.
clave_rsa(Bits, Privada, Publica) :-
    Mitad is Bits // 2,
    repeat,
    crypto_generate_prime(Mitad, P, []),
    crypto_generate_prime(Mitad, Q, []),
    P =\= Q,
    clave_desde_primos(P, Q, Privada, Publica),
    !.

%!  clave_desde_primos(+P:integer, +Q:integer, -Privada, -Publica)
%!      is semidet.
%
%   Privada es private_key(rsa(N, E, D, P, Q, DP, DQ, QI)), con los ocho
%   números en hexadecimal como los espera library(crypto): el módulo, los
%   dos exponentes, los dos primos y tres valores que aceleran el cálculo.
%   Publica es la clave pública que le corresponde. E es 65537; falla si
%   no tiene inverso módulo (P-1)*(Q-1).
clave_desde_primos(P, Q, private_key(rsa(HN, HE, HD, HP, HQ, HDP, HDQ, HQI)),
                   public_key(rsa(HN, HE, -, -, -, -, -, -))) :-
    E = 65537,
    N is P * Q,
    Fi is (P - 1) * (Q - 1),
    inverso(E, Fi, D),
    DP is D mod (P - 1),
    DQ is D mod (Q - 1),
    inverso(Q, P, QI),
    maplist(hexadecimal, [N, E, D, P, Q, DP, DQ, QI],
            [HN, HE, HD, HP, HQ, HDP, HDQ, HQI]).

%!  hexadecimal(+N:integer, -Hex:atom) is det.
%
%   Hex son los dígitos hexadecimales de N.
hexadecimal(N, Hex) :-
    format(atom(Hex), "~16r", [N]).

%!  publica(+Publica, -Clave) is det.
%
%   Clave es publica(N, E), los dos enteros de la clave pública Publica.
publica(public_key(rsa(HN, HE, _, _, _, _, _, _)), publica(N, E)) :-
    hex_numero(HN, N),
    hex_numero(HE, E).

%!  hex_numero(+Hex:atom, -N:integer) is det.
%
%   N es el entero de los dígitos hexadecimales Hex.
hex_numero(Hex, N) :-
    atom_concat('0x', Hex, Texto),
    atom_number(Texto, N).

% --- El llavero ------------------------------------------------------------

:- dynamic clave/3.

%!  generar(+Nombre, +Bits:integer) is det.
%
%   Guarda en el llavero, con Nombre, un par de claves nuevo de Bits bits.
%   Reemplaza el que hubiera con ese nombre.
generar(Nombre, Bits) :-
    clave_rsa(Bits, Privada, Publica),
    retractall(clave(Nombre, _, _)),
    assertz(clave(Nombre, Privada, Publica)).

%!  exportar(+Nombre, -Publica) is semidet.
%
%   Publica es la clave pública guardada con Nombre: lo único que el autor
%   entrega a quien verifica.
exportar(Nombre, Publica) :-
    clave(Nombre, _, Publica).

%!  importar(+Nombre, +Publica) is det.
%
%   Guarda con Nombre la clave pública de otro, sin clave privada.
%   Reemplaza la que hubiera con ese nombre.
importar(Nombre, Publica) :-
    retractall(clave(Nombre, _, _)),
    assertz(clave(Nombre, ninguna, Publica)).

%!  compartir(+Autor, +Otro) is semidet.
%
%   Guarda con el nombre Otro la clave pública de Autor, como la guarda
%   quien la recibe: sin la clave privada.
compartir(Autor, Otro) :-
    exportar(Autor, Publica),
    importar(Otro, Publica).

%!  privada(+Nombre, -Privada) is semidet.
%
%   Privada es la clave privada guardada con Nombre; falla si el llavero
%   solo tiene la pública.
privada(Nombre, Privada) :-
    clave(Nombre, Privada, _),
    Privada \== ninguna.

%!  huella(+Nombre, -Huella:atom) is semidet.
%
%   Huella son los primeros 16 dígitos del resumen de N y E de la clave
%   pública guardada con Nombre, en grupos de cuatro: lo que se dicta o se
%   compara a simple vista para comprobar, por otro canal, que una clave
%   pública es la que se espera.
huella(Nombre, Huella) :-
    exportar(Nombre, public_key(rsa(HN, HE, _, _, _, _, _, _))),
    format(atom(Datos), "~w:~w", [HN, HE]),
    resumen(Datos, Hex),
    sub_atom(Hex, 0, 16, _, Corto),
    atom_codes(Corto, Cs),
    grupos(Cs, Gs),
    atomic_list_concat(Gs, ':', Huella).

%!  grupos(+Codigos:list, -Grupos:list(atom)) is det.
%
%   Grupos son los Codigos de a cuatro, cada grupo un átomo.
grupos([], []).
grupos([A, B, C, D|Cs], [G|Gs]) :-
    atom_codes(G, [A, B, C, D]),
    grupos(Cs, Gs).

% --- Firmas -----------------------------------------------------------------

%!  firmar_texto(+Nombre, +Texto, -Firma:atom) is semidet.
%
%   Firma es la firma RSA de Texto con la clave privada de Nombre, en
%   hexadecimal: la del resumen SHA-256 de Texto, con el relleno de
%   PKCS #1 v1.5. Falla si el llavero no tiene la clave privada.
firmar_texto(Nombre, Texto, Firma) :-
    privada(Nombre, Privada),
    resumen(Texto, Hex),
    rsa_sign(Privada, Hex, F, [type(sha256)]),
    atom_string(Firma, F).

%!  verificar_texto(+Nombre, +Texto, +Firma) is semidet.
%
%   Firma es una firma válida de Texto hecha con la clave privada que
%   corresponde a la clave pública guardada con Nombre.
verificar_texto(Nombre, Texto, Firma) :-
    exportar(Nombre, Publica),
    resumen(Texto, Hex),
    rsa_verify(Publica, Hex, Firma, [type(sha256)]).

%!  bloque_firmado(+Nombre, +Firma, -Bloque:atom) is semidet.
%
%   Bloque es lo que la firma cifra: Firma^E mod N, con la clave pública
%   de Nombre, como hace verificar/3 de rsa.pl, escrito en hexadecimal con
%   el ancho del módulo.
bloque_firmado(Nombre, Firma, Bloque) :-
    exportar(Nombre, Publica),
    publica(Publica, publica(N, E)),
    hex_numero(Firma, S),
    M is powm(S, E, N),
    Ancho is (msb(N) + 8) // 8 * 2,
    format(atom(Bloque), "~`0t~16r~*|", [M, Ancho]).

%!  relleno_pkcs1(+Bloque:atom, -Hex:atom) is semidet.
%
%   Bloque tiene el formato de una firma SHA-256 de PKCS #1 v1.5: 0001,
%   bytes ff, un byte 00, el identificador de SHA-256 y el resumen Hex.
relleno_pkcs1(Bloque, Hex) :-
    atom_concat('0001', Resto, Bloque),
    atom_codes(Resto, Cs),
    phrase(relleno(Hex), Cs).

%!  relleno(-Hex:atom)// is semidet.
%
%   Los bytes ff, al menos ocho, el separador 00, el identificador de
%   SHA-256 y los 64 dígitos del resumen.
relleno(Hex) -->
    unos(K),
    { K >= 8 },
    "00",
    "3031300d060960864801650304020105000420",
    resto(Cs),
    { length(Cs, 64), atom_codes(Hex, Cs) }.

%!  unos(-K:integer)// is det.
%
%   K bytes ff seguidos: todos los que hay.
unos(K) -->
    "ff",
    !,
    unos(K0),
    { K is K0 + 1 }.
unos(0) -->
    [].

%!  resto(-Cs:list)// is det.
%
%   Cs son todos los códigos que quedan.
resto(Cs, Cs, []).

%!  publicar(+Dir, +Nombre, +Destino) is semidet.
%
%   Escribe en el directorio Destino, una ruta o un alias como
%   entregas(fechas), el manifiesto de Dir, SHA256SUMS, y su firma con la
%   clave privada de Nombre, SHA256SUMS.firma; crea Destino si no existe.
%   Falla sin escribir nada si el llavero no tiene la clave privada.
publicar(Dir, Nombre, Destino0) :-
    manifiesto(Dir, Entradas),
    manifiesto_texto(Entradas, Texto),
    firmar_texto(Nombre, Texto, Firma),
    absolute_file_name(Destino0, Destino),
    make_directory_path(Destino),
    directory_file_path(Destino, 'SHA256SUMS', Sumas),
    directory_file_path(Destino, 'SHA256SUMS.firma', ArchivoFirma),
    escribir(Sumas, Texto),
    escribir(ArchivoFirma, Firma).

%!  escribir(+Archivo, +Texto) is det.
%
%   Archivo contiene Texto, en UTF-8 y con fines de línea LF.
escribir(Archivo, Texto) :-
    setup_call_cleanup(
        open(Archivo, write, S, [encoding(utf8), newline(posix)]),
        write(S, Texto),
        close(S)).

%!  comprobar_entrega(+Dir, +Destino, +Nombre, -Resultado) is det.
%
%   Resultado juzga el directorio Dir contra SHA256SUMS y SHA256SUMS.firma
%   de Destino: firma_invalida si la firma no corresponde al manifiesto con
%   la clave pública de Nombre; si corresponde, intacta o
%   alterada(Cambios), con Cambios el informe de verificar/3 sin los
%   archivos iguales.
comprobar_entrega(Dir, Destino0, Nombre, Resultado) :-
    absolute_file_name(Destino0, Destino, [file_type(directory)]),
    directory_file_path(Destino, 'SHA256SUMS', Sumas),
    directory_file_path(Destino, 'SHA256SUMS.firma', ArchivoFirma),
    read_file_to_string(Sumas, Texto, [encoding(utf8)]),
    read_file_to_string(ArchivoFirma, Firma0, []),
    split_string(Firma0, "", " \n", [Firma]),
    (   verificar_texto(Nombre, Texto, Firma),
        texto_manifiesto(Texto, Entradas)
    ->  verificar(Dir, Entradas, Informe),
        exclude(igual, Informe, Cambios),
        (   Cambios == []
        ->  Resultado = intacta
        ;   Resultado = alterada(Cambios)
        )
    ;   Resultado = firma_invalida
    ).

%!  igual(+Estado) is semidet.
%
%   Estado es igual(_), un archivo sin cambios.
igual(igual(_)).
