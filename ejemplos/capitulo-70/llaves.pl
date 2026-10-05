:- encoding(utf8).

% Capítulo 70 - El mundo de las llaves y las cajas.
%
% Una versión del problema que Warren resuelve en el apéndice de su memo
% de 1974, a su vez una simplificación de una prueba de Donald Michie.
% Adentro hay cuatro lugares, la mesa, la caja 1, la caja 2 y la puerta;
% afuera hay un solo lugar. Las llaves 1 y 2 están en las cajas y el
% objeto rojo en la puerta. El robot puede ir a un lugar de adentro y
% llevar consigo un objeto, pero solo si es el único que hay en el lugar
% donde está. Solo puede sacar algo afuera si las dos llaves están en la
% puerta. Los hechos son
%
%   robot(L)      el robot está en L;
%   esta(X, L)    el objeto X está en L;
%   solo(X, L)    X es el único objeto en L;
%   vacio(L)      no hay ningún objeto en L.
%
% Como en el memo, llevar un objeto tiene dos versiones según el destino:
% llevar/3 a un lugar vacío, juntar/4 a un lugar donde hay un solo objeto.
% Las precondiciones de cada versión son distintas, y una acción de
% WARPLAN tiene un solo juego de precondiciones.
%
% solo-local: es un módulo, y SWISH no admite módulos propios.
%
%?- plan_de_warren(P), saca_el_rojo(P).

:- module(llaves,
          [ agrega/2,
            borra/2,
            puede/2,
            imposible/1,
            siempre/1,
            prueba/1,
            dado/2,
            distinto/2,
            plan_de_warren/1,
            saca_el_rojo/1
          ]).

:- use_module(regresion, [logra/4]).

%!  agrega(?Hecho, ?Accion) is nondet.
%
%   Accion hace valer Hecho.
agrega(robot(L), ir(L)).
agrega(esta(X, L2), llevar(X, _, L2)).
agrega(solo(X, L2), llevar(X, _, L2)).
agrega(vacio(L1), llevar(_, L1, _)).
agrega(robot(L2), llevar(_, _, L2)).
agrega(esta(X, L2), juntar(X, _, L2, _)).
agrega(vacio(L1), juntar(_, L1, _, _)).
agrega(robot(L2), juntar(_, _, L2, _)).
agrega(esta(X, afuera), sacar(X, _)).
agrega(vacio(L), sacar(_, L)).
agrega(robot(afuera), sacar(_, _)).

%!  borra(?Hecho, ?Accion) is nondet.
%
%   Accion puede hacer que Hecho deje de valer.
borra(robot(_), ir(_)).
borra(robot(_), llevar(_, _, _)).
borra(esta(X, _), llevar(X, _, _)).
borra(solo(X, _), llevar(X, _, _)).
borra(vacio(L2), llevar(_, _, L2)).
borra(robot(_), juntar(_, _, _, _)).
borra(esta(X, _), juntar(X, _, _, _)).
borra(solo(X, _), juntar(X, _, _, _)).
borra(solo(Y, L2), juntar(_, _, L2, Y)).
borra(robot(_), sacar(_, _)).
borra(esta(X, _), sacar(X, _)).
borra(solo(X, _), sacar(X, _)).

%!  puede(?Accion, -Precondiciones:list) is nondet.
%
%   Accion se puede ejecutar donde valen las Precondiciones. Ir a un lugar
%   no exige nada: el robot puede ir a cualquier lugar de adentro.
puede(ir(L), [adentro(L)]).
puede(llevar(X, L1, L2), [vacio(L2), adentro(L2), solo(X, L1), robot(L1),
                          distinto(L1, L2)]).
puede(juntar(X, L1, L2, Y), [solo(Y, L2), solo(X, L1), robot(L1),
                             distinto(L1, L2)]).
puede(sacar(X, L), [esta(llave1, puerta), esta(llave2, puerta), solo(X, L),
                    robot(L)]).

% imposible(Hs): los hechos de Hs no pueden valer juntos.
imposible([robot(L), robot(M), distinto(L, M)]).
imposible([esta(X, L), esta(X, M), distinto(L, M)]).
imposible([solo(X, L), esta(X, M), distinto(L, M)]).
imposible([solo(X, L), solo(Y, L), distinto(X, Y)]).
imposible([vacio(L), esta(_, L)]).
imposible([vacio(L), solo(_, L)]).

% siempre(H): H vale en todo estado.
siempre(adentro(mesa)).
siempre(adentro(caja1)).
siempre(adentro(caja2)).
siempre(adentro(puerta)).

% prueba(H): H se decide llamándolo.
prueba(distinto(_, _)).

%!  distinto(+X, +Y) is semidet.
%
%   X e Y son objetos distintos. Con una variable libre falla.
distinto(X, Y) :-
    X \= Y.

% dado(I, H): H vale en el estado inicial I. En michie el robot no está en
% ningún lugar conocido: el plan empieza por ir a alguno.
dado(michie, vacio(mesa)).
dado(michie, esta(llave1, caja1)).
dado(michie, solo(llave1, caja1)).
dado(michie, esta(llave2, caja2)).
dado(michie, solo(llave2, caja2)).
dado(michie, esta(rojo, puerta)).
dado(michie, solo(rojo, puerta)).

% plan_de_warren(P): P es el plan que el memo de Warren publica para este
% problema, escrito con las acciones de este mundo.
plan_de_warren([ir(puerta), llevar(rojo, puerta, mesa), ir(caja1),
                llevar(llave1, caja1, puerta), ir(caja2),
                juntar(llave2, caja2, puerta, llave1), ir(mesa),
                sacar(rojo, mesa)]).

%!  saca_el_rojo(+Plan:list) is semidet.
%
%   Plan, ejecutado desde el estado inicial michie, deja el objeto rojo
%   afuera: cada acción es ejecutable y la meta vale al final.
saca_el_rojo(Plan) :-
    logra(llaves, michie, Plan, [esta(rojo, afuera)]).
