:- encoding(utf8).

% Capítulo 73 - Proyecto: horarios para Inscripciones. La representación.
%
% Una oferta es un término oferta(Semana, Clases, Aulas, Docentes):
% Semana es semana(Dias, Franjas), la cantidad de días y de franjas de dos
% horas de cada día; Clases, una lista de clase(Id, Materia, Anio,
% Docente, Cupo), una por cada clase semanal de cada materia; Aulas, una
% lista de aula(Nombre, Capacidad), numeradas por su posición; y Docentes,
% una lista de disponible(Docente, Dias), los días en que puede dar clase.
%
% Las materias y sus años son los del módulo datos de Inscripciones
% (capítulo 31); las clases semanales, los docentes, los cupos y las aulas
% son los hechos de este archivo.
%
% Un horario es un calendario del capítulo 72: una lista de
% asignada(Clase, Aula, Inicio, Fin), donde la clase es una tarea de
% duración 1, el aula es el procesador, e Inicio es el momento de la
% semana, de 0 a Dias * Franjas - 1. tareas:valido/2 verifica lo que
% comparten un horario y un calendario; horario_valido/2 agrega las
% reglas propias de un horario.
%
% solo-local: carga módulos de otros capítulos, y SWISH no permite cargar
% otro archivo.
%
%?- oferta(cuatrimestre, O), horario_ejemplo(H), horario_valido(O, H).
%?- oferta(cuatrimestre, O), horario_ejemplo(H), mostrar_anio(O, H, 1).

:- module(oferta,
          [ oferta/2,
            clase/6,
            momentos/2,
            momento/4,
            aula/4,
            disponible/3,
            incompatibles/3,
            horario_valido/2,
            choque/3,
            lineas_anio/4,
            mostrar_anio/3,
            horario_ejemplo/1,
            ver_ejemplo/1
          ]).

:- use_module('../capitulo-31/inscripciones/datos', [materia/3]).
:- use_module('../capitulo-72/tareas', []).

% --- Los datos de la oferta ---------------------------------------------------

% horas(Materia, N): la materia tiene N clases semanales de dos horas.
horas(am1, 3).
horas(alg, 2).
horas(log, 2).
horas(am2, 3).
horas(pp,  2).
horas(ssl, 2).
horas(bd,  2).

% dicta(Docente, Materia): el docente dicta la materia.
dicta(perez,  am1).
dicta(perez,  am2).
dicta(garcia, alg).
dicta(garcia, ssl).
dicta(lopez,  log).
dicta(lopez,  pp).
dicta(ruiz,   bd).

% cupo(Materia, N): se esperan N alumnos en cada clase de la materia.
cupo(am1, 40).
cupo(alg, 35).
cupo(log, 30).
cupo(am2, 25).
cupo(pp,  25).
cupo(ssl, 20).
cupo(bd,  15).

% dias_de(Docente, Dias): los días de la semana, de 1 (lunes) a 5
% (viernes), en que el docente puede dar clase.
dias_de(perez,  [1, 2, 3, 4]).
dias_de(garcia, [1, 2, 3, 4, 5]).
dias_de(lopez,  [2, 3, 4, 5]).
dias_de(ruiz,   [4, 5]).

% aulas(Aulas): las aulas de la facultad, con su capacidad.
aulas([aula(a1, 40), aula(a2, 30), aula(lab, 20)]).

% --- Las ofertas de ejemplo ---------------------------------------------------

%!  oferta(+Nombre, -Oferta) is semidet.
%
%   Oferta es la oferta de ejemplo Nombre. cuatrimestre es la de todas las
%   materias en una semana de cinco días con cuatro franjas; materias(Ms,
%   Dias, Franjas), con todo instanciado, la de las materias Ms en una
%   semana de Dias días con Franjas franjas, para medir con problemas más
%   chicos.
oferta(cuatrimestre, Oferta) :-
    findall(M, materia(M, _, _), Ms),
    oferta(materias(Ms, 5, 4), Oferta).
oferta(materias(Ms, Dias, Franjas),
       oferta(semana(Dias, Franjas), Clases, Aulas, Docentes)) :-
    must_be(list(atom), Ms),
    must_be(positive_integer, Dias),
    must_be(positive_integer, Franjas),
    findall(clase(M-I, M, Anio, D, Cupo),
            ( member(M, Ms),
              materia(M, _, Anio),
              horas(M, N),
              between(1, N, I),
              dicta(D, M),
              cupo(M, Cupo) ),
            Clases),
    aulas(Aulas),
    findall(disponible(D, Ds),
            ( dias_de(D, Ds0),
              include(hasta(Dias), Ds0, Ds) ),
            Docentes).
oferta(facultad(N),
       oferta(semana(5, 3), Clases, Aulas, Docentes)) :-
    must_be(nonneg, N),
    findall(clase(M-K, M, Anio, d(J), Cupo),
            ( between(1, N, I),
              atom_concat(m, I, M),
              Anio is (I - 1) mod 3 + 1,
              J is (I + 1) // 2,
              Cupo is 15 + (7 * I * I) mod 26,
              Horas is 2 + I mod 2,
              between(1, Horas, K) ),
            Clases),
    aulas(Aulas),
    Ultimo is (N + 1) // 2,
    findall(disponible(d(J), Ds),
            ( between(1, Ultimo, J),
              Libre is (3 * J) mod 5 + 1,
              findall(D, ( between(1, 5, D), D =\= Libre ), Ds) ),
            Docentes).

%!  hasta(+Maximo:integer, +Dia:integer) is semidet.
%
%   Dia no pasa de Maximo.
hasta(Maximo, Dia) :-
    Dia =< Maximo.

% --- Acceso a la oferta -------------------------------------------------------

%!  clase(+Oferta, ?Id, ?Materia, ?Anio, ?Docente, ?Cupo) is nondet.
%
%   Id es una clase de Oferta, de Materia, del año Anio, que dicta Docente
%   para Cupo alumnos. Con Id instanciado del todo hay a lo sumo una
%   respuesta, y memberchk/2 la da sin dejar alternativas pendientes; con
%   Id instanciado en parte, como M-K con K libre, hay una por clase.
clase(oferta(_, Clases, _, _), Id, Materia, Anio, Docente, Cupo) :-
    (   ground(Id)
    ->  memberchk(clase(Id, Materia, Anio, Docente, Cupo), Clases)
    ;   member(clase(Id, Materia, Anio, Docente, Cupo), Clases)
    ).

%!  momentos(+Oferta, -N:integer) is det.
%
%   La semana de Oferta tiene N momentos, numerados de 0 a N - 1.
momentos(oferta(semana(Dias, Franjas), _, _, _), N) :-
    N is Dias * Franjas.

%!  momento(+Oferta, ?S:integer, ?Dia:integer, ?Franja:integer) is nondet.
%
%   El momento S de la semana de Oferta es la franja Franja del día Dia;
%   los días y las franjas se numeran desde 1.
momento(oferta(semana(Dias, Franjas), _, _, _), S, Dia, Franja) :-
    (   integer(S)
    ->  S >= 0,
        S < Dias * Franjas,
        Dia is S // Franjas + 1,
        Franja is S mod Franjas + 1
    ;   between(1, Dias, Dia),
        between(1, Franjas, Franja),
        S is (Dia - 1) * Franjas + Franja - 1
    ).

%!  aula(+Oferta, ?Numero:integer, ?Nombre, ?Capacidad:integer) is nondet.
%
%   El aula Numero de Oferta se llama Nombre y tiene Capacidad lugares.
aula(oferta(_, _, Aulas, _), Numero, Nombre, Capacidad) :-
    nth1(Numero, Aulas, aula(Nombre, Capacidad)).

%!  disponible(+Oferta, ?Docente, ?Dia:integer) is nondet.
%
%   Docente puede dar clase el día Dia.
disponible(oferta(_, _, _, Docentes), Docente, Dia) :-
    member(disponible(Docente, Dias), Docentes),
    member(Dia, Dias).

%!  incompatibles(+Oferta, ?C1, ?C2) is nondet.
%
%   Las clases C1 y C2 de Oferta, con C1 antes que C2 en el orden estándar,
%   no pueden darse en el mismo momento: las dicta el mismo docente o son
%   de materias del mismo año, que un alumno que sigue el plan cursa
%   juntas. Una respuesta por par.
incompatibles(Oferta, C1, C2) :-
    clase(Oferta, C1, _, A1, D1, _),
    clase(Oferta, C2, _, A2, D2, _),
    C1 @< C2,
    once(( A1 == A2
         ; D1 == D2
         )).

% --- Verificar un horario -----------------------------------------------------

%!  horario_valido(+Oferta, +Horario:list) is semidet.
%
%   Horario cumple con Oferta: es un calendario válido del proyecto en que
%   cada clase es una tarea de duración 1 y cada aula un procesador; cada
%   clase cae dentro de la semana, en un aula donde cabe y un día en que su
%   docente está disponible; y no hay ningún choque.
horario_valido(Oferta, Horario) :-
    Oferta = oferta(_, _, Aulas, _),
    findall(tarea(C, 1), clase(Oferta, C, _, _, _, _), Tareas),
    length(Aulas, NA),
    tareas:valido(proyecto(Tareas, [], NA), Horario),
    momentos(Oferta, N),
    forall(member(asignada(C, A, S, _), Horario),
           ( S < N,
             clase(Oferta, C, _, _, Docente, Cupo),
             aula(Oferta, A, _, Capacidad),
             Cupo =< Capacidad,
             momento(Oferta, S, Dia, _),
             disponible(Oferta, Docente, Dia) )),
    \+ choque(Oferta, Horario, _).

%!  choque(+Oferta, +Horario:list, -Choque) is nondet.
%
%   Choque es una regla de Oferta que Horario no cumple entre dos clases:
%   mismo_momento(C1, C2), dos clases incompatibles en el mismo momento, o
%   mismo_dia(C1, C2), dos clases de la misma materia el mismo día.
choque(Oferta, Horario, mismo_momento(C1, C2)) :-
    incompatibles(Oferta, C1, C2),
    memberchk(asignada(C1, _, S, _), Horario),
    memberchk(asignada(C2, _, S, _), Horario).
choque(Oferta, Horario, mismo_dia(C1, C2)) :-
    member(asignada(C1, _, S1, _), Horario),
    member(asignada(C2, _, S2, _), Horario),
    C1 = M-_,
    C2 = M-_,
    C1 @< C2,
    momento(Oferta, S1, Dia, _),
    momento(Oferta, S2, Dia, _).

% --- Dibujar un horario -------------------------------------------------------

%!  lineas_anio(+Oferta, +Horario:list, +Anio:integer, -Lineas:list) is det.
%
%   Lineas son las líneas de texto de la grilla de las clases del año Anio:
%   una línea de encabezado con los días y una por franja, con la materia
%   y el aula de cada clase, o un guion si la franja está libre.
lineas_anio(Oferta, Horario, Anio, [Encabezado|Filas]) :-
    Oferta = oferta(semana(Dias, Franjas), _, _, _),
    numlist(1, Dias, Ds),
    maplist(nombre_dia, Ds, Nombres),
    maplist(columna, Nombres, Columnas),
    atomic_list_concat(['   '|Columnas], Encabezado0),
    recortar(Encabezado0, Encabezado),
    numlist(1, Franjas, Fs),
    maplist(fila(Oferta, Horario, Anio, Ds), Fs, Filas).

%!  fila(+Oferta, +Horario:list, +Anio:integer, +Dias:list, +Franja:integer,
%!       -Linea:string) is det.
%
%   Linea es la fila de la franja Franja en la grilla del año Anio.
fila(Oferta, Horario, Anio, Dias, Franja, Linea) :-
    maplist(celda(Oferta, Horario, Anio, Franja), Dias, Celdas),
    maplist(columna, Celdas, Columnas),
    atomic_list_concat(Columnas, Texto),
    format(string(Linea0), "F~w ~w", [Franja, Texto]),
    recortar(Linea0, Linea).

%!  recortar(+Texto, -Linea:string) is det.
%
%   Linea es Texto sin los blancos del final.
recortar(Texto, Linea) :-
    string_codes(Texto, Cs0),
    reverse(Cs0, Rs0),
    phrase(blancos, Rs0, Rs),
    reverse(Rs, Cs),
    string_codes(Linea, Cs).

%!  blancos// is det.
%
%   Consume los blancos del comienzo de la lista.
blancos -->
    [0' ],
    !,
    blancos.
blancos -->
    [].

%!  celda(+Oferta, +Horario:list, +Anio:integer, +Franja:integer,
%!        +Dia:integer, -Texto:atom) is det.
%
%   Texto es lo que muestra la grilla del año Anio en el día Dia y la
%   franja Franja: la materia y el aula de la clase de ese año, o un guion.
celda(Oferta, Horario, Anio, Franja, Dia, Texto) :-
    momento(Oferta, S, Dia, Franja),
    (   member(asignada(C, A, S, _), Horario),
        clase(Oferta, C, M, Anio, _, _)
    ->  aula(Oferta, A, Aula, _),
        format(atom(Texto), "~w/~w", [M, Aula])
    ;   Texto = '-'
    ).

%!  columna(+Texto, -Columna:atom) is det.
%
%   Columna es Texto completado con blancos hasta diez caracteres.
columna(Texto, Columna) :-
    format(atom(Columna), "~w~t~10|", [Texto]).

%!  nombre_dia(+Dia:integer, -Nombre:atom) is det.
%
%   Nombre es la abreviatura del día Dia de la semana.
nombre_dia(Dia, Nombre) :-
    nth1(Dia, [lun, mar, mie, jue, vie, sab], Nombre).

%!  mostrar_anio(+Oferta, +Horario:list, +Anio:integer) is det.
%
%   Escribe la grilla de las clases del año Anio.
mostrar_anio(Oferta, Horario, Anio) :-
    lineas_anio(Oferta, Horario, Anio, Lineas),
    forall(member(L, Lineas), format("~s~n", [L])).

% horario_ejemplo(H): un horario válido de la oferta cuatrimestre, escrito
% a mano para probar horario_valido/2 y el dibujo.
horario_ejemplo([ asignada(am1-1, 1, 0, 1), asignada(alg-1, 1, 1, 2),
                  asignada(log-1, 2, 5, 6), asignada(am1-2, 1, 4, 5),
                  asignada(alg-2, 1, 9, 10), asignada(am1-3, 1, 8, 9),
                  asignada(log-2, 2, 13, 14), asignada(am2-1, 2, 2, 3),
                  asignada(am2-2, 2, 6, 7), asignada(am2-3, 2, 10, 11),
                  asignada(pp-1, 2, 7, 8), asignada(pp-2, 2, 15, 16),
                  asignada(ssl-1, 3, 3, 4), asignada(ssl-2, 3, 11, 12),
                  asignada(bd-1, 3, 12, 13), asignada(bd-2, 3, 16, 17) ]).

%!  ver_ejemplo(+Anio:integer) is det.
%
%   Escribe la grilla del año Anio en el horario de ejemplo de la oferta
%   cuatrimestre.
ver_ejemplo(Anio) :-
    oferta(cuatrimestre, Oferta),
    horario_ejemplo(Horario),
    mostrar_anio(Oferta, Horario, Anio).
