:- encoding(utf8).

% Capítulo 80 - Versión 4: el filtrado de Waltz.
%
% Cada unión empieza con la lista de todas sus combinaciones posibles, ya
% traducidas a etiquetas de líneas: su dominio. Una combinación de una unión
% K se descarta si da a la línea que K comparte con una vecina J una
% etiqueta que ninguna combinación de J le da. Cuando el dominio de K se
% reduce, K entra en la cola, porque sus vecinas pueden perder a su vez
% combinaciones; el filtrado termina cuando la cola se vacía. Si un dominio
% queda vacío, el dibujo no tiene interpretación. Si al terminar alguno
% tiene más de una combinación, la búsqueda elige una en la unión de
% dominio más chico y vuelve a filtrar.
%
% Los dominios se guardan en un árbol AVL de library(assoc), con la unión
% como clave: el filtrado no modifica ningún hecho de la base de datos.
%
% solo-local: carga dibujo.pl.
%
%?- tamanos(cubo, sin_borde, inicial, Ts).
%?- tamanos(cubo, sin_borde, filtrado, Ts).
%?- etiquetar_waltz(cubo, borde, Lineas).

:- ensure_loaded(dibujo).

%!  inicio(+F, +Modo, -Vecinos, -Dominios) is semidet.
%
%   Vecinos asocia cada unión del dibujo F con sus vecinas, y Dominios con
%   la lista de sus combinaciones posibles; cada combinación es una lista
%   de pares Linea-Etiqueta, con la etiqueta vista desde la primera punta de
%   la línea. Las combinaciones que contradicen las etiquetas que el Modo
%   fija no entran en el dominio.
inicio(F, Modo, Vecinos, Dominios) :-
    uniones(F, Us),
    fijas(F, Modo, Fijas),
    findall(P-Ks, member(u(P, _, Ks), Us), PsKs),
    list_to_assoc(PsKs, Vecinos),
    maplist(dominio(Fijas), Us, PsDs),
    list_to_assoc(PsDs, Dominios).

%!  dominio(+Fijas:list, +U, -Par) is det.
%
%   Par es P-Cs, donde Cs son las combinaciones de la unión U = u(P, Tipo,
%   Ks) compatibles con las etiquetas Fijas.
dominio(Fijas, u(P, Tipo, Ks), P-Cs) :-
    findall(C,
            ( union_posible(Tipo, Locales),
              maplist(par_global(P), Ks, Locales, C),
              compatible(C, Fijas) ),
            Cs).

%!  par_global(+P, +K, +Local, -Par) is det.
%
%   Par es Linea-E para la línea de P a K que la unión P ve con la etiqueta
%   Local; E es la etiqueta vista desde la primera punta de la línea.
par_global(P, K, Local, L-E) :-
    linea(P, K, L),
    (   P @< K
    ->  E = Local
    ;   inversa(Local, E)
    ).

%!  compatible(+C:list, +Fijas:list) is semidet.
%
%   Ninguna línea de la combinación C tiene en Fijas otra etiqueta.
compatible(C, Fijas) :-
    \+ ( member(L-E, C),
         memberchk(L-E2, Fijas),
         E \== E2 ).

%!  filtrar(+F, +Modo, -Dominios) is semidet.
%
%   Dominios son los dominios de las uniones del dibujo F después del
%   filtrado. Falla si algún dominio queda vacío.
filtrar(F, Modo, Dominios) :-
    inicio(F, Modo, Vecinos, Dominios0),
    assoc_to_keys(Dominios0, Cola),
    propagar(Cola, Vecinos, Dominios0, Dominios, _).

%!  propagar(+Cola:list, +Vecinos, +D0, -D, -Pasos:list) is semidet.
%
%   D son los dominios D0 filtrados a partir de las uniones de la Cola.
%   Pasos registra cada reducción como K-N: la unión y el tamaño en que
%   quedó su dominio. Falla si un dominio queda vacío.
propagar([], _, D, D, []).
propagar([J|Cola0], Vecinos, D0, D, Pasos) :-
    get_assoc(J, Vecinos, Ks),
    revisar_vecinas(Ks, J, D0, D1, Cola0, Cola, Pasos, Pasos1),
    propagar(Cola, Vecinos, D1, D, Pasos1).

%!  revisar_vecinas(+Ks:list, +J, +D0, -D, +Cola0, -Cola, -Pasos, ?Resto)
%!      is semidet.
%
%   Revisa el dominio de cada vecina K de J contra el de J. Cada vecina
%   cuyo dominio se reduce se agrega al final de la cola, si no estaba, y
%   su reducción se anota en la lista diferencia Pasos-Resto.
revisar_vecinas([], _, D, D, Cola, Cola, Pasos, Pasos).
revisar_vecinas([K|Ks], J, D0, D, Cola0, Cola, Pasos, Resto) :-
    revisar(J, K, D0, D1, Reducido),
    (   Reducido = si(N)
    ->  N > 0,
        Pasos = [K-N|Pasos1],
        (   memberchk(K, Cola0)
        ->  Cola1 = Cola0
        ;   append(Cola0, [K], Cola1)
        )
    ;   Pasos1 = Pasos,
        Cola1 = Cola0
    ),
    revisar_vecinas(Ks, J, D1, D, Cola1, Cola, Pasos1, Resto).

%!  revisar(+J, +K, +D0, -D, -Reducido) is det.
%
%   D es D0 sin las combinaciones de K que dan a la línea J-K una etiqueta
%   que ninguna combinación de J le da. Reducido es si(N), con N el nuevo
%   tamaño, o no si no se quitó ninguna.
revisar(J, K, D0, D, Reducido) :-
    linea(J, K, L),
    get_assoc(J, D0, CsJ),
    get_assoc(K, D0, CsK),
    findall(E, ( member(C, CsJ), memberchk(L-E, C) ), Es0),
    sort(Es0, Es),
    include(da_etiqueta(L, Es), CsK, Quedan),
    length(CsK, Antes),
    length(Quedan, Despues),
    (   Despues < Antes
    ->  put_assoc(K, D0, Quedan, D),
        Reducido = si(Despues)
    ;   D = D0,
        Reducido = no
    ).

%!  da_etiqueta(+L, +Es:list, +C:list) is semidet.
%
%   La combinación C da a la línea L una de las etiquetas Es.
da_etiqueta(L, Es, C) :-
    memberchk(L-E, C),
    memberchk(E, Es).

%!  tamanos(+F, +Modo, +Momento, -Ts:list) is semidet.
%
%   Ts son pares Union-N con el tamaño de cada dominio del dibujo F en el
%   Momento: inicial, antes de filtrar, o filtrado, después.
tamanos(F, Modo, Momento, Ts) :-
    (   Momento == inicial
    ->  inicio(F, Modo, _, D)
    ;   filtrar(F, Modo, D)
    ),
    assoc_to_list(D, Ps),
    maplist(tamano, Ps, Ts).

%!  tamano(+Par, -ParTamano) is det.
%
%   Reemplaza la lista de un par P-Cs por su longitud.
tamano(P-Cs, P-N) :-
    length(Cs, N).

%!  etiquetar_waltz(+F, +Modo, -Lineas:list) is nondet.
%
%   Lineas es una interpretación del dibujo F: filtrado, y búsqueda con
%   filtrado después de cada elección.
etiquetar_waltz(F, Modo, Lineas) :-
    inicio(F, Modo, Vecinos, D0),
    assoc_to_keys(D0, Cola),
    propagar(Cola, Vecinos, D0, D, _),
    buscar(Vecinos, D, Lineas).

%!  buscar(+Vecinos, +D, -Lineas:list) is nondet.
%
%   Si todos los dominios de D tienen una sola combinación, Lineas es su
%   unión. Si no, elige una combinación de la unión ambigua de dominio más
%   chico, filtra desde ella y sigue.
buscar(Vecinos, D, Lineas) :-
    assoc_to_list(D, Ps),
    (   ambigua(Ps, J)
    ->  get_assoc(J, D, Cs),
        member(C, Cs),
        put_assoc(J, D, [C], D1),
        propagar([J], Vecinos, D1, D2, _),
        buscar(Vecinos, D2, Lineas)
    ;   pairs_values(Ps, Unicas),
        append(Unicas, Combinaciones),
        append(Combinaciones, Pares),
        sort(Pares, Lineas)
    ).

%!  ambigua(+Ps:list, -J) is semidet.
%
%   J es la unión con más de una combinación y el dominio más chico de los
%   pares P-Cs. Falla si no hay ninguna.
ambigua(Ps, J) :-
    findall(N-P, ( member(P-Cs, Ps), length(Cs, N), N > 1 ), Ns),
    sort(Ns, [_-J|_]).

%!  interpretaciones_waltz(+F, +Modo, -N:integer) is det.
%
%   N es la cantidad de interpretaciones del dibujo F.
interpretaciones_waltz(F, Modo, N) :-
    aggregate_all(count, etiquetar_waltz(F, Modo, _), N).

%!  escribir_interpretaciones(+F, +Modo) is det.
%
%   Escribe las interpretaciones del dibujo F, numeradas, una por renglón,
%   con cada línea seguida de su etiqueta.
escribir_interpretaciones(F, Modo) :-
    findall(Ls, etiquetar_waltz(F, Modo, Ls), Todas),
    forall(nth1(I, Todas, Ls),
           ( format("~w:", [I]),
             forall(member((A-B)-E, Ls), format(" ~w~w=~w", [A, B, E])),
             nl )).

%!  escribir_tamanos(+F, +Modo, +Momento) is semidet.
%
%   Escribe en un renglón el tamaño del dominio de cada unión del dibujo F
%   en el Momento, inicial o filtrado. Falla si el filtrado vacía un
%   dominio.
escribir_tamanos(F, Modo, Momento) :-
    tamanos(F, Modo, Momento, Ts),
    findall(Texto, ( member(P-N, Ts), format(atom(Texto), "~w:~w", [P, N]) ),
            Textos),
    atomic_list_concat(Textos, ' ', Renglon),
    writeln(Renglon).
