:- encoding(utf8).

% Pruebas de las inscripciones concurrentes. Cada prueba deja el estado
% como lo encontró. Comparan cantidades y conjuntos de resultados, que no
% dependen del orden de los hilos; inscribir/3 sin mutex no se prueba con
% hilos: la sección 37.7 muestra qué hace.

:- use_module(library(http/http_client)).
:- use_module(library(http/http_json)).
:- use_module('../capitulo-31/inscripciones/datos').

%!  con_estado(:Meta) is semidet.
%
%   Corre Meta y restaura después los datos que cambian.
con_estado(Meta) :-
    estado(Antes),
    call_cleanup(Meta, restaurar(Antes)).

:- begin_tests(concurrente).

% Cuatro alumnos que pueden cursar álgebra y una vacante: una inscripción
% aceptada, cualquiera sea el alumno, y tres rechazadas. Cien veces.
test(una_vacante, [true(Rs == [1-[0]])]) :-
    findall(R, ( between(1, 100, _),
                 carrera(inscribir_seguro, alg, [102, 105, 106, 107], R) ),
            Rs0),
    sort(Rs0, Rs).

test(resultados, [true(Ordenados == [aceptada, rechazada(sin_vacantes)])]) :-
    con_estado(( cambiar_vacantes(alg, -29),
                 simultaneos(inscribir_seguro,
                             [102-alg, 105-alg, 106-alg, 107-alg], Rs) )),
    sort(Rs, Ordenados).

% Ocho hilos con 200 inscripciones rechazadas cada uno: el contador de
% operaciones suma exactamente 1600.
test(contador, [true(D == 1600)]) :-
    con_estado(( operaciones(O0),
                 length(Ids, 8),
                 maplist([Id]>>thread_create(
                                   forall(between(1, 200, _),
                                          inscribir_seguro(101, am1, _)),
                                   Id),
                         Ids),
                 maplist([Id]>>thread_join(Id, true), Ids),
                 operaciones(O),
                 D is O - O0 )).

% Mientras cuatro hilos inscriben, un hilo lector comprueba mil veces que
% los alumnos que cursan y las vacantes suman lo mismo: nunca ve una
% inscripción a medias.
test(lector, [true(Sumas == [4])]) :-
    thread_self(Yo),
    con_estado(( cambiar_vacantes(alg, -26),
                 thread_create(( leer_sumas(1000, S),
                                 thread_send_message(Yo, sumas(S)) ),
                               Lector),
                 simultaneos(inscribir_seguro,
                             [102-alg, 105-alg, 106-alg, 107-alg], _),
                 thread_join(Lector, true) )),
    thread_get_message(sumas(Sumas)).

test(baja, [true(V1-V2 == 29-30)]) :-
    con_estado(( inscribir_seguro(105, alg, aceptada),
                 vacantes(alg, V1),
                 dar_de_baja_seguro(105, alg),
                 vacantes(alg, V2) )).

% El servicio con la ruta nueva: cuatro pedidos simultáneos, una vacante.
test(servicio, [true(Codigos == [201, 409, 409, 409])]) :-
    iniciar_api(Puerto),
    call_cleanup(con_estado(( cambiar_vacantes(alg, -29),
                              simultaneos(inscribir_por_http(Puerto),
                                          [102-alg, 105-alg,
                                           106-alg, 107-alg],
                                          Cs) )),
                 detener_api(Puerto)),
    msort(Cs, Codigos).

:- end_tests(concurrente).

%!  leer_sumas(+N:integer, -Sumas:list(integer)) is det.
%
%   Sumas son los valores distintos de Cursando + Vacantes en álgebra,
%   leídos N veces con ocupacion/3.
leer_sumas(N, Sumas) :-
    findall(S, ( between(1, N, _),
                 ocupacion(alg, C, V),
                 S is C + V ),
            Ss),
    sort(Ss, Sumas).

%!  inscribir_por_http(+Puerto:integer, +Legajo:integer, +Materia:atom,
%!                     -Codigo:integer) is det.
%
%   Hace POST /inscripciones al servicio de Puerto; Codigo es el código de
%   estado de la respuesta.
inscribir_por_http(Puerto, Legajo, Materia, Codigo) :-
    format(atom(Url), "http://127.0.0.1:~w/inscripciones", [Puerto]),
    http_post(Url, json(_{legajo: Legajo, materia: Materia}), _,
              [ status_code(Codigo), json_object(dict) ]).
