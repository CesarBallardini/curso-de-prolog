:- encoding(utf8).

% Capítulo 62 - Soluciones de los ejercicios 2, 4, 6, 8, 9, 10, 11 y 12.
%
% Cada solución usa los módulos del capítulo sin modificarlos: comparacion
% carga todas las versiones, resolucion agrega el demostrador
% proposicional, y verificador.pl, que no es un módulo, se carga aparte.
%
% solo-local: carga los módulos del capítulo, y SWISH no admite módulos
% propios.
%
%?- clasificar("(p → q) ∨ (q → p)", C).
%?- decidir("(p → q) → (q → p)", V).

:- use_module(library(lists)).
:- use_module(library(apply)).
:- use_module(library(ordsets)).
:- use_module(comparacion).
:- use_module(resolucion).
:- ensure_loaded(verificador).
:- use_module(modelos).

% --- Ejercicio 2 ---------------------------------------------------------

%!  clasificar(+Texto, -Clase) is det.
%
%   Clase es tautologia, contradiccion o contingente, según la fórmula
%   sin cuantificadores que Texto escribe: una contradicción es una
%   fórmula cuya negación es una tautología.
clasificar(Texto, Clase) :-
    leer_formula(Texto, F),
    (   tautologia(clpb, F)
    ->  Clase = tautologia
    ;   tautologia(clpb, no(F))
    ->  Clase = contradiccion
    ;   Clase = contingente
    ).

% --- Ejercicio 4 ---------------------------------------------------------

%!  clausulas_def(+F, -Clausulas:list) is det.
%
%   Clausulas es la forma clausal definicional de F, una fórmula sin
%   cuantificadores: satisfacible si y solo si F lo es. Cada conjunción y
%   cada disyunción de la forma normal negada recibe un átomo d(N) y las
%   cláusulas que dicen que d(N) implica la subfórmula.
clausulas_def(F, Clausulas) :-
    fnn(F, G),
    definir(G, 1, _, L, Cs),
    maplist(sort, [[L]|Cs], Clausulas).

%!  definir(+G, +N0:integer, -N:integer, -L, -Cs:list) is det.
%
%   L es el literal que representa a G, en forma normal negada, y Cs las
%   cláusulas que lo definen; N0 y N numeran los átomos nuevos.
definir(at(A), N, N, +A, []).
definir(no(at(A)), N, N, -A, []).
definir(y(A, B), N0, N, +d(N0), [[-d(N0), LA], [-d(N0), LB]|Cs]) :-
    N1 is N0 + 1,
    definir(A, N1, N2, LA, CA),
    definir(B, N2, N, LB, CB),
    append(CA, CB, Cs).
definir(o(A, B), N0, N, +d(N0), [[-d(N0), LA, LB]|Cs]) :-
    N1 is N0 + 1,
    definir(A, N1, N2, LA, CA),
    definir(B, N2, N, LB, CB),
    append(CA, CB, Cs).

%!  cadena(+N:integer, -Texto:string) is det.
%
%   Texto es la disyunción de N conjunciones a1 ∧ b1 ∨ … ∨ aN ∧ bN.
cadena(N, Texto) :-
    numlist(1, N, Is),
    maplist([I, T]>>format(string(T), "a~w ∧ b~w", [I, I]), Is, Ts),
    atomic_list_concat(Ts, ' ∨ ', A),
    atom_string(A, Texto).

%!  comparar_def(+N:integer, -Distribucion:integer, -Definicional:integer)
%!      is det.
%
%   Cantidad de cláusulas de las dos formas clausales de cadena(N).
comparar_def(N, D, E) :-
    cadena(N, T),
    leer_formula(T, F),
    clausulas(F, C1),
    length(C1, D),
    clausulas_def(F, C2),
    length(C2, E).

% --- Ejercicio 6 ---------------------------------------------------------

%!  primer_error(+Prueba, -K) is det.
%
%   K es el número del primer paso incorrecto de Prueba; ninguno si todos
%   son correctos y el último produce la cláusula vacía, e incompleta si
%   todos son correctos y ninguno la produce.
primer_error(prueba(Clausulas, Pasos), K) :-
    primer_error(Pasos, Clausulas, 1, K).

%!  primer_error(+Pasos:list, +Clausulas:list, +I:integer, -K) is det.
%
%   Como primer_error/2; I es el número del primer paso de Pasos.
primer_error([], Clausulas, _, K) :-
    (   last(Clausulas, [])
    ->  K = ninguno
    ;   K = incompleta
    ).
primer_error([Paso|Pasos], Clausulas, I, K) :-
    (   paso_correcto(Paso, Clausulas, C)
    ->  append(Clausulas, [C], Clausulas1),
        I1 is I + 1,
        primer_error(Pasos, Clausulas1, I1, K)
    ;   K = I
    ).

% --- Ejercicio 8 ---------------------------------------------------------

%!  clausulas_alcance(+F, -Clausulas:list) is det.
%
%   Como clausulas_fo/2, pero skolemiza antes de la forma prenexa: cada
%   término de Skolem depende solo de las variables universales cuyo
%   cuantificador rodea al existencial.
clausulas_alcance(F, Clausulas) :-
    fnn(F, G0),
    renombrar(G0, G),
    skolemizar_fnn(G, [], 1, _, H),
    prenexa(H, _, Matriz),
    fnc(Matriz, Clausulas).

%!  skolemizar_fnn(+G, +Us:list, +N0:integer, -N:integer, -H) is det.
%
%   H es G, en forma normal negada, sin cuantificadores existenciales:
%   cada variable existencial se liga a skN(Us…), donde Us son las
%   variables universales que la rodean.
skolemizar_fnn(at(A), _, N, N, at(A)).
skolemizar_fnn(no(A), _, N, N, no(A)).
skolemizar_fnn(y(A, B), Us, N0, N, y(HA, HB)) :-
    skolemizar_fnn(A, Us, N0, N1, HA),
    skolemizar_fnn(B, Us, N1, N, HB).
skolemizar_fnn(o(A, B), Us, N0, N, o(HA, HB)) :-
    skolemizar_fnn(A, Us, N0, N1, HA),
    skolemizar_fnn(B, Us, N1, N, HB).
skolemizar_fnn(todo(X, F), Us, N0, N, todo(X, H)) :-
    append(Us, [X], Us1),
    skolemizar_fnn(F, Us1, N0, N, H).
skolemizar_fnn(existe(X, F), Us, N0, N, H) :-
    skolemizar([existe(X)], Us, N0, N1),
    skolemizar_fnn(F, Us, N1, N, H).

%!  skolemizar(+Prefijo:list, +Us:list, +N0:integer, -N:integer) is det.
%
%   Liga cada existencial del Prefijo a un término de las variables Us.
skolemizar([], _, N, N).
skolemizar([existe(X)|P], Us, N0, N) :-
    atom_concat(sk, N0, Nombre),
    (   Us == []
    ->  X = Nombre
    ;   compound_name_arguments(X, Nombre, Us)
    ),
    N1 is N0 + 1,
    skolemizar(P, Us, N1, N).

% --- Ejercicio 9 ---------------------------------------------------------

%!  refutar_unitaria(+Clausulas:list, +Max:integer, -Pasos:list) is semidet.
%
%   Pasos es la refutación más corta, de a lo sumo Max pasos, en la que
%   uno de los dos padres de cada paso tiene un solo literal.
refutar_unitaria(Clausulas, Max, Pasos) :-
    between(0, Max, N),
    length(Pasos, N),
    derivar_unitaria(Pasos, Clausulas),
    !.

%!  derivar_unitaria(?Pasos:list, +Clausulas:list) is nondet.
%
%   Como derivar/2 de resolucion.pl, con un padre unitario en cada paso.
%   La condición es un condicional y no una disyunción: con los dos
%   padres unitarios, la disyunción daría cada derivación dos veces.
derivar_unitaria([], Clausulas) :-
    memberchk([], Clausulas).
derivar_unitaria([r(I, J, R)|Pasos], Clausulas) :-
    nth1(J, Clausulas, C2),
    nth1(I, Clausulas, C1),
    I < J,
    (   C1 = [_]
    ->  true
    ;   C2 = [_]
    ),
    resolvente(C1, C2, R),
    \+ memberchk(R, Clausulas),
    append(Clausulas, [R], Clausulas1),
    derivar_unitaria(Pasos, Clausulas1).

% --- Ejercicio 10 --------------------------------------------------------

%!  decidir(+Texto, -Veredicto) is det.
%
%   Veredicto es teorema(Prueba), con una refutación de a lo sumo 10
%   pasos de la negación de la fórmula que Texto escribe, o
%   contraejemplo(A), con una asignación que la hace falsa. Si no hay
%   ninguna de las dos, la refutación necesita más de 10 pasos, y el
%   Veredicto es desconocido.
decidir(Texto, Veredicto) :-
    leer_formula(Texto, F),
    (   demostrar(Texto, 10, Prueba)
    ->  Veredicto = teorema(Prueba)
    ;   once(contraejemplo(F, A))
    ->  Veredicto = contraejemplo(A)
    ;   Veredicto = desconocido
    ).

%!  valor_en(+F, +A:list, -V) is det.
%
%   V, 0 o 1, es el valor de F, sin cuantificadores, con la asignación A
%   de pares Átomo-Valor.
valor_en(at(P), A, V) :-
    memberchk(P-V, A).
valor_en(no(F), A, V) :-
    valor_en(F, A, W),
    V is 1 - W.
valor_en(y(F, G), A, V) :-
    valor_en(F, A, VF),
    valor_en(G, A, VG),
    V is min(VF, VG).
valor_en(o(F, G), A, V) :-
    valor_en(F, A, VF),
    valor_en(G, A, VG),
    V is max(VF, VG).
valor_en(si(F, G), A, V) :-
    valor_en(F, A, VF),
    valor_en(G, A, VG),
    V is max(1 - VF, VG).
valor_en(sii(F, G), A, V) :-
    valor_en(F, A, VF),
    valor_en(G, A, VG),
    (   VF =:= VG
    ->  V = 1
    ;   V = 0
    ).

% --- Ejercicio 11 --------------------------------------------------------

%!  saturar(+Clausulas:list, -Niveles:integer, -Resultado) is det.
%
%   Resultado es refutada si la saturación por niveles de las Clausulas,
%   sin variables, llega a la cláusula vacía, y saturada si llega a un
%   nivel sin resolventes nuevos; Niveles es la cantidad de niveles
%   calculados. Un resolvente subsumido por una cláusula anterior no se
%   agrega.
saturar(Clausulas, Niveles, Resultado) :-
    saturar(Clausulas, 0, Niveles, Resultado).

%!  saturar(+Clausulas:list, +N0:integer, -N:integer, -Resultado) is det.
%
%   Como saturar/3; N0 es la cantidad de niveles ya calculados.
saturar(Clausulas, N, N, refutada) :-
    memberchk([], Clausulas),
    !.
saturar(Clausulas, N0, N, Resultado) :-
    findall(R,
            ( append(_, [C1|Resto], Clausulas),
              member(C2, Resto),
              resolvente(C1, C2, R),
              \+ subsumida(R, Clausulas)
            ),
            Rs0),
    sort(Rs0, Rs),
    (   Rs == []
    ->  N = N0,
        Resultado = saturada
    ;   append(Clausulas, Rs, Clausulas1),
        N1 is N0 + 1,
        saturar(Clausulas1, N1, N, Resultado)
    ).

%!  subsumida(+R:list, +Clausulas:list) is semidet.
%
%   Alguna de las Clausulas, sin variables, está contenida en R.
subsumida(R, Clausulas) :-
    member(C, Clausulas),
    ord_subset(C, R),
    !.

% --- Ejercicio 12 --------------------------------------------------------

%!  modelo_minimo(+Clausulas:list, -Modelo:list) is nondet.
%
%   Modelo es un modelo de las Clausulas que construye modelo/2 y del que
%   ningún subconjunto propio es un modelo. Puede dar dos veces el mismo
%   modelo, si modelo/2 lo construye por dos caminos.
modelo_minimo(Clausulas, Modelo) :-
    modelo(Clausulas, Modelo),
    \+ ( subconjunto_propio(Modelo, Menor),
         es_modelo(Clausulas, Menor)
       ).

%!  es_modelo(+Clausulas:list, +Modelo:list) is semidet.
%
%   Ninguna de las Clausulas está violada en el Modelo.
es_modelo(Clausulas, Modelo) :-
    \+ ( member(C, Clausulas),
         modelos:violada(C, Modelo, _)
       ).

%!  subconjunto_propio(+Conjunto:list, -Subconjunto:list) is nondet.
%
%   Subconjunto es un subconjunto de Conjunto con al menos un elemento
%   menos, en el mismo orden.
subconjunto_propio(Conjunto, Subconjunto) :-
    subconjunto(Conjunto, Subconjunto),
    Subconjunto \== Conjunto.

%!  subconjunto(+Conjunto:list, -Subconjunto:list) is multi.
%
%   Subconjunto tiene algunos de los elementos de Conjunto, en el mismo
%   orden.
subconjunto([], []).
subconjunto([X|Xs], [X|Ys]) :-
    subconjunto(Xs, Ys).
subconjunto([_|Xs], Ys) :-
    subconjunto(Xs, Ys).
