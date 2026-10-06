:- encoding(utf8).

% Capítulo 53 - Soluciones de los ejercicios 14 y 15.
%
% Carga la versión 6, que carga la 5 y la 4.
%
% solo-local: carga módulos.
%
%?- regla_dos_niveles(jota_g, P, O, I, D), compilar(P, O, I, D, Ps).
%?- findall(P, derivada(P, prefijo("in", _)), Ps).

:- ensure_loaded(derivacion).

:- discontiguous regla_dos_niveles/5.

% Ejercicio 14: la regla jota en la notación de dos niveles, como dos
% reglas. No se registran: la versión 3 ya tiene la regla jota.
regla_dos_niveles(jota_g, ['J']:[g], '<=>', [],
                  [[limite, frontal], [frontal]]).
regla_dos_niveles(jota_j, [j]:[j], '=>', [],
                  [[limite, frontal], [frontal]]).

% Ejercicio 15: la N de in- se escribe r ante r (irreal) y no se escribe
% ante l (ilegal).
dos_niveles:par(['N']:[r]).
dos_niveles:par(['N']:[]).
regla_dos_niveles(nasal_r, ['N']:[r], '<=>', [],
                  [[limite, par([r]:[r])]]).
regla_dos_niveles(nasal_l, ['N']:[], '<=>', [],
                  [[limite, par([l]:[l])]]).
dos_niveles:regla(Nombre, Patrones) :-
    member(Nombre, [nasal_r, nasal_l]),
    regla_dos_niveles(Nombre, Par, Op, Izquierda, Derechas),
    compilar(Par, Op, Izquierda, Derechas, Patrones).

lexico:adjetivo("real", invariable).
lexico:adjetivo("legal", invariable).
admite_in("real").
admite_in("legal").
