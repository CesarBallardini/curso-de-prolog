:- encoding(utf8).

% Capítulo 15 - Un menú con repeat: lee órdenes hasta que llega salir.
%
% repeat tiene infinitas respuestas: cada vez que un objetivo posterior falla,
% la ejecución vuelve a él y el ciclo recomienza. El corte final, que se
% alcanza solo con la orden salir, termina el ciclo. Las órdenes se leen de un
% stream, para poder probar el menú con un texto en lugar del teclado:
% menu(user_input) lo usa en el toplevel.
%
% solo-local: lee órdenes de un stream en un ciclo.
%?- open_string("edad(ana). salir.", In), menu(In).

% edad(P, A): P tiene A años.
edad(juan, 68).
edad(ana, 41).
edad(luis, 12).

%!  menu(+In) is det.
%
%   Lee órdenes del stream In y ejecuta cada una, hasta leer salir o llegar
%   al final del stream.
menu(In) :-
    repeat,
    read(In, Orden),
    ejecutar(Orden),
    (   Orden == salir
    ;   Orden == end_of_file
    ),
    !.

%!  ejecutar(+Orden) is det.
%
%   Ejecuta una orden del menú. Una orden desconocida se informa y el menú
%   sigue.
ejecutar(edad(P)) :-
    !,
    (   edad(P, A)
    ->  format("~w tiene ~d años~n", [P, A])
    ;   format("~w no está en la base~n", [P])
    ).
ejecutar(salir) :-
    !,
    format("Fin~n").
ejecutar(end_of_file) :-
    !.
ejecutar(Orden) :-
    format("Orden desconocida: ~q~n", [Orden]).
