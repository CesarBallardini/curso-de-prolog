:- encoding(utf8).

:- begin_tests(variantes).

test(resolver_como_prolog, true(Rs == Ps)) :-
    findall(A-D, resolver(antepasado(A, D)), Rs),
    findall(A-D, antepasado(A, D), Ps).

% De derecha a izquierda, la recursión a la izquierda termina.
test(der_izquierda, all(A == [luis, ana, juan])) :-
    resolver_der(antepasado_izq(A, eva)).

test(der_verifica, [nondet]) :-
    resolver_der(antepasado_izq(juan, eva)).

test(der_sin_prueba, [fail]) :-
    resolver_der(antepasado_izq(eva, juan)).

% La misma estrategia no termina con la recursión a la derecha: después de
% la última respuesta, la búsqueda sigue sin fin.
test(der_derecha_no_termina,
     [error(resource_error(_))]) :-
    call_with_stack_limit(
        findall(A, resolver_der(antepasado(A, eva)), _)).

test(lista, all(D == [ana, pedro, luis, eva])) :-
    resolver_lista([antepasado(juan, D)]).

test(lista_como_resolver, true(Rs == Ps)) :-
    findall(A-D, resolver_lista([antepasado(A, D)]), Rs),
    findall(A-D, resolver(antepasado(A, D)), Ps).

test(lista_conjuncion, all(A-B == [juan-luis])) :-
    resolver_lista([padre(A, H), padre(H, B), padre(B, eva)]).

test(negacion, all(P == [pedro, eva])) :-
    resolver(sin_hijos(P)).

test(negacion_lista, all(P == [pedro, eva])) :-
    resolver_lista([sin_hijos(P)]).

test(negacion_der, [fail]) :-
    resolver_der(sin_hijos(juan)).

test(pasos, all(N == [6])) :-
    resolver_pasos(antepasado(juan, eva), N).

test(pasos_hecho, all(N == [1])) :-
    resolver_pasos(padre(juan, ana), N).

% La negación no suma los pasos de su prueba fallida.
test(pasos_negacion, all(N == [2])) :-
    resolver_pasos(sin_hijos(eva), N).

:- end_tests(variantes).

%!  call_with_stack_limit(:G) is det.
%
%   Ejecuta G con una pila de 64 MB, para que una recursión sin fin termine
%   pronto con un error de recursos.
call_with_stack_limit(G) :-
    current_prolog_flag(stack_limit, Antes),
    setup_call_cleanup(set_prolog_flag(stack_limit, 64 000 000),
                       G,
                       set_prolog_flag(stack_limit, Antes)).
