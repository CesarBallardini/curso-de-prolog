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

:- end_tests(arbol).
