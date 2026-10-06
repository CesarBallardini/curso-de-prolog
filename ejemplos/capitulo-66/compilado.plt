:- encoding(utf8).

:- use_module(library(lists)).

:- begin_tests(compilado).

test(clausulas, [true(N == 331)]) :-
    aggregate_all(count, clause(compilado:nodo(_, _, _), _), N).

test(casos, [true(Hs == [guepardo, cebra, avestruz, pinguino, ninguna])]) :-
    findall(H, ( caso(_, Os), identificar_compilado(Os, H) ), Hs).

% El árbol compilado da, para todos los animales posibles, la primera
% hipótesis del sistema experto del capítulo 33.
test(igual_que_33) :-
    forall(observaciones(Os),
           ( identificar_compilado(Os, H),
             (   once(identificar(Os, H0))
             ->  true
             ;   H0 = ninguna
             ),
             H == H0 )).

% La consulta del capítulo 33 pregunta vuela para buscar otra prueba de
% ave; el árbol no.
test(encadenando, [true(Ps =@= [tiene_pelo, da_leche, tiene_plumas,
                               no_vuela, nada, vuela, peso(_)])]) :-
    caso(3, Os),
    preguntas_encadenando(Os, Ps).

test(prototipos, [true(S-T == 72-68)]) :-
    arbol(orden, A),
    aggregate_all(sum(N), ( prototipo(_, Os),
                            preguntas_encadenando(Os, Ps),
                            length(Ps, N) ), S),
    aggregate_all(sum(N), ( prototipo(_, Os),
                            consultar(A, lista(Os), _, Ps),
                            length(Ps, N) ), T).

% La consulta con el usuario, con las respuestas desde una cadena.
test(interactiva, [true(H-S == guepardo-"¿tiene_pelo? Responde si o no. \c
    ¿come_carne? Responde si o no. ¿color_leonado? Responde si o no. \c
    ¿manchas_oscuras? Responde si o no. Tu animal es: guepardo.\n")]) :-
    con_entrada("si. si. si. si.",
                with_output_to(string(S), consulta_interactiva(H))).

test(interactiva_valor, [true(H == avestruz)]) :-
    con_entrada("no. no. si. si. no. 90.",
                with_output_to(string(_), consulta_interactiva(H))).

test(interactiva_ninguna, [true(H == ninguna)]) :-
    con_entrada("no. no. no.",
                with_output_to(string(_), consulta_interactiva(H))).

% clausulas//3 de un árbol de una pregunta: tres nodos, el 1 pregunta y
% el 2 y el 3 son hojas.
test(clausulas, [true(N-S == 3-4)]) :-
    phrase(compilado:clausulas(pregunta(p, hoja(si), hoja(no)), 1, S), Cs),
    length(Cs, N).

% term_expansion/2 solo expande arbol_compilado/1.
test(term_expansion_otro, [fail]) :-
    compilado:term_expansion(otro(orden), _).

test(responde_lista) :-
    compilado:responde(lista([tiene_pelo]), tiene_pelo),
    \+ compilado:responde(lista([tiene_pelo]), tiene_plumas).

% repetir/3 sin respuestas previas da lo mismo que
% preguntas_encadenando/2.
test(repetir) :-
    caso(1, Os),
    compilado:repetir(Os, [], Ps),
    preguntas_encadenando(Os, Ps1),
    Ps =@= Ps1.

:- end_tests(compilado).

%!  con_entrada(+Texto:string, :G) is semidet.
%
%   Ejecuta G una vez leyendo la entrada de Texto.
con_entrada(Texto, G) :-
    setup_call_cleanup(open_string(Texto, Entrada),
                       con_entrada_actual(Entrada, G),
                       close(Entrada)).

%!  con_entrada_actual(+Entrada, :G) is semidet.
%
%   Ejecuta G una vez con Entrada como entrada actual.
con_entrada_actual(Entrada, G) :-
    current_input(Antes),
    setup_call_cleanup(set_input(Entrada),
                       once(G),
                       set_input(Antes)).
