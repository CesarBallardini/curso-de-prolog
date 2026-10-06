:- encoding(utf8).

% Capítulo 56 - Solución del ejercicio 13: los archivos que comparten dos
% personas, agregados a los predicados multifile, sin modificar
% propietarios.pl.
%
% solo-local: carga el programa del capítulo con ensure_loaded/1.
%
%?- responder_modelo("¿Qué archivos comparte Chris con David?", R).

:- ensure_loaded(propietarios).

:- multifile pedido//1, plan/3, oracion/2.

pedido(compartidos(U1, U2)) -->
    ["que"],
    sustantivo(archivo, _, pl),
    ["comparte"],
    nombre(U1),
    ["con"],
    nombre(U2).

plan(compartidos(U1, U2), M, [informar(compartidos(U1, U2, Rs))]) :-
    usuario(U1, M),
    usuario(U2, M),
    findall(R, ( member(archivo(R, _, _), M),
                 U1 \== U2,
                 acceso(R, U1, M),
                 acceso(R, U2, M) ),
            Rs).

oracion(compartidos(U1, U2, []), T) :-
    !,
    persona(U1, P1),
    persona(U2, P2),
    format(string(T), "~s y ~s no comparten archivos.", [P1, P2]).
oracion(compartidos(U1, U2, Rs), T) :-
    persona(U1, P1),
    persona(U2, P2),
    atomic_list_concat(Rs, ', ', Rutas),
    format(string(T), "~s y ~s comparten ~w.", [P1, P2, Rutas]).
