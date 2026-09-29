:- encoding(utf8).

% Capítulo 65 - Negación como falla, semántica bien fundada y reglas
% rebatibles, sobre los mismos dos casos.
%
% El diamante de Drácula con tnot/1: las dos reglas con excepciones que se
% niegan una a la otra, tabuladas, dan respuestas indefinidas en lugar de
% no terminar. Las reglas r11, r12 y r13 de la sección 38.7, escritas como
% reglas rebatibles: las observaciones son hechos, «ave y nada» concluye
% pingüino en forma rebatible, y «los pingüinos no vuelan» es una regla
% estricta. El capítulo 39 da el resultado de la semántica bien fundada
% para las mismas observaciones: este archivo carga su experto.pl.
%
% solo-local: carga el módulo rebatible y el experto.pl del capítulo 39,
% y SWISH no admite cargar otros archivos.
%
%?- valor(vuela_tabulada(dracula), V).
%?- diagnostico(vuela, [tiene_plumas, nada, peso(30)], R).
%?- respuesta([especificidad], pinguino, R).

:- ensure_loaded('../capitulo-39/experto').
:- use_module(rebatible).

% murcielago(X): X es un murciélago.
murcielago(dracula).

% muerto(X): X está muerto.
muerto(dracula).

:- table vuela_tabulada/1, no_vuela_tabulada/1.

%!  vuela_tabulada(?X) is nondet.
%
%   X vuela: es un murciélago y no se prueba que no vuele. Con Drácula, la
%   respuesta es indefinida.
vuela_tabulada(X) :-
    murcielago(X),
    tnot(no_vuela_tabulada(X)).

%!  no_vuela_tabulada(?X) is nondet.
%
%   X no vuela: está muerto y no se prueba que vuele.
no_vuela_tabulada(X) :-
    muerto(X),
    tnot(vuela_tabulada(X)).

% Las observaciones del caso de la sección 38.7: un ave con plumas, que
% nada y pesa 30 kilos.
tiene_plumas.
nada.
peso(30).

%!  ave is semidet.
%
%   Lo observado es un ave: tiene plumas.
ave :-
    tiene_plumas.

% neg vuela: un pingüino o un avestruz no vuela.
neg vuela :-
    pinguino.
neg vuela :-
    avestruz.

% r13: un ave normalmente vuela. r11: un ave que nada normalmente es un
% pingüino. r12: un ave de más de 50 kilos normalmente es un avestruz.
vuela :~ ave.
pinguino :~ ave, nada.
avestruz :~ ave, peso(P), P > 50.

% Mundo cerrado para las dos hipótesis: ningún ave es un pingüino ni un
% avestruz, salvo que una regla lo concluya.
neg pinguino :~ true.
neg avestruz :~ true.
