:- encoding(utf8).

% Capítulo 24 - Solución del ejercicio 17: double_quotes en un archivo sin
% módulo.
%
% El archivo no declara un módulo: consult/1 lo carga en user, y la
% directiva cambia la bandera de user. Lo que se carga después en user, el
% archivo de pruebas incluido, y las consultas del toplevel leen las comillas
% dobles como listas de códigos.
%
% solo-local: el ejemplo trata de la carga de archivos.
%
%?- saludo(S).

:- set_prolog_flag(double_quotes, codes).

% saludo(S): S es lo que este archivo lee de "hola".
saludo("hola").
