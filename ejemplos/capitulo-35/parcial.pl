:- encoding(utf8).

% Capítulo 35 - Un evaluador parcial: ejecuta, antes de la consulta, la
% parte de un objetivo que no depende de los datos de la consulta.
%
% parcial/3 recorre un objetivo como un intérprete, pero en lugar de
% probarlo lo reemplaza por un residuo: las unificaciones se hacen, y las
% llamadas que el control indica se despliegan con sus cláusulas; el resto
% queda como está. El control es un predicado que recibe cada llamada y
% responde desplegar o dejar(R). Lo usan especializar.pl y experto.pl.
% potencia/3, con el exponente en números de Peano, es el ejemplo.
%
%?- parcial(potencia(s(s(s(cero))), X, Y), control_potencia, R).
%?- parcial(potencia(N, X, Y), control_potencia, R).

%!  parcial(+Meta, :Control, -Residuo) is nondet.
%
%   Residuo es Meta con las unificaciones hechas y cada llamada G tratada
%   según call(Control, G, Accion): desplegar, o dejar(R). Una respuesta por
%   cada combinación de cláusulas desplegadas.
parcial(true, _, true) :-
    !.
parcial((A, B), Control, Residuo) :-
    !,
    parcial(A, Control, RA),
    parcial(B, Control, RB),
    conjuncion(RA, RB, Residuo).
parcial(X = Y, _, true) :-
    !,
    X = Y.
parcial(Meta, Control, Residuo) :-
    call(Control, Meta, Accion),
    !,
    accion(Accion, Meta, Control, Residuo).
parcial(Meta, _, Meta).

%!  accion(+Accion, +Meta, :Control, -Residuo) is nondet.
%
%   Residuo es lo que queda de Meta según Accion: desplegar, o dejar(R).
accion(desplegar, Meta, Control, Residuo) :-
    clause(Meta, Cuerpo),
    parcial(Cuerpo, Control, Residuo).
accion(dejar(Residuo), _, _, Residuo).

%!  conjuncion(+A, +B, -AB) is det.
%
%   AB es la conjunción de A y B, sin los true que sobran y agrupada a la
%   derecha, como se escribe: (A1, (A2, B)).
conjuncion(true, B, B) :-
    !.
conjuncion(A, true, A) :-
    !.
conjuncion((A1, A2), B, (A1, AB)) :-
    !,
    conjuncion(A2, B, AB).
conjuncion(A, B, (A, B)).

%!  potencia(+N, +X:number, -Y:number) is det.
%
%   Y es X elevado a N, un natural de Peano: cero, s(cero), ...
potencia(cero, _, 1).
potencia(s(N), X, Y) :-
    potencia(N, X, Y0),
    Y is X * Y0.

%!  control_potencia(+Meta, -Accion) is semidet.
%
%   potencia/3 se despliega si su exponente es conocido.
control_potencia(potencia(N, _, _), desplegar) :-
    nonvar(N).
