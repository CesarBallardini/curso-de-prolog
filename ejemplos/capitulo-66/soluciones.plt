:- encoding(utf8).

:- use_module(library(lists)).

:- begin_tests(soluciones).

test(atenuacion, [true(F == [mamifero-[0.63, 0.6, 0.7],
                             carnivoro-[0.3528, 0.1, 0.7],
                             guepardo-[0.1469, 0.0, 0.7]])]) :-
    atenuacion(0.7, F).

test(metodos_de_los_shells, [true(Ps == [0.84, 0.6])]) :-
    findall(P, ( member(M, [mycin, conman]),
                 grado(mamifero, [tiene_pelo-0.6, da_leche-0.6], M, P) ),
            Ps).

% Los métodos de los shells quedan entre las cotas.
test(shells_entre_cotas, [forall(( member(M, [mycin, conman]),
                                   member(G, [0.4, 0.7, 1.0]) ))]) :-
    caso(1, Os),
    findall(O-G, member(O, Os), Gs),
    intervalo(guepardo, Gs, I, S),
    grado(guepardo, Gs, M, P),
    I =< P,
    P =< S.

test(y_no, [true(Ps == [0.72, 0.7, 0.8])]) :-
    findall(P, ( member(M, [independiente, conservador, liberal]),
                 y_no(M, 0.9, 0.2, P) ),
            Ps).

test(dos_reglas, [true(Ps == [0.92, 0.8, 1.0])]) :-
    findall(P, ( member(M, [independiente, conservador, liberal]),
                 dos_reglas(M, P) ),
            Ps).

test(mas_probable, [true(H == guepardo)]) :-
    mas_probable([tiene_pelo-0.9, come_carne-0.7, color_leonado-0.8,
                  manchas_oscuras-0.6, rayas_negras-0.3],
                 independiente, H).

test(mas_probable_ninguna, [fail]) :-
    mas_probable([tiene_pelo-0.9, come_carne-0.7, color_leonado-0.8,
                  manchas_oscuras-0.6, rayas_negras-0.3],
                 conservador, _).

test(excluyentes, [true(M-P == m(105, 106, 12)-5.08)]) :-
    arbol_excluyentes(orden, A),
    medidas(A, M),
    promedio(A, prototipos, P).

% El árbol con preguntas excluyentes sigue dando la primera hipótesis
% del capítulo 33 para todo animal que no vuela y no_vuela a la vez.
test(excluyentes_correcto) :-
    arbol_excluyentes(orden, A),
    forall(( observaciones(Os),
             \+ ( memberchk(vuela, Os), memberchk(no_vuela, Os) ) ),
           ( consultar(A, lista(Os), H, _),
             (   once(identificar(Os, H0))
             ->  true
             ;   H0 = ninguna
             ),
             H == H0 )).

test(costo_minimo, [true(C == 68)]) :-
    costo_minimo(C).

test(ponderado, [true(Ps == [5.9, 6.2, 5.9])]) :-
    findall(P, ( estrategia(E), arbol(E, A), promedio_ponderado(A, P) ),
            Ps).

test(escribir_arbol, [true(H == cebra)]) :-
    tmp_file_stream(text, Archivo, S0),
    close(S0),
    escribir_arbol(Archivo),
    load_files(suelto:Archivo, []),
    suelto:nodo(1, lista([da_leche, tiene_cascos, rayas_negras]), H),
    delete_file(Archivo).

test(con_grado, [true(R == [guepardo-0.1851, ninguna-0.0])]) :-
    arbol(orden, A),
    findall(H-P, ( member(U, [0.5, 0.7]),
                   consultar_con_grado(A, [tiene_pelo-0.9, come_carne-0.7,
                                           color_leonado-0.8,
                                           manchas_oscuras-0.6,
                                           rayas_negras-0.3],
                                       U, H, P) ),
            R).

test(fuerza_estimada, [true(Fs == [0.4-0.022, 0.5-0.013, 0.35-0.107,
                                   0.001-0.001])]) :-
    findall(F-E, ( member(X-N, [200-500, 800-1600, 7-20, 2-2000]),
                   fuerza_estimada(X, N, F, E) ),
            Fs).

test(con_grado_pred, [true(P == tiene_pelo-0.8)]) :-
    soluciones:con_grado(0.8, tiene_pelo, P).

% con_alguna/2: la regla tiene alguna de las preguntas.
test(con_alguna) :-
    soluciones:con_alguna([c, a], x-[a, b]),
    \+ soluciones:con_alguna([c], x-[a, b]).

% construir_excl/4 sin preguntas excluyentes construye lo mismo que
% construir/4.
test(construir_excl) :-
    R = [x-[a, b], y-[a, c], z-[d]],
    soluciones:construir_excl(frecuente, R, [], A1),
    arbol:construir(frecuente, R, [], A2),
    A1 == A2.

% costo/3: una hoja solo se alcanza sin preguntas pendientes, así que una
% regla de una pregunta cuesta 1 por prototipo; con dos reglas, la primera
% pregunta llega a los dos prototipos y la segunda a uno: 3.
test(costo, [true(C1-C2 == 1-3)]) :-
    soluciones:costo([cebra-[tiene_pelo]], [cebra-[tiene_pelo]], C1),
    soluciones:costo([cebra-[tiene_pelo], ave-[tiene_plumas]],
                     [cebra-[tiene_pelo], ave-[tiene_plumas]], C2).

test(sumar_pesado, [true(A == 5-23)]) :-
    foldl(soluciones:sumar_pesado, [2-4, 3-5], 0-0, A).

test(supera) :-
    soluciones:supera(0.5, a-0.5),
    \+ soluciones:supera(0.5, a-0.4).

:- end_tests(soluciones).
