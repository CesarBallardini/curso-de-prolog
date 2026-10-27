:- encoding(utf8).

:- begin_tests(transito).

test(luz, [true(Ls == [rojo-fija, flecha_verde-izquierda])]) :-
    findall(T-E, luz([luz(rojo, fija), puede_frenar,
                      luz(flecha_verde, izquierda)], T, E), Ls).

test(puede_frenar) :-
    puede_frenar([luz(rojo, fija), puede_frenar]).

test(no_puede_frenar, [fail]) :-
    puede_frenar([luz(rojo, fija)]).

test(cruce_horario) :-
    cruce_horario([cruce_horario]).

test(alto_peaton, [true(Es == [intermitente])]) :-
    findall(E, alto_peaton([luz(mano, intermitente)], E), Es).

test(paso_peaton, [true(Es == [fija])]) :-
    findall(E, paso_peaton([luz(cruce, fija)], E), Es).

test(senales_peaton) :-
    senales_peaton([luz(silueta, intermitente), luz(espere, fija)]).

test(sin_senales_peaton, [fail]) :-
    senales_peaton([luz(verde, fija)]).

test(verde_de_frente) :-
    verde_de_frente([luz(flecha_verde, derecha)]),
    verde_de_frente([cruce_horario, luz(flecha_verde, izquierda)]).

test(verde_no_de_frente, [fail]) :-
    verde_de_frente([cruce_horario, luz(flecha_verde, derecha)]).

test(auto_amarillo, [true(As == [detenerse])]) :-
    findall(A, auto([luz(amarillo, fija), puede_frenar], A), As).

test(peaton_paso, [true(As == [ceder_y_avanzar])]) :-
    findall(A, peaton([luz(silueta, fija)], A), As).

test(ejemplo_auto, [true(As == [ceder_y_girar_izquierda, detenerse])]) :-
    findall(A, accion_v1([puede_frenar, luz(amarillo, fija),
                          luz(flecha_verde, izquierda)], auto, A), As).

test(ejemplo_peaton, [true(As == [avanzar])]) :-
    findall(A, accion_v1([cruce_horario, luz(verde, fija),
                          luz(silueta, intermitente)], peaton, A), As).

test(v1_omision_con_especifica, [true(As == [avanzar_despacio, avanzar])]) :-
    findall(A, accion_v1([luz(amarillo, intermitente)], auto, A), As).

test(v1_peaton_como_auto, [true(As == [ceder_y_avanzar, avanzar, avanzar])]) :-
    findall(A, accion_v1([luz(verde, fija)], peaton, A), As).

test(especifica, [true(As == [detenerse])]) :-
    findall(A, especifica([luz(rojo, fija)], auto, A), As).

test(accion_solo_especifica, [true(As == [avanzar_despacio])]) :-
    findall(A, accion([luz(amarillo, intermitente)], auto, A), As).

test(accion_por_omision, [true(As == [avanzar])]) :-
    findall(A, accion([], auto, A), As).

test(accion_peaton_como_auto, [true(As == [ceder_y_avanzar])]) :-
    findall(A, accion([luz(verde, fija)], peaton, A), As).

test(accion_peaton_flecha_de_frente, [true(As == [detenerse])]) :-
    findall(A, accion([luz(flecha_verde, derecha)], peaton, A), As).

test(decision, [true(A == ceder_y_girar_izquierda)]) :-
    decision([puede_frenar, luz(amarillo, fija),
              luz(flecha_verde, izquierda)], auto, A).

test(tabla, [true(N == 24)]) :-
    tabla(auto, Filas),
    length(Filas, N).

test(tabla_una_accion) :-
    tabla(auto, Filas),
    forall(member(_-_-As, Filas), length(As, 1)).

test(tabla_fila, [true(As == [ceder_y_avanzar])]) :-
    tabla(auto, Filas),
    memberchk(luz(amarillo, fija)-no-As, Filas).

:- end_tests(transito).
