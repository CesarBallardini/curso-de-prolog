:- encoding(utf8).

% Capítulo 35 - Archivos .qlf: un archivo fuente compilado una vez, que se
% carga sin volver a leerlo.
%
% generar_cuadrados/2 escribe un archivo fuente con muchos hechos, para
% medir cuánto tarda su carga. precompilar/1 lo compila a .qlf con
% qcompile/1, en el mismo directorio.
%
% solo-local: escribe archivos en el disco y los compila, lo que SWISH no
% permite.
%
%?- tmp_file(c, B), file_name_extension(B, pl, F), generar_cuadrados(F, 9).

%!  generar_cuadrados(+Archivo, +N:integer) is det.
%
%   Escribe en Archivo los hechos cuadrado(I, C), con C el cuadrado de I,
%   para I de 1 a N.
generar_cuadrados(Archivo, N) :-
    setup_call_cleanup(open(Archivo, write, Salida),
                       escribir_cuadrados(Salida, N),
                       close(Salida)).

%!  escribir_cuadrados(+Salida, +N:integer) is det.
%
%   Escribe en Salida los hechos cuadrado/2 de 1 a N, uno por línea.
escribir_cuadrados(Salida, N) :-
    forall(between(1, N, I),
           ( C is I * I,
             format(Salida, "cuadrado(~d, ~d).~n", [I, C]) )).

%!  precompilar(+Archivo) is det.
%
%   Compila Archivo, un archivo fuente, a un archivo .qlf con el mismo
%   nombre, y lo carga.
precompilar(Archivo) :-
    qcompile(Archivo).
