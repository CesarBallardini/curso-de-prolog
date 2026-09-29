:- encoding(utf8).

% El servidor arranca con tres trabajadores al empezar la unidad. Las
% pruebas comparan conjuntos y cantidades: qué trabajador atiende cada
% pedido depende del orden de los hilos. /contar, sin mutex, no se prueba
% con pedidos simultáneos: la sección 37.6 muestra su resultado.

:- dynamic puerto_de_prueba/1.

%!  arrancar is det.
%
%   Arranca el servidor de las pruebas en un puerto libre.
arrancar :-
    iniciar(Puerto, 3),
    assertz(puerto_de_prueba(Puerto)).

%!  parar is det.
%
%   Detiene el servidor de las pruebas.
parar :-
    retract(puerto_de_prueba(Puerto)),
    detener(Puerto).

:- begin_tests(servidor, [setup(arrancar), cleanup(parar)]).

% Treinta pedidos, atendidos por los tres trabajadores o por algunos de
% ellos: nunca por otro hilo.
test(trabajadores, [true(subset(Hilos, Trabajadores))]) :-
    puerto_de_prueba(P),
    muchos_pedidos(P, hilo, 30, Hilos),
    assertion(Hilos \== []),
    findall(T, ( between(1, 3, I),
                 format(string(T), "httpd@localhost:~w_~w", [P, I]) ),
            Trabajadores).

test(tres, [true(N == 3)]) :-
    puerto_de_prueba(P),
    http_workers(P, N).

% Quinientos pedidos simultáneos con el mutex: ninguno se pierde.
test(con_mutex, [true(Codigos-V == [200-500]-500)]) :-
    puerto_de_prueba(P),
    sin_visitas,
    muchos_pedidos(P, contar_seguro, 500, Codigos),
    visitas(V).

% De a uno, /contar también cuenta bien.
test(de_a_uno, [true(Rs-V == [200-1, 200-2, 200-3]-3)]) :-
    puerto_de_prueba(P),
    sin_visitas,
    findall(C-N, ( between(1, 3, _),
                   pedir(P, contar, C, R),
                   get_dict(visitas, R, N) ), Rs),
    visitas(V).

:- end_tests(servidor).
