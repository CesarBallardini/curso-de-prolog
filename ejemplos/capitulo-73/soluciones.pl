:- encoding(utf8).

% Capítulo 73 - Soluciones de los ejercicios.
%
% Carga la grilla web (que reexporta las versiones 5 y 4 y la
% representación), la versión 2 y el llamado a examen, sin modificarlos.
%
% solo-local: carga otros archivos, y SWISH no permite cargar otro archivo.
%
%?- ejercicio_1(Choques, Tareas).
%?- medir_grado(facultad(12), K).
%?- oferta(cuatrimestre, O), horario_con_recursantes(O, [am1-am2, alg-pp], H).

:- module(soluciones,
          [ proyecto_de/2,
            ejercicio_1/2,
            construir_por_grado/2,
            clases_por_grado/2,
            medir_grado/2,
            reparar/3,
            horario_con_recursantes/3,
            medir_etiquetado/3,
            costo_docentes/3,
            optimo_docentes/3,
            cota_docentes/2,
            primero_de_varios/3,
            mejor_de_varios/4,
            cuerpo_aula/4,
            llamado_separado/3,
            candidatos/2,
            mostrar_llamado/1,
            ver_reparacion/1,
            ver_recursantes/2,
            comparar_costos/2,
            costos_de_varios/2,
            ver_llamado_separado/1
          ]).

:- use_module(library(clpfd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/html_write)).
:- reexport(web).
:- use_module(construir, [ ubicacion/3, compatible/3, contar_paso/0,
                           incompatibles_en_orden/3 ]).
:- use_module(examenes, [ proyecto_examenes/2, mostrar_llamado/1 ]).
:- use_module(generar, [ candidatos/2 ]).
:- use_module('../capitulo-31/inscripciones/datos', [correlativa/2]).
:- use_module('../capitulo-31/inscripciones/horarios', [conflicto/2]).
:- use_module('../capitulo-72/tareas', [repartir/3]).

:- http_handler(root(aula/Nombre), pagina_aula(Nombre), [method(get)]).

% --- Ejercicio 1 --------------------------------------------------------------

%!  proyecto_de(+Oferta, -Proyecto) is det.
%
%   Proyecto es el proyecto de tareas.pl de Oferta: una tarea de duración
%   1 por clase, sin precedencias, y un procesador por aula.
proyecto_de(Oferta, proyecto(Tareas, [], NA)) :-
    Oferta = oferta(_, _, Aulas, _),
    findall(tarea(C, 1), clase(Oferta, C, _, _, _, _), Tareas),
    length(Aulas, NA).

%!  ejercicio_1(-Choques:list, -Tareas) is det.
%
%   Choques son los choques del horario de ejemplo con alg-2 en el
%   momento 2 y log-2 en el momento 5, y Tareas es valido o invalido según
%   lo que responde tareas:valido/2 sobre ese horario.
ejercicio_1(Choques, Tareas) :-
    oferta(cuatrimestre, O),
    horario_ejemplo(H0),
    selectchk(asignada(alg-2, 1, 9, 10), H0, asignada(alg-2, 1, 2, 3), H1),
    selectchk(asignada(log-2, 2, 13, 14), H1, asignada(log-2, 2, 5, 6), H),
    findall(C, choque(O, H, C), Choques),
    proyecto_de(O, P),
    (   tareas:valido(P, H)
    ->  Tareas = valido
    ;   Tareas = invalido
    ).

% --- Ejercicio 3 --------------------------------------------------------------

%!  construir_por_grado(+Oferta, -Horario:list) is nondet.
%
%   Horario es un horario válido de Oferta, construido como en la versión
%   2 con las clases ordenadas de más a menos clases incompatibles.
construir_por_grado(Oferta, Horario) :-
    clases_por_grado(Oferta, Clases),
    en_orden(Oferta, Clases, [], Horario0),
    msort(Horario0, Horario).

%!  clases_por_grado(+Oferta, -Clases:list) is det.
%
%   Clases son las clases de Oferta de más a menos clases incompatibles
%   con ellas; con el mismo grado, en el orden de la oferta.
clases_por_grado(Oferta, Clases) :-
    findall(G-C,
            ( clase(Oferta, C, _, _, _, _),
              aggregate_all(count,
                            ( clase(Oferta, C2, _, _, _, _),
                              C2 \== C,
                              incompatibles_en_orden(Oferta, C, C2) ),
                            N),
              G is -N ),
            Pares0),
    keysort(Pares0, Pares),
    pairs_values(Pares, Clases).

%!  en_orden(+Oferta, +Clases:list, +Parcial:list, -Horario:list) is nondet.
%
%   Horario agrega a Parcial una ubicación compatible para cada clase de
%   Clases, en ese orden.
en_orden(_, [], Horario, Horario).
en_orden(Oferta, [C|Cs], Parcial, Horario) :-
    ubicacion(Oferta, C, Asignada),
    compatible(Oferta, Asignada, Parcial),
    contar_paso,
    en_orden(Oferta, Cs, [Asignada|Parcial], Horario).

%!  medir_grado(+Nombre, -K:integer) is semidet.
%
%   K es la cantidad de clases que ubica construir_por_grado/2 hasta el
%   primer horario de la oferta de ejemplo Nombre.
medir_grado(Nombre, K) :-
    oferta(Nombre, Oferta),
    nb_setval(pasos, 0),
    once(construir_por_grado(Oferta, _)),
    nb_getval(pasos, K),
    nb_delete(pasos).

% --- Ejercicio 4 --------------------------------------------------------------

%!  reparar(+Oferta, +Horario0:list, -Horario:list) is det.
%
%   Horario es Horario0 después de mover, mientras haya un choque, una de
%   sus dos clases a una ubicación compatible con todas las demás. Si
%   ninguna de las dos se puede mover, Horario es el horario alcanzado,
%   que puede tener todavía choques.
reparar(Oferta, Horario0, Horario) :-
    (   choque(Oferta, Horario0, Choque),
        arg(I, Choque, C),
        I =< 2,
        selectchk(asignada(C, _, _, _), Horario0, Resto),
        ubicacion(Oferta, C, Nueva),
        compatible(Oferta, Nueva, Resto)
    ->  reparar(Oferta, [Nueva|Resto], Horario)
    ;   msort(Horario0, Horario)
    ).

% --- Ejercicio 5 --------------------------------------------------------------

%!  horario_con_recursantes(+Oferta, +Pares:list, -Horario:list) is semidet.
%
%   Horario es el primer horario válido de Oferta en que, además, las
%   clases de las dos materias de cada par M1-M2 de Pares ocupan momentos
%   distintos.
horario_con_recursantes(Oferta, Pares, Horario) :-
    modelo(Oferta, conteo, Horario, vars(_, _, Ps)),
    maplist(separar_materias(Horario), Pares),
    once(labeling([ff], Ps)).

%!  separar_materias(+Horario:list, +Par) is det.
%
%   Cada clase de M1 tiene un momento distinto del de cada clase de M2,
%   para el par M1-M2.
separar_materias(Horario, M1-M2) :-
    include(de_la_materia(M1), Horario, H1),
    include(de_la_materia(M2), Horario, H2),
    maplist(momento_de, H1, Ss1),
    maplist(momento_de, H2, Ss2),
    maplist(distinto_de_todos(Ss2), Ss1).

%!  de_la_materia(+M, +Asignada) is semidet.
%
%   Asignada es de una clase de la materia M.
de_la_materia(M, asignada(M-_, _, _, _)).

%!  distinto_de_todos(+Ss:list, +S) is det.
%
%   S es distinto de cada variable de Ss.
distinto_de_todos(Ss, S) :-
    maplist(#\=(S), Ss).

% --- Ejercicio 6 --------------------------------------------------------------

%!  medir_etiquetado(+Nombre, +Opcion, -Resultado) is det.
%
%   Resultado es r(si, I) si el etiquetado del par momento-aula con la
%   opción Opcion de labeling/2 encuentra un horario de la oferta de
%   ejemplo Nombre (modelo simple) con I inferencias, o limite si pasa de
%   veinte millones de inferencias.
medir_etiquetado(Nombre, Opcion, Resultado) :-
    oferta(Nombre, Oferta),
    modelo(Oferta, simple, _, vars(_, _, Ps)),
    statistics(inferences, I0),
    call_with_inference_limit(once(labeling([Opcion], Ps)), 20000000, R),
    statistics(inferences, I1),
    (   R == inference_limit_exceeded
    ->  Resultado = limite
    ;   I is I1 - I0,
        Resultado = r(si, I)
    ).

% --- Ejercicio 7 --------------------------------------------------------------

%!  costo_docentes(+Oferta, +Horario:list, -Costo) is det.
%
%   Costo es la variable de la cantidad de días que viene cada docente,
%   sumada sobre todos los docentes de Oferta.
costo_docentes(Oferta, Horario, Costo) :-
    Oferta = oferta(semana(Dias, Franjas), _, _, _),
    findall(D, grupo(Oferta, docente(D)), Docentes),
    numlist(1, Dias, Ds),
    findall(D-Dia, ( member(D, Docentes), member(Dia, Ds) ), Claves),
    maplist(viene(Oferta, Horario, Franjas), Claves, Bs),
    sum(Bs, #=, Costo).

%!  viene(+Oferta, +Horario:list, +Franjas:integer, +Clave, -B) is det.
%
%   B es 1 si el docente de Clave, un par Docente-Dia, tiene alguna clase
%   ese día, y 0 si no.
viene(Oferta, Horario, Franjas, D-Dia, B) :-
    include(en_grupo(Oferta, docente(D)), Horario, Suyas),
    maplist(momento_de, Suyas, Ss),
    maplist(ese_dia(Franjas, Dia), Ss, Bs),
    sum(Bs, #=, N),
    B #<==> (N #>= 1).

%!  ese_dia(+Franjas:integer, +Dia:integer, +S, -B) is det.
%
%   B es 1 si el momento S cae el día Dia, y 0 si no.
ese_dia(Franjas, Dia, S, B) :-
    B #<==> (S // Franjas #= Dia - 1).

%!  optimo_docentes(+Oferta, -Horario:list, -Costo:integer) is semidet.
%
%   Horario es un horario válido de Oferta con la menor cantidad de días
%   de docentes, Costo, acotada desde cota_docentes/2 hacia arriba.
optimo_docentes(Oferta, Horario, Costo) :-
    modelo(Oferta, conteo, Horario, vars(_, _, Ps)),
    costo_docentes(Oferta, Horario, Costo),
    cota_docentes(Oferta, Minimo),
    fd_sup(Costo, Maximo),
    between(Minimo, Maximo, Cota),
    Costo #=< Cota,
    once(labeling([ff], Ps)),
    !.

%!  cota_docentes(+Oferta, -Cota:integer) is det.
%
%   Ningún horario de Oferta tiene menos de Cota días de docentes: cada
%   docente viene al menos tantos días como clases tiene la materia suya
%   de más clases, porque van en días distintos.
cota_docentes(Oferta, Cota) :-
    findall(N,
            ( grupo(Oferta, docente(D)),
              aggregate_all(max(K), clase(Oferta, _-K, _, _, D, _), N) ),
            Ns),
    sum_list(Ns, Cota).

% --- Ejercicio 8 --------------------------------------------------------------

%!  primero_de_varios(+Oferta, -Horario:list, -Costo:integer) is semidet.
%
%   Horario es el de menor costo entre los primeros horarios de Oferta con
%   cuatro opciones de etiquetado del par momento-aula: ff, ffc, leftmost
%   y ff con los valores de mayor a menor.
primero_de_varios(Oferta, Horario, Costo) :-
    findall(C-H,
            ( member(Opciones, [[ff], [ffc], [leftmost], [ff, down]]),
              modelo(Oferta, conteo, H, vars(_, _, Ps)),
              once(labeling(Opciones, Ps)),
              evaluar(Oferta, H, C) ),
            Pares),
    keysort(Pares, [Costo-Horario|_]).

%!  mejor_de_varios(+Oferta, +Limite:integer, -Horario:list, -Garantia)
%!      is semidet.
%
%   Como mejor_con_limite/4, pero la mejora empieza por el horario de
%   primero_de_varios/3.
mejor_de_varios(Oferta, Limite, Horario, Garantia) :-
    cota_inferior(Oferta, Cota),
    primero_de_varios(Oferta, Primero, C0),
    mejorar(Oferta, Limite, Cota, Primero, C0, Horario, Garantia).

% --- Ejercicio 9 --------------------------------------------------------------

%!  pagina_aula(+Nombre:atom, +Pedido) is det.
%
%   GET /aula/Nombre: la ocupación del aula Nombre en el horario
%   publicado, o 404 si no hay un aula con ese nombre.
pagina_aula(Nombre, Pedido) :-
    oferta(cuatrimestre, Oferta),
    (   aula(Oferta, _, Nombre, _)
    ->  optimo(Oferta, cotas, Horario, _),
        cuerpo_aula(Oferta, Horario, Nombre, Cuerpo),
        reply_html_page(title(Nombre), Cuerpo)
    ;   http_404([], Pedido)
    ).

%!  cuerpo_aula(+Oferta, +Horario:list, +Nombre, -Cuerpo:list) is semidet.
%
%   Cuerpo es la página de la ocupación del aula Nombre en Horario: una
%   tabla con una columna por día, una fila por franja y, en cada casilla,
%   la clase que usa el aula. Falla si no hay un aula con ese nombre.
cuerpo_aula(Oferta, Horario, Nombre,
            [h1(Titulo), table([tr([th('Franja')|Encabezados])|Filas])]) :-
    once(aula(Oferta, Numero, Nombre, _)),
    Oferta = oferta(semana(Dias, Franjas), _, _, _),
    format(atom(Titulo), "Aula ~w", [Nombre]),
    numlist(1, Dias, Ds),
    maplist(nombre_del_dia, Ds, Encabezados),
    numlist(1, Franjas, Fs),
    maplist(fila_aula(Oferta, Horario, Numero, Ds), Fs, Filas).

%!  nombre_del_dia(+Dia:integer, -Th) is det.
%
%   Th es la celda de encabezado del día Dia.
nombre_del_dia(Dia, th(Nombre)) :-
    nth1(Dia, [lun, mar, mie, jue, vie], Nombre).

%!  fila_aula(+Oferta, +Horario:list, +Numero:integer, +Dias:list,
%!            +Franja:integer, -Tr) is det.
%
%   Tr es la fila de la franja Franja en la ocupación del aula Numero.
fila_aula(Oferta, Horario, Numero, Dias, Franja, tr([th(Franja)|Celdas])) :-
    maplist(celda_aula(Oferta, Horario, Numero, Franja), Dias, Celdas).

%!  celda_aula(+Oferta, +Horario:list, +Numero:integer, +Franja:integer,
%!             +Dia:integer, -Td) is det.
%
%   Td muestra la clase que usa el aula Numero en ese día y franja, o
%   está vacía.
celda_aula(Oferta, Horario, Numero, Franja, Dia, Td) :-
    momento(Oferta, S, Dia, Franja),
    (   memberchk(asignada(M-K, Numero, S, _), Horario)
    ->  format(atom(Texto), "~w-~w", [M, K]),
        Td = td(Texto)
    ;   Td = td([])
    ).

% --- Ejercicio 10 -------------------------------------------------------------

%!  llamado_separado(+Aulas:integer, -Calendario:list, -Dias:integer)
%!      is semidet.
%
%   Como llamado_clpfd/3, pero entre dos exámenes en conflicto queda al
%   menos un día libre.
llamado_separado(Aulas, Calendario, Dias) :-
    proyecto_examenes(Aulas, proyecto(Tareas, _, _)),
    length(Tareas, N),
    findall(M-_, member(tarea(M, _), Tareas), Pares),
    pairs_values(Pares, Ds),
    Ultimo is 2 * N,
    Ds ins 0..Ultimo,
    Tope is Ultimo + 1,
    Dias in 1..Tope,
    maplist(#>(Dias), Ds),
    findall(R-M, correlativa(M, R), Correlativas),
    maplist(antes(Pares), Correlativas),
    findall(M1-M2, conflicto(M1, M2), Conflictos),
    maplist(separados(Pares), Conflictos),
    numlist(0, Ultimo, Todos),
    findall(D-_, member(D, Todos), Cuentas),
    pairs_values(Cuentas, Cs),
    Cs ins 0..Aulas,
    global_cardinality(Ds, Cuentas),
    once(labeling([min(Dias), ff], [Dias|Ds])),
    findall(tramo(M, D, F), ( member(M-D, Pares), F is D + 1 ), Tramos),
    repartir(Aulas, Tramos, Calendario).

%!  antes(+Pares:list, +Correlativa:pair) is det.
%
%   El examen de R va antes que el de M, para el par R-M.
antes(Pares, R-M) :-
    memberchk(R-DR, Pares),
    memberchk(M-DM, Pares),
    DR #< DM.

%!  separados(+Pares:list, +Conflicto:pair) is det.
%
%   Entre los exámenes de las dos materias del Conflicto queda al menos un
%   día libre.
separados(Pares, M1-M2) :-
    memberchk(M1-D1, Pares),
    memberchk(M2-D2, Pares),
    abs(D1 - D2) #>= 2.

% --- Consultas de la página de soluciones -------------------------------------

%!  ver_reparacion(-Cambios:list) is det.
%
%   Cambios son las asignaciones que reparar/3 agrega al horario de
%   ejemplo después de pasar am2-1 al momento 0. Falla si el resultado no
%   es un horario válido.
ver_reparacion(Cambios) :-
    oferta(cuatrimestre, O),
    horario_ejemplo(H0),
    selectchk(asignada(am2-1, 2, 2, 3), H0, asignada(am2-1, 2, 0, 1), H1),
    reparar(O, H1, H),
    horario_valido(O, H),
    subtract(H, H0, Cambios).

%!  ver_recursantes(+Pares:list, +Anio:integer) is semidet.
%
%   Escribe la grilla del año Anio en el horario de
%   horario_con_recursantes/3 para la oferta cuatrimestre y Pares.
ver_recursantes(Pares, Anio) :-
    oferta(cuatrimestre, O),
    horario_con_recursantes(O, Pares, H),
    mostrar_anio(O, H, Anio).

%!  comparar_costos(-Docentes, -Alumnos) is semidet.
%
%   Docentes es r(D, A) para el horario de la oferta cuatrimestre que
%   minimiza los días de docentes, y Alumnos lo mismo para el que minimiza
%   el costo de los alumnos: D, los días de docentes, y A, el costo de
%   evaluar/3.
comparar_costos(r(D1, A1), r(D2, A2)) :-
    oferta(cuatrimestre, O),
    optimo_docentes(O, H1, D1),
    evaluar(O, H1, A1),
    optimo(O, cotas, H2, A2),
    costo_docentes(O, H2, D2).

%!  costos_de_varios(+Nombre, -Costos:list) is det.
%
%   Costos tiene un par Opciones-Costo con el costo del primer horario de
%   la oferta de ejemplo Nombre para cada etiquetado de
%   primero_de_varios/3.
costos_de_varios(Nombre, Costos) :-
    oferta(Nombre, Oferta),
    findall(Opciones-C,
            ( member(Opciones, [[ff], [ffc], [leftmost], [ff, down]]),
              modelo(Oferta, conteo, H, vars(_, _, Ps)),
              once(labeling(Opciones, Ps)),
              evaluar(Oferta, H, C) ),
            Costos).

%!  ver_llamado_separado(+Aulas:integer) is semidet.
%
%   Escribe el llamado de llamado_separado/3 con Aulas aulas y su cantidad
%   de días.
ver_llamado_separado(Aulas) :-
    llamado_separado(Aulas, Calendario, Dias),
    mostrar_llamado(Calendario),
    format("días: ~w~n", [Dias]).
