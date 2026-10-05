:- encoding(utf8).

% Capítulo 52 - Versión 7: la máquina universal (Turing, §§6-7).
%
% La máquina U recibe en la cinta la descripción estándar de otra máquina
% M y calcula la misma sucesión que M. Su tabla es la de la sección 7 del
% artículo, escrita con las funciones de configuración de la biblioteca:
% U busca la instrucción de M que corresponde a la última configuración
% completa, la marca, escribe la configuración completa siguiente al
% final de la cinta y, si la instrucción imprime una figura en una casilla
% en blanco, la imprime también, seguida de dos puntos.
%
% Las letras de la descripción estándar son los átomos 'A', 'C', 'D',
% 'L', 'R', 'N' y ';'; los dos puntos son ':' y el doble dos puntos que
% cierra la descripción es un solo símbolo, '::'. Las marcas de U son u,
% v, w, x, y, z.
%
% La tabla publicada no se puede ejecutar tal como está. Cada corrección
% está señalada con CORRECCIÓN y nombra quién la publicó: Post (1947,
% nota 11 del apéndice, p. 7), Davies («Corrections to Turing's Universal
% Computing Machine», en Copeland, The Essential Turing, 2004) y Petzold
% (The Annotated Turing, 2008, cap. 9). Las páginas de Davies son las de
% The Essential Turing.
%
% solo-local: es un módulo, y SWISH no admite módulos propios.
%
%?- descripcion(i, b, [0, 1], SD), figuras_universal(SD, 4, Fs).
%?- universal(i, b, [0, 1], 6, Fs).

:- module(universal, [cinta_universal/2, figuras_universal/3,
                      universal/5, escrito/2, escrito_universal/5]).

:- reexport(numeros).
:- use_module(perezosa, []).

% ce4 y ce5: como ce3, con cuatro y cinco letras. Turing usa ce5 sin
% definirla (Davies, p. 123; Petzold, p. 160).
perezosa:alias(_, ce4(B, Al, Be, Ga, De), ce(ce3(B, Be, Ga, De), Al)).
perezosa:alias(_, ce5(B, Al, Be, Ga, De, Ep), ce(ce4(B, Be, Ga, De, Ep), Al)).

% con(C, Al): desde una casilla F, marca con Al la configuración más
% cercana a la derecha (las letras D A...A D C...C) y -> C, con el cabezal
% cuatro casillas a la derecha de su última letra.
plana:fila(_, con(C, Al), no('A'), [r, r], con(C, Al)).
plana:fila(_, con(C, Al), simbolo('A'), [l, p(Al), r], con1(C, Al)).
plana:fila(_, con1(C, Al), simbolo('A'), [r, p(Al), r], con1(C, Al)).
plana:fila(_, con1(C, Al), simbolo('D'), [r, p(Al), r], con2(C, Al)).
% CORRECCIÓN (Post, nota 11; Petzold, p. 152): si la configuración
% termina en la configuración m, la casilla leída es un blanco, que se
% escribe D. Davies corrige el mismo defecto en b1 e inst1(R) (p. 116).
plana:fila(_, con1(C, Al), blanco, [p('D'), r, p(Al), r, r, r], C).
plana:fila(_, con2(C, Al), simbolo('C'), [r, p(Al), r], con2(C, Al)).
plana:fila(_, con2(C, _), no('C'), [r, r], C).
plana:fila(_, con2(C, _), blanco, [r, r], C).

% b: escribe la primera configuración completa, :DA, después de ::.
plana:fila(universal, b, siempre,
           [r, r, p(':'), r, r, p('D'), r, r, p('A')], anf).

% anf: marca con y la última configuración completa. Turing escribe g
% donde corresponde q; lo señalan Post, Davies (p. 118) y Petzold (p. 154).
perezosa:alias(universal, anf, q(anf1, ':')).
perezosa:alias(universal, anf1, con(kom, y)).

% kom: busca hacia la izquierda el último punto y coma sin marca z, lo
% marca con z y marca con x la configuración de la instrucción que sigue.
plana:fila(universal, kom, simbolo(';'), [r, p(z), l], con(kmp, x)).
plana:fila(universal, kom, simbolo(z), [l, l], kom).
plana:fila(universal, kom, no(z), [l], kom).
plana:fila(universal, kom, blanco, [l], kom).

% kmp: compara lo marcado con x y con y; -> sim si son iguales.
% CORRECCIÓN (Davies, p. 116; Petzold, p. 155): si son distintas, la
% comparación ya borró parte de las marcas y; se borran todas las x y las
% y y se vuelve a anf, que marca de nuevo la configuración; Turing vuelve
% a kom. kom sigue después del último punto y coma marcado con z.
perezosa:alias(universal, kmp, cpe(e(e(anf, x), y), sim, x, y)).

% sim: marca con u el símbolo que la instrucción imprime y el movimiento,
% y con y la configuración m final; borra las marcas z.
perezosa:alias(universal, sim, fl(sim1, sim1, z)).
% con(C, blanco) deja el cabezal en la casilla F que sigue a la D del
% símbolo impreso; sim2 marca la casilla F anterior a la que lee.
perezosa:alias(universal, sim1, con(sim2, blanco)).
% CORRECCIÓN (Post, nota 11; Davies, p. 118; Petzold, p. 157): la segunda
% fila de sim2 empieza con L, no con R.
plana:fila(universal, sim2, simbolo('A'), [], sim3).
plana:fila(universal, sim2, no('A'), [l, p(u), r, r, r], sim2).
plana:fila(universal, sim3, simbolo('A'), [l, p(y), r, r, r], sim3).
plana:fila(universal, sim3, no('A'), [l, p(y)], e(mk, z)).

% mk: marca la última configuración completa en cuatro partes: v lo
% anterior al símbolo que precede a la configuración m, x ese símbolo, la
% configuración sin marcar, y w lo que sigue; escribe : al final.
% CORRECCIÓN (Post, nota 11; Davies, p. 118; Petzold, p. 157): mk sigue
% en mk1, no en mk.
perezosa:alias(universal, mk, q(mk1, ':')).
plana:fila(universal, mk1, no('A'), [r, r], mk1).
plana:fila(universal, mk1, simbolo('A'), [l, l, l, l], mk2).
plana:fila(universal, mk2, simbolo('C'), [r, p(x), l, l, l], mk2).
plana:fila(universal, mk2, simbolo(':'), [], mk4).
plana:fila(universal, mk2, simbolo('D'), [r, p(x), l, l, l], mk3).
plana:fila(universal, mk3, simbolo(':'), [], mk4).
plana:fila(universal, mk3, no(':'), [r, p(v), l, l, l], mk3).
perezosa:alias(universal, mk4, con(l(l(mk5)), blanco)).
plana:fila(universal, mk5, simbolo(_), [r, p(w), r], mk5).
plana:fila(universal, mk5, blanco, [p(':')], sh).

% sh: si la instrucción imprime 0 o 1 en una casilla en blanco, escribe
% la figura y : al final.
perezosa:alias(universal, sh, f(sh1, inst, u)).
plana:fila(universal, sh1, siempre, [l, l, l], sh2).
% CORRECCIÓN (Post, nota 11; Petzold, p. 159): con D, sh2 sigue en sh3,
% no en sh2.
plana:fila(universal, sh2, simbolo('D'), [r, r, r, r], sh3).
plana:fila(universal, sh2, no('D'), [], inst).
plana:fila(universal, sh3, simbolo('C'), [r, r], sh4).
plana:fila(universal, sh3, no('C'), [], inst).
plana:fila(universal, sh4, simbolo('C'), [r, r], sh5).
plana:fila(universal, sh4, no('C'), [], pe2(inst, 0, ':')).
plana:fila(universal, sh5, simbolo('C'), [], inst).
plana:fila(universal, sh5, no('C'), [], pe2(inst, 1, ':')).

% inst: escribe la configuración completa siguiente al final, copiando
% las partes marcadas en el orden que pide el movimiento, y -> ov.
perezosa:alias(universal, inst, q(l(inst1), u)).
plana:fila(universal, inst1, simbolo('L'), [r, e], ce5(ov, v, y, x, u, w)).
plana:fila(universal, inst1, simbolo('R'), [r, e], ce5(ov, v, x, u, y, w)).
plana:fila(universal, inst1, simbolo('N'), [r, e], ce5(ov, v, x, y, u, w)).

% ov: borra todas las marcas y vuelve a empezar.
perezosa:alias(universal, ov, e(anf)).

%!  cinta_universal(+SD:string, -Cinta) is det.
%
%   Cinta es la cinta inicial de U para la descripción estándar SD: ə ə,
%   y en las casillas F cada instrucción precedida por su punto y coma,
%   seguidas de ::, con el cabezal sobre ::. SD es la que da
%   descripcion/4, con el punto y coma después de cada instrucción.
%   CORRECCIÓN (Post, nota 11; Davies, pp. 113 y 118; Petzold, p. 150):
%   kom busca el punto y coma que precede a cada instrucción, así que la
%   descripción empieza con punto y coma y no termina con él.
cinta_universal(SD, Cinta) :-
    string_chars(SD, Letras0),
    once(append(Letras1, [';'], Letras0)),
    Letras = [';'|Letras1],
    append(Letras, ['::'], Fs),
    foldl(casilla_f, Fs, Casillas, []),
    length(Letras, K),
    Posicion is 2 + 2 * K,
    cinta_de([schwa, schwa|Casillas], Posicion, Cinta).

% casilla_f(S, Cs0, Cs): S ocupa una casilla F, y la E que sigue, en
% blanco.
casilla_f(S, [S, blanco|Cs], Cs).

%!  figuras_universal(+SD:string, +N:integer, -Fs:list) is semidet.
%
%   Fs son las primeras N figuras que imprime U con la descripción
%   estándar SD en la cinta.
figuras_universal(SD, N, Fs) :-
    cinta_universal(SD, Cinta),
    perezosa:figuras(universal, b, Cinta, N, Fs0),
    length(Fs, N),
    append(Fs, _, Fs0).

%!  universal(+M, +Q0, +Alfabeto:list, +N:integer, -Fs:list) is semidet.
%
%   Fs son las primeras N figuras que imprime U con la descripción
%   estándar de la máquina M desde Q0 con el Alfabeto.
universal(M, Q0, Alfabeto, N, Fs) :-
    descripcion(M, Q0, Alfabeto, SD),
    figuras_universal(SD, N, Fs).

%!  escrito_universal(+M, +Q0, +Alfabeto:list, +Pasos:integer,
%!                    -Texto:string) is semidet.
%
%   Texto es lo que U escribe después de :: en a lo sumo Pasos pasos, con
%   la descripción estándar de la máquina M desde Q0 con el Alfabeto.
escrito_universal(M, Q0, Alfabeto, Pasos, Texto) :-
    descripcion(M, Q0, Alfabeto, SD),
    cinta_universal(SD, Cinta0),
    ejecutar(universal, b, Cinta0, Pasos, R),
    arg(2, R, Cinta),
    escrito(Cinta, Texto).

%!  escrito(+Cinta, -Texto:string) is semidet.
%
%   Texto es lo que U escribió en las casillas F después de ::, las
%   configuraciones completas y las figuras, separadas por dos puntos.
%   Falla si la cinta no tiene ::.
escrito(Cinta, Texto) :-
    contenido(Cinta, Ss),
    append(_, ['::'|Despues], Ss),
    !,
    casillas_f(Despues, Fs),
    atomic_list_concat(Fs, Texto0),
    atom_string(Texto0, Texto).

%!  casillas_f(+Ss:list, -Fs:list) is det.
%
%   Fs son los símbolos de las casillas F de Ss, que empieza con una
%   casilla E.
casillas_f([], []).
casillas_f([_|Ss], Fs) :-
    casillas_e(Ss, Fs).

%!  casillas_e(+Ss:list, -Fs:list) is det.
%
%   Como casillas_f/2, con Ss que empieza con una casilla F.
casillas_e([], []).
casillas_e([F|Ss], [F|Fs]) :-
    casillas_f(Ss, Fs).
