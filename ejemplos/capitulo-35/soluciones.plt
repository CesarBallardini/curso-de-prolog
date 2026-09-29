:- encoding(utf8).

:- begin_tests(soluciones).

% Ejercicio 3
test(tabla, true(Ps == [chile-santiago, peru-lima])) :-
    findall(P-C, capital(P, C), Ps).

test(sin_tabla, [fail]) :-
    current_predicate(tabla/2).

% Una tabla sin pares no deja ningún hecho.
test(tabla_vacia, true(C == [])) :-
    expand_term(tabla(capital, []), C).

% Ejercicio 4: las dos expansiones terminan, y se aplican una vez.
test(saludar_expandido,
     true(Cuerpo == (escribir_texto(texto(hola)), anotar(texto(hola))))) :-
    clause(saludar, Cuerpo).

test(saludar, true(S == "texto(hola)\ntexto(hola)\n")) :-
    with_output_to(string(S), saludar).

test(anotar_texto, true(G == anotar(texto(a)))) :-
    expand_goal(anotar(texto(a)), G).

test(escribir_expandido, true(G == escribir_texto(texto(a)))) :-
    expand_goal(escribir(a), G).

% Ejercicios 5 y 6: la traducción es la del sistema.
test(como_el_sistema, forall(regla(R))) :-
    traducir(R, C1),
    dcg_translate_rule(R, C2),
    assertion(C1 =@= C2).

% Ejercicio 7
test(ultimo,
     true(Cs =@= [ (ultimo(X, [X]) :- []),
                   (ultimo(Y, [_|Zs]) :- [ultimo(Y, Zs)]) ])) :-
    derivar_ultimo(Cs).

test(ultimo_como_append, true(R1 == R2)) :-
    findall(X, ultimo(X, [a, b, c]), R1),
    findall(X, append(_, [X], [a, b, c]), R2).

test(ultimo_vacia, [fail]) :-
    ultimo(_, []).

% Ejercicio 8
test(suma_largo,
     true(Cs =@= [ (suma_largo([], 0, 0) :- []),
                   (suma_largo([X|Xs], S, N) :-
                        [suma_largo(Xs, S0, N0), S is S0 + X,
                         N is N0 + 1]) ])) :-
    derivar_suma_largo(Cs).

test(reordenar, true(C == (p :- [c, a, b]))) :-
    reordenar((p :- [a, b, c]), [3, 1, 2], C).

test(suma_y_largo, true(S-N == 6-3)) :-
    suma([1, 2, 3], S),
    largo([a, b, c], N).

test(suma_largo_vacia, true(S-N == 0-0)) :-
    suma_largo([], S, N).

test(una_pasada, true(S-N == 5050-100)) :-
    numlist(1, 100, L),
    suma_largo(L, S, N).

test(como_dos_pasadas, true(R1 == R2)) :-
    numlist(1, 100, L),
    suma_largo(L, S1, N1),
    suma_largo_dos(L, S2, N2),
    R1 = S1-N1,
    R2 = S2-N2.

test(menos_inferencias, true(I1 < I2)) :-
    numlist(1, 1000, L),
    inferencias(suma_largo(L, _, _), I1),
    inferencias(suma_largo_dos(L, _, _), I2).

% Ejercicio 15: el despliegue da el hecho de rotar_dif/2.
test(derivar_rotar, true(Cs =@= [(rotar_dif([A|B]-[A|C], B-C) :- [])])) :-
    derivar_rotar(Cs).

test(mostrar, true(S == "rotar_dif([A|B]-[A|C], B-C):-[]\n")) :-
    derivar_rotar(Cs),
    with_output_to(string(S), mostrar(Cs)).

% Con el final cerrado, [A|C] no unifica con [].
test(rotar_cerrada, [fail]) :-
    rotar_dif([a, b]-[], _).

test(rotar_dos_veces, true(L == [3, 1, 2])) :-
    rotar_dif([1, 2, 3|Q]-Q, R1),
    rotar_dif(R1, R2),
    R2 = L-[].

:- end_tests(soluciones).

% regla(R): una regla de gramática con cadenas o pushback.
regla((saludo --> "hola")).
regla((siguiente(C), [C] --> [C])).
regla((a, [x] --> b, c)).
regla((a --> [x], "yz", b)).

%!  inferencias(:G, -N:integer) is det.
%
%   N es la cantidad de inferencias de una ejecución de G.
inferencias(G, N) :-
    statistics(inferences, I0),
    once(G),
    statistics(inferences, I1),
    N is I1 - I0.
