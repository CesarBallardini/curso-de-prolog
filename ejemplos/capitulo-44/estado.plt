:- encoding(utf8).

:- begin_tests(estado, [setup(iniciar), cleanup(iniciar)]).

% recorrido(Ordenes): una secuencia de órdenes que gana la partida.
recorrido([ ir(biblioteca), tomar(llave), ir(vestibulo),
            abrir(puerta_taller), ir(taller), tomar(linterna),
            encender(linterna), abrir(trampilla), ir(sotano), abrir(baul),
            tomar(lente), ir(taller), ir(vestibulo), ir(biblioteca),
            ir(cupula), poner(lente, telescopio) ]).

%!  ordenes(+Ordenes:list, -Respuestas:list) is det.
%
%   Realiza Ordenes una tras otra; Respuestas son sus respuestas.
ordenes(Ordenes, Respuestas) :-
    maplist(realizar, Ordenes, Respuestas).

test(mirar, true(R == vista(vestibulo, [perchero], [biblioteca, taller]))) :-
    iniciar,
    realizar(mirar, R).

test(ganar, true) :-
    iniciar,
    recorrido(Os),
    ordenes(Os, _),
    ganado.

test(no_gana_al_empezar, fail) :-
    iniciar,
    ganado.

test(puerta_cerrada, true(R == no_puede(cerrado(puerta_taller)))) :-
    iniciar,
    realizar(ir(taller), R).

test(ya_esta, true(R == no_puede(ya_esta(vestibulo)))) :-
    iniciar,
    realizar(ir(vestibulo), R).

test(sin_paso, true(R == no_puede(no_hay_paso(cupula)))) :-
    iniciar,
    realizar(ir(cupula), R).

test(falta_la_llave, true(R == no_puede(falta(llave, puerta_taller)))) :-
    iniciar,
    realizar(abrir(puerta_taller), R).

test(a_oscuras, true(Rs == [oscuridad, no_puede(oscuro)])) :-
    iniciar,
    ordenes([ ir(biblioteca), tomar(llave), ir(vestibulo),
              abrir(puerta_taller), ir(taller), abrir(trampilla)
            ], _),
    ordenes([ir(sotano), tomar(lente)], Rs).

test(fijo, true(R == no_puede(fijo(escritorio)))) :-
    iniciar,
    ordenes([ir(biblioteca)], _),
    realizar(tomar(escritorio), R).

test(dentro_de_un_recipiente_cerrado, fail) :-
    iniciar,
    restablecer([aqui(sotano), encendido(linterna),
                 esta_en(linterna, jugador), esta_en(baul, sotano),
                 esta_en(lente, baul), cerrada(baul)]),
    al_alcance(lente).

test(dentro_de_un_recipiente_abierto, [nondet]) :-
    iniciar,
    ordenes([ir(biblioteca)], _),
    al_alcance(llave).

test(una_puerta_no_se_lleva, true(R == no_puede(fijo(puerta_taller)))) :-
    iniciar,
    realizar(tomar(puerta_taller), R).

test(no_se_abre, true(R == no_puede(no_se_abre(catalogo)))) :-
    iniciar,
    ordenes([ir(biblioteca)], _),
    realizar(abrir(catalogo), R).

test(inventario, true(R == inventario([catalogo, llave]))) :-
    iniciar,
    ordenes([ir(biblioteca), tomar(llave), tomar(catalogo)], _),
    realizar(inventario, R).

test(dejar, true(Os == [catalogo, escritorio])) :-
    iniciar,
    ordenes([ir(biblioteca), tomar(catalogo), ir(vestibulo)], _),
    realizar(dejar(catalogo), R),
    assertion(R == dejado(catalogo, vestibulo)),
    objetos_en(vestibulo, [catalogo, perchero]),
    ordenes([tomar(catalogo), ir(biblioteca), dejar(catalogo)], _),
    objetos_en(biblioteca, Os).

test(orden_desconocida, error(domain_error(orden, volar))) :-
    realizar(volar, _).

test(ida_y_vuelta, true(H == H0)) :-
    iniciar,
    ordenes([ir(biblioteca), tomar(llave)], _),
    instantanea(H0),
    iniciar,
    restablecer(H0),
    instantanea(H).

test(hecho_invalido, [ error(domain_error(hecho_de_estado, esta_en(dragon,
                                                                   cupula))),
                       cleanup(assertion(aqui(vestibulo))) ]) :-
    iniciar,
    restablecer([aqui(cupula), esta_en(dragon, cupula)]).

test(dos_lugares, error(domain_error(estado_con_un_lugar, _))) :-
    restablecer([aqui(cupula), aqui(taller)]).

:- end_tests(estado).
