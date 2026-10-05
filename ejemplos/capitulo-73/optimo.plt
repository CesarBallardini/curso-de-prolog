:- encoding(utf8).

:- use_module(library(clpfd)).

:- begin_tests(optimo).

test(cota_cuatrimestre, [true(C == 8)]) :-
    oferta(cuatrimestre, O),
    cota_inferior(O, C).

test(cota_facultad, [true(C == 9)]) :-
    oferta(facultad(6), O),
    cota_inferior(O, C).

test(optimo_cotas, [true(C == 8)]) :-
    oferta(cuatrimestre, O),
    optimo(O, cotas, H, C),
    horario_valido(O, H),
    evaluar(O, H, C).

test(evaluar_ejemplo, [true(C == 10)]) :-
    oferta(cuatrimestre, O),
    horario_ejemplo(H),
    evaluar(O, H, C).

test(evaluar_hueco, [true(C == 2)]) :-
    oferta(materias([am1], 1, 3), O0),
    O0 = oferta(_, [Clase|_], Aulas, Docentes),
    O = oferta(semana(1, 3), [Clase], Aulas, Docentes),
    evaluar(O, [asignada(am1-1, 1, 0, 1)], 1),
    O2 = oferta(semana(1, 3), [Clase, clase(alg-1, alg, 1, garcia, 35)],
                Aulas, [disponible(garcia, [1])|Docentes]),
    evaluar(O2, [asignada(am1-1, 1, 0, 1), asignada(alg-1, 1, 2, 3)], C).

test(costo_igual_a_evaluar, [true(C == E)]) :-
    oferta(cuatrimestre, O),
    horario_ejemplo(H0),
    findall(asignada(Cl, A, _, _), member(asignada(Cl, A, _, _), H0), H),
    costo(O, H, C),
    maplist(fijar(H0), H),
    evaluar(O, H0, E).

test(mejor_cuatrimestre, [true(G == optimo(8))]) :-
    oferta(cuatrimestre, O),
    mejor_con_limite(O, 5000000, H, G),
    horario_valido(O, H).

test(mejor_con_garantia, [true(G == entre(9, 11))]) :-
    oferta(facultad(6), O),
    mejor_con_limite(O, 1000000, H, G),
    horario_valido(O, H),
    evaluar(O, H, 11).

test(carrera) :-
    oferta(facultad(14), O),
    carrera(O, E, H),
    memberchk(E, [momentos, pares, simple]),
    horario_valido(O, H).

test(sin_horario, [fail]) :-
    oferta(facultad(18), O),
    optimo(O, cotas, _, _).

%!  fijar(+Horario0:list, +Asignada) is det.
%
%   El momento de Asignada es el de su clase en Horario0.
fijar(Horario0, asignada(C, _, S, F)) :-
    memberchk(asignada(C, _, S0, F0), Horario0),
    S #= S0,
    F = F0.

:- end_tests(optimo).
