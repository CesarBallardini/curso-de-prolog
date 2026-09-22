:- encoding(utf8).

:- begin_tests(mascotas).

test(la_gata_de_ana, all(N == [felix])) :-
    tiene(ana, mascota(gato, N)).

test(propietarios_de_gato, all(P == [ana, eva])) :-
    propietario_de_gato(P).

% El término se puede consultar completo, sin examinar sus componentes.
test(termino_entero, all(M == [mascota(perro, rocco)])) :-
    tiene(luis, M).

test(nadie_tiene_caballo, [fail]) :-
    tiene(_, mascota(caballo, _)).

:- end_tests(mascotas).
