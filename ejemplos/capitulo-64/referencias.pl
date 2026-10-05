:- encoding(utf8).

% Capítulo 64 - Extensión: tokens que guardan referencias a los hechos.
%
% Un token de la red guarda dos cosas: los sellos de los hechos que usa y
% la instancia del prefijo, una copia de esos hechos con las variables
% ligadas. Los sellos bastan para encontrar los hechos en la memoria de
% trabajo, así que la instancia se puede reconstruir: se recorren los
% pasos del prefijo, cada patrón toma el hecho de su sello y cada prueba
% se vuelve a ejecutar. tamano_memorias/4 mide cuánto ocupan las memorias
% beta con las instancias y cuánto ocuparían solo con los sellos;
% reconstruibles/3 verifica que cada instancia guardada se puede obtener
% de nuevo a partir de sus sellos, y cuenta las que tienen más de una
% reconstrucción.
%
% solo-local: carga pruebas.pl y desconexion.pl con ensure_loaded/1, y SWISH
% no permite cargar archivos.
%
%?- tamano_memorias(familia, cadena(10), Completo, Sellos).
%?- reconstruibles(rangos, lista([n(2), n(3)]), Tokens, Ambiguos).

:- ensure_loaded(pruebas).
:- ensure_loaded(desconexion).

% Una prueba con varias soluciones: cada número X da un token por cada Y
% entre 1 y X, todos con el mismo sello.
programa(rangos,
    [ contar :: [n(X), {between(1, X, Y)}] ---> [agregar(visto(X, Y))] ]).

%!  estado_final(+Programa, +Fuente, -Red, -Memoria, -Rete) is det.
%
%   Memoria y Rete son los del final de una ejecución del Programa con la
%   estrategia orden y la red de red_con_pruebas/2, desde los hechos de la
%   Fuente de hechos_de/2.
estado_final(Programa, Fuente, Red, Memoria, Rete) :-
    hechos_de(Fuente, Hechos),
    red_con_pruebas(Programa, Red),
    cargar(Red, Hechos, Memoria0, Rete0),
    ciclo_rete(Red, orden, sin_traza, 0, _, [], Memoria0-Rete0,
               Memoria-Rete, _).

%!  tamano_memorias(+Programa, +Fuente, -Completo:integer,
%!                  -Sellos:integer) is det.
%
%   Completo son las celdas que ocupan los tokens de las memorias beta al
%   final de la ejecución desde la Fuente, con sus instancias; Sellos, las
%   que ocuparían guardando solo las listas de sellos. Las celdas son las
%   de term_size/2.
tamano_memorias(Programa, Fuente, Completo, Sellos) :-
    estado_final(Programa, Fuente, Red, _, Rete),
    todos_los_tokens(Red, Rete, Tokens),
    findall(Ss, member(_-(Ss-_), Tokens), Listas),
    term_size(Tokens, Completo),
    term_size(Listas, Sellos).

%!  todos_los_tokens(+Red, +Rete, -Tokens:list) is det.
%
%   Tokens tiene un par Nodo-Token por cada token de cada nodo beta,
%   salvo la raíz.
todos_los_tokens(Red, Rete, Tokens) :-
    Red = red(_, _, Nodos, _),
    findall(B-T,
            ( gen_assoc(B, Nodos, _),
              B > 0,
              tokens(B, Rete, Ts),
              member(T, Ts) ),
            Tokens).

%!  reconstruir(+Prefijo:list, +Memoria, +Sellos:list,
%!              -Instancia:list) is nondet.
%
%   Instancia es una copia del Prefijo con cada patrón ligado al hecho de
%   su sello en la Memoria de trabajo y cada prueba ejecutada. Una prueba
%   con varias soluciones da varias instancias.
reconstruir(Prefijo, Memoria, Sellos, Instancia) :-
    copy_term(Prefijo, Instancia),
    reconstruir_pasos(Instancia, Memoria, Sellos).

%!  reconstruir_pasos(+Pasos:list, +Memoria, +Sellos:list) is nondet.
%
%   Liga los Pasos con los hechos de los Sellos, en orden.
reconstruir_pasos([], _, []).
reconstruir_pasos([Paso|Pasos], Memoria, Sellos) :-
    reconstruir_paso(Paso, Memoria, Sellos, Resto),
    reconstruir_pasos(Pasos, Memoria, Resto).

%!  reconstruir_paso(+Paso, +Memoria, +Sellos:list, -Resto:list)
%!      is nondet.
%
%   Un patrón toma el primer sello; una prueba se ejecuta; una negación
%   no usa ningún hecho, porque el nodo ya verificó que no lo hay.
reconstruir_paso(alfa(F, Pruebas), Memoria, [Sello|Resto], Resto) :-
    once(elemento(Sello, F, Memoria)),
    maplist(call, Pruebas).
reconstruir_paso({Meta}, _, Sellos, Sellos) :-
    call(Meta).
reconstruir_paso(no(_), _, Sellos, Sellos).

%!  reconstruibles(+Programa, +Fuente, -Tokens:integer,
%!                  -Ambiguos:integer) is semidet.
%
%   Al final de la ejecución desde la Fuente, Tokens es la cantidad de
%   tokens de las memorias beta, y Ambiguos, la de los que tienen más de
%   una reconstrucción. Falla si alguna instancia guardada no está entre las
%   reconstrucciones de sus sellos.
reconstruibles(Programa, Fuente, N, Ambiguos) :-
    estado_final(Programa, Fuente, Red, Memoria, Rete),
    todos_los_tokens(Red, Rete, Tokens),
    length(Tokens, N),
    Red = red(_, _, Nodos, _),
    foldl(verificar_token(Nodos, Memoria), Tokens, 0, Ambiguos).

%!  verificar_token(+Nodos, +Memoria, +Par, +A0:integer, -A:integer)
%!      is semidet.
%
%   Par es Nodo-(Sellos-Instancia): la Instancia está entre las
%   reconstrucciones de los Sellos con el prefijo del Nodo. A es A0 más
%   uno si hay más de una reconstrucción distinta.
verificar_token(Nodos, Memoria, B-(Sellos-Instancia), A0, A) :-
    get_assoc(B, Nodos, beta(_, _, Prefijo, _, _)),
    findall(I, reconstruir(Prefijo, Memoria, Sellos, I), Is0),
    list_to_set(Is0, Is),
    memberchk(Instancia, Is),
    (   Is = [_, _|_]
    ->  A is A0 + 1
    ;   A = A0
    ).
