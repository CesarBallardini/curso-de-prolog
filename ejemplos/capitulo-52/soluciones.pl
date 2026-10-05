:- encoding(utf8).

% Capítulo 52 - Soluciones de los ejercicios.
%
% Carga el programa terminado y agrega máquinas con cláusulas de
% plana:fila/5 y perezosa:alias/3.
%
% solo-local: carga módulos propios, y SWISH no los admite.
%
%?- figuras(tres, b, 9, Fs).
%?- figuras(ceros_unos, inicio, 12, Fs).
%?- figuras_dn(31332531173113353111731113322531111731111335317, 6, Fs).

:- use_module(universal).
:- use_module(plana, [fila/5]).

% Ejercicio 2: la sucesión 001001001...
plana:fila(tres, b, blanco, [p(0), r, r], c).
plana:fila(tres, c, blanco, [p(0), r, r], d).
plana:fila(tres, d, blanco, [p(1), r, r], b).

% Ejercicio 3: 01 0011 000111 ..., un bloque de K ceros y K unos.
plana:fila(ceros_unos, inicio, siempre, [p(schwa), r, p(schwa)],
           bloque(s(cero))).
perezosa:alias(ceros_unos, bloque(K), ceros(K, unos(K, bloque(s(K))))).
perezosa:alias(ceros_unos, ceros(cero, C), C).
perezosa:alias(ceros_unos, ceros(s(K), C), pe(ceros(K, C), 0)).
perezosa:alias(ceros_unos, unos(cero, C), C).
perezosa:alias(ceros_unos, unos(s(K), C), pe(unos(K, C), 1)).

% Ejercicio 4: cr(C, B, Al) y cr(B, Al) de Turing, con la letra a como
% marca provisoria.
perezosa:alias(_, cr(C, B, Al), c(re(C, B, Al, a), B, Al)).
perezosa:alias(_, cr(B, Al), cr(cr(B, Al), re(B, a, Al), Al)).

% Ejercicio 11: el contador que no vuelve al comienzo de la cinta.
plana:fila(rapido, inicio, siempre, [p(schwa), r, p(schwa), r], bloque(cero)).
plana:fila(rapido, bloque(K), siempre, [p(0), r, r], unos(K, bloque(s(K)))).
plana:fila(rapido, unos(s(K), C), siempre, [p(1), r, r], unos(K, C)).
perezosa:alias(rapido, unos(cero, C), C).

%!  resolver_seguro(+M, +Q0, -Q, -N:integer) is det.
%
%   Como resolver/4, pero lanza error(ciclo_de_alias(Q1), _) si la
%   reescritura vuelve a una configuración Q1 por la que ya pasó.
resolver_seguro(M, Q0, Q, N) :-
    resolver_seguro(M, Q0, [Q0], Q, 0, N).

%!  resolver_seguro(+M, +Q0, +Vistas:list, -Q, +N0, -N) is det.
%
%   Como resolver_seguro/4, con las configuraciones Vistas y N0
%   reescrituras hechas antes.
resolver_seguro(M, Q0, Vistas, Q, N0, N) :-
    (   alias(M, Q0, Q1)
    ->  (   memberchk(Q1, Vistas)
        ->  throw(error(ciclo_de_alias(Q1), _))
        ;   N1 is N0 + 1,
            resolver_seguro(M, Q1, [Q1|Vistas], Q, N1, N)
        )
    ;   Q = Q0,
        N = N0
    ).

% Ejercicio 5: dos alias que se reescriben el uno en el otro.
perezosa:alias(circular, uno, dos(x)).
perezosa:alias(circular, dos(x), uno).

:- table alcanzable/4.

%!  alcanzable(+M, +Q0, +Alfabeto:list, ?Q) is nondet.
%
%   Q es una configuración a la que M llega desde Q0 con los símbolos
%   del Alfabeto y el blanco. No termina si son infinitas.
alcanzable(_, Q0, _, Q0).
alcanzable(M, Q0, Alfabeto, Q) :-
    alcanzable(M, Q0, Alfabeto, Q1),
    member(S, [blanco|Alfabeto]),
    transicion(M, Q1, S, _, Q).

%!  instrucciones_sd(-Is:list)// is nondet.
%
%   Is son las instrucciones i(I, J, K, Mov, M) de una descripción
%   estándar: las configuraciones y los símbolos son números.
instrucciones_sd([I|Is]) -->
    instruccion_sd(I),
    instrucciones_sd(Is).
instrucciones_sd([]) -->
    [].

%!  instruccion_sd(-I)// is nondet.
%
%   I es una instrucción de la descripción estándar.
instruccion_sd(i(I, J, K, Mov, M)) -->
    "D", cuenta(0'A, I),
    "D", cuenta(0'C, J),
    "D", cuenta(0'C, K),
    mov_sd(Mov),
    "D", cuenta(0'A, M),
    ";".

%!  cuenta(+C, -N:integer)// is nondet.
%
%   N repeticiones del carácter de código C; primero la más larga.
cuenta(C, N) -->
    [C],
    cuenta(C, N0),
    { N is N0 + 1 }.
cuenta(_, 0) -->
    [].

% mov_sd(Mov): el movimiento que escribe cada letra.
mov_sd(l) --> "L".
mov_sd(r) --> "R".
mov_sd(n) --> "N".

%!  sd_numero(?SD:string, ?N:integer) is det.
%
%   N es el número de descripción de la descripción estándar SD. Uno de
%   los dos tiene que llegar instanciado.
sd_numero(SD, N) :-
    (   nonvar(SD)
    ->  string_codes(SD, Letras),
        maplist(letra_digito, Letras, Digitos),
        number_codes(N, Digitos)
    ;   number_codes(N, Digitos),
        maplist(letra_digito, Letras, Digitos),
        string_codes(SD, Letras)
    ).

% letra_digito(L, D): la letra L de la descripción estándar es el dígito D.
letra_digito(0'A, 0'1).
letra_digito(0'C, 0'2).
letra_digito(0'D, 0'3).
letra_digito(0'L, 0'4).
letra_digito(0'R, 0'5).
letra_digito(0'N, 0'6).
letra_digito(0';, 0'7).

%!  instrucciones_de(+SD:string, -Is:list) is semidet.
%
%   Is son las instrucciones de la descripción estándar SD.
instrucciones_de(SD, Is) :-
    string_codes(SD, Codigos),
    once(phrase(instrucciones_sd(Is), Codigos)).

%!  figuras_dn(+DN:integer, +N:integer, -Fs:list) is semidet.
%
%   Fs son las primeras N figuras que imprime la máquina cuyo número de
%   descripción es DN, desde la configuración 1 con la cinta en blanco.
%   El símbolo 0 es el blanco, el 1 es la figura 0, el 2 es la figura 1,
%   y el j, para j mayor que 2, es s(j).
figuras_dn(DN, N, Fs) :-
    sd_numero(SD, DN),
    instrucciones_de(SD, Is0),
    maplist(instruccion_estandar, Is0, Is),
    figuras_estandar(tabla([1], Is), N, Fs).

%!  instruccion_estandar(+I0, -I) is det.
%
%   I es la instrucción numerada I0 con los símbolos del programa.
instruccion_estandar(i(Q, J, K, Mov, Q1), i(Q, S, e(W, Mov), Q1)) :-
    simbolo_numero(S, J),
    simbolo_numero(W, K).

%!  simbolo_numero(-S, +J:integer) is det.
%
%   S es el símbolo número J.
simbolo_numero(S, J) :-
    (   J =:= 0
    ->  S = blanco
    ;   J =:= 1
    ->  S = 0
    ;   J =:= 2
    ->  S = 1
    ;   S = s(J)
    ).

% Ejercicio 12: imprime 0 en un blanco y después imprime 1 sobre ese 0.
plana:fila(reimprime, b, blanco, [p(0)], c).
plana:fila(reimprime, c, simbolo(0), [p(1), r, r], b).

% Ejercicio 13: imprime un 0 y se detiene, porque c no tiene filas.
plana:fila(corta, b, blanco, [p(0), r], c).
