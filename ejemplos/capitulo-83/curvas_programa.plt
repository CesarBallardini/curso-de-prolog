:- encoding(utf8).

% Pruebas de curvas_programa.pl: la lectura y la verificación de las
% especificaciones, y el programa completo ejecutado en otro proceso.

:- use_module(library(process)).
:- use_module(library(readutil)).

:- begin_tests(curvas_programa).

%!  aqui(+Relativo, -Ruta) is det.
%
%   Ruta es Relativo tomado desde el directorio de curvas_programa.pl.
aqui(Relativo, Ruta) :-
    source_file(user:leer_especificaciones(_, _), Programa),
    file_directory_name(Programa, Directorio),
    directory_file_path(Directorio, Relativo, Ruta).

%!  correr(+Argumentos:list, -Errores:string, -Estado) is det.
%
%   Ejecuta curvas_programa.pl con Argumentos en otro proceso, desde su
%   directorio. Errores es lo que escribe en la salida de errores; Estado,
%   exit(Codigo).
correr(Argumentos, Errores, Estado) :-
    aqui('curvas_programa.pl', Programa),
    file_directory_name(Programa, Directorio),
    process_create(path(swipl), [Programa|Argumentos],
                   [ cwd(Directorio), stdout(null), stderr(pipe(Err)),
                     process(Pid) ]),
    set_stream(Err, encoding(utf8)),
    read_string(Err, _, Errores),
    close(Err),
    process_wait(Pid, Estado).

%!  error_de(+Archivo, -Error) is det.
%
%   Error es el error que lanza leer_especificaciones/2 con Archivo, del
%   directorio archivos.
error_de(Archivo, Error) :-
    directory_file_path(archivos, Archivo, Relativo),
    aqui(Relativo, Ruta),
    catch(( leer_especificaciones(Ruta, _), Error = ninguno ),
          error(Error, _),
          true).

% --- Las especificaciones --------------------------------------------------

test(especificacion, true(Ps == [1.0-0.0, -1.0-0.0, 1.0-0.0])) :-
    especificacion(curva(c, circulo(0, 0, 1), 0, 2*pi, 2), 1, curva(c, Ps0)),
    maplist(redondear, Ps0, Ps).

%!  redondear(+P:pair, -Q:pair) is det.
%
%   Q es P con cada coordenada redondeada a seis decimales.
redondear(X-Y, X1-Y1) :-
    X1 is round(X * 1.0e6) / 1.0e6,
    Y1 is round(Y * 1.0e6) / 1.0e6.

test(no_es_curva, error(especificacion(3, termino(delete_file(x))))) :-
    especificacion(delete_file(x), 3, _).

test(nombre_con_digitos, error(especificacion(1, nombre(c1)))) :-
    especificacion(curva(c1, circulo(0, 0, 1), 0, 1, 2), 1, _).

test(nombre_con_acento, error(especificacion(1, nombre('cícloide')))) :-
    especificacion(curva('cícloide', circulo(0, 0, 1), 0, 1, 2), 1, _).

test(curva_desconocida, error(especificacion(1, curva(parabola(1))))) :-
    especificacion(curva(p, parabola(1), 0, 1, 2), 1, _).

test(extremo_con_variable, error(especificacion(1, extremo(_)))) :-
    especificacion(curva(c, circulo(0, 0, 1), 0, _, 2), 1, _).

test(extremo_no_aritmetico, error(especificacion(1, extremo(dos*pi)))) :-
    especificacion(curva(c, circulo(0, 0, 1), 0, dos*pi, 2), 1, _).

test(intervalos, error(especificacion(1, intervalos(2.5)))) :-
    especificacion(curva(c, circulo(0, 0, 1), 0, 1, 2.5), 1, _).

test(comentarios, true(Ps == [comentario("uno"), comentario("dos"), fin])) :-
    comentarios([p1-"% uno\n%dos", p2-"/* bloque */"], Ps, [fin]).

test(leer, true(Nombres == [comun, acortada, alargada])) :-
    aqui('archivos/cicloides.curvas', Ruta),
    leer_especificaciones(Ruta, Partes),
    findall(N, member(curva(N, _), Partes), Nombres).

test(leer_comentarios, true(C == 4)) :-
    aqui('archivos/cicloides.curvas', Ruta),
    leer_especificaciones(Ruta, Partes),
    aggregate_all(count, member(comentario(_), Partes), C).

test(peligro, true(E == especificacion(3, termino(delete_file('examen.tex'))))) :-
    error_de('peligro.curvas', E).

test(repetida, true(E == especificacion(3, nombre_repetido(espiral)))) :-
    error_de('repetida.curvas', E).

test(formato_por_extension, true(F-G-H == svg-tikz-epic)) :-
    formato([], 'a.svg', F),
    formato([], 'a.tex', G),
    formato([formato(epic)], 'a.svg', H).

% La figura de las cicloides del capítulo es la salida del programa.
test(figura_del_capitulo, true(Texto == Figura)) :-
    aqui('archivos/cicloides.curvas', Ruta),
    curvas(Ruta, svg, Texto),
    aqui('../../docs/capitulo-83-proyecto-procesamiento-textos/cicloides.svg',
         Svg),
    read_file_to_string(Svg, Figura, [encoding(utf8)]).

% --- El programa -----------------------------------------------------------

test(programa_tikz, true(E-Lineas == exit(0)-5)) :-
    tmp_file(curvas, Salida),
    correr(['archivos/espirales.curvas', Salida], _, E),
    read_file_to_string(Salida, Texto, [encoding(utf8)]),
    delete_file(Salida),
    split_string(Texto, "\n", "", Todas),
    length(Todas, Lineas).

test(programa_peligro, true(E == exit(2))) :-
    tmp_file(curvas, Salida),
    correr(['archivos/peligro.curvas', Salida], Errores, E),
    once(sub_string(Errores, _, _, _, "línea 3: delete_file('examen.tex') no es")),
    \+ exists_file(Salida).

test(programa_sin_salida, true(E == exit(1))) :-
    correr(['archivos/espirales.curvas'], Errores, E),
    once(sub_string(Errores, _, _, _, "Hacen falta dos archivos")).

test(programa_formato_desconocido, true(E == exit(1))) :-
    correr(['-t', 'pdf', 'archivos/espirales.curvas', 'x.pdf'], _, E).

:- end_tests(curvas_programa).
