:- encoding(utf8).

% Capítulo 55 - Solución del ejercicio 12: la aventura del capítulo 44 y
% ELIZA en una conversación.
%
% Una frase que la gramática de órdenes de la aventura entiende se ejecuta
% en el juego; las demás van a ELIZA. El estado del juego está en la base
% de datos del módulo estado, del capítulo 44, y el de ELIZA viaja en el
% argumento de conversar/3.
%
% solo-local: carga archivos de este capítulo y del 44, y SWISH no admite
% módulos propios.
%
%?- open_string("estoy aburrido", In), aventura_con_eliza(In).

:- module(soluciones_aventura,
          [ responder/4,
            aventura_con_eliza/1
          ]).

:- use_module('../capitulo-44/lenguaje', [ iniciar/0,
                                            entender/2,
                                            responder/2 as responder_orden
                                          ]).
:- use_module(eliza, [ estado_inicial/1,
                       responder/4 as responder_eliza,
                       conversar/3
                     ]).

%!  responder(+Frase:string, +Estado0, -Estado, -Respuesta:string) is det.
%
%   Si Frase es una orden de la aventura, la ejecuta y Respuesta es la del
%   juego; si no, Respuesta es la de ELIZA, en el estado Estado0.
responder(Frase, Estado0, Estado, Respuesta) :-
    entender(Frase, Orden),
    (   Orden == no_entendido
    ->  responder_eliza(Frase, Estado0, Estado, Respuesta)
    ;   Estado = Estado0,
        responder_orden(Orden, Respuesta)
    ).

%!  aventura_con_eliza(+In) is det.
%
%   Empieza una partida y conversa con las frases de In.
aventura_con_eliza(In) :-
    iniciar,
    estado_inicial(E0),
    conversar(In, responder, E0).
