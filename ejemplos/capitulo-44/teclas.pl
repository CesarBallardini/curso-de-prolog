:- encoding(utf8).

% Capítulo 44 - Menús de una tecla.
%
% Covington lee la respuesta de un menú con una sola tecla, sin esperar la
% tecla Intro. leer_tecla/2 hace lo mismo con get_single_char/1 cuando el
% stream es el teclado de una terminal, y con get_char/2 en cualquier otro
% stream, como el de una cadena en las pruebas; en los dos casos salta los
% blancos y los fines de línea. menu_tecla/3 es el menú de juego.pl con
% opciones de un dígito, y si_o_no/3 es la pregunta que solo acepta «s» o
% «n», con mayúscula o minúscula.
%
% solo-local: SWISH no lee de la terminal.
%
%?- open_string("x2", In), menu_tecla(In, [opcion("Uno", a), opcion("Dos", b)], V).
%?- open_string("N", In), si_o_no(In, "¿Guardar la partida?", R).

:- module(teclas,
          [ leer_tecla/2,
            menu_tecla/3,
            si_o_no/3
          ]).

:- use_module(library(lists)).

%!  leer_tecla(+In, -C) is det.
%
%   C es el primer carácter de In que no es un blanco, o end_of_file si In
%   se termina antes. Si In es el teclado de una terminal, la tecla se lee
%   sin esperar Intro y se muestra.
leer_tecla(In, C) :-
    leer_caracter(In, C0),
    (   C0 \== end_of_file,
        char_type(C0, space)
    ->  leer_tecla(In, C)
    ;   C = C0
    ).

%!  leer_caracter(+In, -C) is det.
%
%   C es el siguiente carácter de In, o end_of_file.
leer_caracter(In, C) :-
    In == user_input,
    stream_property(user_input, tty(true)),
    !,
    get_single_char(Codigo),
    (   Codigo =:= -1
    ->  C = end_of_file
    ;   char_code(C, Codigo),
        format("~w~n", [C])
    ).
leer_caracter(In, C) :-
    get_char(In, C).

%!  menu_tecla(+In, +Opciones:list, -Valor) is det.
%
%   Muestra Opciones, una lista de hasta nueve opcion(Texto, Valor)
%   numeradas desde 1, y lee de In una tecla. Valor es el de la opción
%   cuyo número es esa tecla; con otra tecla, vuelve a preguntar. Si In se
%   termina, Valor es el de la última opción.
menu_tecla(In, Opciones, Valor) :-
    forall(nth1(I, Opciones, opcion(Texto, _)),
           format("~d. ~w~n", [I, Texto])),
    length(Opciones, Cantidad),
    format("Pulsa una tecla, de 1 a ~d: ", [Cantidad]),
    leer_tecla(In, C),
    (   C == end_of_file
    ->  last(Opciones, opcion(_, Valor))
    ;   char_type(C, digit(N)),
        nth1(N, Opciones, opcion(_, V))
    ->  Valor = V
    ;   format("La tecla ~w no es una de las opciones.~n", [C]),
        menu_tecla(In, Opciones, Valor)
    ).

%!  si_o_no(+In, +Pregunta:string, -Respuesta) is det.
%
%   Muestra Pregunta y lee de In una tecla, hasta que es «s» o «n», en
%   mayúscula o minúscula. Respuesta es si o no; si In se termina, es no.
si_o_no(In, Pregunta, Respuesta) :-
    format("~s (s/n): ", [Pregunta]),
    leer_tecla(In, C),
    (   C == end_of_file
    ->  Respuesta = no
    ;   downcase_atom(C, Minuscula),
        respuesta(Minuscula, R)
    ->  Respuesta = R
    ;   format("Pulsa s o n.~n"),
        si_o_no(In, Pregunta, Respuesta)
    ).

% respuesta(Tecla, R): la tecla Tecla, en minúscula, responde R.
respuesta(s, si).
respuesta(n, no).
