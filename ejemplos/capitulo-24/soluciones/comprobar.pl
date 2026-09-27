:- encoding(utf8).

% Capítulo 24 - Solución del ejercicio 6: una comprobación más de los datos.
%
% comprobar_vacantes/0 advierte por cada materia con vacantes negativas. En
% el proyecto se agrega al cuerpo de comprobar_datos/0; aquí está en un
% módulo aparte para probarlo sin modificar datos.pl.
%
% solo-local: SWISH no admite módulos propios en un programa.
%
%?- comprobar_vacantes.

:- module(comprobar, [comprobar_vacantes/0]).

:- use_module('../inscripciones/datos').

%!  comprobar_vacantes is det.
%
%   Escribe en la salida de errores una advertencia por cada materia con
%   vacantes negativas.
comprobar_vacantes :-
    forall(( vacantes(M, N),
             N < 0 ),
           format(user_error, "Vacantes negativas: ~w tiene ~d~n", [M, N])).
