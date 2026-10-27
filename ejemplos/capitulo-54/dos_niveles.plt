:- encoding(utf8).

:- begin_tests(dos_niveles).

% Con las dos formas dadas, cada regla acepta o rechaza la sucesión de
% pares: luz+s con z escrita c, y con z escrita z.
test(acepta_z) :-
    acepta(complemento(contiene(z)),
           [[l]:[l], [u]:[u], [z]:[c], [+]:[], []:[e], [s]:[s]]).

test(rechaza_z, [fail]) :-
    acepta(complemento(contiene(z)),
           [[l]:[l], [u]:[u], [z]:[z], [+]:[], []:[e], [s]:[s]]).

test(rechaza_epentesis, [fail]) :-
    acepta(complemento(contiene(epentesis)),
           [[l]:[l], [u]:[u], [z]:[c], [+]:[], [s]:[s]]).

test(estados, [true(N == 91)]) :-
    numero_estados(interseccion(complemento(contiene(epentesis)),
                                complemento(contiene(u))),
                   N).

% Sin la regla de z ni las de tildes, luz+s tiene cuatro formas escritas.
test(dos_reglas, [true(Es == [[l, u, c, e, s], [l, u, z, e, s],
                              [l, 'ú', c, e, s], [l, 'ú', z, e, s]])]) :-
    findall(E, transducir(ortografia([epentesis, u]), [l, u, z, +, s], E),
            Es0),
    sort(Es0, Es).

% El léxico elige la forma subyacente que existe.
test(lexico, [true(Ss == [[l, u, z, +, s]])]) :-
    findall(S, transducir(compuesta(lexico, ortografia([epentesis, u])),
                          S, [l, u, c, e, s]),
            Ss).

% Después de k: casa, comer, cuento.
test(siguiente, [true(Ls == [a, o, u])]) :-
    findall(L, dos_niveles:continuacion([k], L), Ls0),
    sort(Ls0, Ls).

test(forma_lexica, [true(A == nombre("luz", femenino, plural))]) :-
    forma_lexica([l, u, z, +, s], A).

test(reglas, [true(Rs == [limite, k, u, g, z, jota, epentesis,
                          quitar_tilde, poner_tilde])]) :-
    reglas(Rs).

test(solo_ante_frontal,
     [true(Ps == [[c, no(o(limite, frontal))]-medio, [c]-final,
                  [c, limite, no(frontal)]-medio, [c, limite]-final])]) :-
    dos_niveles:solo_ante_frontal(c, Ps).

test(no_ante_frontal,
     [true(Ps == [[c, frontal]-medio, [c, limite, frontal]-medio])]) :-
    dos_niveles:no_ante_frontal(c, Ps).

% La regla z es la unión de los patrones de las dos funciones.
test(regla_z, [true(N == 6)]) :-
    regla(z, Ps),
    length(Ps, N).

test(regla_inexistente, [fail]) :-
    regla(ninguna, _).

:- end_tests(dos_niveles).
