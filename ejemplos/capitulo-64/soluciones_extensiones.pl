:- encoding(utf8).

% Capítulo 64 - Soluciones de los ejercicios 13 y 14.
%
% Ejercicio 13: la negación de una conjunción escrita con una regla
% auxiliar y una negación simple. Ejercicio 14: quitar una regla de una
% red en marcha.
%
% solo-local: carga conjuntiva.pl y en_marcha.pl con ensure_loaded/1, y
% SWISH no permite cargar archivos.
%
%?- comparar_bloques([bloque(a), bloque(b), sobre(c, a), color(c, rojo)], F).
%?- igual_sin_regla(familia, 2, [padre(juan, ana), padre(ana, sofia)]).

:- ensure_loaded(conjuntiva).
:- ensure_loaded(en_marcha).

% Ejercicio 13 --------------------------------------------------------------

% La misma regla con un hecho auxiliar: primero se marca cada bloque que
% tiene encima un bloque rojo, y después se declara libre el que no está
% marcado.
programa(bloques_aux,
    [ marcar :: [sobre(Y, X), color(Y, rojo)]
                ---> [agregar(rojo_encima(X))],
      libre :: [bloque(X), no(rojo_encima(X))]
               ---> [agregar(libre_de_rojo(X))]
    ]).

%!  comparar_bloques(+Hechos:list, -Fila) is det.
%
%   Fila es f(Ciclos, Libres, CiclosAux, LibresAux): los ciclos de cada
%   versión desde los Hechos y los bloques que cada una declara libres.
comparar_bloques(Hechos, f(C, L, CA, LA)) :-
    red_conj(bloques, Red),
    ejecutar_red(Red, orden, sin_traza, Hechos, C, M, _),
    libres(M, L),
    ejecutar_rete(bloques_aux, orden, sin_traza, Hechos, CA, MA, _),
    libres(MA, LA).

%!  libres(+Memoria, -Bloques:list) is det.
%
%   Bloques son los X de los hechos libre_de_rojo(X) de la Memoria, en
%   orden alfabético.
libres(Memoria, Bloques) :-
    findall(X, elemento(_, libre_de_rojo(X), Memoria), Bloques0),
    msort(Bloques0, Bloques).

%!  despues_de_quitar(+Programa, +Hechos:list, +Quitado, -Instanciaciones)
%!      is det.
%
%   Instanciaciones es el conjunto de conflicto de la red del Programa
%   después de cargar los Hechos, ejecutar hasta que nada sea aplicable y
%   quitar el hecho Quitado.
despues_de_quitar(bloques, Hechos, Quitado, Instanciaciones) :-
    red_conj(bloques, Red),
    despues_de_quitar_con(Red, Hechos, Quitado, Instanciaciones).
despues_de_quitar(bloques_aux, Hechos, Quitado, Instanciaciones) :-
    red_de(bloques_aux, Red),
    despues_de_quitar_con(Red, Hechos, Quitado, Instanciaciones).

%!  despues_de_quitar_con(+Red, +Hechos:list, +Quitado,
%!                        -Instanciaciones:list) is det.
%
%   Como despues_de_quitar/4, con una Red ya compilada; solo cuenta las
%   instanciaciones de la regla libre.
despues_de_quitar_con(Red, Hechos, Quitado, Instanciaciones) :-
    cargar(Red, Hechos, M0, R0),
    ciclo_rete(Red, orden, sin_traza, 0, _, [], M0-R0, M1-R1, _),
    retirar_rete(Red, Quitado, M1-R1, _-R),
    conjunto_rete(R, Todas),
    include(de_libre, Todas, Instanciaciones).

%!  de_libre(+Instanciacion) is semidet.
%
%   La Instanciacion es de la regla libre.
de_libre(instanciacion(libre, _, _, _)).

% Ejercicio 14 --------------------------------------------------------------

%!  quitar_regla(+K:integer, +Red0, +Rete0, -Red, -Rete) is det.
%
%   Red y Rete son Red0 y Rete0 sin la regla número K: sin sus
%   instanciaciones, sin los nodos beta que ninguna otra regla usa y sin
%   los nodos alfa que quedan sin sucesores, con sus memorias.
quitar_regla(K, red(I0, A0, B0, T0), rete(MA0, MB0, C0),
             Red, rete(MA, MB, C)) :-
    del_assoc(K, T0, _, T),
    assoc_to_list(C0, Pares0),
    exclude(de_regla(K), Pares0, Pares),
    list_to_assoc(Pares, C),
    once(( gen_assoc(Hoja, B0, beta(Tipo, Padre, Pr, Hijos, Ks)),
           memberchk(K, Ks) )),
    subtract(Ks, [K], Ks1),
    put_assoc(Hoja, B0, beta(Tipo, Padre, Pr, Hijos, Ks1), B1),
    podar(Hoja, red(I0, A0, B1, T)-MB0, Red1-MB),
    podar_alfas(Red1, MA0, Red, MA).

%!  de_regla(+K:integer, +Par) is semidet.
%
%   Par es una entrada del conjunto de conflicto de la regla K.
de_regla(K, (K-_)-_).

%!  podar(+B:integer, +Estado0, -Estado) is det.
%
%   Estado0 y Estado son pares Red-MemoriasBeta. Si el nodo B no es la
%   raíz y no tiene hijos ni reglas, se borra con sus memorias, sale de la
%   lista de hijos de su padre y de los sucesores de sus nodos alfa, y se
%   poda el padre.
podar(B, red(I, A0, B0, T)-M0, Estado) :-
    get_assoc(B, B0, beta(Tipo, Padre, _, Hijos, Ks)),
    (   B =\= 0, Hijos == [], Ks == []
    ->  del_assoc(B, B0, _, B1),
        get_assoc(Padre, B1, beta(TP, PP, PrP, HP, KP)),
        subtract(HP, [B], HP1),
        put_assoc(Padre, B1, beta(TP, PP, PrP, HP1, KP), B2),
        alfas_del_tipo(Tipo, As),
        foldl(sin_sucesor(B), As, A0, A1),
        borrar_clave(B, M0, M1),
        borrar_clave(cuentas(B), M1, M2),
        podar(Padre, red(I, A1, B2, T)-M2, Estado)
    ;   Estado = red(I, A0, B0, T)-M0
    ).

%!  alfas_del_tipo(+Tipo, -As:list(integer)) is det.
%
%   As son los nodos alfa que lee un nodo beta del Tipo.
alfas_del_tipo(union(A), [A]).
alfas_del_tipo(negacion(A), [A]).
alfas_del_tipo(negacion_conj(As), As).
alfas_del_tipo(prueba, []).

%!  sin_sucesor(+B:integer, +A:integer, +Alfas0, -Alfas) is det.
%
%   Alfas es Alfas0 sin B entre los sucesores del nodo alfa A.
sin_sucesor(B, A, Alfas0, Alfas) :-
    get_assoc(A, Alfas0, a(Paso, Sucesores)),
    subtract(Sucesores, [B], Sucesores1),
    put_assoc(A, Alfas0, a(Paso, Sucesores1), Alfas).

%!  borrar_clave(+Clave, +Tabla0, -Tabla) is det.
%
%   Tabla es Tabla0 sin la Clave, si la tenía.
borrar_clave(Clave, Tabla0, Tabla) :-
    (   del_assoc(Clave, Tabla0, _, Tabla)
    ->  true
    ;   Tabla = Tabla0
    ).

%!  podar_alfas(+Red0, +Memorias0, -Red, -Memorias) is det.
%
%   Red y Memorias son Red0 y Memorias0 sin los nodos alfa que no tienen
%   sucesores, también borrados del índice de su functor.
podar_alfas(red(I0, A0, B, T), M0, red(I, A, B, T), M) :-
    findall(X, gen_assoc(X, A0, a(_, [])), Vacios),
    foldl(borrar_clave, Vacios, A0, A),
    foldl(borrar_clave, Vacios, M0, M),
    assoc_to_list(I0, Indices0),
    findall(F-Ns,
            ( member(F-Ns0, Indices0),
              subtract(Ns0, Vacios, Ns),
              Ns \== [] ),
            Indices),
    list_to_assoc(Indices, I).

%!  igual_sin_regla(+Programa, +I:integer, +Hechos:list) is semidet.
%
%   Quitar la regla número I de la red cargada con los Hechos deja las
%   mismas instanciaciones y la misma cantidad de nodos que compilar el
%   Programa sin esa regla. El orden y los números de los nodos pueden
%   cambiar.
igual_sin_regla(Programa, I, Hechos) :-
    programa(Programa, Reglas),
    compilar_red(pasos, Reglas, Red0),
    cargar(Red0, Hechos, _, Rete0),
    quitar_regla(I, Red0, Rete0, Red, Rete),
    conjunto_rete(Rete, Is),
    nth1(I, Reglas, _, Otras),
    compilar_red(pasos, Otras, RedSin),
    cargar(RedSin, Hechos, _, ReteSin),
    conjunto_rete(ReteSin, IsSin),
    msort(Is, S),
    msort(IsSin, SSin),
    S =@= SSin,
    medidas_red(Red, A, B, _),
    medidas_red(RedSin, A, B, _).
