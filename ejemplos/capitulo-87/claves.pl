:- encoding(utf8).

% Capítulo 87 - Versión 1: palabras clave y plantillas.
%
% La pregunta se reduce a tres datos: la clase de respuesta que pide (una
% lista con «quién» o «qué», un número con «cuántos», sí o no si no tiene
% palabra interrogativa), el verbo, reconocido por el comienzo de la
% palabra, y los nombres propios que menciona. Una plantilla por clase de
% respuesta consulta la base del capítulo 42. Las demás palabras no se
% leen: la versión responde preguntas sencillas, y responde mal las que
% tienen una negación o un modificador.
%
% solo-local: carga módulos.
%
%?- responder_claves("¿Quién cursa lógica?", R).
%?- responder_claves("¿Cuántos aprobaron álgebra?", R).

:- module(claves,
          [ responder_claves/2,
            datos_clave/4
          ]).

:- use_module('../capitulo-42/base').
:- use_module(palabras).
:- use_module(nombres).

%!  responder_claves(+Texto, -Respuesta) is semidet.
%
%   Respuesta responde la pregunta Texto según sus palabras clave:
%   lista(Nombres), numero(N), si o no. Falla si la pregunta no tiene un
%   verbo conocido o no nombra lo que su plantilla necesita.
responder_claves(Texto, Respuesta) :-
    datos_clave(Texto, Clase, Verbo, Entidades),
    plantilla(Clase, Verbo, Entidades, Respuesta).

%!  datos_clave(+Texto, -Clase, -Verbo, -Entidades:list) is semidet.
%
%   Clase es la clase de respuesta que pide Texto, Verbo el primer verbo
%   que reconoce, y Entidades los nombres propios que menciona, como
%   pares Tipo-Entidad, en el orden del texto.
datos_clave(Texto, Clase, Verbo, Entidades) :-
    palabras(Texto, Palabras),
    clase(Palabras, Clase),
    once(( member(P, Palabras), verbo_clave(P, Verbo) )),
    entidades(Palabras, Entidades).

%!  clase(+Palabras:list(string), -Clase) is det.
%
%   Clase es lista si hay una palabra interrogativa que pide una lista,
%   numero si pide una cantidad, y si_no si no hay ninguna.
clase(Palabras, Clase) :-
    (   member(P, Palabras), interrogativa(P, Clase0)
    ->  Clase = Clase0
    ;   Clase = si_no
    ).

% interrogativa(Palabra, Clase): la clase de respuesta que pide Palabra.
interrogativa("quién", lista).
interrogativa("quiénes", lista).
interrogativa("qué", lista).
interrogativa("cuántos", numero).
interrogativa("cuántas", numero).

%!  verbo_clave(+Palabra:string, -Verbo) is semidet.
%
%   Palabra empieza como una forma de Verbo.
verbo_clave(Palabra, Verbo) :-
    raiz_clave(Raiz, Verbo),
    string_concat(Raiz, _, Palabra),
    !.

% raiz_clave(Raiz, Verbo): las palabras que empiezan con Raiz son formas
% de Verbo. «aprob» no reconoce «aprueba».
raiz_clave("curs", cursar).
raiz_clave("aprob", aprobar).
raiz_clave("necesit", necesitar).

%!  entidades(+Palabras:list(string), -Entidades:list) is det.
%
%   Entidades son los nombres propios de Palabras, como Tipo-Entidad.
entidades([], []).
entidades([P|Ps], Entidades) :-
    (   phrase(nombre_propio(Tipo, Entidad), [P|Ps], Resto)
    ->  Entidades = [Tipo-Entidad|Es],
        entidades(Resto, Es)
    ;   entidades(Ps, Entidades)
    ).

%!  plantilla(+Clase, +Verbo, +Entidades:list, -Respuesta) is semidet.
%
%   Respuesta responde la plantilla de Clase con Verbo y Entidades. Con una
%   materia y una lista o un número, la pregunta es por los alumnos; con
%   un alumno, por las materias; sí o no necesita un alumno y una materia.
plantilla(lista, Verbo, Entidades, lista(Nombres)) :-
    respuestas(Verbo, Entidades, Claves),
    maplist(nombre_de, Claves, Nombres).
plantilla(numero, Verbo, Entidades, numero(N)) :-
    respuestas(Verbo, Entidades, Claves),
    length(Claves, N).
plantilla(si_no, Verbo, Entidades, Respuesta) :-
    memberchk(alumno-Legajo, Entidades),
    memberchk(materia-Materia, Entidades),
    (   relacion(Verbo, Legajo, Materia)
    ->  Respuesta = si
    ;   Respuesta = no
    ).

%!  respuestas(+Verbo, +Entidades:list, -Claves:list) is semidet.
%
%   Claves son, ordenadas, las entidades que cumplen Verbo con la primera
%   entidad que se menciona: los alumnos de una materia, las materias de
%   un alumno, o los requisitos de una materia.
respuestas(Verbo, [Tipo-Entidad|_], Claves) :-
    (   Tipo == materia, Verbo \== necesitar
    ->  findall(L, relacion(Verbo, L, Entidad), Ls)
    ;   findall(M, relacion(Verbo, Entidad, M), Ls)
    ),
    sort(Ls, Claves).

%!  relacion(?Verbo, ?A, ?B) is nondet.
%
%   A y B cumplen Verbo en la base: A cursa o aprobó B, o la materia A
%   tiene a B como correlativa.
relacion(cursar, Legajo, Materia) :-
    inscripcion(Legajo, Materia, _).
relacion(aprobar, Legajo, Materia) :-
    aprobada(Legajo, Materia, _).
relacion(necesitar, Materia, Requisito) :-
    correlativa(Materia, Requisito).
