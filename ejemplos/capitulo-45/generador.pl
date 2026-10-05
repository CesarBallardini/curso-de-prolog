:- encoding(utf8).

% Capítulo 45 - Versión 3: la generación de código para una máquina de pila
% y el ensamblador.
%
% generar/2 traduce la sintaxis abstracta a código simbólico: instrucciones
% de una máquina de pila que nombran las variables de Mini por su nombre y
% marcan los destinos de los saltos con etiqueta(L). Cada etiqueta es una
% variable nueva de Prolog, que no se confunde con ninguna otra. ensamblar/3
% quita las marcas y liga cada etiqueta a su dirección por unificación, en
% una sola pasada; las variables de Mini reciben un número de celda con la
% tabla de símbolos del capítulo 34, un diccionario incompleto (buscar/3 y
% numerar/2 de diccionario.pl).
%
% solo-local: carga sintaxis.pl y diccionario.pl del capítulo 34 con
% ensure_loaded/1.
%
%?- analizar("x := 2 * x + 1", P), generar(P, C).
%?- codigo_ejemplo(cuenta, C).
%?- compilar("mientras x < 3 hacer x := x + 1 fin", C).
%?- listar_objeto("x := 1; escribir x").

:- ensure_loaded(sintaxis).
:- ensure_loaded('../capitulo-34/diccionario').

% El código de las sentencias y de las expresiones, y las clases de las
% instrucciones, son multifile: otros archivos agregan construcciones e
% instrucciones.
:- multifile
    codigo_sentencia//1,
    codigo_expresion//1,
    clase/2.

%!  compilar(+Texto, -Objeto:list) is semidet.
%
%   Objeto es el código ensamblado del programa Mini de Texto. Falla si
%   Texto no es un programa Mini.
compilar(Texto, Objeto) :-
    analizar(Texto, Programa),
    generar(Programa, Simbolico),
    ensamblar(Simbolico, Objeto, _).

%!  generar(+Programa:list, -Codigo:list) is det.
%
%   Codigo es el código simbólico de Programa para la máquina de pila.
generar(Programa, Codigo) :-
    phrase(codigo_bloque(Programa), Codigo).

%!  codigo_bloque(+Ss:list)// is det.
%
%   El código de las sentencias Ss, una después de otra.
codigo_bloque([]) -->
    [].
codigo_bloque([S|Ss]) -->
    codigo_sentencia(S),
    codigo_bloque(Ss).

%!  codigo_sentencia(+S)// is det.
%
%   El código de la sentencia S. Las etiquetas Sino, Fin e Inicio son
%   variables nuevas en cada uso de la cláusula.
codigo_sentencia(asignar(X, E)) -->
    codigo_expresion(E),
    [guardar(X)].
codigo_sentencia(escribir(E)) -->
    codigo_expresion(E),
    [escribir].
codigo_sentencia(si(C, Si, No)) -->
    codigo_condicion(C),
    [saltar_si_cero(Sino)],
    codigo_bloque(Si),
    [saltar(Fin), etiqueta(Sino)],
    codigo_bloque(No),
    [etiqueta(Fin)].
codigo_sentencia(mientras(C, Cuerpo)) -->
    [etiqueta(Inicio)],
    codigo_condicion(C),
    [saltar_si_cero(Fin)],
    codigo_bloque(Cuerpo),
    [saltar(Inicio), etiqueta(Fin)].

%!  codigo_condicion(+C)// is det.
%
%   El código que deja en la pila 1 si la condición C se cumple, 0 si no.
codigo_condicion(rel(Op, A, B)) -->
    codigo_expresion(A),
    codigo_expresion(B),
    [comparar(Op)].

%!  codigo_expresion(+E)// is det.
%
%   El código que deja en la pila el valor de la expresión E: primero el
%   operando izquierdo, después el derecho, después la operación.
codigo_expresion(num(N)) -->
    [apilar(N)].
codigo_expresion(id(X)) -->
    [cargar(X)].
codigo_expresion(bin(Op, A, B)) -->
    codigo_expresion(A),
    codigo_expresion(B),
    { aritmetica(Op, I) },
    [I].

% aritmetica(Op, I): la instrucción I hace la operación Op de Mini.
aritmetica(+, sumar).
aritmetica(-, restar).
aritmetica(*, multiplicar).
aritmetica(/, dividir).

%!  ensamblar(+Simbolico:list, -Objeto:list, -Tabla:list) is semidet.
%
%   Objeto es Simbolico sin las marcas de etiqueta, con cada etiqueta ligada
%   a la dirección de la instrucción que sigue a su marca, contando desde
%   0, y cada variable de Mini reemplazada por su celda. Tabla es el
%   diccionario incompleto de las celdas, numeradas desde 0 en el orden de
%   aparición. Liga las etiquetas también en Simbolico. Falla si una
%   etiqueta se marca en dos direcciones distintas.
ensamblar(Simbolico, Objeto, Tabla) :-
    phrase(objeto(Simbolico, 0, Tabla), Objeto),
    numerar(Tabla, 0).

%!  objeto(+Simbolico:list, +Dir:integer, ?Tabla)// is semidet.
%
%   El código objeto de Simbolico, cuya primera instrucción va en Dir.
objeto([], _, _) -->
    [].
objeto([I|Is], Dir, Tabla) -->
    { clase(I, Clase) },
    ensamblar_instruccion(Clase, I, Dir, Dir1, Tabla),
    objeto(Is, Dir1, Tabla).

%!  ensamblar_instruccion(+Clase, +I, +Dir, -Dir1, ?Tabla)// is semidet.
%
%   El código objeto de la instrucción I, de la clase Clase, en la
%   dirección Dir; Dir1 es la dirección de la siguiente. Una marca no ocupa
%   lugar: su etiqueta se liga a Dir.
ensamblar_instruccion(marca, etiqueta(Dir), Dir, Dir, _) -->
    [].
ensamblar_instruccion(memoria, I, Dir, Dir1, Tabla) -->
    { I =.. [Nombre, X],
      buscar(X, Tabla, Celda),
      I1 =.. [Nombre, Celda],
      Dir1 is Dir + 1 },
    [I1].
ensamblar_instruccion(fija, I, Dir, Dir1, _) -->
    [I],
    { Dir1 is Dir + 1 }.

% clase(I, Clase): la instrucción I es una marca, usa la memoria o se copia
% tal cual. Es la lista de las instrucciones de la máquina.
clase(etiqueta(_), marca).
clase(cargar(_), memoria).
clase(guardar(_), memoria).
clase(apilar(_), fija).
clase(sumar, fija).
clase(restar, fija).
clase(multiplicar, fija).
clase(dividir, fija).
clase(comparar(_), fija).
clase(escribir, fija).
clase(saltar(_), fija).
clase(saltar_si_cero(_), fija).

%!  codigo_ejemplo(?Nombre, -Codigo:list) is nondet.
%
%   Codigo es el código simbólico del programa de ejemplo Nombre.
codigo_ejemplo(Nombre, Codigo) :-
    programa_ejemplo(Nombre, Programa),
    generar(Programa, Codigo).

%!  listar_objeto(+Texto) is semidet.
%
%   Escribe el código objeto del programa Mini de Texto, una instrucción
%   por línea, con su dirección. Falla si Texto no es un programa Mini.
listar_objeto(Texto) :-
    compilar(Texto, Objeto),
    listar_codigo(Objeto, 0).

%!  listar_codigo(+Codigo:list, +Dir:integer) is det.
%
%   Escribe cada instrucción de Codigo con su dirección, desde Dir.
listar_codigo([], _).
listar_codigo([I|Is], Dir) :-
    format("~w~t~4|~w~n", [Dir, I]),
    Dir1 is Dir + 1,
    listar_codigo(Is, Dir1).
