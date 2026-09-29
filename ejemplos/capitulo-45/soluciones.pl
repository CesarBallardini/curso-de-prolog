:- encoding(utf8).

% Capítulo 45 - Soluciones de los ejercicios 2 a 7, 9, 10 y 12.
%
% Las extensiones del lenguaje (ejercicios 2, 3 y 4) agregan cláusulas a
% predicados de los archivos del capítulo. Para que dos archivos definan
% cláusulas del mismo predicado, este archivo lo declara multifile antes de
% cargar compilador.pl; las cláusulas nuevas quedan después de las
% originales.
%
% solo-local: carga compilador.pl con ensure_loaded/1.
%
%?- ejecutar("x := -3 * 2; escribir 2 - -x", S).
%?- fuente_repetir(T), ejecutar(T, S), correr(T, S).
%?- analizar("x := a + (b + (c + d))", P), a_texto(P, T).

:- multifile
    factor//1,
    reservada/1,
    sentencia//1,
    ejecutar_sentencia//3,
    codigo_sentencia//1,
    paso//3,
    clase/2.

:- ensure_loaded(compilador).

% Ejercicio 2: el menos unario, como una resta desde 0.
factor(bin(-, num(0), F)) -->
    [-],
    factor(F).

% Ejercicio 3: repetir Bloque hasta Condicion.
reservada(repetir).
reservada(hasta).

sentencia(repetir(Cuerpo, C)) -->
    [repetir],
    bloque(Cuerpo),
    [hasta],
    condicion(C).

% El intérprete ejecuta el cuerpo una vez y sigue como un mientras con la
% condición contraria.
ejecutar_sentencia(repetir(Cuerpo, rel(Op, A, B)), E0, E) -->
    { contraria(Op, No) },
    ejecutar_bloque(Cuerpo, E0, E1),
    ejecutar_sentencia(mientras(rel(No, A, B), Cuerpo), E1, E).

% El generador pone la condición al final: si no se cumple, vuelve.
codigo_sentencia(repetir(Cuerpo, C)) -->
    [etiqueta(Inicio)],
    codigo_bloque(Cuerpo),
    codigo_condicion(C),
    [saltar_si_cero(Inicio)].

%!  fuente_repetir(-Texto:string) is det.
%
%   El programa de prueba del ejercicio: escribe de 1 a 10.
fuente_repetir("i := 1;
repetir
  escribir i;
  i := i + 1
hasta i = 11").

% Ejercicio 4: saltar_si_no(Op, D) compara los dos valores del tope y salta
% a D si la comparación Op no se cumple.
clase(saltar_si_no(_, _), fija).

paso(saltar_si_no(Op, D), s(PC, [Y, X|P], M), s(PC1, P, M)) -->
    {   comparar(Op, X, Y)
    ->  PC1 is PC + 1
    ;   PC1 = D
    }.

%!  modismo_fusion(+Codigo0:list, -Codigo:list) is semidet.
%
%   Los modismos de modismo/2, y una comparación seguida de un salto si
%   cero reemplazada por un salto si la comparación no se cumple.
modismo_fusion([comparar(Op), saltar_si_cero(L)|R], [saltar_si_no(Op, L)|R]).
modismo_fusion(Codigo0, Codigo) :-
    modismo(Codigo0, Codigo).

%!  compilar_fusion(+Texto, -Objeto:list) is semidet.
%
%   Como compilar_optimizado/2, con modismo_fusion/2 en la mirilla.
compilar_fusion(Texto, Objeto) :-
    analizar(Texto, Programa0),
    optimizar(Programa0, Programa),
    generar(Programa, Simbolico0),
    mirilla(modismo_fusion, Simbolico0, Simbolico),
    ensamblar(Simbolico, Objeto, _).

% Ejercicio 5: la máquina que cuenta los pasos y la pila máxima.

%!  maquina_medida(+Objeto, -Salida, -Pasos, -Maxima) is det.
%
%   Como maquina/2; Pasos es la cantidad de instrucciones ejecutadas y
%   Maxima la mayor cantidad de valores que tuvo la pila.
maquina_medida(Objeto, Salida, Pasos, Maxima) :-
    compound_name_arguments(Codigo, codigo, Objeto),
    empty_assoc(Memoria),
    phrase(ciclo_medido(Codigo, s(0, [], Memoria), 0-0, Pasos-Maxima),
           Salida).

%!  ciclo_medido(+Codigo, +Estado, +Medida0, -Medida)// is det.
%
%   Como ciclo//2; Medida0 y Medida son pares Pasos-Maxima, antes y al
%   terminar.
ciclo_medido(Codigo, s(PC, P, M), N0-H0, Medida) -->
    (   { K is PC + 1,
          arg(K, Codigo, I) }
    ->  paso(I, s(PC, P, M), s(PC1, P1, M1)),
        { N1 is N0 + 1,
          length(P1, Altura),
          H1 is max(H0, Altura) },
        ciclo_medido(Codigo, s(PC1, P1, M1), N1-H1, Medida)
    ;   { Medida = N0-H0 }
    ).

%!  medir_ejemplo(+Nombre, :Compilar, -N, -Pasos, -Maxima) is semidet.
%
%   Compila el programa de ejemplo Nombre con call(Compilar, Texto,
%   Objeto): N es la cantidad de instrucciones de Objeto, y Pasos y Maxima
%   las de maquina_medida/4 al ejecutarlo.
medir_ejemplo(Nombre, Compilar, N, Pasos, Maxima) :-
    fuente_ejemplo(Nombre, Texto),
    call(Compilar, Texto, Objeto),
    length(Objeto, N),
    maquina_medida(Objeto, _, Pasos, Maxima).

% Ejercicio 6: las comparaciones también se reordenan, con la relación
% espejada.

%!  reordenar_condiciones(+Programa0:list, -Programa:list) is det.
%
%   Programa es Programa0 con las expresiones reordenadas y, en cada
%   condición, el lado que más pila necesita primero.
reordenar_condiciones(Ss0, Ss) :-
    maplist(condiciones_sentencia, Ss0, Ss).

condiciones_sentencia(asignar(X, E0), asignar(X, E)) :-
    reordenar_expresion(E0, E).
condiciones_sentencia(escribir(E0), escribir(E)) :-
    reordenar_expresion(E0, E).
condiciones_sentencia(si(C0, Si0, No0), si(C, Si, No)) :-
    condicion_reordenada(C0, C),
    reordenar_condiciones(Si0, Si),
    reordenar_condiciones(No0, No).
condiciones_sentencia(mientras(C0, Cuerpo0), mientras(C, Cuerpo)) :-
    condicion_reordenada(C0, C),
    reordenar_condiciones(Cuerpo0, Cuerpo).

%!  condicion_reordenada(+C0, -C) is det.
%
%   C es la condición C0 con sus lados reordenados y, si el derecho
%   necesita más pila, intercambiados, con la relación espejada.
condicion_reordenada(rel(Op, A0, B0), C) :-
    reordenar(A0, A, NA),
    reordenar(B0, B, NB),
    (   NB > NA
    ->  espejo(Op, Op1),
        C = rel(Op1, B, A)
    ;   C = rel(Op, A, B)
    ).

% espejo(Op, Op1): A Op B se cumple si y solo si B Op1 A se cumple.
espejo(=, =).
espejo(<>, <>).
espejo(<, >).
espejo(>, <).
espejo(<=, >=).
espejo(>=, <=).

%!  pila_condicion(+C, -N:integer) is det.
%
%   N es la pila que necesita la máquina para evaluar la condición C.
pila_condicion(rel(_, A, B), N) :-
    pila(A, NA),
    pila(B, NB),
    N is max(NA, NB + 1).

% Ejercicio 7: reasociar para que las constantes de una suma queden juntas.

%!  plegar_asociando(+E0, -E) is det.
%
%   Como plegar_expresion/2, pero antes de simplificar agrupa las
%   constantes de las sumas y restas encadenadas: (X + A) + B pasa a
%   X + (A + B).
plegar_asociando(E0, E) :-
    a_termino(E0, T0),
    simplificar(T0, T1),
    reasociar(T1, T2),
    simplificar(T2, T),
    de_termino(T, E).

%!  reasociar(+T0, -T) is det.
%
%   T es la expresión de Prolog T0 con regla_asociar/2 aplicada de abajo
%   hacia arriba, hasta que no se aplica en ningún nodo.
reasociar(T0, T) :-
    (   compound(T0)
    ->  mapargs(reasociar, T0, T1)
    ;   T1 = T0
    ),
    (   regla_asociar(T1, T2)
    ->  reasociar(T2, T)
    ;   T = T1
    ).

%!  regla_asociar(+T0, -T) is semidet.
%
%   T es T0 con dos constantes de una suma o resta encadenada sumadas.
regla_asociar((X + A) + B, X + C) :-
    number(A),
    number(B),
    C is A + B.
regla_asociar((X + A) - B, X + C) :-
    number(A),
    number(B),
    C is A - B.
regla_asociar((X - A) + B, X + C) :-
    number(A),
    number(B),
    C is B - A.
regla_asociar((X - A) - B, X - C) :-
    number(A),
    number(B),
    C is A + B.

% Ejercicio 9: las marcas que ningún salto usa se quitan.

%!  mirilla_completa(+Codigo0:list, -Codigo:list) is det.
%
%   Codigo es Codigo0 pasado por la mirilla y sin las marcas de etiquetas
%   que ningún salto usa, repetido hasta que no cambia.
mirilla_completa(Codigo0, Codigo) :-
    mirilla(Codigo0, Codigo1),
    quitar_marcas(Codigo1, Codigo2),
    (   Codigo2 == Codigo1
    ->  Codigo = Codigo1
    ;   mirilla_completa(Codigo2, Codigo)
    ).

%!  quitar_marcas(+Codigo0:list, -Codigo:list) is det.
%
%   Codigo es Codigo0 sin las marcas de etiquetas que ninguna instrucción
%   de Codigo0 usa como destino.
quitar_marcas(Codigo0, Codigo) :-
    exclude(marca_sin_uso(Codigo0), Codigo0, Codigo).

%!  marca_sin_uso(+Codigo:list, +I) is semidet.
%
%   I es una marca de una etiqueta que ningún salto de Codigo usa.
marca_sin_uso(Codigo, etiqueta(L)) :-
    \+ ( member(I, Codigo),
         destino(I, D),
         D == L ).

% destino(I, D): la instrucción I salta a la etiqueta D.
destino(saltar(D), D).
destino(saltar_si_cero(D), D).

% Ejercicio 10: de la sintaxis abstracta al texto.

%!  a_texto(+Programa:list, -Texto:atom) is det.
%
%   Texto es un texto de Programa que analizar/2 lee como Programa: las
%   sentencias separadas por punto y coma y cada expresión con los
%   paréntesis que su forma necesita. Los números deben ser naturales, como
%   los que produce analizar/2.
a_texto(Programa, Texto) :-
    bloque_texto(Programa, Texto).

bloque_texto(Ss, Texto) :-
    maplist(sentencia_texto, Ss, Ts),
    atomic_list_concat(Ts, '; ', Texto).

sentencia_texto(asignar(X, E), T) :-
    expresion_texto(E, 1, TE),
    format(atom(T), "~w := ~w", [X, TE]).
sentencia_texto(escribir(E), T) :-
    expresion_texto(E, 1, TE),
    format(atom(T), "escribir ~w", [TE]).
sentencia_texto(si(C, Si, No), T) :-
    condicion_texto(C, TC),
    bloque_texto(Si, TSi),
    (   No == []
    ->  format(atom(T), "si ~w entonces ~w fin", [TC, TSi])
    ;   bloque_texto(No, TNo),
        format(atom(T), "si ~w entonces ~w sino ~w fin", [TC, TSi, TNo])
    ).
sentencia_texto(mientras(C, Cuerpo), T) :-
    condicion_texto(C, TC),
    bloque_texto(Cuerpo, TB),
    format(atom(T), "mientras ~w hacer ~w fin", [TC, TB]).

condicion_texto(rel(Op, A, B), T) :-
    expresion_texto(A, 1, TA),
    expresion_texto(B, 1, TB),
    format(atom(T), "~w ~w ~w", [TA, Op, TB]).

%!  expresion_texto(+E, +Minima:integer, -T:atom) is det.
%
%   T es el texto de la expresión E; va entre paréntesis si la precedencia
%   de su operador es menor que Minima. El operando derecho exige una
%   precedencia mayor que la del operador, porque se agrupa a la
%   izquierda: a - (b - c) necesita los paréntesis.
expresion_texto(num(N), _, N).
expresion_texto(id(X), _, X).
expresion_texto(bin(Op, A, B), Minima, T) :-
    precedencia(Op, P),
    expresion_texto(A, P, TA),
    P1 is P + 1,
    expresion_texto(B, P1, TB),
    format(atom(T0), "~w ~w ~w", [TA, Op, TB]),
    (   P < Minima
    ->  format(atom(T), "(~w)", [T0])
    ;   T = T0
    ).

% precedencia(Op, P): el operador Op agrupa con precedencia P; mayor
% precedencia agrupa antes.
precedencia(+, 1).
precedencia(-, 1).
precedencia(*, 2).
precedencia(/, 2).

% Ejercicio 12: subexpresiones comunes, con un diccionario incompleto.

%!  compartir(+Programa0:list, -Programa:list) is det.
%
%   Programa es Programa0 con cada subexpresión compuesta que aparece más
%   de una vez en una asignación o un escribir calculada una sola vez, en
%   una variable nueva t_1, t_2, ... asignada antes. Supone que el programa
%   no usa esos nombres.
compartir(Ss0, Ss) :-
    compartir(Ss0, 1, _, Ss).

%!  compartir(+Ss0:list, +N0:integer, -N:integer, -Ss:list) is det.
%
%   Como compartir/2; N0 es el número de la primera variable nueva y N el
%   de la siguiente a la última usada.
compartir([], N, N, []).
compartir([S0|Ss0], N0, N, Ss) :-
    compartir_sentencia(S0, N0, N1, Ss1),
    compartir(Ss0, N1, N, Ss2),
    append(Ss1, Ss2, Ss).

compartir_sentencia(asignar(X, E0), N0, N, Ss) :-
    compartir_expresion(E0, N0, N, Temporales, E),
    append(Temporales, [asignar(X, E)], Ss).
compartir_sentencia(escribir(E0), N0, N, Ss) :-
    compartir_expresion(E0, N0, N, Temporales, E),
    append(Temporales, [escribir(E)], Ss).
compartir_sentencia(si(C, Si0, No0), N0, N, [si(C, Si, No)]) :-
    compartir(Si0, N0, N1, Si),
    compartir(No0, N1, N, No).
compartir_sentencia(mientras(C, Cuerpo0), N0, N, [mientras(C, Cuerpo)]) :-
    compartir(Cuerpo0, N0, N, Cuerpo).

%!  compartir_expresion(+E0, +N0, -N, -Temporales, -E) is det.
%
%   E es E0 con cada subexpresión repetida reemplazada por una variable
%   nueva; Temporales son las asignaciones de esas variables, las internas
%   primero. El diccionario incompleto (buscar/3 del capítulo 34) asocia
%   cada subexpresión repetida con su nombre y su definición: la primera
%   aparición la agrega, las siguientes la encuentran.
compartir_expresion(E0, N0, N, Temporales, E) :-
    repetidas(E0, Repetidas),
    reemplazar(E0, Repetidas, Dic, E),
    definiciones(Dic, N0, N, Temporales).

%!  repetidas(+E, -Repetidas:list) is det.
%
%   Repetidas son las subexpresiones compuestas de E que aparecen más de
%   una vez.
repetidas(E, Repetidas) :-
    findall(S, ( sub_term(S, E), S = bin(_, _, _) ), Ss0),
    msort(Ss0, Ss),
    clumped(Ss, Pares),
    findall(S, ( member(S-K, Pares), K > 1 ), Repetidas).

%!  reemplazar(+E0, +Repetidas:list, ?Dic, -E) is det.
%
%   E es E0 con cada subexpresión de Repetidas reemplazada, de abajo hacia
%   arriba, por id(Nombre), con Nombre libre hasta definiciones/4. Dic es
%   el diccionario incompleto de pares Subexpresion-t(Nombre, Cuerpo).
reemplazar(num(N), _, _, num(N)).
reemplazar(id(X), _, _, id(X)).
reemplazar(bin(Op, A0, B0), Repetidas, Dic, E) :-
    reemplazar(A0, Repetidas, Dic, A),
    reemplazar(B0, Repetidas, Dic, B),
    Nodo = bin(Op, A, B),
    (   memberchk(bin(Op, A0, B0), Repetidas)
    ->  buscar(bin(Op, A0, B0), Dic, t(Nombre, Nodo)),
        E = id(Nombre)
    ;   E = Nodo
    ).

%!  definiciones(?Dic, +N0:integer, -N:integer, -Temporales:list) is det.
%
%   Da nombre a las entradas del diccionario incompleto Dic, en orden,
%   desde t_N0, y Temporales son sus asignaciones.
definiciones(Dic, N, N, []) :-
    var(Dic),
    !.
definiciones([_-t(Nombre, Cuerpo)|Dic], N0, N, [asignar(Nombre, Cuerpo)|Ts]) :-
    format(atom(Nombre), "t_~w", [N0]),
    N1 is N0 + 1,
    definiciones(Dic, N1, N, Ts).
