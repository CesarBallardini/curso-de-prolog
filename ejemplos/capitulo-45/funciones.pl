:- encoding(utf8).

% Capítulo 45 - Funciones y marcos de pila.
%
% El compilador de Triska («Thinking in States») traduce un lenguaje con
% funciones recursivas a una máquina de pila con call y ret. Este archivo
% agrega a Mini definiciones de funciones antes del programa:
%
%     funcion fac(n)
%       si n <= 1 entonces devolver 1 fin;
%       devolver n * fac(n - 1)
%     fin;
%     escribir fac(5)
%
% Las variables de una función son locales: sus parámetros y las que
% asigna. Cada llamada tiene un marco con sus valores y la dirección de
% retorno, y los marcos forman una pila aparte de la de los valores. La
% máquina recibe cuatro instrucciones: llamar(D, N) toma los N argumentos
% de la pila de valores y apila un marco nuevo; volver deja el valor
% devuelto en la pila y quita el marco; cargar_local(I) y guardar_local(I)
% usan la variable local número I del marco del tope. Una función que
% termina sin devolver devuelve 0. Una función no ve las variables del
% programa principal.
%
% solo-local: carga maquina.pl con ensure_loaded/1.
%
%?- analizar_funciones("funcion doble(x) devolver 2 * x fin; escribir doble(4)", P).
%?- correr_funciones("funcion doble(x) devolver 2 * x fin; escribir doble(4)", S).
%?- fuente_funciones(factorial, T), correr_funciones(T, S).

:- ensure_loaded(maquina).

:- multifile
    reservada/1,
    simbolo//1,
    sentencia//1,
    factor//1,
    codigo_sentencia//1,
    codigo_expresion//1,
    clase/2.

% Las palabras reservadas, la coma, la sentencia devolver y la llamada.
reservada(funcion).
reservada(devolver).

simbolo(',') -->
    ",".

sentencia(devolver(E)) -->
    [devolver],
    expresion(E).

factor(llamada(F, Args)) -->
    [id(F), '('],
    argumentos(Args),
    [')'].

%!  analizar_funciones(+Texto, -Programa) is semidet.
%
%   Programa es programa(Funciones, Sentencias), la sintaxis abstracta del
%   programa con funciones de Texto. Falla si Texto no es un programa.
analizar_funciones(Texto, programa(Fs, Ss)) :-
    lexico(Texto, Componentes),
    phrase(programa_con_funciones(Fs, Ss), Componentes),
    !.

%!  programa_con_funciones(?Fs:list, ?Ss:list)// is nondet.
%
%   Las definiciones Fs, cada una seguida de punto y coma, y después el
%   bloque Ss del programa principal.
programa_con_funciones([F|Fs], Ss) -->
    definicion(F),
    [;],
    programa_con_funciones(Fs, Ss).
programa_con_funciones([], Ss) -->
    bloque(Ss).

%!  definicion(?F)// is nondet.
%
%   Una definición funcion(Nombre, Parametros, Cuerpo).
definicion(funcion(F, Ps, Cuerpo)) -->
    [funcion, id(F), '('],
    parametros(Ps),
    [')'],
    bloque(Cuerpo),
    [fin].

%!  parametros(?Ps:list)// is nondet.
%
%   Nombres separados por comas, posiblemente ninguno.
parametros([P|Ps]) -->
    [id(P)],
    mas_parametros(Ps).
parametros([]) -->
    [].

mas_parametros([P|Ps]) -->
    [',', id(P)],
    mas_parametros(Ps).
mas_parametros([]) -->
    [].

%!  argumentos(?As:list)// is nondet.
%
%   Expresiones separadas por comas, posiblemente ninguna.
argumentos([A|As]) -->
    expresion(A),
    mas_argumentos(As).
argumentos([]) -->
    [].

mas_argumentos([A|As]) -->
    [','],
    expresion(A),
    mas_argumentos(As).
mas_argumentos([]) -->
    [].

% El código de la llamada y de devolver.
codigo_expresion(llamada(F, Args)) -->
    codigo_argumentos(Args),
    { length(Args, N) },
    [llamar(F, N)].

codigo_sentencia(devolver(E)) -->
    codigo_expresion(E),
    [volver].

%!  codigo_argumentos(+Args:list)// is det.
%
%   El código que apila los valores de Args, el primero abajo.
codigo_argumentos([]) -->
    [].
codigo_argumentos([A|As]) -->
    codigo_expresion(A),
    codigo_argumentos(As).

% Las instrucciones nuevas no nombran celdas de la memoria.
clase(llamar(_, _), fija).
clase(volver, fija).
clase(cargar_local(_), fija).
clase(guardar_local(_), fija).

%!  compilar_funciones(+Texto, -Objeto:list) is semidet.
%
%   Objeto es el código ensamblado del programa con funciones de Texto: el
%   programa principal, un salto al final, y el código de cada función.
%   Falla si Texto no es un programa, o si llama a una función que no
%   está definida o con otra cantidad de argumentos.
compilar_funciones(Texto, Objeto) :-
    analizar_funciones(Texto, programa(Fs, Ss)),
    maplist(entrada_funcion, Fs, Tabla),
    generar(Ss, Principal0),
    resolver_llamadas(Tabla, Principal0, Principal),
    maplist(codigo_funcion(Tabla), Fs, Codigos),
    append([Principal, [saltar(Fin)] | Codigos], Simbolico0),
    append(Simbolico0, [etiqueta(Fin)], Simbolico),
    ensamblar(Simbolico, Objeto, _).

%!  entrada_funcion(+F, -Entrada) is det.
%
%   Entrada es Nombre-Etiqueta-Aridad para la definición F, con una
%   etiqueta nueva para su primera instrucción.
entrada_funcion(funcion(F, Ps, _), F-_-N) :-
    length(Ps, N).

%!  codigo_funcion(+Tabla:list, +F, -Codigo:list) is semidet.
%
%   Codigo es el código simbólico de la definición F: la marca de su
%   etiqueta, el cuerpo con las variables locales, y devolver 0.
codigo_funcion(Tabla, funcion(F, Ps, Cuerpo), Codigo) :-
    memberchk(F-Etiqueta-_, Tabla),
    generar(Cuerpo, Codigo0),
    locales(Ps, Cuerpo, Locales),
    maplist(localizar(Locales), Codigo0, Codigo1),
    resolver_llamadas(Tabla, Codigo1, Codigo2),
    append([[etiqueta(Etiqueta)], Codigo2, [apilar(0), volver]], Codigo).

%!  locales(+Ps:list, +Cuerpo:list, -Locales:list) is det.
%
%   Locales son las variables locales de una función: los parámetros Ps,
%   en su orden, y después las demás variables de Cuerpo.
locales(Ps, Cuerpo, Locales) :-
    variables(Cuerpo, Vs),
    subtract(Vs, Ps, Otras),
    append(Ps, Otras, Locales).

%!  localizar(+Locales:list, +I0, -I) is det.
%
%   I es la instrucción I0 con la variable que nombra reemplazada por su
%   número entre Locales.
localizar(Locales, I0, I) :-
    (   I0 = cargar(X)
    ->  once(nth0(N, Locales, X)),
        I = cargar_local(N)
    ;   I0 = guardar(X)
    ->  once(nth0(N, Locales, X)),
        I = guardar_local(N)
    ;   I = I0
    ).

%!  resolver_llamadas(+Tabla:list, +Codigo0:list, -Codigo:list) is semidet.
%
%   Codigo es Codigo0 con cada llamar(Nombre, N) reemplazado por
%   llamar(Etiqueta, N). Falla si la función no está en Tabla con aridad N.
resolver_llamadas(Tabla, Codigo0, Codigo) :-
    maplist(resolver_llamada(Tabla), Codigo0, Codigo).

%!  resolver_llamada(+Tabla:list, +I0, -I) is semidet.
%
%   I es la instrucción I0, con la etiqueta de la función si es llamar/2.
resolver_llamada(Tabla, I0, I) :-
    (   I0 = llamar(F, N)
    ->  memberchk(F-Etiqueta-Aridad, Tabla),
        N =:= Aridad,
        I = llamar(Etiqueta, N)
    ;   I = I0
    ).

%!  correr_funciones(+Texto, -Salida:list(integer)) is semidet.
%
%   Salida es lo que escribe el programa con funciones de Texto, compilado
%   y ejecutado en la máquina.
correr_funciones(Texto, Salida) :-
    compilar_funciones(Texto, Objeto),
    maquina_funciones(Objeto, Salida).

%!  maquina_funciones(+Objeto:list, -Salida:list(integer)) is semidet.
%
%   Como maquina/2, con una pila de marcos, vacía al empezar. Falla si
%   el código ejecuta volver sin un marco.
maquina_funciones(Objeto, Salida) :-
    compound_name_arguments(Codigo, codigo, Objeto),
    empty_assoc(Memoria),
    phrase(ciclo_funciones(Codigo, f(s(0, [], Memoria), [])), Salida).

%!  ciclo_funciones(+Codigo, +Estado)// is semidet.
%
%   Como ciclo//2, con el estado f(S, Marcos): S es el estado de la
%   máquina de pila y Marcos la pila de marcos, el del tope primero.
ciclo_funciones(Codigo, f(s(PC, P, M), Marcos)) -->
    (   { N is PC + 1,
          arg(N, Codigo, I) }
    ->  paso_funciones(I, f(s(PC, P, M), Marcos), Estado),
        ciclo_funciones(Codigo, Estado)
    ;   []
    ).

%!  paso_funciones(+I, +Estado0, -Estado)// is semidet.
%
%   Ejecutar la instrucción I lleva la máquina de Estado0 a Estado. Las
%   instrucciones de la máquina de pila no tocan los marcos. Un marco es
%   marco(Locales, Retorno): un árbol AVL del número de cada variable local
%   a su valor, y la dirección a la que vuelve la llamada.
paso_funciones(llamar(D, N), f(s(PC, P0, M), Ms),
               f(s(D, P, M), [marco(Locales, Retorno)|Ms])) -->
    !,
    { length(Invertidos, N),
      append(Invertidos, P, P0),
      reverse(Invertidos, Args),
      findall(I-A, nth0(I, Args, A), Pares),
      list_to_assoc(Pares, Locales),
      Retorno is PC + 1 }.
paso_funciones(volver, f(s(_, [V|P], M), [marco(_, Retorno)|Ms]),
               f(s(Retorno, [V|P], M), Ms)) -->
    !.
paso_funciones(cargar_local(I), f(s(PC, P, M), [marco(L, R)|Ms]),
               f(s(PC1, [V|P], M), [marco(L, R)|Ms])) -->
    !,
    { PC1 is PC + 1,
      (   get_assoc(I, L, V0)
      ->  V = V0
      ;   V = 0
      ) }.
paso_funciones(guardar_local(I), f(s(PC, [V|P], M), [marco(L0, R)|Ms]),
               f(s(PC1, P, M), [marco(L, R)|Ms])) -->
    !,
    { PC1 is PC + 1,
      put_assoc(I, L0, V, L) }.
paso_funciones(I, f(S0, Ms), f(S, Ms)) -->
    paso(I, S0, S).

%!  fuente_funciones(?Nombre, -Texto:atom) is nondet.
%
%   Texto es el programa con funciones Nombre.
fuente_funciones(Nombre, Texto) :-
    fuente_f(Nombre, Lineas),
    atomic_list_concat(Lineas, '\n', Texto).

% fuente_f(Nombre, Lineas): el texto de un programa con funciones, por
% líneas.
fuente_f(factorial, [ "funcion fac(n)",
                      "  si n <= 1 entonces devolver 1 fin;",
                      "  devolver n * fac(n - 1)",
                      "fin;",
                      "escribir fac(5)" ]).
fuente_f(iterativo, [ "funcion fac(n)",
                      "  f := 1;",
                      "  mientras n > 1 hacer f := f * n; n := n - 1 fin;",
                      "  devolver f",
                      "fin;",
                      "n := 4; escribir fac(n); escribir n" ]).
fuente_f(fibonacci, [ "funcion fib(n)",
                      "  si n < 2 entonces devolver n fin;",
                      "  devolver fib(n - 1) + fib(n - 2)",
                      "fin;",
                      "i := 0;",
                      "mientras i < 8 hacer escribir fib(i); i := i + 1 fin" ]).
fuente_f(paridad, [ "funcion par(n)",
                    "  si n = 0 entonces devolver 1 fin;",
                    "  devolver impar(n - 1)",
                    "fin;",
                    "funcion impar(n)",
                    "  si n = 0 entonces devolver 0 fin;",
                    "  devolver par(n - 1)",
                    "fin;",
                    "escribir par(10); escribir impar(7); escribir par(3)" ]).
fuente_f(mcd, [ "funcion mcd(a, b)",
                "  si b = 0 entonces devolver a fin;",
                "  devolver mcd(b, a - a / b * b)",
                "fin;",
                "escribir mcd(84, 36)" ]).
