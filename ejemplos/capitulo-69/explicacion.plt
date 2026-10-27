:- encoding(utf8).

:- use_module(library(apply)).
:- use_module(library(lists)).

:- begin_tests(explicacion).

test(taza1, [true(Raiz == taza(taza1))]) :-
    hechos(taza1, Hs),
    once(explicar(taza, Hs, taza(taza1), prueba(Raiz, _))).

test(vaso1, [fail]) :-
    hechos(vaso1, Hs),
    explicar(taza, Hs, taza(vaso1), _).

% Cada hoja de la prueba es un hecho de la descripción o una comparación
% predefinida.
test(hojas, [true]) :-
    hechos(taza1, Hs),
    once(explicar(taza, Hs, taza(taza1), A)),
    forall(hoja(A, H),
           (   H = sis(_)
           ->  true
           ;   H = prueba(G, []),
               memberchk(G, Hs)
           )).

test(color_no_interviene, [fail]) :-
    hechos(taza1, Hs),
    once(explicar(taza, Hs, taza(taza1), A)),
    hoja(A, prueba(color(_, _), [])).

test(taza2_carton, [true]) :-
    hechos(taza2, Hs),
    once(explicar(taza, Hs, taza(taza2), A)),
    once(hoja(A, prueba(material(taza2, carton), []))).

test(una_prueba, [true(N == 1)]) :-
    hechos(taza1, Hs),
    aggregate_all(count, explicar(taza, Hs, taza(taza1), _), N).

test(familia, [true(A =@= prueba(abuelo(juan, luis),
                          [ prueba(varon(juan), []),
                            prueba(progenitor(juan, pedro),
                                   [prueba(padre(juan, pedro), [])]),
                            prueba(progenitor(pedro, luis),
                                   [prueba(padre(pedro, luis), [])]) ]))]) :-
    hechos(familia, Hs),
    once(explicar(familia, Hs, abuelo(juan, luis), A)).

test(operacional, [true]) :-
    operacional(taza, peso(_, _)),
    \+ operacional(taza, liviano(_)).

test(como, [true(sub_string(S, 0, _, _, "taza(taza1)\n  se_levanta(taza1)\n"))]) :-
    with_output_to(string(S), once(como(taza, taza1, taza(taza1)))).

test(poblacion, [true(Ts == [o1, o9, o25, o41])]) :-
    clasificar_con_teoria(taza, Ts).

% hoja(A, H): H es una hoja del árbol de prueba A.
hoja(sis(G), sis(G)).
hoja(prueba(G, []), prueba(G, [])).
hoja(prueba(_, [H|Hs]), Hoja) :-
    member(A, [H|Hs]),
    hoja(A, Hoja).

:- end_tests(explicacion).
