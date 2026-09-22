:- encoding(utf8).

:- begin_tests(corte).

% Sin corte, sofia pertenece a las tres categorías.
test(sin_corte_contesta_de_mas, all(C == [bebe, chico, adulto])) :-
    categoria_sin_corte(sofia, C).

test(sin_corte_eva, all(C == [chico, adulto])) :-
    categoria_sin_corte(eva, C).

% Con corte, una sola respuesta por persona.
test(sofia_es_bebe, all(C == [bebe])) :-
    categoria(sofia, C).

test(eva_es_chica, all(C == [chico])) :-
    categoria(eva, C).

test(juan_es_adulto, all(C == [adulto])) :-
    categoria(juan, C).

% En la consulta inversa el corte no tiene efecto: la cabeza se unifica antes.
test(el_corte_no_protege_al_reves) :-
    categoria(sofia, adulto).

test(un_mayor_de_edad, all(P == [juan])) :-
    un_mayor_de_edad(P).

:- end_tests(corte).
