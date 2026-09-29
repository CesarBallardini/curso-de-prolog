:- encoding(utf8).

:- begin_tests(revision).

test(borrador, [true(Avisos == [ aviso(texto:4, sin_encabezado, promedio/2),
                                 aviso(texto:4, singular, 'L'),
                                 aviso(texto:4, singular, 'Largo'),
                                 aviso(texto:13, separadas, notas/2),
                                 aviso(texto:14, repetida, '_S0'),
                                 aviso(texto:14, separadas, suma/2) ])]) :-
    revisar_texto(borrador, Avisos).

test(singulares, [true(Ts == [singular-'X', singular-'Z', repetida-'_W'])]) :-
    singulares((p(X, Y) :- q(Y, Z), r(W, W)),
               ['X'=X, 'Y'=Y, 'Z'=Z, '_W'=W], Avisos),
    findall(T-N, member(aviso(_, T, N), Avisos), Ts).

% Un predicado declarado discontiguous no merece aviso.
test(discontiguous, [true(Avisos == [])]) :-
    unir_lineas([ ":- discontiguous p/1.", "% p(X): X.", "p(1).",
                  "% q(X): X.", "q(1).", "p(2)." ], Texto),
    revisar_texto_de(Texto, Avisos).

% Una regla de gramática cuyo cuerpo es solo una lista de terminales es un
% hecho de la gramática: basta el comentario de una línea.
test(gramatica, [true(Avisos == [aviso(texto:3, sin_encabezado, frase/2)])]) :-
    unir_lineas([ "% articulo//: un artículo.", "articulo --> [el].",
                  "frase --> articulo, [perro]." ], Texto),
    revisar_texto_de(Texto, Avisos).

% El proyecto Inscripciones sigue las convenciones: ningún aviso.
test(inscripciones, [true(Avisos == [])]) :-
    archivos(inscripciones, Fs),
    revisar_archivos(Fs, Avisos).

% Las variables singulares coinciden con las que informa el lector del
% sistema, con la opción singletons de read_term/3.
test(como_el_sistema, [true(Nuestras == DelSistema)]) :-
    texto(borrador, Texto),
    revisar_texto_de(Texto, Avisos),
    findall(N, member(aviso(_, singular, N), Avisos), Nuestras),
    setup_call_cleanup(open_string(Texto, S),
                       singulares_del_sistema(S, DelSistema0),
                       close(S)),
    msort(DelSistema0, DelSistema).

%!  singulares_del_sistema(+Stream, -Nombres:list) is det.
%
%   Nombres son las variables que read_term/3 informa como singulares en
%   los términos de Stream, sin las que empiezan con _.
singulares_del_sistema(S, Nombres) :-
    read_term(S, T, [singletons(Ss)]),
    (   T == end_of_file
    ->  Nombres = []
    ;   findall(N, ( member(N = _, Ss),
                     \+ sub_atom(N, 0, _, _, '_') ),
                Ns),
        singulares_del_sistema(S, Resto),
        append(Ns, Resto, Nombres)
    ).

%!  unir_lineas(+Lineas:list(string), -Texto:string) is det.
%
%   Texto es el programa de las Lineas, separadas por saltos de línea.
unir_lineas(Lineas, Texto) :-
    atomic_list_concat(Lineas, '\n', Atomo),
    atom_string(Atomo, Texto).

:- end_tests(revision).
