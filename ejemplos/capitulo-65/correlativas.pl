:- encoding(utf8).

% Capítulo 65 - Versión 5: excepciones en las correlativas de Inscripciones.
%
% Carga los módulos datos y reglas del capítulo 31 sin cambiarlos. Cada
% correlativa se decide con reglas rebatibles: un requisito aprobado se
% cumple en forma estricta; uno no aprobado normalmente no se cumple, salvo
% que el alumno lo esté cursando o que el departamento lo haya autorizado;
% y quien cursa de nuevo un requisito que desaprobó podría no cumplirlo.
% inscripcion_rebatible/3 es inscripcion_posible/3 del capítulo 31 con esa
% decisión en lugar del rechazo por falta de una correlativa: la parte
% procedural queda en Prolog común.
%
% solo-local: carga módulos propios, y SWISH no los admite.
%
%?- respuesta([especificidad], cumple(105, am2, am1), R).
%?- inscripcion_rebatible(105, am2, R).
%?- inscripcion_rebatible(101, bd, R).

:- use_module('../capitulo-31/inscripciones/datos').
:- use_module('../capitulo-31/inscripciones/reglas').
:- use_module(rebatible).

:- dynamic autorizacion/3.

% autorizacion(Legajo, Materia, Requisito): el departamento autorizó al
% alumno Legajo a cursar Materia sin haber aprobado Requisito. Es dinámico:
% el departamento agrega autorizaciones durante el año.
autorizacion(105, am2, alg).

%!  cumple(?Legajo:integer, ?Materia:atom, ?Requisito:atom) is nondet.
%
%   El alumno Legajo cumple el Requisito de Materia en forma estricta:
%   lo aprobó.
cumple(Legajo, Materia, Requisito) :-
    correlativa(Materia, Requisito),
    aprobada(Legajo, Requisito, _).

%!  desaprobada(?Legajo:integer, ?Materia:atom) is nondet.
%
%   El alumno Legajo tiene una nota menor que la mínima en Materia.
desaprobada(Legajo, Materia) :-
    inscripcion(Legajo, Materia, nota(Nota)),
    nota_minima(Minima),
    Nota < Minima.

% Un requisito no aprobado normalmente no se cumple; sí, si el alumno lo
% está cursando o si está autorizado.
neg cumple(_L, M, R) :~ correlativa(M, R).
cumple(L, M, R) :~ correlativa(M, R), cursa(L, R).
cumple(L, M, R) :~ correlativa(M, R), autorizacion(L, M, R).

% Quien cursa de nuevo un requisito que desaprobó podría no cumplirlo.
neg cumple(L, M, R) :^ correlativa(M, R), cursa(L, R), desaprobada(L, R).

%!  inscripcion_rebatible(+Legajo:integer, +Materia:atom, -Resultado) is det.
%
%   Resultado es el de inscripcion_posible/3, salvo cuando esta rechaza
%   por una correlativa: entonces es rechazada(falta(R)) con el primer
%   requisito que presumiblemente no se cumple, a_revisar(R) con el primero
%   del que las reglas no concluyen nada, rechazada(sin_vacantes), o
%   condicional(Rs), con los requisitos que se dan por cumplidos por una
%   excepción.
inscripcion_rebatible(Legajo, Materia, Resultado) :-
    inscripcion_posible(Legajo, Materia, Resultado0),
    (   Resultado0 = rechazada(falta(_))
    ->  por_requisitos(Legajo, Materia, Resultado)
    ;   Resultado = Resultado0
    ).

%!  por_requisitos(+Legajo:integer, +Materia:atom, -Resultado) is det.
%
%   Resultado decide la inscripción del alumno Legajo en Materia por la
%   respuesta de las reglas sobre cada correlativa.
por_requisitos(Legajo, Materia, Resultado) :-
    findall(R-V,
            ( correlativa(Materia, R),
              respuesta([especificidad], cumple(Legajo, Materia, R), V) ),
            Vs),
    (   member(R-presumiblemente_no, Vs)
    ->  Resultado = rechazada(falta(R))
    ;   member(R-sin_conclusion, Vs)
    ->  Resultado = a_revisar(R)
    ;   vacantes(Materia, 0)
    ->  Resultado = rechazada(sin_vacantes)
    ;   findall(R, member(R-presumiblemente_si, Vs), Rs),
        Resultado = condicional(Rs)
    ).

%!  costo(+Version:atom, -Inferencias:integer) is det.
%
%   Inferencias son las que cuesta decidir todas las combinaciones de un
%   alumno y una materia con la Version dada: posible, la del capítulo 31,
%   o rebatible, la de este capítulo.
costo(Version, Inferencias) :-
    must_be(oneof([posible, rebatible]), Version),
    findall(L-M, ( alumno(L, _, _, _), materia(M, _, _) ), Pares),
    statistics(inferences, I0),
    forall(member(L-M, Pares), decidir(Version, L, M)),
    statistics(inferences, I),
    Inferencias is I - I0.

%!  decidir(+Version:atom, +Legajo:integer, +Materia:atom) is det.
%
%   Decide la inscripción de Legajo en Materia con la Version dada.
decidir(posible, Legajo, Materia) :-
    inscripcion_posible(Legajo, Materia, _).
decidir(rebatible, Legajo, Materia) :-
    inscripcion_rebatible(Legajo, Materia, _).
