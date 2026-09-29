:- encoding(utf8).

% Capítulo 64 - Versión 2: las memorias alfa.
%
% Cada nodo alfa tiene una memoria con los hechos que aceptó, como pares
% Sello-Paso: el paso alfa(F, Pruebas) del nodo, con F ligada al hecho.
% Un hecho que entra o sale de la memoria de trabajo se compara solo con
% los nodos alfa de su functor, que el índice de la red da directamente:
% un hecho que ningún patrón usa no se compara con nada. La memoria de un
% nodo está indexada por el primer argumento del hecho, como Prolog indexa
% las cláusulas: quien busca un hecho con el primer argumento conocido no
% recorre los demás. Un signo, mas o menos, dice si el hecho entra o sale.
%
% solo-local: carga red.pl con ensure_loaded/1, y SWISH no permite cargar
% archivos.
%
%?- alfas_de(cajas, sobre(a, piso), Alfas).
%?- memorias_alfa(familia, [padre(juan, ana), madre(ana, sofia)], M).

:- ensure_loaded(red).

%!  alfas_del_hecho(+Red, +Hecho, -Alfas:list(integer)) is det.
%
%   Alfas son los nodos alfa de la Red que aceptan el Hecho. Solo se
%   prueban los del functor de Hecho.
alfas_del_hecho(red(Indice, Alfas, _, _), Hecho, Nodos) :-
    functor(Hecho, Nombre, Aridad),
    (   get_assoc(Nombre/Aridad, Indice, Candidatos)
    ->  include(acepta(Alfas, Hecho), Candidatos, Nodos)
    ;   Nodos = []
    ).

%!  alfas_de(+Programa, +Hecho, -Alfas:list(integer)) is det.
%
%   Como alfas_del_hecho/3, con la red del Programa.
alfas_de(Programa, Hecho, Alfas) :-
    red_de(Programa, Red),
    alfas_del_hecho(Red, Hecho, Alfas).

%!  acepta(+Alfas, +Hecho, +A:integer) is semidet.
%
%   El nodo alfa A acepta el Hecho.
acepta(Alfas, Hecho, A) :-
    instancias(Alfas, Hecho, A, [_|_]).

%!  instancias(+Alfas, +Hecho, +A:integer, -Pasos:list) is det.
%
%   Pasos son las copias del paso alfa(F, Pruebas) del nodo A con F
%   unificada con Hecho, una por cada manera de cumplir las Pruebas.
instancias(Alfas, Hecho, A, Pasos) :-
    get_assoc(A, Alfas, a(Paso, _)),
    findall(Copia,
            ( copy_term(Paso, Copia),
              Copia = alfa(Hecho, Pruebas),
              maplist(call, Pruebas) ),
            Pasos).

%!  memorias_alfa_vacias(+Red, -Memorias) is det.
%
%   Memorias asocia cada nodo alfa de la Red con una memoria vacía.
memorias_alfa_vacias(red(_, Alfas, _, _), Memorias) :-
    empty_assoc(Vacia),
    assoc_to_keys(Alfas, Nodos),
    findall(A-Vacia, member(A, Nodos), Pares),
    list_to_assoc(Pares, Memorias).

%!  entrar_alfa(+Signo, +Sello:integer, +Hecho, +Red, +Memorias0,
%!              -Memorias, -Entradas:list) is det.
%
%   Memorias son las Memorias0 después de que Hecho, con el Sello, entra
%   (Signo mas) o sale (Signo menos) de los nodos alfa que lo aceptan.
%   Entradas tiene un par A-Paso por cada paso que entró o salió del nodo
%   A. Un hecho que sale no vuelve a ejecutar las pruebas: se quitan los
%   pasos guardados con su sello.
entrar_alfa(mas, Sello, Hecho, red(Indice, Alfas, _, _), Memorias0,
            Memorias, Entradas) :-
    candidatos(Indice, Hecho, Candidatos),
    findall(A-Paso,
            ( member(A, Candidatos),
              instancias(Alfas, Hecho, A, Pasos),
              member(Paso, Pasos) ),
            Entradas),
    clave(Hecho, Clave),
    foldl(guardar_alfa(Sello, Clave), Entradas, Memorias0, Memorias).
entrar_alfa(menos, Sello, Hecho, red(Indice, _, _, _), Memorias0,
            Memorias, Entradas) :-
    candidatos(Indice, Hecho, Candidatos),
    clave(Hecho, Clave),
    foldl(quitar_alfa(Sello, Clave), Candidatos, Memorias0-[], Memorias-E),
    append(E, Entradas).

%!  candidatos(+Indice, +Hecho, -Candidatos:list(integer)) is det.
%
%   Candidatos son los nodos alfa del functor de Hecho.
candidatos(Indice, Hecho, Candidatos) :-
    functor(Hecho, Nombre, Aridad),
    (   get_assoc(Nombre/Aridad, Indice, Candidatos)
    ->  true
    ;   Candidatos = []
    ).

%!  clave(+Hecho, -Clave) is det.
%
%   Clave es el primer argumento de Hecho, o Hecho mismo si no tiene
%   argumentos.
clave(Hecho, Clave) :-
    (   compound(Hecho)
    ->  arg(1, Hecho, Clave)
    ;   Clave = Hecho
    ).

%!  guardar_alfa(+Sello:integer, +Clave, +Entrada, +Memorias0, -Memorias)
%!      is det.
%
%   La Entrada A-Paso queda en la memoria del nodo A, bajo la Clave.
guardar_alfa(Sello, Clave, A-Paso, Memorias0, Memorias) :-
    get_assoc(A, Memorias0, Memoria0),
    (   get_assoc(Clave, Memoria0, Lista)
    ->  true
    ;   Lista = []
    ),
    put_assoc(Clave, Memoria0, [Sello-Paso|Lista], Memoria),
    put_assoc(A, Memorias0, Memoria, Memorias).

%!  quitar_alfa(+Sello:integer, +Clave, +A:integer, +Estado0, -Estado)
%!      is det.
%
%   Estado0 y Estado son pares Memorias-Quitadas. Quita de la memoria del
%   nodo A los pasos guardados con el Sello bajo la Clave, y agrega a
%   Quitadas la lista de los pares A-Paso quitados.
quitar_alfa(Sello, Clave, A, Memorias0-Q0, Memorias-[Quitados|Q0]) :-
    get_assoc(A, Memorias0, Memoria0),
    (   get_assoc(Clave, Memoria0, Lista0)
    ->  partition(con_sello(Sello), Lista0, Salen, Lista),
        findall(A-Paso, member(_-Paso, Salen), Quitados),
        (   Lista == []
        ->  del_assoc(Clave, Memoria0, _, Memoria)
        ;   put_assoc(Clave, Memoria0, Lista, Memoria)
        ),
        put_assoc(A, Memorias0, Memoria, Memorias)
    ;   Quitados = [],
        Memorias = Memorias0
    ).

%!  con_sello(+Sello:integer, +Elemento) is semidet.
%
%   Elemento es un par Sello-Paso con el Sello dado.
con_sello(Sello, S-_) :-
    S =:= Sello.

%!  elementos_alfa(+Memoria, +F, -Elementos:list) is det.
%
%   Elementos son los pares Sello-Paso de la Memoria de un nodo alfa que
%   pueden unificar con F. Si el primer argumento de F no tiene variables,
%   se toman solo los de esa clave; si no, todos.
elementos_alfa(Memoria, F, Elementos) :-
    clave(F, Clave),
    (   ground(Clave)
    ->  (   get_assoc(Clave, Memoria, Elementos)
        ->  true
        ;   Elementos = []
        )
    ;   assoc_to_values(Memoria, Listas),
        append(Listas, Elementos)
    ).

%!  memorias_alfa(+Programa, +Hechos:list, -Contenido:list) is det.
%
%   Contenido tiene un par A-Elementos por cada nodo alfa de la red del
%   Programa, con los pares Sello-Hecho de su memoria después de agregar
%   los Hechos en orden, con los sellos 1, 2, ...
memorias_alfa(Programa, Hechos, Contenido) :-
    red_de(Programa, Red),
    memorias_alfa_vacias(Red, Memorias0),
    foldl(entrar_numerado(Red), Hechos, Memorias0-1, Memorias-_),
    assoc_to_list(Memorias, Pares),
    maplist(contenido, Pares, Contenido).

%!  entrar_numerado(+Red, +Hecho, +Memorias0S0, -MemoriasS) is det.
%
%   Hecho entra con el sello S0, y S es el sello siguiente.
entrar_numerado(Red, Hecho, Memorias0-S0, Memorias-S) :-
    entrar_alfa(mas, S0, Hecho, Red, Memorias0, Memorias, _),
    S is S0 + 1.

%!  contenido(+Par, -Contenido) is det.
%
%   Par es A-Memoria, y Contenido es A-Elementos, con los pares
%   Sello-Hecho de la Memoria ordenados por sello.
contenido(A-Memoria, A-Elementos) :-
    assoc_to_values(Memoria, Listas),
    append(Listas, Todos),
    findall(S-H, member(S-alfa(H, _), Todos), Elementos0),
    msort(Elementos0, Elementos).
