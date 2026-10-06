:- encoding(utf8).

% Capítulo 83 - El filtro de marcas, versión 1: el estado como argumento.
%
% Un texto es una lista de líneas, cadenas sin el salto de línea final. El
% filtro quita todas las líneas que van desde una línea que empieza con la
% marca de inicio hasta la siguiente que empieza con la marca de fin, las dos
% marcas incluidas, y conserva el resto. Recorre las líneas en uno de dos
% estados, copiando o salteando, y la relación paso/6 dice, para cada
% estado y cada línea, el estado siguiente y lo que se escribe.
%
%?- cribar(["a", "INICIO", "b", "FIN", "c"], "INICIO", "FIN", Quedan).
%?- paso(copiando, "INICIO x", "INICIO", "FIN", Estado, Salida).

%!  cribar(+Lineas:list(string), +Inicio:string, +Fin:string,
%!         -Quedan:list(string)) is det.
%
%   Quedan son las líneas de Lineas que no están entre una línea que
%   empieza con Inicio y la siguiente que empieza con Fin; las dos líneas
%   de las marcas también se quitan.
cribar(Lineas, Inicio, Fin, Quedan) :-
    cribar(Lineas, copiando, Inicio, Fin, Quedan).

%!  cribar(+Lineas:list(string), +Estado, +Inicio:string, +Fin:string,
%!         -Quedan:list(string)) is det.
%
%   Como cribar/4, con el recorrido en Estado al llegar a la primera línea.
cribar([], _, _, _, []).
cribar([Linea|Lineas], Estado, Inicio, Fin, Quedan) :-
    paso(Estado, Linea, Inicio, Fin, Estado1, Salida),
    append(Salida, Resto, Quedan),
    cribar(Lineas, Estado1, Inicio, Fin, Resto).

%!  paso(+Estado, +Linea:string, +Inicio:string, +Fin:string,
%!       -Estado1, -Salida:list(string)) is det.
%
%   Leída Linea en Estado, el recorrido pasa a Estado1 y escribe Salida:
%   la lista con Linea, o la lista vacía. Los estados son copiando y
%   salteando.
paso(copiando, Linea, Inicio, _, Estado1, Salida) :-
    (   empieza(Linea, Inicio)
    ->  Estado1 = salteando,
        Salida = []
    ;   Estado1 = copiando,
        Salida = [Linea]
    ).
paso(salteando, Linea, _, Fin, Estado1, []) :-
    (   empieza(Linea, Fin)
    ->  Estado1 = copiando
    ;   Estado1 = salteando
    ).

%!  empieza(+Linea:string, +Marca:string) is semidet.
%
%   Linea empieza con Marca.
empieza(Linea, Marca) :-
    string_concat(Marca, _, Linea).
