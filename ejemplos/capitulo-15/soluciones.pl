:- encoding(utf8).

% Capítulo 15 - Soluciones de los ejercicios.
%
% Los ejercicios 10 y 15 usan library(reif) y están en soluciones_puras.pl.
%
%?- paridad(3, P).
%?- inscripcion_posible_por_anio(105, bd, R).

% --- Ejercicio 2 -----------------------------------------------------------

%!  no(:Objetivo) is semidet.
%
%   Objetivo no se puede probar: la definición de \+/1.
no(Objetivo) :-
    (   call(Objetivo)
    ->  fail
    ;   true
    ).

%!  una_vez(:Objetivo) is semidet.
%
%   La primera respuesta de Objetivo: la definición de once/1.
una_vez(Objetivo) :-
    (   call(Objetivo)
    ->  true
    ).

%!  ignorar(:Objetivo) is det.
%
%   Ejecuta Objetivo si puede, y se cumple igual: la definición de ignore/1.
ignorar(Objetivo) :-
    (   call(Objetivo)
    ->  true
    ;   true
    ).

% --- Ejercicio 3 -----------------------------------------------------------

%!  maximo(+X:number, +Y:number, -M:number) is det.
%!  maximo(+X:number, +Y:number, +M:number) is semidet.
%
%   M es el mayor de X e Y.
maximo(X, Y, M) :-
    (   X >= Y
    ->  M = X
    ;   M = Y
    ).

%!  descuento(+Edad:integer, -D:integer) is det.
%!  descuento(+Edad:integer, +D:integer) is semidet.
%
%   D es el descuento que corresponde a Edad.
descuento(Edad, D) :-
    (   Edad < 12
    ->  D = 50
    ;   Edad >= 65
    ->  D = 30
    ;   D = 0
    ).

% --- Ejercicio 4 -----------------------------------------------------------

%!  valor_absoluto(+X:number, -A:number) is det.
%!  valor_absoluto(+X:number, +A:number) is semidet.
%
%   A es el valor absoluto de X.
valor_absoluto(X, A) :-
    (   X < 0
    ->  A is -X
    ;   A = X
    ).

% --- Ejercicio 5 -----------------------------------------------------------

%!  paridad(+N:integer, -P:atom) is det.
%!  paridad(+N:integer, +P:atom) is semidet.
%
%   P es par o impar, según N.
paridad(N, P) :-
    (   0 =:= N mod 2
    ->  P = par
    ;   P = impar
    ).

% --- Ejercicio 9 -----------------------------------------------------------

%!  contar_hasta(+N:integer) is det.
%
%   Escribe los números de 1 a N, con un bucle por falla.
contar_hasta(N) :-
    (   between(1, N, I),
        format("~d~n", [I]),
        fail
    ;   true
    ).

%!  contar_hasta_rec(+N:integer) is det.
%
%   Escribe los números de 1 a N, con una recursión.
contar_hasta_rec(N) :-
    contando(1, N).

%!  contando(+I:integer, +N:integer) is det.
%
%   Escribe los números de I a N.
contando(I, N) :-
    (   I > N
    ->  true
    ;   format("~d~n", [I]),
        I1 is I + 1,
        contando(I1, N)
    ).

%!  suma_hasta(+N:integer, -S:integer) is det.
%
%   S es la suma de 1 a N: con la recursión, porque el resultado se construye
%   durante el recorrido.
suma_hasta(N, S) :-
    sumando(1, N, 0, S).

%!  sumando(+I:integer, +N:integer, +Hasta:integer, -S:integer) is det.
%
%   S es Hasta más la suma de I a N.
sumando(I, N, Hasta, S) :-
    (   I > N
    ->  S = Hasta
    ;   Ahora is Hasta + I,
        I1 is I + 1,
        sumando(I1, N, Ahora, S)
    ).

% --- Ejercicios 8 y 14: el menú, con la orden todas y órdenes incompletas ---

% edad(P, A): P tiene A años.
edad(juan, 68).
edad(ana, 41).
edad(pedro, 45).
edad(luis, 12).
edad(eva, 8).
edad(sofia, 3).

%!  listar_edades is det.
%
%   Escribe una línea por cada persona de la base, con su edad.
listar_edades :-
    (   edad(P, A),
        format("~w: ~d~n", [P, A]),
        fail
    ;   true
    ).

%!  menu(+In) is det.
%
%   Lee órdenes del stream In y ejecuta cada una, hasta leer salir o llegar
%   al final del stream.
menu(In) :-
    repeat,
    read(In, Orden),
    ejecutar(Orden),
    (   Orden == salir
    ;   Orden == end_of_file
    ),
    !.

%!  ejecutar(+Orden) is det.
%
%   Ejecuta una orden del menú. Una orden con una variable libre es una orden
%   incompleta: se informa, en lugar de responder por cualquier persona.
%   var/1, que el capítulo 32 presenta, reconoce la variable libre.
ejecutar(edad(P)) :-
    var(P),
    !,
    format("Orden incompleta: falta el nombre~n").
ejecutar(edad(P)) :-
    !,
    (   edad(P, A)
    ->  format("~w tiene ~d años~n", [P, A])
    ;   format("~w no está en la base~n", [P])
    ).
ejecutar(todas) :-
    !,
    listar_edades.
ejecutar(salir) :-
    !,
    format("Fin~n").
ejecutar(end_of_file) :-
    !.
ejecutar(Orden) :-
    format("Orden desconocida: ~q~n", [Orden]).

% --- Ejercicios 6, 7, 11 y 12: los datos de Inscripciones del capítulo -------

% alumno(Legajo, Nombre, Carrera, Ingreso): el alumno de ese legajo cursa esa
% carrera desde el año de ingreso.
alumno(101, ana,      sistemas,   2023).
alumno(102, bruno,    sistemas,   2024).
alumno(103, carla,    civil,      2023).
alumno(104, diego,    sistemas,   2024).
alumno(105, elena,    civil,      2025).
alumno(106, facundo,  industrial, 2024).
alumno(107, gabriela, industrial, 2025).

% materia(Codigo, Nombre, Anio): la materia de ese código es del año indicado.
materia(am1, analisis_1,     1).
materia(alg, algebra,        1).
materia(log, logica,         1).
materia(am2, analisis_2,     2).
materia(pp,  paradigmas,     2).
materia(ssl, sintaxis,       2).
materia(bd,  bases_de_datos, 3).

% correlativa(Materia, Requisito): para cursar Materia es necesario aprobar
% Requisito.
correlativa(am2, am1).
correlativa(am2, alg).
correlativa(pp,  log).
correlativa(ssl, log).
correlativa(ssl, alg).
correlativa(bd,  pp).
correlativa(bd,  ssl).

% inscripcion(Legajo, Materia, Estado): el alumno se inscribió en la materia;
% Estado es cursando, o nota(N) con la nota final N, de 1 a 10.
inscripcion(101, am1, nota(8)).
inscripcion(101, alg, nota(9)).
inscripcion(101, log, nota(10)).
inscripcion(101, am2, nota(7)).
inscripcion(101, pp,  cursando).
inscripcion(102, am1, nota(4)).
inscripcion(102, log, nota(6)).
inscripcion(102, alg, nota(2)).
inscripcion(103, am1, nota(7)).
inscripcion(103, alg, nota(5)).
inscripcion(103, am2, cursando).
inscripcion(104, log, nota(9)).
inscripcion(104, alg, nota(7)).
inscripcion(104, pp,  nota(8)).
inscripcion(105, am1, cursando).
inscripcion(106, log, nota(3)).
inscripcion(106, am1, nota(6)).

%!  nota_minima(-N:integer) is det.
%
%   N es la nota mínima para aprobar una materia.
nota_minima(6).

%!  aprobada(?Legajo:integer, ?Materia:atom, ?Nota:integer) is nondet.
%
%   El alumno Legajo aprobó Materia con Nota. Con Legajo y Materia ligados
%   hay una respuesta o ninguna; con Nota ligada, además, se comprueba la
%   nota.
aprobada(Legajo, Materia, Nota) :-
    inscripcion(Legajo, Materia, nota(Nota)),
    nota_minima(Minima),
    Nota >= Minima.

%!  cursa(?Legajo:integer, ?Materia:atom) is nondet.
%
%   El alumno Legajo está cursando Materia, todavía sin nota.
cursa(Legajo, Materia) :-
    inscripcion(Legajo, Materia, cursando).

% vacantes(Materia, N): quedan N lugares en la materia.
vacantes(am1, 30).
vacantes(alg, 30).
vacantes(log, 0).
vacantes(am2, 25).
vacantes(pp,  25).
vacantes(ssl, 20).
vacantes(bd,  15).

%!  inscripcion_posible(+Legajo:integer, +Materia:atom, -Resultado) is det.
%
%   Resultado es aceptada si el alumno Legajo se puede inscribir en Materia,
%   o rechazada(Motivo) con el primer motivo que lo impide: alumno_inexistente,
%   materia_inexistente, ya_aprobada, ya_la_cursa, falta(Requisito) o
%   sin_vacantes. Una materia desaprobada se puede volver a cursar.
inscripcion_posible(Legajo, Materia, Resultado) :-
    (   \+ alumno(Legajo, _, _, _)
    ->  Resultado = rechazada(alumno_inexistente)
    ;   \+ materia(Materia, _, _)
    ->  Resultado = rechazada(materia_inexistente)
    ;   aprobada(Legajo, Materia, _)
    ->  Resultado = rechazada(ya_aprobada)
    ;   cursa(Legajo, Materia)
    ->  Resultado = rechazada(ya_la_cursa)
    ;   correlativa(Materia, Requisito),
        \+ aprobada(Legajo, Requisito, _)
    ->  Resultado = rechazada(falta(Requisito))
    ;   vacantes(Materia, 0)
    ->  Resultado = rechazada(sin_vacantes)
    ;   Resultado = aceptada
    ).

%!  puede_inscribirse(+Legajo:integer, +Materia:atom) is semidet.
%
%   El alumno Legajo se puede inscribir en Materia.
puede_inscribirse(Legajo, Materia) :-
    inscripcion_posible(Legajo, Materia, aceptada).

% --- Ejercicio 6 -----------------------------------------------------------

%!  primera_aprobada(+Legajo:integer, -Materia:atom) is semidet.
%
%   Materia es la primera materia aprobada del alumno Legajo. once/1 va en
%   este predicado, que promete una respuesta, y no en aprobada/3.
primera_aprobada(Legajo, Materia) :-
    once(aprobada(Legajo, Materia, _Nota)).

% --- Ejercicio 7 -----------------------------------------------------------

%!  listar_aprobadas(+Legajo:integer) is det.
%
%   Escribe una línea por cada materia aprobada del alumno, con su nota.
listar_aprobadas(Legajo) :-
    (   aprobada(Legajo, Materia, Nota),
        format("~w: ~d~n", [Materia, Nota]),
        fail
    ;   true
    ).

% --- Ejercicio 11 ----------------------------------------------------------

% requisitos(Materia, Lista): los requisitos de Materia, en una lista. Repite
% la información de correlativa/2: el capítulo 17 evita esa repetición.
requisitos(am1, []).
requisitos(alg, []).
requisitos(log, []).
requisitos(am2, [am1, alg]).
requisitos(pp,  [log]).
requisitos(ssl, [log, alg]).
requisitos(bd,  [pp, ssl]).

%!  requisitos_faltantes(+Legajo:integer, +Materia:atom, -Faltan:list) is det.
%
%   Faltan son los requisitos de Materia que el alumno Legajo no aprobó.
requisitos_faltantes(Legajo, Materia, Faltan) :-
    requisitos(Materia, Requisitos),
    no_aprobados(Requisitos, Legajo, Faltan).

%!  no_aprobados(+Materias:list, +Legajo:integer, -Faltan:list) is det.
%
%   Faltan son las materias de la lista que el alumno Legajo no aprobó. La
%   lista va primero: SWI-Prolog distingue [] de [_|_] por el primer
%   argumento, y así el recorrido no deja alternativas pendientes.
no_aprobados([], _, []).
no_aprobados([Materia|Resto], Legajo, Faltan) :-
    (   aprobada(Legajo, Materia, _)
    ->  Faltan = Faltan0
    ;   Faltan = [Materia|Faltan0]
    ),
    no_aprobados(Resto, Legajo, Faltan0).

% --- Ejercicio 12 ----------------------------------------------------------

%!  inscripcion_posible_por_anio(+Legajo:integer, +Materia:atom,
%!                               -Resultado) is det.
%
%   Como inscripcion_posible/3, con un motivo más: un alumno que ingresó en
%   2025 no puede cursar materias de tercer año. La condición va después de
%   verificar que el alumno y la materia existen, y antes de los requisitos.
inscripcion_posible_por_anio(Legajo, Materia, Resultado) :-
    (   \+ alumno(Legajo, _, _, _)
    ->  Resultado = rechazada(alumno_inexistente)
    ;   \+ materia(Materia, _, _)
    ->  Resultado = rechazada(materia_inexistente)
    ;   alumno(Legajo, _, _, 2025),
        materia(Materia, _, 3)
    ->  Resultado = rechazada(anio_no_permitido)
    ;   inscripcion_posible(Legajo, Materia, Resultado)
    ).

% --- Ejercicio 16 ----------------------------------------------------------

%!  tomada(?Legajo:integer, ?Materia:atom, ?Anio:integer) is nondet.
%
%   El alumno Legajo cursa Materia o ya la aprobó, y Materia es del año Anio.
%   La disyunción está en el cuerpo.
tomada(Legajo, Materia, Anio) :-
    (   cursa(Legajo, Materia)
    ;   aprobada(Legajo, Materia, _)
    ),
    materia(Materia, _, Anio).

%!  tomada_en_dos(?Legajo:integer, ?Materia:atom, ?Anio:integer) is nondet.
%
%   La misma relación que tomada/3, con una cláusula por alternativa. El
%   objetivo que seguía a la disyunción se repite en las dos.
tomada_en_dos(Legajo, Materia, Anio) :-
    cursa(Legajo, Materia),
    materia(Materia, _, Anio).
tomada_en_dos(Legajo, Materia, Anio) :-
    aprobada(Legajo, Materia, _),
    materia(Materia, _, Anio).

% --- Ejercicio 17 ----------------------------------------------------------

%!  eco(+In) is det.
%
%   Escribe, uno por línea, los términos que lee del stream In. El bucle no
%   tiene condición de salida: al final del stream, read/2 da end_of_file
%   cada vez, y el ciclo no termina nunca.
eco(In) :-
    repeat,
    read(In, Termino),
    format("~w~n", [Termino]),
    fail.

%!  eco_hasta_el_final(+In) is det.
%
%   Escribe, uno por línea, los términos que lee del stream In, hasta llegar
%   al final del stream.
eco_hasta_el_final(In) :-
    repeat,
    read(In, Termino),
    escribir_termino(Termino),
    Termino == end_of_file,
    !.

%!  escribir_termino(+Termino) is det.
%
%   Escribe Termino en una línea, salvo la marca de fin del stream.
escribir_termino(Termino) :-
    (   Termino == end_of_file
    ->  true
    ;   format("~w~n", [Termino])
    ).

% --- Ejercicio 18 ----------------------------------------------------------

%!  propiedad(?Nombre:atom, +N:integer) is nondet.
%
%   N cumple la propiedad Nombre: par, positivo o mayor_que_10.
propiedad(par, N) :-
    0 =:= N mod 2.
propiedad(positivo, N) :-
    N > 0.
propiedad(mayor_que_10, N) :-
    N > 10.

%!  cumple(+N:integer) is det.
%
%   Escribe una línea por cada propiedad que N cumple, y ninguna si no cumple
%   ninguna. *-> conserva todas las respuestas de la condición y el bucle por
%   falla las recorre; ignore/1 da una respuesta en los dos casos.
cumple(N) :-
    ignore(( propiedad(P, N)
           *-> format("~w~n", [P]),
               fail
           ;   format("ninguna~n") )).

%!  presentar(+P) is det.
%
%   Escribe el nombre de P y, si se conoce, su edad: presentar/1 de
%   condicional.pl con un condicional en lugar de ignore/1.
presentar(P) :-
    format("~w", [P]),
    (   edad(P, A)
    ->  format(" (~d años)", [A])
    ;   true
    ),
    nl.
