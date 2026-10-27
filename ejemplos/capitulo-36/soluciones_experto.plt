:- encoding(utf8).

:- begin_tests(soluciones_experto).

% Ejercicio 13
test(murcielago, all(A == [murcielago])) :-
    caso(6, Obs),
    identificar_compilado(Obs, A).

test(murcielago_interpretado, all(A == [murcielago])) :-
    caso(6, Obs),
    identificar(Obs, A).

test(r13_compilada,
     true(C =@= (concluir(murcielago, F, P,
                          deducido(murcielago, r13, A y observado(vuela))) :-
                     concluir(mamifero, F, [r13-murcielago|P], A),
                     observar(F, vuela, [r13-murcielago|P])))) :-
    T = deducido(murcielago, r13, _),
    clause(concluir(murcielago, F0, P0, T), B),
    C = (concluir(murcielago, F0, P0, T) :- B).

% Una regla agregada al ejecutar la ve el intérprete, no la versión
% compilada.
test(regla_agregada,
     [ setup(( assertz(user:regla(r14, si ave y nada entonces pato)),
               assertz(user:hipotesis(pato)) )),
       cleanup(( retract(user:regla(r14, _)),
                 retract(user:hipotesis(pato)) )),
       true(As-Bs == [pato]-[]) ]) :-
    findall(A, identificar([tiene_plumas, nada], A), As),
    findall(A, identificar_compilado([tiene_plumas, nada], A), Bs).

% Ejercicio 14: la traducción directa da las cláusulas de la expansión.
test(sin_evaluador, forall(clause(regla(R, C), true))) :-
    compilar_regla(regla(R, C), Clausula),
    Clausula = (Cabeza :- _),
    Cabeza = concluir(_, _, _, deducido(_, R, _)),
    once(clause(Cabeza, Cuerpo)),
    assertion(Clausula =@= (Cabeza :- Cuerpo)).

:- end_tests(soluciones_experto).
