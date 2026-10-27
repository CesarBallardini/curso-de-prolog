:- encoding(utf8).

:- begin_tests(libros).

% Ejercicio 10
test(edicion_en_espanol, all(T-A == ["The Unified Software Development Process"-2000])) :-
    edicion_impresa(T, "español", A).

% La primera edición de Logic for Problem Solving no está impresa.
test(edicion_no_impresa, [fail]) :-
    edicion_impresa("Logic for Problem Solving", _, 1983).

test(ediciones_impresas_en_ingles, all(T-A == ["The Art of Prolog"-1994,
                                              "Logic for Problem Solving"-2014,
                                              "The Unified Software Development Process"-2000])) :-
    edicion_impresa(T, "inglés", A).

test(autores_de_un_libro, all(C == [2])) :-
    cantidad_autores("The Art of Prolog", C).

test(autores_de_todos, all(T-C == ["The Art of Prolog"-2,
                                   "The Unified Software Development Process"-3,
                                   "Logic for Problem Solving"-1])) :-
    cantidad_autores(T, C).

test(autores_libro_ajeno, [fail]) :-
    cantidad_autores("Programming in Prolog", _).

test(lista_editoriales, all(L == [["The MIT Press", "Addison-Wesley", "Prentice Hall"]])) :-
    lista_editoriales(L).

% Ejercicio 11
test(el_mas_caro, all(T == ["The Art of Prolog"])) :-
    precio_maximo(T).

test(no_es_el_mas_caro, [fail]) :-
    precio_maximo("Logic for Problem Solving").

:- end_tests(libros).
