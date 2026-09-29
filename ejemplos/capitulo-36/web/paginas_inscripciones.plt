:- encoding(utf8).

% Pruebas de las páginas: los cuerpos se prueban como términos y como
% texto, y las rutas con pedidos HTTP reales a un servidor en un puerto libre
% (Patrón 41).

:- use_module(library(http/http_open)).
:- use_module(library(http/html_write)).
:- use_module('../../capitulo-31/inscripciones/datos').

:- dynamic puerto_de_prueba/1.

%!  arrancar_para_pruebas is det.
%
%   Arranca el servidor en un puerto libre y lo recuerda.
arrancar_para_pruebas :-
    iniciar_api(Puerto),
    assertz(puerto_de_prueba(Puerto)).

%!  parar_despues_de_pruebas is det.
%
%   Detiene el servidor de las pruebas.
parar_despues_de_pruebas :-
    retract(puerto_de_prueba(Puerto)),
    detener_api(Puerto).

%!  pedir(+Ruta:atom, +Opciones:list, -Codigo:integer, -Texto:string) is det.
%
%   Hace el pedido de Ruta con Opciones; Codigo es el código de estado y
%   Texto el cuerpo de la respuesta.
pedir(Ruta, Opciones, Codigo, Texto) :-
    puerto_de_prueba(Puerto),
    format(atom(Url), "http://127.0.0.1:~w~w", [Puerto, Ruta]),
    setup_call_cleanup(
        http_open(Url, S, [status_code(Codigo)|Opciones]),
        read_string(S, _, Texto),
        close(S)).

%!  como_texto(+Cuerpo, -Texto:string) is det.
%
%   Texto es el HTML que html//1 escribe para Cuerpo.
como_texto(Cuerpo, Texto) :-
    phrase(html(Cuerpo), Tokens),
    with_output_to(string(Texto), print_html(Tokens)).

:- begin_tests(paginas_inscripciones,
               [ setup(arrancar_para_pruebas),
                 cleanup(parar_despues_de_pruebas) ]).

test(materias, true(Fila == tr([td(log),
                                td(a(href('/pagina/materias/log'), logica)),
                                td(4)]))) :-
    cuerpo_materias([_, table(Filas)]),
    nth1(4, Filas, Fila).

test(materia_inexistente, fail) :-
    cuerpo_materia(quimica, _).

test(resultado_aceptada,
     true(C == [ h1('Inscripción'),
                 p('Aceptada: 104 en ssl.'),
                 p(a(href('/pagina/materias/ssl'), 'Volver')) ])) :-
    cuerpo_resultado(104, ssl-aceptada, C).

test(resultado_rechazada,
     true(T == 'Rechazada: 103 en ssl, falta(log).')) :-
    cuerpo_resultado(103, ssl-rechazada(falta(log)), [_, p(T), _]).

% html//1 reemplaza los caracteres especiales de HTML en el texto.
test(texto_escapado, true(T == "\n\n<p>\na &lt; b &amp; c</p>")) :-
    como_texto(p('a < b & c'), T).

test(pagina, true(C == 200)) :-
    pedir('/pagina/materias/log', [], C, Texto),
    once(sub_string(Texto, _, _, _, "<li>104 diego</li>")),
    once(sub_string(Texto, _, _, _, "Promedio: 7.00")).

% Una materia sin inscriptos: la lista vacía y el promedio sin notas.
test(materia_sin_inscriptos,
     true(C == [h1(bases_de_datos), ul([]), p('Promedio: sin notas')])) :-
    cuerpo_materia(bd, [H, U, P|_]),
    C = [H, U, P].

test(pagina_materias, true(C == 200)) :-
    pedir('/pagina/materias', [], C, Texto),
    once(sub_string(Texto, _, _, _, "href=\"/pagina/materias/log\"")).

test(pagina_404, true(C == 404)) :-
    pedir('/pagina/materias/quimica', [], C, _).

test(formulario, true(C-Aceptada == 200-true)) :-
    estado(E),
    setup_call_cleanup(
        true,
        pedir('/pagina/inscribir',
              [post(form([legajo='104', materia=ssl]))], C, Texto),
        restaurar(E)),
    (   sub_string(Texto, _, _, _, "Aceptada: 104 en ssl.")
    ->  Aceptada = true
    ;   Aceptada = false
    ).

test(legajo_no_numerico, true(C == 400)) :-
    pedir('/pagina/inscribir', [post(form([legajo=abc, materia=ssl]))],
          C, _).

% Las rutas de JSON del capítulo 31 siguen en el mismo servidor.
test(json_en_el_mismo_servidor, true(C == 200)) :-
    pedir('/ranking', [], C, _).

:- end_tests(paginas_inscripciones).
