:- encoding(utf8).

% Capítulo 25 - Soluciones de los ejercicios 11, 12 y 13: el proyecto.
%
% Carga los módulos del proyecto y agrega registrar_nota/3 con validación
% (ejercicio 11), un comando para registrar notas que convierte los errores
% en respuestas (ejercicio 12), y el registro de los errores (ejercicio 13).
%
% solo-local: SWISH no admite módulos propios en un programa.
%
%?- catch(registrar_nota(101, pp, 11), error(F, _), true).
%?- ejecutar_ampliado("nota de 101 en paradigmas 11", R).

:- use_module(library(error)).
:- use_module(inscripciones/datos).
:- use_module(inscripciones/comandos).

:- dynamic error_registrado/2.

% --- Ejercicio 11 ---------------------------------------------------------

%!  registrar_nota(+Legajo:integer, +Materia:atom, +Nota:integer) is det.
%
%   Registra la nota final Nota del alumno Legajo en Materia, que debe estar
%   cursando. Produce un error de tipo si un argumento no es del tipo
%   declarado, domain_error(nota, Nota) si la nota no está entre 1 y 10, y
%   existence_error(cursada, Legajo-Materia) si el alumno no la cursa.
registrar_nota(Legajo, Materia, Nota) :-
    must_be(integer, Legajo),
    must_be(atom, Materia),
    must_be(integer, Nota),
    (   between(1, 10, Nota)
    ->  true
    ;   domain_error(nota, Nota)
    ),
    (   quitar_inscripcion(Legajo, Materia, cursando)
    ->  agregar_inscripcion(Legajo, Materia, nota(Nota))
    ;   existence_error(cursada, Legajo-Materia)
    ).

% --- Ejercicios 12 y 13 ---------------------------------------------------

%!  ejecutar_ampliado(+Texto:text, -Respuesta) is det.
%
%   Como ejecutar/2, con el comando "nota de Legajo en Materia Nota". Un
%   error de registrar_nota/3 se convierte en la respuesta error(Formal), y
%   queda registrado en error_registrado/2.
ejecutar_ampliado(Texto, Respuesta) :-
    must_be(text, Texto),
    text_to_string(Texto, Cadena),
    string_codes(Cadena, Codigos),
    phrase(palabras(Palabras), Codigos),
    (   Palabras = [nota, de, L, en, Nombre, N],
        materia(M, Nombre, _)
    ->  catch(( registrar_nota(L, M, N),
                Respuesta = registrada ),
              error(Formal, _),
              ( assertz(error_registrado(Cadena, Formal)),
                Respuesta = error(Formal) ))
    ;   ejecutar(Cadena, Respuesta)
    ).

%!  errores(-Errores:list(pair)) is det.
%
%   Errores son los errores registrados, como pares Texto-Formal, en el
%   orden en que ocurrieron.
errores(Errores) :-
    findall(T-F, error_registrado(T, F), Errores).
