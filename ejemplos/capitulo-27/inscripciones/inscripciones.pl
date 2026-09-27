:- encoding(utf8).

% Capítulo 27 - Inscripciones: el programa completo, en seis módulos.
%
% Este archivo solo carga los módulos. Cargarlo es cargar el programa; cada
% módulo se puede cargar y probar también por separado. Al terminar de cargar,
% comprobar_datos/0 revisa que cada inscripción sea de un alumno y una
% materia existentes.
%
% solo-local: SWISH no admite módulos propios en un programa.
%
%?- ejecutar("inscribir a 104 en sintaxis", Respuesta).
%?- horario(5, 6, Horario).
%?- escribir_ranking(user_output).

:- use_module(datos).
:- use_module(reglas).
:- use_module(informes).
:- use_module(comandos).
:- use_module(horarios).
:- use_module(intercambio).

:- initialization(comprobar_datos).
