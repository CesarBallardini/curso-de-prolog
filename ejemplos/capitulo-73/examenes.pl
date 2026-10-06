:- encoding(utf8).

% Capítulo 73 - El calendario de exámenes como proyecto del capítulo 72.
%
% Cada materia de Inscripciones tiene un examen que dura un día; cada día
% hay tantas aulas como indica el llamado, y cada aula toma un examen por
% día; y un examen va después del de cada una de sus correlativas, para
% que un alumno pueda rendir las dos en el mismo llamado. Así planteado,
% el llamado es un proyecto de tareas.pl: los exámenes son las tareas, las
% aulas los procesadores y las correlativas las precedencias, y el
% planificador del capítulo 72 da el llamado más corto.
%
% Lo que ese modelo no puede expresar son los conflictos de los alumnos:
% dos materias con un alumno inscripto en común no pueden rendirse el
% mismo día (conflicto/2 del módulo horarios del capítulo 31). Un
% procesador idéntico a otro no distingue qué tareas comparten alumnos.
% llamado_clpfd/3 agrega los conflictos a un modelo de restricciones y
% devuelve el calendario en el mismo formato, verificable con
% tareas:valido/2.
%
% solo-local: carga módulos de otros capítulos.
%
%?- llamado_72(2, C, G), mostrar_llamado(C).
%?- llamado_clpfd(2, C, D), mostrar_llamado(C).

:- module(examenes,
          [ proyecto_examenes/2,
            llamado_72/3,
            conflictos_violados/2,
            llamado_clpfd/3,
            sin_conflictos/1,
            lineas_llamado/2,
            mostrar_llamado/1,
            ver_llamado_72/1,
            ver_llamado/1
          ]).

:- use_module(library(clpfd)).
:- use_module('../capitulo-31/inscripciones/datos', [materia/3, correlativa/2]).
:- use_module('../capitulo-31/inscripciones/horarios', [conflicto/2]).
:- reexport('../capitulo-72/planificador', [planificar/4]).
:- reexport('../capitulo-72/tareas', [valido/2, mostrar/2, duracion/2]).
:- use_module('../capitulo-72/tareas', [repartir/3]).

%!  proyecto_examenes(+Aulas:integer, -Proyecto) is det.
%
%   Proyecto es el llamado a examen como proyecto del capítulo 72: una
%   tarea de duración 1 por materia, una precedencia antes(R, M) por cada
%   correlativa R de M, y Aulas procesadores.
proyecto_examenes(Aulas, proyecto(Tareas, Precedencias, Aulas)) :-
    must_be(positive_integer, Aulas),
    findall(tarea(M, 1), materia(M, _, _), Tareas),
    findall(antes(R, M), correlativa(M, R), Precedencias).

%!  llamado_72(+Aulas:integer, -Calendario:list, -Garantia) is det.
%
%   Calendario es el llamado más corto con Aulas aulas por día según el
%   planificador del capítulo 72, con la Garantia que este da.
llamado_72(Aulas, Calendario, Garantia) :-
    proyecto_examenes(Aulas, Proyecto),
    planificar(Proyecto, 1000000, Calendario, Garantia).

%!  conflictos_violados(+Calendario:list, -Pares:list) is det.
%
%   Pares son los pares M1-M2 de materias en conflicto que Calendario pone
%   el mismo día.
conflictos_violados(Calendario, Pares) :-
    findall(M1-M2,
            ( conflicto(M1, M2),
              memberchk(asignada(M1, _, Dia, _), Calendario),
              memberchk(asignada(M2, _, Dia, _), Calendario) ),
            Pares).

%!  sin_conflictos(+Calendario:list) is semidet.
%
%   Calendario no pone el mismo día dos materias en conflicto.
sin_conflictos(Calendario) :-
    conflictos_violados(Calendario, []).

%!  llamado_clpfd(+Aulas:integer, -Calendario:list, -Dias:integer) is semidet.
%
%   Calendario es un llamado de Aulas aulas por día que respeta las
%   correlativas y los conflictos, con la menor cantidad de días, Dias. Es
%   un calendario del capítulo 72: el examen de M el día D (desde 0) es
%   asignada(M, Aula, D, D + 1). Falla si no hay ninguno.
llamado_clpfd(Aulas, Calendario, Dias) :-
    proyecto_examenes(Aulas, proyecto(Tareas, _, _)),
    length(Tareas, N),
    findall(M-_, member(tarea(M, _), Tareas), Pares),
    pairs_values(Pares, Ds),
    Ultimo is N - 1,
    Ds ins 0..Ultimo,
    Dias in 1..N,
    maplist(antes_de(Dias), Ds),
    findall(R-M, correlativa(M, R), Correlativas),
    maplist(precedencia(Pares), Correlativas),
    findall(M1-M2, conflicto(M1, M2), Conflictos),
    maplist(dia_distinto(Pares), Conflictos),
    numlist(0, Ultimo, Todos),
    findall(D-_, member(D, Todos), Cuentas),
    pairs_values(Cuentas, Cs),
    Cs ins 0..Aulas,
    global_cardinality(Ds, Cuentas),
    once(labeling([min(Dias), ff], [Dias|Ds])),
    findall(tramo(M, D, F), ( member(M-D, Pares), F is D + 1 ), Tramos),
    repartir(Aulas, Tramos, Calendario).

%!  antes_de(+Dias, +D) is det.
%
%   El día D es anterior a Dias.
antes_de(Dias, D) :-
    D #< Dias.

%!  precedencia(+Pares:list, +Correlativa:pair) is det.
%
%   El examen de la correlativa R va un día antes que el de M, por lo
%   menos, para un par R-M.
precedencia(Pares, R-M) :-
    memberchk(R-DR, Pares),
    memberchk(M-DM, Pares),
    DR #< DM.

%!  dia_distinto(+Pares:list, +Conflicto:pair) is det.
%
%   Las dos materias del Conflicto rinden en días distintos.
dia_distinto(Pares, M1-M2) :-
    memberchk(M1-D1, Pares),
    memberchk(M2-D2, Pares),
    D1 #\= D2.

%!  lineas_llamado(+Calendario:list, -Lineas:list) is det.
%
%   Lineas tiene una cadena por día del llamado Calendario, desde el
%   primero hasta el último, con las materias que rinden ese día, en el
%   orden de las aulas.
lineas_llamado(Calendario, Lineas) :-
    duracion(Calendario, D),
    Ultimo is D - 1,
    numlist(0, Ultimo, Dias),
    maplist(linea_dia(Calendario), Dias, Lineas).

%!  linea_dia(+Calendario:list, +Dia:integer, -Linea:string) is det.
%
%   Linea dice qué materias rinden el día Dia (desde 0) de Calendario.
linea_dia(Calendario, Dia, Linea) :-
    findall(A-M, member(asignada(M, A, Dia, _), Calendario), Pares0),
    keysort(Pares0, Pares),
    pairs_values(Pares, Ms),
    atomic_list_concat(Ms, ' ', Texto),
    Numero is Dia + 1,
    format(string(Linea), "día ~w: ~w", [Numero, Texto]).

%!  mostrar_llamado(+Calendario:list) is det.
%
%   Escribe las líneas de Calendario, un día por línea.
mostrar_llamado(Calendario) :-
    lineas_llamado(Calendario, Lineas),
    forall(member(L, Lineas), format("~s~n", [L])).

%!  ver_llamado_72(+Aulas:integer) is det.
%
%   Escribe el llamado de llamado_72/3 con Aulas aulas, su garantía y los
%   conflictos que no respeta.
ver_llamado_72(Aulas) :-
    llamado_72(Aulas, Calendario, Garantia),
    mostrar_llamado(Calendario),
    conflictos_violados(Calendario, Pares),
    format("garantía: ~w~nconflictos: ~w~n", [Garantia, Pares]).

%!  ver_llamado(+Aulas:integer) is semidet.
%
%   Escribe el llamado de llamado_clpfd/3 con Aulas aulas y su cantidad de
%   días.
ver_llamado(Aulas) :-
    llamado_clpfd(Aulas, Calendario, Dias),
    mostrar_llamado(Calendario),
    format("días: ~w~n", [Dias]).
