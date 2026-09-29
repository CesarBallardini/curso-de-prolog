:- encoding(utf8).

% Capítulo 61 - La máquina de Prolog terminada.
%
% Carga las seis versiones, cada una en su módulo, sin importar nada de
% ellas: resolver/3 elige la versión por su nombre (resolvente,
% alternativas, almacen, corte, indice o compilado). ejecutar_archivo/2 lee un
% archivo de Prolog con el lector del capítulo 59, sin cargarlo, y ejecuta
% una consulta con sus cláusulas en la versión 5. tabla_de_medidas/1
% compara lo que miden las versiones 3 a 6, tabla_de_inferencias/1 las
% inferencias de Prolog que cuestan las versiones 5 y 6, y igual_que_prolog/3
% compara las respuestas de una versión con las del propio Prolog.
%
% solo-local: carga los módulos de las versiones y el lector del
% capítulo 59.
%
%?- resolver(indice, familia, abuelo(juan, N)).
%?- ejecutar_archivo(ejemplos('capitulo-07/recorrer'), largo([a, b], N)).
%?- tabla_de_medidas([almacen-listas-suma_hasta(50, _)]).

:- use_module(programas).
:- use_module(resolvente, []).
:- use_module(alternativas, []).
:- use_module(almacen, []).
:- use_module(corte, []).
:- use_module(indice, []).
:- use_module(compilado, []).
:- ensure_loaded('../capitulo-59/leer').

:- multifile user:file_search_path/2.
:- prolog_load_context(directory, Aqui),
   directory_file_path(Aqui, '..', Dir),
   asserta(user:file_search_path(ejemplos, Dir)).

%!  resolver(+Version:atom, +Nombre:atom, ?Meta) is nondet.
%
%   Meta se prueba con el programa objeto Nombre en la Version de la
%   máquina.
resolver(Version, Nombre, Meta) :-
    version(Version),
    Version:resolver(Nombre, Meta).

% version(V): V es el módulo de una versión de la máquina.
version(resolvente).
version(alternativas).
version(almacen).
version(corte).
version(indice).
version(compilado).

%!  igual_que_prolog(+Version:atom, +Nombre:atom, +Meta) is semidet.
%
%   La Version de la máquina da las mismas respuestas que Prolog, en el
%   mismo orden, para Meta con el programa objeto Nombre.
igual_que_prolog(Version, Nombre, Meta) :-
    findall(Meta, resolver(Version, Nombre, Meta), Respuestas),
    respuestas_nativas(Nombre, Meta, Nativas),
    Respuestas =@= Nativas.

%!  ejecutar_archivo(+Archivo, ?Meta) is nondet.
%
%   Meta se prueba en la versión 5 de la máquina con las cláusulas del
%   Archivo, una especificación como ejemplos('capitulo-06/antepasados'),
%   leídas con leer_archivo/2 y programa/3 del capítulo 59. Las directivas
%   del archivo no se ejecutan.
ejecutar_archivo(Archivo, Meta) :-
    absolute_file_name(Archivo, Ruta,
                       [file_type(prolog), access(read)]),
    leer_archivo(Ruta, Leidos),
    programa(Leidos, Clausulas0, _),
    exclude(directiva, Clausulas0, Clausulas1),
    maplist(con_cuerpo, Clausulas1, Clausulas),
    almacen:resolver_clausulas(indice, Clausulas, Meta).

%!  directiva(+Clausula) is semidet.
%
%   Clausula es una de las que programa/3 crea para las directivas.
directiva(('<carga>' :- _)).

%!  con_cuerpo(+Clausula0, -Clausula) is det.
%
%   Clausula es Clausula0 escrita como Cabeza :- Cuerpo.
con_cuerpo(Clausula0, Clausula) :-
    (   Clausula0 = (_ :- _)
    ->  Clausula = Clausula0
    ;   Clausula = (Clausula0 :- true)
    ).

%!  tabla_de_medidas(+Filas:list) is det.
%
%   Escribe una fila por cada Version-Nombre-Meta de Filas, con lo que mide
%   esa versión de la máquina, la 3, la 4 o la 5, en la búsqueda completa
%   de Meta con el programa objeto Nombre.
tabla_de_medidas(Filas) :-
    escribir_fila([ version, programa, consulta, pasos, intentos, metas,
                    elecciones, rastro, celdas
                  ]),
    forall(member(Version-Nombre-Meta, Filas),
           fila(Version, Nombre, Meta)).

%!  fila(+Version:atom, +Nombre:atom, +Meta) is det.
%
%   Escribe la fila de la tabla de Meta en la Version.
fila(Version, Nombre, Meta) :-
    Version:medir(Nombre, Meta, Medidas),
    pairs_values(Medidas, [_|Valores]),
    copy_term(Meta, Meta1),
    numbervars(Meta1, 0, _),
    format(atom(Consulta), "~W", [Meta1, [numbervars(true), quoted(true)]]),
    escribir_fila([Version, Nombre, Consulta|Valores]).

%!  escribir_fila(+Valores:list) is det.
%
%   Escribe los Valores en las columnas de la tabla: las tres primeras
%   alineadas a la izquierda, las demás a la derecha.
escribir_fila(Valores) :-
    columnas(Columnas),
    foldl(escribir_celda, Valores, Columnas, 1, _),
    nl.

% columnas(Cs): Cs son las columnas donde termina cada celda de la tabla.
columnas([9, 18, 41, 47, 56, 62, 73, 80, 87]).

%!  escribir_celda(+Valor, +Columna:integer, +I0:integer, -I:integer)
%!      is det.
%
%   Escribe Valor, la celda número I0 de la fila, hasta la Columna.
escribir_celda(Valor, Columna, I0, I) :-
    (   I0 =< 3
    ->  format("~w~t~*|", [Valor, Columna])
    ;   format("~t~w~*|", [Valor, Columna])
    ),
    I is I0 + 1.

%!  tabla_de_inferencias(+Consultas:list) is det.
%
%   Escribe, por cada Nombre-Meta de Consultas, las inferencias de Prolog
%   que cuesta la búsqueda completa de Meta con el programa objeto Nombre
%   en las versiones 5 y 6, y el cociente entre las dos.
tabla_de_inferencias(Consultas) :-
    format("~w~t~30|~t~w~40|~t~w~51|~t~w~61|~n",
           [consulta, indice, compilado, cociente]),
    forall(member(Nombre-Meta, Consultas),
           fila_de_inferencias(Nombre, Meta)).

%!  fila_de_inferencias(+Nombre:atom, +Meta) is det.
%
%   Escribe la fila de Meta en la tabla de inferencias.
fila_de_inferencias(Nombre, Meta) :-
    inferencias(indice, Nombre, Meta, I5),
    inferencias(compilado, Nombre, Meta, I6),
    Cociente is I6 / I5,
    copy_term(Meta, Meta1),
    numbervars(Meta1, 0, _),
    format(atom(Consulta), "~W", [Meta1, [numbervars(true), quoted(true)]]),
    format("~w~t~30|~t~d~40|~t~d~51|~t~2f~61|~n",
           [Consulta, I5, I6, Cociente]).

%!  inferencias(+Version:atom, +Nombre:atom, +Meta, -N:integer) is det.
%
%   N es la cantidad de inferencias de Prolog que cuesta obtener todas las
%   respuestas de Meta en la Version. Se mide la segunda ejecución, para no
%   contar la carga de las bibliotecas que la primera provoca.
inferencias(Version, Nombre, Meta, N) :-
    findall(x, resolver(Version, Nombre, Meta), _),
    statistics(inferences, I0),
    findall(x, resolver(Version, Nombre, Meta), _),
    statistics(inferences, I1),
    N is I1 - I0.
