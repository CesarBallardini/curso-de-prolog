:- encoding(utf8).

% Capítulo 71 - La notación de Bratko y los puntos clave.
%
% Bratko escribe un grafo Y/O con el operador --->: Nodo ---> or:Hijos o
% Nodo ---> and:Hijos, donde cada hijo es Hijo/Costo, y los problemas
% triviales con un predicado aparte. Este archivo escribe en esa notación
% dos problemas, el grafo de la figura 13.4 del libro y la ruta por el
% mapa de mapa.pl con «puntos clave», y los conecta con las búsquedas del
% capítulo a través de expansion/4: el problema bratko(E) lee las
% cláusulas de --->/2, con la estimación E.
%
% Un punto clave entre X y Z es un lugar por el que tiene que pasar toda
% ruta de X a Z. Si hay puntos clave, X-Z es un nodo O con un hijo
% X-Z via Y por cada punto clave Y, y cada uno es un nodo Y con dos
% partes, X-Y e Y-Z. Si no los hay, X-Z sale por un camino de X.
%
% Bratko declara ---> con prioridad 600 y redefine : con 500; en
% SWI-Prolog : ya es un operador de prioridad 600, el de los módulos, y
% ---> se declara con prioridad 700 para que admita T:Hijos a su derecha
% sin redefinir :.
%
% solo-local: carga mejor.pl y profundidad.pl.
%
%?- mejor(bratko(cero), a, A, C, K).
%?- mejor(bratko(distancia), alamos-islas, A, C, K).

:- ensure_loaded(mejor).
:- ensure_loaded(profundidad).

:- op(700, xfx, --->).
:- op(560, xfx, via).

:- multifile primitivo/2, expansion/4, estimacion/3.
:- discontiguous (--->)/2, trivial/1.

% --- La figura 13.4: costos en los arcos -----------------------------------

% N ---> T:Hijos: el nodo N es un nodo T, or o and, con los Hijos, cada
% uno escrito Hijo/Costo.
a ---> or:[b/1, c/3].
b ---> and:[d/1, e/1].
c ---> and:[f/2, g/1].
e ---> or:[h/6].
f ---> or:[h/2, i/3].

% trivial(N): el problema N se resuelve sin descomponerlo.
trivial(d).
trivial(g).
trivial(h).
trivial(X-X).

% --- La ruta con puntos clave ------------------------------------------------

%!  clave(+Problema, -Y) is nondet.
%
%   Y es un punto clave entre X y Z, con Problema igual a X-Z: si X y Z
%   están en orillas opuestas del río, los tres pueblos sobre el río.
clave(X-Z, Y) :-
    separados(X, Z),
    pueblo(Y, rio, _, _).

%!  --->(+Nodo, -Reduccion) is semidet.
%
%   Las reglas de Bratko para la ruta: con puntos clave, un nodo O con un
%   hijo via por cada uno; sin ellos, un nodo O con un hijo por camino;
%   un nodo via es un nodo Y con los dos tramos.
X-Z ---> or:Hijos :-
    findall((X-Z via Y)/0, clave(X-Z, Y), Hijos),
    Hijos \== [],
    !.
X-Z ---> or:Hijos :-
    findall((Y-Z)/D, tramo(X, Y, D), Hijos).
X-Z via Y ---> and:[(X-Y)/0, (Y-Z)/0].

% --- La conexión con las búsquedas del capítulo -----------------------------

% primitivo(P, N): los problemas triviales de --->/2.
primitivo(bratko(_), Nodo) :-
    trivial(Nodo).

%!  expansion(+Problema, +Nodo, -Tipo, -Hijos:list) is semidet.
%
%   Con Problema igual a bratko(E), Nodo se reduce según --->/2: or es un
%   nodo o, and un nodo y, y cada Hijo/Costo es Hijo-Costo.
expansion(bratko(_), Nodo, Tipo, Hijos) :-
    \+ trivial(Nodo),
    once(Nodo ---> T:Lista),
    tipo_bratko(T, Tipo),
    maplist(arco_bratko, Lista, Hijos).

%!  estimacion(+Problema, +Nodo, -H:integer) is det.
%
%   Con bratko(cero), cero; con bratko(distancia), la distancia en línea
%   recta de la ruta, pasando por el punto clave si lo hay, y cero para
%   los nodos de la figura.
estimacion(bratko(cero), _, 0).
estimacion(bratko(distancia), Nodo, H) :-
    distancia_bratko(Nodo, H).

%!  distancia_bratko(+Nodo, -H:integer) is det.
%
%   H es la distancia en línea recta que recorre cualquier ruta de Nodo.
distancia_bratko(X-Z via Y, H) :-
    !,
    distancia(X, Y, H1),
    distancia(Y, Z, H2),
    H is H1 + H2.
distancia_bratko(X-Z, H) :-
    pueblo(X, _, _, _),
    !,
    distancia(X, Z, H).
distancia_bratko(_, 0).

% tipo_bratko(T, Tipo): el nombre de Bratko y el del capítulo.
tipo_bratko(or, o).
tipo_bratko(and, y).

%!  arco_bratko(+HijoCosto, -Arco) is det.
%
%   Arco es Hijo-Costo para HijoCosto igual a Hijo/Costo.
arco_bratko(Hijo/Costo, Hijo-Costo).
