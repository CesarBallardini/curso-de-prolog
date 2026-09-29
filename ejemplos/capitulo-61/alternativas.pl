:- encoding(utf8).

% Capítulo 61 - Versión 2: la búsqueda como una pila de alternativas.
%
% La máquina ya no deja que Prolog elija las cláusulas. Su estado es una
% pila de alternativas, cada una una resolvente completa junto con la
% instancia de la consulta que le corresponde. Un paso saca la alternativa
% de arriba y la reemplaza por todas las que se obtienen de su primera
% meta, una por cada cláusula que sirve, cada una con su propia copia de
% las variables. La búsqueda es un ciclo sin puntos de elección de Prolog;
% el único que queda es el que entrega las respuestas de a una. El precio
% es la copia: cada alternativa copia la resolvente entera.
%
% solo-local: carga el módulo programas.
%
%?- resolver(familia, abuelo(juan, N)).
%?- medir(listas, suma_hasta(100, S), M).

:- module(alternativas, [resolver/2, medir/3]).

:- use_module(library(apply)).
:- use_module(library(lists)).
:- use_module(programas).

%!  resolver(+Nombre:atom, ?Meta) is nondet.
%
%   Meta se prueba con las cláusulas del programa objeto Nombre: una
%   respuesta por cada demostración, en el orden de Prolog.
resolver(Nombre, Meta) :-
    programa(Nombre, Clausulas),
    buscar([alt([Meta], Meta)], Clausulas, med(0, 0, 0), Evento),
    Evento = respuesta(Meta).

%!  medir(+Nombre:atom, +Meta, -Medidas:list) is det.
%
%   Medidas son los pares pasos-P, respuestas-R, alternativas-A y
%   copiado-C de la búsqueda completa de Meta: P pasos, R respuestas, A
%   alternativas en la pila como máximo, y C celdas copiadas en total al
%   crear alternativas.
medir(Nombre, Meta, [ pasos-P, respuestas-R, alternativas-A, copiado-C ]) :-
    programa(Nombre, Clausulas),
    findall(Evento,
            buscar([alt([Meta], Meta)], Clausulas, med(0, 0, 0), Evento),
            Eventos),
    include(es_respuesta, Eventos, Respuestas),
    length(Respuestas, R),
    last(Eventos, fin(med(P, A, C))).

%!  es_respuesta(+Evento) is semidet.
%
%   Evento es una respuesta.
es_respuesta(respuesta(_)).

%!  buscar(+Pila:list, +Clausulas:list, +Medidas, -Evento) is multi.
%
%   Evento es, en orden, respuesta(R) por cada respuesta R que se obtiene
%   de la Pila de alternativas, y por último fin(Medidas).
buscar([], _, Medidas, fin(Medidas)).
buscar([alt(Metas, R)|Pila], Clausulas, Medidas, Evento) :-
    desde(Metas, R, Pila, Clausulas, Medidas, Evento).

%!  desde(+Metas:list, +R, +Pila:list, +Clausulas:list, +Medidas,
%!        -Evento) is multi.
%
%   Continúa la búsqueda con la alternativa Metas, cuya consulta es R,
%   encima de la Pila.
desde([], R, Pila, Clausulas, Medidas, Evento) :-
    (   Evento = respuesta(R)
    ;   buscar(Pila, Clausulas, Medidas, Evento)
    ).
desde([Meta|Metas], R, Pila, Clausulas, Medidas0, Evento) :-
    clase(Meta, Clase),
    expandir(Clase, Metas, R, Clausulas, Nuevas),
    append(Nuevas, Pila, Pila1),
    contar(Clase, Nuevas, Pila1, Medidas0, Medidas),
    buscar(Pila1, Clausulas, Medidas, Evento).

%!  expandir(+Clase, +Metas:list, +R, +Clausulas:list, -Nuevas:list)
%!      is det.
%
%   Nuevas son las alternativas que resultan de probar una meta de la
%   Clase dada, seguida de Metas, con la consulta R: ninguna, una o una
%   por cada cláusula cuya cabeza unifica con la meta.
expandir(verdad, Metas, R, _, [alt(Metas, R)]).
expandir(conjuncion(A, B), Metas, R, _, [alt([A, B|Metas], R)]).
expandir(corte, Metas, R, _, [alt(Metas, R)]).
expandir(predefinida(Meta), Metas, R, _, Nuevas) :-
    (   ejecutar(Meta)
    ->  Nuevas = [alt(Metas, R)]
    ;   Nuevas = []
    ).
expandir(usuario(Meta), Metas, R, Clausulas, Nuevas) :-
    findall(alt([Cuerpo|Metas], R),
            ( member(Clausula, Clausulas),
              copy_term(Clausula, (Meta :- Cuerpo))
            ),
            Nuevas).

%!  contar(+Clase, +Nuevas:list, +Pila:list, +Medidas0, -Medidas) is det.
%
%   Medidas agrega a Medidas0 un paso, el tamaño de la Pila y, si la meta
%   era de usuario, las celdas de las Nuevas alternativas, que findall/3
%   copió.
contar(Clase, Nuevas, Pila, med(P0, A0, C0), med(P, A, C)) :-
    P is P0 + 1,
    length(Pila, N),
    A is max(A0, N),
    (   Clase = usuario(_)
    ->  term_size(Nuevas, Celdas),
        C is C0 + Celdas
    ;   C = C0
    ).
