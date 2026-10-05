:- encoding(utf8).

% Capítulo 52 - Versión 3: la biblioteca de funciones de configuración m.
%
% Las tablas esqueleto de Turing (1936, §4), como filas y alias que valen
% para todas las máquinas: la variable anónima ocupa el lugar del nombre
% de la máquina. Las mayúsculas góticas de Turing son variables de
% configuración (C, B, A, E) y las griegas son variables de símbolo (Al,
% Be, Ga por α, β, γ). Los nombres con prima se escriben con l y r: f' es
% fl y f'' es fr.
%
% Las funciones suponen la disposición de Turing: la cinta empieza con ə ə
% (el átomo schwa dos veces), las figuras van en las casillas pares desde
% la 2 (casillas F) y las marcas en la casilla de la derecha de cada
% figura (casillas E). Una figura S con la marca a a su derecha está
% «marcada con a».
%
% La máquina contador calcula la misma sucesión que la máquina II con
% una configuración que crece: m(K) imprime un 0 y K unos, y pasa a
% m(s(K)). Tiene infinitas configuraciones distintas.
%
% solo-local: es un módulo, y SWISH no admite módulos propios.
%
%?- figuras(contador, inicio, 15, Fs).
%?- cinta_de([schwa, schwa, 1, x, 0, x], 5, C0), ejecutar(biblioteca, e(fin, x), C0, 100, R).

:- module(biblioteca, []).

:- reexport(perezosa).
:- reexport(plana, [cinta_vacia/1, leer/2, contenido/2]).

% f(C, B, Al): busca la primera Al, la de más a la izquierda; -> C si
% la encuentra, con el cabezal sobre ella, y -> B si no hay ninguna.
plana:fila(_, f(C, B, Al), simbolo(schwa), [l], f1(C, B, Al)).
plana:fila(_, f(C, B, Al), no(schwa), [l], f(C, B, Al)).
% CORRECCIÓN (Post, nota 11; Petzold, p. 116): la tabla de Turing no
% tiene fila para el blanco en f; el blanco se trata igual que «no
% schwa», y sin esa fila la máquina se detiene en la primera casilla
% vacía que encuentra al retroceder.
plana:fila(_, f(C, B, Al), blanco, [l], f(C, B, Al)).
plana:fila(_, f1(C, _, Al), simbolo(Al), [], C).
plana:fila(_, f1(C, B, Al), no(Al), [r], f1(C, B, Al)).
plana:fila(_, f1(C, B, Al), blanco, [r], f2(C, B, Al)).
plana:fila(_, f2(C, _, Al), simbolo(Al), [], C).
plana:fila(_, f2(C, B, Al), no(Al), [r], f1(C, B, Al)).
plana:fila(_, f2(_, B, _), blanco, [r], B).

% e(C, B, Al): borra la primera Al y -> C; -> B si no hay ninguna.
% e(B, Al): borra todas las Al y -> B.
perezosa:alias(_, e(C, B, Al), f(e1(C, B, Al), B, Al)).
plana:fila(_, e1(C, _, _), siempre, [e], C).
perezosa:alias(_, e(B, Al), e(e(B, Al), B, Al)).

% pe(C, Be): imprime Be en la primera casilla F en blanco y -> C.
perezosa:alias(_, pe(C, Be), f(pe1(C, Be), C, schwa)).
plana:fila(_, pe1(C, Be), simbolo(_), [r, r], pe1(C, Be)).
plana:fila(_, pe1(C, Be), blanco, [p(Be)], C).

% l(C), r(C): mueven el cabezal y -> C. fl y fr: como f, y después
% mueven el cabezal a la izquierda o a la derecha.
plana:fila(_, l(C), siempre, [l], C).
plana:fila(_, r(C), siempre, [r], C).
perezosa:alias(_, fl(C, B, Al), f(l(C), B, Al)).
perezosa:alias(_, fr(C, B, Al), f(r(C), B, Al)).

% c(C, B, Al): copia al final la primera figura marcada con Al y -> C.
% c1(C) lee la figura en la variable Be, que la fila liga.
perezosa:alias(_, c(C, B, Al), fl(c1(C), B, Al)).
plana:fila(_, c1(C), simbolo(Be), [], pe(C, Be)).

% ce(C, B, Al): copia la primera figura marcada con Al, borra la marca y
% -> C. ce(B, Al): copia en orden todas las marcadas con Al, borra las
% marcas y -> B. ce2 y ce3 copian las marcadas con dos o tres letras.
perezosa:alias(_, ce(C, B, Al), c(e(C, B, Al), B, Al)).
perezosa:alias(_, ce(B, Al), ce(ce(B, Al), B, Al)).
perezosa:alias(_, ce2(B, Al, Be), ce(ce(B, Be), Al)).
perezosa:alias(_, ce3(B, Al, Be, Ga), ce(ce2(B, Be, Ga), Al)).

% re(C, B, Al, Be): reemplaza la primera Al por Be y -> C; -> B si no
% hay ninguna. re(B, Al, Be): reemplaza todas y -> B.
perezosa:alias(_, re(C, B, Al, Be), f(re1(C, B, Al, Be), B, Al)).
plana:fila(_, re1(C, _, _, Be), siempre, [e, p(Be)], C).
perezosa:alias(_, re(B, Al, Be), re(re(B, Al, Be), B, Al, Be)).

% cp(C, A, E, Al, Be): compara la primera figura marcada con Al con la
% primera marcada con Be; -> E si no hay ninguna de las dos, -> C si hay
% las dos y son iguales, y -> A en otro caso. cpe hace lo mismo y, si
% son iguales, borra las dos marcas. cpe(A, E, Al, Be) compara las dos
% sucesiones marcadas: -> E si son iguales y -> A si no.
perezosa:alias(_, cp(C, A, E, Al, Be), fl(cp1(C, A, Be), f(A, E, Be), Al)).
plana:fila(_, cp1(C, A, Be), simbolo(Ga), [], fl(cp2(C, A, Ga), A, Be)).
plana:fila(_, cp2(C, _, Ga), simbolo(Ga), [], C).
plana:fila(_, cp2(_, A, Ga), no(Ga), [], A).
perezosa:alias(_, cpe(C, A, E, Al, Be),
               cp(e(e(C, C, Be), C, Al), A, E, Al, Be)).
perezosa:alias(_, cpe(A, E, Al, Be), cpe(cpe(A, E, Al, Be), A, E, Al, Be)).

% q(C): va hasta el final de la cinta, la primera casilla F en blanco
% seguida de una E en blanco, y -> C. q(C, Al): busca la última Al y -> C.
plana:fila(_, q(C), simbolo(_), [r], q(C)).
plana:fila(_, q(C), blanco, [r], q1(C)).
plana:fila(_, q1(C), simbolo(_), [r], q(C)).
plana:fila(_, q1(C), blanco, [], C).
perezosa:alias(_, q(C, Al), q(q1(C, Al))).
plana:fila(_, q1(C, Al), simbolo(Al), [], C).
plana:fila(_, q1(C, Al), no(Al), [l], q1(C, Al)).
plana:fila(_, q1(C, Al), blanco, [l], q1(C, Al)).

% pe2(C, Al, Be): imprime Al y Be al final y -> C.
perezosa:alias(_, pe2(C, Al, Be), pe(pe(C, Be), Al)).

% e(C): borra todas las marcas de las casillas E y -> C.
plana:fila(_, e(C), simbolo(schwa), [r], e1(C)).
plana:fila(_, e(C), no(schwa), [l], e(C)).
plana:fila(_, e(C), blanco, [l], e(C)).
plana:fila(_, e1(C), simbolo(_), [r, e, r], e1(C)).
plana:fila(_, e1(C), blanco, [], C).

% La máquina contador: la sucesión 001011011101111... con pe.
plana:fila(contador, inicio, siempre, [p(schwa), r, p(schwa)], m(cero)).
perezosa:alias(contador, m(K), pe(unos(K, m(s(K))), 0)).
perezosa:alias(contador, unos(cero, C), C).
perezosa:alias(contador, unos(s(K), C), pe(unos(K, C), 1)).
