:- encoding(utf8).

% Capítulo 60 - Versión 4: un demostrador pequeño por resolución.
%
% Un programa dirigido por patrones que demuestra fórmulas de la lógica
% proposicional. La negación de la fórmula se pasa a forma clausal; cada
% cláusula, una lista ordenada de literales, es un hecho clausula(C) de la
% memoria. Los módulos buscan la cláusula vacía, quitan las cláusulas
% tautológicas y agregan resolventes nuevos; si la cláusula vacía aparece,
% la fórmula es un teorema. Carga la versión 3.
%
% solo-local: carga conflictos.pl con ensure_loaded/1, y SWISH no permite
% cargar archivos.
%
%?- demostrar((a ==> b) & (b ==> c) ==> (a ==> c), primera, V).
%?- trazar_demostracion((a ==> b) & (b ==> c) ==> (a ==> c), primera, V).

:- ensure_loaded(conflictos).

:- op(720, xfy, &).
:- op(730, xfy, v).
:- op(740, xfx, ==>).

programa(resolucion,
    [ contradiccion :: [clausula([])]
           ---> [parar(contradiccion)],
      tautologia :: [clausula(C), {tautologica(C)}]
           ---> [quitar(clausula(C))],
      resolver :: [clausula(C1), clausula(C2),
                   {resolvente(C1, C2, R), \+ tautologica(R)},
                   no(clausula(R))]
           ---> [agregar(clausula(R))],
      agotado :: []
           ---> [parar(sin_contradiccion)]
    ]).

%!  demostrar(+Formula, +Estrategia, -Veredicto) is det.
%
%   Veredicto es teorema si la negación de Formula lleva a la cláusula
%   vacía con el programa resolucion y la Estrategia, y no_teorema si no.
demostrar(Formula, Estrategia, Veredicto) :-
    memoria_inicial(Formula, Memoria),
    ejecutar(resolucion, Estrategia, Memoria, _, Resultado),
    veredicto(Resultado, Veredicto).

%!  trazar_demostracion(+Formula, +Estrategia, -Veredicto) is det.
%
%   Como demostrar/3, y escribe la traza de los ciclos.
trazar_demostracion(Formula, Estrategia, Veredicto) :-
    memoria_inicial(Formula, Memoria),
    trazar(resolucion, Estrategia, Memoria, _, Resultado),
    veredicto(Resultado, Veredicto).

%!  memoria_inicial(+Formula, -Memoria:list) is det.
%
%   Memoria tiene un hecho clausula(C) por cada cláusula de la forma
%   clausal de la negación de Formula.
memoria_inicial(Formula, Memoria) :-
    clausulas(-Formula, Clausulas),
    findall(clausula(C), member(C, Clausulas), Memoria).

%!  veredicto(+Resultado, -Veredicto) is det.
%
%   Veredicto es la conclusión que corresponde al Resultado del programa.
veredicto(contradiccion, teorema).
veredicto(sin_contradiccion, no_teorema).

%!  resolvente(+C1:list, +C2:list, -R:list) is nondet.
%
%   R es un resolvente de las cláusulas C1 y C2: C1 tiene un literal L,
%   C2 su opuesto, y R reúne los demás literales de las dos.
resolvente(C1, C2, R) :-
    select(L, C1, R1),
    opuesto(L, M),
    selectchk(M, C2, R2),
    ord_union(R1, R2, R).

%!  tautologica(+C:list) is semidet.
%
%   La cláusula C tiene un literal y su opuesto.
tautologica(C) :-
    member(L, C),
    opuesto(L, M),
    memberchk(M, C),
    !.

%!  opuesto(+L, -M) is det.
%
%   M es el literal opuesto de L: -P para un átomo P, y P para -P.
opuesto(P, -P) :-
    atom(P).
opuesto(-P, P) :-
    atom(P).

%!  clausulas(+Formula, -Clausulas:list) is det.
%
%   Clausulas es la forma clausal de Formula, sin repeticiones: cada
%   cláusula es una lista ordenada de literales.
clausulas(Formula, Clausulas) :-
    fnn(Formula, F),
    fnc(F, Cs),
    sort(Cs, Clausulas).

%!  fnn(+Formula, -F) is det.
%
%   F es Formula en forma normal negada: sin ==>, y con la negación solo
%   delante de los átomos.
fnn(P, P) :-
    atom(P).
fnn(A ==> B, F) :-
    fnn(-A v B, F).
fnn(A & B, FA & FB) :-
    fnn(A, FA),
    fnn(B, FB).
fnn(A v B, FA v FB) :-
    fnn(A, FA),
    fnn(B, FB).
fnn(-A, F) :-
    fnn_negada(A, F).

%!  fnn_negada(+Formula, -F) is det.
%
%   F es la forma normal negada de la negación de Formula.
fnn_negada(P, -P) :-
    atom(P).
fnn_negada(A ==> B, F) :-
    fnn(A & -B, F).
fnn_negada(A & B, F) :-
    fnn(-A v -B, F).
fnn_negada(A v B, F) :-
    fnn(-A & -B, F).
fnn_negada(-A, F) :-
    fnn(A, F).

%!  fnc(+F, -Clausulas:list) is det.
%
%   Clausulas es la lista de cláusulas de F, una fórmula en forma normal
%   negada: una conjunción de disyunciones de literales.
fnc(P, [[P]]) :-
    atom(P).
fnc(A & B, Cs) :-
    fnc(A, CA),
    fnc(B, CB),
    append(CA, CB, Cs).
fnc(A v B, Cs) :-
    fnc(A, CA),
    fnc(B, CB),
    findall(C, ( member(X, CA), member(Y, CB), ord_union(X, Y, C) ), Cs).
fnc(-P, [[-P]]).
