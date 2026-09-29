:- encoding(utf8).

% Capítulo 59 - Versión 3: el programa leído de sus archivos.
%
% leer_archivo/2 lee los términos de un archivo con read_term/3, sin
% cargarlo: cada uno con su archivo y su línea, los nombres de sus
% variables y los comentarios que lo preceden. programa/3 convierte lo
% leído en la lista de cláusulas de las versiones anteriores y en la lista
% de los puntos de entrada: los predicados que exporta cada módulo, los
% que se definen para otro módulo (como prolog:message//1) y '<carga>'/0,
% un predicado que llama a cada directiva.
%
% El programa inscripciones son los archivos de archivos/2, en la copia de
% caso/: clausulas/2 y raices/2 los leen, de modo que los análisis de las
% versiones anteriores lo reciben por su nombre.
%
% El conocimiento sobre el sistema deja de ser una tabla: un predicado es
% predefinido si está definido en un módulo vacío, externo, donde se cargan
% las bibliotecas que los archivos importan; y una metallamada es lo que
% declara su meta_predicate.
%
% solo-local: lee archivos y carga problemas.pl.
%
%?- termino_leido(inscripciones(datos), leido((nota_minima(N) :- C), P, Ns, _)).
%?- indefinidos(inscripciones, Is), no_usados(inscripciones, Us).

:- ensure_loaded(problemas).
:- use_module(library(apply)).
:- use_module(library(lists)).

:- set_module(externo:base(system)).

% El proyecto Inscripciones del capítulo 31 se lee de una copia anterior a
% la declaración meta_predicate que el capítulo 31 agregó después a api.pl:
% ver caso/LEEME.txt.
:- multifile user:file_search_path/2.
:- prolog_load_context(directory, Aqui),
   directory_file_path(Aqui, caso, Dir),
   asserta(user:file_search_path(inscripciones, Dir)).

%!  archivos(+Programa, -Archivos:list) is semidet.
%
%   Archivos son los archivos del programa llamado Programa. Falla si no
%   hay un programa con ese nombre. El de inscripciones es el proyecto del
%   capítulo 31 que forma el programa de línea de órdenes: los nueve
%   módulos, el archivo que los carga y el programa principal.
archivos(inscripciones, Archivos) :-
    Nombres = [ datos, reglas, informes, comandos, horarios, intercambio,
                consola, puente, api, inscripciones, principal ],
    maplist(archivo_de_inscripciones, Nombres, Archivos).

%!  archivo_de_inscripciones(+Nombre:atom, -Archivo:atom) is det.
%
%   Archivo es la ruta del archivo Nombre.pl del proyecto.
archivo_de_inscripciones(Nombre, Archivo) :-
    absolute_file_name(inscripciones(Nombre), Archivo,
                       [file_type(prolog), access(read)]).

%!  clausulas(+Programa, -Clausulas:list) is semidet.
%
%   Cláusula agregada: las cláusulas de inscripciones, leídas de sus
%   archivos.
clausulas(inscripciones, Clausulas) :-
    archivos(inscripciones, Archivos),
    leer_programa(Archivos, Clausulas, _).

%!  raices(+Programa, -Raices:list) is semidet.
%
%   Cláusula agregada: los puntos de entrada de inscripciones, leídos de
%   sus archivos.
raices(inscripciones, Raices) :-
    archivos(inscripciones, Archivos),
    leer_programa(Archivos, _, Raices).

%!  termino_leido(+Archivo, -Leido) is nondet.
%
%   Leido es uno de los términos de Archivo, como los da leer_archivo/2.
%   Archivo es una ruta o una especificación, como inscripciones(datos).
termino_leido(Archivo, Leido) :-
    absolute_file_name(Archivo, Ruta, [file_type(prolog), access(read)]),
    leer_archivo(Ruta, Leidos),
    member(Leido, Leidos).

%!  leer_archivo(+Archivo, -Leidos:list) is det.
%
%   Leidos son los términos de Archivo, en orden, cada uno como
%   leido(Termino, Base:Linea, Nombres, Comentarios): Base es el nombre del
%   archivo sin directorio, Linea la línea donde empieza el término,
%   Nombres la lista Nombre=Variable de sus variables y Comentarios los
%   textos de los comentarios que lo preceden. Una directiva que importa
%   una biblioteca la carga en el módulo externo, que así conoce también
%   sus operadores.
leer_archivo(Archivo, Leidos) :-
    file_base_name(Archivo, Base),
    setup_call_cleanup(open(Archivo, read, Stream, [encoding(utf8)]),
                       leer_terminos(Stream, Base, Leidos),
                       close(Stream)).

%!  leer_terminos(+Stream, +Base:atom, -Leidos:list) is det.
%
%   Leidos son los términos que quedan en Stream.
leer_terminos(Stream, Base, Leidos) :-
    read_term(Stream, Termino,
              [ module(externo),
                variable_names(Nombres),
                term_position(Posicion),
                comments(Comentarios0)
              ]),
    (   Termino == end_of_file
    ->  Leidos = []
    ;   stream_position_data(line_count, Posicion, Linea),
        findall(Texto, member(_-Texto, Comentarios0), Comentarios),
        preparar_lectura(Termino),
        Leidos = [leido(Termino, Base:Linea, Nombres, Comentarios)|Resto],
        leer_terminos(Stream, Base, Resto)
    ).

%!  preparar_lectura(+Termino) is det.
%
%   Si Termino importa una biblioteca, la carga en el módulo externo; si
%   define un operador, lo define allí. Cualquier otro término no cambia
%   nada.
preparar_lectura(:- use_module(library(B))) :-
    !,
    externo:use_module(library(B)).
preparar_lectura(:- use_module(library(B), _)) :-
    !,
    externo:use_module(library(B)).
preparar_lectura(:- op(P, T, Nombres)) :-
    !,
    op(P, T, externo:Nombres).
preparar_lectura(_).

%!  leer_programa(+Archivos:list, -Clausulas:list, -Raices:list) is det.
%
%   Clausulas son las cláusulas de los Archivos, y Raices sus puntos de
%   entrada, ordenados.
leer_programa(Archivos, Clausulas, Raices) :-
    maplist(leer_archivo, Archivos, Leidos0),
    append(Leidos0, Leidos),
    programa(Leidos, Clausulas, Raices).

%!  programa(+Leidos:list, -Clausulas:list, -Raices:list) is det.
%
%   Clausulas son las cláusulas de los términos Leidos, con las reglas de
%   gramática traducidas y sin la calificación de módulo de las cabezas;
%   Raices son los puntos de entrada, ordenados.
programa(Leidos, Clausulas, Raices) :-
    foldl(termino, Leidos, Clausulas-Raices0, []-[]),
    sort(['<carga>'/0|Raices0], Raices).

%!  termino(+Leido, +Programa0, -Programa) is det.
%
%   Agrega el término Leido al programa, representado como una lista
%   diferencia de cláusulas y otra de raíces: Programa0 es
%   Clausulas-Raices, y Programa, las colas que quedan por completar.
termino(leido(Termino, _, _, _), Cs0-Rs0, Cs-Rs) :-
    traducir(Termino, Clausulas, Raices),
    append(Clausulas, Cs, Cs0),
    append(Raices, Rs, Rs0).

%!  traducir(+Termino, -Clausulas:list, -Raices:list) is det.
%
%   Clausulas son las cláusulas que el término aporta al programa, y
%   Raices los puntos de entrada que declara.
traducir(:- module(_, Exportados), [], Raices) :-
    !,
    convlist(exportado, Exportados, Raices).
traducir(:- encoding(_), [], []) :-
    !.
traducir(:- Declaracion, Clausulas, []) :-
    declaracion_dinamica(Declaracion, Especificaciones),
    !,
    lista_de_especificaciones(Especificaciones, PIs),
    maplist(cabeza_declarada, PIs, Clausulas).
traducir(:- use_module(library(B)), [('<carga>' :- Directiva)], Raices) :-
    !,
    Directiva = use_module(library(B)),
    findall(PI, gancho(B, PI), Raices).
traducir(:- initialization(Meta), [('<carga>' :- Meta)], []) :-
    !.
traducir(:- initialization(Meta, _), [('<carga>' :- Meta)], []) :-
    !.
traducir(:- Directiva, [('<carga>' :- Directiva)], []) :-
    !.
traducir((Cabeza --> Cuerpo), [Clausula], Raices) :-
    !,
    dcg_translate_rule((Cabeza --> Cuerpo), Clausula0),
    sin_modulo(Clausula0, Clausula, Raices).
traducir(Clausula0, [Clausula], Raices) :-
    sin_modulo(Clausula0, Clausula, Raices).

%!  declaracion_dinamica(+Declaracion, -Especificaciones) is semidet.
%
%   Declaracion declara predicados que pueden no tener cláusulas.
declaracion_dinamica(dynamic(Es), Es).
declaracion_dinamica(table(Es), Es).

%!  lista_de_especificaciones(+Es, -PIs:list) is det.
%
%   PIs son los indicadores de Es, una conjunción o una lista de ellos.
lista_de_especificaciones(Es, PIs) :-
    (   is_list(Es)
    ->  PIs = Es
    ;   Es = (A, B)
    ->  lista_de_especificaciones(A, PAs),
        lista_de_especificaciones(B, PBs),
        append(PAs, PBs, PIs)
    ;   PIs = [Es]
    ).

%!  cabeza_declarada(+PI, -Cabeza) is det.
%
%   Cabeza es una cabeza con argumentos libres del predicado PI: la
%   declaración cuenta como una definición sin cláusulas que llamen a otro.
cabeza_declarada(Nombre/Aridad, Cabeza) :-
    functor(Cabeza, Nombre, Aridad).

%!  exportado(+Exportado, -PI) is semidet.
%
%   PI es el predicado que exporta la entrada Exportado de una lista de
%   exportación; un no terminal N//A es el predicado N/A+2. Falla con una
%   entrada que exporta un operador.
exportado(Nombre/Aridad, Nombre/Aridad).
exportado(Nombre//Aridad0, Nombre/Aridad) :-
    Aridad is Aridad0 + 2.

%!  sin_modulo(+Clausula0, -Clausula, -Raices:list) is det.
%
%   Clausula es Clausula0 sin la calificación de módulo de la cabeza. Una
%   cláusula para otro módulo, como prolog:message//1, la llama el sistema:
%   su predicado es un punto de entrada.
sin_modulo(Clausula0, Clausula, Raices) :-
    cabeza_cuerpo(Clausula0, Cabeza0, Cuerpo),
    (   Cabeza0 = _:Cabeza
    ->  indicador(Cabeza, PI),
        Raices = [PI]
    ;   Cabeza = Cabeza0,
        Raices = []
    ),
    (   Cuerpo == true
    ->  Clausula = Cabeza
    ;   Clausula = (Cabeza :- Cuerpo)
    ).

% Lo que el sistema informa se agrega a las tablas de la versión 1.

%!  predefinido(+P) is semidet.
%
%   Cláusula agregada: P está definido en el módulo externo, porque es del
%   sistema, de una biblioteca que se autocarga o de una que el programa
%   importa.
predefinido(Nombre/Aridad) :-
    atom(Nombre),
    integer(Aridad),
    functor(Cabeza, Nombre, Aridad),
    predicate_property(externo:Cabeza, defined).

%!  meta_argumento(+Meta, -G, -Extra:integer) is nondet.
%
%   Cláusulas agregadas: lo que dice la declaración meta_predicate del
%   predicado de Meta, y lo que las bibliotecas llaman sin que una
%   declaración lo diga: http_handler/3 llama a su manejador con el pedido
%   como un argumento más.
meta_argumento(Meta, G, Extra) :-
    callable(Meta),
    predicate_property(externo:Meta, meta_predicate(Declaracion)),
    arg(I, Declaracion, Tipo),
    arg(I, Meta, G0),
    meta_tipo(Tipo, G0, G, Extra).
meta_argumento(http_handler(_, G, _), G, 1).

% gancho(B, PI): la biblioteca B llama por su nombre al predicado PI del
% programa que la importa.
gancho(main, main/1).
gancho(main, opt_type/3).
gancho(main, opt_help/2).
gancho(main, opt_meta/2).

%!  meta_tipo(+Tipo, +G0, -G, -Extra:integer) is semidet.
%
%   Un argumento de tipo Tipo en una declaración meta_predicate, con valor
%   G0, es la meta G llamada con Extra argumentos más: un entero dice
%   cuántos, ^ admite variables cuantificadas, // es un cuerpo de gramática.
meta_tipo(N, G, G, N) :-
    integer(N).
meta_tipo(^, G0, G, 0) :-
    sin_cuantificar(G0, G).
meta_tipo(//, G, G, 2) :-
    \+ is_list(G).
