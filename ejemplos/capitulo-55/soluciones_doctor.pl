:- encoding(utf8).

% Capítulo 55 - Solución del ejercicio 13: una clave más para el guion
% DOCTOR, agregada a los predicados multifile del módulo doctor.
%
% solo-local: carga archivos de este capítulo y del 44, y SWISH no admite
% módulos propios.
%
%?- estado_doctor(E0), responder_doctor("Recuerdo mi infancia.", E0, _, R).

:- use_module(doctor).

doctor:sustituye(recuerdo, "recuerdas").

doctor:clave(recuerdo, 5,
             [ [0, "recuerdas", 0]
               - [ ["¿Piensas a menudo en ", 3, "?"],
                   ["¿Qué más recuerdas?"] ] ]).

%!  respuestas_doctor(+Frases:list(string), -Respuestas:list(string)) is det.
%
%   Respuestas son las respuestas del guion a Frases, en orden y desde el
%   estado inicial.
respuestas_doctor(Frases, Respuestas) :-
    estado_doctor(E0),
    foldl(responder_en_orden, Frases, Respuestas, E0, _).

%!  responder_en_orden(+Frase, -Respuesta, +E0, -E) is det.
%
%   responder_doctor/4 con el estado en los dos últimos argumentos.
responder_en_orden(Frase, Respuesta, E0, E) :-
    responder_doctor(Frase, E0, E, Respuesta).
