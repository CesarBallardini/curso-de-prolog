:- encoding(utf8).

% Capítulo 58 - Versión 6: procedimientos y un análisis interprocedural.
%
% Mini se amplía con procedimientos anidados, alcance estático y paso de
% parámetros por valor, como el lenguaje del intérprete de Warren. Un
% bloque es bloque(Declaraciones, Sentencias); una declaración es var(X)
% o proc(Nombre, Parametros, Bloque), y la sentencia nueva es
% llamar(Nombre, Argumentos). Las expresiones, las condiciones y las
% sentencias simples se escriben como texto de Mini y se leen con el
% analizador del capítulo 45.
%
% El estado de una ejecución es una pila de registros de activación: el
% primero es el del bloque que se ejecuta, y los siguientes los de los
% bloques que lo encierran en el texto del programa, no los de quien lo
% llamó. Un nombre se busca del primer registro al último; un
% procedimiento declarado en el registro I se ejecuta sobre la pila sin
% los I primeros registros, que se vuelven a poner al retornar.
%
% El análisis de signos tabula el efecto de cada sentencia, como en la
% versión 3, y también el de cada procedimiento con cada combinación de
% signos de sus argumentos y de las variables que ve: la tabla de
% a_procedimiento/5 es el resumen del procedimiento en cada contexto de
% llamada, y la tabulación hace terminar el análisis de la recursión.
%
% solo-local: carga signos.pl con ensure_loaded/1.
%
%?- p_correr_caso(factorial, [n-5], R).
%?- p_correr_caso(alcance, [], R).
%?- p_finales_caso(cociente, Fs).
%?- p_resumenes_caso(cociente, Rs).

:- ensure_loaded(signos).

% caso_p(Nombre, Entradas, Bloque): un programa con procedimientos.
caso_p(factorial, [n-entre(0, sup)],
       bloque([ var(r),
                proc(fact, [k],
                     bloque([],
                            [ si("k > 0",
                                 [ "r := r * k",
                                   llamar(fact, ["k - 1"]) ],
                                 []) ])) ],
              [ "r := 1",
                llamar(fact, ["n"]),
                "escribir r" ])).
caso_p(alcance, [],
       bloque([ var(x),
                proc(mostrar, [], bloque([], ["escribir x"])),
                proc(probar, [],
                     bloque([var(x)],
                            [ "x := 2",
                              llamar(mostrar, []) ])) ],
              [ "x := 1",
                llamar(probar, []) ])).
caso_p(cociente, [a-entre(inf, sup)],
       bloque([ var(q),
                proc(dividir, [d], bloque([], ["q := 100 / d"])) ],
              [ si("a > 0",
                   [ llamar(dividir, ["a"]) ],
                   [ llamar(dividir, ["1 - a"]) ]),
                "escribir q" ])).

%!  bloque_caso(?Nombre, -Bloque, -Entradas:list) is nondet.
%
%   Bloque es la sintaxis abstracta del caso Nombre, y Entradas la
%   descripción de sus variables de entrada.
bloque_caso(Nombre, Bloque, Entradas) :-
    caso_p(Nombre, Entradas, Bloque0),
    traducir_bloque(Bloque0, Bloque).

%!  traducir_bloque(+Bloque0, -Bloque) is semidet.
%
%   Bloque es Bloque0 con los textos de Mini leídos con el analizador del
%   capítulo 45. Falla si un texto no es de Mini.
traducir_bloque(bloque(Ds0, Ss0), bloque(Ds, Ss)) :-
    maplist(traducir_declaracion, Ds0, Ds),
    traducir_sentencias(Ss0, Ss).

% traducir_declaracion(D0, D): D es la declaración D0 con su bloque leído.
traducir_declaracion(var(X), var(X)).
traducir_declaracion(proc(N, Ps, B0), proc(N, Ps, B)) :-
    traducir_bloque(B0, B).

%!  traducir_sentencias(+Partes:list, -Ss:list) is semidet.
%
%   Ss son las sentencias de Partes: un texto aporta las sentencias que
%   escribe, y llamar/2, si/3 y mientras/2 llevan sus expresiones y su
%   condición como texto.
traducir_sentencias([], []).
traducir_sentencias([P|Ps], Ss) :-
    traducir_parte(P, Ss0),
    append(Ss0, Ss1, Ss),
    traducir_sentencias(Ps, Ss1).

% traducir_parte(P, Ss): Ss son las sentencias de la parte P.
traducir_parte(Texto, Ss) :-
    string(Texto),
    analizar(Texto, Ss).
traducir_parte(llamar(N, Textos), [llamar(N, Es)]) :-
    maplist(leer_expresion, Textos, Es).
traducir_parte(si(Texto, Si0, No0), [si(C, Si, No)]) :-
    leer_condicion(Texto, C),
    traducir_sentencias(Si0, Si),
    traducir_sentencias(No0, No).
traducir_parte(mientras(Texto, Cuerpo0), [mientras(C, Cuerpo)]) :-
    leer_condicion(Texto, C),
    traducir_sentencias(Cuerpo0, Cuerpo).

% leer_expresion(T, E): E es la expresión de Mini del texto T, la primera
% lectura de la gramática, que es la única.
leer_expresion(Texto, E) :-
    lexico(Texto, Cs),
    once(phrase(expresion(E), Cs)).

% leer_condicion(T, C): C es la condición de Mini del texto T.
leer_condicion(Texto, C) :-
    lexico(Texto, Cs),
    once(phrase(condicion(C), Cs)).

% La pila de registros de activación.

%!  p_registro(+Ds:list, +Cero, +Params:list, -Registro:list) is det.
%
%   Registro es el registro de activación de un bloque con las
%   declaraciones Ds: los pares Params de los parámetros, cada variable
%   declarada con el valor Cero y cada procedimiento con su definición.
p_registro(Ds, Cero, Params, Registro) :-
    phrase(locales(Ds, Cero), Locales),
    append(Params, Locales, Registro).

% locales(Ds, Cero)//: los pares de las declaraciones Ds en el registro.
locales([], _) -->
    [].
locales([D|Ds], Cero) -->
    local(D, Cero),
    locales(Ds, Cero).

% local(D, Cero)//: el par de la declaración D en el registro.
local(var(X), Cero) -->
    [X-Cero].
local(proc(N, Ps, B), _) -->
    [N-proc(Ps, B)].

%!  p_buscar(+X:atom, +Pila:list, -I:integer, -V) is semidet.
%
%   V es el valor del nombre X en el primer registro de Pila que lo
%   declara, el registro I, contado desde 0. Falla si ninguno lo declara.
p_buscar(X, [Registro|Pila], I, V) :-
    (   memberchk(X-V0, Registro)
    ->  I = 0,
        V = V0
    ;   p_buscar(X, Pila, I0, V),
        I is I0 + 1
    ).

%!  p_poner(+X:atom, +V, +Pila0:list, -Pila:list) is semidet.
%
%   Pila es Pila0 con el valor de X cambiado por V en el primer registro
%   que lo declara.
p_poner(X, V, [Registro0|Pila0], [Registro|Pila]) :-
    (   memberchk(X-_, Registro0)
    ->  actualizar(X, V, Registro0, Registro),
        Pila = Pila0
    ;   Registro = Registro0,
        p_poner(X, V, Pila0, Pila)
    ).

%!  p_partir(+I:integer, +Pila:list, -Interiores:list, -Definidor:list)
%!      is det.
%
%   Interiores son los I primeros registros de Pila, y Definidor los
%   demás: la pila del bloque que declaró un procedimiento hallado en el
%   registro I.
p_partir(I, Pila, Interiores, Definidor) :-
    length(Interiores, I),
    append(Interiores, Definidor, Pila).

% El intérprete concreto.

%!  p_correr(+Bloque, +Valores:list, -Resultado) is det.
%
%   Resultado es lo que produce el Bloque principal con las variables de
%   entrada de Valores, pares X-N: fin(Salida, Final), con la salida y las
%   variables del bloque principal, o error(division_por_cero).
p_correr(Bloque, Valores, Resultado) :-
    catch(( once(phrase(p_bloque(Bloque, Valores, [], Registro, []),
                        Salida)),
            variables_de([Registro], Final),
            Resultado = fin(Salida, Final) ),
          error(evaluation_error(zero_divisor), _),
          Resultado = error(division_por_cero)).

%!  p_correr_caso(+Nombre, +Valores:list, -Resultado) is semidet.
%
%   Como p_correr/3, sobre el caso Nombre.
p_correr_caso(Nombre, Valores, Resultado) :-
    bloque_caso(Nombre, Bloque, _),
    p_correr(Bloque, Valores, Resultado).

%!  p_bloque(+Bloque, +Params:list, +Pila0:list, -Registro:list,
%!           -Pila:list)// is nondet.
%
%   Ejecuta Bloque con los parámetros Params sobre la pila Pila0 de los
%   bloques que lo encierran. Registro es su registro al terminar, y Pila
%   la pila Pila0 con los cambios que el bloque hizo en ella.
p_bloque(bloque(Ds, Ss), Params, Pila0, Registro, Pila) -->
    { p_registro(Ds, 0, Params, Registro0) },
    p_sentencias(Ss, [Registro0|Pila0], [Registro|Pila]).

%!  p_sentencias(+Ss:list, +Pila0:list, -Pila:list)// is nondet.
%
%   Ejecuta las sentencias Ss en orden.
p_sentencias([], Pila, Pila) -->
    [].
p_sentencias([S|Ss], Pila0, Pila) -->
    p_sentencia(S, Pila0, Pila1),
    p_sentencias(Ss, Pila1, Pila).

%!  p_sentencia(+S, +Pila0:list, -Pila:list)// is nondet.
%
%   Ejecuta la sentencia S: las de Mini sobre la pila, y llamar/2 sobre la
%   pila del bloque que declaró el procedimiento, con un registro nuevo
%   para sus parámetros y sus declaraciones.
p_sentencia(asignar(X, E), Pila0, Pila) -->
    { p_evaluar(E, Pila0, V),
      p_poner(X, V, Pila0, Pila) }.
p_sentencia(escribir(E), Pila, Pila) -->
    { p_evaluar(E, Pila, V) },
    [V].
p_sentencia(si(C, Si, No), Pila0, Pila) -->
    (   { p_cierta(C, Pila0) }
    ->  p_sentencias(Si, Pila0, Pila)
    ;   p_sentencias(No, Pila0, Pila)
    ).
p_sentencia(mientras(C, Cuerpo), Pila0, Pila) -->
    (   { p_cierta(C, Pila0) }
    ->  p_sentencias(Cuerpo, Pila0, Pila1),
        p_sentencia(mientras(C, Cuerpo), Pila1, Pila)
    ;   { Pila = Pila0 }
    ).
p_sentencia(llamar(N, Args), Pila0, Pila) -->
    { p_buscar(N, Pila0, I, proc(Ps, B)),
      maplist(p_evaluar_en(Pila0), Args, Vs),
      pairs_keys_values(Params, Ps, Vs),
      p_partir(I, Pila0, Interiores, Definidor0) },
    p_bloque(B, Params, Definidor0, _, Definidor),
    { append(Interiores, Definidor, Pila) }.

%!  p_evaluar(+E, +Pila:list, -V:integer) is det.
%
%   V es el valor de la expresión E con los valores de Pila. Produce un
%   error de evaluación si divide por cero.
p_evaluar(num(N), _, N).
p_evaluar(id(X), Pila, V) :-
    p_buscar(X, Pila, _, V).
p_evaluar(bin(Op, A, B), Pila, V) :-
    p_evaluar(A, Pila, X),
    p_evaluar(B, Pila, Y),
    operar(Op, X, Y, V).

% p_evaluar_en(Pila, E, V): p_evaluar/3 con los argumentos en otro orden.
p_evaluar_en(Pila, E, V) :-
    p_evaluar(E, Pila, V).

% p_cierta(C, Pila): la condición C se cumple con los valores de Pila.
p_cierta(rel(Op, A, B), Pila) :-
    p_evaluar(A, Pila, X),
    p_evaluar(B, Pila, Y),
    comparar(Op, X, Y).

%!  variables_de(+Pila:list, -Vs:list) is det.
%
%   Vs son los pares X-V de las variables de Pila, sin los
%   procedimientos, en orden.
variables_de(Pila, Vs) :-
    append(Pila, Pares),
    exclude(es_procedimiento, Pares, Vs).

% es_procedimiento(Par): el par es el de un procedimiento.
es_procedimiento(_-proc(_, _)).

% El análisis de signos, por conjuntos de estados.

:- table a_efecto/3.

%!  a_efecto(+S, +R0, -R) is nondet.
%
%   Ejecutar la sentencia S sobre signos puede llevar el estado R0 a R. Un
%   estado es pila(Pila), con signos en lugar de números, o error.
a_efecto(_, error, error).
a_efecto(asignar(X, E), pila(Pila0), R) :-
    a_valor(E, Pila0, V),
    (   V == error
    ->  R = error
    ;   p_poner(X, V, Pila0, Pila),
        R = pila(Pila)
    ).
a_efecto(escribir(E), pila(Pila), R) :-
    a_valor(E, Pila, V),
    seguir(V, pila(Pila), R).
a_efecto(si(C, Si, _), pila(Pila), R) :-
    a_veredicto(C, Pila, cierta),
    a_efecto_lista(Si, pila(Pila), R).
a_efecto(si(C, _, No), pila(Pila), R) :-
    a_veredicto(C, Pila, falsa),
    a_efecto_lista(No, pila(Pila), R).
a_efecto(mientras(C, Cuerpo), pila(Pila), R) :-
    a_veredicto(C, Pila, cierta),
    a_efecto_lista(Cuerpo, pila(Pila), R1),
    a_efecto(mientras(C, Cuerpo), R1, R).
a_efecto(mientras(C, _), pila(Pila), pila(Pila)) :-
    a_veredicto(C, Pila, falsa).
a_efecto(S, pila(Pila), error) :-
    condicion_de(S, C),
    a_veredicto(C, Pila, error).
a_efecto(llamar(N, Args), pila(Pila0), R) :-
    p_buscar(N, Pila0, I, proc(Ps, B)),
    maplist(a_valor_en(Pila0), Args, Vs),
    (   memberchk(error, Vs)
    ->  R = error
    ;   p_partir(I, Pila0, Interiores, Definidor0),
        a_procedimiento(N, Ps-B, Vs, Definidor0, R1),
        retornar(R1, Interiores, R)
    ).

%!  a_efecto_lista(+Ss:list, +R0, -R) is nondet.
%
%   Ejecutar las sentencias Ss sobre signos puede llevar R0 a R.
a_efecto_lista([], R, R).
a_efecto_lista([S|Ss], R0, R) :-
    a_efecto(S, R0, R1),
    a_efecto_lista(Ss, R1, R).

:- table a_procedimiento/5.

%!  a_procedimiento(+N, +Definicion, +Vs:list, +Definidor0:list, -R)
%!      is nondet.
%
%   Llamar al procedimiento N, con Definicion Parametros-Bloque, con los
%   signos Vs en sus parámetros, sobre la pila Definidor0 del bloque que
%   lo declaró, puede terminar en R: pila(Definidor), esa pila con los
%   cambios del procedimiento, o error. Tabulado, guarda el resumen de N
%   para cada contexto de llamada.
a_procedimiento(_, Ps-bloque(Ds, Ss), Vs, Definidor0, R) :-
    pairs_keys_values(Params, Ps, Vs),
    p_registro(Ds, cero, Params, Registro),
    a_efecto_lista(Ss, pila([Registro|Definidor0]), R0),
    (   R0 = pila([_|Definidor])
    ->  R = pila(Definidor)
    ;   R = error
    ).

% retornar(R1, Interiores, R): R es el estado del llamador después de que
% el procedimiento termina en R1.
retornar(error, _, error).
retornar(pila(Definidor), Interiores, pila(Pila)) :-
    append(Interiores, Definidor, Pila).

%!  a_valor(+E, +Pila:list, -R) is nondet.
%
%   R es un resultado posible de la expresión E con los signos de Pila: un
%   signo o error.
a_valor(num(N), _, S) :-
    signo_de(N, S).
a_valor(id(X), Pila, S) :-
    p_buscar(X, Pila, _, S).
a_valor(bin(Op, A, B), Pila, R) :-
    a_valor(A, Pila, RA),
    a_valor(B, Pila, RB),
    op_signos(Op, RA, RB, R).

% a_valor_en(Pila, E, R): a_valor/3 con los argumentos en otro orden.
a_valor_en(Pila, E, R) :-
    a_valor(E, Pila, R).

% a_veredicto(C, Pila, V): V es un veredicto posible de la condición C.
a_veredicto(rel(Op, A, B), Pila, V) :-
    a_valor(A, Pila, RA),
    a_valor(B, Pila, RB),
    veredicto(Op, RA, RB, V).

%!  p_finales(+Bloque, +Entradas:list, -Finales:list) is det.
%
%   Finales es el conjunto ordenado de los estados en que puede terminar el
%   Bloque principal según el análisis de signos: error, o estado(Vs) con
%   los signos de sus variables.
p_finales(Bloque, Entradas, Finales) :-
    findall(F, ( p_inicial(Bloque, Entradas, R0),
                 Bloque = bloque(_, Ss),
                 a_efecto_lista(Ss, R0, R),
                 final(R, F) ),
            Fs),
    sort(Fs, Finales).

%!  p_finales_caso(+Nombre, -Finales:list) is semidet.
%
%   Como p_finales/3, sobre el caso Nombre con sus entradas.
p_finales_caso(Nombre, Finales) :-
    bloque_caso(Nombre, Bloque, Entradas),
    p_finales(Bloque, Entradas, Finales).

% p_inicial(Bloque, Entradas, R): R es un estado inicial del Bloque, con un
% signo del rango de cada entrada.
p_inicial(bloque(Ds, _), Entradas, pila([Registro])) :-
    findall(X-cero, member(X-_, Entradas), Params0),
    foldl(entrada_signo, Entradas, Params0, Params),
    p_registro(Ds, cero, Params, Registro).

% final(R, F): F es el estado final que se informa para R.
final(error, error).
final(pila(Pila), estado(Vs)) :-
    variables_de(Pila, Vs).

%!  p_resumenes(+Bloque, +Entradas:list, -Resumenes:list) is det.
%
%   Resumenes son los resúmenes de los procedimientos que el análisis de
%   signos llama, ordenados: resumen(N, Vs, Entrada, Salidas) dice que N,
%   llamado con los signos Vs y las variables que ve con los signos de
%   Entrada, termina en Salidas, el conjunto de error y de los signos de
%   esas variables. Los lee de la tabla de a_procedimiento/5, después de
%   borrar todas las tablas y analizar el Bloque.
p_resumenes(Bloque, Entradas, Resumenes) :-
    abolish_all_tables,
    p_finales(Bloque, Entradas, _),
    findall(resumen(N, Vs, Entrada, Salidas),
            ( current_table(_:a_procedimiento(N, D, Vs, Def0, _), _),
              variables_de(Def0, Entrada),
              findall(S, ( a_procedimiento(N, D, Vs, Def0, R),
                           salida(R, S) ),
                      Ss),
              sort(Ss, Salidas) ),
            Resumenes0),
    sort(Resumenes0, Resumenes).

%!  p_resumenes_caso(+Nombre, -Resumenes:list) is semidet.
%
%   Como p_resumenes/3, sobre el caso Nombre con sus entradas.
p_resumenes_caso(Nombre, Resumenes) :-
    bloque_caso(Nombre, Bloque, Entradas),
    p_resumenes(Bloque, Entradas, Resumenes).

% salida(R, S): S es lo que el resumen informa del estado R.
salida(error, error).
salida(pila(Pila), Vs) :-
    variables_de(Pila, Vs).
