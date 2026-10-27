:- encoding(utf8).

:- begin_tests(puntaje, [setup(iniciar_puntaje), cleanup(iniciar_puntaje)]).

% recorrido(Ordenes): una secuencia de órdenes que gana la partida.
recorrido([ ir(biblioteca), tomar(llave), ir(vestibulo),
            abrir(puerta_taller), ir(taller), tomar(linterna),
            encender(linterna), abrir(trampilla), ir(sotano), abrir(baul),
            tomar(lente), ir(taller), ir(vestibulo), ir(biblioteca),
            ir(cupula), poner(lente, telescopio) ]).

test(al_empezar, true(P-T == 0-0)) :-
    iniciar_puntaje,
    puntaje(P),
    turnos(T).

test(un_logro, true(P-T == 5-2)) :-
    iniciar_puntaje,
    jugada(ir(biblioteca), _),
    jugada(tomar(llave), _),
    puntaje(P),
    turnos(T).

test(el_logro_queda, true(P == 5)) :-
    iniciar_puntaje,
    jugada(ir(biblioteca), _),
    jugada(tomar(llave), _),
    jugada(dejar(llave), _),
    puntaje(P).

test(no_se_cuenta_dos_veces, true(P == 5)) :-
    iniciar_puntaje,
    jugada(ir(biblioteca), _),
    jugada(tomar(llave), _),
    jugada(dejar(llave), _),
    jugada(tomar(llave), _),
    puntaje(P).

test(orden_bloqueada_cuenta, true(R-T == no_puede(cerrado(puerta_taller))-1)) :-
    iniciar_puntaje,
    jugada(ir(taller), R),
    turnos(T).

test(partida_completa, true(P-T == 50-16)) :-
    iniciar_puntaje,
    recorrido(Os),
    forall(member(O, Os), jugada(O, _)),
    puntaje(P),
    turnos(T).

test(maximo, true(M == 50)) :-
    maximo(M).

test(rangos, true(Rs == ["principiante", "explorador",
                         "astrónomo aficionado", "astrónomo"])) :-
    maplist(rango, [9, 10, 49, 50], Rs).

test(informe, true(T == "Obtuviste 5 de 50 puntos posibles en 3 \c
                         turnos. Tu rango: principiante.")) :-
    iniciar_puntaje,
    jugada(ir(biblioteca), _),
    jugada(tomar(llave), _),
    jugada(dejar(llave), _),
    informe(T).

test(nuevo_logro, all(H == [esta_en(llave, jugador)])) :-
    iniciar_puntaje,
    estado:realizar(ir(biblioteca), _),
    estado:realizar(tomar(llave), _),
    puntaje:nuevo_logro(H).

:- end_tests(puntaje).
