:- encoding(utf8).

% Capítulo 10 - Prescindir de \+.
%
% Cada predicado de por_negacion.pl y negacion.pl que usa \+, escrito de dos
% maneras más: con corte y falla, que es la definición de \+ escrita a mano, y
% sin negación, con los datos repetidos en una lista y un recorrido.
%
%?- mayor_edad_con_corte(Quien).
%?- mayor_edad_sin_negacion(Quien).

% persona(P): P es una de las personas de la base.
persona(juan).
persona(ana).
persona(pedro).
persona(luis).
persona(eva).

% padre(P, H): P es el padre de H.
padre(juan, ana).
padre(juan, pedro).
padre(pedro, luis).
padre(pedro, eva).

% edad(P, A): P tiene A años.
edad(juan, 68).
edad(ana, 41).
edad(pedro, 39).
edad(luis, 12).
edad(eva, 8).

% personas(L): L es la lista de todas las personas. Repite persona/1.
personas([juan, ana, pedro, luis, eva]).

% hijos(P, L): L es la lista de los hijos de P. Repite padre/2.
hijos(juan, [ana, pedro]).
hijos(pedro, [luis, eva]).

% --- mayor_edad/1 ------------------------------------------------------------

%!  mayor_edad_con_corte(?P) is nondet.
%
%   P tiene la mayor edad de la base, sin \+: la negación está escrita a mano
%   en ninguna_mayor/1.
mayor_edad_con_corte(P) :-
    edad(P, E),
    ninguna_mayor(E).

%!  ninguna_mayor(+E) is semidet.
%
%   Ninguna edad de la base es mayor que E. Si se encuentra una, el corte
%   descarta la segunda cláusula y fail hace fallar al predicado.
ninguna_mayor(E) :-
    edad(_, Otra),
    Otra > E,
    !,
    fail.
ninguna_mayor(_).

%!  mayor_edad_sin_negacion(?P) is semidet.
%
%   P tiene la mayor edad de la base, sin negación: recorre la lista de las
%   personas y conserva la mayor edad vista. Con empate, responde solo la
%   primera.
mayor_edad_sin_negacion(P) :-
    personas([Primera|Resto]),
    edad(Primera, E),
    mayor_desde(Resto, Primera, E, P).

%!  mayor_desde(+L, +Hasta, +E, -P) is det.
%
%   P es la persona de mayor edad entre Hasta, de edad E, y las de L.
mayor_desde([], P, _, P).
mayor_desde([Q|Resto], _, E, P) :-
    edad(Q, EQ),
    EQ > E,
    mayor_desde(Resto, Q, EQ, P).
mayor_desde([Q|Resto], Hasta, E, P) :-
    edad(Q, EQ),
    EQ =< E,
    mayor_desde(Resto, Hasta, E, P).

% --- hijo_menor/2 ------------------------------------------------------------

%!  hijo_menor_con_corte(?P, ?H) is nondet.
%
%   H es el hijo de menor edad de P, sin \+.
hijo_menor_con_corte(P, H) :-
    padre(P, H),
    edad(H, E),
    ningun_hermano_menor(P, E).

%!  ningun_hermano_menor(+P, +E) is semidet.
%
%   Ningún hijo de P tiene menos de E años.
ningun_hermano_menor(P, E) :-
    padre(P, Otro),
    edad(Otro, E2),
    E2 < E,
    !,
    fail.
ningun_hermano_menor(_, _).

%!  hijo_menor_sin_negacion(?P, ?H) is nondet.
%
%   H es el hijo de menor edad de P, sin negación: recorre la lista de los
%   hijos de P y conserva la menor edad vista.
hijo_menor_sin_negacion(P, H) :-
    hijos(P, [Primero|Resto]),
    edad(Primero, E),
    menor_desde(Resto, Primero, E, H).

%!  menor_desde(+L, +Hasta, +E, -H) is det.
%
%   H es la persona de menor edad entre Hasta, de edad E, y las de L.
menor_desde([], H, _, H).
menor_desde([Q|Resto], _, E, H) :-
    edad(Q, EQ),
    EQ < E,
    menor_desde(Resto, Q, EQ, H).
menor_desde([Q|Resto], Hasta, E, H) :-
    edad(Q, EQ),
    EQ >= E,
    menor_desde(Resto, Hasta, E, H).

% --- hijo_unico/1 ------------------------------------------------------------

%!  hijo_unico_con_corte(?H) is nondet.
%
%   H tiene un padre, y ese padre no tiene otros hijos. Sin \+.
hijo_unico_con_corte(H) :-
    padre(P, H),
    sin_otro_hijo(P, H).

%!  sin_otro_hijo(+P, +H) is semidet.
%
%   P no tiene ningún hijo que no sea H.
sin_otro_hijo(P, H) :-
    padre(P, Otro),
    Otro \== H,
    !,
    fail.
sin_otro_hijo(_, _).

%!  hijo_unico_sin_negacion(?H) is nondet.
%
%   H es el único elemento de la lista de hijos de su padre.
hijo_unico_sin_negacion(H) :-
    hijos(_, [H]).
