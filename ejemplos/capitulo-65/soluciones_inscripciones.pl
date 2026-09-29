:- encoding(utf8).

% Capítulo 65 - Soluciones de los ejercicios 4 y 11: Inscripciones.
%
% excepciones/3 da los requisitos que un alumno cumple solo por una
% excepción. inscripcion_con_criterio/4 es inscripcion_rebatible/3 con el
% criterio de superioridad como argumento; la base agrega que la regla de
% la autorización prevalece sobre el refutador de quien cursa de nuevo una
% materia desaprobada.
%
% solo-local: carga módulos propios, y SWISH no los admite.
%
%?- excepciones(105, am2, Rs).
%?- inscripcion_con_criterio([declarada, especificidad], 102, ssl, R).

:- ensure_loaded(correlativas).

% La autorización prevalece sobre el refutador.
superior((cumple(L, M, R) :~ correlativa(M, R), autorizacion(L, M, R)),
         (neg cumple(L, M, R) :^ correlativa(M, R), cursa(L, R),
                                 desaprobada(L, R))).

%!  excepciones(+Legajo:integer, +Materia:atom, -Requisitos:list) is det.
%
%   Requisitos son las correlativas de Materia que el alumno Legajo cumple
%   solo por una excepción: presumiblemente, y no en forma estricta.
excepciones(Legajo, Materia, Requisitos) :-
    findall(R,
            ( correlativa(Materia, R),
              respuesta([especificidad], cumple(Legajo, Materia, R),
                        presumiblemente_si) ),
            Requisitos).

%!  inscripcion_con_criterio(+Criterio:list, +Legajo:integer,
%!      +Materia:atom, -Resultado) is det.
%
%   Resultado es el de inscripcion_rebatible/3, con Criterio para
%   comparar las reglas de cada requisito.
inscripcion_con_criterio(Criterio, Legajo, Materia, Resultado) :-
    inscripcion_posible(Legajo, Materia, Resultado0),
    (   Resultado0 = rechazada(falta(_))
    ->  con_criterio(Criterio, Legajo, Materia, Resultado)
    ;   Resultado = Resultado0
    ).

%!  con_criterio(+Criterio:list, +Legajo:integer, +Materia:atom,
%!      -Resultado) is det.
%
%   por_requisitos/3 con Criterio.
con_criterio(Criterio, Legajo, Materia, Resultado) :-
    findall(R-V,
            ( correlativa(Materia, R),
              respuesta(Criterio, cumple(Legajo, Materia, R), V) ),
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

%!  decisiones(-Antes:list, -Despues:list) is det.
%
%   Con una autorización para que Bruno curse Sintaxis sin Álgebra, Antes
%   y Despues son las decisiones sobre su inscripción en Sintaxis con los
%   dos criterios, antes y después de que se inscriba de nuevo en Álgebra.
%   Deja los datos como estaban.
decisiones(Antes, Despues) :-
    estado(E),
    setup_call_cleanup(
        assertz(autorizacion(102, ssl, alg)),
        ( las_dos(Antes),
          inscribir(102, alg, aceptada),
          las_dos(Despues) ),
        ( retract(autorizacion(102, ssl, alg)),
          restaurar(E) )).

%!  las_dos(-Decisiones:list) is det.
%
%   Decisiones son las de Bruno en Sintaxis con cada criterio.
las_dos(Decisiones) :-
    findall(C-R,
            ( member(C, [[especificidad], [declarada, especificidad]]),
              inscripcion_con_criterio(C, 102, ssl, R) ),
            Decisiones).
