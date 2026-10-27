:- encoding(utf8).

% Capítulo 12 - Ejercicios 10 y 11: una base de datos de libros.
%
% Los libros, sus ediciones y las ediciones impresas. Las consultas combinan
% las tres relaciones, la lista de editoriales se arma con la estrategia
% para recolectar soluciones, y el libro más caro se obtiene por negación.
%
%?- edicion_impresa(T, "español", A).
%?- lista_editoriales(L).
%?- precio_maximo(T).

% libro(T, E, A): el libro de título T es de la editorial E y sus autores son
% los de la lista A.
libro(titulo("The Art of Prolog"), editorial("The MIT Press"), autor([sterling, shapiro])).
libro(titulo("The Unified Software Development Process"), editorial("Addison-Wesley"), autor([jacobson, booch, rumbaugh])).
libro(titulo("Logic for Problem Solving"), editorial("Prentice Hall"), autor([kowalski])).

% edicion(T, N, I, Id): la edición número N del libro de título T tiene el
% ISBN I y está en el idioma Id.
edicion(titulo("Logic for Problem Solving"), numero(1), isbn(978-0444003683), idioma("inglés")).
edicion(titulo("The Art of Prolog"), numero(2), isbn(978-0262193382), idioma("inglés")).
edicion(titulo("Logic for Problem Solving"), numero(2), isbn(978-3837036299), idioma("inglés")).
edicion(titulo("The Unified Software Development Process"), numero(1), isbn(978-8478290369), idioma("español")).
edicion(titulo("The Art of Prolog"), numero(1), isbn(978-2225819483), idioma("francés")).
edicion(titulo("The Unified Software Development Process"), numero(1), isbn(978-0201571691), idioma("inglés")).

% impreso(I, P, Pr, A): la edición de ISBN I está impresa, con P páginas,
% precio Pr y año A.
impreso(isbn(978-0262193382), pag(560), precio(65), anio(1994)).
impreso(isbn(978-0201571691), pag(472), precio(56), anio(2000)).
impreso(isbn(978-3837036299), pag(346), precio(64), anio(2014)).
impreso(isbn(978-2225819483), pag(505), precio(30), anio(1997)).
impreso(isbn(978-8478290369), pag(472), precio(25), anio(2000)).

% --- Ejercicio 10 ----------------------------------------------------------

%!  edicion_impresa(?T, ?Id, ?A) is nondet.
%
%   El libro de título T tiene una edición impresa en el idioma Id en el año
%   A.
edicion_impresa(T, Id, A) :-
    edicion(titulo(T), numero(_), isbn(I), idioma(Id)),
    impreso(isbn(I), pag(_), precio(_), anio(A)).

%!  cantidad_autores(?T, ?C) is nondet.
%
%   C es la cantidad de autores del libro de título T.
cantidad_autores(T, C) :-
    libro(titulo(T), editorial(_), autor(As)),
    length(As, C).

%!  lista_editoriales(-L) is det.
%
%   L es la lista de todas las editoriales, sin repetidas, en el orden de los
%   hechos. L debe llegar libre.
lista_editoriales(L) :-
    armar_lista_editoriales(L, []).

%!  armar_lista_editoriales(-L, +YaIncluidas) is det.
%
%   L es la lista de las editoriales que no están en YaIncluidas.
armar_lista_editoriales([E|L], YaIncluidas) :-
    libro(titulo(_), editorial(E), autor(_)),
    \+ member(E, YaIncluidas),
    !,
    append(YaIncluidas, [E], YaIncluidasConE),
    armar_lista_editoriales(L, YaIncluidasConE).
armar_lista_editoriales([], _).

% --- Ejercicio 11 ----------------------------------------------------------

%!  precio_maximo(?T) is nondet.
%
%   El libro de título T tiene la edición impresa de mayor precio: ninguna
%   edición impresa tiene un precio mayor.
precio_maximo(T) :-
    edicion(titulo(T), _, isbn(I), _),
    impreso(isbn(I), _, precio(P), _),
    \+ ( impreso(_, _, precio(Otro), _),
         Otro > P ).
