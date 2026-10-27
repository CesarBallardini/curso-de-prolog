:- encoding(utf8).

:- begin_tests(negacion).

% Flach: la explicación de que vuela supone que no es pingüino ni está
% muerta, y la del pingüino se descarta.
test(vuela, all(S == [[gorrion(piolin)-verdadero, pinguino(piolin)-falso,
                       muerto(piolin)-falso]])) :-
    suponer(vuela(piolin), S),
    cerrar(S).

% El orden de las metas cambia el orden de los supuestos, no cuáles son.
test(vuela_bis, all(S == [[pinguino(piolin)-falso, muerto(piolin)-falso,
                           gorrion(piolin)-verdadero]])) :-
    suponer(vuela_bis(piolin), S),
    cerrar(S).

test(luz_apagada, all(S == [[hay_corriente-falso], [lampara_sana-falso]])) :-
    suponer(no(enciende), S),
    cerrar(S).

% La radio suena: hay corriente, y la lámpara es la sospechosa.
test(radio, all(S == [[lampara_sana-falso, hay_corriente-verdadero]])) :-
    suponer((no(enciende), suena_la_radio), S),
    cerrar(S).

test(luz_encendida, all(S == [[hay_corriente-verdadero,
                               lampara_sana-verdadero]])) :-
    suponer(enciende, S),
    cerrar(S).

% Un abducible no se supone con los dos valores.
test(contradiccion, [fail]) :-
    suponer((enciende, no(suena_la_radio)), _).

% Un supuesto previo se respeta.
test(supuesto_previo, [fail]) :-
    suponer(vuela(piolin), [gorrion(piolin)-falso|_]).

% Un hecho no se puede refutar.
test(hecho, [fail]) :-
    refutar(llave_cerrada, _).

% Un átomo sin reglas que no es abducible es falso sin suponer nada.
test(sin_reglas, all(S == [[]])) :-
    suponer(no(nada), S),
    cerrar(S).

test(refutar_conjuncion, all(S == [[hay_corriente-falso],
                                   [lampara_sana-falso]])) :-
    refutar((hay_corriente, lampara_sana), S),
    cerrar(S).

test(refutar_negacion, all(S == [[hay_corriente-verdadero]])) :-
    refutar(no(suena_la_radio), S),
    cerrar(S).

test(refutar_todos, all(S == [[pinguino(piolin)-falso,
                               muerto(piolin)-falso]])) :-
    negacion:refutar_todos([pinguino(piolin), muerto(piolin)], S),
    cerrar(S).

test(refutar_todos_vacia, all(S == [[]])) :-
    negacion:refutar_todos([], S),
    cerrar(S).

test(cerrar, [true(D == [a])]) :-
    D = [a|_],
    cerrar(D).

:- end_tests(negacion).
