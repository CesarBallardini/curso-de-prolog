:- encoding(utf8).

% Capítulo 29 - Python desde Prolog: py_call/2.
%
% py_call(Modulo:Funcion(Argumentos), Resultado) llama a una función de
% Python y convierte el resultado a Prolog. Los datos cruzan como en la otra
% dirección: listas, números, cadenas, diccionarios.
%
% solo-local: necesita Python; en Windows, su directorio en el PATH, o el
% programa ejecutado desde Python.
%
%?- raiz(16, R).
%?- mediana([3, 1, 4, 1, 5], M).

:- use_module(library(janus)).

%!  raiz(+X:number, -R:float) is det.
%
%   R es la raíz cuadrada de X, calculada con el módulo math de Python.
raiz(X, R) :-
    py_call(math:sqrt(X), R).

%!  mediana(+Numeros:list(number), -Mediana:number) is det.
%
%   Mediana es la mediana de Numeros, calculada con el módulo statistics de
%   Python.
mediana(Numeros, Mediana) :-
    py_call(statistics:median(Numeros), Mediana).

%!  palabras_frecuentes(+Texto:string, +N:integer, -Pares:list(pair)) is det.
%
%   Pares son las N palabras más frecuentes de Texto, como pares
%   Palabra-Cantidad, contadas con collections.Counter de Python. La opción
%   py_object(true) conserva el contador como objeto de Python, en lugar de
%   convertirlo en un dict; las tuplas de dos elementos que devuelve
%   most_common() llegan como pares.
palabras_frecuentes(Texto, N, Pares) :-
    split_string(Texto, " ", " ", Palabras),
    py_call(collections:'Counter'(Palabras), Contador, [py_object(true)]),
    py_call(Contador:most_common(N), Pares).
