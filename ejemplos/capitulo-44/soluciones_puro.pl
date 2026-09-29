:- encoding(utf8).

% Capítulo 44 - Solución del ejercicio 10: el núcleo con el estado en
% argumentos, para mirar, ir, tomar y dejar.
%
% El estado es la lista ordenada de hechos que da instantanea/1. paso/4 no
% consulta ni modifica la base de datos: recibe un estado y da el
% siguiente. Sus impedimentos y efectos repiten, sobre la lista, las
% cláusulas de estado.pl para esas cuatro órdenes, en el mismo orden.
%
% solo-local: carga los módulos del capítulo, y SWISH no admite módulos
% propios.
%
%?- findall(H, mundo:inicio(H), E0), sort(E0, E), paso(ir(biblioteca), E, _, R).

:- module(soluciones_puro,
          [ paso/4,
            pasos/4
          ]).

:- use_module(mundo).

%!  pasos(+Ordenes:list, +Estado0:list, -Estado:list, -Respuestas:list)
%!      is det.
%
%   Aplica Ordenes una tras otra a partir de Estado0.
pasos(Ordenes, Estado0, Estado, Respuestas) :-
    foldl(paso_acumulado, Ordenes, Respuestas, Estado0, Estado).

%!  paso_acumulado(+Orden, -Respuesta, +Estado0:list, -Estado:list) is det.
%
%   paso/4 con los argumentos en el orden que pide foldl/5.
paso_acumulado(Orden, Respuesta, Estado0, Estado) :-
    paso(Orden, Estado0, Estado, Respuesta).

%!  paso(+Orden, +Estado0:list, -Estado:list, -Respuesta) is det.
%
%   Estado y Respuesta son el estado y la respuesta después de Orden, que
%   es mirar, ir(S), tomar(O) o dejar(O).
paso(Orden, Estado0, Estado, Respuesta) :-
    (   impedimento_en(Estado0, Orden, Motivo)
    ->  Estado = Estado0,
        Respuesta = no_puede(Motivo)
    ;   efecto_en(Orden, Estado0, Estado, Respuesta)
    ).

%!  impedimento_en(+E:list, +Orden, -Motivo) is nondet.
%
%   Motivo impide ejecutar Orden en el estado E.
impedimento_en(E, ir(S), ya_esta(S)) :-
    memberchk(aqui(S), E).
impedimento_en(E, ir(S), no_hay_paso(S)) :-
    memberchk(aqui(A), E),
    \+ conecta(_, A, S).
impedimento_en(E, ir(S), cerrado(P)) :-
    memberchk(aqui(A), E),
    conecta(P, A, S),
    memberchk(cerrada(P), E).
impedimento_en(E, tomar(_), oscuro) :-
    a_oscuras_en(E).
impedimento_en(E, dejar(O), no_lo_tiene(O)) :-
    \+ memberchk(esta_en(O, jugador), E).
impedimento_en(E, tomar(O), no_esta(O)) :-
    \+ al_alcance_en(E, O).
impedimento_en(E, tomar(O), ya_lo_tiene(O)) :-
    memberchk(esta_en(O, jugador), E).
impedimento_en(_, tomar(O), fijo(O)) :-
    (   fijo(O)
    ->  true
    ;   \+ objeto(O)
    ).

%!  efecto_en(+Orden, +E0:list, -E:list, -Respuesta) is det.
%
%   Aplica Orden, que ningún impedimento bloquea, al estado E0.
efecto_en(mirar, E, E, Respuesta) :-
    vista_en(E, Respuesta).
efecto_en(ir(S), E0, E, Respuesta) :-
    reemplazar(aqui(_), aqui(S), E0, E),
    vista_en(E, Respuesta).
efecto_en(tomar(O), E0, E, tomado(O)) :-
    reemplazar(esta_en(O, _), esta_en(O, jugador), E0, E).
efecto_en(dejar(O), E0, E, dejado(O, S)) :-
    memberchk(aqui(S), E0),
    reemplazar(esta_en(O, _), esta_en(O, S), E0, E).

%!  reemplazar(+Viejo, +Nuevo, +E0:list, -E:list) is det.
%
%   E es E0, ordenado, con el primer hecho que unifica con Viejo
%   reemplazado por Nuevo.
reemplazar(Viejo, Nuevo, E0, E) :-
    selectchk(Viejo, E0, E1),
    sort([Nuevo|E1], E).

%!  vista_en(+E:list, -Respuesta) is det.
%
%   Lo que se ve en la sala actual del estado E.
vista_en(E, Respuesta) :-
    (   a_oscuras_en(E)
    ->  Respuesta = oscuridad
    ;   memberchk(aqui(S), E),
        findall(O, member(esta_en(O, S), E), Os0),
        sort(Os0, Os),
        findall(D, conecta(_, S, D), Salidas),
        Respuesta = vista(S, Os, Salidas)
    ).

%!  al_alcance_en(+E:list, ?X) is nondet.
%
%   X está al alcance en el estado E, como en al_alcance/1.
al_alcance_en(E, X) :-
    memberchk(aqui(S), E),
    conecta(X, S, _).
al_alcance_en(E, X) :-
    member(esta_en(X, L), E),
    accesible_en(E, L).

%!  accesible_en(+E:list, +L) is semidet.
%
%   Lo que está en L está al alcance en el estado E.
accesible_en(_, jugador).
accesible_en(E, S) :-
    memberchk(aqui(S), E).
accesible_en(E, R) :-
    recipiente(R),
    \+ memberchk(cerrada(R), E),
    al_alcance_en(E, R).

%!  a_oscuras_en(+E:list) is semidet.
%
%   En el estado E, la sala actual es oscura y no hay una luz encendida
%   al alcance.
a_oscuras_en(E) :-
    memberchk(aqui(S), E),
    oscura(S),
    \+ ( luz(L),
         memberchk(encendido(L), E),
         al_alcance_en(E, L) ).
