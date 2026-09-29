:- encoding(utf8).

% Capítulo 59 - Soluciones de los ejercicios 6 y 7: las declaraciones
% meta_predicate del programa, y las que se pueden inferir de su código.
%
% Las dos soluciones declaran metallamadas en el módulo externo de la
% versión 3, donde meta_argumento/3 las encuentra. El programa con_meta es
% el de texto_con_meta/1, con p/0 como punto de entrada.
%
% solo-local: lee archivos y carga leer.pl.
%
%?- no_usados(con_meta, Ps).
%?- metas_inferidas(inscripciones, Ds).

:- ensure_loaded(leer).

% Ejercicio 6: las declaraciones del programa.

%!  texto_con_meta(-Texto:string) is det.
%
%   Texto es un programa con una metallamada propia, aplicar/2, declarada.
texto_con_meta(Texto) :-
    Lineas = [ ":- meta_predicate aplicar(1, ?).",
               "",
               "%!  aplicar(:G, ?X) is nondet.",
               "%",
               "%   Llama a G con X como argumento más.",
               "aplicar(G, X) :-",
               "    call(G, X).",
               "",
               "%!  p is semidet.",
               "%",
               "%   El número 1 cumple q/1.",
               "p :-",
               "    aplicar(q, 1).",
               "",
               "% q(X): X es uno.",
               "q(1)."
             ],
    atomic_list_concat(Lineas, '\n', Atomo),
    atom_string(Atomo, Texto).

%!  leidos_con_meta(-Leidos:list) is det.
%
%   Leidos son los términos del programa de texto_con_meta/1.
leidos_con_meta(Leidos) :-
    texto_con_meta(Texto),
    setup_call_cleanup(open_string(Texto, Stream),
                       leer_terminos(Stream, texto, Leidos),
                       close(Stream)).

%!  clausulas(+Programa, -Clausulas:list) is semidet.
%
%   Cláusula agregada: las cláusulas de con_meta, el programa de
%   texto_con_meta/1. Sus declaraciones meta_predicate quedan en el módulo
%   externo.
clausulas(con_meta, Clausulas) :-
    leidos_con_meta(Leidos),
    declarar_metas(Leidos),
    programa(Leidos, Clausulas, _).

%!  raices(+Programa, -Raices:list) is semidet.
%
%   Cláusula agregada: los puntos de entrada de con_meta y p/0.
raices(con_meta, Raices) :-
    leidos_con_meta(Leidos),
    programa(Leidos, _, Raices0),
    sort([p/0|Raices0], Raices).

%!  declarar_metas(+Leidos:list) is det.
%
%   Declara en el módulo externo cada declaración meta_predicate de
%   Leidos.
declarar_metas(Leidos) :-
    forall(( member(leido((:- meta_predicate(E)), _, _, _), Leidos),
             lista_de_especificaciones(E, Ds),
             member(D, Ds) ),
           declarar_meta(D)).

%!  declarar_meta(+Declaracion) is det.
%
%   Declara Declaracion en el módulo externo. El predicado se declara
%   dynamic antes: predicate_property/2 no informa la declaración de un
%   predicado que no existe.
declarar_meta(Declaracion) :-
    functor(Declaracion, Nombre, Aridad),
    dynamic(externo:Nombre/Aridad),
    meta_predicate(externo:Declaracion).

% Ejercicio 7: las declaraciones que se infieren.

%!  metas_inferidas_de(+Clausulas:list, -Declaraciones:list) is det.
%
%   Declaraciones son las declaraciones meta_predicate que se infieren de
%   Clausulas: una por cada predicado que llama como meta a alguno de sus
%   argumentos.
metas_inferidas_de(Clausulas, Declaraciones) :-
    definidos(Clausulas, Ds),
    findall(D, ( member(PI, Ds),
                 metaargumentos(Clausulas, PI, D) ),
            Declaraciones).

%!  metaargumentos(+Clausulas:list, +PI, -Declaracion) is semidet.
%
%   Declaracion es la cabeza de PI con un entero en cada argumento que una
%   cláusula de PI llama como meta, el número de argumentos que le agrega,
%   y ? en los demás. Falla si PI no llama a ninguno de sus argumentos.
metaargumentos(Clausulas, Nombre/Aridad, Declaracion) :-
    findall(I-Extra, ( member(C, Clausulas),
                       cabeza_cuerpo(C, Cabeza, Cuerpo),
                       functor(Cabeza, Nombre, Aridad),
                       variable_llamada(Cuerpo, V, Extra),
                       arg(I, Cabeza, A),
                       A == V ),
            Pares),
    Pares \== [],
    numlist(1, Aridad, Is),
    maplist(tipo(Pares), Is, Tipos),
    Declaracion =.. [Nombre|Tipos].

%!  tipo(+Pares:list, +I:integer, -Tipo) is det.
%
%   Tipo es el número de argumentos que se agregan al argumento I, según
%   Pares, o ? si no se llama como meta.
tipo(Pares, I, Tipo) :-
    (   memberchk(I-Extra, Pares)
    ->  Tipo = Extra
    ;   Tipo = ?
    ).

%!  variable_llamada(+Cuerpo, -V, -Extra:integer) is nondet.
%
%   Cuerpo llama como meta a la variable V con Extra argumentos más:
%   directamente, dentro de una construcción de control o como argumento de
%   una metallamada.
variable_llamada(G, V, Extra) :-
    (   var(G)
    ->  V = G,
        Extra = 0
    ;   partes_de_control(G, Partes)
    ->  member(P, Partes),
        variable_llamada(P, V, Extra)
    ;   meta_argumento(G, A, E0),
        (   var(A)
        ->  V = A,
            Extra = E0
        ;   E0 == 0,
            variable_llamada(A, V, Extra)
        )
    ).

%!  partes_de_control(+G, -Partes:list) is semidet.
%
%   G es una construcción de control y Partes son sus metas.
partes_de_control((A, B), [A, B]).
partes_de_control((A ; B), [A, B]).
partes_de_control((A -> B), [A, B]).
partes_de_control((A *-> B), [A, B]).
partes_de_control(\+ A, [A]).
partes_de_control(_:A, [A]).

%!  declarar_inferidas_de(+Clausulas:list) is det.
%
%   Declara en el módulo externo las metallamadas que se infieren de
%   Clausulas.
declarar_inferidas_de(Clausulas) :-
    metas_inferidas_de(Clausulas, Declaraciones),
    forall(member(D, Declaraciones), declarar_meta(D)).

%!  metas_inferidas(+Programa, -Declaraciones:list) is det.
%
%   metas_inferidas_de/2 sobre las cláusulas del programa llamado Programa.
metas_inferidas(Programa, Declaraciones) :-
    clausulas(Programa, Clausulas),
    metas_inferidas_de(Clausulas, Declaraciones).

%!  declarar_inferidas(+Programa) is det.
%
%   declarar_inferidas_de/1 sobre las cláusulas del programa llamado
%   Programa.
declarar_inferidas(Programa) :-
    clausulas(Programa, Clausulas),
    declarar_inferidas_de(Clausulas).
