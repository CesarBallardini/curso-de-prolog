:- encoding(utf8).

% Capítulo 36 - Páginas web de Inscripciones, servidas junto al servicio
% REST del capítulo 31.
%
%     GET  /pagina/materias           las materias, con sus inscriptos
%     GET  /pagina/materias/{codigo}  los inscriptos y un formulario
%     POST /pagina/inscribir          el formulario: legajo y materia
%
% Cada página es un término de html//1 que arma un predicado puro
% (cuerpo_materias/1, cuerpo_materia/2, cuerpo_resultado/3); los
% manejadores solo leen el pedido y responden con reply_html_page/2. Cargar
% este módulo agrega las rutas al servidor de api.pl, que las sirve junto
% con las de JSON.
%
% solo-local: SWISH no admite módulos propios ni permite abrir puertos.
%
%?- iniciar_api(Puerto), detener_api(Puerto).

:- module(paginas_inscripciones,
          [ cuerpo_materias/1,
            cuerpo_materia/2,
            cuerpo_resultado/3
          ]).

:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_parameters)).
:- use_module(library(http/html_write)).
:- use_module('../../capitulo-31/inscripciones/datos').
:- use_module('../../capitulo-31/inscripciones/reglas').
:- use_module('../../capitulo-31/inscripciones/informes').
:- reexport('../../capitulo-31/inscripciones/api',
            [iniciar_api/1, detener_api/1]).

:- http_handler(root(pagina/materias), pagina_materias, [method(get)]).
:- http_handler(root(pagina/materias/Codigo), pagina_materia(Codigo),
                [method(get)]).
:- http_handler(root(pagina/inscribir), pagina_inscribir, [method(post)]).

%!  pagina_materias(+Pedido) is det.
%
%   GET /pagina/materias.
pagina_materias(_Pedido) :-
    cuerpo_materias(Cuerpo),
    reply_html_page(title('Materias'), Cuerpo).

%!  pagina_materia(+Codigo:atom, +Pedido) is det.
%
%   GET /pagina/materias/Codigo, o 404 si la materia no existe.
pagina_materia(Codigo, Pedido) :-
    (   cuerpo_materia(Codigo, Cuerpo)
    ->  reply_html_page(title(Codigo), Cuerpo)
    ;   http_404([], Pedido)
    ).

%!  pagina_inscribir(+Pedido) is det.
%
%   POST /pagina/inscribir, con el legajo y la materia del formulario.
pagina_inscribir(Pedido) :-
    http_parameters(Pedido, [ legajo(Legajo, [integer]),
                              materia(Materia, [atom]) ]),
    inscribir(Legajo, Materia, Resultado),
    cuerpo_resultado(Legajo, Materia-Resultado, Cuerpo),
    reply_html_page(title('Inscripción'), Cuerpo).

%!  cuerpo_materias(-Cuerpo) is det.
%
%   Cuerpo es la página de las materias: una tabla con el código, el
%   nombre, que enlaza con la página de la materia, y los inscriptos.
cuerpo_materias([ h1('Materias'),
                  table([ tr([th('Código'), th('Nombre'), th('Inscriptos')])
                        | Filas ])
                ]) :-
    findall(tr([ td(Codigo),
                 td(a(href(Enlace), Nombre)),
                 td(Cantidad) ]),
            ( materia(Codigo, Nombre, _),
              atom_concat('/pagina/materias/', Codigo, Enlace),
              inscriptos(Codigo, Legajos),
              length(Legajos, Cantidad) ),
            Filas).

%!  cuerpo_materia(+Codigo:atom, -Cuerpo) is semidet.
%
%   Cuerpo es la página de la materia Codigo: sus inscriptos, el promedio
%   y el formulario para inscribir. Falla si la materia no existe.
cuerpo_materia(Codigo, [ h1(Nombre),
                         ul(Items),
                         p(Promedio),
                         form([ action('/pagina/inscribir'), method(post) ],
                              [ input([ type(hidden), name(materia),
                                        value(Codigo) ]),
                                label([ 'Legajo ',
                                        input([ name(legajo), size(6) ]) ]),
                                input([ type(submit), value('Inscribir') ])
                              ]),
                         p(a(href('/pagina/materias'), 'Todas las materias'))
                       ]) :-
    materia(Codigo, Nombre, _),
    inscriptos(Codigo, Legajos),
    findall(li([Legajo, ' ', Alumno]),
            ( member(Legajo, Legajos),
              alumno(Legajo, Alumno, _, _) ),
            Items),
    (   promedio_de_materia(Codigo, P)
    ->  format(atom(Promedio), "Promedio: ~2f", [P])
    ;   Promedio = 'Promedio: sin notas'
    ).

%!  cuerpo_resultado(+Legajo:integer, +Inscripcion:pair, -Cuerpo) is det.
%
%   Cuerpo informa el resultado de inscribir a Legajo; Inscripcion es el
%   par Materia-Resultado.
cuerpo_resultado(Legajo, Materia-Resultado, [ h1('Inscripción'),
                                              p(Texto),
                                              p(a(href(Enlace), 'Volver'))
                                            ]) :-
    (   Resultado == aceptada
    ->  format(atom(Texto), "Aceptada: ~w en ~w.", [Legajo, Materia])
    ;   Resultado = rechazada(Motivo),
        format(atom(Texto), "Rechazada: ~w en ~w, ~w.",
               [Legajo, Materia, Motivo])
    ),
    atom_concat('/pagina/materias/', Materia, Enlace).
