:- encoding(utf8).

:- use_module(library(http/http_open)).

:- begin_tests(servidor).

%!  codigo(+Url:atom, +Opciones:list, -Codigo:integer) is det.
%
%   Codigo es el código de la última respuesta al pedido de Url.
codigo(Url, Opciones, Codigo) :-
    setup_call_cleanup(http_open(Url, S, [status_code(Codigo)|Opciones]),
                       read_string(S, _, _),
                       close(S)).

% Las páginas de las dos partes y el servicio responden en el mismo puerto;
% una partida nueva lleva a la página de su tablero.
test(todo_en_un_puerto, [ cleanup(detener_api(P)),
                          true(C == [200, 200, 200]) ]) :-
    iniciar(P),
    format(atom(Materias), "http://127.0.0.1:~w/pagina/materias", [P]),
    format(atom(Ranking), "http://127.0.0.1:~w/ranking", [P]),
    format(atom(Juego), "http://127.0.0.1:~w/juego", [P]),
    codigo(Materias, [], C1),
    codigo(Ranking, [], C2),
    codigo(Juego, [method(post), post(form([]))], C3),
    C = [C1, C2, C3].

:- end_tests(servidor).
