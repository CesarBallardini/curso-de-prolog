:- encoding(utf8).

% Capítulo 87 - Los nombres propios: alumnos, materias y carreras.
%
% Los nombres propios de las preguntas se toman de la base del capítulo
% 42: un alumno se nombra por su nombre, una carrera por su nombre, y una
% materia por su nombre escrito, con tildes y espacios, que da escrita/2.
% La forma lógica no usa los nombres sino las claves de la base: el
% legajo del alumno y el código de la materia. nombre_propio//2 reconoce
% una o varias palabras, sin distinguir tildes, y da la clave y su tipo;
% nombre_de/2 hace lo inverso, para escribir las respuestas.
%
% solo-local: carga el módulo base del capítulo 42.
%
%?- phrase(nombre_propio(T, E), ["bases", "de", "datos"]).
%?- nombre_de(101, N).

:- module(nombres,
          [ nombre_propio//2,
            nombre_de/2,
            escrita/2
          ]).

:- use_module('../capitulo-42/base').
:- use_module(palabras).

% escrita(Codigo, Texto): el nombre de la materia Codigo, como se escribe.
escrita(am1, "análisis 1").
escrita(alg, "álgebra").
escrita(log, "lógica").
escrita(am2, "análisis 2").
escrita(pp,  "paradigmas").
escrita(ssl, "sintaxis").
escrita(bd,  "bases de datos").

%!  nombre_propio(?Tipo, ?Entidad)// is nondet.
%
%   Las palabras nombran a Entidad, de Tipo alumno, materia o carrera.
%   Entidad es una clave de la base: un legajo, un código o una carrera.
nombre_propio(Tipo, Entidad) -->
    palabras_iguales(Palabras),
    { nombre(Tipo, Entidad, Palabras) }.

%!  palabras_iguales(-Palabras:list(string))// is nondet.
%
%   Palabras son las palabras siguientes, una o más, sin tildes: la más
%   corta primero.
palabras_iguales([P]) -->
    [P0],
    { sin_tildes(P0, P) }.
palabras_iguales([P|Ps]) -->
    [P0],
    { sin_tildes(P0, P) },
    palabras_iguales(Ps).

%!  nombre(?Tipo, ?Entidad, ?Palabras:list(string)) is nondet.
%
%   Palabras, sin tildes, nombran a Entidad, de Tipo.
nombre(alumno, Legajo, [Palabra]) :-
    alumno(Legajo, Nombre, _, _),
    atom_string(Nombre, Palabra).
nombre(materia, Codigo, Palabras) :-
    escrita(Codigo, Texto),
    sin_tildes(Texto, Simple),
    split_string(Simple, " ", "", Palabras).
nombre(carrera, Carrera, [Palabra]) :-
    distinct(Carrera, alumno(_, _, Carrera, _)),
    atom_string(Carrera, Palabra).

%!  nombre_de(+Entidad, -Texto:string) is semidet.
%
%   Texto es el nombre con que se escribe Entidad en una respuesta: el
%   nombre de un alumno, el de una materia o el de una carrera.
nombre_de(Entidad, Texto) :-
    (   alumno(Entidad, Nombre, _, _)
    ->  atom_string(Nombre, Texto)
    ;   escrita(Entidad, Texto0)
    ->  Texto = Texto0
    ;   atom(Entidad),
        alumno(_, _, Entidad, _)
    ->  atom_string(Entidad, Texto)
    ).
