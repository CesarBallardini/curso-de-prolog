:- encoding(utf8).

% Capítulo 82 - Versión 1: la integridad, con resúmenes criptográficos.
%
% Un resumen (hash) SHA-256 de unos datos es una cadena de 64 dígitos
% hexadecimales, 256 bits, que cambia por completo si cambia un solo bit
% de los datos. Un manifiesto es la lista de los archivos de un directorio
% con el resumen de cada uno, en el formato de la orden sha256sum: quien
% recibe el directorio y el manifiesto recalcula los resúmenes y detecta
% cualquier archivo modificado, agregado o faltante. El directorio de
% ejemplo es el pack del capítulo 31, que se nombra con el alias
% paquete31: paquete31(fechas_castellano).
%
% solo-local: lee archivos y directorios.
%
%?- resumen("Inscripciones", H).
%?- manifiesto(paquete31(fechas_castellano), Es).

:- module(resumenes,
          [ resumen/2,
            resumen_archivo/2,
            bits_distintos/3,
            archivos/2,
            manifiesto/2,
            manifiesto_texto/2,
            texto_manifiesto/2,
            verificar/3,
            intacto/2,
            pack_31/1
          ]).

:- use_module(library(crypto)).
:- use_module(library(lists)).
:- use_module(library(apply)).
:- use_module(library(ordsets)).
:- use_module(library(dcg/basics), [string_without//2]).

%!  resumen(+Datos, -Hex:atom) is det.
%!  resumen(+Datos, +Hex:atom) is semidet.
%
%   Hex es el resumen SHA-256 de Datos, un texto (átomo, cadena o lista de
%   códigos) tomado en UTF-8, como 64 dígitos hexadecimales. El resumen se
%   calcula en una variable nueva y después se unifica, porque
%   crypto_data_hash/3, si recibe un resumen instanciado distinto del que
%   calcula, da un error en lugar de fallar.
resumen(Datos, Hex) :-
    crypto_data_hash(Datos, H, [algorithm(sha256)]),
    Hex = H.

%!  resumen_archivo(+Archivo, -Hex:atom) is det.
%!  resumen_archivo(+Archivo, +Hex:atom) is semidet.
%
%   Hex es el resumen SHA-256 de los bytes de Archivo. La opción
%   encoding(octet) es imprescindible: sin ella, crypto_file_hash/3 toma
%   cada byte leído como un carácter y lo codifica en UTF-8, y el resumen
%   de un archivo con bytes mayores que 127 no es el de sus bytes.
resumen_archivo(Archivo, Hex) :-
    crypto_file_hash(Archivo, H, [algorithm(sha256), encoding(octet)]),
    Hex = H.

%!  bits_distintos(+Hex1:atom, +Hex2:atom, -N:integer) is det.
%
%   N es la cantidad de bits en que difieren dos resúmenes de igual
%   longitud: la cantidad de unos del o exclusivo de los dos números.
bits_distintos(Hex1, Hex2, N) :-
    hex_entero(Hex1, A),
    hex_entero(Hex2, B),
    N is popcount(A xor B).

%!  hex_entero(+Hex:atom, -N:integer) is det.
%
%   N es el entero que escriben los dígitos hexadecimales de Hex.
hex_entero(Hex, N) :-
    atom_concat('0x', Hex, Texto),
    atom_number(Texto, N).

%   paquete31(Dir): el alias del directorio de los packs del capítulo 31.
:- multifile user:file_search_path/2.
:- prolog_load_context(directory, Aqui),
   atom_concat(Aqui, '/../capitulo-31/paquete', Dir),
   assertz(user:file_search_path(paquete31, Dir)).

%!  pack_31(-Dir:atom) is det.
%
%   Dir es la ruta absoluta del pack fechas_castellano del capítulo 31.
pack_31(Dir) :-
    directorio(paquete31(fechas_castellano), Dir).

%!  directorio(+Dir0, -Dir:atom) is det.
%
%   Dir es la ruta absoluta del directorio Dir0, una ruta o un alias como
%   paquete31(fechas_castellano).
directorio(Dir0, Dir) :-
    absolute_file_name(Dir0, Dir, [file_type(directory)]).

%!  archivos(+Dir, -Rutas:list(atom)) is det.
%
%   Rutas son los archivos que hay debajo de Dir, una ruta o un alias, en
%   cualquier nivel, con la ruta relativa a Dir y separada por /, en orden
%   alfabético.
archivos(Dir0, Rutas) :-
    directorio(Dir0, Dir),
    findall(R, archivo_bajo(Dir, '', R), Rs),
    sort(Rs, Rutas).

%!  archivo_bajo(+Dir, +Prefijo:atom, -Ruta:atom) is nondet.
%
%   Ruta es un archivo debajo de Dir, con Prefijo delante.
archivo_bajo(Dir, Prefijo, Ruta) :-
    directory_files(Dir, Nombres),
    member(Nombre, Nombres),
    \+ memberchk(Nombre, ['.', '..']),
    directory_file_path(Dir, Nombre, Camino),
    atom_concat(Prefijo, Nombre, Relativa),
    (   exists_directory(Camino)
    ->  atom_concat(Relativa, '/', Prefijo1),
        archivo_bajo(Camino, Prefijo1, Ruta)
    ;   Ruta = Relativa
    ).

%!  manifiesto(+Dir, -Entradas:list) is det.
%
%   Entradas son los pares Ruta-Hex de los archivos de Dir, en el orden de
%   archivos/2, con el resumen SHA-256 de cada uno.
manifiesto(Dir0, Entradas) :-
    directorio(Dir0, Dir),
    archivos(Dir, Rutas),
    maplist(entrada(Dir), Rutas, Entradas).

%!  entrada(+Dir, +Ruta:atom, -Entrada:pair) is det.
%
%   Entrada es Ruta-Hex, con Hex el resumen del archivo Ruta de Dir.
entrada(Dir, Ruta, Ruta-Hex) :-
    directory_file_path(Dir, Ruta, Camino),
    resumen_archivo(Camino, Hex).

%!  manifiesto_texto(+Entradas:list, -Texto:string) is det.
%
%   Texto es el manifiesto en el formato de sha256sum: una línea por
%   archivo, con el resumen, dos espacios y la ruta.
manifiesto_texto(Entradas, Texto) :-
    with_output_to(string(Texto),
                   forall(member(Ruta-Hex, Entradas),
                          format("~w  ~w~n", [Hex, Ruta]))).

%!  texto_manifiesto(+Texto, -Entradas:list) is semidet.
%
%   Entradas son los pares Ruta-Hex que escribe Texto, en el formato de
%   sha256sum. Falla si alguna línea no tiene ese formato.
texto_manifiesto(Texto, Entradas) :-
    string_codes(Texto, Codigos),
    phrase(lineas(Entradas), Codigos).

%!  lineas(-Entradas:list)// is semidet.
%
%   Las líneas de un manifiesto, cada una terminada en un fin de línea.
lineas([Ruta-Hex|Es]) -->
    linea(Ruta, Hex),
    !,
    lineas(Es).
lineas([]) -->
    [].

%!  linea(-Ruta:atom, -Hex:atom)// is semidet.
%
%   Una línea: 64 dígitos hexadecimales, dos espacios, la ruta y el fin
%   de línea.
linea(Ruta, Hex) -->
    digitos_hex(Ds),
    { length(Ds, 64), atom_codes(Hex, Ds) },
    "  ",
    string_without("\n", Cs),
    { Cs \== [], atom_codes(Ruta, Cs) },
    "\n".

%!  digitos_hex(-Codigos:list)// is det.
%
%   Los dígitos hexadecimales que siguen, todos los que haya.
digitos_hex([C|Cs]) -->
    [C],
    { code_type(C, xdigit(_)) },
    !,
    digitos_hex(Cs).
digitos_hex([]) -->
    [].

%!  verificar(+Dir, +Entradas:list, -Informe:list) is det.
%
%   Informe compara los archivos de Dir con el manifiesto Entradas: un
%   término por ruta, en orden alfabético, igual(R) o distinto(R) para los
%   archivos que están en los dos, falta(R) para los del manifiesto que no
%   están en Dir y sobra(R) para los de Dir que no están en el manifiesto.
verificar(Dir, Entradas, Informe) :-
    manifiesto(Dir, Actual),
    pairs_keys(Entradas, Esperadas),
    pairs_keys(Actual, Presentes),
    list_to_ord_set(Esperadas, E),
    list_to_ord_set(Presentes, P),
    ord_union(E, P, Todas),
    maplist(estado(Entradas, Actual), Todas, Informe).

%!  estado(+Entradas:list, +Actual:list, +Ruta:atom, -Estado) is det.
%
%   Estado es igual(Ruta), distinto(Ruta), falta(Ruta) o sobra(Ruta).
estado(Entradas, Actual, Ruta, Estado) :-
    (   memberchk(Ruta-H1, Entradas)
    ->  (   memberchk(Ruta-H2, Actual)
        ->  (   H1 == H2
            ->  Estado = igual(Ruta)
            ;   Estado = distinto(Ruta)
            )
        ;   Estado = falta(Ruta)
        )
    ;   Estado = sobra(Ruta)
    ).

%!  intacto(+Dir, +Entradas:list) is semidet.
%
%   Los archivos de Dir son exactamente los del manifiesto Entradas, y
%   cada uno tiene el resumen que el manifiesto registra.
intacto(Dir, Entradas) :-
    verificar(Dir, Entradas, Informe),
    forall(member(E, Informe), E = igual(_)).
