:- encoding(utf8).

% Capítulo 61 - Versión 6: el programa compilado a instrucciones.
%
% Las versiones anteriores examinan cada cláusula al usarla: renombran la
% cabeza entera, la unifican con el algoritmo general, clasifican cada meta
% del cuerpo con clase/2 y buscan su procedimiento por nombre y aridad.
% Esta versión hace ese trabajo una vez, al traducir el programa. La cabeza
% se compila a una lista de instrucciones de unificación, una por
% argumento; I es la posición del argumento en el término que lo contiene:
%   constante(I, C)          el argumento es la constante C
%   primera(I, V)            primera aparición de la variable V: su celda,
%                            nueva, se liga al argumento sin unificar
%   otra(I, V)               otra aparición de V: se unifica
%   estructura(I, F/N, Is, E)  el argumento es un término F/N: si es una
%                            celda libre, se liga al esqueleto E
%                            renombrado; si no, se ejecutan con él las
%                            instrucciones Is de sus argumentos
% El cuerpo se compila a instrucciones de llamada ya clasificadas:
%   '$llamar'(Nombre/Aridad, Meta), '$predefinida'(Meta) y '$cortar'.
% En la resolvente, '$cortar' pasa a ser '$corte'(Altura), como en
% corte.pl. La indexación es la de indice.pl.
%
% solo-local: carga los módulos almacen, corte e indice.
%
%?- resolver(listas, suma([1, 2, 3], S)).
%?- compilar_clausula_v6((p(f(X), X) :- q(X)), C).

:- module(compilado,
          [ resolver/2,
            medir/3,
            compilar_clausula_v6/2
          ]).

:- use_module(library(apply)).
:- use_module(library(assoc)).
:- use_module(library(error)).
:- use_module(library(lists)).
:- use_module(programas).
:- use_module(almacen,
              [ resolver_con/3,
                medir_con/4,
                compilar/2 as agrupar,
                compilar_clausula/2,
                renombrar/3,
                desreferenciar/3,
                unificar/5,
                ligar/5,
                marca/2,
                deshacer/3,
                ejecutar_predefinida/4,
                contar_intento/2
              ]).
:- use_module(corte, [cortar/4]).
:- use_module(indice, [clave/2, clave_actual/3, siguiente/4]).

%!  resolver(+Nombre:atom, ?Meta) is nondet.
%
%   Meta se prueba con el programa objeto Nombre, compilado.
resolver(Nombre, Meta) :-
    resolver_con(compilado, Nombre, Meta).

%!  medir(+Nombre:atom, +Meta, -Medidas:list) is det.
%
%   Medidas son las medidas de la búsqueda completa de Meta, como las
%   describe medir_con/4 de almacen.pl.
medir(Nombre, Meta, Medidas) :-
    medir_con(compilado, Nombre, Meta, Medidas).

%!  compilar(+Clausulas:list, -Tabla) is det.
%
%   Tabla asocia a cada Nombre/Aridad la lista de sus cláusulas compiladas,
%   en orden, cada una en un par Clave-cc(K, Cabeza, Cuerpo).
compilar(Clausulas, Tabla) :-
    agrupar(Clausulas, Tabla0),
    map_assoc(compilar_procedimiento, Tabla0, Tabla).

%!  compilar_procedimiento(+Clausulas:list, -Pares:list) is det.
%
%   Pares son las Clausulas traducidas, cl(K, Cabeza, Cuerpo), compiladas.
compilar_procedimiento(Clausulas, Pares) :-
    maplist(compilar_traducida, Clausulas, Pares).

%!  compilar_clausula_v6(+Clausula, -Compilada) is det.
%
%   Compilada es la Clausula, de la forma Cabeza :- Cuerpo, compilada:
%   Clave-cc(K, Instrucciones, Llamadas).
compilar_clausula_v6(Clausula, Compilada) :-
    compilar_clausula(Clausula, _-Traducida),
    compilar_traducida(Traducida, Compilada).

%!  compilar_traducida(+Traducida, -Compilada) is det.
%
%   Compilada es la cláusula Traducida, cl(K, Cabeza, Cuerpo), con la
%   clave de su cabeza, las instrucciones de la cabeza y las del cuerpo.
compilar_traducida(cl(K, Cabeza, Cuerpo),
                   Clave-cc(K, Instrucciones, Llamadas)) :-
    clave(Cabeza, Clave),
    instrucciones(Cabeza, Instrucciones),
    maplist(llamada, Cuerpo, Llamadas).

%!  llamada(+Meta, -Instruccion) is det.
%
%   Instruccion es la meta Meta de un cuerpo, ya clasificada.
llamada(Meta, Instruccion) :-
    clase(Meta, Clase),
    llamada_de(Clase, Meta, Instruccion).

%!  llamada_de(+Clase, +Meta, -Instruccion) is det.
%
%   Instruccion es la de una Meta de la Clase dada.
llamada_de(corte, _, '$cortar').
llamada_de(predefinida(_), Meta, '$predefinida'(Meta)).
llamada_de(usuario(_), Meta, '$llamar'(Nombre/Aridad, Meta)) :-
    functor(Meta, Nombre, Aridad).

%!  instrucciones(+Termino, -Instrucciones:list) is det.
%
%   Instrucciones son las de unificación de los argumentos del Termino,
%   una cabeza o un subtérmino de ella.
instrucciones(Termino, Instrucciones) :-
    instrucciones(Termino, [], _, Instrucciones).

%!  instrucciones(+Termino, +Vistas0:list, -Vistas:list,
%!                -Instrucciones:list) is det.
%
%   Como instrucciones/2; Vistas0 y Vistas son las variables ya aparecidas
%   antes y después.
instrucciones(Termino, Vistas0, Vistas, Instrucciones) :-
    (   compound(Termino)
    ->  compound_name_arguments(Termino, _, Argumentos)
    ;   Argumentos = []
    ),
    length(Argumentos, N),
    numlist_desde_1(N, Posiciones),
    foldl(instruccion, Posiciones, Argumentos, Instrucciones,
          Vistas0, Vistas).

%!  numlist_desde_1(+N:integer, -Posiciones:list) is det.
%
%   Posiciones es la lista de 1 a N, vacía si N es 0.
numlist_desde_1(N, Posiciones) :-
    (   N =:= 0
    ->  Posiciones = []
    ;   numlist(1, N, Posiciones)
    ).

%!  instruccion(+I:integer, +Argumento, -Instruccion, +Vistas0:list,
%!              -Vistas:list) is det.
%
%   Instruccion es la del Argumento que está en la posición I.
instruccion(I, Argumento, Instruccion, Vistas0, Vistas) :-
    (   Argumento = '$v'(V)
    ->  (   memberchk(V, Vistas0)
        ->  Instruccion = otra(I, V),
            Vistas = Vistas0
        ;   Instruccion = primera(I, V),
            Vistas = [V|Vistas0]
        )
    ;   atomic(Argumento)
    ->  Instruccion = constante(I, Argumento),
        Vistas = Vistas0
    ;   compound_name_arity(Argumento, Nombre, Aridad),
        instrucciones(Argumento, Vistas0, Vistas, Hijas),
        Instruccion = estructura(I, Nombre/Aridad, Hijas, Argumento)
    ).

%!  paso(+Meta, +Metas:list, +Tabla, +Estado0, -Resultado) is det.
%
%   Como paso/5 de indice.pl, con las metas compiladas. Una meta sin
%   compilar, la de la consulta, se compila al tomarla.
paso(Meta, Metas, Tabla, Estado0, Resultado) :-
    (   Meta = '$llamar'(Indicador, M)
    ->  procedimiento_de(Tabla, Indicador, Pares),
        Estado0 = m(_, Pila, _, _, _, _),
        length(Pila, Altura),
        llamar(Pares, Meta, M, Metas, Altura, Estado0, Resultado)
    ;   Meta = '$predefinida'(M)
    ->  Estado0 = m(_, Pila, A0, R0, L, Med),
        marca(Pila, Marca),
        (   ejecutar_predefinida(M, Marca, A0-R0, A-R)
        ->  Resultado = sigue(m(Metas, Pila, A, R, L, Med))
        ;   Resultado = falla(Estado0)
        )
    ;   Meta = '$corte'(Altura)
    ->  cortar(Altura, Metas, Estado0, Estado),
        Resultado = sigue(Estado)
    ;   Meta == !
    ->  cortar(0, Metas, Estado0, Estado),
        Resultado = sigue(Estado)
    ;   llamada(Meta, Instruccion),
        paso(Instruccion, Metas, Tabla, Estado0, Resultado)
    ).

%!  procedimiento_de(+Tabla, +Indicador, -Pares:list) is det.
%
%   Pares son las cláusulas compiladas del predicado Indicador. Un
%   predicado sin cláusulas produce un error de existencia.
procedimiento_de(Tabla, Indicador, Pares) :-
    (   get_assoc(Indicador, Tabla, Pares)
    ->  true
    ;   existence_error(procedure, Indicador)
    ).

%!  llamar(+Pares:list, +Entrada, +Meta, +Metas:list, +Altura:integer,
%!         +Estado0, -Resultado) is det.
%
%   Como llamar/6 de indice.pl; Entrada es la meta compilada, que el punto
%   de elección guarda, y Meta la meta que se unifica.
llamar(Pares0, Entrada, Meta, Metas, Altura, Estado0, Resultado) :-
    Estado0 = m(_, _, Almacen, _, _, _),
    clave_actual(Meta, Almacen, Clave),
    (   siguiente(Pares0, Clave, Clausula, Pares)
    ->  contar_intento(Estado0, Estado1),
        (   Pares == []
        ->  Estado2 = Estado1
        ;   Estado1 = m(Ms, Pila, A, R, L, M),
            length(R, N),
            Estado2 = m(Ms, [eleccion([Entrada|Metas], Pares, N, L)|Pila],
                        A, R, L, M)
        ),
        (   usar(Clausula, Meta, Metas, Altura, Estado2, Estado)
        ->  Resultado = sigue(Estado)
        ;   Pares == []
        ->  Resultado = falla(Estado1)
        ;   llamar(Pares, Entrada, Meta, Metas, Altura, Estado1, Resultado)
        )
    ;   Resultado = falla(Estado0)
    ).

%!  usar(+Clausula, +Meta, +Metas:list, +Altura:integer, +Estado0,
%!       -Estado) is semidet.
%
%   Usa la Clausula compilada, cc(K, Instrucciones, Llamadas): ejecuta las
%   instrucciones de la cabeza con los argumentos de Meta, con las celdas
%   de la cláusula desde la primera libre, y pone las llamadas,
%   renombradas, delante de Metas. Falla si una instrucción falla.
usar(cc(K, Instrucciones, Llamadas), Meta, Metas, Altura,
     m(_, Pila, A0, R0, L0, M), m(Metas1, Pila, A, R, L, M)) :-
    marca(Pila, Marca),
    foldl(ejecutar(Meta, L0, Marca), Instrucciones, A0-R0, A-R),
    maplist(instanciar(L0, Altura), Llamadas, Llamadas1),
    append(Llamadas1, Metas, Metas1),
    L is L0 + K.

%!  instanciar(+Base:integer, +Altura:integer, +Llamada0, -Llamada) is det.
%
%   Llamada es la Llamada0 compilada de un cuerpo, renombrada desde Base;
%   '$cortar' pasa a ser '$corte'(Altura).
instanciar(Base, Altura, Llamada0, Llamada) :-
    (   Llamada0 == '$cortar'
    ->  Llamada = '$corte'(Altura)
    ;   renombrar(Base, Llamada0, Llamada)
    ).

%!  ejecutar(+Termino, +Base:integer, +Marca:integer, +Instruccion,
%!           +Estado0, -Estado) is semidet.
%
%   Ejecuta una instrucción con el argumento que le corresponde del
%   Termino, ya desreferenciado. Estado0 y Estado son pares
%   Almacen-Rastro; la variable V de la cláusula es la celda Base + V.
ejecutar(Termino, Base, Marca, Instruccion, A0-R0, A-R) :-
    arg(1, Instruccion, I),
    arg(I, Termino, Argumento),
    desreferenciar(Argumento, A0, T),
    (   Instruccion = primera(_, V)
    ->  Celda is Base + V,
        put_assoc(Celda, A0, T, A),
        R = R0
    ;   Instruccion = constante(_, C)
    ->  (   T = '$v'(N)
        ->  ligar(N, C, Marca, A0-R0, A-R)
        ;   T == C,
            A = A0,
            R = R0
        )
    ;   Instruccion = otra(_, V)
    ->  Celda is Base + V,
        unificar('$v'(Celda), T, Marca, A0-R0, A-R)
    ;   Instruccion = estructura(_, Nombre/Aridad, Hijas, Esqueleto),
        (   T = '$v'(N)
        ->  renombrar(Base, Esqueleto, Nuevo),
            ligar(N, Nuevo, Marca, A0-R0, A-R)
        ;   compound(T),
            compound_name_arity(T, Nombre, Aridad),
            foldl(ejecutar(T, Base, Marca), Hijas, A0-R0, A-R)
        )
    ).

%!  volver(+Tabla, +Estado0, -Resultado) is det.
%
%   Como volver/3 de indice.pl, con la meta compilada del punto de
%   elección.
volver(Tabla, Estado0, Resultado) :-
    (   Estado0 = m(_, [], _, _, _, _)
    ->  Resultado = fin(Estado0)
    ;   volver_desde(Tabla, Estado0, Resultado)
    ).

%!  volver_desde(+Tabla, +Estado0, -Resultado) is det.
%
%   Como volver/3, con al menos un punto de elección en la pila.
volver_desde(Tabla, m(_, [Eleccion|Pila], A0, R0, L, M), Resultado) :-
    Eleccion = eleccion([Entrada|Metas], Pares, N, _),
    Entrada = '$llamar'(_, Meta),
    deshacer(N, A0-R0, A-R),
    length(Pila, Altura),
    llamar(Pares, Entrada, Meta, Metas, Altura,
           m([Entrada|Metas], Pila, A, R, L, M), Resultado0),
    (   Resultado0 = falla(Estado)
    ->  volver(Tabla, Estado, Resultado)
    ;   Resultado = Resultado0
    ).
