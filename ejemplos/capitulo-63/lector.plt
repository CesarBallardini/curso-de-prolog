:- encoding(utf8).

:- begin_tests(lector).

test(precedencia, [true(F == si(y(no(at(p)), at(q)), o(at(r), at(s))))]) :-
    leer_formula("¬p ∧ q → r ∨ s", F).

% Los símbolos ASCII dan el mismo término que los de la lógica.
test(ascii, [true(F1 == F2)]) :-
    leer_formula("~p & q -> r | s <-> t", F1),
    leer_formula("¬p ∧ q → r ∨ s ↔ t", F2).

test(implicacion_derecha, [true(F == si(at(p), si(at(q), at(r))))]) :-
    leer_formula("p → q → r", F).

test(conjuncion_izquierda, [true(F == y(y(at(p), at(q)), at(r)))]) :-
    leer_formula("p ∧ q ∧ r", F).

% El cuantificador alcanza solo a la fórmula que lo sigue.
test(alcance, [true(F =@= si(todo(X, at(p(X))), at(q(x))))]) :-
    leer_formula("∀x p(x) → q(x)", F).

test(variables, [true(F =@= todo(X, existe(Y, at(ama(X, f(Y, c))))))]) :-
    leer_formula("todo x existe y ama(x, f(y, c))", F).

% Dos cuantificadores sobre el mismo nombre ligan variables distintas.
test(sombra, [true(X \== Y)]) :-
    leer_formula("∀x (p(x) ∧ ∃x q(x))", todo(X, y(_, existe(Y, _)))).

test(error_incompleta, [error(syntax_error(formula(_)))]) :-
    leer_formula("p ∧", _).

test(error_sii, [error(syntax_error(formula(_)))]) :-
    leer_formula("p ↔ q ↔ r", _).

test(escritura, [true(T == "(p → q) ∧ ¬(r ∨ s) → t")]) :-
    leer_formula("((p -> q) & ~(r | s)) -> t", F),
    formula_texto(F, T).

test(escritura_variables,
     [true(T == "∃x ∀y (afeita(x, y) ↔ ¬afeita(y, y))")]) :-
    leer_formula("existe b todo p (afeita(b, p) <-> ~afeita(p, p))", F),
    formula_texto(F, T).

% Leer lo escrito da una variante de la fórmula original.
test(ida_y_vuelta, [forall(member(T, ["p ∧ (q ∧ r)", "(p → q) → r",
                                      "(p ↔ q) ↔ r", "¬∀x ∃y p(x, y)",
                                      "p ∨ q ∧ r → ¬s"])),
                    true(F2 =@= F1)]) :-
    leer_formula(T, F1),
    formula_texto(F1, T1),
    leer_formula(T1, F2).

% simbolo//1 reconoce los símbolos ASCII y los de la lógica, y las
% palabras clave de los cuantificadores, sin dejar alternativas pendientes.
test(simbolo, [true(Ss == [no, si, sii, todo, todo, id(padre), '('])]) :-
    maplist(simbolo_de, ["¬", "->", "<->", "∀", "todo", "padre", "("], Ss).

test(simbolo_resto, all(S-R == [si-` q`])) :-
    phrase(lector:simbolo(S), `-> q`, R).

test(simbolo_determinista, [true(S-R == y-` p`)]) :-
    phrase(lector:simbolo(S), `& p`, R).

test(simbolo_nombre_determinista, [true(S-R == id(p)-`(x)`)]) :-
    phrase(lector:simbolo(S), `p(x)`, R).

% Con el símbolo instanciado, simbolo//1 lo comprueba.
test(simbolo_instanciado, [fail]) :-
    phrase(lector:simbolo(o), `&`, _).

test(implicacion, all(F == [si(at(p), si(at(q), at(r)))])) :-
    phrase(lector:implicacion([], F), [id(p), si, id(q), si, id(r)]).

test(conjuncion_resto, all(F == [y(y(at(p), at(q)), at(r))])) :-
    phrase(lector:conjuncion_resto([], at(p), F), [y, id(q), y, id(r)]).

test(conjuncion_resto_vacia, all(F == [at(p)])) :-
    phrase(lector:conjuncion_resto([], at(p), F), []).

test(unaria_negacion, all(F == [no(no(at(p)))])) :-
    phrase(lector:unaria([], F), [no, no, id(p)]).

% El cuantificador liga la variable de Prolog que el entorno asocia al
% nombre; un nombre que el entorno no tiene es una constante.
test(unaria_cuantificador, [true(Fs =@= [todo(X, at(p(X, y)))])]) :-
    findall(F, phrase(lector:unaria([], F),
                      [todo, id(x), id(p), '(', id(x), ',', id(y), ')']),
            Fs).

test(unaria_entorno, [true(F == at(p(V)))]) :-
    phrase(lector:unaria([x-V], F), [id(p), '(', id(x), ')']).

simbolo_de(Texto, S) :-
    string_codes(Texto, Cs),
    phrase(lector:simbolo(S), Cs).

:- end_tests(lector).
