:- encoding(utf8).

% Capítulo 71 - Problemas, grafos Y/O y árboles solución.
%
% Un problema se describe con tres predicados, que las búsquedas del
% capítulo llaman sin conocer el problema por dentro:
%
%   primitivo(Problema, Nodo)      Nodo se resuelve sin descomponerlo;
%   expansion(Problema, Nodo, Tipo, Hijos)
%                                  Nodo se reduce a Hijos, una lista de
%                                  Hijo-Costo: basta uno (Tipo = o) o
%                                  hacen falta todos (Tipo = y);
%   estimacion(Problema, Nodo, H)  H no supera el costo de resolver Nodo.
%
% Un nodo que no es primitivo y no tiene expansión no tiene solución. Cada
% archivo de problema agrega sus cláusulas a estos predicados, que por eso
% son multifile.
%
% Un árbol solución es un término: meta(N) para un nodo primitivo,
% o(N, A-C) para un nodo O resuelto por el hijo cuyo árbol es A, con un
% arco de costo C, e y(N, [A1-C1, ..., Ak-Ck]) para un nodo Y resuelto por
% todos sus hijos. El costo de un árbol es la suma de los costos de sus
% arcos.
%
%?- costo(y(a, [meta(b)-1, o(c, meta(d)-3)-2]), C).
%?- mostrar(y(a, [meta(b)-1, o(c, meta(d)-3)-2])).

:- multifile primitivo/2, expansion/4, estimacion/3.
:- dynamic primitivo/2, expansion/4, estimacion/3.

%!  costo(+Arbol, -Costo:number) is det.
%
%   Costo es la suma de los costos de los arcos de Arbol.
costo(meta(_), 0).
costo(o(_, A-C), Costo) :-
    costo(A, Costo0),
    Costo is C + Costo0.
costo(y(_, Hijos), Costo) :-
    foldl(sumar_arco, Hijos, 0, Costo).

%!  sumar_arco(+Arco, +S0:number, -S:number) is det.
%
%   S es S0 más el costo C del arco A-C y el del árbol A.
sumar_arco(A-C, S0, S) :-
    costo(A, CA),
    S is S0 + C + CA.

%!  raiz(+Arbol, -Nodo) is det.
%
%   Nodo es el nodo de la raíz de Arbol.
raiz(meta(N), N).
raiz(o(N, _), N).
raiz(y(N, _), N).

%!  hojas(+Arbol, -Hojas:list) is det.
%
%   Hojas son los nodos primitivos de Arbol, de izquierda a derecha.
hojas(Arbol, Hojas) :-
    phrase(hojas(Arbol), Hojas).

%!  hojas(+Arbol)// is det.
%
%   La lista son los nodos primitivos de Arbol.
hojas(meta(N)) -->
    [N].
hojas(o(_, A-_)) -->
    hojas(A).
hojas(y(_, Hijos)) -->
    hojas_de(Hijos).

%!  hojas_de(+Hijos:list)// is det.
%
%   La lista son los nodos primitivos de los árboles de Hijos, en orden.
hojas_de([]) -->
    [].
hojas_de([A-_|As]) -->
    hojas(A),
    hojas_de(As).

%!  mostrar(+Arbol) is det.
%
%   Escribe Arbol con un nodo por línea, sangrado según su profundidad.
%   Un nodo O lleva una «o» al final y un nodo Y, una «y»; delante de cada
%   hijo va el costo de su arco, con un «+».
mostrar(Arbol) :-
    mostrar(Arbol, 0, "").

%!  mostrar(+Arbol, +Sangria:integer, +Arco:string) is det.
%
%   Escribe Arbol con Sangria espacios y el texto Arco delante de su raíz.
mostrar(meta(N), S, Arco) :-
    format("~*c~s~w~n", [S, 0' , Arco, N]).
mostrar(o(N, Hijo), S, Arco) :-
    format("~*c~s~w  o~n", [S, 0' , Arco, N]),
    mostrar_hijo(S, Hijo).
mostrar(y(N, Hijos), S, Arco) :-
    format("~*c~s~w  y~n", [S, 0' , Arco, N]),
    forall(member(Hijo, Hijos), mostrar_hijo(S, Hijo)).

%!  mostrar_hijo(+Sangria:integer, +Hijo) is det.
%
%   Escribe el árbol A del hijo A-C, dos espacios más adentro y con +C
%   delante.
mostrar_hijo(S, A-C) :-
    S1 is S + 2,
    format(string(Arco), "+~w ", [C]),
    mostrar(A, S1, Arco).
