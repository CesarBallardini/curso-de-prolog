:- encoding(utf8).

:- use_module(estado).

:- begin_tests(personajes, [setup(iniciar_personajes),
                            cleanup(iniciar_personajes)]).

% en_la_cupula_con_el_gato: el jugador en la cúpula con la lente, y el gato
% en la cúpula.
en_la_cupula_con_el_gato :-
    iniciar_personajes,
    restablecer([aqui(cupula), esta_en(lente, jugador),
                 esta_en(telescopio, cupula)]),
    retract(personajes:paso_en_ruta(gato, _)),
    assertz(personajes:paso_en_ruta(gato, 1)).

test(al_empezar, all(S == [biblioteca])) :-
    iniciar_personajes,
    personaje_en(gato, S).

test(recorrido, true(Ss == [cupula, biblioteca, vestibulo, biblioteca])) :-
    iniciar_personajes,
    findall(S, ( between(1, 4, _),
                 mover_personajes,
                 personaje_en(gato, S) ), Ss).

test(llega, true(Rs == [vista(biblioteca, [catalogo, escritorio],
                              [cupula, vestibulo]),
                        llega(gato)])) :-
    iniciar_personajes,
    turno(mirar, _),
    turno(ir(biblioteca), Rs).

test(se_va, true(Rs == [vista(biblioteca, [catalogo, escritorio],
                              [cupula, vestibulo]),
                        se_va(gato)])) :-
    iniciar_personajes,
    turno(mirar, _),
    turno(ir(biblioteca), _),
    turno(mirar, Rs).

test(bloquea, true(Rs == [no_puede(personaje(gato)), se_va(gato)])) :-
    en_la_cupula_con_el_gato,
    turno(poner(lente, telescopio), Rs).

test(ya_no_bloquea, true(R == puesto(lente, telescopio))) :-
    en_la_cupula_con_el_gato,
    turno(poner(lente, telescopio), _),
    turno(poner(lente, telescopio), [R|_]).

test(textos, true(Ts == ["El gato duerme sobre el telescopio: no puedes \c
                          poner nada en él.", "El gato se va."])) :-
    texto_turno([no_puede(personaje(gato)), se_va(gato)], Ts).

test(texto_llega, true(Ts == ["Entra un gato."])) :-
    texto_turno([mirar_algo, llega(gato)], Ts).

test(avisos, true(As == [llega(b), se_va(a)])) :-
    personajes:avisos([a], [b], As).

:- end_tests(personajes).
