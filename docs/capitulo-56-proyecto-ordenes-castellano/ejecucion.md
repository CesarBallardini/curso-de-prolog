# El plan sobre una carpeta real

Esta página contiene el desarrollo de la sección
[56.5](index.md#565-version-4-el-plan-sobre-una-carpeta-real) del
[capítulo 56](index.md): la versión 4 de las órdenes, `sistema.pl`, que lee
el modelo de una carpeta real y realiza el plan sobre ella. El archivo está
en `ejemplos/capitulo-56/`, con sus pruebas, y carga `plan.pl` y
`procesos.pl` del
[capítulo 28](../capitulo-28-programas-de-linea-de-comandos/index.md).

## El plan sobre una carpeta real

`sistema.pl` agrega los bordes con el disco. `leer_modelo/2` recorre la
carpeta de trabajo con los predicados de archivos del
[capítulo 27](../capitulo-27-archivos-streams-y-formatos/index.md#274-archivos-y-directorios)
y construye el modelo: `directory_files/2` da los nombres de cada carpeta,
`exists_directory/1` separa las subcarpetas, que se recorren a su vez, y
`size_file/2` y `time_file/2` dan el tamaño y la fecha de cada archivo, que
`format_time/3` escribe como `2026-09-20`:

<!-- ejemplo: capitulo-56/sistema.pl predicado: leer_modelo/2 entrada/3 -->
```prolog
%!  leer_modelo(+Raiz, -Modelo:list) is det.
%
%   Modelo son las carpetas y los archivos que hay debajo de la carpeta
%   Raiz, ordenados, con rutas relativas a Raiz. La fecha de un archivo es
%   la de su última modificación, en la zona horaria local.
leer_modelo(Raiz, Modelo) :-
    findall(E, entrada(Raiz, ".", E), Es),
    msort(Es, Modelo).

%!  entrada(+Raiz, +Rel:string, -E) is nondet.
%
%   E es una carpeta o un archivo que está debajo de la carpeta Rel.
entrada(Raiz, Rel, E) :-
    ruta_real(Raiz, Rel, Dir),
    directory_files(Dir, Nombres),
    member(N0, Nombres),
    \+ memberchk(N0, ['.', '..']),
    atom_string(N0, N),
    dentro(Rel, N, R),
    directory_file_path(Dir, N0, Abs),
    (   exists_directory(Abs)
    ->  (   E = carpeta(R)
        ;   entrada(Raiz, R, E)
        )
    ;   size_file(Abs, B),
        time_file(Abs, T),
        format_time(string(F), '%F', T),
        E = archivo(R, B, F)
    ).
```

`ejecutar_plan/6` realiza cada acción y devuelve un resultado por acción.
Las copias usan `copy_file/2`, de `library(filesex)`, y las mudanzas,
`rename_file/2`. Antes de borrar, pregunta; la respuesta es la línea que
devuelve `call(Leer, Linea)`, y así las pruebas le pasan una cadena y el
programa terminado, el teclado. `ejecutar/1` corre un programa Prolog en
otro proceso con `salida_de/4`, del
[capítulo 28](../capitulo-28-programas-de-linea-de-comandos/index.md#286-procesos-externos),
que usa `process_create/3`; la opción `-t halt` hace que `swipl` termine
aunque el programa no lo haga. En modo `simulacion`, ninguna acción
modifica el disco: cada una se devuelve descrita, `simulada(Accion)`. Es
la idea del ejercicio de Covington que muestra el comando antes de
ejecutarlo, llevada a no ejecutarlo. Cada cláusula del modo `real` corta
después de la cabeza: la acción ya eligió la cláusula, y como `realizar/6`
es `multifile` y otros archivos le agregan cláusulas, sin el corte quedaría
pendiente la alternativa de probarlas:

<!-- ejemplo: capitulo-56/sistema.pl predicado: realizar/6 -->
```prolog
%!  realizar(+Modo, +Raiz, +Leer, +Salida, +Accion, -Resultado) is det.
%
%   Resultado dice qué pasó al realizar Accion.
realizar(_, _, _, _, informar(Hecho), Hecho) :-
    !.
realizar(_, _, _, _, rechazo(Motivo), rechazo(Motivo)) :-
    !.
realizar(_, _, _, _, salir, salir) :-
    !.
realizar(simulacion, _, _, _, Accion, simulada(Accion)) :-
    !.
realizar(real, Raiz, _, _, copiar(R, D), copiado(R, D)) :-
    !,
    ruta_real(Raiz, R, De),
    ruta_real(Raiz, D, A),
    copy_file(De, A).
realizar(real, Raiz, _, _, mover(R, D), movido(R, D)) :-
    !,
    ruta_real(Raiz, R, De),
    ruta_real(Raiz, D, A),
    rename_file(De, A).
realizar(real, Raiz, Leer, Out, borrar(R), Resultado) :-
    !,
    ruta_real(Raiz, R, Abs),
    format(Out, "¿Quieres borrar ~s? (s/n) ", [R]),
    flush_output(Out),
    call(Leer, Respuesta),
    (   afirmativa(Respuesta)
    ->  delete_file(Abs),
        Resultado = borrado(R)
    ;   Resultado = conservado(R)
    ).
realizar(real, Raiz, _, _, ejecutar(R), salida(R, Estado, Lineas)) :-
    !,
    ruta_real(Raiz, R, Abs),
    salida_de(swipl, ['-t', halt, Abs], Texto, Estado),
    split_string(Texto, "\n", "\r", Lineas0),
    exclude(==(""), Lineas0, Lineas).
```

Las pruebas no pueden usar una carpeta fija: la ejecución la modifica, y
las fechas de los archivos dependerían del momento en que se copiaron.
`crear_muestra/2` hace lo inverso de `leer_modelo/2`: escribe un modelo en
una carpeta, con el tamaño exacto de cada archivo y su fecha fijada con
`set_time_file/3`. Cada prueba de `sistema.plt` crea una carpeta nueva con
`tmp_file/2` y `make_directory/1`, escribe en ella `modelo_ejemplo/1` y la
borra al terminar con `delete_directory_and_contents/1`. La primera prueba
comprueba que leer lo escrito devuelve exactamente el modelo de ejemplo:

```prolog
test(ida_y_vuelta, [ setup(muestra(D)),
                     cleanup(delete_directory_and_contents(D)) ]) :-
    leer_modelo(D, M),
    modelo_ejemplo(M).
```
