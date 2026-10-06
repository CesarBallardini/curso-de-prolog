:- encoding(utf8).

:- use_module(library(lists)).

:- begin_tests(arbol).

test(medidas, [true(Ms == [m(165, 166, 14), m(178, 179, 14),
                           m(209, 210, 14)])]) :-
    findall(M, ( estrategia(E), arbol(E, A), medidas(A, M) ), Ms).

test(caso_1, [true(H-Ps == guepardo-[tiene_pelo, come_carne,
                                     color_leonado, manchas_oscuras])]) :-
    arbol(orden, A),
    caso(1, Os),
    consultar(A, lista(Os), H, Ps).

test(caso_5, [true(H-N == ninguna-7)]) :-
    arbol(orden, A),
    caso(5, Os),
    consultar(A, lista(Os), H, Ps),
    length(Ps, N).

% Cada prototipo lleva a la hoja de su hipótesis, con cada estrategia.
test(prototipos, [forall(( estrategia(E), prototipo(H, Os) ))]) :-
    arbol(E, A),
    consultar(A, lista(Os), H1, _),
    H1 == H.

test(promedios, [true(Ps == [5.67-6.05, 6.17-5.96, 5.67-6.5])]) :-
    findall(P1-P2, ( estrategia(E), arbol(E, A),
                     promedio(A, prototipos, P1),
                     promedio(A, todos, P2) ),
            Ps).

% Para todos los animales posibles, el árbol da la primera hipótesis que
% prueba el sistema experto del capítulo 33, o ninguna.
test(igual_que_33, [forall(estrategia(E))]) :-
    arbol(E, A),
    forall(observaciones(Os),
           ( consultar(A, lista(Os), H, _),
             (   once(identificar(Os, H0))
             ->  true
             ;   H0 = ninguna
             ),
             ( H == H0 ; identificar(Os, H) ) )).

% construir/4 con reglas abstractas: frecuente elige a, que está en dos
% reglas; en la rama del no quedan solo las reglas sin a.
test(construir, [true(A == pregunta(a,
                                    pregunta(b, hoja(x),
                                             pregunta(c, hoja(y),
                                                      pregunta(d, hoja(z),
                                                               hoja(ninguna)))),
                                    pregunta(d, hoja(z), hoja(ninguna))))]) :-
    arbol:construir(frecuente, [x-[a, b], y-[a, c], z-[d]], [], A).

test(construir_vacio, [true(A == hoja(ninguna))]) :-
    arbol:construir(orden, [], [], A).

% elegir/4 con orden toma la primera pregunta de la primera regla.
test(elegir_orden, [true(P == b)]) :-
    arbol:elegir(orden, [x-[b, a], y-[a]], [], P).

test(elegir_frecuente, [true(P == a)]) :-
    arbol:elegir(frecuente, [x-[b, a], y-[a]], [], P).

% entropia/2: dos hipótesis igualmente frecuentes dan un bit; una sola,
% cero; la lista vacía, cero.
test(entropia, [true(Hs == [1.0, 0.0, 0.0])]) :-
    arbol:entropia([a-[], b-[]], H1),
    arbol:entropia([a-[], a-[]], H2),
    arbol:entropia([], H3),
    maplist([X, Y]>>(Y is abs(X)), [H1, H2, H3], Hs).

% ganancia/3: tiene_pelo separa por completo una cebra de un ave, y gana
% un bit; tiene_plumas no la separa de otra cebra.
test(ganancia, [true(G1-G2 == 1.0-0.0)]) :-
    arbol:ganancia([cebra-[tiene_pelo], ave-[tiene_plumas]], tiene_pelo,
                   G1),
    arbol:ganancia([cebra-[tiene_pelo], cebra-[tiene_pelo]], tiene_plumas,
                   G2).

% consulta/4 construye el árbol de la estrategia y lo recorre.
test(consulta, [true(H == avestruz)]) :-
    caso(3, Os),
    consulta(informacion, Os, H, _).

% medir/4 enumera las estrategias, con las medidas y los promedios de
% medidas/2 y promedio/3.
test(medir, [true(L == [orden-m(165, 166, 14)-5.67-6.05,
                        frecuente-m(178, 179, 14)-6.17-5.96,
                        informacion-m(209, 210, 14)-5.67-6.5])]) :-
    findall(E-M-P1-P2, medir(E, M, P1, P2), L).

:- end_tests(arbol).
