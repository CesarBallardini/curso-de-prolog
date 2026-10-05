:- encoding(utf8).

% Capítulo 59 - Solución del ejercicio 12: el comando que inserta las
% cláusulas de un archivo, como el «I Filename» del editor de Kluźniak y
% Szpakowicz.
%
% solo-local: carga editor.pl y lee archivos.
%
%?- tmp_file_stream(text, F, S), format(S, "nota(rosa, 10).~n", []),
%   close(S), abrir(nota/2, E0), insertar_archivo(F, E0, E).

:- ensure_loaded(editor).

%!  insertar_archivo(+Archivo, +Estado0, -Estado) is det.
%
%   Estado es Estado0 con las cláusulas de Archivo insertadas después del
%   cursor, como con el comando i, y guardadas en la base. Las cláusulas se
%   leen hasta end o hasta el fin del archivo.
insertar_archivo(Archivo, Estado0, Estado) :-
    setup_call_cleanup(open(Archivo, read, In, [encoding(utf8)]),
                       leer_clausulas(In, Clausulas),
                       close(In)),
    comando(i(Clausulas), Estado0, Estado),
    grabar(Estado).
