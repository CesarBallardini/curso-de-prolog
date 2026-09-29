:- encoding(utf8).

% Capítulo 65 - Versión 6: la anticipación de los rivales.
%
% Dos cadenas de reglas rebatibles sobre el pago de la matrícula. Un
% alumno de intercambio normalmente es un alumno regular, y un regular
% normalmente paga; pero un alumno de intercambio normalmente no paga. Un
% becario normalmente está inscripto en una carrera, y un inscripto
% normalmente paga; pero un becario normalmente no paga. Lucía es de
% intercambio y becaria. Cada regla que dice que no paga supera a la de
% su propia cadena, pero no a la de la otra, y sin anticipación la base no
% concluye nada. Con anticipación, la regla de los regulares queda
% anticipada por la de los alumnos de intercambio, y la de los inscriptos
% por la de los becarios: Lucía, presumiblemente, no paga.
%
% solo-local: carga el módulo rebatible, y SWISH no admite módulos propios.
%
%?- respuesta([especificidad], paga(lucia), R).
%?- respuesta([anticipacion, especificidad], paga(lucia), R).

:- use_module(rebatible).

% intercambio(X): X es un alumno de intercambio.
intercambio(lucia).
intercambio(marcos).

% becario(X): X tiene una beca.
becario(lucia).

regular(X) :~ intercambio(X).
inscripto(X) :~ becario(X).
paga(X) :~ regular(X).
paga(X) :~ inscripto(X).
neg paga(X) :~ intercambio(X).
neg paga(X) :~ becario(X).

%!  medir(+Criterio:list, +Meta, -Inferencias:integer) is det.
%
%   Inferencias son las que cuesta la respuesta sobre Meta con Criterio,
%   después de una primera llamada que carga lo que haga falta.
medir(Criterio, Meta, Inferencias) :-
    respuesta(Criterio, Meta, _),
    statistics(inferences, I0),
    respuesta(Criterio, Meta, _),
    statistics(inferences, I),
    Inferencias is I - I0.
