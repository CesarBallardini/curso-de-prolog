:- encoding(utf8).

% Capítulo 83 - Soluciones de los ejercicios.
%
% Carga cribar.pl (la versión 1 del filtro), paso/7 y final/1 de
% cribar_seguro.pl, y curvas_programa.pl, que carga curvas.pl y cicloide.pl;
% ninguno se modifica. La versión 2 del filtro se llama como
% cribar_seguro:cribar/4, porque cribar/4 es también la versión 1. Las
% clases de curva nuevas se agregan como cláusulas de curvas:punto/3.
%
% solo-local: carga otros archivos.
%
%?- conservar(["a", "INICIO", "b", "FIN", "c"], "INICIO", "FIN", Q).
%?- secciones(["a", "INICIO", "b", "FIN", "c"], "INICIO", "FIN", R).

:- ensure_loaded(cribar).
:- use_module(cribar_seguro, [paso/7, final/1]).
:- ensure_loaded(curvas_programa).
:- use_module(cicloide, [decimal//1, codigos//1]).

% --- Ejercicio 2 ------------------------------------------------------------

%!  conservar(+Lineas:list(string), +Inicio:string, +Fin:string,
%!            -Quedan:list(string)) is det.
%
%   Quedan son las líneas de Lineas que están dentro de las secciones, sin
%   las marcas. Lanza los errores de paso/7 y final/1.
conservar(Lineas, Inicio, Fin, Quedan) :-
    conservar(Lineas, 1, copiando, Inicio, Fin, Quedan).

%!  conservar(+Lineas:list(string), +N:integer, +Estado, +Inicio:string,
%!            +Fin:string, -Quedan:list(string)) is det.
%
%   Como conservar/4, con la primera línea numerada N y el recorrido en
%   Estado. Una línea queda si el recorrido está salteando antes y después
%   de su paso: las marcas cambian el estado, y las líneas de afuera no
%   están salteando.
conservar([], _, Estado, _, _, []) :-
    final(Estado).
conservar([Linea|Lineas], N, Estado, Inicio, Fin, Quedan) :-
    paso(Estado, N, Linea, Inicio, Fin, Estado1, _),
    (   Estado = salteando(_),
        Estado1 = salteando(_)
    ->  Quedan = [Linea|Resto]
    ;   Quedan = Resto
    ),
    N1 is N + 1,
    conservar(Lineas, N1, Estado1, Inicio, Fin, Resto).

% --- Ejercicio 3 ------------------------------------------------------------

%!  cribar_sangria(+Lineas:list(string), +Inicio:string, +Fin:string,
%!                 -Quedan:list(string)) is det.
%
%   Como cribar/4 de la versión 2, con las marcas reconocidas también
%   después de espacios y tabulaciones. Las líneas que quedan no cambian.
cribar_sangria(Lineas, Inicio, Fin, Quedan) :-
    cribar_sangria(Lineas, 1, copiando, Inicio, Fin, Quedan).

%!  cribar_sangria(+Lineas:list(string), +N:integer, +Estado,
%!                 +Inicio:string, +Fin:string,
%!                 -Quedan:list(string)) is det.
%
%   Como cribar_sangria/4, desde la línea N en Estado. El paso decide sobre
%   la línea sin la sangría, y se escribe la línea original.
cribar_sangria([], _, Estado, _, _, []) :-
    final(Estado).
cribar_sangria([Linea|Lineas], N, Estado, Inicio, Fin, Quedan) :-
    sin_sangria(Linea, Recortada),
    paso(Estado, N, Recortada, Inicio, Fin, Estado1, Salida),
    (   Salida == []
    ->  Quedan = Resto
    ;   Quedan = [Linea|Resto]
    ),
    N1 is N + 1,
    cribar_sangria(Lineas, N1, Estado1, Inicio, Fin, Resto).

%!  sin_sangria(+Linea:string, -Recortada:string) is det.
%
%   Recortada es Linea sin los espacios y las tabulaciones del principio.
sin_sangria(Linea, Recortada) :-
    string_codes(Linea, Codigos),
    sin_blancos(Codigos, Resto),
    string_codes(Recortada, Resto).

%!  sin_blancos(+Codigos:list, -Resto:list) is det.
%
%   Resto es Codigos sin los espacios y las tabulaciones del principio.
sin_blancos([C|Cs], Resto) :-
    memberchk(C, [0' , 0'\t]),
    !,
    sin_blancos(Cs, Resto).
sin_blancos(Codigos, Codigos).

% --- Ejercicio 4 ------------------------------------------------------------

%!  secciones(+Lineas:list(string), +Inicio:string, +Fin:string,
%!            -Rangos:list(pair)) is det.
%
%   Rangos son los pares Desde-Hasta, las líneas de la marca de inicio y de
%   la de fin de cada sección de Lineas, en orden. Lanza los errores de
%   paso/7 y final/1.
secciones(Lineas, Inicio, Fin, Rangos) :-
    secciones(Lineas, 1, copiando, Inicio, Fin, Rangos).

%!  secciones(+Lineas:list(string), +N:integer, +Estado, +Inicio:string,
%!            +Fin:string, -Rangos:list(pair)) is det.
%
%   Como secciones/4, desde la línea N en Estado. Una sección termina en
%   el paso que va de salteando(N0) a copiando.
secciones([], _, Estado, _, _, []) :-
    final(Estado).
secciones([Linea|Lineas], N, Estado, Inicio, Fin, Rangos) :-
    paso(Estado, N, Linea, Inicio, Fin, Estado1, _),
    (   Estado = salteando(N0),
        Estado1 == copiando
    ->  Rangos = [N0-N|Resto]
    ;   Rangos = Resto
    ),
    N1 is N + 1,
    secciones(Lineas, N1, Estado1, Inicio, Fin, Resto).

%!  secciones_archivo(+Archivo, +Inicio:string, +Fin:string,
%!                    -Rangos:list(pair)) is det.
%
%   Rangos son las secciones del archivo Archivo, del directorio de este
%   programa.
secciones_archivo(Archivo, Inicio, Fin, Rangos) :-
    source_file(user:secciones(_, _, _, _), Programa),
    file_directory_name(Programa, Directorio),
    directory_file_path(Directorio, Archivo, Ruta),
    read_file_to_string(Ruta, Texto, [encoding(utf8)]),
    split_string(Texto, "\n", "\r", Partes),
    (   append(Lineas, [""], Partes)
    ->  true
    ;   Lineas = Partes
    ),
    secciones(Lineas, Inicio, Fin, Rangos).

% --- Ejercicio 5 ------------------------------------------------------------

%!  cribar_pares(+Lineas:list(string), +Pares:list(pair),
%!               -Quedan:list(string)) is det.
%
%   Quedan son las líneas de Lineas fuera de las secciones de cualquiera de
%   los pares Inicio-Fin de Pares. Lanza los errores de la versión 2:
%   error(marcas(Problema), _), con los mismos problemas.
cribar_pares(Lineas, Pares, Quedan) :-
    cribar_pares(Lineas, 1, copiando, Pares, Quedan).

%!  cribar_pares(+Lineas:list(string), +N:integer, +Estado,
%!               +Pares:list(pair), -Quedan:list(string)) is det.
%
%   Como cribar_pares/3, desde la línea N en Estado: copiando, o
%   salteando(Fin, N0), con Fin la marca que cierra la sección abierta en
%   la línea N0.
cribar_pares([], _, Estado, _, []) :-
    final_par(Estado).
cribar_pares([Linea|Lineas], N, Estado, Pares, Quedan) :-
    paso_par(Estado, N, Linea, Pares, Estado1, Salida),
    append(Salida, Resto, Quedan),
    N1 is N + 1,
    cribar_pares(Lineas, N1, Estado1, Pares, Resto).

%!  paso_par(+Estado, +N:integer, +Linea:string, +Pares:list(pair),
%!           -Estado1, -Salida:list(string)) is det.
%
%   El paso de cribar_pares/5: como paso/7, con la marca de fin de la
%   sección abierta en el estado. Dentro de una sección, la marca de fin
%   de otro par es una marca de fin sin su inicio.
paso_par(copiando, N, Linea, Pares, Estado1, Salida) :-
    (   member(Inicio-Fin, Pares),
        string_concat(Inicio, _, Linea)
    ->  Estado1 = salteando(Fin, N),
        Salida = []
    ;   member(_-Fin, Pares),
        string_concat(Fin, _, Linea)
    ->  throw(error(marcas(fin_sin_inicio(N)), _))
    ;   Estado1 = copiando,
        Salida = [Linea]
    ).
paso_par(salteando(Fin, N0), N, Linea, Pares, Estado1, []) :-
    (   string_concat(Fin, _, Linea)
    ->  Estado1 = copiando
    ;   member(Inicio-_, Pares),
        string_concat(Inicio, _, Linea)
    ->  throw(error(marcas(inicio_anidado(N, N0)), _))
    ;   member(_-Otro, Pares),
        string_concat(Otro, _, Linea)
    ->  throw(error(marcas(fin_sin_inicio(N)), _))
    ;   Estado1 = salteando(Fin, N0)
    ).

%!  final_par(+Estado) is det.
%
%   El texto puede terminar en Estado; si no, lanza el error de final/1.
final_par(copiando).
final_par(salteando(_, N0)) :-
    final(salteando(N0)).

% --- Ejercicios 7 y 8 -------------------------------------------------------

:- multifile curvas:punto/3.

% La curva de Lissajous: x = sin(A t + Delta), y = sin(B t).
curvas:punto(lissajous(A, B, Delta), T, X-Y) :-
    X is sin(A * T + Delta),
    Y is sin(B * T).

% La hipocicloide de un disco de radio Rd que rueda por dentro de una
% circunferencia de radio R, con el punto a distancia D de su centro.
curvas:punto(hipocicloide(R, Rd, D), T, X-Y) :-
    K is (R - Rd) / Rd,
    X is (R - Rd) * cos(T) + D * cos(K * T),
    Y is (R - Rd) * sin(T) - D * sin(K * T).

%!  dibujar(+Entrada, +Salida) is det.
%
%   Escribe en Salida el dibujo SVG de las especificaciones de Entrada,
%   con las clases de curva de este archivo; los dos nombres son relativos
%   al directorio de este programa.
dibujar(Entrada, Salida) :-
    source_file(user:dibujar(_, _), Programa),
    file_directory_name(Programa, Directorio),
    directory_file_path(Directorio, Entrada, RutaEntrada),
    directory_file_path(Directorio, Salida, RutaSalida),
    curvas(RutaEntrada, svg, Texto),
    setup_call_cleanup(open(RutaSalida, write, Out, [encoding(utf8)]),
                       write(Out, Texto),
                       close(Out)).

% --- Ejercicio 10 -----------------------------------------------------------

%!  datos(+Partes:list, -Texto:string) is det.
%
%   Texto es Partes en el formato de datos de los programas de gráficos:
%   una línea X Y por punto, una línea vacía entre dos curvas, y cada
%   comentario en una línea que empieza con #.
datos(Partes, Texto) :-
    phrase(datos(Partes, primera), Codigos),
    string_codes(Texto, Codigos).

%!  datos(+Partes:list, +Antes)// is det.
%
%   Las líneas de Partes; Antes es primera hasta la primera curva, y
%   despues desde ella, para separar cada curva de la anterior.
datos([], _) -->
    [].
datos([Parte|Partes], Antes) -->
    dato(Parte, Antes, Despues),
    datos(Partes, Despues).

%!  dato(+Parte, +Antes, -Despues)// is det.
%
%   Las líneas de una parte.
dato(comentario(Texto), Antes, Antes) -->
    { string_codes(Texto, Codigos) },
    "# ", codigos(Codigos), "\n".
dato(curva(_, Puntos), Antes, despues) -->
    (   { Antes == despues }
    ->  "\n"
    ;   []
    ),
    lineas_xy(Puntos).

%!  lineas_xy(+Puntos:list(pair))// is det.
%
%   Una línea X Y por punto, con cuatro decimales.
lineas_xy([]) -->
    [].
lineas_xy([X-Y|Ps]) -->
    decimal(X), " ", decimal(Y), "\n",
    lineas_xy(Ps).
