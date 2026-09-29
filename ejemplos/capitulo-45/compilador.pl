:- encoding(utf8).

% Capítulo 45 - El compilador de Mini terminado.
%
% Carga las seis versiones del capítulo: el análisis (sintaxis.pl), el
% intérprete (interprete.pl), la generación de código y el ensamblador
% (generador.pl), la máquina de pila (maquina.pl), las optimizaciones
% (optimizador.pl) y el intérprete especializado (especializar.pl). mini/1
% compila un programa con todas las optimizaciones, escribe el código
% objeto y lo ejecuta; mini_ejemplo/1 hace lo mismo con un programa de
% ejemplo, después de escribir su texto.
%
% solo-local: carga los archivos de las versiones con ensure_loaded/1.
%
%?- mini("x := 6; escribir x * 7").
%?- mini_ejemplo(factorial).

:- ensure_loaded(optimizador).
:- ensure_loaded(especializar).

%!  mini(+Texto) is semidet.
%
%   Compila el programa Mini de Texto con compilar_optimizado/2, escribe
%   el código objeto, una instrucción por línea con su dirección, y
%   después lo que escribe el programa al ejecutarse en la máquina. Falla
%   si Texto no es un programa Mini.
mini(Texto) :-
    compilar_optimizado(Texto, Objeto),
    listar_codigo(Objeto, 0),
    maquina(Objeto, Salida),
    format("salida: ~w~n", [Salida]).

%!  mini_ejemplo(+Nombre) is semidet.
%
%   Escribe el texto del programa de ejemplo Nombre, y después hace con él
%   lo que mini/1.
mini_ejemplo(Nombre) :-
    fuente(Nombre, Lineas),
    forall(member(L, Lineas), format("    ~s~n", [L])),
    atomic_list_concat(Lineas, '\n', Texto),
    mini(Texto).
