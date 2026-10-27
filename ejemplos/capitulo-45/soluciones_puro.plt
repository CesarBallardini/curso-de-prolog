:- encoding(utf8).

:- use_module(estado).

:- begin_tests(soluciones_puro, [setup(iniciar), cleanup(iniciar)]).

%!  como_la_base(+Hechos:list, +Ordenes:list) is semidet.
%
%   A partir del estado Hechos, las Ordenes dan las mismas respuestas y el
%   mismo estado final con paso/4 que con realizar/2.
como_la_base(Hechos, Ordenes) :-
    msort(Hechos, E0),
    pasos(Ordenes, E0, E, Rs),
    restablecer(Hechos),
    maplist(realizar, Ordenes, Rs0),
    instantanea(H),
    assertion(Rs == Rs0),
    assertion(E == H).

test(recorrido, true) :-
    findall(H, mundo:inicio(H), Hechos),
    como_la_base(Hechos,
                 [ mirar, ir(taller), ir(biblioteca), tomar(escritorio),
                   tomar(llave), tomar(llave), ir(cupula), ir(vestibulo),
                   dejar(llave), dejar(catalogo), tomar(llave),
                   tomar(puerta_taller), ir(biblioteca), mirar ]).

test(a_oscuras, true) :-
    como_la_base([ aqui(sotano), esta_en(linterna, jugador),
                   esta_en(baul, sotano), esta_en(lente, baul) ],
                 [ mirar, tomar(lente), dejar(linterna), ir(taller) ]).

test(con_luz, true) :-
    como_la_base([ aqui(sotano), esta_en(linterna, jugador),
                   encendido(linterna), esta_en(baul, sotano),
                   esta_en(lente, baul) ],
                 [ mirar, tomar(lente), dejar(linterna), mirar ]).

test(no_toca_la_base, true(H == H0)) :-
    iniciar,
    instantanea(H0),
    pasos([ir(biblioteca), tomar(llave)], H0, _, _),
    instantanea(H).

test(impedimento_en, all(M == [cerrado(puerta_taller)])) :-
    iniciar,
    instantanea(E),
    soluciones_puro:impedimento_en(E, ir(taller), M).

test(impedimento_en_ninguno, fail) :-
    iniciar,
    instantanea(E),
    soluciones_puro:impedimento_en(E, ir(biblioteca), _).

test(efecto_en, true(R-A == vista(biblioteca, [catalogo, escritorio],
                                   [cupula, vestibulo])-aqui(biblioteca))) :-
    iniciar,
    instantanea(E0),
    soluciones_puro:efecto_en(ir(biblioteca), E0, E, R),
    memberchk(aqui(S), E),
    A = aqui(S).

test(reemplazar, true(E == [a, c, z])) :-
    soluciones_puro:reemplazar(b, z, [a, b, c], E).

test(reemplazar_ausente, fail) :-
    soluciones_puro:reemplazar(q, z, [a, b, c], _).

test(a_oscuras_en) :-
    soluciones_puro:a_oscuras_en([aqui(sotano)]).

test(al_alcance_en, all(X == [puerta_biblioteca, puerta_taller, perchero])) :-
    iniciar,
    instantanea(E),
    soluciones_puro:al_alcance_en(E, X).

test(paso_mirar, true(R == vista(vestibulo, [perchero], [biblioteca, taller]))) :-
    iniciar,
    instantanea(E0),
    paso(mirar, E0, E, R),
    assertion(E == E0).

:- end_tests(soluciones_puro).
