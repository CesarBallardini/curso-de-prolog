:- encoding(utf8).

% Capítulo 62 - Versión 1: el lector de fórmulas.
%
% Lee una fórmula de la lógica de predicados escrita como texto, con los
% símbolos ¬ ∧ ∨ → ↔ ∀ ∃ o sus equivalentes ~ & | -> <-> todo existe, y la
% devuelve como un término con una representación limpia: at(A) para una
% fórmula atómica, no/1, y/2, o/2, si/2, sii/2, todo/2 y existe/2. Un
% analizador léxico pasa el texto a una lista de símbolos, y una gramática
% con un no terminal por nivel de precedencia la pasa a un término. Cada
% cuantificador liga una variable de Prolog nueva: las variables del objeto
% son variables de Prolog, y dos cuantificadores nunca comparten una.
% formula_texto/2 hace el camino inverso.
%
% solo-local: es un módulo, y los demás archivos del capítulo lo cargan;
% SWISH no admite módulos propios.
%
%?- leer_formula("¬p ∧ q → r ∨ s", F).
%?- leer_formula("∀x (hombre(x) → mortal(x))", F).

:- module(lector,
          [ leer_formula/2,
            formula_texto/2
          ]).

:- use_module(library(lists)).
:- use_module(library(error)).

%!  leer_formula(+Texto, -Formula) is det.
%
%   Formula es la fórmula que Texto escribe. Un texto que no es una
%   fórmula produce un error de sintaxis.
leer_formula(Texto, Formula) :-
    text_to_string(Texto, Cadena),
    string_codes(Cadena, Codigos),
    (   phrase(simbolos(Simbolos), Codigos),
        phrase(formula([], Formula), Simbolos)
    ->  true
    ;   syntax_error(formula(Cadena))
    ).

% --- El analizador léxico ------------------------------------------------

%!  simbolos(-Simbolos:list)// is semidet.
%
%   Simbolos es la lista de los símbolos del texto, sin los blancos.
simbolos([S|Ss]) -->
    blancos,
    simbolo(S),
    !,
    simbolos(Ss).
simbolos([]) -->
    blancos.

%!  simbolo(-S)// is semidet.
%
%   S es el símbolo que empieza en el texto: un conectivo, un
%   cuantificador, un paréntesis, una coma o id(Nombre).
simbolo(no)     --> ( "¬" ; "~" ).
simbolo(y)      --> ( "∧" ; "&" ).
simbolo(o)      --> ( "∨" ; "|" ).
simbolo(si)     --> ( "→" ; "->" ).
simbolo(sii)    --> ( "↔" ; "<->" ).
simbolo(todo)   --> "∀".
simbolo(existe) --> "∃".
simbolo('(')    --> "(".
simbolo(')')    --> ")".
simbolo(',')    --> ",".
simbolo(S) -->
    [C],
    { code_type(C, csymf) },
    resto_nombre(Cs),
    { atom_codes(Nombre, [C|Cs]),
      palabra(Nombre, S)
    }.

%!  palabra(+Nombre, -S) is det.
%
%   S es el símbolo de la palabra Nombre: todo y existe son
%   cuantificadores, y cualquier otra es un nombre.
palabra(todo, todo) :- !.
palabra(existe, existe) :- !.
palabra(Nombre, id(Nombre)).

%!  resto_nombre(-Cs:list)// is det.
%
%   Cs son los caracteres que continúan un nombre: letras, dígitos y _.
resto_nombre([C|Cs]) -->
    [C],
    { code_type(C, csym) },
    !,
    resto_nombre(Cs).
resto_nombre([]) -->
    [].

%!  blancos// is det.
%
%   Consume los blancos del texto.
blancos -->
    [C],
    { code_type(C, space) },
    !,
    blancos.
blancos -->
    [].

% --- La gramática --------------------------------------------------------
%
% Un no terminal por nivel, del que liga menos al que liga más: ↔, →, ∨,
% ∧, y los operadores de un solo argumento (¬ y los cuantificadores). El
% argumento Entorno es la lista de pares Nombre-Variable de los
% cuantificadores que rodean el punto de la lectura, el más cercano
% primero.

%!  formula(+Entorno:list, -F)// is semidet.
%
%   F es una fórmula; ↔ no se asocia: p ↔ q ↔ r no es una fórmula.
formula(E, F) -->
    implicacion(E, A),
    (   [sii]
    ->  implicacion(E, B),
        { F = sii(A, B) }
    ;   { F = A }
    ).

%!  implicacion(+Entorno:list, -F)// is semidet.
%
%   F es una implicación, que se asocia a la derecha: p → q → r es
%   p → (q → r).
implicacion(E, F) -->
    disyuncion(E, A),
    (   [si]
    ->  implicacion(E, B),
        { F = si(A, B) }
    ;   { F = A }
    ).

%!  disyuncion(+Entorno:list, -F)// is semidet.
%
%   F es una disyunción, que se asocia a la izquierda.
disyuncion(E, F) -->
    conjuncion(E, A),
    disyuncion_resto(E, A, F).

%!  disyuncion_resto(+Entorno:list, +A, -F)// is semidet.
%
%   F es A seguida de los disyuntos que quedan en el texto.
disyuncion_resto(E, A, F) -->
    [o],
    !,
    conjuncion(E, B),
    disyuncion_resto(E, o(A, B), F).
disyuncion_resto(_, F, F) -->
    [].

%!  conjuncion(+Entorno:list, -F)// is semidet.
%
%   F es una conjunción, que se asocia a la izquierda.
conjuncion(E, F) -->
    unaria(E, A),
    conjuncion_resto(E, A, F).

%!  conjuncion_resto(+Entorno:list, +A, -F)// is semidet.
%
%   F es A seguida de los factores que quedan en el texto.
conjuncion_resto(E, A, F) -->
    [y],
    !,
    unaria(E, B),
    conjuncion_resto(E, y(A, B), F).
conjuncion_resto(_, F, F) -->
    [].

%!  unaria(+Entorno:list, -F)// is semidet.
%
%   F es una negación, una fórmula cuantificada, una fórmula entre
%   paréntesis o una fórmula atómica. Un cuantificador liga una variable
%   nueva y alcanza solo a la fórmula que lo sigue: ∀x p(x) → q(x) es
%   (∀x p(x)) → q(x).
unaria(E, no(F)) -->
    [no],
    !,
    unaria(E, F).
unaria(E, todo(X, F)) -->
    [todo, id(N)],
    !,
    unaria([N-X|E], F).
unaria(E, existe(X, F)) -->
    [existe, id(N)],
    !,
    unaria([N-X|E], F).
unaria(E, F) -->
    ['('],
    !,
    formula(E, F),
    [')'].
unaria(E, at(A)) -->
    [id(N)],
    argumentos(E, Ts),
    { compound_name_arguments_o_atomo(A, N, Ts) }.

%!  argumentos(+Entorno:list, -Ts:list)// is semidet.
%
%   Ts son los términos entre paréntesis que siguen a un nombre, o [] si
%   no sigue un paréntesis.
argumentos(E, [T|Ts]) -->
    ['('],
    !,
    termino(E, T),
    mas_terminos(E, Ts),
    [')'].
argumentos(_, []) -->
    [].

%!  mas_terminos(+Entorno:list, -Ts:list)// is semidet.
%
%   Ts son los términos que siguen, cada uno después de una coma.
mas_terminos(E, [T|Ts]) -->
    [','],
    !,
    termino(E, T),
    mas_terminos(E, Ts).
mas_terminos(_, []) -->
    [].

%!  termino(+Entorno:list, -T)// is semidet.
%
%   T es un término: el nombre de una variable ligada es esa variable, y
%   cualquier otro nombre es una constante o un símbolo de función.
termino(E, T) -->
    [id(N)],
    argumentos(E, Ts),
    { (   Ts == [],
          memberchk(N-V, E)
      ->  T = V
      ;   compound_name_arguments_o_atomo(T, N, Ts)
      )
    }.

%!  compound_name_arguments_o_atomo(-T, +Nombre, +Args:list) is det.
%
%   T es el átomo Nombre si Args es [], y el término Nombre(Args) si no.
compound_name_arguments_o_atomo(Nombre, Nombre, []) :-
    !.
compound_name_arguments_o_atomo(T, Nombre, Args) :-
    compound_name_arguments(T, Nombre, Args).

% --- La escritura --------------------------------------------------------

%!  formula_texto(+Formula, -Texto:string) is det.
%
%   Texto escribe Formula con los símbolos ¬ ∧ ∨ → ↔ ∀ ∃ y los paréntesis
%   que la precedencia exige. Las variables ligadas se escriben x, y, z,
%   u, v, w, x1, y1…, en el orden de sus cuantificadores.
formula_texto(Formula, Texto) :-
    copy_term(Formula, F),
    nombrar(F, 0, _),
    phrase(texto(F), Codigos),
    string_codes(Texto, Codigos).

%!  nombrar(+F, +N0:integer, -N:integer) is det.
%
%   Liga cada variable cuantificada de F a un nombre; N0 y N cuentan los
%   nombres usados antes y después.
nombrar(at(_), N, N).
nombrar(no(F), N0, N) :-
    nombrar(F, N0, N).
nombrar(y(A, B), N0, N) :-
    nombrar_dos(A, B, N0, N).
nombrar(o(A, B), N0, N) :-
    nombrar_dos(A, B, N0, N).
nombrar(si(A, B), N0, N) :-
    nombrar_dos(A, B, N0, N).
nombrar(sii(A, B), N0, N) :-
    nombrar_dos(A, B, N0, N).
nombrar(todo(X, F), N0, N) :-
    nombrar_ligada(X, F, N0, N).
nombrar(existe(X, F), N0, N) :-
    nombrar_ligada(X, F, N0, N).

%!  nombrar_dos(+A, +B, +N0:integer, -N:integer) is det.
%
%   Nombra las variables de A y después las de B.
nombrar_dos(A, B, N0, N) :-
    nombrar(A, N0, N1),
    nombrar(B, N1, N).

%!  nombrar_ligada(-X, +F, +N0:integer, -N:integer) is det.
%
%   Liga X al nombre número N0, y nombra las variables de F.
nombrar_ligada(X, F, N0, N) :-
    nombre_variable(N0, X),
    N1 is N0 + 1,
    nombrar(F, N1, N).

%!  nombre_variable(+N:integer, -Nombre) is det.
%
%   Nombre es el nombre de la variable número N, desde 0.
nombre_variable(N, Nombre) :-
    Letras = [x, y, z, u, v, w],
    length(Letras, L),
    I is N mod L,
    nth0(I, Letras, Letra),
    (   N < L
    ->  Nombre = Letra
    ;   K is N // L,
        atom_concat(Letra, K, Nombre)
    ).

%!  simbolo_texto(?Conectivo, ?Simbolo) is semidet.
%
%   Simbolo es el átomo con que se escribe el Conectivo.
simbolo_texto(y, '∧').
simbolo_texto(o, '∨').
simbolo_texto(si, '→').
simbolo_texto(sii, '↔').
simbolo_texto(todo, '∀').
simbolo_texto(existe, '∃').

%!  nivel(+F, -N:integer) is det.
%
%   N es el nivel de precedencia del conectivo principal de F: 0 para una
%   fórmula atómica, 1 para ¬ y los cuantificadores, y de 2 a 5 para ∧,
%   ∨, → y ↔.
nivel(at(_), 0).
nivel(no(_), 1).
nivel(todo(_, _), 1).
nivel(existe(_, _), 1).
nivel(y(_, _), 2).
nivel(o(_, _), 3).
nivel(si(_, _), 4).
nivel(sii(_, _), 5).

%!  texto(+F)// is det.
%
%   Los códigos de la escritura de F, con las variables ya nombradas.
texto(at(A)) -->
    { format(codes(Cs), "~W", [A, [spacing(next_argument)]]) },
    Cs.
texto(no(F)) -->
    "¬",
    operando(F, 1).
texto(todo(X, F)) -->
    cuantificada(todo, X, F).
texto(existe(X, F)) -->
    cuantificada(existe, X, F).
texto(y(A, B)) -->
    binaria(y(A, B)).
texto(o(A, B)) -->
    binaria(o(A, B)).
texto(si(A, B)) -->
    binaria(si(A, B)).
texto(sii(A, B)) -->
    binaria(sii(A, B)).

%!  cuantificada(+Cuantificador, +X, +F)// is det.
%
%   La escritura de F cuantificada sobre la variable, ya nombrada, X.
cuantificada(Q, X, F) -->
    atomo(Q),
    { atom_codes(X, Cs) },
    Cs,
    " ",
    operando(F, 1).

%!  binaria(+F)// is det.
%
%   La escritura de la fórmula binaria F, con sus operandos entre
%   paréntesis cuando la precedencia lo exige.
binaria(F) -->
    { F =.. [C, A, B],
      nivel(F, N),
      limites(C, N, MaxA, MaxB)
    },
    operando(A, MaxA),
    " ",
    atomo(C),
    " ",
    operando(B, MaxB).

%!  atomo(+Conectivo)// is det.
%
%   Los códigos del símbolo del Conectivo.
atomo(C) -->
    { simbolo_texto(C, S),
      atom_codes(S, Cs)
    },
    Cs.

%!  limites(+Conectivo, +N:integer, -MaxA:integer, -MaxB:integer) is det.
%
%   MaxA y MaxB son los niveles más altos que admiten sin paréntesis los
%   operandos izquierdo y derecho del Conectivo binario, de nivel N: ∧ y
%   ∨ se asocian a la izquierda, → a la derecha, y ↔ no se asocia.
limites(y, N, N, MaxB) :-
    MaxB is N - 1.
limites(o, N, N, MaxB) :-
    MaxB is N - 1.
limites(si, N, MaxA, N) :-
    MaxA is N - 1.
limites(sii, N, Max, Max) :-
    Max is N - 1.

%!  operando(+F, +Max:integer)// is det.
%
%   La escritura de F, entre paréntesis si su nivel es mayor que Max.
operando(F, Max) -->
    { nivel(F, N) },
    (   { N =< Max }
    ->  texto(F)
    ;   "(",
        texto(F),
        ")"
    ).
