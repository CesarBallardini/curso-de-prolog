:- encoding(utf8).

% Capítulo 62 - Versión 6: resolución en la lógica de predicados.
%
% El demostrador de la versión 3, con cláusulas que tienen variables.
% Antes de cada paso se copian las cláusulas, de modo que dos cláusulas
% nunca comparten variables; los literales opuestos se unifican con
% unify_with_occurs_check/2, y el paso de factorización une dos literales
% del mismo signo de una cláusula. Un resolvente se descarta si es
% tautológico o si repite una cláusula anterior. La búsqueda sigue
% siendo la profundización iterativa sobre la longitud de la prueba, que
% en la lógica de predicados necesita un máximo: si la fórmula no es un
% teorema, la búsqueda puede no terminar nunca. La estrategia lineal
% reduce la búsqueda: desde el segundo paso, cada uno usa la cláusula que
% agregó el anterior.
%
% refutar_con/4 recibe las opciones de la búsqueda, para medir el efecto
% de cada una: la estrategia (general o lineal), el filtro (repetida o
% subsumida), la unificación (unify_with_occurs_check o =) y si hay
% factorización (si o no).
%
% solo-local: carga los módulos lector, clausal, primer_orden y
% resolucion, y SWISH no admite módulos propios.
%
%?- demostrar_fo("∃x (bebe(x) → ∀y bebe(y))", 5, P), escribir_prueba(P).
%?- demostrar_fo("¬∃x ∀y (afeita(x, y) ↔ ¬afeita(y, y))", 5, P).

:- module(resolucion_fo,
          [ demostrar_fo/3,
            refutar_fo/3,
            refutar_con/4,
            resolvente_fo/4,
            factor/3,
            subsume/2
          ]).

:- use_module(library(lists)).
:- reexport(primer_orden).
:- reexport(resolucion, [escribir_prueba/1, clausula_texto/2]).

%!  demostrar_fo(+Texto, +Max:integer, -Prueba) is semidet.
%
%   Prueba es la refutación más corta, de a lo sumo Max pasos, de la
%   negación de la fórmula cerrada que Texto escribe. Falla si no hay
%   ninguna de Max pasos o menos.
demostrar_fo(Texto, Max, prueba(Clausulas, Pasos)) :-
    leer_formula(Texto, F),
    clausulas_fo(no(F), Clausulas),
    refutar_fo(Clausulas, Max, Pasos).

%!  refutar_fo(+Clausulas:list, +Max:integer, -Pasos:list) is semidet.
%
%   Pasos es la refutación lineal más corta de las Clausulas, de a lo sumo
%   Max pasos, con comprobación de ocurrencia y factorización, que
%   descarta los resolventes repetidos.
refutar_fo(Clausulas, Max, Pasos) :-
    refutar_con(opciones(lineal, repetida, unify_with_occurs_check, si),
                Clausulas, Max, Pasos).

%!  refutar_con(+Opciones, +Clausulas:list, +Max:integer, -Pasos:list)
%!      is semidet.
%
%   Como refutar_fo/3, con las Opciones opciones(Estrategia, Filtro,
%   Unificar, Factorizar). Estrategia es general (cada paso usa dos
%   cláusulas cualesquiera) o lineal (desde el segundo paso, cada uno usa
%   la cláusula que agregó el anterior). Filtro es repetida (se descarta
%   un resolvente que es una variante de una cláusula anterior) o
%   subsumida (se descarta si una cláusula anterior lo subsume). Unificar
%   es el predicado que unifica los literales, y Factorizar es si o no.
refutar_con(Opciones, Clausulas, Max, Pasos) :-
    between(0, Max, N),
    length(Pasos, N),
    derivar(Opciones, Pasos, Clausulas, ninguna),
    !.

%!  derivar(+Opciones, ?Pasos:list, +Clausulas:list, +Centro) is nondet.
%
%   Pasos, una lista de longitud conocida, lleva de Clausulas a una lista
%   que contiene la cláusula vacía. Centro es el número de la cláusula
%   que agregó el paso anterior, o ninguna antes del primero.
derivar(_, [], Clausulas, _) :-
    memberchk([], Clausulas).
derivar(Opciones, [Paso|Pasos], Clausulas, Centro) :-
    paso(Opciones, Clausulas, Centro, Paso, R),
    \+ tautologica(R),
    \+ redundante(Opciones, R, Clausulas),
    append(Clausulas, [R], Clausulas1),
    length(Clausulas1, Centro1),
    derivar(Opciones, Pasos, Clausulas1, Centro1).

%!  paso(+Opciones, +Clausulas:list, +Centro, -Paso, -R:list) is nondet.
%
%   Paso es un paso de resolución o de factorización sobre las Clausulas,
%   y R la cláusula que agrega. Con la estrategia lineal, un paso que no
%   es el primero usa la cláusula número Centro.
paso(opciones(E, _, U, _), Clausulas, Centro, r(I, J, R), R) :-
    centro(E, Centro, J),
    nth1(J, Clausulas, C2),
    nth1(I, Clausulas, C1),
    I =< J,
    resolvente_fo(U, C1, C2, R).
paso(opciones(E, _, U, si), Clausulas, Centro, f(I, R), R) :-
    centro(E, Centro, I),
    nth1(I, Clausulas, C),
    factor(U, C, R).

%!  centro(+Estrategia, +Centro, -J) is det.
%
%   J es la cláusula que el paso debe usar: libre con la estrategia
%   general o en el primer paso, y Centro en los demás pasos lineales.
centro(general, _, _).
centro(lineal, ninguna, _) :-
    !.
centro(lineal, Centro, Centro).

%!  resolvente_fo(+Unificar, +C1:list, +C2:list, -R:list) is nondet.
%
%   R es un resolvente de copias de C1 y C2 sin variables comunes: un
%   literal de una y el opuesto de un literal de la otra se unifican con
%   Unificar, y R reúne los demás, sin repetidos.
resolvente_fo(U, C1, C2, R) :-
    copy_term(C1, D1),
    copy_term(C2, D2),
    select(L1, D1, R1),
    select(L2, D2, R2),
    opuestos(U, L1, L2),
    append(R1, R2, R0),
    sort(R0, R).

%!  opuestos(+Unificar, +L1, +L2) is semidet.
%
%   L1 y L2 tienen signos opuestos y Unificar unifica sus fórmulas.
opuestos(U, +A, -B) :-
    call(U, A, B).
opuestos(U, -A, +B) :-
    call(U, A, B).

%!  factor(+Unificar, +C:list, -R:list) is nondet.
%
%   R es un factor de una copia de C: dos literales del mismo signo se
%   unifican con Unificar, y quedan como uno solo.
factor(U, C, R) :-
    copy_term(C, D),
    select(L1, D, D1),
    member(L2, D1),
    mismo_signo(L1, L2),
    call(U, L1, L2),
    sort(D1, R).

%!  mismo_signo(+L1, +L2) is semidet.
%
%   L1 y L2 son los dos positivos o los dos negativos.
mismo_signo(+_, +_).
mismo_signo(-_, -_).

%!  redundante(+Opciones, +R:list, +Clausulas:list) is semidet.
%
%   R no aporta nada a las Clausulas: es una variante de una de ellas o,
%   con el filtro subsumida, alguna de ellas lo subsume.
redundante(opciones(_, repetida, _, _), R, Clausulas) :-
    member(C, Clausulas),
    C =@= R,
    !.
redundante(opciones(_, subsumida, _, _), R, Clausulas) :-
    member(C, Clausulas),
    subsume(C, R),
    !.

%!  subsume(+C:list, +D:list) is semidet.
%
%   La cláusula C subsume a D: C no tiene más literales que D, y alguna
%   sustitución de las variables de C convierte cada literal de C en un
%   literal de D. Sin la condición sobre la cantidad, una cláusula
%   subsumiría a sus propios factores. C y D no comparten variables. Las
%   variables de D se congelan con numbervars/3, dentro de una doble
%   negación que deshace todas las ligaduras.
subsume(C, D) :-
    length(C, NC),
    length(D, ND),
    NC =< ND,
    \+ \+ ( numbervars(D, 0, _),
            subconjunto(C, D)
          ).

%!  subconjunto(+C:list, +D:list) is nondet.
%
%   Cada literal de C unifica con algún literal de D.
subconjunto([], _).
subconjunto([L|Ls], D) :-
    member(L, D),
    subconjunto(Ls, D).
