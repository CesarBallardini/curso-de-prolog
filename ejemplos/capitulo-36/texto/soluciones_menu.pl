:- encoding(utf8).

% Capítulo 36 - Solución del ejercicio 6: el menú de Inscripciones con un
% formulario para inscribir.
%
% El estado es menu(N, Vista, Aviso): Vista es materias, inscriptos,
% formulario(Legajo) o salir, y Aviso es la línea de estado, "" si no hay
% ninguna. Las vistas de menu_inscripciones.pl no cambian: sus pantallas y
% sus teclas se piden a pantalla_menu/2 y paso_menu/3. El texto del
% resultado es el de mensaje_de_inscripcion/3, de la ventana de XPCE.
%
% solo-local: SWISH no admite módulos propios.
%
%?- pantalla_formulario(menu(3, formulario("10"), ""), L).

:- module(soluciones_menu,
          [ pantalla_formulario/2,
            paso_formulario/3,
            bucle_formulario/3
          ]).

:- meta_predicate
    bucle_formulario(1, +, -).

:- use_module(pantalla, except([leer_tecla/2, caja/3])).
:- use_module(soluciones_pantalla, [leer_tecla/2, caja/3]).
:- use_module(menu_inscripciones).
:- use_module('../ventanas/inscripciones_xpce', [mensaje_de_inscripcion/3]).
:- use_module('../../capitulo-31/inscripciones/datos').

%!  bucle_formulario(:Siguiente, +Menu0, -Menu) is det.
%
%   Dibuja Menu0 y, hasta que la vista sea salir, lee una tecla de
%   Siguiente y la aplica.
bucle_formulario(_, menu(N, salir, A), menu(N, salir, A)) :-
    !.
bucle_formulario(Siguiente, Menu0, Menu) :-
    pantalla_formulario(Menu0, Lineas),
    dibujar(Lineas),
    leer_tecla(Siguiente, Tecla),
    paso_formulario(Tecla, Menu0, Menu1),
    bucle_formulario(Siguiente, Menu1, Menu).

%!  paso_formulario(+Tecla, +Menu0, -Menu) is det.
%
%   Menu es Menu0 después de Tecla. En los inscriptos, i abre el
%   formulario. En el formulario, los dígitos se agregan al legajo, borrar
%   quita el último, q vuelve sin inscribir y Enter inscribe con
%   inscribir/3 y vuelve a los inscriptos con el resultado como aviso. Las
%   demás vistas responden como en paso_menu/3.
paso_formulario(fin, menu(N, _, A), menu(N, salir, A)) :-
    !.
paso_formulario(Tecla, menu(N, formulario(Legajo), A), Menu) :-
    !,
    en_el_formulario(Tecla, N, Legajo, A, Menu).
paso_formulario(letra(i), menu(N, inscriptos, _),
                menu(N, formulario(""), "")) :-
    !.
paso_formulario(Tecla, menu(N0, Vista0, A), menu(N, Vista, A)) :-
    paso_menu(Tecla, menu(N0, Vista0), menu(N, Vista)).

%!  en_el_formulario(+Tecla, +N:integer, +Legajo:string, +Aviso:string,
%!                   -Menu) is det.
%
%   Menu resulta de Tecla en el formulario de la materia N.
en_el_formulario(letra(D), N, Legajo0, A, menu(N, formulario(Legajo), A)) :-
    char_type(D, digit(_)),
    !,
    string_concat(Legajo0, D, Legajo).
en_el_formulario(borrar, N, Legajo0, A, menu(N, formulario(Legajo), A)) :-
    !,
    (   sub_string(Legajo0, 0, _, 1, Legajo)
    ->  true
    ;   Legajo = Legajo0
    ).
en_el_formulario(letra(q), N, _, A, menu(N, inscriptos, A)) :-
    !.
en_el_formulario(enter, N, Legajo, _, menu(N, inscriptos, Aviso)) :-
    !,
    materia_numero(N, Materia),
    atom_string(Texto, Legajo),
    mensaje_de_inscripcion(Texto, Materia, Aviso).
en_el_formulario(_, N, Legajo, A, menu(N, formulario(Legajo), A)).

%!  materia_numero(+N:integer, -Codigo:atom) is det.
%
%   Codigo es la materia número N, en el orden de los hechos.
materia_numero(N, Codigo) :-
    findall(C, materia(C, _, _), Codigos),
    nth1(N, Codigos, Codigo).

%!  pantalla_formulario(+Menu, -Lineas:list(string)) is det.
%
%   Lineas es la pantalla de Menu: la del menú, o, en el formulario, la de
%   los inscriptos sin su ayuda y la caja del formulario; debajo, el
%   aviso, si hay uno.
pantalla_formulario(menu(N, Vista, Aviso), Lineas) :-
    pantalla_de_vista(Vista, N, Lineas0),
    (   Aviso == ""
    ->  Lineas = Lineas0
    ;   append(Lineas0, [Aviso], Lineas)
    ).

%!  pantalla_de_vista(+Vista, +N:integer, -Lineas:list(string)) is det.
%
%   Lineas son las líneas de Vista, sin el aviso.
pantalla_de_vista(formulario(Legajo), N, Lineas) :-
    !,
    pantalla_menu(menu(N, inscriptos), Inscriptos),
    once(append(SinAyuda, [_], Inscriptos)),
    materia_numero(N, Codigo),
    materia(Codigo, Nombre, _),
    format(string(Titulo), "Inscribir en ~w", [Nombre]),
    format(string(Campo), "Legajo: ~w_", [Legajo]),
    caja(Titulo, [Campo], Caja),
    append([SinAyuda, Caja, ["Dígitos: legajo  Enter: inscribir  \c
                               q: cancelar"]], Lineas).
pantalla_de_vista(Vista, N, Lineas) :-
    pantalla_menu(menu(N, Vista), Lineas).
