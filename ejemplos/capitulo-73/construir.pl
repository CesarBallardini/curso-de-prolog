:- encoding(utf8).

% Capítulo 73 - Versión 2: construir el horario probando en cada paso.
%
% En lugar de probar el horario terminado, se lo construye clase por
% clase, y cada clase se ubica solo en un momento y un aula compatibles
% con las que ya están ubicadas: la prueba se reparte entre los pasos de
% la generación. Es el esquema del programa de horarios de Covington,
% Nute y Vellino (Prolog Programming in Depth, sección 8.8), donde
% available/5 verifica cada asignación contra el horario parcial.
%
% El orden en que se toman las clases decide cuánto se vuelve atrás. Con
% orden(datos), las clases van en el orden de la oferta; con
% orden(dificiles), primero las que tienen menos ubicaciones posibles,
% como los trabajos «cuello de botella» que Covington pone primero.
%
% solo-local: carga otros archivos, y SWISH no permite cargar otro archivo.
%
%?- oferta(cuatrimestre, O), construir(O, datos, H), mostrar_anio(O, H, 1).
%?- medir_construir(cuatrimestre, datos, K).

:- module(construir,
          [ construir/3,
            ubicaciones/3,
            ordenar_clases/3,
            compatible/3,
            ubicacion/3,
            incompatibles_en_orden/3,
            contar_paso/0,
            medir_construir/3,
            ver_construir/3
          ]).

:- reexport(oferta).

%!  construir(+Oferta, +Orden, -Horario:list) is nondet.
%
%   Horario es un horario válido de Oferta, construido clase por clase en
%   el Orden indicado (datos o dificiles). Cada clase toma el primer
%   momento y la primera aula compatibles con las ya ubicadas; si no hay
%   ninguna, la vuelta atrás cambia la ubicación de la clase anterior.
construir(Oferta, Orden, Horario) :-
    ordenar_clases(Oferta, Orden, Clases),
    ubicar_todas(Oferta, Clases, [], Horario0),
    msort(Horario0, Horario).

%!  ubicar_todas(+Oferta, +Clases:list, +Parcial:list, -Horario:list)
%!      is nondet.
%
%   Horario agrega a Parcial una ubicación compatible para cada clase de
%   Clases.
ubicar_todas(_, [], Horario, Horario).
ubicar_todas(Oferta, [C|Cs], Parcial, Horario) :-
    ubicacion(Oferta, C, Asignada),
    compatible(Oferta, Asignada, Parcial),
    contar_paso,
    ubicar_todas(Oferta, Cs, [Asignada|Parcial], Horario).

%!  ubicacion(+Oferta, +Clase, -Asignada) is nondet.
%
%   Asignada pone Clase en un momento de la semana en que su docente está
%   disponible y en un aula donde cabe: las reglas que dependen de una
%   sola clase.
ubicacion(Oferta, C, asignada(C, A, S, F)) :-
    clase(Oferta, C, _, _, Docente, Cupo),
    momento(Oferta, S, Dia, _),
    disponible(Oferta, Docente, Dia),
    aula(Oferta, A, _, Capacidad),
    Cupo =< Capacidad,
    F is S + 1.

%!  ubicaciones(+Oferta, +Clase, -N:integer) is det.
%
%   N es la cantidad de ubicaciones posibles de Clase, sin contar las
%   demás clases.
ubicaciones(Oferta, C, N) :-
    aggregate_all(count, ubicacion(Oferta, C, _), N).

%!  compatible(+Oferta, +Asignada, +Parcial:list) is semidet.
%
%   Asignada no choca con ninguna clase de Parcial: el aula está libre en
%   ese momento, ninguna clase incompatible ocupa el mismo momento y
%   ninguna clase de la misma materia cae el mismo día.
compatible(Oferta, asignada(C, A, S, _), Parcial) :-
    \+ memberchk(asignada(_, A, S, _), Parcial),
    \+ ( member(asignada(C2, _, S, _), Parcial),
         incompatibles_en_orden(Oferta, C, C2) ),
    C = M-_,
    momento(Oferta, S, Dia, _),
    \+ ( member(asignada(M-_, _, S2, _), Parcial),
         momento(Oferta, S2, Dia, _) ).

%!  incompatibles_en_orden(+Oferta, +C1, +C2) is semidet.
%
%   C1 y C2 son incompatibles, en cualquier orden.
incompatibles_en_orden(Oferta, C1, C2) :-
    (   C1 @< C2
    ->  incompatibles(Oferta, C1, C2)
    ;   incompatibles(Oferta, C2, C1)
    ),
    !.

%!  ordenar_clases(+Oferta, +Orden, -Clases:list) is det.
%
%   Clases son las clases de Oferta en el Orden pedido: datos, el de la
%   oferta, o dificiles, de menos a más ubicaciones posibles, y entre las
%   que tienen las mismas, en el orden de la oferta.
ordenar_clases(Oferta, datos, Clases) :-
    !,
    findall(C, clase(Oferta, C, _, _, _, _), Clases).
ordenar_clases(Oferta, dificiles, Clases) :-
    findall(N-C,
            ( clase(Oferta, C, _, _, _, _),
              ubicaciones(Oferta, C, N) ),
            Pares0),
    keysort(Pares0, Pares),
    pairs_values(Pares, Clases).

%!  contar_paso is det.
%
%   Suma uno a la cantidad de clases ubicadas, que medir_construir/3 lee.
contar_paso :-
    (   nb_current(pasos, K0)
    ->  K is K0 + 1,
        nb_setval(pasos, K)
    ;   true
    ).

%!  medir_construir(+Nombre, +Orden, -K:integer) is semidet.
%
%   K es la cantidad de veces que construir/3 ubica una clase hasta
%   encontrar el primer horario de la oferta de ejemplo Nombre, con el
%   Orden indicado.
medir_construir(Nombre, Orden, K) :-
    oferta(Nombre, Oferta),
    nb_setval(pasos, 0),
    once(construir(Oferta, Orden, _)),
    nb_getval(pasos, K),
    nb_delete(pasos).

%!  ver_construir(+Nombre, +Orden, +Anio:integer) is semidet.
%
%   Escribe la grilla del año Anio en el primer horario que construir/3
%   encuentra para la oferta de ejemplo Nombre con el Orden indicado.
ver_construir(Nombre, Orden, Anio) :-
    oferta(Nombre, Oferta),
    once(construir(Oferta, Orden, Horario)),
    mostrar_anio(Oferta, Horario, Anio).
