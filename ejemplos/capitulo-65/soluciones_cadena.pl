:- encoding(utf8).

% Capítulo 65 - Solución del ejercicio 8: una cadena de clases.
%
% La clase I+1 está incluida en la clase I, por una regla estricta, y cada
% clase tiene normalmente la propiedad contraria a la de la anterior: las
% clases pares la tienen, las impares no. El individuo a está en la última
% clase. cadena/1 genera la base con assertz/1; medir/3 cuenta las
% inferencias de la respuesta sobre a.
%
% solo-local: carga el módulo rebatible, y SWISH no admite módulos propios.
%
%?- medir(4, R, I).

:- use_module(rebatible).

:- dynamic clase/2.

%!  cadena(+N:integer) is det.
%
%   Reemplaza la base por una cadena de N+1 clases, de la 0 a la N, con el
%   individuo a en la clase N.
cadena(N) :-
    must_be(nonneg, N),
    retractall(clase(_, _)),
    retractall(tiene(_) :~ _),
    retractall(neg tiene(_) :~ _),
    forall(between(1, N, J),
           ( I is J - 1,
             assertz((clase(I, X) :- clase(J, X))) )),
    assertz(clase(N, a)),
    forall(between(0, N, I),
           (   I mod 2 =:= 0
           ->  assertz((tiene(X) :~ clase(I, X)))
           ;   assertz((neg tiene(X) :~ clase(I, X)))
           )).

%!  medir(+N:integer, -Respuesta, -Inferencias:integer) is det.
%
%   Respuesta es lo que la cadena de N+1 clases dice de tiene(a), e
%   Inferencias lo que cuesta obtenerlo.
medir(N, Respuesta, Inferencias) :-
    cadena(N),
    statistics(inferences, I0),
    respuesta([especificidad], tiene(a), Respuesta),
    statistics(inferences, I),
    Inferencias is I - I0.
