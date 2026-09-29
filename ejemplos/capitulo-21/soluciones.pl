:- encoding(utf8).

% Capítulo 21 - Soluciones de los ejercicios 1 a 13. Las de los ejercicios 14
% a 16, sobre el proyecto, están en soluciones_proyecto.pl.
%
%?- phrase(oracion_verdadera(H), P).
%?- phrase(expresion(V), `2+3*4-6/2`).
%?- string_codes("cuanto es 5 mas 13 por 2", Cs), phrase(problema(V), Cs).

:- use_module(library(dcg/basics)).
:- use_module(library(dcg/high_order)).

% --- Ejercicio 2 --------------------------------------------------------------

%!  ab// is nondet.
%
%   Una o más a seguidas de la misma cantidad de b.
ab --> [a], [b].
ab --> [a], ab, [b].

%!  ab_invertida// is nondet.
%
%   El mismo lenguaje que ab//0, con las reglas en el orden inverso
%   (ejercicio 6). Analiza bien, pero no genera: la primera regla es siempre
%   la recursiva, y la generación no llega nunca a una lista completa.
ab_invertida --> [a], ab_invertida, [b].
ab_invertida --> [a], [b].

% --- Ejercicio 3 --------------------------------------------------------------

%!  saludo_a(?N)// is nondet.
%
%   Los códigos de "hola " seguidos del nombre N.
saludo_a(N) -->
    "hola ",
    nombre(N).

%!  saludo_a_traducido(?N, ?S0, ?S) is nondet.
%
%   La traducción de saludo_a//1 escrita a mano: los códigos de "hola " al
%   principio de S0, y el nombre en lo que sigue.
saludo_a_traducido(N, S0, S) :-
    S0 = [0'h, 0'o, 0'l, 0'a, 0' |S1],
    nombre(N, S1, S).

%!  nombre(?N)// is nondet.
%
%   Los códigos de uno de los nombres conocidos.
nombre(ana)  --> "ana".
nombre(luis) --> "luis".

% --- Ejercicio 4 --------------------------------------------------------------

%!  frase// is nondet.
%
%   Un sujeto y un verbo que concuerdan en número: "el perro ladra" o "los
%   perros ladran", como listas de palabras.
frase -->
    sujeto(Numero),
    verbo(Numero).

%!  sujeto(?Numero)// is nondet.
%
%   Un artículo y un sustantivo en singular o en plural.
sujeto(Numero) -->
    articulo(Numero),
    sustantivo(Numero).

% articulo(Numero)//: el artículo de ese número.
articulo(singular) --> [el].
articulo(plural)   --> [los].

% sustantivo(Numero)//: un sustantivo de ese número.
sustantivo(singular) --> [perro].
sustantivo(plural)   --> [perros].
sustantivo(singular) --> [gato].
sustantivo(plural)   --> [gatos].

% verbo(Numero)//: un verbo conjugado en ese número.
verbo(singular) --> [ladra].
verbo(plural)   --> [ladran].

% --- Ejercicio 5 --------------------------------------------------------------

% persona(P): P es una de las personas de las que se puede hablar.
persona(juan).
persona(ana).
persona(pedro).
persona(marta).

% padre(P, H): P es el padre de H.
padre(juan, ana).
padre(juan, pedro).
% madre(M, H): M es la madre de H.
madre(marta, ana).
madre(marta, pedro).

%!  oracion_verdadera(?Hecho)// is nondet.
%
%   Una oración de la sección 21.1 que afirma Hecho, siempre que Hecho sea
%   uno de los hechos de la base.
oracion_verdadera(Hecho) -->
    nombre_de_persona(A),
    [es],
    relacion(A, B, Hecho),
    [de],
    nombre_de_persona(B),
    { verdadero(Hecho) }.

%!  verdadero(+Hecho) is semidet.
%
%   Hecho es uno de los hechos de padre/2 o de madre/2. Una cláusula por
%   relación, en lugar de call/1: el sandbox de SWISH no acepta llamar un
%   objetivo que no conoce de antemano.
verdadero(padre(A, B)) :-
    padre(A, B).
verdadero(madre(A, B)) :-
    madre(A, B).

% relacion(A, B, Hecho)//: el artículo y el sustantivo de una relación.
relacion(A, B, padre(A, B)) --> [el, padre].
relacion(A, B, madre(A, B)) --> [la, madre].

%!  nombre_de_persona(?P)// is nondet.
%
%   El nombre de una persona conocida.
nombre_de_persona(P) -->
    [P],
    { persona(P) }.

% --- Ejercicio 7 --------------------------------------------------------------

%!  preorden(+Arbol)// is det.
%
%   Los nombres de los nodos de Arbol, cada uno antes que sus subárboles. Un
%   árbol es nil o nodo(Nombre, Izquierdo, Derecho).
preorden(nil) --> [].
preorden(nodo(Nombre, I, D)) -->
    [Nombre],
    preorden(I),
    preorden(D).

%!  simetrico(+Arbol)// is det.
%
%   Los nombres de los nodos de Arbol, cada uno entre sus dos subárboles.
simetrico(nil) --> [].
simetrico(nodo(Nombre, I, D)) -->
    simetrico(I),
    [Nombre],
    simetrico(D).

%!  postorden(+Arbol)// is det.
%
%   Los nombres de los nodos de Arbol, cada uno después de sus subárboles.
postorden(nil) --> [].
postorden(nodo(Nombre, I, D)) -->
    postorden(I),
    postorden(D),
    [Nombre].

% --- Ejercicio 8 --------------------------------------------------------------

%!  balanceado// is semidet.
%
%   Los paréntesis, corchetes y llaves del texto están bien anidados; los
%   demás códigos se ignoran.
balanceado -->
    balanceado([]).

%!  balanceado(+Abiertos:list)// is semidet.
%
%   Abiertos son los cierres que faltan, el próximo primero.
balanceado([]) -->
    eos,
    !.
balanceado(Abiertos) -->
    [C],
    { apertura(C, Cierre) },
    !,
    balanceado([Cierre|Abiertos]).
balanceado([Cierre|Abiertos]) -->
    [Cierre],
    !,
    balanceado(Abiertos).
balanceado(Abiertos) -->
    [C],
    { \+ apertura(C, _),
      \+ apertura(_, C) },
    balanceado(Abiertos).

% apertura(A, C): A abre un grupo que C cierra.
apertura(0'(, 0')).
apertura(0'[, 0']).
apertura(0'{, 0'}).

% --- Ejercicio 9 --------------------------------------------------------------

%!  expresion(-V:number)// is semidet.
%
%   Una expresión con enteros, +, -, * y /, sin paréntesis. * y / se
%   evalúan antes que + y -, y operadores de la misma precedencia, de
%   izquierda a derecha.
expresion(V) -->
    termino(T),
    sumas(T, V).

%!  sumas(+Hasta:number, -V:number)// is det.
%
%   V es Hasta con las sumas y restas que siguen aplicadas en orden.
sumas(Hasta, V) -->
    "+",
    !,
    termino(T),
    { Ahora is Hasta + T },
    sumas(Ahora, V).
sumas(Hasta, V) -->
    "-",
    !,
    termino(T),
    { Ahora is Hasta - T },
    sumas(Ahora, V).
sumas(V, V) -->
    [].

%!  termino(-V:number)// is semidet.
%
%   Un producto o cociente de enteros, de izquierda a derecha.
termino(V) -->
    integer(N),
    productos(N, V).

%!  productos(+Hasta:number, -V:number)// is det.
%
%   V es Hasta con los productos y cocientes que siguen aplicados en orden.
productos(Hasta, V) -->
    "*",
    !,
    integer(N),
    { Ahora is Hasta * N },
    productos(Ahora, V).
productos(Hasta, V) -->
    "/",
    !,
    integer(N),
    { Ahora is Hasta / N },
    productos(Ahora, V).
productos(V, V) -->
    [].

% --- Ejercicio 10 -------------------------------------------------------------

%!  fecha_larga(?F)// is semidet.
%
%   El texto "24 de septiembre de 2026" de la fecha F = fecha(2026, 9, 24),
%   en los dos sentidos.
fecha_larga(fecha(Anio, Mes, Dia)) -->
    integer(Dia),
    " de ",
    nombre_de_mes(Mes),
    " de ",
    integer(Anio).

%!  nombre_de_mes(?Mes:integer)// is semidet.
%
%   Los códigos del nombre del mes número Mes. atom//1 escribe el nombre al
%   generar, y lo compara con la entrada al analizar.
nombre_de_mes(Mes) -->
    { nth1(Mes, [enero, febrero, marzo, abril, mayo, junio, julio, agosto,
                 septiembre, octubre, noviembre, diciembre], Nombre) },
    atom(Nombre).

% --- Ejercicio 11 -------------------------------------------------------------

%!  enumeracion(-Nombres:list)// is semidet.
%
%   Los nombres separados por comas, con y antes del último: "ana",
%   "ana y luis", "ana, luis y eva". Solo analiza: csym//1 no genera.
enumeracion([N]) -->
    csym(N).
enumeracion([N1, N2]) -->
    csym(N1),
    " y ",
    csym(N2).
enumeracion([N1, N2, N3|Ns]) -->
    csym(N1),
    ", ",
    enumeracion([N2, N3|Ns]).

% --- Ejercicio 12 -------------------------------------------------------------

%!  problema(-V:number)// is semidet.
%
%   "cuanto es 5 mas 13 por 2": V es el resultado de las operaciones,
%   aplicadas de izquierda a derecha, sin precedencia.
problema(V) -->
    "cuanto es ",
    integer(N),
    operaciones(N, V).

%!  operaciones(+Hasta:number, -V:number)// is semidet.
%
%   V es Hasta con cada " operación número" que sigue aplicada en orden.
operaciones(Hasta, V) -->
    " ",
    operacion(Op),
    " ",
    !,
    integer(N),
    { aplicar(Op, Hasta, N, Ahora) },
    operaciones(Ahora, V).
operaciones(V, V) -->
    [].

%!  operacion(?Op)// is nondet.
%
%   Los códigos de la palabra que nombra la operación Op.
operacion(suma)     --> "mas".
operacion(resta)    --> "menos".
operacion(producto) --> "por".
operacion(cociente) --> "dividido".

%!  aplicar(+Op, +A:number, +B:number, -R:number) is det.
%
%   R es el resultado de la operación Op entre A y B.
aplicar(suma, A, B, R)     :- R is A + B.
aplicar(resta, A, B, R)    :- R is A - B.
aplicar(producto, A, B, R) :- R is A * B.
aplicar(cociente, A, B, R) :- R is A / B.

% --- Ejercicio 13 -------------------------------------------------------------

%!  lista_de_enteros(?L:list(integer))// is semidet.
%
%   "[1, 2, 3]": enteros entre corchetes, separados por coma y espacio.
lista_de_enteros(L) -->
    sequence("[", integer, ", ", "]", L).
