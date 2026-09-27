:- encoding(utf8).

% Capítulo 29 - Soluciones de los ejercicios 10 y 11: Python desde Prolog.
%
% solo-local: necesita Python; test_soluciones.py ejecuta sus pruebas dentro
% del proceso de Python.
%
%?- envolver("uno dos tres cuatro cinco", 9, Lineas).

:- use_module(library(janus)).

%!  envolver(+Texto:text, +Ancho:integer, -Lineas:list(atom)) is det.
%
%   Lineas son las líneas de Texto, de Ancho caracteres como máximo, cortadas
%   entre palabras por textwrap.wrap de Python. Las cadenas de Python llegan
%   como átomos.
envolver(Texto, Ancho, Lineas) :-
    py_call(textwrap:wrap(Texto, width = Ancho), Lineas).

%!  a_json(+Dict:dict, -Texto:atom) is det.
%
%   Texto es Dict escrito en JSON por json.dumps de Python, con las claves
%   en orden alfabético.
a_json(Dict, Texto) :-
    py_call(json:dumps(Dict, sort_keys = @(true)), Texto).
