:- encoding(utf8).

% Cada prueba deja el estado como lo encontró, y compara cantidades o
% conjuntos de resultados.

:- use_module(library(http/http_client)).

%!  post(+Puerto:integer, +Cuerpo:dict, -Codigo:integer) is det.
%
%   Hace POST /inscripciones con Cuerpo al servicio de Puerto; Codigo es
%   el código de estado.
post(Puerto, Cuerpo, Codigo) :-
    format(atom(Url), "http://127.0.0.1:~w/inscripciones", [Puerto]),
    http_post(Url, json(Cuerpo), _,
              [ status_code(Codigo), json_object(dict) ]).

%!  pedido_de(+Puerto:integer, +Legajo:integer, +Materia:atom,
%!            -Codigo:integer) is det.
%
%   Codigo es el de la inscripción de Legajo en Materia por el servicio.
pedido_de(Puerto, Legajo, Materia, Codigo) :-
    post(Puerto, _{legajo: Legajo, materia: Materia}, Codigo).

:- begin_tests(soluciones_inscripciones).

test(cas_una_vacante, [true(Rs == [1-[0]])]) :-
    findall(R, ( between(1, 100, _),
                 carrera(inscribir_cas, alg, [102, 105, 106, 107], R) ),
            Rs0),
    sort(Rs0, Rs).

test(cas_de_a_uno, [true(R-V == aceptada-29)]) :-
    estado(Antes),
    call_cleanup(( inscribir_cas(105, alg, R),
                   vacantes(alg, V) ),
                 restaurar(Antes)).

test(servicio_fino, [true(Cs-Incompleto == [201, 409, 409, 409]-400)]) :-
    iniciar_api(P),
    estado(Antes),
    call_cleanup(( cambiar_vacantes(alg, -29),
                   simultaneos(pedido_de(P),
                               [102-alg, 105-alg, 106-alg, 107-alg], Cs0),
                   msort(Cs0, Cs),
                   post(P, _{legajo: 102}, Incompleto) ),
                 ( restaurar(Antes),
                   detener_api(P) )).

test(coherentes) :-
    coherentes(alg).

% Con las vacantes en negativo, la restricción falla.
test(incoherentes, [true(C == false)]) :-
    estado(Antes),
    call_cleanup(( vacantes(alg, V),
                   Cambio is -V - 1,
                   cambiar_vacantes(alg, Cambio),
                   (   coherentes(alg)
                   ->  C = true
                   ;   C = false
                   ) ),
                 restaurar(Antes)).

:- end_tests(soluciones_inscripciones).
