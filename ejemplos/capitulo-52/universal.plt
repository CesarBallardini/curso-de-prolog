:- encoding(utf8).

:- begin_tests(universal).

test(cinta, [true(S-Ss == '::'-[schwa, schwa, ';', blanco, 'D', blanco,
                               'A', blanco, 'D', blanco, 'D', blanco,
                               'C', blanco, 'R', blanco, 'D', blanco,
                               'A', blanco, '::'])]) :-
    cinta_universal("DADDCRDA;", C),
    leer(C, S),
    contenido(C, Ss).

% Una sola instrucción: en q1 sobre un blanco, imprime 0, avanza y
% sigue en q1.
test(ceros, [true(Fs == [0, 0, 0])]) :-
    figuras_universal("DADDCRDA;", 3, Fs).

test(maquina_i, [true(Fs == [0, 1, 0, 1])]) :-
    universal(i, b, [0, 1], 4, Fs).

% U calcula lo mismo que la máquina que simula.
test(como_la_maquina, [true(Fs == Gs)]) :-
    universal(i_bis, b, [0, 1], 4, Fs),
    figuras(i_bis, b, 4, Gs).

test(escrito, [true(T == ":DAD:0:DCDAAD:DCDDAAAD:1:DCDDCCDAAAAD")]) :-
    descripcion(i, b, [0, 1], SD),
    cinta_universal(SD, C0),
    ejecutar(universal, b, C0, 50000, limite(_, C)),
    escrito(C, T).

test(escrito_sin_doble_dos_puntos, [fail]) :-
    cinta_de([schwa, schwa, 'D', blanco], 0, C),
    escrito(C, _).

% con marca la configuración de una instrucción y deja el cabezal cuatro
% casillas después de su última letra.
test(con, [true(R == detenida(fin, c([blanco, 'D', x, 'C', x, 'D', x,
                                      'A', x, 'D', blanco, ';', schwa,
                                      schwa],
                                     'C', [blanco, 'R', blanco, 'D',
                                           blanco, 'A', blanco])))]) :-
    cinta_de([schwa, schwa, ';', blanco, 'D', blanco, 'A', blanco, 'D',
              blanco, 'C', blanco, 'D', blanco, 'C', blanco, 'R', blanco,
              'D', blanco, 'A', blanco], 2, C0),
    ejecutar(universal, con(fin, x), C0, 100, R).

% Una configuración que termina en la configuración m lee un blanco, que
% con escribe D.
test(con_al_final, [true(Ss == [schwa, schwa, ':', blanco, 'D', y, 'A', y,
                                'D', y])]) :-
    cinta_de([schwa, schwa, ':', blanco, 'D', blanco, 'A', blanco], 2, C0),
    ejecutar(universal, con(fin, y), C0, 100, detenida(fin, C)),
    contenido(C, Ss).

test(ce5, [true(Ss == [schwa, schwa, 'D', blanco, 'C', blanco, 'A',
                       blanco, 'R', blanco, 'D', blanco, 'C', blanco, 'A',
                       blanco, 'R'])]) :-
    cinta_de([schwa, schwa, 'D', v, 'C', x, 'A', y, 'R', w], 0, C0),
    ejecutar(universal, ce5(fin, v, x, y, w, u), C0, 10000,
             detenida(fin, C)),
    contenido(C, Ss).

test(escrito_universal, [true(T == ":DAD:0:DCDAAD:DCDDAAAD:1:DCDDCCDAAAAD")]) :-
    escrito_universal(i, b, [0, 1], 50000, T).

test(escrito_al_comienzo, [true(T == ":DA")]) :-
    escrito_universal(i, b, [0, 1], 1, T).

:- end_tests(universal).
