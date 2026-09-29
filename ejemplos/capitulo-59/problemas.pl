:- encoding(utf8).

% Capítulo 59 - Versión 2: lo que el grafo de llamadas dice del programa.
%
% grafo/2 arma el grafo de llamadas con library(ugraphs): los vértices son
% los predicados del programa y los que llama sin definirlos, salvo los
% predefinidos. Sobre ese grafo, indefinidos_de/2 da los predicados que se
% llaman y nadie define; no_usados_de/3, los que no se alcanzan desde los
% puntos de entrada; recursivos_de/2, los que se llaman a sí mismos,
% directa o indirectamente; y componentes_de/2, los grupos de predicados
% mutuamente recursivos. arbol/3 da el árbol de llamadas desde un
% predicado, con un número por predicado y una referencia a ese número
% cuando se repite. Cada análisis tiene también la forma que recibe el
% nombre del programa; raices/2 da los puntos de entrada de cada uno.
%
% solo-local: carga llamadas.pl.
%
%?- indefinidos(notas, Ps).
%?- no_usados(notas, Ps).
%?- componentes(notas, Grupos).
%?- escribir_arbol(notas, informe/0).

:- ensure_loaded(llamadas).
:- use_module(library(ugraphs)).
:- use_module(library(assoc)).
:- use_module(library(ordsets)).

:- multifile raices/2.

%!  raices(+Programa, -Raices:list) is semidet.
%
%   Raices son los puntos de entrada del programa llamado Programa: los
%   predicados desde los que se lo usa. Falla si no hay un programa con ese
%   nombre. El de notas se usa desde informe/0.
raices(notas, [informe/0]).

%!  propio(+Ds:list, +Q) is semidet.
%
%   Q es un predicado del programa: está entre sus definidos Ds, o no es
%   predefinido y el programa debería definirlo. Un predicado que el
%   programa define es suyo aunque el sistema tenga otro con ese nombre.
propio(Ds, Q) :-
    (   ord_memberchk(Q, Ds)
    ->  true
    ;   \+ predefinido(Q)
    ).

%!  grafo(+Clausulas:list, -Grafo) is det.
%
%   Grafo es el grafo de llamadas de Clausulas en la representación de
%   library(ugraphs), sin los predicados predefinidos.
grafo(Clausulas, Grafo) :-
    definidos(Clausulas, Ds),
    arcos(Clausulas, Arcos0),
    include(arco_propio(Ds), Arcos0, Arcos),
    vertices_edges_to_ugraph(Ds, Arcos, Grafo).

%!  arco_propio(+Ds:list, +Arco) is semidet.
%
%   El arco P-Q llega a un predicado Q del programa.
arco_propio(Ds, _-Q) :-
    propio(Ds, Q).

%!  indefinidos_de(+Clausulas:list, -Ps:list) is det.
%
%   Ps son los predicados que Clausulas llama y no define, sin contar los
%   predefinidos.
indefinidos_de(Clausulas, Ps) :-
    grafo(Clausulas, Grafo),
    vertices(Grafo, Vs),
    definidos(Clausulas, Ds),
    ord_subtract(Vs, Ds, Ps).

%!  alcanzables(+Clausulas:list, +Raices:list, -Ps:list) is det.
%
%   Ps son los predicados que se alcanzan desde alguno de Raices en el
%   grafo de llamadas, incluidos los de Raices.
alcanzables(Clausulas, Raices, Ps) :-
    grafo(Clausulas, Grafo),
    findall(P, ( member(R, Raices),
                 reachable(R, Grafo, Rs),
                 member(P, Rs) ),
            Ps0),
    sort(Ps0, Ps).

%!  no_usados_de(+Clausulas:list, +Raices:list, -Ps:list) is det.
%
%   Ps son los predicados definidos en Clausulas que no se alcanzan desde
%   ninguno de los puntos de entrada Raices.
no_usados_de(Clausulas, Raices, Ps) :-
    definidos(Clausulas, Ds),
    alcanzables(Clausulas, Raices, As),
    ord_subtract(Ds, As, Ps).

%!  recursivos_de(+Clausulas:list, -Ps:list) is det.
%
%   Ps son los predicados que, directa o indirectamente, se llaman a sí
%   mismos: los que aparecen entre sus propios sucesores en la clausura
%   transitiva del grafo.
recursivos_de(Clausulas, Ps) :-
    grafo(Clausulas, Grafo),
    transitive_closure(Grafo, Clausura),
    findall(P, ( member(P-Sucesores, Clausura),
                 ord_memberchk(P, Sucesores) ),
            Ps).

%!  componentes_de(+Clausulas:list, -Grupos:list(list)) is det.
%
%   Grupos son las componentes fuertemente conexas del grafo que tienen
%   algún ciclo: cada una es la lista ordenada de los predicados que se
%   alcanzan mutuamente, y un predicado recursivo por sí solo forma una
%   componente de uno.
componentes_de(Clausulas, Grupos) :-
    grafo(Clausulas, Grafo),
    transitive_closure(Grafo, Clausura),
    findall(Grupo, ( member(P-SP, Clausura),
                     ord_memberchk(P, SP),
                     findall(Q, ( member(Q, SP),
                                  neighbours(Q, Clausura, SQ),
                                  ord_memberchk(P, SQ) ),
                             Grupo) ),
            Grupos0),
    sort(Grupos0, Grupos).

%!  indefinidos(+Programa, -Ps:list) is det.
%
%   indefinidos_de/2 sobre las cláusulas del programa llamado Programa.
indefinidos(Programa, Ps) :-
    clausulas(Programa, Clausulas),
    indefinidos_de(Clausulas, Ps).

%!  no_usados(+Programa, -Ps:list) is det.
%
%   no_usados_de/3 sobre las cláusulas y los puntos de entrada del programa
%   llamado Programa.
no_usados(Programa, Ps) :-
    clausulas(Programa, Clausulas),
    raices(Programa, Raices),
    no_usados_de(Clausulas, Raices, Ps).

%!  recursivos(+Programa, -Ps:list) is det.
%
%   recursivos_de/2 sobre las cláusulas del programa llamado Programa.
recursivos(Programa, Ps) :-
    clausulas(Programa, Clausulas),
    recursivos_de(Clausulas, Ps).

%!  componentes(+Programa, -Grupos:list(list)) is det.
%
%   componentes_de/2 sobre las cláusulas del programa llamado Programa.
componentes(Programa, Grupos) :-
    clausulas(Programa, Clausulas),
    componentes_de(Clausulas, Grupos).

%!  arbol(+Clausulas:list, +Raiz, -Lineas:list) is det.
%
%   Lineas es el árbol de llamadas desde el predicado Raiz, sin los
%   predefinidos, en preorden: linea(N, Nivel, P, Nota) para la primera
%   aparición de P, con su número N, y linea(-, Nivel, P, ver(N)) para las
%   siguientes. Nota es indefinido para un predicado que nadie define, y
%   ninguna para los demás.
arbol(Clausulas, Raiz, Lineas) :-
    definidos(Clausulas, Ds),
    empty_assoc(Vistos),
    phrase(nodo(Clausulas, Ds, 0, Raiz, Vistos-1, _), Lineas).

%!  nodo(+Clausulas, +Ds, +Nivel, +P, +Estado0, -Estado)// is det.
%
%   Describe las líneas del subárbol de P en el nivel Nivel. El estado es
%   Vistos-N: la tabla de los predicados ya numerados y el próximo número.
nodo(Clausulas, Ds, Nivel, P, Vistos0-N0, Estado) -->
    (   { get_assoc(P, Vistos0, K) }
    ->  [linea(-, Nivel, P, ver(K))],
        { Estado = Vistos0-N0 }
    ;   { put_assoc(P, Vistos0, N0, Vistos),
          N is N0 + 1 },
        (   { ord_memberchk(P, Ds) }
        ->  [linea(N0, Nivel, P, ninguna)],
            { llamadas_de(Clausulas, P, Qs0),
              include(propio(Ds), Qs0, Qs),
              Nivel1 is Nivel + 1 },
            hijos(Qs, Clausulas, Ds, Nivel1, Vistos-N, Estado)
        ;   [linea(N0, Nivel, P, indefinido)],
            { Estado = Vistos-N }
        )
    ).

%!  hijos(+Qs, +Clausulas, +Ds, +Nivel, +Estado0, -Estado)// is det.
%
%   Describe los subárboles de los predicados Qs, en orden.
hijos([], _, _, _, Estado, Estado) -->
    [].
hijos([Q|Qs], Clausulas, Ds, Nivel, Estado0, Estado) -->
    nodo(Clausulas, Ds, Nivel, Q, Estado0, Estado1),
    hijos(Qs, Clausulas, Ds, Nivel, Estado1, Estado).

%!  escribir_arbol_de(+Clausulas:list, +Raiz) is det.
%
%   Escribe el árbol de llamadas desde Raiz: el número de cada predicado
%   en cuatro columnas, y tres espacios de sangría por nivel.
escribir_arbol_de(Clausulas, Raiz) :-
    arbol(Clausulas, Raiz, Lineas),
    forall(member(L, Lineas), escribir_linea(L)).

%!  escribir_arbol(+Programa, +Raiz) is det.
%
%   escribir_arbol_de/2 sobre las cláusulas del programa llamado Programa.
escribir_arbol(Programa, Raiz) :-
    clausulas(Programa, Clausulas),
    escribir_arbol_de(Clausulas, Raiz).

%!  escribir_linea(+Linea) is det.
%
%   Escribe una línea del árbol de llamadas.
escribir_linea(linea(N, Nivel, P, Nota)) :-
    (   N == (-)
    ->  Numero = ''
    ;   Numero = N
    ),
    Sangria is 3 * Nivel,
    nota(Nota, Texto),
    format("~t~w~4| ~*c~q~w~n", [Numero, Sangria, 0' , P, Texto]).

%!  nota(+Nota, -Texto:atom) is det.
%
%   Texto es lo que se escribe después del predicado en su línea.
nota(ninguna, '').
nota(indefinido, ' (indefinido)').
nota(ver(K), Texto) :-
    format(atom(Texto), " (ver ~d)", [K]).
