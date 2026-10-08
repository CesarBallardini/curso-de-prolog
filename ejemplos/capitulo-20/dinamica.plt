:- encoding(utf8).

:- begin_tests(dinamica).

% Cada prueba que modifica la base usa guardar/1 y restaurar/1 en setup y
% cleanup, para que el orden de las pruebas no importe. Las pruebas corren en
% su propio módulo: assertz/1 y retractall/1 llevan user: para modificar los
% hechos del programa y no crear otros en el módulo de las pruebas.

%!  guardar(-Estado:list) is det.
%
%   Estado es una copia de los hechos dinámicos del programa.
guardar([Ps, Es, Ns]) :-
    findall(padre(A, B), padre(A, B), Ps),
    findall(edad(A, B), edad(A, B), Es),
    findall(numero(N), numero(N), Ns).

%!  restaurar(+Estado:list) is det.
%
%   Deja los hechos dinámicos como estaban en Estado.
restaurar([Ps, Es, Ns]) :-
    retractall(user:padre(_, _)),
    retractall(user:edad(_, _)),
    retractall(user:numero(_)),
    forall(member(H, Ps), assertz(user:H)),
    forall(member(H, Es), assertz(user:H)),
    forall(member(H, Ns), assertz(user:H)).

% Un predicado dinámico sin hechos falla; uno sin definir produce un error.
test(dinamico_sin_hechos, [fail]) :-
    visita(ana, _).

test(sin_definir, [error(existence_error(procedure, _), _)]) :-
    call(sin_definir, _).

test(nace, [ setup(guardar(E)), cleanup(restaurar(E)),
             all(H == [luis, eva, sofia]) ]) :-
    nace(sofia, pedro),
    padre(pedro, H).

test(cumple_anios, [ setup(guardar(E)), cleanup(restaurar(E)),
                     true(A == 9) ]) :-
    cumple_anios(eva),
    edad(eva, A).

test(cumple_anios_sin_edad, [ setup(guardar(E)), cleanup(restaurar(E)),
                              fail ]) :-
    cumple_anios(zoe).

% asserta/1 agrega al principio; assertz/1, al final.
test(asserta_y_assertz, [ setup(guardar(E)), cleanup(restaurar(E)),
                          true(L == [x-y, juan-ana, juan-pedro, pedro-luis,
                                     pedro-eva, z-w]) ]) :-
    assertz(user:padre(z, w)),
    asserta(user:padre(x, y)),
    findall(P-H, padre(P, H), L).

test(olvidar, [ setup(guardar(E)), cleanup(restaurar(E)),
                true(L == [juan-ana]) ]) :-
    olvidar(pedro),
    findall(P-H, padre(P, H), L).

% La vista lógica: forall/2 recorre solo los números que había al empezar.
test(multiplicar_por_diez, [ setup(guardar(E)), cleanup(restaurar(E)),
                             true(L == [1, 2, 10, 20]) ]) :-
    multiplicar_por_diez,
    findall(N, numero(N), L).

% Las pruebas anteriores dejaron la base como estaba.
test(base_intacta, true(N == 5)) :-
    aggregate_all(count, edad(_, _), N).

:- end_tests(dinamica).
