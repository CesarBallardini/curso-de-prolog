:- encoding(utf8).

% Capítulo 29 - Inscripciones, módulo puente: los datos que cruzan a Python.
%
% Janus convierte listas, números, átomos, cadenas, pares y dicts, pero no
% los términos compuestos como rechazada(falta(am1)) o estado(...). Este
% módulo convierte las respuestas del programa en datos que Janus puede
% llevar a Python: dicts con claves fijas, y los motivos como texto. El
% estado viaja envuelto en prolog/1, como un objeto que Python solo guarda y
% devuelve.
%
% solo-local: SWISH no admite módulos propios ni ejecuta Python.
%
%?- ranking_py(Filas).

:- module(puente,
          [ ranking_py/1,
            materias_py/1,
            inscribir_py/3,
            estado_py/1,
            restaurar_py/1
          ]).

:- use_module(datos).
:- use_module(reglas).
:- use_module(informes).

%!  ranking_py(-Filas:list(dict)) is det.
%
%   Filas es el ranking, de mayor a menor promedio: un dict por alumno, con
%   las claves legajo, nombre y promedio.
ranking_py(Filas) :-
    ranking(Ranking),
    maplist(fila_del_ranking, Ranking, Filas).

%!  fila_del_ranking(+Par:pair, -Fila:dict) is det.
%
%   Fila es el dict del par Legajo-Promedio del ranking.
fila_del_ranking(Legajo-Promedio,
                 _{legajo: Legajo, nombre: Nombre, promedio: Promedio}) :-
    alumno(Legajo, Nombre, _, _).

%!  materias_py(-Materias:list(dict)) is det.
%
%   Materias son las materias, en el orden de los hechos: un dict por
%   materia, con las claves codigo, nombre, anio e inscriptos, la cantidad
%   de alumnos inscriptos.
materias_py(Materias) :-
    findall(_{codigo: C, nombre: N, anio: A, inscriptos: K},
            ( materia(C, N, A),
              inscriptos(C, Legajos),
              length(Legajos, K) ),
            Materias).

%!  inscribir_py(+Legajo:integer, +Materia:atom, -Resultado:dict) is det.
%
%   Inscribe al alumno Legajo en Materia, como inscribir/3. Resultado es
%   _{aceptada: true} o _{aceptada: false, motivo: Texto}; true y false se
%   escriben @(true) y @(false), que Janus convierte en los booleanos de
%   Python.
inscribir_py(Legajo, Materia, Resultado) :-
    inscribir(Legajo, Materia, Respuesta),
    resultado_py(Respuesta, Resultado).

%!  resultado_py(+Respuesta, -Resultado:dict) is det.
%
%   Resultado es el dict de una respuesta de inscribir/3.
resultado_py(aceptada, _{aceptada: @(true)}).
resultado_py(rechazada(Motivo), _{aceptada: @(false), motivo: Texto}) :-
    term_string(Motivo, Texto).

%!  estado_py(-Estado) is det.
%
%   Estado es el estado del programa, envuelto en prolog/1: Python recibe un
%   objeto janus.Term, que puede guardar y devolver sin mirarlo.
estado_py(prolog(Estado)) :-
    estado(Estado).

%!  restaurar_py(+Estado) is det.
%
%   Vuelve al Estado que dio estado_py/1.
restaurar_py(Estado) :-
    restaurar(Estado).
