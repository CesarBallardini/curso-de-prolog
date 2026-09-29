:- encoding(utf8).

:- begin_tests(leer).

test(datos_terminos, [true(N == 61)]) :-
    archivo_de_inscripciones(datos, F),
    leer_archivo(F, Leidos),
    length(Leidos, N).

% Cada término llega con su archivo y su línea, los nombres de sus
% variables y los comentarios que lo preceden.
test(posicion_y_comentario,
     [true(Posicion-Nombres-Encabezado == ('datos.pl':92)-['N']-"%!  ")]) :-
    archivo_de_inscripciones(datos, F),
    leer_archivo(F, Leidos),
    member(leido((nota_minima(_) :- _), Posicion, Nombres0, [C]), Leidos),
    !,
    findall(Nombre, member(Nombre = _, Nombres0), Nombres),
    sub_string(C, 0, 4, _, Encabezado).

% termino_leido/2 recibe el archivo por su especificación.
test(termino_leido, [true(C == setting(nota_minima, N)), nondet]) :-
    termino_leido(inscripciones(datos),
                  leido((nota_minima(N) :- C), 'datos.pl':92, _, _)).

% programa/3 sobre términos escritos a mano: la exportación de un no
% terminal, una declaración dynamic, una regla de gramática, una cláusula
% para otro módulo y una directiva. Se compara con =@=: las variables son
% otras.
test(traducir, [true(Cs-Rs =@= [ ('<carga>' :- iniciar),
                                 d(_),
                                 (p(X, S0, S) :- q(X, S0, S)),
                                 m(1) ]-
                               [ '<carga>'/0, m/1, p/3 ])]) :-
    Leidos = [ leido((:- module(ejemplo, [p//1])), a:1, [], []),
               leido((:- initialization(iniciar)), a:2, [], []),
               leido((:- dynamic d/1), a:3, [], []),
               leido((p(X) --> q(X)), a:4, [], []),
               leido(otro:m(1), a:5, [], []) ],
    programa(Leidos, Cs, Rs).

test(inscripciones_indefinidos, [true(Ps == [])]) :-
    indefinidos(inscripciones, Ps).

% Los dos que quedan se llaman dentro del argumento de responder/1, que
% la copia de api.pl no declara como metallamada.
test(inscripciones_no_usados, [true(Ps == [legajo/2, resultado_json/3])]) :-
    no_usados(inscripciones, Ps).

test(inscripciones_componentes,
     [true(Gs == [[bucle/1], [palabras/3], [requisito/2]])]) :-
    componentes(inscripciones, Gs).

test(inscripciones_tamanio, [true([NC, ND, NA] == [225, 98, 302])]) :-
    clausulas(inscripciones, Cs),
    length(Cs, NC),
    definidos(Cs, Ds),
    length(Ds, ND),
    arcos(Cs, Arcos),
    length(Arcos, NA).

% El sistema sabe que setup_call_cleanup/3 llama a sus tres argumentos, y
% que foldl/4 agrega tres argumentos a su clausura.
test(meta_del_sistema, [true(Ps == [a/0, b/0, c/0, f/3])]) :-
    metas((setup_call_cleanup(a, b, c), foldl(f, _, 0, _)), Ms),
    maplist(indicador, Ms, Ps0),
    exclude(predefinido, Ps0, Ps1),
    list_to_set(Ps1, Ps).

test(predefinido_por_el_sistema, [nondet]) :-
    predefinido(must_be/2),
    predefinido(atom_length/2),
    \+ predefinido(inscribir/3).

:- end_tests(leer).
