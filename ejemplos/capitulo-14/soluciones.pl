:- encoding(utf8).

% Capítulo 14 - Soluciones de los ejercicios.
%
%?- signo(-3, S).
%?- aprobadas_de(101, Materia).
%?- reemplazo(b, [a, b, c, b], z, L).

% --- Ejercicio 3 -----------------------------------------------------------

%!  sacar(+X, +L:list, -R:list) is semidet.
%
%   R es L sin la primera aparición de X; falla si X no está en L.
sacar(X, [X|Resto], Resto).
sacar(X, [Otro|Resto], [Otro|RestoR]) :-
    Otro \== X,
    sacar(X, Resto, RestoR).

% --- Ejercicio 4 -----------------------------------------------------------

% padre(P, H): P es el padre de H.
padre(ana, luis).
padre(luis, eva).

%!  abuelo(?A, ?N) is nondet.
%
%   A es abuelo de N: A es padre de alguien que es padre de N.
abuelo(A, N) :-
    padre(A, P),
    padre(P, N).

% --- Ejercicio 5 -----------------------------------------------------------

%!  signo(+N:number, -S:atom) is det.
%!  signo(+N:number, +S:atom) is semidet.
%
%   S es negativo, cero o positivo, según N. Cada salida se liga después del
%   corte, de modo que el resultado no depende de que S llegue ligada.
signo(N, S) :-
    N < 0,
    !,
    S = negativo.
signo(N, S) :-
    N =:= 0,
    !,
    S = cero.
signo(_, positivo).

% --- Ejercicio 7: los datos de Inscripciones del capítulo -----------------

% inscripcion(Legajo, Materia, Estado): Estado es cursando o nota(N).
inscripcion(101, am1, nota(8)).
inscripcion(101, alg, nota(9)).
inscripcion(101, log, nota(10)).
inscripcion(101, am2, nota(7)).
inscripcion(101, pp,  cursando).
inscripcion(102, am1, nota(4)).
inscripcion(102, log, nota(6)).
inscripcion(102, alg, nota(2)).

%!  nota_minima(-N:integer) is det.
%
%   N es la nota mínima para aprobar una materia.
nota_minima(6).

%!  aprobada(?Legajo:integer, ?Materia:atom, ?Nota:integer) is nondet.
%
%   El alumno Legajo aprobó Materia con Nota.
aprobada(Legajo, Materia, Nota) :-
    inscripcion(Legajo, Materia, nota(Nota)),
    nota_minima(Minima),
    Nota >= Minima.

%!  aprobadas_de(?Legajo:integer, ?Materia:atom) is nondet.
%
%   El alumno Legajo aprobó Materia, con cualquier nota.
aprobadas_de(Legajo, Materia) :-
    aprobada(Legajo, Materia, _Nota).

% --- Ejercicio 8 -----------------------------------------------------------

% prestamo_por_defecto(Id, Devuelto, Vencido): Devuelto es la fecha de
% devolución o no; Vencido es la fecha desde la que está vencido o no.
prestamo_por_defecto(p1, no,       no).
prestamo_por_defecto(p2, 20260910, no).
prestamo_por_defecto(p3, no,       20260901).

%!  vencido_por_defecto(?Id:atom) is nondet.
%
%   El préstamo Id está vencido, con la representación por defecto: es
%   necesario distinguir el valor especial no de una fecha.
vencido_por_defecto(Id) :-
    prestamo_por_defecto(Id, no, Desde),
    Desde \== no.

% prestamo(Id, Estado): Estado es en_curso, devuelto(Fecha) o
% vencido(Desde).
prestamo(p1, en_curso).
prestamo(p2, devuelto(20260910)).
prestamo(p3, vencido(20260901)).

%!  vencido(?Id:atom) is nondet.
%
%   El préstamo Id está vencido. El caso se selecciona por unificación.
vencido(Id) :-
    prestamo(Id, vencido(_Desde)).

% --- Ejercicio 12 ----------------------------------------------------------

%!  iguala(?A, ?B) is semidet.
%
%   A y B unifican. Liga variables de los dos: sus argumentos son ?, no @.
iguala(A, B) :-
    A = B.

% --- Ejercicio 15 ----------------------------------------------------------

%!  reemplazo(?Viejo, +Lista:list, ?Nuevo, -Resultado:list) is nondet.
%!  reemplazo(?Viejo, -Lista:list, ?Nuevo, +Resultado:list) is nondet.
%
%   Resultado es Lista con una aparición de Viejo reemplazada por Nuevo. Si
%   Viejo aparece varias veces, hay una respuesta por cada aparición.
reemplazo(Viejo, [Viejo|Resto], Nuevo, [Nuevo|Resto]).
reemplazo(Viejo, [Otro|Resto], Nuevo, [Otro|Resto2]) :-
    reemplazo(Viejo, Resto, Nuevo, Resto2).
