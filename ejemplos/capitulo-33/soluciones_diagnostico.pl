:- encoding(utf8).

% Capítulo 33 - Soluciones de los ejercicios 11 y 12: depuración
% algorítmica de un programa nuevo, con el oráculo escrito como programa o
% con las respuestas del usuario.
%
% invertir_mal/2 da una respuesta incorrecta. El intérprete y la búsqueda
% de la cláusula falsa son los de diagnostico.pl; el oráculo es ahora un
% argumento: programa, que usa pretendido/1, o usuario, que pregunta.
%
%?- invertir_mal([a, b, c], Ys).
%?- respuesta_incorrecta(programa, invertir_mal([a, b, c], Ys), C).

%!  invertir_mal(+Xs:list, -Ys:list) is det.
%
%   Debería ser: Ys tiene los elementos de Xs en el orden inverso.
invertir_mal(Xs, Ys) :-
    invertir_mal(Xs, [], Ys).

%!  invertir_mal(+Xs:list, +Acumulado:list, -Ys:list) is det.
%
%   Debería ser: Ys es Xs invertida delante de Acumulado. El error: la
%   segunda cláusula pierde el acumulado anterior.
invertir_mal([], Ys, Ys).
invertir_mal([X|Xs], _, Ys) :-
    invertir_mal(Xs, [X], Ys).

%!  pretendido(+Meta) is semidet.
%
%   Meta es verdadero en el significado que el programa debería tener.
pretendido(invertir_mal(Xs, Ys)) :-
    reverse(Xs, Ys).
pretendido(invertir_mal(Xs, Acumulado, Ys)) :-
    reverse(Xs, Rs),
    append(Rs, Acumulado, Ys).

:- dynamic juicio/2.

% juicio(Meta, Respuesta): el usuario ya dijo si Meta es correcto.

%!  correcto(+Oraculo, +Meta) is semidet.
%
%   Meta es verdadero según Oraculo: programa o usuario.
correcto(programa, Meta) :-
    pretendido(Meta).
correcto(usuario, Meta) :-
    preguntar_juicio(Meta).

%!  preguntar_juicio(+Meta) is semidet.
%
%   El usuario responde si a la pregunta de si Meta es correcto. Cada
%   pregunta se hace una sola vez.
preguntar_juicio(Meta) :-
    (   juicio(Pregunta, Respuesta),
        Pregunta =@= Meta
    ->  true
    ;   format("¿Es correcto ~q? ", [Meta]),
        read(Respuesta),
        assertz(juicio(Meta, Respuesta))
    ),
    Respuesta == si.

%!  clausula(+Meta, -Cuerpo) is nondet.
%
%   Meta :- Cuerpo es una cláusula del programa, con el cuerpo en la
%   representación limpia; el programa no usa predefinidos.
clausula(Meta, Cuerpo) :-
    clause(Meta, Cuerpo0),
    limpiar(Cuerpo0, Cuerpo).

%!  limpiar(+Cuerpo0, -Cuerpo) is det.
%
%   Cuerpo es el cuerpo Cuerpo0 con cada objetivo marcado.
limpiar(true, true) :-
    !.
limpiar((A0, B0), (A, B)) :-
    !,
    limpiar(A0, A),
    limpiar(B0, B).
limpiar(G, prog(G)).

%!  resolver(+Meta, -Arbol) is nondet.
%
%   Meta se prueba, y Arbol es la prueba, como en arbol.pl.
resolver(Meta, Arbol) :-
    phrase(pruebas(prog(Meta)), [Arbol]).

%!  pruebas(+Cuerpo)// is nondet.
%
%   Cuerpo se prueba, y la lista describe las pruebas de sus objetivos.
pruebas(true) -->
    [].
pruebas((A, B)) -->
    pruebas(A),
    pruebas(B).
pruebas(prog(G)) -->
    { clausula(G, Cuerpo),
      phrase(pruebas(Cuerpo), Hijos) },
    [prueba(G, Hijos)].

%!  respuesta_incorrecta(+Oraculo, +Meta, -Clausula) is nondet.
%
%   Meta se prueba con una respuesta que Oraculo rechaza, y Clausula es una
%   instancia falsa de una cláusula del programa.
respuesta_incorrecta(Oraculo, Meta, Clausula) :-
    resolver(Meta, Arbol),
    \+ correcto(Oraculo, Meta),
    clausula_falsa(Oraculo, Arbol, Clausula).

%!  clausula_falsa(+Oraculo, +Arbol, -Clausula) is det.
%
%   La raíz de Arbol es falsa según Oraculo. Si algún hijo también lo es,
%   la cláusula falsa está debajo de él; si no, es la de la raíz.
clausula_falsa(Oraculo, prueba(G, Hijos), Clausula) :-
    (   member(prueba(H, Nietos), Hijos),
        \+ correcto(Oraculo, H)
    ->  clausula_falsa(Oraculo, prueba(H, Nietos), Clausula)
    ;   maplist([prueba(M, _), M]>>true, Hijos, Objetivos),
        conjuncion(Objetivos, Cuerpo),
        Clausula = (G :- Cuerpo)
    ).

%!  conjuncion(+Objetivos:list, -Cuerpo) is det.
%
%   Cuerpo es la conjunción de Objetivos; true si no hay ninguno.
conjuncion([], true).
conjuncion([G], G) :-
    !.
conjuncion([G|Gs], (G, Cuerpo)) :-
    conjuncion(Gs, Cuerpo).
