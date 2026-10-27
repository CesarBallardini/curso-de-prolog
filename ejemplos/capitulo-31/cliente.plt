:- encoding(utf8).

% Pruebas de cliente.pl, contra el servidor de servidor.pl en un puerto
% libre.

:- ensure_loaded(servidor).

:- dynamic base_de_prueba/1.

%!  arrancar_para_pruebas is det.
%
%   Arranca el servidor en un puerto libre y recuerda su dirección base.
arrancar_para_pruebas :-
    iniciar(Puerto),
    format(atom(Base), "http://localhost:~w", [Puerto]),
    assertz(base_de_prueba(Base)).

%!  parar_despues_de_pruebas is det.
%
%   Detiene el servidor de las pruebas.
parar_despues_de_pruebas :-
    retract(base_de_prueba(Base)),
    atomic_list_concat([_, _, Puerto], ':', Base),
    atom_number(Puerto, Numero),
    detener(Numero).

:- begin_tests(cliente, [ setup(arrancar_para_pruebas),
                          cleanup(parar_despues_de_pruebas) ]).

test(direccion, true(U == 'http://s/nietos?abuelo=juan%20p%C3%A9rez')) :-
    direccion('http://s', '/nietos', [abuelo='juan pérez'], U).

test(direccion_sin_parametros, true(U == 'http://s/hola')) :-
    direccion('http://s', '/hola', [], U).

test(ficha_remota, true(E-H == 41-["luis", "eva"])) :-
    base_de_prueba(Base),
    ficha_remota(Base, ana, F),
    E = F.edad,
    H = F.hijos.

test(ficha_inexistente, fail) :-
    base_de_prueba(Base),
    ficha_remota(Base, zoe, _).

test(nietos_remotos, true(N == ["luis", "eva"])) :-
    base_de_prueba(Base),
    nietos_remotos(Base, juan, N).

test(sin_nietos, true(N == [])) :-
    base_de_prueba(Base),
    nietos_remotos(Base, 'juan pérez', N).

test(cambiar_edad_remota, [ cleanup(cambiar_edad(juan, 68)),
                            true(C-E == 201-70) ]) :-
    base_de_prueba(Base),
    cambiar_edad_remota(Base, juan, 70, C),
    edad(juan, E).

test(edad_rechazada, true(C == 400)) :-
    base_de_prueba(Base),
    cambiar_edad_remota(Base, juan, -1, C).

:- end_tests(cliente).
