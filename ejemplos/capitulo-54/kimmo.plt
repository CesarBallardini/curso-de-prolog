:- encoding(utf8).

:- begin_tests(kimmo).

% La regla z escrita en la notación de dos niveles da los mismos
% patrones que la regla z de la versión 3.
test(z_como_la_version_3, [true(A == B)]) :-
    regla_dos_niveles(z_k, Par, Op, Izquierda, Derechas),
    compilar(Par, Op, Izquierda, Derechas, Ps),
    once(regla(z, Qs)),
    msort(Ps, A),
    msort(Qs, B).

test(restriccion_derecha,
     [true(Ps == [[par(['N']:[n]), no(limite)]-medio,
                  [par(['N']:[n])]-final])]) :-
    compilar(['N']:[n], '=>', [], [[limite]], Ps).

% La regla de la e final de Covington: e:0 => C:C _ +:0.
test(restriccion_izquierda,
     [true(Ps == [[no(consonante), par([e]:[])]-medio,
                  [par([e]:[])]-inicio,
                  [par([e]:[]), no(limite)]-medio,
                  [par([e]:[])]-final])]) :-
    compilar([e]:[], '=>', [consonante], [[limite]], Ps).

test(coercion, [true(Ps == [[par(['N']:[n]), limite, par([p]:[p])]-medio])]) :-
    compilar(['N']:[m], '<=', [], [[limite, par([p]:[p])]], Ps).

test(coercion_sin_otros, [true(Ps == [])]) :-
    coercion([+]:[], [], [[vocal]], Ps).

test(a_la_derecha_arbol,
     [true(Ps == [[c, no(o(limite, frontal))]-medio, [c]-final,
                  [c, limite, no(frontal)]-medio, [c, limite]-final])]) :-
    a_la_derecha([[limite, frontal], [frontal]], [c], Ps).

test(a_la_derecha_contexto_vacio, [true(Ps == [])]) :-
    a_la_derecha([[]], [c], Ps).

test(a_la_izquierda, [true(Ps == [[no(b), c]-medio, [c]-inicio,
                                  [no(a), b, c]-medio, [b, c]-inicio])]) :-
    a_la_izquierda([b, a], [c], Ps).

test(primeras, [true(Cs == [limite, frontal])]) :-
    primeras([[limite, frontal], [frontal], [limite]], Cs).

test(disyuncion, [true(O == o(a, o(b, c)))]) :-
    disyuncion([a, b, c], O).

test(disyuncion_una, [true(O == a)]) :-
    disyuncion([a], O).

test(registradas, [true(Ns == [nasal, nasal_n])]) :-
    reglas(Rs),
    include([R]>>memberchk(R, [nasal, nasal_n]), Rs, Ns).

test(imposible, [true(Es == [[i, m, p, o, s, i, b, l, e]])]) :-
    reglas(Rs),
    findall(E, transducir(paralelo(Rs), [i, 'N', +, p, o, s, i, b, l, e], E),
            Es).

test(infeliz, [true(Es == [[i, n, f, e, l, i, z]])]) :-
    reglas(Rs),
    findall(E, transducir(paralelo(Rs), [i, 'N', +, f, e, l, i, z], E), Es).

% La N solo aparece ante el límite: la forma subyacente de un lema no la
% tiene.
test(sin_n_en_la_raiz, [true(Ss == [[k, a, m, i, 'ó', n]])]) :-
    findall(S, raiz("camión", S), Ss).

test(n_sin_limite, [fail]) :-
    reglas(Rs),
    transducir(paralelo(Rs), [k, a, m, i, 'ó', 'N'], _).

% Con las dos reglas nuevas, las formas del léxico no cambian.
test(como_la_version_2, [true(Distintas == [])]) :-
    findall(A-P,
            ( reglas:analisis(A),
              reglas:generar(A, P),
              \+ findall(Q, forma(Q, A), [P]) ),
            Distintas).

:- end_tests(kimmo).
