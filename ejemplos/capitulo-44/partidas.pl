:- encoding(utf8).

% Capítulo 44 - Versión 3 de la aventura: guardar y cargar una partida.
%
% Una partida guardada es la instantánea del estado, escrita como hechos,
% uno por línea, en un archivo de texto. Cargarla es leer esos términos
% con read_term/3, sin ejecutarlos, y pasarlos a restablecer/1, que los
% valida antes de cambiar nada: un archivo dañado o con directivas produce
% un error y deja la partida como estaba.
%
% solo-local: SWISH no admite módulos propios ni escribe archivos.
%
%?- iniciar, tmp_file(p, A), guardar(A), read_file_to_string(A, S, []).

:- module(partidas,
          [ guardar/1,
            cargar/1
          ]).

:- reexport(estado).

%!  guardar(+Archivo) is det.
%
%   Escribe en Archivo los hechos del estado actual, uno por línea.
guardar(Archivo) :-
    instantanea(Hechos),
    setup_call_cleanup(
        open(Archivo, write, Out, [encoding(utf8)]),
        forall(member(H, Hechos), portray_clause(Out, H)),
        close(Out)).

%!  cargar(+Archivo) is det.
%
%   Reemplaza el estado por los hechos de Archivo. Produce un error, y no
%   cambia el estado, si Archivo no existe, no es texto Prolog válido o
%   tiene términos que no son hechos de estado.
cargar(Archivo) :-
    setup_call_cleanup(
        open(Archivo, read, In, [encoding(utf8)]),
        leer_terminos(In, Hechos),
        close(In)),
    restablecer(Hechos).

%!  leer_terminos(+In, -Terminos:list) is det.
%
%   Terminos son los términos que quedan por leer en el stream In.
leer_terminos(In, Terminos) :-
    read_term(In, T, []),
    (   T == end_of_file
    ->  Terminos = []
    ;   Terminos = [T|Ts],
        leer_terminos(In, Ts)
    ).
