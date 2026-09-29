:- encoding(utf8).

% Capítulo 37 - Soluciones de los ejercicios 14 y 15, sobre Inscripciones.
%
% inscripciones_finas/1 atiende POST /inscripciones con el mutex solo
% alrededor de la inscripción: el cuerpo se lee y la respuesta se escribe
% fuera de él. Se declara después que la ruta de concurrente.pl, y la
% reemplaza. inscribir_cas/3 inscribe con transaction/3: la restricción
% verifica, al confirmar, que los datos sigan siendo coherentes.
%
% solo-local: SWISH no admite módulos propios, hilos ni servidores.
%
%?- carrera(inscribir_cas, alg, [102, 105, 106, 107], R).

:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_json)).
:- use_module(concurrente).
:- use_module('../capitulo-31/inscripciones/datos').
:- use_module('../capitulo-31/inscripciones/reglas').

:- http_handler(root(inscripciones), inscripciones_finas, [method(post)]).

% --- Ejercicio 14 ----------------------------------------------------------

%!  inscripciones_finas(+Pedido) is det.
%
%   POST /inscripciones: las mismas respuestas que el manejador de api.pl,
%   con los errores convertidos por api:responder/1, y el mutex tomado solo
%   por inscribir_seguro/3.
inscripciones_finas(Pedido) :-
    api:responder(user:inscribir_pedido(Pedido)).

%!  inscribir_pedido(+Pedido) is semidet.
%
%   Lee el legajo y la materia del cuerpo de Pedido, los inscribe con
%   inscribir_seguro/3 y responde. Falla si al cuerpo le falta un campo.
inscribir_pedido(Pedido) :-
    http_read_json_dict(Pedido, Datos, [value_string_as(atom)]),
    _{legajo: Legajo, materia: Materia} :< Datos,
    inscribir_seguro(Legajo, Materia, Respuesta),
    api:resultado_json(Respuesta, Resultado, Codigo),
    reply_json_dict(Resultado, [status(Codigo)]).

% --- Ejercicio 15 ----------------------------------------------------------

%!  inscribir_cas(+Legajo:integer, +Materia:atom, -Resultado) is det.
%
%   inscribir/3 dentro de transaction/3: se ejecuta sin mutex, y al
%   confirmar se verifica con el mutex inscripciones que los datos sean
%   coherentes; si otra inscripción se confirmó mientras tanto, no lo son,
%   y se vuelve a empezar.
inscribir_cas(Legajo, Materia, Resultado) :-
    repeat,
    transaction(inscribir(Legajo, Materia, Resultado),
                coherentes(Materia),
                inscripciones),
    !.

%!  coherentes(+Materia:atom) is semidet.
%
%   Materia tiene un solo hecho vacantes/2, no negativo, y hay un solo
%   hecho operaciones/1.
coherentes(Materia) :-
    aggregate_all(count, vacantes(Materia, _), 1),
    vacantes(Materia, V),
    V >= 0,
    aggregate_all(count, operaciones(_), 1).
