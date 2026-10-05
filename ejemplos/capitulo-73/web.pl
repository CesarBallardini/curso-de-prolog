:- encoding(utf8).

% Capítulo 73 - Versión 6: la grilla web del horario.
%
% Cada año del plan tiene una página con su grilla: una tabla con los días
% en las columnas, las franjas en las filas y, en cada casilla, la materia
% y el aula de la clase. La página es un término de html//1 (capítulo 36)
% que arma un predicado puro, cuerpo_anio/4, a partir de la oferta y del
% horario; el manejador solo calcula el horario de costo mínimo y responde
% con reply_html_page/2.
%
%     GET /horario          los enlaces a la grilla de cada año
%     GET /horario/{anio}   la grilla del año
%
% solo-local: abre un puerto, y SWISH no permite cargar otro archivo.
%
%?- oferta(cuatrimestre, O), horario_ejemplo(H), cuerpo_anio(O, H, 3, C).
%?- iniciar_web(Puerto), detener_web(Puerto).

:- module(web,
          [ cuerpo_anio/4,
            cuerpo_indice/2,
            celda_html/6,
            iniciar_web/1,
            detener_web/1
          ]).

:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/html_write)).
:- use_module('../capitulo-31/inscripciones/datos', [materia/3]).
:- reexport(optimo).

:- http_handler(root(horario), pagina_indice, [method(get)]).
:- http_handler(root(horario/Anio), pagina_anio(Anio), [method(get)]).

%!  iniciar_web(?Puerto:integer) is det.
%
%   Arranca el servidor de las páginas en Puerto de la máquina local; con
%   Puerto libre, elige uno que no esté en uso.
iniciar_web(Puerto) :-
    http_server(http_dispatch, [port(localhost:Puerto)]).

%!  detener_web(+Puerto:integer) is det.
%
%   Detiene el servidor de Puerto.
detener_web(Puerto) :-
    http_stop_server(Puerto, []).

%!  horario_publicado(-Oferta, -Horario:list) is det.
%
%   Horario es el horario de costo mínimo de la oferta cuatrimestre, el
%   que publican las páginas.
horario_publicado(Oferta, Horario) :-
    oferta(cuatrimestre, Oferta),
    optimo(Oferta, cotas, Horario, _).

%!  pagina_indice(+Pedido) is det.
%
%   GET /horario.
pagina_indice(_Pedido) :-
    oferta(cuatrimestre, Oferta),
    cuerpo_indice(Oferta, Cuerpo),
    reply_html_page(title('Horarios'), Cuerpo).

%!  pagina_anio(+Texto:atom, +Pedido) is det.
%
%   GET /horario/Texto: la grilla del año Texto, o 404 si no es un año
%   del plan.
pagina_anio(Texto, Pedido) :-
    horario_publicado(Oferta, Horario),
    (   atom_number(Texto, Anio),
        grupo(Oferta, anio(Anio))
    ->  cuerpo_anio(Oferta, Horario, Anio, Cuerpo),
        format(atom(Titulo), "Año ~w", [Anio]),
        reply_html_page(title(Titulo), Cuerpo)
    ;   http_404([], Pedido)
    ).

%!  cuerpo_indice(+Oferta, -Cuerpo:list) is det.
%
%   Cuerpo es la página con un enlace a la grilla de cada año de Oferta.
cuerpo_indice(Oferta, [h1('Horarios'), ul(Items)]) :-
    findall(li(a(href(Enlace), Texto)),
            ( grupo(Oferta, anio(Anio)),
              format(atom(Enlace), "/horario/~w", [Anio]),
              format(atom(Texto), "Año ~w", [Anio]) ),
            Items).

%!  cuerpo_anio(+Oferta, +Horario:list, +Anio:integer, -Cuerpo:list) is det.
%
%   Cuerpo es la página de la grilla del año Anio en Horario: un título y
%   una tabla con una columna por día y una fila por franja.
cuerpo_anio(Oferta, Horario, Anio,
            [ h1(Titulo),
              table(class(horario), [tr([th('Franja')|Encabezados])|Filas]),
              p(a(href('/horario'), 'Todos los años'))
            ]) :-
    Oferta = oferta(semana(Dias, Franjas), _, _, _),
    format(atom(Titulo), "Horario de ~wº año", [Anio]),
    numlist(1, Dias, Ds),
    maplist(encabezado, Ds, Encabezados),
    numlist(1, Franjas, Fs),
    maplist(fila_html(Oferta, Horario, Anio, Ds), Fs, Filas).

%!  encabezado(+Dia:integer, -Th) is det.
%
%   Th es la celda de encabezado del día Dia.
encabezado(Dia, th(Nombre)) :-
    nth1(Dia, ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes'], Nombre).

%!  fila_html(+Oferta, +Horario:list, +Anio:integer, +Dias:list,
%!            +Franja:integer, -Tr) is det.
%
%   Tr es la fila de la franja Franja: su hora y una celda por día.
fila_html(Oferta, Horario, Anio, Dias, Franja, tr([th(Hora)|Celdas])) :-
    Desde is 6 + 2 * Franja,
    Hasta is Desde + 2,
    format(atom(Hora), "~w a ~w", [Desde, Hasta]),
    maplist(celda_html(Oferta, Horario, Anio, Franja), Dias, Celdas).

%!  celda_html(+Oferta, +Horario:list, +Anio:integer, +Franja:integer,
%!             +Dia:integer, -Td) is det.
%
%   Td es la casilla del día Dia y la franja Franja: el nombre de la
%   materia de la clase del año Anio, con su aula, o una casilla vacía.
%   El nombre sale del módulo datos de Inscripciones; una materia que no
%   está allí, como las de las ofertas facultad(N), muestra su código.
celda_html(Oferta, Horario, Anio, Franja, Dia, Td) :-
    momento(Oferta, S, Dia, Franja),
    (   member(asignada(C, A, S, _), Horario),
        clase(Oferta, C, M, Anio, _, _)
    ->  (   materia(M, Nombre, _)
        ->  true
        ;   Nombre = M
        ),
        aula(Oferta, A, Aula, _),
        Td = td([b(Nombre), br([]), Aula])
    ;   Td = td([])
    ).
