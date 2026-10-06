:- encoding(utf8).

% Capítulo 83 - El filtro de marcas, versión 2: las marcas mal cerradas.
%
% El mismo filtro de cribar.pl, con el número de cada línea en el
% recorrido. Una marca de inicio que no se cierra, una marca de fin sin
% inicio y una marca de inicio dentro de una sección ya abierta son
% errores, que nombran la línea en que se produjeron, en lugar de quitar o
% copiar texto sin aviso. El estado salteando recuerda la línea en que
% empezó la sección.
%
%?- cribar(["a", "INICIO", "b", "FIN", "c"], "INICIO", "FIN", Quedan).
%?- catch(cribar(["a", "INICIO", "b"], "INICIO", "FIN", Q), error(E, _), true).

:- module(cribar_seguro,
          [ cribar/4,
            paso/7,
            final/1
          ]).

:- multifile prolog:message//1.

%!  cribar(+Lineas:list(string), +Inicio:string, +Fin:string,
%!         -Quedan:list(string)) is det.
%
%   Quedan son las líneas de Lineas fuera de las secciones que abre una
%   línea que empieza con Inicio y cierra la siguiente que empieza con Fin.
%   Lanza error(marcas(Problema), _) si las marcas no forman pares; ver
%   paso/7 y final/1.
cribar(Lineas, Inicio, Fin, Quedan) :-
    cribar(Lineas, 1, copiando, Inicio, Fin, Quedan).

%!  cribar(+Lineas:list(string), +N:integer, +Estado, +Inicio:string,
%!         +Fin:string, -Quedan:list(string)) is det.
%
%   Como cribar/4, con la primera línea de Lineas numerada N y el
%   recorrido en Estado.
cribar([], _, Estado, _, _, []) :-
    final(Estado).
cribar([Linea|Lineas], N, Estado, Inicio, Fin, Quedan) :-
    paso(Estado, N, Linea, Inicio, Fin, Estado1, Salida),
    append(Salida, Resto, Quedan),
    N1 is N + 1,
    cribar(Lineas, N1, Estado1, Inicio, Fin, Resto).

%!  paso(+Estado, +N:integer, +Linea:string, +Inicio:string, +Fin:string,
%!       -Estado1, -Salida:list(string)) is det.
%
%   Leída la línea N, Linea, en Estado, el recorrido pasa a Estado1 y
%   escribe Salida, la lista con Linea o la lista vacía. Los estados son
%   copiando y salteando(N0), con N0 la línea de la marca de inicio. Lanza
%   error(marcas(fin_sin_inicio(N)), _) con una marca de fin fuera de una
%   sección, y error(marcas(inicio_anidado(N, N0)), _) con una marca de
%   inicio dentro de la sección abierta en la línea N0. Si las dos marcas
%   son iguales, dentro de una sección la línea se toma como fin.
paso(copiando, N, Linea, Inicio, Fin, Estado1, Salida) :-
    (   empieza(Linea, Inicio)
    ->  Estado1 = salteando(N),
        Salida = []
    ;   empieza(Linea, Fin)
    ->  throw(error(marcas(fin_sin_inicio(N)), _))
    ;   Estado1 = copiando,
        Salida = [Linea]
    ).
paso(salteando(N0), N, Linea, Inicio, Fin, Estado1, []) :-
    (   empieza(Linea, Fin)
    ->  Estado1 = copiando
    ;   empieza(Linea, Inicio)
    ->  throw(error(marcas(inicio_anidado(N, N0)), _))
    ;   Estado1 = salteando(N0)
    ).

%!  final(+Estado) is det.
%
%   El texto puede terminar en Estado. Lanza
%   error(marcas(inicio_sin_fin(N0)), _) si termina dentro de la sección
%   abierta en la línea N0.
final(copiando).
final(salteando(N0)) :-
    throw(error(marcas(inicio_sin_fin(N0)), _)).

%!  empieza(+Linea:string, +Marca:string) is semidet.
%
%   Linea empieza con Marca.
empieza(Linea, Marca) :-
    string_concat(Marca, _, Linea).

%!  prolog:message(+Mensaje)// is semidet.
%
%   El texto de los errores de las marcas.
prolog:message(error(marcas(Problema), _)) -->
    problema(Problema).

%!  problema(+Problema)// is det.
%
%   El texto de un problema con las marcas.
problema(fin_sin_inicio(N)) -->
    [ 'línea ~d: marca de fin sin marca de inicio'-[N] ].
problema(inicio_anidado(N, N0)) -->
    [ 'línea ~d: marca de inicio dentro de la sección abierta'-[N],
      ' en la línea ~d'-[N0] ].
problema(inicio_sin_fin(N0)) -->
    [ 'línea ~d: la sección que empieza aquí no tiene marca de fin'-[N0] ].
