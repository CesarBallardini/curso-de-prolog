:- encoding(utf8).

% Capítulo 85 - La herencia de los marcos del capítulo 81, evaluada de
% abajo hacia arriba.
%
% Los marcos son los hechos valor/3 de marcos.pl del capítulo 81, cargado
% en el módulo marcos81 sin copiarlo, con las relaciones por las que se
% hereda cada ranura, hereda/2, y el año de las edades, anio_actual/1. Las
% reglas son las de la herencia escritas como un programa Datalog: un
% valor propio reemplaza al heredado, por medio de la negación de
% con_propio/2, y las partes se derivan en los dos sentidos, con las dos
% reglas de Rowe que se llaman una a la otra. Resueltas por Prolog, esas
% dos reglas no terminan; de abajo hacia arriba, el modelo es finito.
%
% solo-local: carga un archivo de otro capítulo.
%
%?- consulta_marcos(tiene_valor(bateria_de_juan_hoy, R, V), Rs, C).
%?- comparar_marcos(Iguales).

:- module(marcos,
          [ parte_de_rowe/2,
            tiene_parte_rowe/2,
            reglas_marcos/1,
            programa_marcos/1,
            consulta_marcos/3,
            componentes_marcos/1,
            comparar_marcos/1
          ]).

:- use_module(library(lists)).
:- use_module(library(apply)).
:- use_module(estratos).
:- reexport(estratos, [componentes/2]).
:- reexport(magia, [respuestas/4, respuestas_magicas/4]).

:- load_files(marcos81:'../capitulo-81/marcos', []).

%!  parte_de_rowe(?P, ?O) is nondet.
%
%   P es parte de O: lo dice el marco de P, o O tiene la parte P. Es la
%   regla de Rowe; con tiene_parte_rowe/2, cada una llama a la otra, y
%   Prolog no termina cuando el dato no está.
parte_de_rowe(P, O) :-
    marcos81:valor(P, parte_de, O).
parte_de_rowe(P, O) :-
    tiene_parte_rowe(O, P).

%!  tiene_parte_rowe(?O, ?P) is nondet.
%
%   O tiene la parte P: lo dice el marco de O, o P es parte de O.
tiene_parte_rowe(O, P) :-
    marcos81:valor(O, tiene_parte, P).
tiene_parte_rowe(O, P) :-
    parte_de_rowe(P, O).

%!  reglas_marcos(-Reglas:list) is det.
%
%   Las reglas de la herencia, en el orden en que el motor necesita las
%   variables ligadas.
reglas_marcos([
    (parte_de(P, O) :- valor(P, parte_de, O)),
    (parte_de(P, O) :- tiene_parte(O, P)),
    (tiene_parte(O, P) :- valor(O, tiene_parte, P)),
    (tiene_parte(O, P) :- parte_de(P, O)),
    (propio(O, R, V) :- valor(O, R, V)),
    (propio(O, tiene_parte, P) :- tiene_parte(O, P)),
    (propio(O, edad, E) :-
        valor(O, fabricado, A), anio_actual(Hoy), E is Hoy - A),
    (con_propio(O, R) :- propio(O, R, _)),
    (tiene_valor(O, R, V) :- propio(O, R, V)),
    (tiene_valor(O, R, V) :-
        hereda(R, Relacion), valor(O, Relacion, S), \+ con_propio(O, R),
        tiene_valor(S, R, V)),
    (tiene_valor(O, R, V) :-
        valor(O, intension, I), tiene_valor(I, R, V),
        \+ con_propio(O, R))
]).

%!  programa_marcos(-Clausulas:list) is det.
%
%   Clausulas son los hechos valor/3, hereda/2 y anio_actual/1 del
%   capítulo 81 y las reglas de reglas_marcos/1.
programa_marcos(Clausulas) :-
    findall((valor(O, R, V) :- true), marcos81:valor(O, R, V), Valores),
    findall((hereda(R, Rel) :- true), marcos81:hereda(R, Rel), Herencias),
    findall((anio_actual(A) :- true), marcos81:anio_actual(A), Anios),
    reglas_marcos(Reglas),
    append([Valores, Herencias, Anios, Reglas], Clausulas).

%!  consulta_marcos(+Meta, -Respuestas:list, -Costo) is det.
%
%   Respuestas son las instancias de Meta en el modelo de
%   programa_marcos/1, con respuestas/4; Costo, el de la evaluación.
consulta_marcos(Meta, Respuestas, Costo) :-
    programa_marcos(Clausulas),
    respuestas(Clausulas, Meta, Respuestas, Costo).

%!  componentes_marcos(-Componentes:list(list)) is det.
%
%   Componentes son las de programa_marcos/1, en orden de evaluación.
componentes_marcos(Componentes) :-
    programa_marcos(Clausulas),
    componentes(Clausulas, Componentes).

%!  comparar_marcos(-Iguales:boolean) is det.
%
%   Iguales es true si los valores que tiene_valor/3 del capítulo 81 da a
%   cada objeto en cada ranura heredable, más tiene_parte y edad, son los
%   mismos que tiene_valor/3 tiene en el modelo del programa, y false si
%   no.
comparar_marcos(Iguales) :-
    programa_marcos(Clausulas),
    evaluar(Clausulas, Modelo, _),
    findall(R, marcos81:hereda(R, _), Rs0),
    sort([edad, tiene_parte|Rs0], Rs),
    findall(O, ( marcos81:valor(O, _, _) ; marcos81:valor(_, _, O) ), Os0),
    sort(Os0, Os),
    findall(tiene_valor(O, R, V),
            ( member(O, Os),
              atom(O),
              member(R, Rs),
              marcos81:tiene_valor(O, R, V) ),
            Capitulo81),
    sort(Capitulo81, Esperado),
    findall(tiene_valor(O, R, V),
            ( member(tiene_valor(O, R, V), Modelo),
              memberchk(R, Rs) ),
            Motor),
    sort(Motor, Obtenido),
    (   Esperado == Obtenido
    ->  Iguales = true
    ;   Iguales = false
    ).
