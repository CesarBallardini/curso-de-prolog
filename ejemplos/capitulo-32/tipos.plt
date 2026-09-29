:- encoding(utf8).

:- begin_tests(tipos).

test(clase_compuesto, true(C == compuesto(f/2))) :-
    clase(f(a, _), C).

test(clase_variable, true(C == variable)) :-
    clase(_, C).

% [] es una constante propia, no un átomo, y una lista no vacía es un
% término compuesto con el functor '[|]'/2.
test(clase_listas, true(Cs == [lista_vacia, compuesto('[|]'/2)])) :-
    clase([], C1),
    clase([a], C2),
    Cs = [C1, C2].

test(clase_constantes, true(Cs == [entero, flotante, atomo, cadena])) :-
    clase(3, C1),
    clase(3.0, C2),
    clase(ana, C3),
    clase("ana", C4),
    Cs = [C1, C2, C3, C4].

% clase/2 no liga su primer argumento.
test(clase_no_liga, true(var(X))) :-
    clase(X, _).

% atom/1 no es una relación: el orden de los objetivos cambia la respuesta.
test(atom_despues, true(X == ana)) :-
    X = ana,
    atom(X).

% call/2 evita que el compilador descarte atom(X) por ser siempre falso.
test(atom_antes, [fail]) :-
    call(atom, X),
    X = ana.

test(ingenuo_error, [error(type_error(evaluable, desconocida/0))]) :-
    mayor_de_edad_ingenuo(desconocida).

test(ingenuo_libre, [error(instantiation_error)]) :-
    mayor_de_edad_ingenuo(_).

test(ingenuo_filtra, all(P == [ana, juan])) :-
    member(P-E, [ana-41, luis-12, juan-68]),
    mayor_de_edad_ingenuo(E).

test(clase_compuesto_cero, true(C == compuesto(f/0))) :-
    compound_name_arguments(T, f, []),
    clase(T, C).

test(mayor_de_edad_filtra, all(P == [ana, juan])) :-
    edad(P, E),
    mayor_de_edad(E).

% La consulta más general falla, aunque existen enteros mayores que 18.
test(mayor_de_edad_libre, [fail]) :-
    mayor_de_edad(_).

test(verificado, [true]) :-
    mayor_de_edad_verificado(41).

test(verificado_menor, [fail]) :-
    mayor_de_edad_verificado(12).

test(verificado_libre, [error(instantiation_error)]) :-
    mayor_de_edad_verificado(_).

test(verificado_tipo, [error(type_error(integer, desconocida))]) :-
    mayor_de_edad_verificado(desconocida).

test(restringido_libre, true(Min == 18)) :-
    mayor_de_edad_restringido(E),
    fd_inf(E, Min).

test(restringido_ligado_despues, true(E == 20)) :-
    mayor_de_edad_restringido(E),
    E = 20.

test(restringido_menor, [fail]) :-
    mayor_de_edad_restringido(12).

test(restringido_tipo,
     [error(domain_error(clpfd_expression, desconocida))]) :-
    mayor_de_edad_restringido(desconocida).

test(is_of_type_libre, [fail]) :-
    is_of_type(integer, _).

test(is_of_type_lista, [true]) :-
    is_of_type(list(atom), [a, b]).

:- end_tests(tipos).
