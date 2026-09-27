:- encoding(utf8).

% Capítulo 19 - Soluciones de los ejercicios 10 y 11: las reglas de rechazo
% del proyecto.
%
% Ejercicio 10: por_que/2 escribe la prueba de cada motivo de rechazo con
% explicar/2. Ejercicio 11: la regla v5, que concluye aceptada cuando ningún
% rechazo se prueba, y se_acepta/2. Los datos y las reglas son los de
% inscripciones.pl; el archivo repite lo que las reglas necesitan.
%
%?- por_que(102, am2).
%?- se_acepta(104, ssl).

:- op(800, xfx, entonces).
:- op(790, fx, si).
:- op(780, xfy, y).
:- op(770, fy, no).

% correlativa(Materia, Requisito): para cursar Materia hay que aprobar
% Requisito.
correlativa(am2, am1).
correlativa(am2, alg).
correlativa(pp,  log).
correlativa(ssl, log).
correlativa(ssl, alg).
correlativa(bd,  pp).
correlativa(bd,  ssl).

% inscripcion(Legajo, Materia, Estado): el alumno se inscribió en la materia;
% Estado es cursando, o nota(N) con la nota final N, de 1 a 10.
inscripcion(101, am1, nota(8)).
inscripcion(101, alg, nota(9)).
inscripcion(101, log, nota(10)).
inscripcion(101, am2, nota(7)).
inscripcion(101, pp,  cursando).
inscripcion(102, am1, nota(4)).
inscripcion(102, log, nota(6)).
inscripcion(102, alg, nota(2)).
inscripcion(103, am1, nota(7)).
inscripcion(103, alg, nota(5)).
inscripcion(103, am2, cursando).
inscripcion(104, log, nota(9)).
inscripcion(104, alg, nota(7)).
inscripcion(104, pp,  nota(8)).
inscripcion(105, am1, cursando).
inscripcion(106, log, nota(3)).
inscripcion(106, am1, nota(6)).

% vacantes(Materia, N): quedan N lugares en la materia.
vacantes(am1, 30).
vacantes(alg, 30).
vacantes(log, 0).
vacantes(am2, 25).
vacantes(pp,  25).
vacantes(ssl, 20).
vacantes(bd,  15).

%!  nota_minima(-N:integer) is det.
%
%   N es la nota mínima para aprobar una materia.
nota_minima(6).

%!  aprobada(?Legajo:integer, ?Materia:atom, ?Nota:integer) is nondet.
%
%   El alumno Legajo aprobó Materia con Nota.
aprobada(Legajo, Materia, Nota) :-
    inscripcion(Legajo, Materia, nota(Nota)),
    nota_minima(Minima),
    Nota >= Minima.

%!  cursa(?Legajo:integer, ?Materia:atom) is nondet.
%
%   El alumno Legajo está cursando Materia, todavía sin nota.
cursa(Legajo, Materia) :-
    inscripcion(Legajo, Materia, cursando).

% regla(Nombre, si Condiciones entonces Conclusion): los motivos que rechazan
% una inscripción, y la regla v5 del ejercicio 11, que la acepta cuando
% ningún rechazo se puede probar.
regla(v1, si materia(M) y aprobada(M) entonces rechazada(ya_aprobada)).
regla(v2, si materia(M) y cursando(M) entonces rechazada(ya_la_cursa)).
regla(v3, si requisito(R) y no aprobada(R) entonces rechazada(falta(R))).
regla(v4, si vacantes(0) entonces rechazada(sin_vacantes)).
regla(v5, si no rechazada(_) entonces aceptada).

%!  situacion(+Legajo:integer, +Materia:atom, -Observaciones:list) is det.
%
%   Observaciones describe la situación del alumno Legajo frente a Materia
%   en el vocabulario de las reglas.
situacion(Legajo, Materia, Observaciones) :-
    findall(Obs, observacion(Legajo, Materia, Obs), Observaciones).

%!  observacion(+Legajo:integer, +Materia:atom, -Obs) is nondet.
%
%   Obs es una observación sobre el alumno Legajo y la materia Materia.
observacion(_, Materia, materia(Materia)).
observacion(Legajo, _, aprobada(M)) :-
    aprobada(Legajo, M, _).
observacion(Legajo, _, cursando(M)) :-
    cursa(Legajo, M).
observacion(_, Materia, requisito(R)) :-
    correlativa(Materia, R).
observacion(_, Materia, vacantes(N)) :-
    vacantes(Materia, N).

%!  prueba(+Meta, +Observaciones:list, -Arbol) is nondet.
%
%   El intérprete del proyecto: el de la sección 19.4 con la cláusula para
%   no. Meta debe llegar sin variables libres, salvo dentro de no: no Meta
%   pregunta si ninguna instancia de Meta se puede probar.
prueba(A y B, Observaciones, ArbolA y ArbolB) :-
    prueba(A, Observaciones, ArbolA),
    prueba(B, Observaciones, ArbolB).
prueba(no Meta, Observaciones, no Meta) :-
    \+ prueba(Meta, Observaciones, _).
prueba(X > Y, _, X > Y) :-
    X > Y.
prueba(X < Y, _, X < Y) :-
    X < Y.
prueba(Meta, Observaciones, observado(Meta)) :-
    member(Meta, Observaciones).
prueba(Meta, Observaciones, deducido(Meta, Regla, Arbol)) :-
    regla(Regla, si Condiciones entonces Meta),
    prueba(Condiciones, Observaciones, Arbol).

% --- Ejercicio 10 -------------------------------------------------------------

%!  por_que(+Legajo:integer, +Materia:atom) is det.
%
%   Escribe la prueba de cada motivo por el que se rechaza la inscripción
%   del alumno Legajo en Materia, con explicar/2. No escribe nada si no hay
%   ningún motivo.
por_que(Legajo, Materia) :-
    situacion(Legajo, Materia, Observaciones),
    forall(prueba(rechazada(_), Observaciones, Arbol),
           explicar(Arbol, 0)).

%!  explicar(+Arbol, +Sangria:integer) is det.
%
%   Escribe Arbol a partir de la columna Sangria: el explicar/2 del
%   ejercicio 7, con una cláusula para no.
explicar(A y B, Sangria) :-
    explicar(A, Sangria),
    explicar(B, Sangria).
explicar(observado(M), Sangria) :-
    format("~t~*|~w: observado~n", [Sangria, M]).
explicar(no M, Sangria) :-
    format("~t~*|no ~w: no se prueba~n", [Sangria, M]).
explicar(X > Y, Sangria) :-
    format("~t~*|~w > ~w: se cumple~n", [Sangria, X, Y]).
explicar(X < Y, Sangria) :-
    format("~t~*|~w < ~w: se cumple~n", [Sangria, X, Y]).
explicar(deducido(M, Regla, Arbol), Sangria) :-
    format("~t~*|~w: por ~w~n", [Sangria, M, Regla]),
    Siguiente is Sangria + 2,
    explicar(Arbol, Siguiente).

% --- Ejercicio 11 -------------------------------------------------------------

%!  se_acepta(+Legajo:integer, +Materia:atom) is semidet.
%
%   La inscripción del alumno Legajo en Materia se acepta: la regla v5 se
%   prueba, porque ningún rechazada(Motivo) se puede probar.
se_acepta(Legajo, Materia) :-
    situacion(Legajo, Materia, Observaciones),
    once(prueba(aceptada, Observaciones, _)).
