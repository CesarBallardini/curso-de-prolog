:- encoding(utf8).

:- begin_tests(pantalla).

%!  teclas(+Texto:string, -Teclas:list) is det.
%
%   Teclas son las teclas que leer_tecla/2 obtiene de Texto, hasta fin.
teclas(Texto, Teclas) :-
    setup_call_cleanup(open_string(Texto, In),
                       leer_todas(In, Teclas),
                       close(In)).

%!  leer_todas(+In, -Teclas:list) is det.
%
%   Teclas son las teclas de In, hasta fin, que no se incluye.
leer_todas(In, Teclas) :-
    leer_tecla(get_code(In), Tecla),
    (   Tecla == fin
    ->  Teclas = []
    ;   Teclas = [Tecla|Resto],
        leer_todas(In, Resto)
    ).

test(caja, true(C == ["┌─ Hola ────┐",
                      "│ uno       │",
                      "│ dos largo │",
                      "└───────────┘"])) :-
    caja("Hola", ["uno", "dos largo"], C).

test(titulo_largo, true(C == ["┌─ Minas ┐",
                              "│ a      │",
                              "└────────┘"])) :-
    caja("Minas", ["a"], C).

test(sin_titulo, true(C == ["┌─────┐", "│ abc │", "└─────┘"])) :-
    caja("", ["abc"], C).

test(flechas, true(T == [arriba, abajo, derecha, izquierda])) :-
    teclas("\e[A\e[B\e[C\e[D", T).

test(otras, true(T == [enter, espacio, letra(m), letra(q), enter, otra,
                       otra])) :-
    teclas("\r mq\n\e[Z\t", T).

test(dibujar, true(S == "\e[2J\e[H\e[1;1Hab\e[2;1Hc")) :-
    with_output_to(string(S), dibujar(["ab", "c"])).

test(con_pantalla, true(S == "\e[?25lx\e[?25h\n")) :-
    with_output_to(string(S), con_pantalla(write(x))).

% Cuando tty_size/2 produce un error, porque la salida no es una terminal,
% tamanio/2 da el tamaño por omisión.
test(tamanio, [ condition(\+ catch(tty_size(_, _), _, fail)),
                true(F-C == 24-80) ]) :-
    tamanio(F, C).

test(ir_a, true(S == "\e[3;10H")) :-
    with_output_to(string(S), ir_a(3, 10)).

test(repetir, true(S == "─────")) :-
    pantalla:repetir("─", 5, S).

% Una entrada vacía da la tecla fin, y no espera.
test(fin, true(T == fin)) :-
    setup_call_cleanup(open_string("", In),
                       leer_tecla(get_code(In), T),
                       close(In)).

test(limpiar, true(S == "\e[2J\e[H")) :-
    with_output_to(string(S), limpiar).

% Un recuadro sin líneas tiene solo los dos bordes.
test(caja_vacia, true(C == ["┌─ T ┐", "└────┘"])) :-
    caja("T", [], C).

% El cursor vuelve a mostrarse aunque el objetivo produzca un error o falle.
test(con_pantalla_error, true(S == "\e[?25l\e[?25h\n")) :-
    with_output_to(string(S), catch(con_pantalla(throw(e)), e, true)).

test(con_pantalla_falla, true(S-R == "\e[?25l\e[?25h\n"-fallo)) :-
    with_output_to(string(S),
                   (   con_pantalla(fail)
                   ->  R = exito
                   ;   R = fallo
                   )).

% Una secuencia de escape cortada por el fin de la entrada es otra tecla, y
% la lectura siguiente da fin.
test(escape_cortado, true(T == [otra])) :-
    teclas("\e", T).

:- end_tests(pantalla).
