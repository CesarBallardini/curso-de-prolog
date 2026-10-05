:- encoding(utf8).

% Capítulo 45 - Una máquina de registros y la asignación de registros.
%
% La máquina de registros de Clocksin opera solo entre registros, r(0),
% r(1), ...: cargar(R, V) pone en r(R) la constante num(N) o la variable
% id(X), y operar(Op, R1, R2) reemplaza r(R1) por r(R1) Op r(R2).
% generar_ingenuo/2 es el generador de Clocksin: el operando izquierdo en
% el registro R, el derecho en R+1. generar_registros/2 asigna los
% registros con el algoritmo de Sethi y Ullman: etiqueta cada nodo con la
% cantidad de registros que necesita (registros_necesarios/2) y evalúa
% primero el operando que más necesita; así usa la menor cantidad posible
% de registros sin guardar valores intermedios en la memoria.
%
% solo-local: carga interprete.pl con ensure_loaded/1.
%
%?- generar_ingenuo(bin(-, id(a), bin(*, id(b), id(c))), C).
%?- generar_registros(bin(-, id(a), bin(*, id(b), id(c))), C).

:- ensure_loaded(interprete).
:- use_module(library(assoc)).

%!  generar_ingenuo(+E, -Codigo:list) is det.
%
%   Codigo deja el valor de E en r(0): cada operando izquierdo en el
%   registro de su operación, el derecho en el siguiente.
generar_ingenuo(E, Codigo) :-
    phrase(codigo_ingenuo(E, 0), Codigo).

%!  codigo_ingenuo(+E, +R:integer)// is det.
%
%   El código que deja el valor de E en r(R), usando los registros desde R.
codigo_ingenuo(bin(Op, A, B), R) -->
    !,
    { R1 is R + 1 },
    codigo_ingenuo(A, R),
    codigo_ingenuo(B, R1),
    [operar(Op, R, R1)].
codigo_ingenuo(E, R) -->
    [cargar(R, E)].

%!  registros_necesarios(+E, -N:integer) is det.
%
%   N es la cantidad de registros que necesita E: uno para una hoja; para
%   una operación, la mayor de las de sus operandos si son distintas, o
%   una más si son iguales.
registros_necesarios(bin(_, A, B), N) :-
    !,
    registros_necesarios(A, NA),
    registros_necesarios(B, NB),
    (   NA =:= NB
    ->  N is NA + 1
    ;   N is max(NA, NB)
    ).
registros_necesarios(_, 1).

%!  generar_registros(+E, -Codigo:list) is det.
%
%   Codigo deja el valor de E en r(0) y usa los registros r(0) a r(N-1),
%   donde N es registros_necesarios(E, N).
generar_registros(E, Codigo) :-
    registros_necesarios(E, N),
    Ultimo is N - 1,
    numlist(0, Ultimo, Libres),
    phrase(codigo_registros(E, Libres), Codigo).

%!  codigo_registros(+E, +Libres:list(integer))// is det.
%
%   El código que deja el valor de E en el primer registro de Libres, y
%   usa solo registros de Libres. El operando que necesita más registros
%   se evalúa primero; si es el derecho, se evalúa en el segundo registro
%   libre, para que el resultado quede en el primero.
codigo_registros(bin(Op, A, B), [R|Rs]) -->
    !,
    { registros_necesarios(A, NA),
      registros_necesarios(B, NB) },
    (   { NA >= NB }
    ->  { Rs = [R2|_] },
        codigo_registros(A, [R|Rs]),
        codigo_registros(B, Rs)
    ;   { Rs = [R2|Resto] },
        codigo_registros(B, [R2, R|Resto]),
        codigo_registros(A, [R|Resto])
    ),
    [operar(Op, R, R2)].
codigo_registros(E, [R|_]) -->
    [cargar(R, E)].

%!  registros_usados(+Codigo:list, -N:integer) is det.
%
%   N es la cantidad de registros distintos que nombra Codigo.
registros_usados(Codigo, N) :-
    findall(R, ( member(I, Codigo), registro(I, R) ), Rs),
    sort(Rs, Distintos),
    length(Distintos, N).

%!  registro(+I, -R:integer) is nondet.
%
%   La instrucción I nombra el registro R.
registro(cargar(R, _), R).
registro(operar(_, R, _), R).
registro(operar(_, _, R), R).

%!  ejecutar_registros(+Codigo:list, +Entorno:list, -V:integer) is det.
%
%   V es el valor de r(0) después de ejecutar Codigo, con las variables de
%   Mini en Entorno, una lista de pares Nombre-Valor.
ejecutar_registros(Codigo, Entorno, V) :-
    empty_assoc(Registros0),
    foldl(instruccion_registros(Entorno), Codigo, Registros0, Registros),
    get_assoc(0, Registros, V).

%!  instruccion_registros(+Entorno:list, +I, +Registros0, -Registros) is det.
%
%   paso_registros/4 con el entorno primero, para foldl/4.
instruccion_registros(Entorno, I, Registros0, Registros) :-
    paso_registros(I, Entorno, Registros0, Registros).

%!  paso_registros(+I, +Entorno:list, +Registros0, -Registros) is det.
%
%   Ejecutar la instrucción I cambia los registros de Registros0 a
%   Registros, un árbol AVL que asocia cada número de registro con su
%   valor.
paso_registros(cargar(R, num(N)), _, Rs0, Rs) :-
    put_assoc(R, Rs0, N, Rs).
paso_registros(cargar(R, id(X)), E, Rs0, Rs) :-
    valor(X, E, V),
    put_assoc(R, Rs0, V, Rs).
paso_registros(operar(Op, R1, R2), _, Rs0, Rs) :-
    get_assoc(R1, Rs0, X),
    get_assoc(R2, Rs0, Y),
    operar(Op, X, Y, V),
    put_assoc(R1, Rs0, V, Rs).
