:- encoding(utf8).

% Capítulo 55 - Versión 5 de los diálogos: la agenda y ELIZA en una misma
% conversación. Es el programa terminado.
%
% Cada frase pasa primero por la gramática de la agenda, que es la
% plantilla más específica: si la reconoce, la agenda responde; si no,
% responde ELIZA. El estado de la conversación reúne los dos estados, y el
% bucle es conversar/3 de la versión 3, con otro predicado para responder.
%
% solo-local: carga archivos de otros capítulos, y SWISH no admite módulos
% propios.
%
%?- dialogo_inicial(E0), responder("Estoy cansado", E0, _, R).

:- module(dialogo,
          [ dialogo_inicial/1,
            responder/4,
            dialogo/1,
            dialogo/0
          ]).

:- use_module(eliza, [ estado_inicial/1,
                       responder/4 as responder_eliza,
                       conversar/3
                     ]).
:- use_module(agenda, [atender/4]).

%!  dialogo_inicial(-Estado) is det.
%
%   Estado es el de una conversación que empieza: el estado inicial de
%   ELIZA y una agenda vacía.
dialogo_inicial(dialogo(Eliza, [])) :-
    estado_inicial(Eliza).

%!  responder(+Frase:string, +Estado0, -Estado, -Respuesta:string) is det.
%
%   Respuesta es la respuesta de la agenda a Frase, si la agenda la
%   reconoce, o la de ELIZA si no; Estado es el estado que queda.
responder(Frase, dialogo(Eliza0, Agenda0), dialogo(Eliza, Agenda),
          Respuesta) :-
    (   atender(Frase, Agenda0, Agenda1, Respuesta0)
    ->  Eliza = Eliza0,
        Agenda = Agenda1,
        Respuesta = Respuesta0
    ;   Agenda = Agenda0,
        responder_eliza(Frase, Eliza0, Eliza, Respuesta)
    ).

%!  dialogo(+In) is det.
%
%   Saluda y conversa con las frases de In.
dialogo(In) :-
    format("Hola. Cuéntame qué te preocupa, o dime qué citas tienes.~n"),
    dialogo_inicial(E0),
    conversar(In, responder, E0).

%!  dialogo is det.
%
%   Conversa con el teclado.
dialogo :-
    dialogo(user_input).
