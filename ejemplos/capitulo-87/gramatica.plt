:- encoding(utf8).

% Las formas lógicas tienen variables: se comparan con =@=, que acepta
% variables con otro nombre.

:- begin_tests(gramatica).

test(quien, [true(F =@= cual(X, y(alumno(X), cursar(X, log))))]) :-
    analizar("¿Quién cursa lógica?", F).

test(cuantos, [true(F =@= cuantos(X, y(alumno(X), aprobar(X, alg))))]) :-
    analizar("¿Cuántos aprobaron álgebra?", F).

test(negacion, [true(F =@= cual(X, y(alumno(X), no(aprobar(X, alg)))))]) :-
    analizar("¿Quién no aprobó álgebra?", F).

test(de_carrera,
     [true(F =@= cuantos(X, y(y(alumno(X), carrera(X, sistemas)),
                               aprobar(X, alg))))]) :-
    analizar("¿Cuántos alumnos de sistemas aprobaron álgebra?", F).

% El sujeto va después del verbo: ana cursa las materias.
test(objeto, [true(F =@= cual(X, y(materia(X), cursar(101, X))))]) :-
    analizar("¿Qué materias cursa ana?", F).

test(si_no, [true(F == si_no(aprobar(101, log)))]) :-
    analizar("¿Ana aprobó lógica?", F).

test(todos,
     [true(F =@= si_no(todo(X, y(alumno(X), carrera(X, civil)),
                            cursar(X, am1))))]) :-
    analizar("¿Todos los alumnos de civil cursan análisis 1?", F).

test(ninguno, [true(F =@= si_no(no(alguno(X, alumno(X), aprobar(X, ssl)))))]) :-
    analizar("¿Ningún alumno aprobó sintaxis?", F).

test(relativa,
     [true(F =@= cual(X, y(y(alumno(X), cursar(X, pp)), aprobar(X, log))))]) :-
    analizar("¿Qué alumnos que cursan paradigmas aprobaron lógica?", F).

% «qué» sin nombre: el objeto primero, después el sujeto.
test(dos_lecturas,
     [true(Fs =@= [cual(X, y(materia(X), necesitar(bd, X))),
                   cual(Y, y(materia(Y), necesitar(Y, bd)))])]) :-
    lecturas("¿Qué necesita bases de datos?", Fs).

% Con «materias» y el verbo en plural, la materia es el sujeto.
test(concordancia, [true(Fs =@= [cual(X, y(materia(X), necesitar(X, log)))])]) :-
    lecturas("¿Qué materias necesitan lógica?", Fs).

% Los tipos: una materia no cursa, y ana no es una materia.
test(tipos, [true(Fs == [])]) :-
    lecturas("¿Qué materias cursan ana?", Fs).

test(numero, [fail]) :-
    analizar("¿Cuántos alumnos aprobó lógica?", _).

test(genero, [fail]) :-
    analizar("¿Cuántas alumnos aprobaron lógica?", _).

test(desconocida, [fail]) :-
    analizar("¿Quién enseña lógica?", _).

test(verbo_tipos, [all(V == [cursar, aprobar])]) :-
    verbo_tipos(V, alumno, materia).

:- end_tests(gramatica).
