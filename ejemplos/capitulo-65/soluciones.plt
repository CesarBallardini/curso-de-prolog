:- encoding(utf8).

:- begin_tests(soluciones).

test(hans, [true(R-S == presumiblemente_si-presumiblemente_no)]) :-
    respuesta([especificidad], nacio_en(hans, eeuu), R),
    respuesta([especificidad], neg nacio_en(hans, eeuu), S).

test(ines, [true(R == presumiblemente_no)]) :-
    respuesta([especificidad], se_mantiene(ines), R).

test(sospechosas, [true(A-B-C == [bateria, arranque, combustible]-
                                  [arranque, combustible]-[])]) :-
    sospechosas(auto2, A),
    sospechosas(auto3, B),
    sospechosas(auto1, C).

test(escribir, [true(Lineas == 4)]) :-
    once(derivacion([especificidad], arranca(auto1), A)),
    with_output_to(string(S), escribir_derivacion(A)),
    split_string(S, "\n", "", Partes),
    exclude(==(""), Partes, Llenas),
    length(Llenas, Lineas).

test(tnot, [true(V-N-R == false-true-true)]) :-
    ( vuela_t(dracula) -> V = true ; V = false ),
    ( no_vuela_t(dracula) -> N = true ; N = false ),
    ( vuela_t(rufo) -> R = true ; R = false ).

test(flach_dracula, [true(Es == [[mamiferos_no_vuelan(dracula)],
                                 [muertos_no_vuelan(dracula)]])]) :-
    findall(E, explicar_por_defecto(no(vuela(dracula)), E), Es).

test(flach_ambas, [true(A-B == [[murcielagos_vuelan(rufo)]]-
                              [[mamiferos_no_vuelan(rufo)]])]) :-
    findall(E, explicar_por_defecto(vuela(rufo), E), A),
    findall(E, explicar_por_defecto(no(vuela(rufo)), E), B).

test(dialecto, [true(Xs == [hans])]) :-
    findall(X, habla_dialecto_aleman(X), Xs).

% literal/2 recorre la conjunción de izquierda a derecha.
test(literal, [true(Ls == [a, b, c])]) :-
    findall(L, literal(L, (a, (b, c))), Ls).

test(probar_f, [true(Xs == [dracula, rufo])]) :-
    findall(X, probar_f(mamifero(X)), Xs).

% Las reglas de este ejercicio no tienen cabezas no(...): ningún supuesto
% las contradice.
test(contradice, [fail]) :-
    contradice(vuela(dracula)).

test(explicar_f, [nondet, true(S == [murcielagos_vuelan(rufo), previo])]) :-
    explicar_f(vuela(rufo), [previo], S).

:- end_tests(soluciones).
