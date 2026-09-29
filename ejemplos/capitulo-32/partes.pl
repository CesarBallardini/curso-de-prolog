:- encoding(utf8).

% Capítulo 32 - Construir y descomponer términos: functor/3, arg/3, =.. y
% compound_name_arguments/3.
%
% Los predicados de este archivo trabajan con términos cuya forma no se
% conoce al escribir el programa: no saben el nombre ni la aridad del
% término que reciben, y los obtienen durante la ejecución.
%
%?- argumentos(fecha(2026, 9, 27), Args).
%?- cambiar_argumento(2, fecha(2026, 9, 27), 10, T).
%?- agregar_argumento(padre(juan), H, Meta).

%!  argumentos(+Termino, -Args:list) is det.
%
%   Args son los argumentos de Termino, en orden; la lista vacía si Termino
%   es atómico. Usa functor/3 y arg/3.
argumentos(T, Args) :-
    functor(T, _, Aridad),
    argumentos_desde(1, Aridad, T, Args).

%!  argumentos_desde(+I:integer, +Aridad:integer, +Termino, -Args:list)
%!      is det.
%
%   Args son los argumentos de Termino desde la posición I hasta Aridad.
argumentos_desde(I, Aridad, T, Args) :-
    (   I > Aridad
    ->  Args = []
    ;   arg(I, T, A),
        Args = [A|Resto],
        I1 is I + 1,
        argumentos_desde(I1, Aridad, T, Resto)
    ).

%!  cambiar_argumento(+N:integer, +Termino0, ?X, -Termino) is semidet.
%
%   Termino es Termino0 con X en el lugar del argumento N. Termino0 no
%   cambia: Termino es un término nuevo, que comparte con Termino0 los
%   demás argumentos. Falla si Termino0 no tiene argumento N.
cambiar_argumento(N, T0, X, T) :-
    functor(T0, Nombre, Aridad),
    functor(T, Nombre, Aridad),
    arg(N, T, X),
    copiar_otros(1, Aridad, N, T0, T).

%!  copiar_otros(+I:integer, +Aridad:integer, +N:integer, +Origen, +Destino)
%!      is det.
%
%   Los argumentos de Destino desde la posición I, salvo el N, son los de
%   Origen.
copiar_otros(I, Aridad, N, Origen, Destino) :-
    (   I > Aridad
    ->  true
    ;   (   I =:= N
        ->  true
        ;   arg(I, Origen, A),
            arg(I, Destino, A)
        ),
        I1 is I + 1,
        copiar_otros(I1, Aridad, N, Origen, Destino)
    ).

%!  argumentos_univ(+Termino, -Args:list) is det.
%
%   Args son los argumentos de Termino, como en argumentos/2, obtenidos con
%   =.. en un solo paso.
argumentos_univ(T, Args) :-
    T =.. [_|Args].

%!  renombrar(+Termino0, +Nombre:atom, -Termino) is det.
%
%   Termino tiene los argumentos de Termino0 y el nombre Nombre.
renombrar(T0, Nombre, T) :-
    T0 =.. [_|Args],
    T =.. [Nombre|Args].

%!  agregar_argumento(+Meta0:callable, ?X, -Meta:callable) is det.
%
%   Meta es Meta0 con X como argumento adicional, al final: la operación que
%   call/2 realiza antes de llamar.
agregar_argumento(Meta0, X, Meta) :-
    Meta0 =.. [Nombre|Args0],
    append(Args0, [X], Args),
    Meta =.. [Nombre|Args].
