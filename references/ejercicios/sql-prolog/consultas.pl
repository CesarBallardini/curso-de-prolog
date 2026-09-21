% Unidad 11: Prolog y SQL. Soluciones Prolog de los ejercicios PAR-n.
%
% Cada sección "%% PAR-n" contiene las reglas que pide el ejercicio y una
% cláusula par(n, Fila): su cuerpo es exactamente la consulta que el alumno
% escribiría en SWISH (?- Cuerpo.) y Fila lista las columnas del resultado,
% en el mismo orden que el SELECT de la solución SQL.
%
% Las cláusulas con identificador de la forma 'nb' (por ejemplo '35b') son
% verificaciones adicionales que se mencionan en las notas del ejercicio.
%
% Uso: verificar.py carga datos.pl y este archivo y ejecuta cada par/2
% dentro de snapshot/1, de modo que los assertz/retract de un ejercicio no
% afectan a los demás.

:- ensure_loaded(datos).
:- discontiguous par/2.

%% PAR-1
par(1, [L, N]) :-
    alumno(L, N, sistemas, _).

%% PAR-2
par(2, [N, C, I]) :-
    alumno(_, N, C, I), I >= 2024, C \== civil.

%% PAR-3
par(3, [C]) :-
    alumno(_, _, C, _).

%% PAR-4
par(4, [C]) :-
    setof(C0, L^N^I^alumno(L, N, C0, I), Cs), member(C, Cs).

%% PAR-5
par(5, [I, N]) :-
    order_by([asc(I), asc(N)], alumno(_, N, _, I)).

%% PAR-6
par(6, [N, Nota]) :-
    inscripcion(L, am1, Nota), alumno(L, N, _, _).

%% PAR-7
par(7, [A, NM, Nota]) :-
    inscripcion(L, M, Nota), integer(Nota), Nota >= 6,
    alumno(L, A, _, _), materia(M, NM, _).

%% PAR-8
par(8, [N1, N2, C]) :-
    alumno(L1, N1, C, _), alumno(L2, N2, C, _), L1 < L2.

%% PAR-9
en_am1_o_log(L) :- inscripcion(L, am1, _).
en_am1_o_log(L) :- inscripcion(L, log, _).

par(9, [L]) :-
    setof(L0, en_am1_o_log(L0), Ls), member(L, Ls).

%% PAR-10
par(10, [L]) :-
    en_am1_o_log(L).

%% PAR-11
par(11, [L]) :-
    inscripcion(L, am1, _), inscripcion(L, alg, _).

%% PAR-12
par(12, [L]) :-
    inscripcion(L, am1, _), \+ inscripcion(L, alg, _).

%% PAR-13
par(13, [L, N]) :-
    alumno(L, N, _, _), \+ inscripcion(L, _, _).

%% PAR-14
par(14, [L, N]) :-
    \+ inscripcion(L, _, _), alumno(L, N, _, _).

%% PAR-15
aprobada(L, M, N) :-
    inscripcion(L, M, N), integer(N), N >= 6.

par(15, [M]) :-
    aprobada(101, M, _).

%% PAR-16
par(16, [L, N]) :-
    alumno(L, N, _, _),
    forall(materia(M, _, 1), aprobada(L, M, _)).

par('16b', [L, N]) :-
    alumno(L, N, _, _),
    \+ ( materia(M, _, 1), \+ aprobada(L, M, _) ).

%% PAR-17
par(17, [K]) :-
    aggregate_all(count, alumno(_, _, sistemas, _), K).

%% PAR-18
par(18, [C, K]) :-
    bagof(L, N^I^alumno(L, N, C, I), Ls), length(Ls, K).

%% PAR-19
par(19, [M, K]) :-
    materia(M, _, _), aggregate_all(count, inscripcion(_, M, _), K).

%% PAR-20
par(20, [L, P]) :-
    bagof(N, M^(inscripcion(L, M, N), integer(N)), Ns),
    sum_list(Ns, S), length(Ns, K), P is S / K.

%% PAR-21
par(21, [A, Max]) :-
    aggregate_all(max(N), (inscripcion(_, log, N), integer(N)), Max),
    inscripcion(L, log, Max), alumno(L, A, _, _).

%% PAR-22
par(22, [N, K]) :-
    alumno(L, N, _, _),
    aggregate_all(count, aprobada(L, _, _), K), K >= 3.

%% PAR-23
par(23, [E, J]) :-
    empleado(_, E, _, _, IdJ), empleado(IdJ, J, _, _, _).

%% PAR-24
jefe_o_null(E, J) :-
    empleado(_, E, _, _, IdJ), empleado(IdJ, J, _, _, _).
jefe_o_null(E, null) :-
    empleado(_, E, _, _, IdJ), \+ empleado(IdJ, _, _, _, _).

par(24, [E, J]) :-
    jefe_o_null(E, J).

%% PAR-25
par(25, [E, ND]) :-
    empleado(_, E, D, _, _), departamento(D, ND, rosario).

%% PAR-26
par(26, [D]) :-
    departamento(D, _, _), \+ empleado(_, _, D, _, _).

%% PAR-27
par(27, [D, T]) :-
    departamento(D, _, _),
    aggregate_all(sum(S), empleado(_, _, D, S, _), T), T > 1000000.

%% PAR-28
par(28, [D, N, S]) :-
    empleado(_, N, D, S, _),
    \+ ( empleado(_, _, D, S2, _), S2 > S ).

%% PAR-29
par(29, [N, S]) :-
    limit(3, order_by([desc(S)], empleado(_, N, _, S, _))).

%% PAR-30
par(30, [Id, N]) :-
    empleado(Id, N, _, _, _), \+ empleado(_, _, _, _, Id).

%% PAR-31
par(31, [Id, N]) :-
    empleado(Id, N, _, _, _), \+ empleado(_, _, _, _, Id).

%% PAR-32
par(32, [N]) :-
    empleado(_, N, _, _, J), J \== 1.

par('32b', [N]) :-
    empleado(_, N, _, _, J), J \== null, J \== 1.

%% PAR-33
subordinado(S, J) :-
    empleado(S, _, _, _, J).
subordinado(S, J) :-
    empleado(S, _, _, _, X), subordinado(X, J).

par(33, [Id, N]) :-
    subordinado(Id, 3), empleado(Id, N, _, _, _).

%% PAR-34
nivel(Id, 0) :-
    empleado(Id, _, _, _, null).
nivel(Id, K) :-
    empleado(Id, _, _, _, J), nivel(J, K0), K is K0 + 1.

par(34, [N, K]) :-
    empleado(Id, N, _, _, _), nivel(Id, K).

%% PAR-35
requisito(M, R) :-
    correlativa(M, R).
requisito(M, R) :-
    correlativa(M, X), requisito(X, R).

par(35, [R]) :-
    setof(R0, requisito(bd, R0), Rs), member(R, Rs).

par('35b', [R]) :-
    requisito(bd, R).

%% PAR-36
par(36, [Y, Z, P]) :-
    vuelo(ros, Y, _, P1), vuelo(Y, Z, _, P2), P is P1 + P2.

%% PAR-37
:- table alcanza/2.
alcanza(X, Y) :- vuelo(X, Y, _, _).
alcanza(X, Y) :- alcanza(X, Z), vuelo(Z, Y, _, _).

par(37, [Y]) :-
    alcanza(ros, Y).

%% PAR-38
:- table costo(_, _, min).
costo(X, Y, P) :- vuelo(X, Y, _, P).
costo(X, Y, P) :- costo(X, Z, P1), vuelo(Z, Y, _, P2), P is P1 + P2.

par(38, [Y, P]) :-
    costo(ros, Y, P).

%% PAR-39
par(39, [M, N]) :-
    assertz(inscripcion(107, log, null)),
    inscripcion(107, M, N).

%% PAR-40
par(40, [M, N]) :-
    retract(inscripcion(101, pp, _)),
    assertz(inscripcion(101, pp, 8)),
    inscripcion(101, M, N).

%% PAR-41
par(41, [Id, S]) :-
    forall(retract(empleado(I, Nom, it, S0, J)),
           ( S1 is S0 * 110 // 100, assertz(empleado(I, Nom, it, S1, J)) )),
    empleado(Id, _, it, S, _).

%% PAR-42
par(42, [Total, SinNota]) :-
    retractall(inscripcion(_, _, null)),
    aggregate_all(count, inscripcion(_, _, _), Total),
    aggregate_all(count, inscripcion(_, _, null), SinNota).

%% PAR-43
par(43, [O, D, P]) :-
    forall(( vuelo(O0, D0, fb, P0), P0 > 70 ), retract(vuelo(O0, D0, fb, P0))),
    vuelo(O, D, fb, P).

%% PAR-44
alta_alumno(L, N, C, I) :-
    \+ alumno(L, _, _, _),
    assertz(alumno(L, N, C, I)).

par(44, [N]) :-
    ( alta_alumno(101, zoe, civil, 2025) -> true ; true ),
    alumno(101, N, _, _).

par('44b', [N]) :-
    assertz(alumno(101, zoe, civil, 2025)),
    alumno(101, N, _, _).

%% PAR-45
alta_inscripcion(L, M) :-
    alumno(L, _, _, _),
    materia(M, _, _),
    \+ inscripcion(L, M, _),
    assertz(inscripcion(L, M, null)).

par(45, [L, M, N]) :-
    ( alta_inscripcion(999, am1) -> true ; true ),
    ( alta_inscripcion(107, am1) -> true ; true ),
    inscripcion(L, M, N), member(L, [999, 107]).

%% PAR-46
par(46, [K]) :-
    aggregate_all(count, alumno(_, _, quimica, _), K).

par('46b', [C, K]) :-
    C = quimica,
    bagof(L, N^I^alumno(L, N, C, I), Ls), length(Ls, K).

%% PAR-47
par(47, [T]) :-
    aggregate_all(sum(S), empleado(_, _, legal, S, _), T).

par('47b', [M]) :-
    aggregate_all(max(S), empleado(_, _, legal, S, _), M).

%% PAR-48
alcanza_sin_tabla(X, Y) :- vuelo(X, Y, _, _).
alcanza_sin_tabla(X, Y) :- vuelo(X, Z, _, _), alcanza_sin_tabla(Z, Y).

par(48, [R]) :-
    call_with_inference_limit(
        findall(Y, alcanza_sin_tabla(ros, Y), _), 100000, R0),
    ( R0 == inference_limit_exceeded -> R = no_termina ; R = termina ).

%% PAR-49
par(49, [L, M, N]) :-
    inscripcion(L, M, N), \+ aprobada(L, M, _).

%% PAR-50
par(50, [B, S]) :-
    findall(C, alumno(_, _, C, _), Bolsa), length(Bolsa, B),
    sort(Bolsa, Conjunto), length(Conjunto, S).
