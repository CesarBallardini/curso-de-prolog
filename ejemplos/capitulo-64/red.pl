:- encoding(utf8).

% Capítulo 64 - Versión 1: las reglas compiladas en una red.
%
% compilar_red/3 traduce las condiciones de cada regla a pasos y construye
% una red con dos clases de nodos. Un nodo alfa representa un patrón
% suelto, el paso alfa(F, Pruebas): su memoria guardará los hechos que
% unifican con F y cumplen las Pruebas, que por ahora son siempre la lista
% vacía. Un nodo beta representa un prefijo de los pasos de una regla,
% desde el primero hasta uno dado: su memoria guardará las maneras de
% cumplir ese prefijo. Dos reglas cuyos prefijos son variantes comparten
% el nodo beta, y dos patrones variantes comparten el nodo alfa: la red es
% un grafo acíclico, no un árbol por regla. El nodo beta 0 es la raíz, el
% prefijo vacío.
%
% La red de un programa se compila una sola vez: red_de/2 está tabulada.
%
% solo-local: carga costo.pl del capítulo 63 con ensure_loaded/1, y SWISH
% no permite cargar archivos.
%
%?- mostrar_red(familia).
%?- tamano_red(cajas, Alfas, Betas, Condiciones).

:- ensure_loaded('../capitulo-63/costo').
:- use_module(library(assoc)).
:- use_module(library(lists)).
:- use_module(library(apply)).

:- table red_de/2.

%!  red_de(+Programa, -Red) is det.
%
%   Red es la red compilada de las reglas del Programa, con un paso por
%   condición. La primera consulta la compila, y la tabla guarda el
%   resultado para las siguientes.
red_de(Programa, Red) :-
    programa(Programa, Reglas),
    compilar_red(pasos, Reglas, Red).

%!  pasos(+Condiciones:list, -Pasos:list) is det.
%
%   Pasos tiene un paso por condición: un patrón F es alfa(F, []), y no(F)
%   y {Meta} quedan como están. Comparte las variables con Condiciones.
pasos(Condiciones, Pasos) :-
    maplist(paso, Condiciones, Pasos).

%!  paso(+Condicion, -Paso) is det.
%
%   Paso es el paso de la Condicion.
paso(Condicion, Paso) :-
    (   Condicion = {_}
    ->  Paso = Condicion
    ;   Condicion = no(_)
    ->  Paso = Condicion
    ;   Paso = alfa(Condicion, [])
    ).

%!  compilar_red(:Agrupar, +Reglas:list, -Red) is det.
%
%   Red es el término red(Indice, Alfas, Betas, Terminales), construido con
%   los pasos que call(Agrupar, Condiciones, Pasos) da para cada regla.
%   Alfas asocia cada número de nodo alfa con a(Paso, Sucesores), donde
%   Paso es alfa(F, Pruebas); Indice asocia cada Nombre/Aridad con los
%   nodos alfa de ese functor. Betas asocia cada número de nodo beta con
%   beta(Tipo, Padre, Prefijo, Hijos, Reglas), y Terminales, el número de
%   cada regla con regla(Nombre, N, Pasos, Acciones), donde N es la
%   cantidad de condiciones.
compilar_red(Agrupar, Reglas, Red) :-
    empty_assoc(Vacio),
    list_to_assoc([0-beta(raiz, ninguno, [], [], [])], Betas0),
    foldl(compilar_regla(Agrupar), Reglas,
          red(Vacio, Vacio, Betas0, Vacio)-1, Red-_).

%!  compilar_regla(:Agrupar, +Regla, +Red0K0, -RedK) is det.
%
%   Agrega a la red la Regla, que es la número K0 del programa: recorre sus
%   pasos y cuelga la regla del nodo beta del último.
compilar_regla(Agrupar, Nombre :: Condiciones ---> Acciones, Red0-K0,
               Red-K) :-
    call(Agrupar, Condiciones, Pasos),
    unir(Pasos, [], 0, Red0, Red1, Hoja),
    Red1 = red(Indice, Alfas, Betas1, Terminales0),
    length(Condiciones, N),
    copy_term(Pasos-Acciones, Ps-As),
    put_assoc(K0, Terminales0, regla(Nombre, N, Ps, As), Terminales),
    get_assoc(Hoja, Betas1, beta(T, P, Pr, H, Rs)),
    append(Rs, [K0], Rs1),
    put_assoc(Hoja, Betas1, beta(T, P, Pr, H, Rs1), Betas),
    Red = red(Indice, Alfas, Betas, Terminales),
    K is K0 + 1.

%!  unir(+Pasos:list, +Prefijo0:list, +Padre:integer, +Red0, -Red,
%!       -Hoja:integer) is det.
%
%   Recorre los Pasos que siguen al Prefijo0, cuyo nodo es Padre. Hoja es
%   el nodo del prefijo completo.
unir([], _, Hoja, Red, Red, Hoja).
unir([Paso|Pasos], Prefijo0, Padre, Red0, Red, Hoja) :-
    append(Prefijo0, [Paso], Prefijo),
    nodo_beta(Paso, Prefijo, Padre, Red0, Red1, Nodo),
    unir(Pasos, Prefijo, Nodo, Red1, Red, Hoja).

%!  nodo_beta(+Paso, +Prefijo:list, +Padre:integer, +Red0, -Red,
%!            -Nodo:integer) is det.
%
%   Nodo es el hijo de Padre cuyo prefijo es una variante de Prefijo, que
%   termina en Paso. Si no hay ninguno, se crea.
nodo_beta(_, Prefijo, Padre, Red, Red, Nodo) :-
    Red = red(_, _, Betas, _),
    get_assoc(Padre, Betas, beta(_, _, _, Hijos, _)),
    member(Nodo, Hijos),
    get_assoc(Nodo, Betas, beta(_, _, Guardado, _, _)),
    Guardado =@= Prefijo,
    !.
nodo_beta(Paso, Prefijo, Padre, Red0, Red, Nodo) :-
    tipo_de(Paso, Tipo, Red0, Red1),
    Red1 = red(Indice, Alfas0, Betas0, Terminales),
    max_assoc(Betas0, Ultimo, _),
    Nodo is Ultimo + 1,
    copy_term(Prefijo, Copia),
    put_assoc(Nodo, Betas0, beta(Tipo, Padre, Copia, [], []), Betas1),
    get_assoc(Padre, Betas1, beta(T, P, Pr, Hijos, Rs)),
    append(Hijos, [Nodo], Hijos1),
    put_assoc(Padre, Betas1, beta(T, P, Pr, Hijos1, Rs), Betas),
    agregar_sucesor(Tipo, Nodo, Alfas0, Alfas),
    Red = red(Indice, Alfas, Betas, Terminales).

%!  tipo_de(+Paso, -Tipo, +Red0, -Red) is det.
%
%   Tipo es prueba para {Meta}, negacion(A) para no(F) y union(A) para
%   alfa(F, Pruebas), donde A es el nodo alfa, que se crea si hace falta.
%   El nodo alfa de no(F) es el de alfa(F, []).
tipo_de(Paso, Tipo, Red0, Red) :-
    (   Paso = {_}
    ->  Tipo = prueba,
        Red = Red0
    ;   Paso = no(F)
    ->  Tipo = negacion(A),
        nodo_alfa(alfa(F, []), Red0, Red, A)
    ;   Tipo = union(A),
        nodo_alfa(Paso, Red0, Red, A)
    ).

%!  nodo_alfa(+Paso, +Red0, -Red, -A:integer) is det.
%
%   A es el nodo alfa de un paso variante de Paso, alfa(F, Pruebas). Si no
%   hay ninguno, se crea y se agrega al índice del functor de F.
nodo_alfa(Paso, Red0, Red, A) :-
    Red0 = red(Indice0, Alfas0, Betas, Terminales),
    Paso = alfa(F, _),
    functor(F, Nombre, Aridad),
    (   get_assoc(Nombre/Aridad, Indice0, Candidatos)
    ->  true
    ;   Candidatos = []
    ),
    (   member(A, Candidatos),
        get_assoc(A, Alfas0, a(Guardado, _)),
        Guardado =@= Paso
    ->  Red = Red0
    ;   (   max_assoc(Alfas0, Ultimo, _)
        ->  A is Ultimo + 1
        ;   A = 1
        ),
        copy_term(Paso, Copia),
        put_assoc(A, Alfas0, a(Copia, []), Alfas),
        append(Candidatos, [A], Candidatos1),
        put_assoc(Nombre/Aridad, Indice0, Candidatos1, Indice),
        Red = red(Indice, Alfas, Betas, Terminales)
    ).

%!  agregar_sucesor(+Tipo, +Nodo:integer, +Alfas0, -Alfas) is det.
%
%   Si el Tipo lee un nodo alfa, Nodo pasa a ser uno de sus sucesores. Los
%   sucesores quedan del mayor al menor: un nodo se crea después que su
%   padre, así que los más profundos quedan primero.
agregar_sucesor(prueba, _, Alfas, Alfas).
agregar_sucesor(negacion(A), Nodo, Alfas0, Alfas) :-
    agregar_sucesor(union(A), Nodo, Alfas0, Alfas).
agregar_sucesor(union(A), Nodo, Alfas0, Alfas) :-
    get_assoc(A, Alfas0, a(Paso, Sucesores)),
    sort(0, @>=, [Nodo|Sucesores], Sucesores1),
    put_assoc(A, Alfas0, a(Paso, Sucesores1), Alfas).

%!  tamano_red(+Programa, -Alfas:integer, -Betas:integer,
%!             -Condiciones:integer) is det.
%
%   La red del Programa tiene Alfas nodos alfa y Betas nodos beta, sin
%   contar la raíz; las reglas suman Condiciones condiciones, que es la
%   cantidad de nodos beta que tendría la red sin compartir ninguno.
tamano_red(Programa, NAlfas, NBetas, Condiciones) :-
    red_de(Programa, Red),
    medidas_red(Red, NAlfas, NBetas, Condiciones).

%!  medidas_red(+Red, -Alfas:integer, -Betas:integer,
%!              -Condiciones:integer) is det.
%
%   Como tamano_red/4, para una Red ya compilada.
medidas_red(red(_, Alfas, Betas, Terminales), NAlfas, NBetas,
            Condiciones) :-
    assoc_to_keys(Alfas, As),
    length(As, NAlfas),
    assoc_to_keys(Betas, Bs),
    length(Bs, NBetas1),
    NBetas is NBetas1 - 1,
    assoc_to_values(Terminales, Reglas),
    foldl(sumar_condiciones, Reglas, 0, Condiciones).

%!  sumar_condiciones(+Regla, +S0:integer, -S:integer) is det.
%
%   S es S0 más la cantidad de condiciones de la Regla.
sumar_condiciones(regla(_, N, _, _), S0, S) :-
    S is S0 + N.

%!  mostrar_red(+Programa) is det.
%
%   Escribe la red del Programa con mostrar/1.
mostrar_red(Programa) :-
    red_de(Programa, Red),
    mostrar(Red).

%!  mostrar(+Red) is det.
%
%   Escribe una línea por nodo alfa, con su patrón, sus pruebas si las
%   tiene, y sus sucesores, y una por nodo beta, con su padre, su tipo, su
%   último paso y las reglas que terminan en él.
mostrar(red(_, Alfas, Betas, Terminales)) :-
    forall(gen_assoc(A, Alfas, a(Paso, Sucesores)),
           escribir(alfa(A, Paso, Sucesores))),
    forall(( gen_assoc(B, Betas, beta(Tipo, Padre, Prefijo, _, Ks)),
             B > 0 ),
           ( maplist(nombre_regla(Terminales), Ks, Nombres),
             escribir(beta(B, Padre, Tipo, Prefijo, Nombres))
           )).

%!  nombre_regla(+Terminales, +K:integer, -Nombre) is det.
%
%   Nombre es el de la regla número K.
nombre_regla(Terminales, K, Nombre) :-
    get_assoc(K, Terminales, regla(Nombre, _, _, _)).

%!  escribir(+Linea) is det.
%
%   Escribe una línea de mostrar/1, con las variables como A, B, ... Las
%   de un nodo beta se nombran en todo su prefijo, así que la misma letra
%   en dos nodos de una cadena es la misma variable.
escribir(Linea) :-
    \+ \+ ( numbervars(Linea, 0, _),
            escribir_linea(Linea) ).

%!  escribir_linea(+Linea) is det.
%
%   Escribe la Linea, cuyas variables ya tienen nombre.
escribir_linea(alfa(A, Paso, Sucesores)) :-
    format("alfa ~w: ", [A]),
    escribir_paso(Paso),
    format(" -> ~w~n", [Sucesores]).
escribir_linea(beta(B, Padre, Tipo, Prefijo, Nombres)) :-
    last(Prefijo, Paso),
    format("beta ~w (de ~w, ~p): ", [B, Padre, Tipo]),
    escribir_paso(Paso),
    (   Nombres == []
    ->  nl
    ;   format(" => ~w~n", [Nombres])
    ).

%!  escribir_paso(+Paso) is det.
%
%   Escribe un paso: alfa(F, []) como F, y alfa(F, Pruebas) como F seguido
%   de las Pruebas entre llaves.
escribir_paso(Paso) :-
    (   Paso = alfa(F, [])
    ->  format("~p", [F])
    ;   Paso = alfa(F, Pruebas)
    ->  format("~p ~p", [F, Pruebas])
    ;   format("~p", [Paso])
    ).
