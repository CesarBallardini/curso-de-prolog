:- encoding(utf8).

% Capítulo 57 - Versión 3: una sintaxis concreta y un preludio.
%
% Lee programas del lenguaje objeto escritos como texto y los traduce a la
% sintaxis abstracta de entornos.pl, con dos gramáticas, como en el
% capítulo 45: lexico/2 convierte el texto en componentes léxicos y
% expresion//1 convierte los componentes en una expresión.
%   fun x y -> e                 lam(x, lam(y, e))
%   f a b                        ap(ap(f, a), b); la aplicación asocia a
%                                la izquierda y liga más que los operadores
%   a + b, a - b, a * b          ap(ap(id(Op), a), b)
%   a = b, a < b, a > b          lo mismo, con menor precedencia
%   (+)                          id(+), el operador como función
%   [a, b]                       ap(ap(id(cons), a), ap(ap(id(cons), b),
%                                id(nil)))
%   si c entonces a sino b       si(c, a, b)
%   sea x = e1 en e2             sea(x, e1, e2)
% Una definición es «f x y = e»: def(f, lam(x, lam(y, e))). El preludio
% define map, filtrar y los plegados en el propio lenguaje.
%
% solo-local: carga entornos.pl, y SWISH no carga otros archivos.
%
%?- ejecutar("map (fun x -> x * x) [1, 2, 3]", V).
%?- leer_expresion("fun x -> x + 1", E).
%?- ejecutar("f 2 3", "f x y = x * 10 + y", V).

:- ensure_loaded(entornos).
:- use_module(library(dcg/basics)).

%!  ejecutar(+Texto, -Valor) is det.
%
%   Valor es el resultado de evaluar la expresión escrita en Texto, con
%   las definiciones del preludio.
ejecutar(Texto, V) :-
    ejecutar(Texto, "", V).

%!  ejecutar(+Texto, +Definiciones, -Valor) is det.
%
%   Como ejecutar/2, con las Definiciones del texto, separadas por punto y
%   coma, delante de las del preludio: una definición del texto oculta a la
%   del preludio del mismo nombre.
ejecutar(Texto, Definiciones, V) :-
    leer_programa(Definiciones, Propias),
    preludio_leido(Preludio),
    append(Propias, Preludio, Prog),
    leer_expresion(Texto, E),
    evaluar(E, [], Prog, V).

%!  leer_expresion(+Texto, -E) is det.
%
%   E es la sintaxis abstracta de la expresión escrita en Texto. Error de
%   sintaxis si Texto no es una expresión.
leer_expresion(Texto, E) :-
    lexico(Texto, Ts),
    (   phrase(expresion(E0), Ts)
    ->  E = E0
    ;   syntax_error(expresion)
    ).

%!  leer_programa(+Texto, -Programa:list) is det.
%
%   Programa es la lista de las definiciones escritas en Texto, separadas
%   por punto y coma. Error de sintaxis si Texto no es un programa.
leer_programa(Texto, Prog) :-
    lexico(Texto, Ts),
    (   phrase(definiciones(Prog0), Ts)
    ->  Prog = Prog0
    ;   syntax_error(programa)
    ).

%!  preludio_leido(-Programa:list) is det.
%
%   Programa es la lista de las definiciones del preludio.
preludio_leido(Prog) :-
    findall(D, ( preludio(T), leer_programa(T, [D]) ), Prog).

% El análisis léxico.

%!  lexico(+Texto, -Componentes:list) is det.
%
%   Componentes es la lista de componentes léxicos de Texto: num(N),
%   id(X), una palabra reservada o un símbolo. Error de sintaxis si Texto
%   tiene un carácter que no empieza ningún componente.
lexico(Texto, Ts) :-
    string_codes(Texto, Cs),
    (   phrase(componentes(Ts0), Cs)
    ->  Ts = Ts0
    ;   syntax_error(componente_lexico)
    ).

%!  componentes(-Componentes:list)// is semidet.
%
%   Los componentes de la lista de códigos, separados por blancos.
componentes(Ts) -->
    blanks,
    componentes_(Ts).

%!  componentes_(-Componentes:list)// is semidet.
%
%   Los componentes que siguen a los blancos, hasta el final del texto.
componentes_([T|Ts]) -->
    componente(T),
    !,
    componentes(Ts).
componentes_([]) -->
    eos.

%!  componente(-T)// is semidet.
%
%   Un componente léxico: el más largo que empieza en la posición actual.
componente(num(N)) -->
    digit(D),
    !,
    digits(Ds),
    { number_codes(N, [D|Ds]) }.
componente(T) -->
    [C],
    { code_type(C, csymf) },
    !,
    alfanumericos(Cs),
    { atom_codes(A, [C|Cs]),
      (   reservada(A)
      ->  T = A
      ;   T = id(A)
      ) }.
componente(S) -->
    simbolo(S).

%!  alfanumericos(-Cs:list)// is det.
%
%   Los códigos de letras, dígitos y guiones bajos que siguen, los más
%   posibles.
alfanumericos([C|Cs]) -->
    [C],
    { code_type(C, csym) },
    !,
    alfanumericos(Cs).
alfanumericos([]) -->
    [].

% reservada(P): P es una palabra reservada.
reservada(fun).
reservada(si).
reservada(entonces).
reservada(sino).
reservada(sea).
reservada(en).

%!  simbolo(-S)// is semidet.
%
%   Un símbolo; «->» antes que «-», para leer el más largo.
simbolo('->') --> "->", !.
simbolo(S) -->
    [C],
    { memberchk(C-S, [0'(-'(', 0')-')', 0'[-'[', 0']-']', 0',-',',
                      0';-';', 0'=-(=), 0'<-(<), 0'>-(>), 0'+-(+),
                      0'--(-), 0'*-(*)]) }.

% El análisis sintáctico, sobre los componentes.

%!  definiciones(-Programa:list)// is semidet.
%
%   Una o más definiciones separadas por punto y coma, o ninguna.
definiciones([D|Ds]) -->
    definicion(D),
    !,
    (   [;]
    ->  definiciones(Ds)
    ;   { Ds = [] }
    ).
definiciones([]) -->
    [].

%!  definicion(-D)// is semidet.
%
%   «f x y = e»: la función f, con parámetros x e y, anidados en lambdas.
definicion(def(F, E)) -->
    [id(F)],
    parametros(Xs),
    [=],
    expresion(Cuerpo),
    { lambdas(Xs, Cuerpo, E) }.

%!  parametros(-Xs:list)// is det.
%
%   Cero o más identificadores.
parametros([X|Xs]) -->
    [id(X)],
    !,
    parametros(Xs).
parametros([]) -->
    [].

%!  lambdas(+Xs:list, +Cuerpo, -E) is det.
%
%   E anida una lambda por cada parámetro de Xs alrededor de Cuerpo.
lambdas([], E, E).
lambdas([X|Xs], Cuerpo, lam(X, E)) :-
    lambdas(Xs, Cuerpo, E).

%!  expresion(-E)// is semidet.
%
%   Una expresión: una función, un condicional, un «sea» o una comparación.
expresion(E) -->
    [fun],
    !,
    [id(X)],
    parametros(Xs),
    ['->'],
    expresion(Cuerpo),
    { lambdas([X|Xs], Cuerpo, E) }.
expresion(si(C, A, B)) -->
    [si],
    !,
    expresion(C),
    [entonces],
    expresion(A),
    [sino],
    expresion(B).
expresion(sea(X, E1, E2)) -->
    [sea],
    !,
    [id(X)],
    [=],
    expresion(E1),
    [en],
    expresion(E2).
expresion(E) -->
    comparacion(E).

%!  comparacion(-E)// is semidet.
%
%   Una suma, o dos sumas comparadas con =, < o >.
comparacion(E) -->
    suma(A),
    (   [Op],
        { memberchk(Op, [=, <, >]) }
    ->  suma(B),
        { E = ap(ap(id(Op), A), B) }
    ;   { E = A }
    ).

%!  suma(-E)// is semidet.
%
%   Términos separados por + o -, asociados a la izquierda.
suma(E) -->
    termino(A),
    resto_suma(A, E).

%!  resto_suma(+A, -E)// is semidet.
%
%   E es A seguido de los términos que siguen, sumados o restados.
resto_suma(A, E) -->
    [Op],
    { memberchk(Op, [+, -]) },
    !,
    termino(B),
    resto_suma(ap(ap(id(Op), A), B), E).
resto_suma(E, E) -->
    [].

%!  termino(-E)// is semidet.
%
%   Aplicaciones separadas por *, asociadas a la izquierda.
termino(E) -->
    aplicacion(A),
    resto_termino(A, E).

%!  resto_termino(+A, -E)// is semidet.
%
%   E es A multiplicado por las aplicaciones que siguen.
resto_termino(A, E) -->
    [*],
    !,
    aplicacion(B),
    resto_termino(ap(ap(id(*), A), B), E).
resto_termino(E, E) -->
    [].

%!  aplicacion(-E)// is semidet.
%
%   Uno o más átomos seguidos: la función y sus argumentos, de a uno.
aplicacion(E) -->
    atomo(F),
    resto_aplicacion(F, E).

%!  resto_aplicacion(+F, -E)// is det.
%
%   E es F aplicada, de a uno, a los átomos que siguen.
resto_aplicacion(F, E) -->
    atomo(A),
    !,
    resto_aplicacion(ap(F, A), E).
resto_aplicacion(E, E) -->
    [].

%!  atomo(-E)// is semidet.
%
%   Un número, un identificador, un operador entre paréntesis, una
%   expresión entre paréntesis o una lista entre corchetes.
atomo(num(N)) -->
    [num(N)].
atomo(id(X)) -->
    [id(X)].
atomo(id(Op)) -->
    ['(', Op, ')'],
    { memberchk(Op, [+, -, *, =, <, >]) },
    !.
atomo(E) -->
    ['('],
    expresion(E),
    [')'].
atomo(E) -->
    ['['],
    elementos(E),
    [']'].

%!  elementos(-E)// is semidet.
%
%   Los elementos de una lista, separados por comas, como una cadena de
%   aplicaciones de cons que termina en nil.
elementos(ap(ap(id(cons), A), E)) -->
    expresion(A),
    !,
    (   [',']
    ->  elementos(E)
    ;   { E = id(nil) }
    ).
elementos(id(nil)) -->
    [].

% preludio(Texto): una definición del preludio. Un \c al final de una
% línea continúa la cadena en la siguiente, sin el salto ni los blancos
% del principio.
preludio("map f l = si vacia l entonces [] \c
          sino cons (f (cabeza l)) (map f (cola l))").
preludio("filtrar p l = si vacia l entonces [] \c
          sino si p (cabeza l) \c
          entonces cons (cabeza l) (filtrar p (cola l)) \c
          sino filtrar p (cola l)").
preludio("plegar_izq f a l = si vacia l entonces a \c
          sino plegar_izq f (f a (cabeza l)) (cola l)").
preludio("plegar_der f a l = si vacia l entonces a \c
          sino f (cabeza l) (plegar_der f a (cola l))").
preludio("componer f g x = f (g x)").
preludio("suma = plegar_izq (+) 0").
preludio("longitud = plegar_izq (fun n x -> n + 1) 0").
preludio("invertir = plegar_izq (fun a x -> cons x a) []").
preludio("hasta a b = si a > b entonces [] sino cons a (hasta (a + 1) b)").
preludio("desde n = cons n (desde (n + 1))").
preludio("tomar n l = si n = 0 entonces [] \c
          sino cons (cabeza l) (tomar (n - 1) (cola l))").
preludio("nesimo n l = si n = 0 entonces cabeza l \c
          sino nesimo (n - 1) (cola l)").
preludio("zipcon f a b = cons (f (cabeza a) (cabeza b)) \c
          (zipcon f (cola a) (cola b))").
preludio("fibs = cons 0 (cons 1 (zipcon (+) fibs (cola fibs)))").
preludio("criba l = sea p = cabeza l en \c
          cons p (criba (filtrar (fun x -> mod x p > 0) (cola l)))").
preludio("primos = criba (desde 2)").
