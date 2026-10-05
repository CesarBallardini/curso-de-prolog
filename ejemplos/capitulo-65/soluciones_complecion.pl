:- encoding(utf8).

% Capítulo 65 - Solución del ejercicio 13: programas completos.
%
% completo/2 decide si la compleción de un programa tiene un único modelo,
% y lo devuelve. Se agregan dos programas de Flach: Pedro es amistoso si
% no lo es, y antepasado/2 sobre progenitor/2, con una variable
% existencial; y p :- p, que se define a sí mismo.
%
% solo-local: carga un archivo de otro capítulo.
%
%?- escribir_complecion(amistoso).
%?- findall(N-M, ( member(N, [gusta, amistoso, tautologia, antepasados]), modelo_unico(N, M) ), L).

:- ensure_loaded(complecion).

:- multifile generado/2.

% generado(Nombre, Clausulas): los programas del ejercicio.
generado(amistoso, [ (amistoso(pedro) :- \+ amistoso(pedro)) ]).
generado(antepasados,
    [ (progenitor(ana, luis) :- true),
      (progenitor(luis, eva) :- true),
      (antepasado(X, Y) :- progenitor(X, Y)),
      (antepasado(X, Y) :- progenitor(X, Z), antepasado(Z, Y))
    ]).
generado(tautologia, [ (p :- p) ]).

%!  completo(+Nombre, -Modelo:list) is semidet.
%
%   La compleción del programa Nombre tiene un único modelo, Modelo.
completo(Nombre, Modelo) :-
    modelos(Nombre, [Modelo]).

%!  modelo_unico(+Nombre, -Respuesta) is det.
%
%   Respuesta es el único modelo de la compleción del programa Nombre, o
%   ninguno, o varios(N) si tiene N modelos.
modelo_unico(Nombre, Respuesta) :-
    modelos(Nombre, Ms),
    length(Ms, N),
    (   N =:= 1
    ->  Ms = [Respuesta]
    ;   N =:= 0
    ->  Respuesta = ninguno
    ;   Respuesta = varios(N)
    ).
