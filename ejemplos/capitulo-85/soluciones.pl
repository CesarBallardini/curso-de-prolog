:- encoding(utf8).

% Capítulo 85 - Soluciones de los ejercicios.
%
% Cargan el motor completo, datalog.pl, las tablas de tablas.pl, las
% reglas del Wumpus de wumpus.pl, y de costos.pl la tabla de un juego de
% retrogrado.pl y los predicados que miden, sin modificarlos. Los
% programas de los ejercicios son listas de cláusulas, como en el
% capítulo.
%
% solo-local: carga otros archivos, y SWISH no permite cargar otro
% archivo.
%
%?- casados(Cs), evaluar(Cs, M, C).
%?- misma_profundidad(Cs), respuestas_magicas(Cs, sd(d, X), Rs, C).
%?- restar_con([1, 3, 4], 20, Js), retrogrado(Js, T, N).

:- use_module(datalog).
:- use_module(tablas, [tablas/3, magia/4]).
:- use_module(wumpus, [programa_wumpus/2]).
:- use_module('../capitulo-77/enfoques', [conocer/3]).
:- use_module(costos, [inferencias/2, en_banda/2, rondas/3, retrogrado/3]).

:- use_module(library(lists)).
:- use_module(library(apply)).

% --- Ejercicio 1 -----------------------------------------------------------

%!  expresion(-Clausulas:list) is det.
%
%   El programa del ejercicio 15.1 de Nilsson y Małuszyński, como datos.
expresion([ (expr(X, Z) :- expr(X, [+|Y]), expr(Y, Z)),
            (expr([id|Y], Y) :- true) ]).

%!  expr(?X, ?Z) is nondet.
%
%   El mismo programa como cláusulas de Prolog: Z es lo que queda de la
%   lista X después de una expresión. La recursión a la izquierda no
%   termina.
expr(X, Z) :-
    expr(X, [+|Y]),
    expr(Y, Z).
expr([id|Y], Y).

% --- Ejercicio 3 -----------------------------------------------------------

%!  casados(-Clausulas:list) is det.
%
%   El programa con el que Nilsson y Małuszyński abren su capítulo.
casados([ (married(X, Y) :- married(Y, X)),
          (married(adam, anne) :- true) ]).

% --- Ejercicio 4 -----------------------------------------------------------

%!  suplementario(+Clausula, +K:integer, -Clausulas:list) is det.
%
%   Clausulas reemplazan a Clausula, A0 :- A1, ..., An, por la cadena de
%   predicados suplementarios de Nilsson y Małuszyński: S1 :- A1,
%   Si :- S(i-1), Ai, y A0 :- S(n-1), An. Cada Si tiene las variables de
%   A1, ..., Ai que todavía hacen falta: las de la cabeza y las de los
%   literales siguientes. Los nombres son sup_Nombre_K_i, con Nombre el de
%   la cabeza. Una cláusula de un literal o menos queda igual.
suplementario(Cabeza :- Cuerpo, K, Clausulas) :-
    literales(Cuerpo, Ls),
    length(Ls, N),
    (   N =< 1
    ->  Clausulas = [Cabeza :- Cuerpo]
    ;   functor(Cabeza, Nombre, _),
        Ls = [L|Resto],
        encadenar(Resto, L, 1, Cabeza, Nombre, K, true, Clausulas)
    ).

%!  encadenar(+Resto:list, +L, +I:integer, +Cabeza, +Nombre, +K, +Previo,
%!            -Clausulas:list) is det.
%
%   Clausulas son las del I-ésimo literal L y de los literales Resto que
%   lo siguen; Previo es el suplementario anterior, o true antes del
%   primero.
encadenar([], L, _, Cabeza, _, _, Previo, [Cabeza :- Cuerpo]) :-
    conjuncion(Previo, L, Cuerpo).
encadenar([L2|Ls], L, I, Cabeza, Nombre, K, Previo, [(S :- Cuerpo)|Cs]) :-
    term_variables(Previo-L, Antes),
    term_variables(Cabeza-[L2|Ls], Despues),
    include(aparece_en(Despues), Antes, Vs),
    atomic_list_concat([sup, Nombre, K, I], '_', F),
    S =.. [F|Vs],
    conjuncion(Previo, L, Cuerpo),
    I1 is I + 1,
    encadenar(Ls, L2, I1, Cabeza, Nombre, K, S, Cs).

%!  conjuncion(+Previo, +L, -Cuerpo) is det.
%
%   Cuerpo es L si Previo es true, y (Previo, L) si no.
conjuncion(Previo, L, Cuerpo) :-
    (   Previo == true
    ->  Cuerpo = L
    ;   Cuerpo = (Previo, L)
    ).

%!  aparece_en(+Vs:list, +V) is semidet.
%
%   La variable V es una de Vs.
aparece_en(Vs, V) :-
    member(W, Vs),
    W == V,
    !.

%!  suplementarios(+Clausulas:list, -Transformadas:list) is det.
%
%   Transformadas aplica suplementario/3 a cada cláusula de Clausulas,
%   con su posición como K.
suplementarios(Clausulas, Transformadas) :-
    length(Clausulas, N),
    numlist(1, N, Ks),
    maplist(suplementario, Clausulas, Ks, Partes),
    append(Partes, Transformadas).

%!  franjas(-Clausulas:list) is det.
%
%   El programa de Warren sobre los alumnos de una facultad, con datos
%   generados: 1000 alumnos, el alumno A en el año A mod 4 + 1; cada uno
%   inscripto en las 5 materias de su año, 10 * Anio + K; cada materia con
%   50 franjas horarias. franja_del_anio(Anio, F): algún alumno de Anio
%   cursa en la franja F.
franjas(Clausulas) :-
    findall((alumno(A, Anio) :- true),
            ( between(1, 1000, A), Anio is A mod 4 + 1 ),
            Alumnos),
    findall((inscripto(A, M) :- true),
            ( between(1, 1000, A), Anio is A mod 4 + 1,
              between(1, 5, K), M is 10 * Anio + K ),
            Inscripciones),
    findall((horario(M, F) :- true),
            ( between(1, 4, Anio), between(1, 5, K), M is 10 * Anio + K,
              between(1, 50, J), F is 100 * M + J ),
            Horarios),
    append([Alumnos, Inscripciones, Horarios,
            [ (franja_del_anio(Anio, F) :-
                  alumno(A, Anio), inscripto(A, M), horario(M, F)) ]],
           Clausulas).

% --- Ejercicio 5 -----------------------------------------------------------

%!  misma_profundidad(-Clausulas:list) is det.
%
%   sd/2 de Nilsson y Małuszyński sobre los diez hechos child/2 de su
%   ejercicio 15.2, con nodo/1 para que sd(X, X) sea segura.
misma_profundidad(Clausulas) :-
    Hijos = [b-a, c-a, d-b, e-b, f-c, g-d, h-d, i-e, j-f, k-f],
    findall((child(X, Y) :- true), member(X-Y, Hijos), Cs),
    findall((nodo(N) :- true),
            ( member(X-Y, Hijos), ( N = X ; N = Y ) ),
            Ns0),
    sort(Ns0, Ns),
    append([Cs, Ns,
            [ (sd(X, X) :- nodo(X)),
              (sd(X, Y) :- child(X, Z), child(Y, W), sd(Z, W)) ]],
           Clausulas).

% --- Ejercicio 6 -----------------------------------------------------------

%!  debe_camino(?X, ?Y) is nondet.
%
%   En el camino de 100 personas, X le debe dinero a Y: cada una a la
%   siguiente, y la 100 a nadie.
debe_camino(X, Y) :-
    between(1, 99, X),
    Y is X + 1.

:- table evita_camino/2.

%!  evita_camino(?X, ?Y) is nondet.
%
%   X evita a Y en el camino, con la recursión a la izquierda, tabulada.
evita_camino(X, Y) :-
    debe_camino(X, Y).
evita_camino(X, Y) :-
    evita_camino(X, Z),
    debe_camino(Z, Y).

%!  programa_camino(-Clausulas:list) is det.
%
%   El mismo programa como datos.
programa_camino(Clausulas) :-
    findall((debe(X, Y) :- true), debe_camino(X, Y), Hechos),
    append(Hechos,
           [ (evita(X, Y) :- debe(X, Y)),
             (evita(X, Y) :- evita(X, Z), debe(Z, Y)) ],
           Clausulas).

% --- Ejercicio 7 -----------------------------------------------------------

%!  reducciones(-Clausulas:list) is det.
%
%   El ejemplo de negación estratificada de Warren, con sus doce hechos
%   reduce/2.
reducciones(Clausulas) :-
    Pares = [a-b, b-c, c-d, d-e, e-c, a-f, f-g, g-f, g-k, f-h, h-i, i-h],
    findall((reduce(X, Y) :- true), member(X-Y, Pares), Hechos),
    append(Hechos,
           [ (reachable(X, Y) :- reduce(X, Y)),
             (reachable(X, Y) :- reachable(X, Z), reduce(Z, Y)),
             (reducible(X) :- reachable(X, Y), \+ reachable(Y, X)),
             (fully_reduce(X, Y) :- reachable(X, Y), \+ reducible(Y)) ],
           Clausulas).

% --- Ejercicio 8 -----------------------------------------------------------

%!  quitar_hechos(+Clausulas:list, +Hechos:list, -Modelo:list, -Costo)
%!      is det.
%
%   Modelo es el de Clausulas sin los Hechos, calculado desde cero con
%   evaluar/3; Costo, el de ese cálculo.
quitar_hechos(Clausulas, Hechos, Modelo, Costo) :-
    exclude(hecho_de(Hechos), Clausulas, Quedan),
    evaluar(Quedan, Modelo, Costo).

%!  hecho_de(+Hechos:list, +Clausula) is semidet.
%
%   Clausula es el hecho H :- true de uno de los Hechos.
hecho_de(Hechos, H :- true) :-
    memberchk(H, Hechos).

%!  volver_a_agregar(+Clausulas:list, +Hechos:list, -Costo) is det.
%
%   Costo es el de agregar los Hechos, con agregar_hechos/4, al modelo de
%   Clausulas sin ellos.
volver_a_agregar(Clausulas, Hechos, Costo) :-
    exclude(hecho_de(Hechos), Clausulas, Quedan),
    iniciar(Quedan, Estado, _),
    agregar_hechos(Hechos, Estado, _, Costo).

% --- Ejercicio 9 -----------------------------------------------------------

%!  segura_magica(+K, +Celda, -Respuestas:list, -Costo) is det.
%
%   Respuestas son las de segura(N), con N el número de Celda, en el
%   programa del Wumpus con el conocimiento K transformado para esa
%   consulta.
segura_magica(K, X-Y, Respuestas, Costo) :-
    N is 10 * X + Y,
    programa_wumpus(K, Clausulas),
    respuestas_magicas(Clausulas, segura(N), Respuestas, Costo).

% --- Ejercicio 10 ----------------------------------------------------------

%!  restar_con(+Sacar:list(integer), +N:integer, -Jugadas:list) is det.
%
%   Jugadas son las del juego de restar con N fichas, en el que cada
%   jugador saca una de las cantidades de Sacar.
restar_con(Sacar, N, Jugadas) :-
    findall(X-Y,
            ( between(1, N, X),
              member(M, Sacar),
              Y is X - M,
              Y >= 0 ),
            Jugadas).

% --- Ejercicio 11 ----------------------------------------------------------

%!  evaluar_ingenuo(+Clausulas:list, -Modelo:list, -Costo) is det.
%
%   El modelo de evaluar/3, con la evaluación ingenua en cada componente:
%   cada paso aplica todas las reglas de la componente a la base entera,
%   hasta que no aparece nada nuevo.
evaluar_ingenuo(Clausulas, Modelo, Costo) :-
    separar(Clausulas, Hechos, Reglas),
    componentes(Clausulas, Componentes),
    base(Hechos, Base0),
    foldl(ingenua_componente(Reglas), Componentes,
          Base0-costo(0, 0), Base-Costo),
    atomos(Base, Modelo).

%!  ingenua_componente(+Reglas:list, +Componente:list, +Estado0,
%!                     -Estado) is det.
%
%   Estado0 es Base0-Costo0; Estado agrega lo que derivan las reglas de
%   Componente, aplicadas a la base entera hasta el punto fijo.
ingenua_componente(Reglas, Componente, Base0-costo(P0, D0), Base-Costo) :-
    include(cabeza_en(Componente), Reglas, DeLaComponente),
    findall(H, ( member(r(H, Ls), DeLaComponente), cumplir(Ls, Base0) ),
            Hs),
    length(Hs, D),
    P is P0 + 1,
    D1 is D0 + D,
    agregar(Hs, Base0, Base1, Nuevos),
    (   Nuevos == []
    ->  Base = Base1,
        Costo = costo(P, D1)
    ;   ingenua_componente(Reglas, Componente, Base1-costo(P, D1),
                           Base-Costo)
    ).

%!  cabeza_en(+Componente:list, +Regla) is semidet.
%
%   La cabeza de Regla es de un predicado de Componente.
cabeza_en(Componente, r(H, _)) :-
    functor(H, Nombre, Aridad),
    memberchk(Nombre/Aridad, Componente).
