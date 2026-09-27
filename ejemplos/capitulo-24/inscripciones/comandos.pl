:- encoding(utf8).

% Capítulo 24 - Inscripciones, módulo comandos: el lenguaje de comandos.
%
% ejecutar/2 analiza un comando en texto y lo realiza con las operaciones de
% reglas y los informes. Las gramáticas palabras//1 y comando//1 se exportan
% para probarlas por separado.
%
% solo-local: SWISH no admite módulos propios en un programa.
%
%?- ejecutar("listar analisis_1", Respuesta).

:- module(comandos,
          [ ejecutar/2,
            palabras//1,
            comando//1
          ]).

:- use_module(library(dcg/basics)).
:- use_module(datos).
:- use_module(reglas).
:- use_module(informes).

%!  ejecutar(+Texto:string, -Respuesta) is det.
%
%   Analiza el comando Texto y lo ejecuta. Respuesta es el resultado:
%   aceptada o rechazada(Motivo) para una inscripción, baja o
%   rechazada(no_la_cursa) para una baja, inscriptos(Legajos) para un
%   listado, promedio(P) o sin_notas para un promedio, y no_entendido si el
%   texto no es un comando.
ejecutar(Texto, Respuesta) :-
    string_codes(Texto, Codigos),
    (   phrase(palabras(Palabras), Codigos),
        phrase(comando(Comando), Palabras)
    ->  realizar(Comando, Respuesta)
    ;   Respuesta = no_entendido
    ).

%!  palabras(-Palabras:list)// is det.
%
%   Palabras son las palabras y los números del texto, separados por
%   blancos. Una palabra es un átomo; un número, un entero.
palabras([P|Ps]) -->
    blanks,
    palabra(P),
    !,
    palabras(Ps).
palabras([]) -->
    blanks.

%!  palabra(-P)// is semidet.
%
%   P es un entero, si el texto empieza con dígitos, o un átomo formado por
%   letras, dígitos y guiones bajos.
palabra(N) -->
    integer(N),
    !.
palabra(A) -->
    csym(A).

%!  comando(?Comando)// is nondet.
%
%   La lista de palabras de Comando: inscribir(Legajo, Materia),
%   baja(Legajo, Materia), listar(Materia) o promedio(Legajo). Las materias
%   se escriben con su nombre, no con su código.
comando(inscribir(L, M)) -->
    [inscribir, a], legajo(L), [en], materia_por_nombre(M).
comando(baja(L, M)) -->
    [dar, de, baja, a], legajo(L), [en], materia_por_nombre(M).
comando(listar(M)) -->
    [listar], materia_por_nombre(M).
comando(promedio(L)) -->
    [promedio, de], legajo(L).

%!  legajo(?L)// is semidet.
%
%   El legajo de un alumno.
legajo(L) -->
    [L],
    { alumno(L, _, _, _) }.

%!  materia_por_nombre(?Codigo)// is semidet.
%
%   El nombre de la materia de código Codigo.
materia_por_nombre(Codigo) -->
    [Nombre],
    { materia(Codigo, Nombre, _) }.

%!  realizar(+Comando, -Respuesta) is det.
%
%   Ejecuta Comando, ya analizado, y da su Respuesta.
realizar(inscribir(L, M), Respuesta) :-
    inscribir(L, M, Respuesta).
realizar(baja(L, M), Respuesta) :-
    (   dar_de_baja(L, M)
    ->  Respuesta = baja
    ;   Respuesta = rechazada(no_la_cursa)
    ).
realizar(listar(M), inscriptos(Legajos)) :-
    inscriptos(M, Legajos).
realizar(promedio(L), Respuesta) :-
    (   promedio_de_alumno(L, P)
    ->  Respuesta = promedio(P)
    ;   Respuesta = sin_notas
    ).
