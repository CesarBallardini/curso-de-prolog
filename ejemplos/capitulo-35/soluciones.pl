:- encoding(utf8).

% Capítulo 35 - Soluciones de los ejercicios 3 a 8 y 15.
%
% El archivo repite traducir/2 de gramatica.pl y desplegar/4 y plegar/4 de
% desplegar.pl, para cargarse solo. Contiene la expansión de tabla/2
% (ejercicio 3), las dos expansiones corregidas de escribir/1 y anotar/1
% (ejercicio 4), el traductor con cadenas y pushback (ejercicios 5 y 6), y
% las derivaciones de ultimo/2 y suma_largo/3 (ejercicios 7 y 8) y la de
% rotar_dif/2 (ejercicio 15).
%
%?- capital(peru, C).
%?- traducir((siguiente(C), [C] --> [C]), R).
%?- derivar_ultimo(Cs).
%?- derivar_rotar(Cs).

% Ejercicio 3

%!  term_expansion(+Termino, -Hechos:list) is semidet.
%
%   Un término tabla(Nombre, Pares) se carga como un hecho
%   Nombre(Clave, Valor) por cada par Clave-Valor de Pares.
term_expansion(tabla(Nombre, Pares), Hechos) :-
    findall(Hecho,
            ( member(Clave-Valor, Pares),
              Hecho =.. [Nombre, Clave, Valor] ),
            Hechos).

% tabla(Nombre, Pares): se carga como hechos capital/2.
tabla(capital, [chile-santiago, peru-lima]).

% Ejercicio 4

%!  goal_expansion(+Meta, -Expandida) is semidet.
%
%   escribir(X) se expande a una llamada a otro predicado, que ninguna
%   cláusula de goal_expansion/2 vuelve a expandir. anotar(X) se expande a
%   anotar(texto(X)) solo si X no es ya texto(_): el resultado no cumple la
%   condición, y la expansión se detiene.
goal_expansion(escribir(X), escribir_texto(texto(X))).
goal_expansion(anotar(X), anotar(texto(X))) :-
    X \= texto(_).

%!  escribir_texto(+T) is det.
%
%   Escribe T en una línea.
escribir_texto(T) :-
    format("~w~n", [T]).

%!  anotar(+T) is det.
%
%   Escribe T en una línea.
anotar(T) :-
    format("~w~n", [T]).

%!  saludar is det.
%
%   Escribe texto(hola) dos veces: sus dos llamadas se expandieron al
%   cargar.
saludar :-
    escribir(hola),
    anotar(hola).

% Ejercicios 5 y 6

%!  traducir(+Regla, -Clausula) is det.
%
%   Clausula es la traducción de Regla. Admite el pushback,
%   Cabeza, Terminales --> Cuerpo, y los terminales escritos como cadena.
traducir((Cabeza, Empuje --> Cuerpo), (Cabeza1 :- (Cuerpo1, S = Lista))) :-
    !,
    no_terminal(Cabeza, S0, S, Cabeza1),
    cuerpo(Cuerpo, S0, S1, Cuerpo1),
    append(Empuje, S1, Lista).
traducir((Cabeza --> Cuerpo), (Cabeza1 :- Cuerpo1)) :-
    no_terminal(Cabeza, S0, S, Cabeza1),
    cuerpo(Cuerpo, S0, S, Cuerpo1).

%!  cuerpo(+Cuerpo, ?S0, ?S, -Meta) is det.
%
%   Meta reconoce con Cuerpo la parte de S0 anterior a S.
cuerpo(Var, S0, S, phrase(Var, S0, S)) :-
    var(Var),
    !.
cuerpo((A, B), S0, S, (A1, B1)) :-
    !,
    cuerpo(A, S0, S1, A1),
    cuerpo(B, S1, S, B1).
cuerpo((A ; B), S0, S, (A1 ; B1)) :-
    !,
    cuerpo(A, S0, S, A1),
    cuerpo(B, S0, S, B1).
cuerpo(\+ A, S0, S, (\+ A1, S = S0)) :-
    !,
    cuerpo(A, S0, _, A1).
cuerpo({G}, S0, S, (G, S = S0)) :-
    !.
cuerpo(!, S0, S, (!, S = S0)) :-
    !.
cuerpo([], S0, S, S0 = S) :-
    !.
cuerpo([X|Xs], S0, S, S0 = Lista) :-
    !,
    append([X|Xs], S, Lista).
cuerpo(Cadena, S0, S, S0 = Lista) :-
    string(Cadena),
    !,
    string_codes(Cadena, Codigos),
    append(Codigos, S, Lista).
cuerpo(NoTerminal, S0, S, Meta) :-
    no_terminal(NoTerminal, S0, S, Meta).

%!  no_terminal(+NoTerminal, ?S0, ?S, -Meta) is det.
%
%   Meta es NoTerminal con S0 y S agregados al final de sus argumentos.
no_terminal(NoTerminal, S0, S, Meta) :-
    NoTerminal =.. Lista0,
    append(Lista0, [S0, S], Lista),
    Meta =.. Lista.

% Ejercicios 7 y 8

%!  desplegar(+Clausula, +N:integer, +Programa:list, -Clausulas:list) is det.
%
%   Clausulas son las resolventes de Clausula con las cláusulas de Programa
%   en el objetivo N de su cuerpo, contando desde 1.
desplegar((Cabeza :- Cuerpo), N, Programa, Clausulas) :-
    N1 is N - 1,
    length(Antes, N1),
    append(Antes, [Objetivo|Despues], Cuerpo),
    findall((Cabeza :- Cuerpo1),
            ( member(Clausula, Programa),
              copy_term(Clausula, (Objetivo :- CuerpoObjetivo)),
              append([Antes, CuerpoObjetivo, Despues], Cuerpo1) ),
            Clausulas).

%!  plegar(+Clausula, +N:integer, +Definicion, -Plegada) is semidet.
%
%   Plegada es Clausula con los objetivos desde la posición N, si son una
%   instancia del cuerpo de Definicion, reemplazados por su cabeza.
plegar((Cabeza :- Cuerpo), N, Definicion, (Cabeza :- Cuerpo1)) :-
    copy_term(Definicion, (CabezaDef :- CuerpoDef)),
    length(CuerpoDef, K),
    N1 is N - 1,
    length(Antes, N1),
    length(Medio, K),
    append(Antes, Resto, Cuerpo),
    append(Medio, Despues, Resto),
    subsumes_term(CuerpoDef, Medio),
    CuerpoDef = Medio,
    append(Antes, [CabezaDef|Despues], Cuerpo1).

% programa_append(P): P son las cláusulas de append/3 como datos.
programa_append([ (append([], L, L) :- []),
                  (append([X|Xs], Ys, [X|Zs]) :- [append(Xs, Ys, Zs)]) ]).

% definicion_ultimo(D): X es el último elemento de L.
definicion_ultimo((ultimo(X, L) :- [append(_, [X], L)])).

%!  derivar_ultimo(-Clausulas:list) is det.
%
%   Clausulas es la definición recursiva de ultimo/2: la definición
%   desplegada con append/3, con la segunda resolvente plegada.
derivar_ultimo([C1, C2]) :-
    definicion_ultimo(D),
    programa_append(P),
    desplegar(D, 1, P, [C1, C2a]),
    plegar(C2a, 1, D, C2).

%!  ultimo(?X, ?L:list) is nondet.
%
%   X es el último elemento de L: las cláusulas que obtiene
%   derivar_ultimo/1.
ultimo(X, [X]).
ultimo(X, [_|Zs]) :-
    ultimo(X, Zs).

% programa_suma_largo(P): suma/2 y largo/2 como datos.
programa_suma_largo([ (suma([], 0) :- []),
                      (suma([X|Xs], S) :- [suma(Xs, S0), S is S0 + X]),
                      (largo([], 0) :- []),
                      (largo([_|Xs], N) :- [largo(Xs, N0), N is N0 + 1]) ]).

% definicion_suma_largo(D): S es la suma y N la longitud de L.
definicion_suma_largo((suma_largo(L, S, N) :- [suma(L, S), largo(L, N)])).

%!  reordenar(+Clausula, +Orden:list(integer), -Reordenada) is det.
%
%   Reordenada tiene los objetivos del cuerpo de Clausula en el Orden
%   dado por sus posiciones, contando desde 1.
reordenar((Cabeza :- Cuerpo), Orden, (Cabeza :- Cuerpo1)) :-
    maplist(objetivo(Cuerpo), Orden, Cuerpo1).

%!  objetivo(+Cuerpo:list, +I:integer, -G) is det.
%
%   G es el objetivo I de Cuerpo, contando desde 1.
objetivo(Cuerpo, I, G) :-
    nth1(I, Cuerpo, G).

%!  derivar_suma_largo(-Clausulas:list) is det.
%
%   Clausulas es suma_largo/3 en una sola pasada: los dos objetivos
%   desplegados, el cuerpo reordenado y las dos llamadas plegadas.
derivar_suma_largo([C1, C2]) :-
    definicion_suma_largo(D),
    programa_suma_largo(P),
    desplegar(D, 1, P, [A1, A2]),
    desplegar(A1, 1, P, [C1]),
    desplegar(A2, 3, P, [B2]),
    reordenar(B2, [1, 3, 2, 4], B3),
    plegar(B3, 1, D, C2).

%!  suma_largo(+L:list(number), -S:number, -N:integer) is det.
%
%   S es la suma y N la cantidad de elementos de L, en una sola pasada: las
%   cláusulas que obtiene derivar_suma_largo/1.
suma_largo([], 0, 0).
suma_largo([X|Xs], S, N) :-
    suma_largo(Xs, S0, N0),
    S is S0 + X,
    N is N0 + 1.

%!  suma_largo_dos(+L:list(number), -S:number, -N:integer) is det.
%
%   La misma relación que suma_largo/3, con dos recorridos.
suma_largo_dos(L, S, N) :-
    suma(L, S),
    largo(L, N).

%!  suma(+L:list(number), -S:number) is det.
%
%   S es la suma de los números de L.
suma([], 0).
suma([X|Xs], S) :-
    suma(Xs, S0),
    S is S0 + X.

%!  largo(+L:list, -N:integer) is det.
%
%   N es la cantidad de elementos de L.
largo([], 0).
largo([_|Xs], N) :-
    largo(Xs, N0),
    N is N0 + 1.

% Ejercicio 15

% programa_concatenar(P): concatenar_dif/3 como datos.
programa_concatenar([ (concatenar_dif(L-M, M-F, L-F) :- []) ]).

% definicion_rotar(D): R es la lista diferencia [X|Xs]-F con X al final.
definicion_rotar((rotar_dif([X|Xs]-F, R) :-
                      [concatenar_dif(Xs-F, [X|G]-G, R)])).

%!  derivar_rotar(-Clausulas:list) is det.
%
%   Clausulas es la definición de rotar_dif/2 desplegada con
%   concatenar_dif/3: un hecho.
derivar_rotar(Clausulas) :-
    definicion_rotar(D),
    programa_concatenar(P),
    desplegar(D, 1, P, Clausulas).

% rotar_dif(D, R): la lista diferencia R es D con su primer elemento al
% final; el hecho que obtiene derivar_rotar/1.
rotar_dif([X|Xs]-[X|F], Xs-F).

%!  mostrar(+Clausulas:list) is det.
%
%   Escribe cada cláusula de Clausulas en una línea, con las variables
%   nombradas A, B, ..., y _ para las que aparecen una sola vez.
mostrar(Clausulas) :-
    forall(member(C, Clausulas),
           ( numbervars(C, 0, _, [singletons(true)]),
             format("~W~n", [C, [numbervars(true), quoted(true),
                                 spacing(next_argument)]]) )).
