:- encoding(utf8).

:- begin_tests(soluciones_pantalla).

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

test(largo_visible, true(N == 3)) :-
    largo_visible("a\e[31m*\e[0mb", N).

test(caja_con_color, true(C == ["┌─ M ─┐",
                                "│ \e[31m*\e[0m   │",
                                "│ abc │",
                                "└─────┘"])) :-
    caja("M", ["\e[31m*\e[0m", "abc"], C).

test(teclas_nuevas, true(T == [inicio, letra(a), final, letra(b), suprimir,
                               letra(c), borrar, arriba])) :-
    teclas("\e[Ha\e[Fb\e[3~c\x7F\\e[A", T).

test(tilde_desconocida, true(T == [otra, letra(x)])) :-
    teclas("\e[5~x", T).

test(lado_a_lado, true(L == ["┌─┐  ┌──┐",
                             "│a│  │bb│",
                             "└─┘  │cc│",
                             "     └──┘"])) :-
    lado_a_lado(["┌─┐", "│a│", "└─┘"], ["┌──┐", "│bb│", "│cc│", "└──┘"], L).

test(misma_altura, true(L == ["x  y"])) :-
    lado_a_lado(["x"], ["y"], L).

:- end_tests(soluciones_pantalla).
