:- encoding(utf8).

% Capítulo 25 - setup_call_cleanup/3: un recurso que se libera siempre.
%
% abrir/1 y cerrar/1 simulan un recurso, como un archivo o una conexión:
% abierto/1 registra los que están abiertos. usar/2 abre el recurso, ejecuta
% el objetivo y lo cierra, tanto si el objetivo tiene éxito como si falla o
% produce un error. contar_lineas/2 hace lo mismo con un stream de verdad,
% sobre una cadena.
%
% solo-local: el sandbox de SWISH no permite abrir streams, ni sobre cadenas.
%
%?- usar(r1, true), findall(R, abierto(R), Abiertos).
%?- contar_lineas("uno\ndos\ntres", N).

:- dynamic abierto/1.

%!  abrir(+Recurso) is det.
%
%   Registra que Recurso está abierto.
abrir(Recurso) :-
    assertz(abierto(Recurso)).

%!  cerrar(+Recurso) is det.
%
%   Registra que Recurso ya no está abierto.
cerrar(Recurso) :-
    retractall(abierto(Recurso)).

%!  usar(+Recurso, :Objetivo) is semidet.
%
%   Abre Recurso, ejecuta Objetivo una vez y cierra Recurso, pase lo que pase
%   con Objetivo: éxito, falla o error.
usar(Recurso, Objetivo) :-
    setup_call_cleanup(abrir(Recurso),
                       once(Objetivo),
                       cerrar(Recurso)).

%!  usar_sin_limpieza(+Recurso, :Objetivo) is semidet.
%
%   La versión ingenua: si Objetivo falla o produce un error, cerrar/1 no se
%   ejecuta y el recurso queda abierto.
usar_sin_limpieza(Recurso, Objetivo) :-
    abrir(Recurso),
    once(Objetivo),
    cerrar(Recurso).

%!  contar_lineas(+Texto:string, -N:integer) is det.
%
%   N es la cantidad de líneas de Texto, leídas de un stream que se cierra al
%   terminar.
contar_lineas(Texto, N) :-
    setup_call_cleanup(open_string(Texto, Stream),
                       contar_lineas_de(Stream, 0, N),
                       close(Stream)).

%!  contar_lineas_de(+Stream, +Hasta:integer, -N:integer) is det.
%
%   N es Hasta más la cantidad de líneas que quedan en Stream.
contar_lineas_de(Stream, Hasta, N) :-
    read_line_to_string(Stream, Linea),
    (   Linea == end_of_file
    ->  N = Hasta
    ;   Siguiente is Hasta + 1,
        contar_lineas_de(Stream, Siguiente, N)
    ).
