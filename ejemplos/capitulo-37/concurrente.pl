:- encoding(utf8).

% Capítulo 37 - Inscripciones con varios hilos.
%
% Carga los módulos del capítulo 31 sin cambiarlos. inscribir/3 lee las
% vacantes y el contador de operaciones y después los cambia: con varios
% hilos, dos inscripciones pueden leer los mismos valores. carrera/4
% repite la misma situación muchas veces: varios alumnos se inscriben a la
% vez en una materia con una sola vacante. inscribir_seguro/3 y
% dar_de_baja_seguro/2 hacen las mismas operaciones con el mutex
% inscripciones, y el servicio web usa ese mismo mutex en su ruta de
% inscripción. Cargar este módulo agrega esa ruta al servicio de api.pl.
%
% solo-local: SWISH no admite módulos propios, hilos ni servidores.
%
%?- carrera(inscribir_seguro, alg, [102, 105, 106, 107], Resultados).

:- module(concurrente,
          [ inscribir_seguro/3,
            dar_de_baja_seguro/2,
            ocupacion/3,
            simultaneos/3,
            carrera/4
          ]).

:- reexport('../capitulo-31/inscripciones/api',
            [iniciar_api/1, detener_api/1]).

:- meta_predicate
    simultaneos(3, +, -),
    carrera(3, +, +, -).

:- use_module(library(http/http_dispatch)).
:- use_module('../capitulo-31/inscripciones/datos').
:- use_module('../capitulo-31/inscripciones/reglas').

:- http_handler(root(inscripciones), inscripciones_seguras, [method(post)]).

%!  inscribir_seguro(+Legajo:integer, +Materia:atom, -Resultado) is det.
%
%   inscribir/3 con el mutex inscripciones, que impide que dos
%   inscripciones o bajas se superpongan, y dentro de una transacción: los
%   hilos que solo leen ven los datos de antes o los de después, nunca los
%   de la mitad.
inscribir_seguro(Legajo, Materia, Resultado) :-
    with_mutex(inscripciones,
               transaction(inscribir(Legajo, Materia, Resultado))).

%!  dar_de_baja_seguro(+Legajo:integer, +Materia:atom) is semidet.
%
%   dar_de_baja/2 con el mismo mutex, dentro de una transacción.
dar_de_baja_seguro(Legajo, Materia) :-
    with_mutex(inscripciones,
               transaction(dar_de_baja(Legajo, Materia))).

%!  ocupacion(+Materia:atom, -Cursando:integer, -Vacantes:integer) is det.
%
%   Cursando es la cantidad de alumnos que cursan Materia y Vacantes sus
%   vacantes, leídas las dos en el mismo estado de la base de datos.
ocupacion(Materia, Cursando, Vacantes) :-
    snapshot(( aggregate_all(count, inscripcion(_, Materia, cursando),
                             Cursando),
               vacantes(Materia, Vacantes) )).

%!  inscripciones_seguras(+Pedido) is det.
%
%   POST /inscripciones: el manejador del capítulo 31, api:inscripciones/1,
%   con el mutex inscripciones y dentro de una transacción, como
%   inscribir_seguro/3. Reemplaza al de api.pl, porque se declara para la
%   misma ruta después.
inscripciones_seguras(Pedido) :-
    with_mutex(inscripciones,
               transaction(api:inscripciones(Pedido))).

%!  simultaneos(:Inscribir, +Pedidos:list, -Resultados:list) is det.
%
%   Corre call(Inscribir, L, M, R) para cada L-M de Pedidos, cada uno en su
%   propio hilo, todos a la vez. Resultados tiene un R por pedido, en el
%   orden de Pedidos, o fallo si la llamada falló o lanzó una excepción.
simultaneos(Inscribir, Pedidos, Resultados) :-
    message_queue_create(Cola),
    maplist(lanzar(Inscribir, Cola), Pedidos, Ids),
    maplist(thread_join, Ids, _),
    maplist(recoger(Cola), Pedidos, Resultados),
    message_queue_destroy(Cola).

%!  lanzar(:Inscribir, +Cola, +Pedido, -Id) is det.
%
%   Id es un hilo que atiende Pedido, L-M, y deja en Cola el par L-R.
lanzar(Inscribir, Cola, L-M, Id) :-
    thread_create(( (   catch(call(Inscribir, L, M, R), _, fail)
                    ->  true
                    ;   R = fallo
                    ),
                    thread_send_message(Cola, L-R) ),
                  Id).

%!  recoger(+Cola, +Pedido, -R) is det.
%
%   R es el resultado del Pedido L-M, tomado de Cola.
recoger(Cola, L-_, R) :-
    thread_get_message(Cola, L-R).

%!  carrera(:Inscribir, +Materia:atom, +Legajos:list, -Resultado) is det.
%
%   Deja una vacante en Materia e inscribe a la vez a todos los Legajos con
%   Inscribir. Resultado es Aceptadas-Vacantes: cuántas inscripciones de
%   Materia quedaron cursando y la lista de valores de vacantes/2. Al
%   terminar restaura el estado anterior.
carrera(Inscribir, Materia, Legajos, Aceptadas-Vacantes) :-
    estado(Antes),
    vacantes(Materia, N),
    Cambio is 1 - N,
    cambiar_vacantes(Materia, Cambio),
    findall(L-Materia, member(L, Legajos), Pedidos),
    simultaneos(Inscribir, Pedidos, _),
    aggregate_all(count, inscripcion(_, Materia, cursando), Aceptadas),
    findall(V, vacantes(Materia, V), Vacantes),
    restaurar(Antes).
