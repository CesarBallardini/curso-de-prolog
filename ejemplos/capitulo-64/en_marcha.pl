:- encoding(utf8).

% Capítulo 64 - Extensión: agregar una regla con la red en marcha.
%
% compilar_regla/4 agrega una regla a una red ya compilada y comparte los
% nodos que puede. Con la red cargada, los nodos nuevos nacen vacíos: hay
% que llenarlos. Cada nodo alfa nuevo recibe los hechos de la memoria de
% trabajo que acepta, del más antiguo al más reciente. Cada nodo beta nuevo
% cuyo padre ya existía recibe por la izquierda los tokens del padre, y la
% salida lleva los tokens hasta los nodos nuevos de más abajo y hasta la
% regla. Si la regla no crea ningún nodo beta, porque su prefijo completo
% ya estaba en la red, sus instanciaciones salen de los tokens del nodo
% del que cuelga.
%
% solo-local: carga rete.pl con ensure_loaded/1, y SWISH no permite cargar
% archivos.
%
%?- con_regla_nueva(familia, [padre(juan, ana), madre(ana, sofia)], Is).

:- ensure_loaded(rete).

%!  agregar_regla(+Regla, +Memoria, +Red0, +Rete0, -Red, -Rete) is det.
%
%   Red es Red0 con la Regla compilada, y Rete, el estado Rete0 con los
%   nodos nuevos llenos con los hechos de la Memoria de trabajo.
agregar_regla(Regla, Memoria, Red0, Rete0, Red, Rete) :-
    Red0 = red(_, Alfas0, Betas0, Terminales0),
    assoc_to_keys(Terminales0, Ks),
    length(Ks, N),
    K is N + 1,
    compilar_regla(pasos, Regla, Red0-K, Red-_),
    Red = red(_, Alfas, Betas, _),
    nuevas_claves(Alfas0, Alfas, NuevosAlfas),
    nuevas_claves(Betas0, Betas, NuevosBetas),
    foldl(llenar_alfa(Red, Memoria), NuevosAlfas, Rete0, Rete1),
    (   NuevosBetas == []
    ->  colgar_regla(Red, K, Rete1, Rete)
    ;   include(con_padre_viejo(Betas, NuevosBetas), NuevosBetas, Raices),
        foldl(llenar_beta(Red), Raices, Rete1, Rete)
    ).

%!  nuevas_claves(+Antes, +Despues, -Nuevas:list) is det.
%
%   Nuevas son las claves de la tabla Despues que no están en Antes, en
%   orden creciente.
nuevas_claves(Antes, Despues, Nuevas) :-
    assoc_to_keys(Despues, Todas),
    exclude(clave_de(Antes), Todas, Nuevas).

%!  clave_de(+Tabla, +Clave) is semidet.
%
%   Clave está en la Tabla.
clave_de(Tabla, Clave) :-
    get_assoc(Clave, Tabla, _).

%!  llenar_alfa(+Red, +Memoria, +A:integer, +Rete0, -Rete) is det.
%
%   La memoria del nodo alfa nuevo A recibe los hechos de la Memoria de
%   trabajo que acepta, del más antiguo al más reciente.
llenar_alfa(Red, Memoria, A, rete(Memorias0, Betas, C),
            rete(Memorias, Betas, C)) :-
    Red = red(_, Alfas, _, _),
    empty_assoc(Vacia),
    put_assoc(A, Memorias0, Vacia, Memorias1),
    findall(S-H, elemento(S, H, Memoria), Elementos0),
    reverse(Elementos0, Elementos),
    foldl(llenar_con(Alfas, A), Elementos, Memorias1, Memorias).

%!  llenar_con(+Alfas, +A:integer, +Elemento, +Memorias0, -Memorias)
%!      is det.
%
%   El hecho del Elemento Sello-Hecho entra en el nodo A si lo acepta.
llenar_con(Alfas, A, Sello-Hecho, Memorias0, Memorias) :-
    instancias(Alfas, Hecho, A, Pasos),
    clave(Hecho, Clave),
    findall(A-Paso, member(Paso, Pasos), Entradas),
    foldl(guardar_alfa(Sello, Clave), Entradas, Memorias0, Memorias).

%!  con_padre_viejo(+Betas, +Nuevos:list, +B:integer) is semidet.
%
%   El padre del nodo beta B no es uno de los Nuevos.
con_padre_viejo(Betas, Nuevos, B) :-
    get_assoc(B, Betas, beta(_, Padre, _, _, _)),
    \+ memberchk(Padre, Nuevos).

%!  llenar_beta(+Red, +B:integer, +Rete0, -Rete) is det.
%
%   Activa por la izquierda el nodo nuevo B con cada token de su padre.
llenar_beta(Red, B, Rete0, Rete) :-
    Red = red(_, _, Betas, _),
    get_assoc(B, Betas, beta(_, Padre, _, _, _)),
    tokens(Padre, Rete0, Tokens),
    foldl(activar_con(Red, B), Tokens, Rete0, Rete).

%!  activar_con(+Red, +B:integer, +Token, +Rete0, -Rete) is det.
%
%   Activa por la izquierda el nodo B con el Token.
activar_con(Red, B, Token, Rete0, Rete) :-
    activar_izquierda(mas, Token, Red, B, Rete0, Rete).

%!  colgar_regla(+Red, +K:integer, +Rete0, -Rete) is det.
%
%   La regla número K cuelga de un nodo que ya existía: cada token de ese
%   nodo es una instanciación suya.
colgar_regla(Red, K, Rete0, Rete) :-
    Red = red(_, _, Betas, _),
    once(( gen_assoc(Hoja, Betas, beta(_, _, _, _, Ks)),
           memberchk(K, Ks) )),
    tokens(Hoja, Rete0, Tokens),
    foldl(terminal_de(Red, K), Tokens, Rete0, Rete).

%!  terminal_de(+Red, +K:integer, +Token, +Rete0, -Rete) is det.
%
%   El Token completa la regla K.
terminal_de(Red, K, Token, Rete0, Rete) :-
    terminal(mas, Token, Red, K, Rete0, Rete).

%!  con_regla_tardia(+Programa, +I:integer, +Hechos:list,
%!                   -Instanciaciones:list) is det.
%
%   Instanciaciones es el conjunto de conflicto que resulta de compilar
%   las reglas del Programa salvo la número I, cargar los Hechos y agregar
%   después la regla I con la red en marcha.
con_regla_tardia(Programa, I, Hechos, Instanciaciones) :-
    programa(Programa, Reglas),
    nth1(I, Reglas, Tardia, Otras),
    compilar_red(pasos, Otras, Red0),
    cargar(Red0, Hechos, Memoria, Rete0),
    agregar_regla(Tardia, Memoria, Red0, Rete0, _, Rete),
    conjunto_rete(Rete, Instanciaciones).

%!  con_regla_nueva(+Programa, +Hechos:list, -Instanciaciones:list) is det.
%
%   Como con_regla_tardia/4, con la última regla del Programa: el
%   conjunto tiene que ser el de reconocer_rete/3, en el mismo orden.
con_regla_nueva(Programa, Hechos, Instanciaciones) :-
    programa(Programa, Reglas),
    length(Reglas, N),
    con_regla_tardia(Programa, N, Hechos, Instanciaciones).

%!  igual_con_cualquier_tardia(+Programa, +Hechos:list) is semidet.
%
%   Para cada regla del Programa, agregarla con la red en marcha da las
%   mismas instanciaciones que compilarlas todas antes de cargar: el orden
%   puede cambiar, porque la regla tardía queda última.
igual_con_cualquier_tardia(Programa, Hechos) :-
    programa(Programa, Reglas),
    length(Reglas, N),
    reconocer_rete(Programa, Hechos, Is0),
    msort(Is0, Ordenadas),
    forall(between(1, N, I),
           ( con_regla_tardia(Programa, I, Hechos, Is),
             msort(Is, Ordenadas1),
             Ordenadas1 =@= Ordenadas )).
