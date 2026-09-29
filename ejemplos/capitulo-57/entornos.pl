:- encoding(utf8).

% Capítulo 57 - Versión 2: entornos y clausuras.
%
% El programa del lenguaje objeto es un término sin variables de Prolog,
% en una representación limpia: cada clase de expresión tiene su functor.
%   num(N)            un número
%   id(X)             el identificador X, un átomo
%   lam(X, E)         la función de un parámetro X con cuerpo E
%   ap(F, A)          la aplicación de F a un argumento A
%   si(C, A, B)       el condicional
%   sea(X, E1, E2)    E2 con X ligado al valor de E1
% Un programa es una lista de definiciones def(Nombre, Expresion).
%
% Los valores son números, los átomos verdadero y falso, listas de Prolog
% de valores, clausuras clausura(X, Cuerpo, Entorno) y primitivas
% prim(Op, Faltan, Recibidos), a las que les faltan Faltan argumentos. El
% entorno es una lista de pares Nombre-Valor; el primero que coincide
% oculta a los demás.
%
%?- ejemplo(ap(ap(id(map), id(cuadrado)), id(l)), [l-[1, 2, 3]], V).
%?- evaluar(ap(ap(id(+), num(1)), num(2)), [], [], V).
%?- evaluar(lam(x, ap(ap(id(+), id(x)), id(n))), [n-10], [], V).

%!  evaluar(+Expresion, +Entorno:list, +Programa:list, -Valor) is det.
%
%   Valor es el resultado de evaluar Expresion, con los identificadores
%   libres de Expresion ligados en Entorno o definidos en Programa. La
%   evaluación es estricta: el argumento se evalúa antes de aplicar la
%   función.
evaluar(num(N), _, _, N).
evaluar(id(X), Ent, Prog, V) :-
    buscar(X, Ent, Prog, V).
evaluar(lam(X, Cuerpo), Ent, _, clausura(X, Cuerpo, Ent)).
evaluar(ap(F, A), Ent, Prog, V) :-
    evaluar(F, Ent, Prog, Fv),
    evaluar(A, Ent, Prog, Av),
    aplicar(Fv, Av, Prog, V).
evaluar(si(C, A, B), Ent, Prog, V) :-
    evaluar(C, Ent, Prog, Cv),
    rama(Cv, A, B, E),
    evaluar(E, Ent, Prog, V).
evaluar(sea(X, E1, E2), Ent, Prog, V) :-
    evaluar(E1, Ent, Prog, V1),
    evaluar(E2, [X-V1|Ent], Prog, V).

%!  buscar(+X:atom, +Entorno:list, +Programa:list, -V) is det.
%
%   V es el valor del identificador X: el del entorno, si está; si no, el
%   de su definición en Programa, evaluada en el entorno vacío; si no, la
%   primitiva o la constante de ese nombre. Error de existencia si X no es
%   ninguna de las cuatro cosas.
buscar(X, Ent, Prog, V) :-
    (   memberchk(X-V0, Ent)
    ->  V = V0
    ;   memberchk(def(X, E), Prog)
    ->  evaluar(E, [], Prog, V)
    ;   primitiva(X, N)
    ->  V = prim(X, N, [])
    ;   constante(X, V0)
    ->  V = V0
    ;   existence_error(identificador, X)
    ).

%!  aplicar(+Funcion, +Argumento, +Programa:list, -V) is det.
%
%   V es el resultado de aplicar el valor Funcion al valor Argumento. Una
%   clausura evalúa su cuerpo en su propio entorno, extendido con el
%   parámetro; una primitiva acumula el argumento hasta tenerlos todos.
aplicar(clausura(X, Cuerpo, Ent), A, Prog, V) :-
    !,
    evaluar(Cuerpo, [X-A|Ent], Prog, V).
aplicar(prim(Op, N, Recibidos), A, _, V) :-
    !,
    (   N =:= 1
    ->  reverse([A|Recibidos], Args),
        calcular(Op, Args, V)
    ;   N1 is N - 1,
        V = prim(Op, N1, [A|Recibidos])
    ).
aplicar(F, _, _, _) :-
    type_error(funcion, F).

%!  rama(+Condicion, +Si, +No, -Elegida) is det.
%
%   Elegida es Si cuando Condicion es verdadero y No cuando es falso. Error
%   de tipo si Condicion no es un booleano.
rama(verdadero, E, _, E) :-
    !.
rama(falso, _, E, E) :-
    !.
rama(C, _, _, _) :-
    type_error(booleano, C).

% primitiva(Op, N): Op es una función predefinida de N argumentos.
primitiva(+, 2).
primitiva(-, 2).
primitiva(*, 2).
primitiva(div, 2).
primitiva(mod, 2).
primitiva(=, 2).
primitiva(<, 2).
primitiva(>, 2).
primitiva(cons, 2).
primitiva(cabeza, 1).
primitiva(cola, 1).
primitiva(vacia, 1).

% constante(Nombre, Valor): los identificadores predefinidos que no son
% funciones.
constante(nil, []).
constante(verdadero, verdadero).
constante(falso, falso).

%!  calcular(+Op, +Args:list, -V) is det.
%
%   V es el resultado de la primitiva Op aplicada a Args. Error de tipo si
%   un argumento no es de la clase que Op necesita.
calcular(+, [X, Y], V) :-
    V is X + Y.
calcular(-, [X, Y], V) :-
    V is X - Y.
calcular(*, [X, Y], V) :-
    V is X * Y.
calcular(div, [X, Y], V) :-
    V is X div Y.
calcular(mod, [X, Y], V) :-
    V is X mod Y.
calcular(=, [X, Y], V) :-
    booleano(X == Y, V).
calcular(<, [X, Y], V) :-
    booleano(X < Y, V).
calcular(>, [X, Y], V) :-
    booleano(X > Y, V).
calcular(cons, [X, Y], [X|Y]).
calcular(cabeza, [L], X) :-
    no_vacia(L, X, _).
calcular(cola, [L], Xs) :-
    no_vacia(L, _, Xs).
calcular(vacia, [L], V) :-
    booleano(L == [], V).

%!  booleano(:Condicion, -B) is det.
%
%   B es verdadero si Condicion se cumple y falso si no.
booleano(Condicion, B) :-
    (   call(Condicion)
    ->  B = verdadero
    ;   B = falso
    ).

%!  no_vacia(+L, -X, -Xs) is det.
%
%   L es la lista [X|Xs]. Error de tipo si L no es una lista no vacía.
no_vacia(L, X, Xs) :-
    (   L = [X0|Xs0]
    ->  X = X0,
        Xs = Xs0
    ;   type_error(lista_no_vacia, L)
    ).

%!  ejemplo(+Expresion, +Entorno:list, -Valor) is det.
%
%   Valor es el resultado de evaluar Expresion en Entorno con las
%   definiciones de programa_ejemplo/1.
ejemplo(E, Ent, V) :-
    programa_ejemplo(Prog),
    evaluar(E, Ent, Prog, V).

%!  programa_ejemplo(-Programa:list) is det.
%
%   Programa define las funciones de sustitucion.pl en sintaxis abstracta.
programa_ejemplo([
    def(cuadrado, lam(x, ap(ap(id(*), id(x)), id(x)))),
    def(inc, ap(id(+), num(1))),
    def(map,
        lam(f, lam(l,
            si(ap(id(vacia), id(l)),
               id(nil),
               ap(ap(id(cons), ap(id(f), ap(id(cabeza), id(l)))),
                  ap(ap(id(map), id(f)), ap(id(cola), id(l)))))))),
    def(plegar_izq,
        lam(f, lam(a, lam(l,
            si(ap(id(vacia), id(l)),
               id(a),
               ap(ap(ap(id(plegar_izq), id(f)),
                     ap(ap(id(f), id(a)), ap(id(cabeza), id(l)))),
                  ap(id(cola), id(l)))))))),
    def(invertir,
        ap(ap(id(plegar_izq), lam(a, lam(x, ap(ap(id(cons), id(x)), id(a))))),
           id(nil))),
    def(sumar_a_todos,
        lam(n, ap(id(map), lam(x, ap(ap(id(+), id(x)), id(n))))))
]).
