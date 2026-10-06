:- encoding(utf8).

:- use_module(programas).

:- begin_tests(alternativas).

test(antepasado, all(D == [ana, pedro, luis, eva])) :-
    resolver(familia, antepasado(juan, D)).

test(concatenar, [true(Rs =@= Ns)]) :-
    findall(concatenar(X, Y, [1, 2, 3]),
            resolver(listas, concatenar(X, Y, [1, 2, 3])), Rs),
    respuestas_nativas(listas, concatenar(_, _, [1, 2, 3]), Ns).

test(invertir, all(R == [[5, 4, 3, 2, 1]])) :-
    resolver(listas, invertir_hasta(5, R)).

test(pasos, [true(P-A == 810-2)]) :-
    medir(listas, suma_hasta(100, _), [pasos-P, respuestas-1,
                                       alternativas-A, copiado-_]).

% Duplicar la lista multiplica lo copiado por más de tres.
test(copiado, [true(C200 > 3 * C100)]) :-
    medir(listas, suma_hasta(100, _), [_, _, _, copiado-C100]),
    medir(listas, suma_hasta(200, _), [_, _, _, copiado-C200]).

% expandir/5 da una alternativa por cada cláusula cuya cabeza unifica,
% con la consulta instanciada en cada una.
test(expandir_usuario, [true(Ns == [alt([true, c], r(1)), alt([true, c], r(2))])]) :-
    alternativas:expandir(usuario(p(X)), [c], r(X),
                          [(p(1) :- true), (q(3) :- true), (p(2) :- true)],
                          Ns).

test(expandir_conjuncion, [true(Ns == [alt([a, b, c], r)])]) :-
    alternativas:expandir(conjuncion(a, b), [c], r, [], Ns).

test(expandir_falla, [true(Ns == [])]) :-
    alternativas:expandir(predefinida(2 < 1), [c], r, [], Ns).

% buscar/4 entrega las respuestas de la pila en orden y termina con fin/1.
test(buscar, all(E == [respuesta(r(1)), respuesta(r(2)), fin(med(0, 0, 0))])) :-
    alternativas:buscar([alt([], r(1)), alt([], r(2))], [], med(0, 0, 0), E).

test(buscar_vacia, all(E == [fin(m)])) :-
    alternativas:buscar([], [], m, E).

% desde/6 cuenta un paso por meta y la pila más alta.
test(desde, all(E == [respuesta(r), fin(med(2, 1, 0))])) :-
    alternativas:desde([1 < 2, 2 < 3], r, [], [], med(0, 0, 0), E).

:- end_tests(alternativas).
