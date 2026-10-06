:- encoding(utf8).

% Capítulo 45 - Una máquina de acumulador.
%
% La máquina de acumulador de Clocksin tiene un solo registro, el
% acumulador, y cada operación combina el acumulador con un valor de la
% memoria. Sus instrucciones son tres: cargar(V) pone V en el acumulador,
% operar(Op, V) lo reemplaza por el acumulador Op V, y guardar(t(K)) lo
% copia en la celda temporal t(K). Un valor V es num(N), id(X) o t(K).
% generar_acumulador/2 traduce una expresión de Mini: si el operando
% derecho es una hoja, la operación lo nombra directamente; si no, se
% calcula primero el derecho y se guarda en una temporal. ejecutar_acumulador/3
% ejecuta el código con los valores de las variables en un entorno como el
% del intérprete.
%
% solo-local: carga interprete.pl con ensure_loaded/1.
%
%?- analizar("escribir a - b * c", [escribir(E)]), generar_acumulador(E, C).
%?- generar_acumulador(bin(+, id(a), bin(+, id(b), bin(+, id(c), id(d)))), C).

:- ensure_loaded(interprete).
:- use_module(library(assoc)).

%!  generar_acumulador(+E, -Codigo:list) is det.
%
%   Codigo es el código de la máquina de acumulador que deja en el
%   acumulador el valor de la expresión E.
generar_acumulador(E, Codigo) :-
    phrase(codigo_acumulador(E, 0), Codigo).

%!  codigo_acumulador(+E, +K:integer)// is det.
%
%   El código de E, que usa las temporales desde t(K).
codigo_acumulador(E, _) -->
    { hoja(E) },
    !,
    [cargar(E)].
codigo_acumulador(bin(Op, A, B), K) -->
    (   { hoja(B) }
    ->  codigo_acumulador(A, K),
        [operar(Op, B)]
    ;   { K1 is K + 1 },
        codigo_acumulador(B, K),
        [guardar(t(K))],
        codigo_acumulador(A, K1),
        [operar(Op, t(K))]
    ).

%!  hoja(+E) is semidet.
%
%   E es una constante o una variable: la máquina la nombra en una
%   instrucción.
hoja(num(_)).
hoja(id(_)).

%!  temporales(+Codigo:list, -N:integer) is det.
%
%   N es la cantidad de temporales distintas que usa Codigo.
temporales(Codigo, N) :-
    findall(K, member(guardar(t(K)), Codigo), Ks),
    sort(Ks, Distintas),
    length(Distintas, N).

%!  ejecutar_acumulador(+Codigo:list, +Entorno:list, -V:integer) is det.
%
%   V es lo que queda en el acumulador después de ejecutar Codigo, con las
%   variables de Mini en Entorno, una lista de pares Nombre-Valor.
ejecutar_acumulador(Codigo, Entorno, V) :-
    empty_assoc(Temporales),
    foldl(instruccion_acumulador(Entorno), Codigo,
          ac(0, Temporales), ac(V, _)).

%!  instruccion_acumulador(+Entorno:list, +I, +Estado0, -Estado) is det.
%
%   paso_acumulador/4 con el entorno primero, para foldl/4.
instruccion_acumulador(Entorno, I, Estado0, Estado) :-
    paso_acumulador(I, Entorno, Estado0, Estado).

%!  paso_acumulador(+I, +Entorno:list, +Estado0, -Estado) is det.
%
%   Ejecutar la instrucción I lleva la máquina de Estado0 a Estado. El
%   estado es ac(Acumulador, Temporales).
paso_acumulador(cargar(X), E, ac(_, T), ac(V, T)) :-
    valor_acumulador(X, E, T, V).
paso_acumulador(operar(Op, X), E, ac(A0, T), ac(A, T)) :-
    valor_acumulador(X, E, T, V),
    operar(Op, A0, V, A).
paso_acumulador(guardar(t(K)), _, ac(A, T0), ac(A, T)) :-
    put_assoc(K, T0, A, T).

%!  valor_acumulador(+X, +Entorno:list, +Temporales, -V:integer) is det.
%
%   V es el valor que nombra X: una constante, una variable de Mini o una
%   temporal.
valor_acumulador(num(N), _, _, N).
valor_acumulador(id(X), E, _, V) :-
    valor(X, E, V).
valor_acumulador(t(K), _, T, V) :-
    get_assoc(K, T, V).
