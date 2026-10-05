:- encoding(utf8).

% Capítulo 85 - Versión 2: las relaciones indexadas y la evaluación
% semi-ingenua por bloques.
%
% Una base es un árbol de library(assoc) que lleva cada predicado,
% Nombre/Aridad, a su relación; una relación es otro árbol, que lleva el
% primer argumento de cada átomo a la lista ordenada de los átomos que lo
% tienen. Un literal con el primer argumento ligado consulta una sola
% lista; uno con el primer argumento libre recorre la relación entera,
% pero nunca los átomos de otro predicado.
%
% bloque/6 evalúa un grupo de reglas hasta el punto fijo, a partir de una
% base: el primer paso usa la base entera, y los siguientes, solo las
% derivaciones que toman de los átomos nuevos del paso anterior el
% literal de alguna posición del cuerpo cuyo predicado está en el grupo.
% Los literales anteriores a esa posición se buscan en la base vieja, y
% los posteriores en la actual: cada derivación se cuenta una sola vez.
% semi_ingenua/3 evalúa así un programa sin negación.
%
% solo-local: es un módulo que carga otro.
%
%?- semi_ingenua([(arco(a, b) :- true), (arco(b, a) :- true), (camino(X, Y) :- arco(X, Y)), (camino(X, Y) :- camino(X, Z), arco(Z, Y))], M, C).

:- module(motor,
          [ base/2,
            atomos/2,
            en_base/2,
            contiene/2,
            agregar/4,
            separar/3,
            cumplir/2,
            bloque/6,
            iterar/7,
            variantes/3,
            semi_ingenua/3,
            exigir_definido/1
          ]).

:- use_module(library(assoc)).
:- use_module(library(lists)).
:- use_module(library(apply)).
:- use_module(library(ordsets)).
:- use_module(seguro).

% --- La base --------------------------------------------------------------

%!  base(+Atomos:list, -Base) is det.
%
%   Base es la base que contiene exactamente los Atomos, sin variables.
base(Atomos, Base) :-
    empty_assoc(Vacia),
    agregar(Atomos, Vacia, Base, _).

%!  agregar(+Atomos:list, +Base0, -Base, -Nuevos:list) is det.
%
%   Base es Base0 con los Atomos; Nuevos son, ordenados y sin repetir, los
%   que no estaban en Base0.
agregar(Atomos, Base0, Base, Nuevos) :-
    sort(Atomos, Ordenados),
    foldl(agregar_atomo, Ordenados, Base0-Nuevos, Base-[]).

%!  agregar_atomo(+Atomo, +Estado0, -Estado) is det.
%
%   Estado0 es Base0-Nuevos0, con Nuevos0 una lista abierta; si Atomo no
%   está en Base0, Estado lo tiene en la base y al principio de la lista.
agregar_atomo(A, Base0-Nuevos0, Base-Nuevos) :-
    (   contiene(Base0, A)
    ->  Base = Base0,
        Nuevos0 = Nuevos
    ;   indice(A, Ind, Clave),
        (   get_assoc(Ind, Base0, R0)
        ->  true
        ;   empty_assoc(R0)
        ),
        (   get_assoc(Clave, R0, As0)
        ->  true
        ;   As0 = []
        ),
        ord_add_element(As0, A, As),
        put_assoc(Clave, R0, As, R),
        put_assoc(Ind, Base0, R, Base),
        Nuevos0 = [A|Nuevos]
    ).

%!  indice(+Atomo, -Indicador, -Clave) is det.
%
%   Indicador es Nombre/Aridad, el predicado de Atomo, y Clave, su primer
%   argumento, o [] si no tiene argumentos.
indice(A, Nombre/Aridad, Clave) :-
    functor(A, Nombre, Aridad),
    (   Aridad =:= 0
    ->  Clave = []
    ;   arg(1, A, Clave)
    ).

%!  contiene(+Base, +Atomo) is semidet.
%
%   Atomo, sin variables, está en Base.
contiene(Base, A) :-
    indice(A, Ind, Clave),
    get_assoc(Ind, Base, R),
    get_assoc(Clave, R, As),
    ord_memberchk(A, As).

%!  en_base(?Atomo, +Base) is nondet.
%
%   Atomo, que llega con su predicado conocido, unifica con un átomo de
%   Base. Con el primer argumento ligado, recorre solo los átomos que lo
%   tienen.
en_base(A, Base) :-
    indice(A, Ind, Clave),
    get_assoc(Ind, Base, R),
    (   ground(Clave)
    ->  get_assoc(Clave, R, As)
    ;   assoc_to_values(R, Listas),
        member(As, Listas)
    ),
    member(A, As).

%!  atomos(+Base, -Atomos:list) is det.
%
%   Atomos son todos los átomos de Base, ordenados.
atomos(Base, Atomos) :-
    assoc_to_values(Base, Relaciones),
    findall(A,
            ( member(R, Relaciones),
              assoc_to_values(R, Listas),
              member(As, Listas),
              member(A, As) ),
            Atomos0),
    sort(Atomos0, Atomos).

% --- Las reglas -----------------------------------------------------------

%!  separar(+Clausulas:list, -Hechos:list, -Reglas:list) is det.
%
%   Hechos son las cabezas de las cláusulas con cuerpo true y sin
%   variables; Reglas son las demás, como términos r(Cabeza, Literales).
separar(Clausulas, Hechos, Reglas) :-
    partition(es_hecho, Clausulas, Hs, Rs),
    maplist(cabeza, Hs, Hechos),
    maplist(regla, Rs, Reglas).

% es_hecho(C): C es un hecho sin variables.
es_hecho(H :- true) :-
    ground(H).

% cabeza(C, H): H es la cabeza de la cláusula C.
cabeza(H :- _, H).

% regla(C, r(H, Ls)): Ls son los literales del cuerpo de C, de cabeza H.
regla(H :- Cuerpo, r(H, Ls)) :-
    literales(Cuerpo, Ls).

%!  cumplir(+Literales:list, +Base) is nondet.
%
%   Cada uno de Literales es verdadero en Base, de izquierda a derecha:
%   un átomo, si unifica con uno de Base; \+ A, si A no está; una
%   comparación o is/2, si se cumple. Una respuesta por cada forma.
cumplir([], _).
cumplir([L|Ls], Base) :-
    literal(L, Base),
    cumplir(Ls, Base).

%!  literal(+L, +Base) is nondet.
%
%   El literal L es verdadero en Base.
literal(L, Base) :-
    (   L = (\+ A)
    ->  \+ contiene(Base, A)
    ;   L = (X is E)
    ->  X is E
    ;   comparacion(L)
    ->  call(L)
    ;   en_base(L, Base)
    ).

% --- La evaluación semi-ingenua -----------------------------------------

%!  variantes(+Reglas:list, +Predicados:list, -Variantes:list) is det.
%
%   Variantes son los términos v(Cabeza, Literal, Antes, Despues): uno por
%   cada regla y cada posición de su cuerpo con un literal positivo de uno
%   de los Predicados, con los literales de antes y de después. El literal
%   elegido se evalúa primero, así que los de antes se reordenan: los
%   átomos positivos, del más cercano al más lejano, para que cada uno
%   reciba las variables que ligan los anteriores, y después los demás,
%   en su orden, con sus variables ya ligadas.
variantes(Reglas, Predicados, Variantes) :-
    findall(v(H, L, Antes, Despues),
            ( member(r(H, Ls), Reglas),
              append(Antes0, [L|Despues], Ls),
              positivo(L),
              indice(L, Ind, _),
              memberchk(Ind, Predicados),
              partition(positivo, Antes0, Positivos, Otros),
              reverse(Positivos, Cercanos),
              append(Cercanos, Otros, Antes) ),
            Variantes).

%!  positivo(+L) is semidet.
%
%   L es un literal positivo: no es una negación, ni una comparación, ni
%   is/2.
positivo(L) :-
    L \= (\+ _),
    L \= (_ is _),
    \+ comparacion(L).

%!  bloque(+Reglas:list, +Predicados:list, +Base0, -Base, +Costo0, -Costo)
%!      is det.
%
%   Base agrega a Base0 todo lo que las Reglas derivan hasta el punto fijo.
%   Predicados son los del grupo, los que pueden cambiar mientras se
%   evalúa. Costo es costo(Pasos, Derivaciones) sumado a Costo0: los pasos
%   y las cabezas derivadas, contando las repetidas.
bloque(Reglas, Predicados, Base0, Base, Costo0, Costo) :-
    findall(H, ( member(r(H, Ls), Reglas), cumplir(Ls, Base0) ), Hs),
    sumar(Costo0, Hs, Costo1),
    agregar(Hs, Base0, Base1, Nuevos),
    variantes(Reglas, Predicados, Variantes),
    iterar(Variantes, Base0, Base1, Nuevos, Base, Costo1, Costo).

%!  iterar(+Variantes:list, +Vieja, +Actual, +Nuevos:list, -Base,
%!         +Costo0, -Costo) is det.
%
%   Sigue la evaluación: Nuevos son los átomos que Actual tiene y Vieja
%   no. Cada paso deriva con las Variantes tomando el literal elegido de
%   Nuevos, los anteriores de Vieja y los posteriores de Actual, hasta que
%   no hay átomos nuevos. Sin variantes, el grupo no es recursivo, y el
%   primer paso alcanzó.
iterar(Variantes, Vieja, Actual, Nuevos, Base, Costo0, Costo) :-
    (   ( Nuevos == [] ; Variantes == [] )
    ->  Base = Actual,
        Costo = Costo0
    ;   base(Nuevos, Delta),
        findall(H,
                ( member(v(H, L, Antes, Despues), Variantes),
                  en_base(L, Delta),
                  cumplir(Antes, Vieja),
                  cumplir(Despues, Actual) ),
                Hs),
        sumar(Costo0, Hs, Costo1),
        agregar(Hs, Actual, Siguiente, Nuevos1),
        iterar(Variantes, Actual, Siguiente, Nuevos1, Base, Costo1, Costo)
    ).

%!  sumar(+Costo0, +Cabezas:list, -Costo) is det.
%
%   Costo agrega a Costo0 un paso y las Cabezas derivadas en él.
sumar(costo(P0, D0), Cabezas, costo(P, D)) :-
    length(Cabezas, N),
    P is P0 + 1,
    D is D0 + N.

%!  semi_ingenua(+Clausulas:list, -Modelo:list, -Costo) is det.
%
%   Modelo es el modelo mínimo de Clausulas, un programa Datalog seguro sin
%   negación, calculado con un solo bloque que reúne todas las reglas.
%   Costo es costo(Pasos, Derivaciones). Error de dominio si el programa no
%   es seguro o tiene una negación.
semi_ingenua(Clausulas, Modelo, Costo) :-
    exigir_definido(Clausulas),
    separar(Clausulas, Hechos, Reglas),
    base(Hechos, Base0),
    findall(Ind, ( member(r(H, _), Reglas), indice(H, Ind, _) ), Is),
    sort(Is, Predicados),
    bloque(Reglas, Predicados, Base0, Base, costo(0, 0), Costo),
    atomos(Base, Modelo).

%!  exigir_definido(+Clausulas:list) is det.
%
%   Clausulas es un programa seguro y sin negación. Error de dominio si no.
exigir_definido(Clausulas) :-
    problemas(Clausulas, Problemas),
    (   Problemas = [P|_]
    ->  domain_error(datalog_seguro, P)
    ;   member(_ :- Cuerpo, Clausulas),
        literales(Cuerpo, Ls),
        member(\+ A, Ls)
    ->  domain_error(programa_sin_negacion, \+ A)
    ;   true
    ).
