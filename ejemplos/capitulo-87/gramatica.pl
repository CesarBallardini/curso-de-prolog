:- encoding(utf8).

% Capítulo 87 - Versión 2: una gramática que da formas lógicas.
%
% La gramática relaciona una pregunta con su forma lógica, con la técnica
% de Montague que Pereira y Shieber usan en su sección 4.1: un sintagma
% nominal recibe la propiedad que el resto de la oración le aplica, como
% un término X^P, y devuelve la fórmula completa. Los cuantificadores son
% los del capítulo 54, todo(X, R, A) y alguno(X, R, A), con no(F) y
% y(A, B). Una pregunta es cual(X, F), las X que cumplen F; cuantos(X, F),
% cuántas son; o si_no(F), si F se cumple.
%
% Los verbos y los nombres comunes se reconocen por su lema, con el
% análisis del capítulo 53, de modo que «aprobó», «aprueba» y «aprobaron»
% son el mismo verbo. Cada verbo declara el tipo de su sujeto y de su
% objeto, y un sintagma de otro tipo no puede ocupar ese lugar: así se
% descarta «¿qué materias cursa ana?» con «materias» como sujeto.
%
% solo-local: carga módulos.
%
%?- analizar("¿Cuántos alumnos aprobaron álgebra?", F).
%?- lecturas("¿Qué necesita bases de datos?", Fs).

:- module(gramatica,
          [ pregunta//1,
            analizar/2,
            lecturas/2,
            verbo_tipos/3,
            palabra//1
          ]).

:- use_module(palabras).
:- use_module(lemas).
:- use_module(nombres).

% Otros archivos pueden agregar clases de preguntas, sintagmas nominales
% y verbos.
:- multifile pregunta//1, sn//3, verbo_tipos/3.

%!  analizar(+Texto, -Forma) is semidet.
%
%   Forma es la forma lógica de la primera lectura de la pregunta Texto.
%   Falla si la gramática no la analiza.
analizar(Texto, Forma) :-
    palabras(Texto, Palabras),
    once(phrase(pregunta(Forma), Palabras)).

%!  lecturas(+Texto, -Formas:list) is det.
%
%   Formas son las formas lógicas de todas las lecturas de Texto, sin
%   repetir, en el orden en que la gramática las encuentra.
lecturas(Texto, Formas) :-
    palabras(Texto, Palabras),
    findall(F, phrase(pregunta(F), Palabras), Fs),
    variantes_distintas(Fs, Formas).

%!  variantes_distintas(+Formas:list, -Distintas:list) is det.
%
%   Distintas son las Formas sin las que son variantes de una anterior.
variantes_distintas([], []).
variantes_distintas([F|Fs], [F|Ds]) :-
    exclude(=@=(F), Fs, Resto),
    variantes_distintas(Resto, Ds).

% --- Las preguntas ---------------------------------------------------

%!  pregunta(?Forma)// is nondet.
%
%   Una pregunta con forma lógica Forma: con «quién», con «qué» o
%   «cuántos» seguidos o no de un nombre, o de sí o no.
pregunta(cual(X, y(alumno(X), F))) -->
    quien(Numero),
    sv(Numero, alumno, X^F).
pregunta(Forma) -->
    interrogativo(Clase, Genero),
    nucleo(Numero, Genero, Tipo, X^R),
    resto_interrogativo(Numero, Tipo, X^F),
    { forma_pregunta(Clase, X, y(R, F), Forma) }.
pregunta(Forma) -->
    interrogativo(Clase, _),
    resto_interrogativo(_, Tipo, X^F),
    { restriccion(Tipo, X, R),
      forma_pregunta(Clase, X, y(R, F), Forma) }.
pregunta(si_no(F)) -->
    oracion(F).

%!  resto_interrogativo(?Numero, ?Tipo, ?P)// is nondet.
%
%   Lo que sigue a la palabra interrogativa: el verbo con su sujeto, si
%   lo interrogado es el objeto, o el sintagma verbal, si es el sujeto. P
%   es X^F, la propiedad que se pregunta de X, de Tipo.
resto_interrogativo(_, Tipo, X^F) -->
    verbo(NumeroV, Lema, TipoS, Tipo),
    { A =.. [Lema, Y, X] },
    sn(NumeroV, TipoS, (Y^A)^F).
resto_interrogativo(Numero, Tipo, X^F) -->
    sv(Numero, Tipo, X^F).

%!  forma_pregunta(?Clase, ?X, ?F, ?Forma) is det.
%
%   Forma es la pregunta de Clase por las X que cumplen F.
forma_pregunta(cual, X, F, cual(X, F)).
forma_pregunta(cuantos, X, F, cuantos(X, F)).

%!  restriccion(?Tipo, ?X, ?R) is det.
%
%   R dice que X es de Tipo.
restriccion(alumno, X, alumno(X)).
restriccion(materia, X, materia(X)).

%!  quien(?Numero)// is semidet.
%
%   «quién» o «quiénes».
quien(singular) --> palabra("quien").
quien(plural) --> palabra("quienes").

%!  interrogativo(?Clase, ?Genero)// is nondet.
%
%   Una palabra que pide una lista (cual) o una cantidad (cuantos).
interrogativo(cual, _) --> palabra("que").
interrogativo(cual, _) --> palabra("cuales").
interrogativo(cuantos, masculino) --> palabra("cuantos").
interrogativo(cuantos, femenino) --> palabra("cuantas").

% --- Oraciones y sintagmas -------------------------------------------

%!  oracion(?F)// is nondet.
%
%   Una oración con sujeto y predicado cuya fórmula es F: el sujeto
%   recibe la propiedad del predicado.
oracion(F) -->
    sn(Numero, Tipo, (X^P)^F),
    sv(Numero, Tipo, X^P).

%!  sn(?Numero, ?Tipo, ?SN)// is nondet.
%
%   Un sintagma nominal de Numero, que nombra algo de Tipo. SN es
%   (X^P)^F: aplicado a la propiedad X^P, da la fórmula F.
sn(singular, Tipo, (E^P)^P) -->
    nombre_propio(Tipo, E),
    { Tipo \== carrera }.
sn(plural, Tipo, (X^P)^todo(X, R, P)) -->
    todos(Genero),
    nucleo(plural, Genero, Tipo, X^R).
sn(singular, Tipo, (X^P)^alguno(X, R, P)) -->
    alguno(Genero),
    nucleo(singular, Genero, Tipo, X^R).
sn(singular, Tipo, (X^P)^no(alguno(X, R, P))) -->
    ninguno(Genero),
    nucleo(singular, Genero, Tipo, X^R).

%!  todos(?Genero)// is semidet.
%
%   «todos los» o «todas las».
todos(masculino) --> palabra("todos"), palabra("los").
todos(femenino) --> palabra("todas"), palabra("las").

%!  alguno(?Genero)// is semidet.
%
%   «algún» o «alguna».
alguno(masculino) --> palabra("algun").
alguno(femenino) --> palabra("alguna").

%!  ninguno(?Genero)// is semidet.
%
%   «ningún» o «ninguna».
ninguno(masculino) --> palabra("ningun").
ninguno(femenino) --> palabra("ninguna").

%!  nucleo(?Numero, ?Genero, ?Tipo, ?P)// is nondet.
%
%   Un nombre común con sus modificadores: «alumnos de sistemas»,
%   «materias que cursa ana». P es X^R, lo que el núcleo dice de X.
nucleo(Numero, Genero, Tipo, X^R) -->
    nombre_comun(Numero, Genero, Tipo, X^R0),
    de_carrera(Tipo, X, R0, R1),
    relativa(Numero, Tipo, X, R1, R).

%!  nombre_comun(?Numero, ?Genero, ?Tipo, ?P)// is semidet.
%
%   Una forma de un nombre común cuyo lema nombra a Tipo.
nombre_comun(Numero, Genero, Tipo, X^R) -->
    [Palabra],
    { analisis(Palabra, nombre(Lema, Genero, Numero)),
      nombre_tipo(Lema, Tipo),
      restriccion(Tipo, X, R) }.

% nombre_tipo(Lema, Tipo): el nombre común Lema nombra a los de Tipo.
nombre_tipo("alumno", alumno).
nombre_tipo("materia", materia).

%!  de_carrera(?Tipo, ?X, ?R0, ?R)// is nondet.
%
%   «de sistemas» después de un nombre de alumnos agrega la carrera a R0;
%   sin ese complemento, R es R0.
de_carrera(alumno, X, R0, y(R0, carrera(X, C))) -->
    palabra("de"),
    nombre_propio(carrera, C).
de_carrera(_, _, R, R) -->
    [].

%!  relativa(?Numero, ?Tipo, ?X, ?R0, ?R)// is nondet.
%
%   «que» y un sintagma verbal del que X es el sujeto agregan una
%   condición a R0; sin relativa, R es R0.
relativa(Numero, Tipo, X, R0, y(R0, F)) -->
    palabra("que"),
    sv(Numero, Tipo, X^F).
relativa(_, _, _, R, R) -->
    [].

%!  sv(?Numero, ?Tipo, ?P)// is nondet.
%
%   Un sintagma verbal en Numero cuyo sujeto es de Tipo. P es X^F, la
%   propiedad que el predicado dice de X. El átomo del verbo se arma
%   antes de analizar el objeto, que lo recibe ya construido.
sv(Numero, Tipo, X^no(F)) -->
    palabra("no"),
    sv(Numero, Tipo, X^F).
sv(Numero, Tipo, X^F) -->
    verbo(Numero, Lema, Tipo, TipoO),
    { A =.. [Lema, X, Y] },
    sn(_, TipoO, (Y^A)^F).

%!  verbo(?Numero, ?Lema, ?TipoS, ?TipoO)// is nondet.
%
%   Una forma de tercera persona de un verbo transitivo cuyo sujeto es de
%   TipoS y su objeto de TipoO.
verbo(Numero, Lema, TipoS, TipoO) -->
    [Palabra],
    { analisis(Palabra, verbo(LemaS, _, 3, Numero)),
      atom_string(Lema, LemaS),
      verbo_tipos(Lema, TipoS, TipoO) }.

% verbo_tipos(Lema, TipoS, TipoO): el sujeto de Lema es de TipoS y su
% objeto de TipoO.
verbo_tipos(cursar, alumno, materia).
verbo_tipos(aprobar, alumno, materia).
verbo_tipos(necesitar, materia, materia).

%!  palabra(?Simple)// is semidet.
%
%   La palabra siguiente, sin tildes, es Simple.
palabra(Simple) -->
    [Palabra],
    { sin_tildes(Palabra, Simple) }.
