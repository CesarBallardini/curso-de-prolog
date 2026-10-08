:- encoding(utf8).

% Capítulo 26 - Inscripciones: el programa completo, en cinco módulos.
%
% Este archivo solo carga los módulos. Cargarlo es cargar el programa; cada
% módulo se puede cargar y probar también por separado. Al terminar de cargar,
% comprobar_datos/0 verifica que cada inscripción sea de un alumno y una
% materia existentes.
%
% solo-local: SWISH no admite módulos propios en un programa.
%
%?- ejecutar("inscribir a 104 en sintaxis", Respuesta).
%?- horario(5, 6, Horario).

:- use_module(datos).
:- use_module(reglas).
:- use_module(informes).
:- use_module(comandos).
:- use_module(horarios).

:- initialization(comprobar_datos).
