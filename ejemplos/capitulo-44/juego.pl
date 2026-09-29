:- encoding(utf8).

% Capítulo 44 - Versión 5 de la aventura: el bucle del juego y el menú de
% inicio.
%
% partida/1 lee una orden por línea de un stream, la ejecuta con
% ejecutar/2 de la versión 4 y escribe la respuesta, hasta que la orden es
% salir, la partida está ganada o la entrada se termina. menu/3 muestra
% opciones numeradas, generadas a partir de una lista, y repite la
% pregunta si la respuesta no es una de ellas. Los dos reciben el stream
% de entrada como argumento: el teclado en jugar/0, una cadena en las
% pruebas.
%
% solo-local: SWISH no admite módulos propios ni lee de la terminal.
%
%?- open_string("2\n", In), menu(In, [opcion("Uno", a), opcion("Dos", b)], V).

:- module(juego,
          [ menu/3,
            opciones_de_inicio/1,
            preparar/2,
            partida/1,
            jugar/1,
            jugar/0
          ]).

:- reexport(lenguaje).

%!  jugar is det.
%
%   Juega en la terminal: el menú de inicio y la partida elegida.
jugar :-
    jugar(user_input).

%!  jugar(+In) is det.
%
%   Muestra el menú de inicio y juega la partida elegida, con las líneas
%   que llegan por el stream In.
jugar(In) :-
    opciones_de_inicio(Opciones),
    menu(In, Opciones, Eleccion),
    (   preparar(Eleccion, Texto)
    ->  format("~w~n", [Texto]),
        partida(In)
    ;   true
    ).

%!  opciones_de_inicio(-Opciones:list) is det.
%
%   Las opciones del menú de inicio.
opciones_de_inicio([ opcion("Partida nueva", nueva),
                     opcion("Continuar la partida guardada", guardada),
                     opcion("Salir", salir)
                   ]).

%!  preparar(+Eleccion, -Texto:string) is semidet.
%
%   Prepara el estado para la partida que indica Eleccion, nueva o
%   guardada, y da el texto con que empieza. Falla si Eleccion es salir.
preparar(nueva, Texto) :-
    iniciar,
    responder(mirar, Texto).
preparar(guardada, Texto) :-
    iniciar,
    responder(cargar(partida), Texto).

%!  partida(+In) is det.
%
%   Lee órdenes de In, una por línea, y escribe sus respuestas, hasta que
%   la orden es salir, la partida está ganada o In se termina.
partida(In) :-
    format("> "),
    read_line_to_string(In, Linea),
    (   Linea == end_of_file
    ->  Orden = salir
    ;   entender(Linea, Orden)
    ),
    responder(Orden, Texto),
    format("~w~n", [Texto]),
    (   (   Orden == salir
        ;   ganado
        )
    ->  true
    ;   partida(In)
    ).

%!  menu(+In, +Opciones:list, -Valor) is det.
%
%   Muestra Opciones, una lista de opcion(Texto, Valor) numeradas desde 1,
%   y lee de In el número de una. Valor es el de la opción elegida; si la
%   respuesta no es un número de la lista, vuelve a preguntar. Si In se
%   termina, Valor es el de la última opción.
menu(In, Opciones, Valor) :-
    forall(nth1(I, Opciones, opcion(Texto, _)),
           format("~d. ~w~n", [I, Texto])),
    length(Opciones, Cantidad),
    format("Elige una opción, de 1 a ~d: ", [Cantidad]),
    read_line_to_string(In, Linea),
    (   Linea == end_of_file
    ->  last(Opciones, opcion(_, Valor))
    ;   normalize_space(atom(Respuesta), Linea),
        atom_number(Respuesta, N),
        integer(N),
        nth1(N, Opciones, opcion(_, V))
    ->  Valor = V
    ;   format("La respuesta no es una de las opciones.~n"),
        menu(In, Opciones, Valor)
    ).
