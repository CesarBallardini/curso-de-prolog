:- encoding(utf8).

% Capítulo 82 - Versión 6: un secreto acordado y un canal cifrado.
%
% Dos partes que nunca compartieron un secreto acuerdan uno por un canal
% que cualquiera escucha, con el intercambio de Diffie y Hellman: cada una
% elige un exponente secreto X, publica G^X mod P, y eleva lo que publica
% la otra a su propio exponente; las dos llegan a G^(X*Y) mod P. P es el
% primo de 2048 bits del grupo 14 del RFC 3526, y G = 2. Del secreto
% acordado, HKDF deriva dos claves independientes: una para cifrar y otra
% para autenticar.
%
% El cifrado es didáctico, armado con las piezas del capítulo: un flujo de
% bytes pseudoaleatorios, el HMAC de la clave de cifrado con el número de
% un solo uso (nonce) y un contador, se combina con el texto por o
% exclusivo; y el HMAC de la clave de autenticación sobre el nonce y el
% cifrado detecta cualquier alteración (cifrar y después autenticar). Un
% programa real usa un cifrado autenticado estándar, como
% ChaCha20-Poly1305 con crypto_data_encrypt/6.
%
% solo-local: carga fichas.pl.
%
%?- grupo(juguete, P, G), publico(juguete, 6, A), publico(juguete, 15, B).
%?- compartido(juguete, 6, 19, S), compartido(juguete, 15, 8, S).

:- module(acuerdo,
          [ grupo/3,
            secreto_aleatorio/1,
            publico/3,
            compartido/4,
            claves_de_sesion/2,
            acordar/3,
            flujo/4,
            cifrar/4,
            sellar/3,
            abrir/3,
            abrir_sin_mac/3,
            alterar/5
          ]).

:- use_module(library(crypto)).
:- use_module(library(lists)).
:- use_module(library(apply)).
:- use_module(library(utf8)).
:- use_module(fichas, [iguales/2]).

%!  grupo(?Nombre, -P:integer, -G:integer) is nondet.
%
%   P es el primo y G el generador del grupo Nombre: juguete, el ejemplo
%   de P = 23 y G = 5, o rfc3526_14, el grupo de 2048 bits del RFC 3526.
grupo(juguete, 23, 5).
grupo(rfc3526_14, P, 2) :-
    atomic_list_concat(
        [ '0xffffffffffffffffc90fdaa22168c234c4c6628b80dc1cd1',
          '29024e088a67cc74020bbea63b139b22514a08798e3404dd',
          'ef9519b3cd3a431b302b0a6df25f14374fe1356d6d51c245',
          'e485b576625e7ec6f44c42e9a637ed6b0bff5cb6f406b7ed',
          'ee386bfb5a899fa5ae9f24117c4b1fe649286651ece45b3d',
          'c2007cb8a163bf0598da48361c55d39a69163fa8fd24cf5f',
          '83655d23dca3ad961c62f356208552bb9ed529077096966d',
          '670c354e4abc9804f1746c08ca18217c32905e462e36ce3b',
          'e39e772c180e86039b2783a2ec07a28fb5c55df06f4c52c9',
          'de2bcbf6955817183995497cea956ae515d2261898fa0510',
          '15728e5a8aacaa68ffffffffffffffff' ], Hex),
    atom_number(Hex, P).

%!  secreto_aleatorio(-X:integer) is det.
%
%   X es un exponente secreto de 256 bits, de crypto_n_random_bytes/2.
secreto_aleatorio(X) :-
    crypto_n_random_bytes(32, Bytes),
    foldl([B, N0, N]>>(N is N0 * 256 + B), Bytes, 0, X).

%!  publico(+Grupo, +X:integer, -A:integer) is det.
%
%   A es G^X mod P, lo que publica quien eligió el exponente secreto X.
publico(Grupo, X, A) :-
    grupo(Grupo, P, G),
    !,
    A is powm(G, X, P).

%!  compartido(+Grupo, +X:integer, +B:integer, -S:integer) is semidet.
%
%   S es B^X mod P: el secreto acordado, para quien eligió X y recibió B.
%   Falla si B no está entre 2 y P-2, un valor que fijaría S.
compartido(Grupo, X, B, S) :-
    grupo(Grupo, P, _),
    !,
    B > 1,
    B < P - 1,
    S is powm(B, X, P).

%!  claves_de_sesion(+S:integer, -Claves) is det.
%
%   Claves es claves(Kc, Ka), dos claves de 32 bytes en hexadecimal
%   derivadas del secreto acordado S con HKDF-SHA256: Kc para cifrar y Ka
%   para autenticar. La etiqueta info/1 las hace independientes.
claves_de_sesion(S, claves(Kc, Ka)) :-
    format(atom(Material), "~16r", [S]),
    derivar(Material, cifrado, Kc),
    derivar(Material, autenticacion, Ka).

%!  acordar(+Grupo, -ClavesA, -ClavesB) is det.
%
%   Simula el acuerdo completo entre A y B en Grupo: cada uno elige su
%   exponente secreto, publica su valor, calcula el secreto con el valor
%   del otro y deriva sus claves de sesión. ClavesA y ClavesB son las
%   claves a las que llega cada uno; por el canal pasan solo los valores
%   públicos.
acordar(Grupo, ClavesA, ClavesB) :-
    secreto_aleatorio(X),
    secreto_aleatorio(Y),
    publico(Grupo, X, A),
    publico(Grupo, Y, B),
    compartido(Grupo, X, B, SA),
    compartido(Grupo, Y, A, SB),
    claves_de_sesion(SA, ClavesA),
    claves_de_sesion(SB, ClavesB).

%!  derivar(+Material, +Etiqueta, -Clave:atom) is det.
%
%   Clave son 32 bytes de HKDF-SHA256 sobre Material con Etiqueta.
derivar(Material, Etiqueta, Clave) :-
    crypto_data_hkdf(Material, 32, Bytes,
                     [info(Etiqueta), algorithm(sha256)]),
    hex_bytes(Clave, Bytes).

%!  flujo(+Kc, +Nonce, +Largo:integer, -Bytes:list) is det.
%
%   Bytes son los primeros Largo bytes del flujo de la clave Kc y Nonce:
%   los bloques HMAC-SHA256(Kc, Nonce:0), HMAC-SHA256(Kc, Nonce:1), …,
%   de 32 bytes cada uno, uno detrás de otro.
flujo(Kc, Nonce, Largo, Bytes) :-
    Bloques is (Largo + 31) // 32,
    Ultimo is Bloques - 1,
    findall(Bs, ( between(0, Ultimo, I),
                  bloque(Kc, Nonce, I, Bs) ), Listas),
    append(Listas, Todos),
    length(Bytes, Largo),
    append(Bytes, _, Todos).

%!  bloque(+Kc, +Nonce, +I:integer, -Bytes:list) is det.
%
%   Bytes son los 32 bytes del bloque I del flujo.
bloque(Kc, Nonce, I, Bytes) :-
    format(atom(Datos), "~w:~d", [Nonce, I]),
    crypto_data_hash(Datos, Hex, [algorithm(sha256), hmac(Kc)]),
    hex_bytes(Hex, Bytes).

%!  cifrar(+Kc, +Nonce, +Bytes0:list, -Bytes:list) is det.
%
%   Bytes es el o exclusivo de Bytes0 con el flujo de Kc y Nonce. La misma
%   operación cifra y descifra.
cifrar(Kc, Nonce, Bytes0, Bytes) :-
    length(Bytes0, Largo),
    flujo(Kc, Nonce, Largo, Flujo),
    maplist([A, B, C]>>(C is A xor B), Bytes0, Flujo, Bytes).

%!  sellar(+Claves, +Texto, -Mensaje) is det.
%
%   Mensaje es mensaje(Nonce, Cifrado, Mac): Texto en UTF-8, cifrado con un
%   nonce aleatorio de 12 bytes, y el HMAC del nonce y el cifrado. Nonce,
%   Cifrado y Mac van en hexadecimal.
sellar(claves(Kc, Ka), Texto, mensaje(Nonce, Cifrado, Mac)) :-
    crypto_n_random_bytes(12, Ns),
    hex_bytes(Nonce, Ns),
    texto_bytes(Texto, Bytes0),
    cifrar(Kc, Nonce, Bytes0, Bytes),
    hex_bytes(Cifrado, Bytes),
    mac_mensaje(Ka, Nonce, Cifrado, Mac).

%!  texto_bytes(+Texto, -Bytes:list) is det.
%
%   Bytes son los bytes de Texto en UTF-8.
texto_bytes(Texto, Bytes) :-
    atom_codes(Texto, Codigos),
    phrase(utf8_codes(Codigos), Bytes).

%!  mac_mensaje(+Ka, +Nonce, +Cifrado, -Mac:atom) is det.
%
%   Mac es el HMAC-SHA256 con la clave Ka de Nonce:Cifrado.
mac_mensaje(Ka, Nonce, Cifrado, Mac) :-
    format(atom(Datos), "~w:~w", [Nonce, Cifrado]),
    crypto_data_hash(Datos, M, [algorithm(sha256), hmac(Ka)]),
    atom_string(Mac, M).

%!  abrir(+Claves, +Mensaje, -Texto:string) is semidet.
%
%   Texto es el texto de Mensaje, si su Mac corresponde al nonce y al
%   cifrado. El Mac se comprueba antes de descifrar; si no corresponde,
%   el mensaje fue alterado y abrir/3 falla sin descifrar nada.
abrir(claves(Kc, Ka), mensaje(Nonce, Cifrado, Mac), Texto) :-
    mac_mensaje(Ka, Nonce, Cifrado, Esperado),
    iguales(Mac, Esperado),
    hex_bytes(Cifrado, Bytes),
    cifrar(Kc, Nonce, Bytes, Bytes0),
    phrase(utf8_codes(Codigos), Bytes0),
    string_codes(Texto, Codigos).

%!  abrir_sin_mac(+Claves, +Mensaje, -Texto:string) is det.
%
%   Texto es el descifrado de Mensaje sin comprobar su Mac: lo que haría un
%   canal que solo cifra. Está para mostrar qué se pierde; no se usa para
%   abrir mensajes.
abrir_sin_mac(claves(Kc, _), mensaje(Nonce, Cifrado, _), Texto) :-
    hex_bytes(Cifrado, Bytes),
    cifrar(Kc, Nonce, Bytes, Bytes0),
    phrase(utf8_codes(Codigos), Bytes0),
    string_codes(Texto, Codigos).

%!  alterar(+Mensaje0, +Posicion:integer, +Viejo, +Nuevo, -Mensaje)
%!      is det.
%
%   Mensaje es Mensaje0 con el cifrado cambiado para que, al descifrarlo,
%   el texto Viejo que empieza en el byte Posicion (desde 0) se lea Nuevo,
%   de igual cantidad de bytes. Lo hace quien conoce esa parte del texto, sin
%   conocer las claves: el o exclusivo con Viejo y Nuevo. El Mac queda el
%   de Mensaje0.
alterar(mensaje(Nonce, Cifrado0, Mac), Posicion, Viejo, Nuevo,
        mensaje(Nonce, Cifrado, Mac)) :-
    hex_bytes(Cifrado0, Bytes0),
    texto_bytes(Viejo, V),
    texto_bytes(Nuevo, N),
    maplist([A, B, C]>>(C is A xor B), V, N, Delta),
    length(Antes, Posicion),
    append(Antes, Resto0, Bytes0),
    length(Delta, K),
    length(Medio0, K),
    append(Medio0, Despues, Resto0),
    maplist([A, B, C]>>(C is A xor B), Medio0, Delta, Medio),
    append([Antes, Medio, Despues], Bytes),
    hex_bytes(Cifrado, Bytes).
