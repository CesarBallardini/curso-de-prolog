:- encoding(utf8).

% Capítulo 60 - Versión 2: la memoria como argumento.
%
% La memoria de trabajo es una lista de hechos, del más reciente al más
% antiguo, que el ciclo recibe y devuelve. Nada queda en la base de datos:
% ejecutar/4 es una relación entre la memoria inicial, la final y el
% resultado, y ejecucion/4 elige el módulo por retroceso, de modo que
% enumera todas las ejecuciones posibles del programa.
%
% solo-local: carga programas.pl con ensure_loaded/1, y SWISH no permite
% cargar archivos.
%
%?- ejecutar(mcd, [numero(25), numero(10), numero(15), numero(30)], M, R).
%?- posiciones([3, 1, 2], H), ejecucion(ordenar, H, M, R).

:- ensure_loaded(programas).

%!  ejecutar(+Programa, +Memoria0:list, -Memoria:list, -Resultado) is semidet.
%
%   Ejecuta el Programa desde Memoria0 aplicando en cada ciclo el primer
%   módulo que se puede aplicar. Memoria es la memoria al terminar, y
%   Resultado el término de parar/1, o nada_aplicable. Falla si falla una
%   acción del módulo elegido: quitar/1 o reemplazar/2 sin el hecho, o
%   una prueba {Meta} que no se cumple.
ejecutar(Programa, Memoria0, Memoria, Resultado) :-
    programa(Programa, Modulos),
    ciclo(Modulos, Memoria0, Memoria, Resultado).

%!  ciclo(+Modulos:list, +Memoria0:list, -Memoria:list, -Resultado) is semidet.
%
%   Aplica el primer módulo de Modulos que se puede aplicar a Memoria0, y
%   repite con la memoria que resulta. Falla si falla una acción del
%   módulo elegido.
ciclo(Modulos, Memoria0, Memoria, Resultado) :-
    (   member(Modulo, Modulos),
        copy_term(Modulo, _ :: Condiciones ---> Acciones),
        satisface(Condiciones, Memoria0, _)
    ->  acciones(Acciones, Memoria0, Memoria1, Fin),
        seguir(Fin, Modulos, Memoria1, Memoria, Resultado)
    ;   Memoria = Memoria0,
        Resultado = nada_aplicable
    ).

%!  seguir(+Fin, +Modulos:list, +Memoria0:list, -Memoria:list, -Resultado)
%!      is semidet.
%
%   Termina con el resultado R si Fin es parar(R), o sigue el ciclo si Fin
%   es seguir. Falla si falla el ciclo que sigue.
seguir(parar(R), _, Memoria, Memoria, R).
seguir(seguir, Modulos, Memoria0, Memoria, Resultado) :-
    ciclo(Modulos, Memoria0, Memoria, Resultado).

%!  ejecucion(+Programa, +Memoria0:list, -Memoria:list, -Resultado)
%!      is nondet.
%
%   Como ejecutar/4, pero cada ciclo aplica cualquier módulo que se pueda
%   aplicar, con cualquiera de los hechos que cumplen sus condiciones: el
%   retroceso da una respuesta por cada ejecución posible.
ejecucion(Programa, Memoria0, Memoria, Resultado) :-
    programa(Programa, Modulos),
    ciclo_libre(Modulos, Memoria0, Memoria, Resultado).

%!  ciclo_libre(+Modulos:list, +Memoria0:list, -Memoria:list, -Resultado)
%!      is nondet.
%
%   Aplica a Memoria0 uno cualquiera de los módulos aplicables, y repite.
ciclo_libre(Modulos, Memoria0, Memoria, Resultado) :-
    (   aplicable(Modulos, Memoria0)
    ->  member(Modulo, Modulos),
        copy_term(Modulo, _ :: Condiciones ---> Acciones),
        satisface(Condiciones, Memoria0, _),
        acciones(Acciones, Memoria0, Memoria1, Fin),
        (   Fin = parar(R)
        ->  Memoria = Memoria1,
            Resultado = R
        ;   ciclo_libre(Modulos, Memoria1, Memoria, Resultado)
        )
    ;   Memoria = Memoria0,
        Resultado = nada_aplicable
    ).

%!  aplicable(+Modulos:list, +Memoria:list) is semidet.
%
%   Algún módulo de Modulos se puede aplicar a Memoria.
aplicable(Modulos, Memoria) :-
    member(Modulo, Modulos),
    copy_term(Modulo, _ :: Condiciones ---> _),
    satisface(Condiciones, Memoria, _),
    !.

%!  satisface(+Condiciones:list, +Memoria:list, -Posiciones:list(integer))
%!      is nondet.
%
%   Memoria cumple todas las Condiciones. Posiciones son las posiciones en
%   Memoria, contadas desde 0, de los hechos que cumplen los patrones, en el
%   orden de las condiciones.
satisface([], _, []).
satisface([C|Cs], Memoria, Posiciones) :-
    condicion(C, Memoria, Posiciones, Resto),
    satisface(Cs, Memoria, Resto).

%!  condicion(+Condicion, +Memoria:list, -Posiciones:list, ?Resto:list)
%!      is nondet.
%
%   Memoria cumple Condicion. Posiciones es Resto precedida por la posición
%   del hecho que cumple un patrón; una prueba y una negación no agregan
%   ninguna.
condicion({Meta}, _, Resto, Resto) :-
    call(Meta).
condicion(no(F), Memoria, Resto, Resto) :-
    \+ memberchk(F, Memoria).
condicion(F, Memoria, [I|Resto], Resto) :-
    patron(F),
    nth0(I, Memoria, F).

%!  acciones(+Acciones:list, +Memoria0:list, -Memoria:list, -Fin)
%!      is semidet.
%
%   Ejecuta las Acciones en orden sobre Memoria0. Fin es parar(R) si una
%   de ellas es parar(R), que deja sin ejecutar las siguientes, o seguir.
%   Falla si falla una acción.
acciones([], Memoria, Memoria, seguir).
acciones([A|As], Memoria0, Memoria, Fin) :-
    (   A = parar(R)
    ->  Memoria = Memoria0,
        Fin = parar(R)
    ;   accion(A, Memoria0, Memoria1),
        acciones(As, Memoria1, Memoria, Fin)
    ).

%!  accion(+Accion, +Memoria0:list, -Memoria:list) is semidet.
%
%   Memoria es Memoria0 después de una acción que no es parar/1. Un hecho
%   agregado va al principio, como el más reciente; quitar un hecho quita
%   la primera aparición que unifica con él. Falla si quitar/1 o
%   reemplazar/2 no encuentran el hecho, o si la prueba de {Meta} falla.
accion({Meta}, Memoria, Memoria) :-
    once(Meta).
accion(agregar(F), Memoria, [F|Memoria]).
accion(quitar(F), Memoria0, Memoria) :-
    selectchk(F, Memoria0, Memoria).
accion(reemplazar(F, G), Memoria0, [G|Memoria]) :-
    selectchk(F, Memoria0, Memoria).
