:- encoding(utf8).

% Capítulo 65 - Versiones 1 y 2: reglas estrictas y rebatibles, y la regla
% más específica.
%
% La base de las aves, con el motor de rebatible.pl. Los hechos y las
% reglas estrictas son cláusulas comunes; las reglas rebatibles se
% escriben con :~. El triángulo de Tweety: las aves normalmente vuelan,
% los pingüinos normalmente no, y todo pingüino es un ave. El diamante de
% Drácula: los murciélagos normalmente vuelan, los muertos normalmente no.
% La estudiante Juana: una cadena de reglas rebatibles que no hace a una
% regla más específica que otra, porque uno de sus eslabones está
% derrotado.
%
% solo-local: carga el módulo rebatible, y SWISH no admite módulos propios.
%
%?- respuesta([], vuela(opus), R).
%?- respuesta([especificidad], vuela(opus), R).
%?- respuesta([especificidad], vuela(dracula), R).
%?- respuesta([declarada, especificidad], vuela(dracula), R).

:- use_module(rebatible).

% pinguino(X): X es un pingüino.
pinguino(opus).

%!  ave(?X) is nondet.
%
%   X es un ave: Tweety, o cualquier pingüino.
ave(tweety).
ave(X) :-
    pinguino(X).

% Las aves normalmente vuelan; los pingüinos normalmente no.
vuela(X) :~ ave(X).
neg vuela(X) :~ pinguino(X).

% murcielago(X): X es un murciélago.
murcielago(rufo).
murcielago(dracula).

% muerto(X): X está muerto.
muerto(dracula).

%!  mamifero(?X) is nondet.
%
%   X es un mamífero: todo murciélago lo es.
mamifero(X) :-
    murcielago(X).

% Los mamíferos normalmente no vuelan; los murciélagos normalmente sí; los
% muertos normalmente no. Entre las dos últimas reglas, prevalece la de
% los muertos.
neg vuela(X) :~ mamifero(X).
vuela(X) :~ murcielago(X).
neg vuela(X) :~ muerto(X).
superior((neg vuela(X) :~ muerto(X)), (vuela(X) :~ murcielago(X))).

% estudiante(X): X es estudiante universitario.
estudiante(juana).

% empleado(X): X tiene un empleo.
empleado(juana).

% Los estudiantes normalmente son adultos y normalmente no tienen empleo;
% los adultos normalmente lo tienen. Quien tiene empleo normalmente se
% mantiene solo; un estudiante, normalmente no.
adulto(X) :~ estudiante(X).
neg empleado(X) :~ estudiante(X).
empleado(X) :~ adulto(X).
se_mantiene(X) :~ empleado(X).
neg se_mantiene(X) :~ estudiante(X).
