:- encoding(utf8).

% Capítulo 59 - El programa terminado: un informe sobre los archivos de un
% programa.
%
% informe_de/1 lee los archivos, arma el grafo de llamadas y escribe lo
% que encuentra: el tamaño del programa, los predicados que se llaman y
% nadie define, los que no se alcanzan desde los puntos de entrada, los
% grupos de predicados recursivos y los avisos de estilo. referencias_de/2
% escribe dónde se define un predicado, a quién llama y quién lo llama.
% informe/1 y referencias/2 reciben el nombre del programa, como en
% archivos/2.
%
% solo-local: lee archivos y carga revision.pl.
%
%?- informe(inscripciones).
%?- referencias(inscripciones, inscripcion_posible/3).

:- ensure_loaded(revision).

%!  informe_de(+Archivos:list) is det.
%
%   Escribe el informe del programa formado por Archivos.
informe_de(Archivos) :-
    maplist(leer_archivo, Archivos, PorArchivo),
    append(PorArchivo, Leidos),
    programa(Leidos, Clausulas, Raices),
    length(Archivos, NA),
    length(Clausulas, NC),
    definidos(Clausulas, Ds),
    length(Ds, ND),
    grafo(Clausulas, Grafo),
    edges(Grafo, Arcos),
    length(Arcos, NL),
    format("Programa: ~d archivos, ~d cláusulas, ~d predicados, \c
            ~d llamadas entre ellos~n", [NA, NC, ND, NL]),
    indefinidos_de(Clausulas, Is),
    findall(Linea, ( member(I, Is),
                     findall(P, llama_de(Clausulas, P, I), Ps),
                     format(atom(Linea), "~q, llamado por ~q", [I, Ps]) ),
            LineasI),
    seccion("Indefinidos", LineasI),
    no_usados_de(Clausulas, Raices, Us),
    maplist(con_posicion(Leidos), Us, LineasU),
    seccion("No alcanzables desde los puntos de entrada", LineasU),
    componentes_de(Clausulas, Grupos),
    maplist(grupo, Grupos, LineasR),
    seccion("Recursivos", LineasR),
    maplist(revisar, PorArchivo, Avisos0),
    append(Avisos0, Avisos),
    maplist(aviso_linea, Avisos, LineasA),
    seccion("Avisos de estilo", LineasA).

%!  informe(+Programa) is det.
%
%   informe_de/1 sobre los archivos del programa llamado Programa.
informe(Programa) :-
    archivos(Programa, Archivos),
    informe_de(Archivos).

%!  seccion(+Titulo:string, +Lineas:list) is det.
%
%   Escribe el título y cada línea con sangría, o el título y ninguno.
seccion(Titulo, []) :-
    !,
    format("~s: ninguno~n", [Titulo]).
seccion(Titulo, Lineas) :-
    format("~s:~n", [Titulo]),
    forall(member(L, Lineas), format("    ~w~n", [L])).

%!  con_posicion(+Leidos:list, +PI, -Linea:atom) is det.
%
%   Linea es PI seguido del archivo y la línea de su primera cláusula.
con_posicion(Leidos, PI, Linea) :-
    (   once(clausula_leida(Leidos, leido(_, Posicion, _, _), PI))
    ->  format(atom(Linea), "~q (~w)", [PI, Posicion])
    ;   format(atom(Linea), "~q", [PI])
    ).

%!  grupo(+Grupo:list, -Linea:atom) is det.
%
%   Linea son los predicados de Grupo separados por comas.
grupo(Grupo, Linea) :-
    maplist(term_to_atom, Grupo, Atomos),
    atomic_list_concat(Atomos, ', ', Linea).

%!  aviso_linea(+Aviso, -Linea:atom) is det.
%
%   Linea es el aviso escrito como Archivo:Linea: tipo detalle.
aviso_linea(aviso(Posicion, Tipo, Detalle), Linea) :-
    format(atom(Linea), "~w: ~w ~q", [Posicion, Tipo, Detalle]).

%!  referencias_de(+Archivos:list, +PI) is det.
%
%   Escribe dónde se define PI en el programa formado por Archivos, a qué
%   predicados del programa llama y qué predicados lo llaman.
referencias_de(Archivos, PI) :-
    maplist(leer_archivo, Archivos, PorArchivo),
    append(PorArchivo, Leidos),
    programa(Leidos, Clausulas, _),
    definidos(Clausulas, Ds),
    con_posicion(Leidos, PI, Linea),
    format("~w~n", [Linea]),
    (   llamadas_de(Clausulas, PI, Qs0)
    ->  include(propio(Ds), Qs0, Qs)
    ;   Qs = []
    ),
    findall(P, llama_de(Clausulas, P, PI), Ps0),
    sort(Ps0, Ps),
    format("    llama a: ~q~n    lo llaman: ~q~n", [Qs, Ps]).

%!  referencias(+Programa, +PI) is det.
%
%   referencias_de/2 sobre los archivos del programa llamado Programa.
referencias(Programa, PI) :-
    archivos(Programa, Archivos),
    referencias_de(Archivos, PI).
