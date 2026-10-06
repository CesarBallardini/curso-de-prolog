:- encoding(utf8).

% Capítulo 87 - Una clase más de preguntas: el horario de una materia.
%
% «¿Cuándo se cursa lógica?» pregunta por el horario de la oferta del
% capítulo 73, que no está en la base del capítulo 42. Este archivo
% agrega la pregunta sin modificar los módulos de las versiones
% anteriores: una regla de la gramática, la evaluación, la explicación y
% la forma de escribir la respuesta, como cláusulas de los predicados
% multifile de gramatica.pl, evaluar.pl y preguntas.pl (Patrón 79). La
% forma lógica es cuando(Materia), y la respuesta, horario(Clases), una
% lista de clase(Dia, Franja, Aula) del horario de ejemplo del capítulo
% 73. sql/2 no tiene traducción para cuando/1: el horario no es una tabla
% de la base.
%
% solo-local: carga módulos de otros capítulos.
%
%?- preguntar("¿Cuándo se cursa lógica?").

:- module(horario,
          [ clases_de/2
          ]).

:- reexport(preguntas).
:- use_module(gramatica).
:- use_module(nombres).
:- use_module('../capitulo-73/oferta',
              [ oferta/2,
                horario_ejemplo/1,
                momento/4,
                aula/4
              ]).

% «dictar» se agrega al léxico del capítulo 53, como en lemas.pl.
lexico:verbo("dictar", regular).

%!  clases_de(+Materia, -Clases:list) is det.
%
%   Clases son las clases semanales de Materia en el horario de ejemplo
%   del capítulo 73, ordenadas: clase(Dia, Franja, Aula), con los días y
%   las franjas numerados desde 1.
clases_de(Materia, Clases) :-
    oferta(cuatrimestre, Oferta),
    horario_ejemplo(Horario),
    findall(clase(Dia, Franja, Aula),
            ( member(asignada(Materia-_, NumeroAula, Inicio, _), Horario),
              momento(Oferta, Inicio, Dia, Franja),
              aula(Oferta, NumeroAula, Aula, _) ),
            Clases0),
    sort(Clases0, Clases).

gramatica:pregunta(cuando(Materia)) -->
    palabra("cuando"),
    palabra("se"),
    [Palabra],
    { lemas:analisis(Palabra, verbo(Lema, _, 3, singular)),
      memberchk(Lema, ["cursar", "dictar"]) },
    nombre_propio(materia, Materia).

evaluar:evaluar(cuando(Materia), horario(Clases)) :-
    clases_de(Materia, Clases).

evaluar:explicar(cuando(Materia), Asignadas) :-
    horario_ejemplo(Horario),
    findall(asignada(Materia-K, A, I, F),
            member(asignada(Materia-K, A, I, F), Horario),
            Asignadas).

preguntas:escribir_respuesta(horario(Clases)) :-
    (   Clases == []
    ->  format("No tiene clases en el horario~n")
    ;   maplist(texto_clase, Clases, Textos),
        atomic_list_concat(Textos, '; ', Texto),
        format("~w~n", [Texto])
    ).

preguntas:escribir_explicacion(Asignadas) :-
    Asignadas = [asignada(_, _, _, _)|_],
    forall(member(A, Asignadas),
           ( format("  "),
             write_term(A, [quoted(true), spacing(next_argument)]),
             nl )).

%!  texto_clase(+Clase, -Texto:string) is det.
%
%   Texto describe Clase: el día, la franja y el aula.
texto_clase(clase(Dia, Franja, Aula), Texto) :-
    nth1(Dia, ["lunes", "martes", "miércoles", "jueves", "viernes"],
         NombreDia),
    format(string(Texto), "~s, franja ~d, aula ~w", [NombreDia, Franja, Aula]).
