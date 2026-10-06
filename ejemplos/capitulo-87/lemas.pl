:- encoding(utf8).

% Capítulo 87 - Las formas de las palabras, reducidas a su lema.
%
% Carga el analizador morfológico del capítulo 53 (paralelo.pl, con sus
% reglas de dos niveles y su léxico) sin copiarlo, y agrega al léxico los
% lemas que las preguntas sobre Inscripciones necesitan: los verbos
% cursar, aprobar y necesitar, y los nombres alumno, materia y carrera.
% El léxico del capítulo 53 declara sus predicados multifile para eso.
%
% analisis/2 es forma/2 del capítulo 53 con una tabla: la gramática
% vuelve atrás y prueba la misma palabra varias veces, y la tabla hace que
% cada palabra se analice una sola vez en toda la sesión.
%
% solo-local: carga módulos de otro capítulo.
%
%?- analisis("aprobaron", A).
%?- findall(A, analisis("cursa", A), As).

:- module(lemas,
          [ analisis/2
          ]).

:- use_module('../capitulo-53/lexico', []).
:- ensure_loaded('../capitulo-53/paralelo').

% Las entradas que este capítulo agrega al léxico del capítulo 53.
lexico:verbo("cursar", regular).
lexico:verbo("aprobar", o_ue).
lexico:verbo("necesitar", regular).
lexico:nombre("alumno", masculino).
lexico:nombre("materia", femenino).
lexico:nombre("carrera", femenino).

:- table analisis/2.

%!  analisis(+Palabra:string, -Analisis) is nondet.
%
%   Analisis es un análisis de Palabra según el capítulo 53: por ejemplo
%   verbo(Lema, Tiempo, Persona, Numero) o nombre(Lema, Genero, Numero).
%   Falla si Palabra no es una forma de ningún lema del léxico.
analisis(Palabra, Analisis) :-
    forma(Palabra, Analisis).
