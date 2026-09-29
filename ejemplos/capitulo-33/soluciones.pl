:- encoding(utf8).

% Capítulo 33 - Soluciones de los ejercicios 2, 4 y 6 a 10.
%
% El programa objeto reúne los de las secciones: la familia, las edades,
% maximo/3, el grafo con ciclos y dos predicados con disyunción y
% condicional. El intérprete es el de limpio.pl, con la disyunción, el
% condicional y la negación del ejercicio 4; los demás ejercicios lo
% extienden sin cambiar el programa.
%
%?- reglas(antepasado/2, N).
%?- resolver(signo(-3, S)).
%?- limit(2, resolver_anchura(camino(a, c, C))).
%?- resolver_acotado(camino(a, d, C), 3, R).

% padre(P, H): P es el padre de H.
padre(juan, ana).
padre(juan, pedro).
padre(ana, luis).
padre(luis, eva).

% edad(P, E): P tiene E años.
edad(juan, 68).
edad(ana, 41).
edad(pedro, 37).

%!  abuelo(?A, ?N) is nondet.
%
%   A es abuelo de N.
abuelo(A, N) :-
    padre(A, P),
    padre(P, N).

%!  antepasado(?A, ?D) is nondet.
%
%   A es un antepasado de D: su padre, o un antepasado de su padre.
antepasado(A, D) :-
    padre(A, D).
antepasado(A, D) :-
    padre(A, H),
    antepasado(H, D).

%!  antepasado_izq(?A, ?D) is nondet.
%
%   A es un antepasado de D, con la recursión a la izquierda.
antepasado_izq(A, D) :-
    padre(A, D).
antepasado_izq(A, D) :-
    antepasado_izq(A, H),
    padre(H, D).

:- dynamic visita/1.

% visita(P): P visitó la casa; el programa agrega y quita estos hechos.
visita(ana).

%!  maximo(+X:number, +Y:number, -M:number) is det.
%
%   M es el mayor de X e Y, con un corte rojo.
maximo(X, Y, X) :-
    X >= Y,
    !.
maximo(_, Y, Y).

%!  signo(+X:number, -S) is det.
%
%   S es positivo, negativo o cero según el signo de X.
signo(X, S) :-
    (   X > 0
    ->  S = positivo
    ;   X < 0
    ->  S = negativo
    ;   S = cero
    ).

%!  pariente_directo(?A, ?B) is nondet.
%
%   A es el padre o el hijo de B.
pariente_directo(A, B) :-
    (   padre(A, B)
    ;   padre(B, A)
    ).

% arista(X, Y): hay una arista de X a Y; el grafo tiene ciclos.
arista(a, b).
arista(b, a).
arista(b, c).
arista(c, b).
arista(c, d).
arista(d, c).

%!  camino(?X, ?Z, ?Aristas:list) is nondet.
%
%   Aristas es un camino de X a Z, como lista de pares Desde-Hasta.
camino(X, X, []).
camino(X, Z, [X-Y|Aristas]) :-
    arista(X, Y),
    camino(Y, Z, Aristas).

% predefinido(G): el intérprete ejecuta G con ejecutar/1.
predefinido(_ = _).
predefinido(_ is _).
predefinido(_ < _).
predefinido(_ > _).
predefinido(_ =< _).
predefinido(_ >= _).
predefinido(!).

%!  ejecutar(+G) is semidet.
%
%   Ejecuta el objetivo predefinido G. El corte se ejecuta como true.
ejecutar(X = Y) :-
    X = Y.
ejecutar(X is E) :-
    X is E.
ejecutar(X < Y) :-
    X < Y.
ejecutar(X > Y) :-
    X > Y.
ejecutar(X =< Y) :-
    X =< Y.
ejecutar(X >= Y) :-
    X >= Y.
ejecutar(!).

%!  reglas(+Indicador, -N:integer) is semidet.
%
%   N es la cantidad de cláusulas del predicado Nombre/Aridad que son
%   reglas: su cuerpo no es true. Falla si el predicado no está definido.
reglas(Nombre/Aridad, N) :-
    current_predicate(Nombre/Aridad),
    functor(Cabeza, Nombre, Aridad),
    aggregate_all(count,
                  ( clause(Cabeza, Cuerpo),
                    Cuerpo \== true ),
                  N).

%!  clausula(+Meta, -Cuerpo) is nondet.
%
%   Meta :- Cuerpo es una cláusula del programa, con el cuerpo en la
%   representación limpia.
clausula(Meta, Cuerpo) :-
    clause(Meta, Cuerpo0),
    limpiar(Cuerpo0, Cuerpo).

%!  limpiar(+Cuerpo0, -Cuerpo) is det.
%
%   Cuerpo es el cuerpo Cuerpo0 con cada objetivo marcado: true, (A, B),
%   si(C, T, E) para (C -> T ; E), o(A, B) para (A ; B), no(C) para \+ C,
%   sis(G) o prog(G).
limpiar(true, true) :-
    !.
limpiar((A0, B0), (A, B)) :-
    !,
    limpiar(A0, A),
    limpiar(B0, B).
limpiar((C0 -> T0 ; E0), si(C, T, E)) :-
    !,
    limpiar(C0, C),
    limpiar(T0, T),
    limpiar(E0, E).
limpiar((A0 ; B0), o(A, B)) :-
    !,
    limpiar(A0, A),
    limpiar(B0, B).
limpiar(\+ G0, no(G)) :-
    !,
    limpiar(G0, G).
limpiar(G, sis(G)) :-
    predefinido(G),
    !.
limpiar(G, prog(G)).

%!  resolver(+Meta) is nondet.
%
%   Meta, un objetivo del programa, se prueba con sus cláusulas.
resolver(Meta) :-
    resolver_cuerpo(prog(Meta)).

%!  resolver_cuerpo(+Cuerpo) is nondet.
%
%   Cuerpo se prueba. La disyunción, el condicional y la negación se
%   prueban con las construcciones de Prolog que les corresponden.
resolver_cuerpo(true).
resolver_cuerpo((A, B)) :-
    resolver_cuerpo(A),
    resolver_cuerpo(B).
resolver_cuerpo(si(C, T, E)) :-
    (   resolver_cuerpo(C)
    ->  resolver_cuerpo(T)
    ;   resolver_cuerpo(E)
    ).
resolver_cuerpo(o(A, B)) :-
    (   resolver_cuerpo(A)
    ;   resolver_cuerpo(B)
    ).
resolver_cuerpo(no(C)) :-
    \+ resolver_cuerpo(C).
resolver_cuerpo(sis(G)) :-
    ejecutar(G).
resolver_cuerpo(prog(G)) :-
    clausula(G, Cuerpo),
    resolver_cuerpo(Cuerpo).

%!  resolver_anchura(+Meta) is nondet.
%
%   Meta se prueba en anchura: las resolventes forman una cola, y se
%   expande siempre la más antigua. Las respuestas salen en orden de
%   cantidad de pasos; ninguna rama infinita impide llegar a las demás.
resolver_anchura(Meta) :-
    anchura([Meta-[prog(Meta)]], Meta).

%!  anchura(+Cola:list, ?Meta) is nondet.
%
%   Cola tiene pares Respuesta-Resolvente. Una resolvente vacía da su
%   Respuesta; una que no lo está se reemplaza, al final de la cola, por
%   las resolventes que resultan de su primer objetivo.
anchura([Respuesta-[]|Cola], Meta) :-
    (   Meta = Respuesta
    ;   anchura(Cola, Meta)
    ).
anchura([Respuesta-[G|Gs]|Cola], Meta) :-
    findall(Respuesta-Nueva, paso(G, Gs, Nueva), Hijas),
    append(Cola, Hijas, Cola1),
    anchura(Cola1, Meta).

%!  paso(+G, +Gs:list, -Resolvente:list) is nondet.
%
%   Resolvente resulta de resolver el objetivo G delante de Gs: una por
%   cada manera de hacerlo.
paso(true, Gs, Gs).
paso((A, B), Gs, [A, B|Gs]).
paso(si(C, T, E), Gs, [Rama|Gs]) :-
    (   resolver_cuerpo(C)
    ->  Rama = T
    ;   Rama = E
    ).
paso(o(A, _), Gs, [A|Gs]).
paso(o(_, B), Gs, [B|Gs]).
paso(no(C), Gs, Gs) :-
    \+ resolver_cuerpo(C).
paso(sis(G), Gs, Gs) :-
    ejecutar(G).
paso(prog(G), Gs, [Cuerpo|Gs]) :-
    clausula(G, Cuerpo).

%!  resolver_arbol(+Meta, -Arbol) is nondet.
%
%   Meta se prueba, y Arbol es la prueba, como en arbol.pl.
resolver_arbol(Meta, Arbol) :-
    phrase(pruebas(prog(Meta)), [Arbol]).

%!  pruebas(+Cuerpo)// is nondet.
%
%   Cuerpo se prueba, y la lista describe las pruebas de sus objetivos.
pruebas(true) -->
    [].
pruebas((A, B)) -->
    pruebas(A),
    pruebas(B).
pruebas(sis(G)) -->
    { ejecutar(G) },
    [sis(G)].
pruebas(prog(G)) -->
    { clausula(G, Cuerpo),
      phrase(pruebas(Cuerpo), Hijos) },
    [prueba(G, Hijos)].

%!  hechos_usados(+Arbol, -Hechos:list) is det.
%
%   Hechos son los hechos del programa que usa la prueba Arbol, en el orden
%   de izquierda a derecha, con repetidos.
hechos_usados(Arbol, Hechos) :-
    phrase(hechos(Arbol), Hechos).

%!  hechos(+Arbol)// is det.
%
%   La lista describe los hechos que usa Arbol.
hechos(sis(_)) -->
    [].
hechos(prueba(G, Hijos)) -->
    hechos_nodo(Hijos, G).

%!  hechos_nodo(+Hijos:list, +G)// is det.
%
%   La lista describe los hechos de un nodo G con esos Hijos: G mismo si no
%   tiene hijos, porque es un hecho, o los hechos de sus hijos.
hechos_nodo([], G) -->
    [G].
hechos_nodo([H|Hs], _) -->
    hechos(H),
    hechos_de(Hs).

%!  hechos_de(+Arboles:list)// is det.
%
%   La lista describe los hechos que usan los Arboles, en orden.
hechos_de([]) -->
    [].
hechos_de([A|As]) -->
    hechos(A),
    hechos_de(As).

%!  resolver_acotado(+Meta, +Limite:integer, -Resultado) is nondet.
%
%   Resultado es si para cada prueba de Meta de altura no mayor que Limite,
%   con sus ligaduras; al final, una respuesta agotado, sin ligaduras, si
%   alguna rama llegó al límite. Sin prueba y sin llegar al límite, falla.
resolver_acotado(Meta, Limite, Resultado) :-
    (   limite(prog(Meta), Limite),
        Resultado = si
    ;   \+ \+ alcanza(prog(Meta), Limite),
        Resultado = agotado
    ).

%!  limite(+Cuerpo, +N:integer) is nondet.
%
%   Cuerpo se prueba sin usar cláusulas a más de N niveles.
limite(true, _).
limite((A, B), N) :-
    limite(A, N),
    limite(B, N).
limite(sis(G), _) :-
    ejecutar(G).
limite(prog(G), N) :-
    N > 0,
    N1 is N - 1,
    clausula(G, Cuerpo),
    limite(Cuerpo, N1).

%!  alcanza(+Cuerpo, +N:integer) is nondet.
%
%   Alguna rama de la búsqueda de Cuerpo llega a un objetivo del programa
%   sin niveles disponibles: la búsqueda con límite N lo cortó.
alcanza((A, B), N) :-
    (   alcanza(A, N)
    ;   limite(A, N),
        alcanza(B, N)
    ).
alcanza(prog(_), 0).
alcanza(prog(G), N) :-
    N > 0,
    N1 is N - 1,
    clausula(G, Cuerpo),
    alcanza(Cuerpo, N1).

%!  resolver_sin_ciclos(+Meta) is nondet.
%
%   Meta se prueba, sin usar cláusulas para un objetivo que es una variante
%   de uno de sus antepasados en la prueba: esa rama se abandona.
resolver_sin_ciclos(Meta) :-
    sin_ciclos(prog(Meta), []).

%!  sin_ciclos(+Cuerpo, +Antepasados:list) is nondet.
%
%   Cuerpo se prueba; Antepasados son los objetivos en curso.
sin_ciclos(true, _).
sin_ciclos((A, B), Antepasados) :-
    sin_ciclos(A, Antepasados),
    sin_ciclos(B, Antepasados).
sin_ciclos(sis(G), _) :-
    ejecutar(G).
sin_ciclos(prog(G), Antepasados) :-
    \+ ( member(A, Antepasados),
         A =@= G ),
    clausula(G, Cuerpo),
    sin_ciclos(Cuerpo, [G|Antepasados]).

%!  rastrear_entradas(+Meta) is nondet.
%
%   Meta se prueba, y se escribe cada llamada y cada salida, con dos
%   columnas de sangría por nivel.
rastrear_entradas(Meta) :-
    entradas(prog(Meta), 0).

%!  entradas(+Cuerpo, +Sangria:integer) is nondet.
%
%   Cuerpo se prueba, y sus objetivos se escriben en la columna Sangria.
entradas(true, _).
entradas((A, B), Sangria) :-
    entradas(A, Sangria),
    entradas(B, Sangria).
entradas(sis(G), Sangria) :-
    escribir_puerto(llama, G, Sangria),
    ejecutar(G),
    escribir_puerto(sale, G, Sangria).
entradas(prog(G), Sangria) :-
    escribir_puerto(llama, G, Sangria),
    Siguiente is Sangria + 2,
    clausula(G, Cuerpo),
    entradas(Cuerpo, Siguiente),
    escribir_puerto(sale, G, Sangria).

%!  escribir_puerto(+Puerto, +G, +Sangria:integer) is det.
%
%   Escribe Puerto y G en la columna Sangria, con las variables nombradas.
escribir_puerto(Puerto, G, Sangria) :-
    \+ \+ ( numbervars(G, 0, _),
            format("~t~*|~w ~W~n",
                   [Sangria, Puerto, G, [numbervars(true), quoted(true),
                                         spacing(next_argument)]]) ).
