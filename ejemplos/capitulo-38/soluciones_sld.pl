:- encoding(utf8).

% Capítulo 38 - Soluciones de los ejercicios 4, 6, 7 y 8: las refutaciones
% con sus resolventes, y la compleción de los predicados de un programa.
% Usa paso_de/4 y complecion_de/3 de sld.pl, y nombra juego(j2) con
% generado/2.
%
% solo-local: carga sld.pl con ensure_loaded/1, y SWISH no permite cargar
% otro archivo.
%
%?- refutacion(izquierda, enlaces, [conexion(a, c)], 4, Rs).
%?- mostrar_complecion(aves).

:- ensure_loaded(sld).

%!  refutacion_de(+Seleccion, +Clausulas:list, +Metas:list,
%!                 +Limite:integer, -Resolventes:list) is nondet.
%
%   Resolventes son las consultas de una refutación de Metas con la regla
%   Seleccion, de Limite pasos o menos: la primera es Metas y la última la
%   consulta vacía. Cada una es una copia tomada en su paso, sin las
%   ligaduras de los pasos siguientes. Una respuesta por refutación, en el
%   orden del árbol SLD; la respuesta calculada queda en Metas.
refutacion_de(Seleccion, Clausulas, Metas, Limite, [Copia|Resolventes]) :-
    copy_term(Metas, Copia),
    (   Metas == []
    ->  Resolventes = []
    ;   Limite > 0,
        Limite1 is Limite - 1,
        paso_de(Seleccion, Clausulas, Metas, Resolvente),
        refutacion_de(Seleccion, Clausulas, Resolvente, Limite1, Resolventes)
    ).

%!  refutacion(+Seleccion, +Programa, +Metas:list, +Limite:integer,
%!             -Resolventes:list) is nondet.
%
%   refutacion_de/5 con las cláusulas del programa llamado Programa.
refutacion(Seleccion, Programa, Metas, Limite, Resolventes) :-
    clausulas(Programa, Clausulas),
    refutacion_de(Seleccion, Clausulas, Metas, Limite, Resolventes).

:- multifile generado/2.

% generado(Programa, Clausulas): el programa juego(j2) son las cláusulas
% del programa juego de semantica.pl, escritas como datos: la regla de
% gana/2 y los movimientos del juego j2.
generado(juego(j2), [ (gana(J, X) :- mueve(J, X, Y), \+ gana(J, Y)),
                      (mueve(j2, a, b) :- true),
                      (mueve(j2, b, a) :- true),
                      (mueve(j2, b, c) :- true),
                      (mueve(j2, c, d) :- true) ]).

%!  mostrar_complecion(+Programa:atom) is det.
%
%   Escribe la definición completada de cada predicado de Programa, uno por
%   línea, con las variables nombradas A, B, C…
mostrar_complecion(Programa) :-
    clausulas(Programa, Clausulas),
    programa(Programa, Indicadores),
    forall(member(Indicador, Indicadores),
           ( complecion_de(Clausulas, Indicador, Formula),
             escribir_formula(Formula) )).

%!  escribir_formula(+Formula) is det.
%
%   Escribe Formula y un salto de línea, con sus variables nombradas A, B,
%   C…, sin ligarlas.
escribir_formula(Formula) :-
    \+ \+ ( numbervars(Formula, 0, _),
            print(Formula),
            nl ).
