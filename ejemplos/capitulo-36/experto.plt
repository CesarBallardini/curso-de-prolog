:- encoding(utf8).

:- begin_tests(experto).

% Las reglas compiladas identifican lo mismo que el intérprete.
test(identifica_igual, forall(caso(N, Obs))) :-
    findall(A, identificar(Obs, A), As),
    findall(A, identificar_compilado(Obs, A), Bs),
    assertion(N-As == N-Bs).

test(caso_3, all(A == [avestruz])) :-
    caso(3, Obs),
    identificar_compilado(Obs, A).

% Los mismos árboles, en el mismo orden.
test(arboles, forall(( member(M, [mamifero, carnivoro, cebra, avestruz]),
                        caso(_, Obs) ))) :-
    findall(T, demostrar(M, lista(Obs), [], T), Ts),
    findall(T, concluir(M, lista(Obs), [], T), Us),
    assertion(Ts == Us).

% Las reglas siguen cargadas como datos.
test(reglas, true(N == 12)) :-
    aggregate_all(count, regla(_, _), N).

% Una regla con una conclusión de otra regla, una observación y una
% comparación.
test(compilada,
     true(C =@= (concluir(avestruz, F, P,
                          deducido(avestruz, r12,
                                   A y observado(no_vuela)
                                     y observado(peso(K)) y K > 50)) :-
                     concluir(ave, F, [r12-avestruz|P], A),
                     observar(F, no_vuela, [r12-avestruz|P]),
                     observar(F, peso(K), [r12-avestruz|P]),
                     K > 50))) :-
    T0 = deducido(avestruz, r12, _),
    clause(concluir(avestruz, F0, P0, T0), B0),
    C = (concluir(avestruz, F0, P0, T0) :- B0).

test(una_por_regla, true(N == 13)) :-
    aggregate_all(count, clause(concluir(_, _, _, _), _), N).

% La versión compilada usa menos inferencias que el intérprete.
test(menos_inferencias, true(I2 < I1 * 3 / 4)) :-
    inferencias(identificar_casos(identificar, 100), I1),
    inferencias(identificar_casos(identificar_compilado, 100), I2).

% regla/2 es estática: una regla no se agrega durante la ejecución.
test(regla_estatica,
     [error(permission_error(modify, static_procedure, regla/2))]) :-
    assertz(user:regla(r99, si nada entonces nada)).

test(simple, all(C =@= [mamifero, peso(_)])) :-
    member(C, [mamifero, peso(_), a y b, 1 > 0, 1 < 2]),
    simple(C).

:- end_tests(experto).

%!  inferencias(:G, -N:integer) is det.
%
%   N es la cantidad de inferencias de una ejecución de G.
inferencias(G, N) :-
    statistics(inferences, I0),
    once(G),
    statistics(inferences, I1),
    N is I1 - I0.
