:- encoding(utf8).

% Capítulo 37 - Estado compartido: el cupo de una materia, con varios
% hilos que inscriben a la vez.
%
% reservar/3 consulta las vacantes y después las descuenta, como
% inscribir/3 de Inscripciones: con un solo hilo es correcto, y con varios
% dos hilos pueden leer el mismo valor. reservar_con_mutex/3 lo corre con
% un mutex; reservar_en_transaccion/3 dentro de transaction/1, que no
% alcanza; reservar_cas/3 con transaction/3, que verifica el valor leído al
% confirmar. concurrencia/5 corre muchos hilos con una de las versiones.
%
% solo-local: SWISH no permite crear hilos, mutex ni transacciones.
%
%?- concurrencia(reservar_con_mutex, 8, 1000, 100, R).

:- dynamic vacantes/2, inscripto/2, fallo/1.

%!  abrir(+Materia:atom, +N:integer) is det.
%
%   Deja Materia sin inscriptos y con N vacantes.
abrir(Materia, N) :-
    retractall(vacantes(Materia, _)),
    retractall(inscripto(_, Materia)),
    retractall(fallo(_)),
    assertz(vacantes(Materia, N)).

%!  reservar(+Materia:atom, +Legajo:integer, -Resultado) is det.
%
%   Si Materia tiene vacantes, inscribe a Legajo y descuenta una: Resultado
%   es aceptada. Si no, Resultado es rechazada. Correcto con un solo hilo.
reservar(Materia, Legajo, Resultado) :-
    vacantes(Materia, N),
    (   N > 0
    ->  assertz(inscripto(Legajo, Materia)),
        descontar(Materia),
        Resultado = aceptada
    ;   Resultado = rechazada
    ).

%!  descontar(+Materia:atom) is det.
%
%   Resta una a las vacantes de Materia.
descontar(Materia) :-
    retract(vacantes(Materia, N0)),
    N is N0 - 1,
    assertz(vacantes(Materia, N)).

%!  reservar_con_mutex(+Materia:atom, +Legajo:integer, -Resultado) is det.
%
%   reservar/3 con el mutex cupo: un solo hilo a la vez lee y cambia las
%   vacantes.
reservar_con_mutex(Materia, Legajo, Resultado) :-
    with_mutex(cupo, reservar(Materia, Legajo, Resultado)).

%!  reservar_en_transaccion(+Materia:atom, +Legajo:integer, -Resultado)
%!      is det.
%
%   reservar/3 dentro de una transacción: sus cambios se ven todos juntos,
%   o ninguno. No impide que dos transacciones lean el mismo valor.
reservar_en_transaccion(Materia, Legajo, Resultado) :-
    transaction(reservar(Materia, Legajo, Resultado)).

%!  reservar_cas(+Materia:atom, +Legajo:integer, -Resultado) is det.
%
%   Decide la inscripción en una transacción, y la confirma solo si las
%   vacantes siguen siendo las que leyó; si cambiaron, la descarta y vuelve
%   a empezar.
reservar_cas(Materia, Legajo, Resultado) :-
    repeat,
    transaction(decidir(Materia, Legajo, N, Resultado),
                confirmar(Materia, N, Resultado),
                cupo),
    !.

%!  decidir(+Materia:atom, +Legajo:integer, -N:integer, -Resultado) is det.
%
%   N son las vacantes de Materia. Si N es positivo, inscribe a Legajo y
%   Resultado es aceptada; si no, Resultado es rechazada.
decidir(Materia, Legajo, N, Resultado) :-
    vacantes(Materia, N),
    (   N > 0
    ->  assertz(inscripto(Legajo, Materia)),
        Resultado = aceptada
    ;   Resultado = rechazada
    ).

%!  confirmar(+Materia:atom, +N:integer, +Resultado) is semidet.
%
%   Las vacantes de Materia siguen siendo N; si Resultado es aceptada, las
%   reemplaza por N - 1. Falla si otro hilo las cambió.
confirmar(Materia, N, aceptada) :-
    retract(vacantes(Materia, N)),
    N1 is N - 1,
    assertz(vacantes(Materia, N1)).
confirmar(Materia, N, rechazada) :-
    vacantes(Materia, N).

%!  concurrencia(:Reservar, +Hilos:integer, +Intentos:integer,
%!               +Vacantes:integer, -Resumen) is det.
%
%   Abre la materia m con Vacantes lugares y corre Hilos hilos, cada uno con
%   Intentos llamadas a call(Reservar, m, Legajo, _), todas con legajos
%   distintos. Resumen es resumen(Inscriptos, Hechos, Valores, Fallos):
%   cuántos alumnos quedaron inscriptos, cuántos hechos vacantes/2 tiene m,
%   sus valores sin repetir y cuántas llamadas fallaron.
concurrencia(Reservar, Hilos, Intentos, Vacantes,
             resumen(Inscriptos, Hechos, Valores, Fallos)) :-
    abrir(m, Vacantes),
    numlist(1, Hilos, Hs),
    maplist(reservador(Reservar, Intentos), Hs, Ids),
    maplist(thread_join, Ids, _),
    aggregate_all(count, inscripto(_, m), Inscriptos),
    aggregate_all(count, vacantes(m, _), Hechos),
    findall(V, vacantes(m, V), Vs),
    sort(Vs, Valores),
    aggregate_all(count, fallo(_), Fallos).

%!  reservador(:Reservar, +Intentos:integer, +H:integer, -Id) is det.
%
%   Id es un hilo nuevo que intenta inscribir en m, con Reservar, a los
%   legajos H * 100000 + I, para I de 1 a Intentos. Anota en fallo/1 cada
%   legajo cuya llamada falla o lanza una excepción.
reservador(Reservar, Intentos, H, Id) :-
    thread_create(forall(between(1, Intentos, I),
                         ( Legajo is H * 100000 + I,
                           intentar(Reservar, Legajo) )),
                  Id).

%!  intentar(:Reservar, +Legajo:integer) is det.
%
%   Llama a call(Reservar, m, Legajo, _); si falla o lanza una excepción,
%   agrega fallo(Legajo).
intentar(Reservar, Legajo) :-
    (   catch(call(Reservar, m, Legajo, _), _, fail)
    ->  true
    ;   assertz(fallo(Legajo))
    ).
