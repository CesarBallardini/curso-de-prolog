:- encoding(utf8).

% Capítulo 82 - Versión 4: RSA con enteros.
%
% Un par de claves RSA sale de dos primos P y Q: la clave pública es
% publica(N, E), con N = P*Q, y la privada es privada(N, D), con D el
% inverso de E módulo (P-1)*(Q-1). Cifrar un entero M menor que N es
% elevarlo a E módulo N, y descifrar es elevar a D; firmar es elevar a D, y
% verificar, elevar la firma a E y comparar. Todo es aritmética de enteros
% de precisión arbitraria: los primos se buscan con la prueba de
% Miller-Rabin, y el inverso, con el algoritmo de Euclides extendido.
%
% Así escrito, RSA tiene dos debilidades que el archivo muestra: cifrar es
% determinista, de modo que un mensaje de pocos valores posibles se
% adivina cifrando cada uno; y el producto de dos firmas es la firma del
% producto de los mensajes. La versión 5 usa las firmas de library(crypto),
% que firman un resumen con relleno.
%
%?- claves(61, 53, 17, Pub, Priv), cifrar(65, Pub, C), descifrar(C, Priv, M).
%?- primo_desde(1000000, P).
%?- texto_entero("Hola", N), entero_texto(N, T).

:- module(rsa,
          [ euclides/5,
            inverso/3,
            primo/1,
            primo_desde/2,
            primo_aleatorio/2,
            claves/5,
            claves_aleatorias/3,
            clave_de_ejemplo/2,
            cifrar/3,
            descifrar/3,
            firmar/3,
            verificar/3,
            texto_entero/2,
            entero_texto/2,
            adivinar/4,
            falsificar/4
          ]).

:- use_module(library(lists)).
:- use_module(library(apply)).
:- use_module(library(utf8)).


%!  euclides(+A:integer, +B:integer, -G:integer, -X:integer, -Y:integer)
%!      is det.
%
%   G es el máximo común divisor de A y B, y A*X + B*Y = G.
euclides(A, B, G, X, Y) :-
    B =:= 0,
    !,
    G = A,
    X = 1,
    Y = 0.
euclides(A, B, G, X, Y) :-
    Q is A // B,
    R is A mod B,
    euclides(B, R, G, X1, Y1),
    X = Y1,
    Y is X1 - Q * Y1.

%!  inverso(+A:integer, +M:integer, -X:integer) is semidet.
%
%   X, entre 0 y M-1, es el inverso de A módulo M: A*X mod M = 1. Falla si
%   A y M tienen un divisor común.
inverso(A, M, X) :-
    euclides(A, M, G, X0, _),
    G =:= 1,
    X is X0 mod M.

% base(B): las bases de la prueba de Miller-Rabin, los doce primeros
% primos. Con ellas la prueba es exacta para N menor que 3,3 * 10^24, y
% para N mayor la probabilidad de aceptar un compuesto es despreciable.
base(2).
base(3).
base(5).
base(7).
base(11).
base(13).
base(17).
base(19).
base(23).
base(29).
base(31).
base(37).

%!  primo(+N:integer) is semidet.
%
%   N es primo según la prueba de Miller-Rabin con las bases de base/1.
primo(N) :-
    N >= 2,
    (   base(N)
    ->  true
    ;   \+ ( base(B), N mod B =:= 0 ),
        descomponer(N, S, D),
        forall(base(B), testigo_no(B, N, S, D))
    ).

%!  descomponer(+N:integer, -S:integer, -D:integer) is det.
%
%   N - 1 = 2^S * D, con D impar.
descomponer(N, S, D) :-
    N1 is N - 1,
    S is lsb(N1),
    D is N1 >> S.

%!  testigo_no(+B:integer, +N:integer, +S:integer, +D:integer) is semidet.
%
%   La base B no prueba que N es compuesto: B^D mod N es 1, o alguno de
%   los S cuadrados sucesivos de B^D es N - 1.
testigo_no(B, N, S, D) :-
    X is powm(B, D, N),
    N1 is N - 1,
    (   ( X =:= 1 ; X =:= N1 )
    ->  true
    ;   cuadrados(S, X, N)
    ).

%!  cuadrados(+S:integer, +X:integer, +N:integer) is semidet.
%
%   Alguno de los S - 1 cuadrados sucesivos de X módulo N es N - 1.
cuadrados(S, X, N) :-
    S > 1,
    Y is X * X mod N,
    (   Y =:= N - 1
    ->  true
    ;   S1 is S - 1,
        cuadrados(S1, Y, N)
    ).

%!  primo_desde(+N:integer, -P:integer) is det.
%
%   P es el menor primo mayor o igual que N.
primo_desde(N, P) :-
    (   primo(N)
    ->  P = N
    ;   N1 is N + 1,
        primo_desde(N1, P)
    ).

%!  primo_aleatorio(+Bits:integer, -P:integer) is det.
%
%   P es un primo de Bits bits: el primero desde un número aleatorio cuyos
%   dos bits más altos son 1, para que el producto de dos de ellos tenga
%   el doble de bits. El generador de números aleatorios no es
%   criptográfico; las claves reales usan crypto_generate_prime/3.
primo_aleatorio(Bits, P) :-
    Min is 3 << (Bits - 2),
    Max is (1 << Bits) - 1,
    repeat,
    random_between(Min, Max, N0),
    primo_desde(N0, P),
    P =< Max,
    !.

%!  claves(+P:integer, +Q:integer, +E:integer, -Publica, -Privada)
%!      is semidet.
%
%   Publica es publica(N, E) y Privada es privada(N, D), con N = P*Q y D
%   el inverso de E módulo (P-1)*(Q-1). Falla si E tiene un divisor común
%   con (P-1)*(Q-1).
claves(P, Q, E, publica(N, E), privada(N, D)) :-
    N is P * Q,
    Fi is (P - 1) * (Q - 1),
    inverso(E, Fi, D).

%!  claves_aleatorias(+Bits:integer, -Publica, -Privada) is det.
%
%   Un par de claves con un N de Bits bits y E = 65537, el exponente que
%   usan casi todas las claves RSA.
claves_aleatorias(Bits, Publica, Privada) :-
    Mitad is Bits // 2,
    repeat,
    primo_aleatorio(Mitad, P),
    primo_aleatorio(Mitad, Q),
    P =\= Q,
    claves(P, Q, 65537, Publica, Privada),
    !.

%!  clave_de_ejemplo(-Publica, -Privada) is det.
%
%   Un par de claves fijo, con primos de 20 dígitos: demasiado pequeño
%   para proteger nada, pero de un tamaño que se lee en una consulta.
clave_de_ejemplo(Publica, Privada) :-
    primo_desde(10000000000000000000, P),
    primo_desde(30000000000000000000, Q),
    claves(P, Q, 65537, Publica, Privada).

%!  cifrar(+M:integer, +Publica, -C:integer) is det.
%
%   C es M^E mod N. M debe estar entre 0 y N-1.
cifrar(M, publica(N, E), C) :-
    C is powm(M, E, N).

%!  descifrar(+C:integer, +Privada, -M:integer) is det.
%
%   M es C^D mod N.
descifrar(C, privada(N, D), M) :-
    M is powm(C, D, N).

%!  firmar(+M:integer, +Privada, -S:integer) is det.
%
%   S es la firma de M: M^D mod N.
firmar(M, privada(N, D), S) :-
    S is powm(M, D, N).

%!  verificar(+M:integer, +S:integer, +Publica) is semidet.
%
%   S es una firma válida de M para Publica: S^E mod N es M.
verificar(M, S, publica(N, E)) :-
    M =:= powm(S, E, N).

%!  texto_entero(+Texto, -N:integer) is det.
%
%   N es el entero cuyos dígitos en base 256 son los bytes de Texto en
%   UTF-8, el primero el más significativo.
texto_entero(Texto, N) :-
    atom_codes(Texto, Codigos),
    phrase(utf8_codes(Codigos), Bytes),
    foldl(digito256, Bytes, 0, N).

%!  digito256(+B:integer, +N0:integer, -N:integer) is det.
%
%   N agrega el dígito B a la derecha de N0, en base 256.
digito256(B, N0, N) :-
    N is N0 * 256 + B.

%!  entero_texto(+N:integer, -Texto:string) is det.
%
%   Texto es el texto cuyos bytes en UTF-8 son los dígitos de N en base
%   256: la conversión inversa de texto_entero/2.
entero_texto(N, Texto) :-
    bytes(N, [], Bytes),
    phrase(utf8_codes(Codigos), Bytes),
    string_codes(Texto, Codigos).

%!  bytes(+N:integer, +Bs0:list, -Bs:list) is det.
%
%   Bs son los dígitos de N en base 256 seguidos de Bs0.
bytes(0, Bs, Bs) :-
    !.
bytes(N, Bs0, Bs) :-
    B is N /\ 255,
    N1 is N >> 8,
    bytes(N1, [B|Bs0], Bs).

%!  adivinar(+C:integer, +Publica, +Opciones:list, -Texto) is semidet.
%
%   Texto es la opción de Opciones cuyo cifrado es C. Cifrar con RSA sin
%   relleno es determinista: quien conoce las opciones posibles las cifra
%   con la clave pública y compara, sin la clave privada.
adivinar(C, Publica, Opciones, Texto) :-
    member(Texto, Opciones),
    texto_entero(Texto, M),
    cifrar(M, Publica, C),
    !.

%!  falsificar(+S1:integer, +S2:integer, +Publica, -S:integer) is det.
%
%   S es S1*S2 mod N. Si S1 firma M1 y S2 firma M2, S firma M1*M2 mod N,
%   un mensaje que el dueño de la clave nunca firmó.
falsificar(S1, S2, publica(N, _), S) :-
    S is S1 * S2 mod N.
