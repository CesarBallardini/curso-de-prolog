:- encoding(utf8).

:- begin_tests(init).

test(el_editor_es_vs_code, all(E == [code])) :-
    current_prolog_flag(editor, E).

% edit/1 construye esta línea de comandos para abrir un archivo en la línea 12.
test(el_comando_abre_en_la_linea, [nondet]) :-
    prolog_edit:edit_command(code, Comando),
    sub_atom(Comando, _, _, _, '--goto'),
    sub_atom(Comando, _, _, _, '--wait').

:- end_tests(init).
