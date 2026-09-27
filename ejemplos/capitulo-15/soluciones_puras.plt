:- encoding(utf8).

:- begin_tests(soluciones_puras).

test(sin_repetidos_ligado, true(R == [a, b, c])) :-
    sin_repetidos_puro([a, b, a, c, b], R).

% Con un elemento libre, los dos casos: que X sea a, y que sea distinto.
test(sin_repetidos_con_un_elemento_libre, all(X-R == [a-[a], z-[a, z]])) :-
    sin_repetidos_puro([a, X], R),
    ( var(X) -> X = z ; true ).

test(categoria_pura_de_sofia, all(C == [bebe])) :-
    categoria_pura(sofia, C).

test(categoria_pura_de_luis, all(C == [chico])) :-
    categoria_pura(luis, C).

:- end_tests(soluciones_puras).
