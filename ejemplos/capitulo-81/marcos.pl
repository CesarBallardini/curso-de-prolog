:- encoding(utf8).

% Capítulo 81 - Marcos: los hechos agrupados por objeto, con herencia.
%
% Un marco reúne lo que se sabe de un objeto o de una clase de objetos.
% valor(Objeto, Ranura, Valor) es una ranura llena; ranura(Objeto,
% Ranura), una ranura que el marco declara sin llenar. Los marcos se
% enlazan con es_un (una clase más general), parte_de (el todo del que el
% objeto es parte), intension (el concepto del que el objeto es la
% extensión en un momento) y extension (la inversa). El ejemplo es el de
% Rowe: los autos, un modelo y el auto de una persona con su batería.
%
% tiene_valor/3 busca el valor de una ranura: el propio, si el marco lo
% tiene, o el heredado por las relaciones que esa ranura admite. Un valor
% propio reemplaza al heredado; una ranura con varios valores propios los
% da todos. tiene_parte y parte_de se guardan en un solo sentido y se
% derivan en el otro, y la edad se calcula a partir del año de
% fabricación.
%
%?- tiene_valor(rabbit_de_juan_hoy, uso, U).
%?- tiene_valor(bateria_de_juan_hoy, edad, E).
%?- tiene_valor(auto, tiene_parte, P).
%?- ranuras(rabbit_de_juan, Rs).

:- use_module(library(lists)).

% --- Los marcos ----------------------------------------------------------

% valor(Objeto, Ranura, Valor): la ranura Ranura del marco Objeto tiene
% el valor Valor.
valor(vehiculo, es_un, objeto_fisico).
valor(vehiculo, uso, transporte).
valor(sistema_de_propulsion, parte_de, vehiculo).
valor(auto, es_un, vehiculo).
valor(auto, propulsion, motor_de_combustion_interna).
valor(auto, extension, autos_en_circulacion).
valor(sistema_electrico, parte_de, auto).
valor(bateria, parte_de, sistema_electrico).
valor(arranque, parte_de, sistema_electrico).
valor(vw_rabbit, es_un, auto).
valor(vw_rabbit, marca, vw).
valor(vw_rabbit, modelo, rabbit).
valor(autos_en_circulacion, intension, auto).
valor(rabbit_de_juan, es_un, vw_rabbit).
valor(rabbit_de_juan, extension, rabbit_de_juan_hoy).
valor(rabbit_de_juan, propietario, juan).
valor(rabbit_de_juan, fabricado, 1976).
valor(rabbit_de_juan_hoy, subconjunto, autos_en_circulacion).
valor(rabbit_de_juan_hoy, intension, rabbit_de_juan).
valor(bateria_de_juan, extension, bateria_de_juan_hoy).
valor(bateria_de_juan, parte_de, rabbit_de_juan).
valor(bateria_de_juan_hoy, intension, bateria_de_juan).
valor(bateria_de_juan_hoy, contenida_en, rabbit_de_juan_hoy).
valor(bateria_de_juan_hoy, estado, descargada).
valor(auto_de_ana, es_un, auto).
valor(auto_de_ana, marca, fiat).

% ranura(Objeto, Ranura): el marco Objeto tiene la ranura Ranura, todavía
% sin llenar.
ranura(objeto_fisico, peso).
ranura(objeto_fisico, nombre).
ranura(objeto_fisico, uso).
ranura(vehiculo, propietario).
ranura(vehiculo, concesionarios).
ranura(vehiculo, fabricado).
ranura(vehiculo, edad).
ranura(vehiculo, propulsion).
ranura(auto, marca).
ranura(auto, modelo).

% unidades(Objeto, Ranura, Unidades): los valores de la ranura se miden
% en Unidades.
unidades(objeto_fisico, peso, kilogramos).
unidades(vehiculo, edad, anios).
unidades(vehiculo, fabricado, anios).

% valores_posibles(Objeto, Ranura, Valores): la ranura solo admite los
% valores de la lista.
valores_posibles(auto, marca, [gm, ford, chrysler, amc, vw, toyota, nissan,
                               bmw]).

% hereda(Ranura, Relacion): la ranura toma su valor del marco al que lleva
% la relación, si el marco no tiene uno propio.
hereda(uso, es_un).
hereda(propulsion, es_un).
hereda(concesionarios, es_un).
hereda(fabricado, es_un).
hereda(edad, es_un).
hereda(marca, es_un).
hereda(modelo, es_un).
hereda(propietario, parte_de).
hereda(concesionarios, parte_de).
hereda(fabricado, parte_de).
hereda(edad, parte_de).
hereda(marca, parte_de).
hereda(modelo, parte_de).

% anio_actual(A): el año en que se calculan las edades: el del libro.
anio_actual(1987).

% --- Los valores ---------------------------------------------------------

%!  propio(?Objeto, ?Ranura, ?Valor) is nondet.
%
%   El marco Objeto tiene Valor en Ranura sin heredarlo: guardado, o
%   derivado de otro valor guardado (tiene_parte de parte_de, la edad del
%   año de fabricación).
propio(O, R, V) :-
    valor(O, R, V).
propio(O, tiene_parte, P) :-
    valor(P, parte_de, O).
propio(O, edad, E) :-
    valor(O, fabricado, A),
    anio_actual(Hoy),
    E is Hoy - A.

%!  tiene_valor(+Objeto, +Ranura, -Valor) is nondet.
%
%   Valor es el valor de Ranura en el marco Objeto: los propios, si los
%   hay; si no, los heredados por las relaciones que Ranura admite, y los
%   del concepto del que Objeto es la extensión. Valor debe llegar libre:
%   con un valor propio distinto, el heredado no se examina.
tiene_valor(O, R, V) :-
    (   propio(O, R, _)
    ->  propio(O, R, V)
    ;   hereda(R, Relacion),
        valor(O, Relacion, Superior),
        tiene_valor(Superior, R, V)
    ;   valor(O, intension, I),
        tiene_valor(I, R, V)
    ).

%!  tiene_ranura(+Objeto, ?Ranura) is nondet.
%
%   El marco Objeto tiene la ranura Ranura, llena o no: propia, de una
%   clase más general por es_un, o del concepto del que es la extensión.
%   Puede dar la misma ranura más de una vez.
tiene_ranura(O, R) :-
    (   ranura(O, R)
    ;   valor(O, R, _)
    ;   valor(O, es_un, Superior),
        tiene_ranura(Superior, R)
    ;   valor(O, intension, I),
        tiene_ranura(I, R)
    ).

%!  ranuras(+Objeto, -Ranuras:list) is det.
%
%   Ranuras son las ranuras del marco Objeto, sin repetir y en orden.
ranuras(O, Ranuras) :-
    (   setof(R, tiene_ranura(O, R), Ranuras)
    ->  true
    ;   Ranuras = []
    ).

%!  tiene_unidades(+Objeto, +Ranura, -Unidades) is semidet.
%
%   Los valores de Ranura en Objeto se miden en Unidades: lo dice el marco
%   o el más cercano de los más generales.
tiene_unidades(O, R, U) :-
    (   unidades(O, R, U0)
    ->  U = U0
    ;   valor(O, es_un, Superior)
    ->  tiene_unidades(Superior, R, U)
    ;   valor(O, intension, I),
        tiene_unidades(I, R, U)
    ).

%!  fuera_de_lo_posible(+Objeto, -Ranura, -Valor) is nondet.
%
%   Valor, el valor de Ranura en Objeto, no está entre los valores
%   posibles que un marco más general admite para Ranura.
fuera_de_lo_posible(O, R, V) :-
    valores_posibles(Clase, R, Posibles),
    es_un_de(O, Clase),
    tiene_valor(O, R, V),
    \+ memberchk(V, Posibles).

%!  es_un_de(+Objeto, ?Clase) is nondet.
%
%   Clase es Objeto o una clase más general, por es_un.
es_un_de(O, O).
es_un_de(O, Clase) :-
    valor(O, es_un, Superior),
    es_un_de(Superior, Clase).
