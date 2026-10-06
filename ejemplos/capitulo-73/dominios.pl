:- encoding(utf8).

% Capítulo 73 - Versión 3: dominios, poda hacia adelante y la clase más
% restringida primero.
%
% Cada clase pendiente lleva su dominio: la lista de ubicaciones
% Momento-Aula que todavía le quedan. Al ubicar una clase se quitan de los
% dominios de las demás las ubicaciones que chocarían con ella (la poda
% hacia adelante), y si algún dominio queda vacío, la rama se abandona en
% ese momento, sin esperar a llegar a esa clase. La próxima clase a ubicar
% es la de dominio más chico (la más restringida primero), un orden que
% cambia a medida que el horario avanza. Es, escrito a mano, lo que la
% biblioteca de restricciones de la versión 4 hace sola.
%
% solo-local: carga otros archivos, y SWISH no permite cargar otro archivo.
%
%?- oferta(cuatrimestre, O), resolver(O, H), mostrar_anio(O, H, 2).
%?- medir_dominios(cuatrimestre, K).

:- module(dominios,
          [ resolver/2,
            dominios_iniciales/2,
            elegir/3,
            podar/4,
            medir_dominios/2
          ]).

:- reexport(construir).

%!  resolver(+Oferta, -Horario:list) is nondet.
%
%   Horario es un horario válido de Oferta, construido con dominios, poda
%   hacia adelante y la clase de dominio más chico primero.
resolver(Oferta, Horario) :-
    dominios_iniciales(Oferta, Pendientes),
    asignar(Oferta, Pendientes, [], Horario0),
    msort(Horario0, Horario).

%!  dominios_iniciales(+Oferta, -Pendientes:list) is det.
%
%   Pendientes tiene un par Clase-Dominio por cada clase de Oferta, en su
%   orden; Dominio son las ubicaciones Momento-Aula que permiten las
%   reglas de una sola clase.
dominios_iniciales(Oferta, Pendientes) :-
    findall(C-Dominio,
            ( clase(Oferta, C, _, _, _, _),
              findall(S-A, ubicacion(Oferta, C, asignada(C, A, S, _)),
                      Dominio) ),
            Pendientes).

%!  asignar(+Oferta, +Pendientes:list, +Parcial:list, -Horario:list)
%!      is nondet.
%
%   Horario agrega a Parcial una ubicación para cada clase de Pendientes,
%   tomada de su dominio.
asignar(_, [], Horario, Horario).
asignar(Oferta, Pendientes, Parcial, Horario) :-
    elegir(Pendientes, C-Dominio, Resto),
    member(S-A, Dominio),
    contar_paso,
    F is S + 1,
    Asignada = asignada(C, A, S, F),
    maplist(podar(Oferta, Asignada), Resto, Resto1),
    asignar(Oferta, Resto1, [Asignada|Parcial], Horario).

%!  elegir(+Pendientes:list, -Elegida, -Resto:list) is det.
%
%   Elegida es el par Clase-Dominio de Pendientes con el dominio más
%   chico, el primero si hay varios; Resto, los demás pares, en su orden.
elegir(Pendientes, Elegida, Resto) :-
    maplist(con_tamanio, Pendientes, Pares0),
    keysort(Pares0, [_-Elegida|_]),
    selectchk(Elegida, Pendientes, Resto).

%!  con_tamanio(+Par, -ConTamanio) is det.
%
%   ConTamanio es el par Clase-Dominio con el tamaño del dominio como
%   clave.
con_tamanio(C-Dominio, N-(C-Dominio)) :-
    length(Dominio, N).

%!  podar(+Oferta, +Asignada, +Par0, -Par) is semidet.
%
%   Par es Par0, un par Clase-Dominio, sin las ubicaciones que chocan con
%   Asignada. Falla si el dominio queda vacío.
podar(Oferta, asignada(C, A, S, _), C2-Dominio0, C2-Dominio) :-
    (   incompatibles_en_orden(Oferta, C, C2)
    ->  Incompatible = si
    ;   Incompatible = no
    ),
    C = M-_,
    (   C2 = M-_
    ->  momento(Oferta, S, Dia, _)
    ;   Dia = ninguno
    ),
    exclude(choca(Oferta, A, S, Incompatible, Dia), Dominio0, Dominio),
    Dominio \== [].

%!  choca(+Oferta, +A:integer, +S:integer, +Incompatible, +Dia,
%!        +Ubicacion) is semidet.
%
%   La Ubicacion S2-A2 de otra clase choca con una clase ubicada en el
%   momento S y el aula A: usa la misma aula en el mismo momento, o el
%   mismo momento si las clases son incompatibles (Incompatible es si), o
%   el mismo día Dia si son de la misma materia (si no, Dia es ninguno).
choca(_, A, S, _, _, S-A) :-
    !.
choca(_, _, S, si, _, S-_) :-
    !.
choca(Oferta, _, _, _, Dia, S2-_) :-
    Dia \== ninguno,
    momento(Oferta, S2, Dia, _).

%!  medir_dominios(+Nombre, -K:integer) is semidet.
%
%   K es la cantidad de veces que resolver/2 ubica una clase hasta
%   encontrar el primer horario de la oferta de ejemplo Nombre.
medir_dominios(Nombre, K) :-
    oferta(Nombre, Oferta),
    nb_setval(pasos, 0),
    once(resolver(Oferta, _)),
    nb_getval(pasos, K),
    nb_delete(pasos).
