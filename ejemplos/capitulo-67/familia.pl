:- encoding(utf8).

% Capítulo 67 - El problema: la familia de los capítulos 2 y 3, los
% ejemplos y el modelo de fondo.
%
% Los hechos no se copian: reglas.pl del capítulo 3 se carga en el módulo
% familia3, y semantica.pl del capítulo 38 en el módulo semantica38. El
% conocimiento de fondo son las cláusulas de varon/1, mujer/1, padre/2,
% madre/2 y progenitor/2, y el modelo de fondo es su modelo mínimo,
% calculado por modelo_minimo_de/2 del capítulo 38. Cada relación que se
% aprende tiene una definición esperada, que conoce el que da los ejemplos
% y no el programa que aprende. Con el supuesto del mundo cerrado, los
% ejemplos negativos son todos los pares de personas que la definición
% esperada no incluye.
%
% solo-local: carga archivos de otros capítulos, y SWISH no permite cargar
% otro archivo.
%
%?- modelo_fondo(M), length(M, N).
%?- ejemplos(abuelo, Pos, Negs), length(Negs, N).

:- module(familia,
          [ de_fondo/1,
            clausulas_fondo/1,
            modelo_fondo/1,
            persona/1,
            esperado/2,
            ejemplos/3,
            modelo_minimo_de/2
          ]).

:- use_module(library(lists)).

:- load_files(familia3:'../capitulo-03/reglas', []).
:- load_files(semantica38:'../capitulo-38/semantica', []).

% de_fondo(P): P es un predicado del conocimiento de fondo.
de_fondo(varon/1).
de_fondo(mujer/1).
de_fondo(padre/2).
de_fondo(madre/2).
de_fondo(progenitor/2).

%!  clausulas_fondo(-Clausulas:list) is det.
%
%   Clausulas son las cláusulas de los predicados de fondo, leídas con
%   clause/2 del módulo familia3, como términos Cabeza :- Cuerpo.
clausulas_fondo(Clausulas) :-
    findall(Cabeza :- Cuerpo,
            ( de_fondo(Nombre/Aridad),
              functor(Cabeza, Nombre, Aridad),
              clause(familia3:Cabeza, Cuerpo) ),
            Clausulas).

%!  modelo_fondo(-M:list) is det.
%
%   M es el modelo mínimo del conocimiento de fondo: los átomos sin
%   variables que se deducen de él, en un conjunto ordenado.
modelo_fondo(M) :-
    clausulas_fondo(Clausulas),
    modelo_minimo_de(Clausulas, M).

%!  modelo_minimo_de(+Clausulas:list, -M:list) is det.
%
%   M es el modelo mínimo de Clausulas: modelo_minimo_de/2 del capítulo
%   38.
modelo_minimo_de(Clausulas, M) :-
    semantica38:modelo_minimo_de(Clausulas, M).

%!  persona(?P) is nondet.
%
%   P es una persona de la familia: un varón o una mujer.
persona(P) :-
    familia3:varon(P).
persona(P) :-
    familia3:mujer(P).

%!  esperado(?Relacion, ?Atomo) is nondet.
%
%   Atomo es verdadero en la definición esperada de Relacion: abuelo y
%   abuela son las reglas del capítulo 3; hermano y antepasado se
%   definen aquí. Es el conocimiento del que da los ejemplos.
esperado(abuelo, abuelo(A, N)) :-
    familia3:abuelo(A, N).
esperado(abuela, abuela(A, N)) :-
    familia3:abuela(A, N).
esperado(hermano, hermano(A, B)) :-
    familia3:varon(A),
    familia3:progenitor(P, A),
    familia3:progenitor(P, B),
    A \== B.
esperado(antepasado, antepasado(A, D)) :-
    ascendiente(A, D).

%!  ascendiente(?A, ?D) is nondet.
%
%   A es un progenitor de D, o un progenitor de un ascendiente de D.
ascendiente(A, D) :-
    familia3:progenitor(A, D).
ascendiente(A, D) :-
    familia3:progenitor(A, H),
    ascendiente(H, D).

%!  ejemplos(+Relacion, -Pos:list, -Negs:list) is det.
%
%   Pos son los ejemplos positivos de Relacion, una relación binaria
%   entre personas, y Negs los negativos: todos los pares de personas que
%   la definición esperada no incluye (supuesto del mundo cerrado). Las
%   dos listas están ordenadas y no tienen repetidos.
ejemplos(Relacion, Pos, Negs) :-
    setof(Atomo, esperado(Relacion, Atomo), Pos),
    findall(Atomo,
            ( persona(A),
              persona(B),
              Atomo =.. [Relacion, A, B],
              \+ memberchk(Atomo, Pos) ),
            Negs0),
    sort(Negs0, Negs).
