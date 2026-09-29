:- encoding(utf8).

:- begin_tests(profundidad).

test(limite, all(C == [[a-b, b-c]])) :-
    resolver_limite(camino(a, c, C), 4).

% Con un límite corto, false. no dice que no haya camino.
test(limite_corto, [fail]) :-
    resolver_limite(camino(a, d, _), 3).

test(limite_cero, [fail]) :-
    resolver_limite(camino(a, a, _), 0).

test(limite_hecho, all(C == [[]])) :-
    resolver_limite(camino(a, a, C), 1).

% Sin límite, Prolog no encuentra el camino: el ciclo a-b-a no termina.
test(prolog_no_termina, [error(resource_error(_))]) :-
    call_with_stack_limit(camino(a, c, _)).

test(ingenuo_repite,
     all(C == [[a-b, b-c], [a-b, b-c], [a-b, b-a, a-b, b-c], [a-b, b-c]])) :-
    limit(4, resolver_iterativo_ingenuo(camino(a, c, C))).

test(iterativo,
     all(C == [[a-b, b-c], [a-b, b-a, a-b, b-c], [a-b, b-c, c-b, b-c]])) :-
    limit(3, resolver_iterativo(camino(a, c, C))).

% Las pruebas salen en orden de altura: el camino más corto primero.
test(iterativo_mas_corto, true(C == [a-b, b-c, c-d, d-e, e-f])) :-
    once(resolver_iterativo(camino(a, f, C))).

% Sin repetidos: las primeras diez respuestas son distintas.
test(iterativo_sin_repetidos, true(N == 10)) :-
    findall(C, limit(10, resolver_iterativo(camino(a, c, C))), Cs),
    sort(Cs, Distintos),
    length(Distintos, N).

test(altura, all(H == [3])) :-
    altura(prog(camino(a, c, [a-b, b-c])), 10, H).

:- end_tests(profundidad).

%!  call_with_stack_limit(:G) is det.
%
%   Ejecuta G con una pila de 64 MB, para que una recursión sin fin termine
%   pronto con un error de recursos.
call_with_stack_limit(G) :-
    current_prolog_flag(stack_limit, Antes),
    setup_call_cleanup(set_prolog_flag(stack_limit, 64 000 000),
                       G,
                       set_prolog_flag(stack_limit, Antes)).
