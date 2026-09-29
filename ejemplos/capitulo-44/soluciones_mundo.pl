:- encoding(utf8).

% Capítulo 44 - Soluciones de los ejercicios 2 y 3: un jardín y tres
% sinónimos, agregados sin modificar los archivos del capítulo.
%
% Los predicados de datos de mundo.pl y forma/2 de lenguaje.pl son
% multifile: este archivo les agrega cláusulas, calificadas con el módulo.
%
% solo-local: carga los módulos del capítulo, y SWISH no admite módulos
% propios.
%
%?- iniciar, ejecutar("abrir la puerta", S1), ejecutar("jardín", S2).

:- use_module(lenguaje).

% Ejercicio 2

mundo:nombre(jardin, m, "jardín").
mundo:nombre(puerta_vidrio, f, "puerta de vidrio").
mundo:nombre(regadera, f, "regadera").

mundo:sala(jardin, "Un jardín descuidado, con canteros secos.").

mundo:puerta(puerta_vidrio, vestibulo, jardin).

mundo:inicio(cerrada(puerta_vidrio)).
mundo:inicio(esta_en(regadera, jardin)).

% Ejercicio 3

lenguaje:forma(tomar, [recoger]).
lenguaje:forma(tomar, [levantar]).
lenguaje:forma(salir, [terminar]).
