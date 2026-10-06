:- encoding(utf8).

% Pruebas de las páginas: los cuerpos se prueban como términos y como
% texto, y las rutas con pedidos HTTP reales a un servidor en un puerto
% libre, como las páginas del capítulo 36.

:- use_module(library(http/http_open)).
:- use_module(library(http/html_write)).

:- dynamic puerto_de_prueba/1.

%!  arrancar_para_pruebas is det.
%
%   Arranca el servidor en un puerto libre y lo recuerda.
arrancar_para_pruebas :-
    iniciar_web(Puerto),
    assertz(puerto_de_prueba(Puerto)).

%!  parar_despues_de_pruebas is det.
%
%   Detiene el servidor de las pruebas.
parar_despues_de_pruebas :-
    retract(puerto_de_prueba(Puerto)),
    detener_web(Puerto).

%!  pedir(+Ruta:atom, -Codigo:integer, -Texto:string) is det.
%
%   Hace el pedido GET de Ruta; Codigo es el código de estado y Texto el
%   cuerpo de la respuesta.
pedir(Ruta, Codigo, Texto) :-
    puerto_de_prueba(Puerto),
    format(atom(Url), "http://127.0.0.1:~w~w", [Puerto, Ruta]),
    setup_call_cleanup(
        http_open(Url, S, [status_code(Codigo)]),
        read_string(S, _, Texto),
        close(S)).

%!  como_texto(+Cuerpo, -Texto:string) is det.
%
%   Texto es el HTML que html//1 escribe para Cuerpo.
como_texto(Cuerpo, Texto) :-
    phrase(html(Cuerpo), Tokens),
    with_output_to(string(Texto), print_html(Tokens)).

:- begin_tests(web, [ setup(arrancar_para_pruebas),
                      cleanup(parar_despues_de_pruebas) ]).

test(celda_con_clase, [true(Td == td([b(bases_de_datos), br([]), lab]))]) :-
    oferta(cuatrimestre, O),
    horario_ejemplo(H),
    celda_html(O, H, 3, 1, 4, Td).

test(celda_vacia, [true(Td == td([]))]) :-
    oferta(cuatrimestre, O),
    horario_ejemplo(H),
    celda_html(O, H, 3, 2, 4, Td).

test(celda_sin_nombre, [true(Td == td([b(m1), br([]), a1]))]) :-
    oferta(facultad(1), O),
    celda_html(O, [asignada(m1-1, 1, 0, 1)], 1, 1, 1, Td).

test(filas_y_columnas, [true(N-M == 5-6)]) :-
    oferta(cuatrimestre, O),
    horario_ejemplo(H),
    cuerpo_anio(O, H, 1, [_, table(_, Filas), _]),
    length(Filas, N),
    Filas = [tr(Encabezado)|_],
    length(Encabezado, M).

test(indice, [true(Items == [ li(a(href('/horario/1'), 'Año 1')),
                              li(a(href('/horario/2'), 'Año 2')),
                              li(a(href('/horario/3'), 'Año 3')) ])]) :-
    oferta(cuatrimestre, O),
    cuerpo_indice(O, [_, ul(Items)]).

test(como_texto) :-
    oferta(cuatrimestre, O),
    horario_ejemplo(H),
    cuerpo_anio(O, H, 3, Cuerpo),
    como_texto(Cuerpo, Texto),
    sub_string(Texto, _, _, _, "<b>bases_de_datos</b>"),
    !.

test(pagina_anio, [true(Codigo == 200)]) :-
    pedir('/horario/1', Codigo, Texto),
    sub_string(Texto, _, _, _, "<b>analisis_1</b>"),
    !.

test(pagina_indice, [true(Codigo == 200)]) :-
    pedir('/horario', Codigo, Texto),
    sub_string(Texto, _, _, _, "/horario/3"),
    !.

test(anio_inexistente, [true(Codigo == 404)]) :-
    pedir('/horario/7', Codigo, _).

:- end_tests(web).
