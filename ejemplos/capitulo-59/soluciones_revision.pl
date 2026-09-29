:- encoding(utf8).

% Capítulo 59 - Soluciones de los ejercicios 5 y 10: un encabezado que
% describe otro predicado, y las consultas %?- de un ejemplo como puntos de
% entrada.
%
% solo-local: lee archivos y carga analisis.pl.
%
%?- encabezados_ajenos(encabezado_ajeno, Avisos).
%?- raices_consultadas(ejemplos('capitulo-33/experto.pl'), Rs).
%?- no_usados_del_ejemplo(ejemplos('capitulo-33/experto.pl'), Ps).

:- ensure_loaded(analisis).

:- multifile user:file_search_path/2.
:- prolog_load_context(directory, Aqui),
   directory_file_path(Aqui, '..', Dir),
   asserta(user:file_search_path(ejemplos, Dir)).

% Ejercicio 5: el encabezado que describe otro predicado.

%!  texto(+Nombre, -Texto:string) is semidet.
%
%   Cláusula agregada: encabezado_ajeno es un programa cuyo encabezado de
%   suma/2 dice suma/3.
texto(encabezado_ajeno, Texto) :-
    Lineas = [ "%!  suma(+Ns:list, +S0:number, -S:number) is det.",
               "%",
               "%   S es la suma de Ns.",
               "suma([], 0).",
               "suma([N|Ns], S) :-",
               "    suma(Ns, S0),",
               "    S is S0 + N."
             ],
    atomic_list_concat(Lineas, '\n', Atomo),
    atom_string(Atomo, Texto).

%!  encabezados_ajenos(+Nombre, -Avisos:list) is det.
%
%   encabezados_ajenos_de/2 sobre los términos del texto llamado Nombre.
encabezados_ajenos(Nombre, Avisos) :-
    texto(Nombre, Texto),
    setup_call_cleanup(open_string(Texto, Stream),
                       leer_terminos(Stream, texto, Leidos),
                       close(Stream)),
    encabezados_ajenos_de(Leidos, Avisos).

%!  encabezados_ajenos_de(+Leidos:list, -Avisos:list) is det.
%
%   Avisos tiene un aviso aviso(P, encabezado_ajeno, D) por cada predicado
%   cuya primera cláusula, en P, va precedida por encabezados %! y ninguno
%   declara ese predicado: D es el que declara el primero.
encabezados_ajenos_de(Leidos, Avisos) :-
    findall(PI, clausula_leida(Leidos, _, PI), PIs0),
    list_to_set(PIs0, PIs),
    findall(aviso(P, encabezado_ajeno, D),
            ( member(PI, PIs),
              once(clausula_leida(Leidos, leido(_, P, _, Cs), PI)),
              findall(D0, ( member(C, Cs),
                            declarado(C, D0) ),
                      [D|Ds]),
              \+ memberchk(PI, [D|Ds]) ),
            Avisos).

%!  declarado(+Comentario:string, -PI) is nondet.
%
%   PI es el predicado que declara una línea %! de Comentario: el texto que
%   sigue a %!, hasta " is ", leído como un término; un no terminal
%   termina en // y tiene dos argumentos más, y el módulo de un predicado
%   de otro módulo no cuenta. Una línea que no se puede leer no declara
%   nada, ni una línea que continúa la anterior.
declarado(Comentario, Nombre/Aridad) :-
    split_string(Comentario, "\n", "", Lineas),
    member(Linea, Lineas),
    string_concat("%!", Resto, Linea),
    (   sub_string(Resto, Antes, _, _, " is ")
    ->  sub_string(Resto, 0, Antes, _, Cabeza0)
    ;   Cabeza0 = Resto
    ),
    normalize_space(string(Cabeza1), Cabeza0),
    Cabeza1 \== "",
    (   string_concat(Cabeza, "//", Cabeza1)
    ->  Mas = 2
    ;   Cabeza = Cabeza1,
        Mas = 0
    ),
    catch(term_string(Termino, Cabeza), error(syntax_error(_), _), fail),
    callable(Termino),
    sin_calificar(Termino, Cabeza2),
    functor(Cabeza2, Nombre, Aridad0),
    Aridad is Aridad0 + Mas.

% Ejercicio 10: las consultas de un ejemplo como puntos de entrada.

%!  raices_consultadas_de(+Leidos:list, -Raices:list) is det.
%
%   Raices son los predicados que llaman las consultas escritas en los
%   comentarios %?- de Leidos, ordenados.
raices_consultadas_de(Leidos, Raices) :-
    findall(PI, ( member(leido(_, _, _, Cs), Leidos),
                  member(C, Cs),
                  split_string(C, "\n", "", Lineas),
                  member(Linea, Lineas),
                  string_concat("%?- ", Texto, Linea),
                  catch(term_string(Consulta, Texto, [module(externo)]),
                        error(syntax_error(_), _), fail),
                  metas(Consulta, Metas),
                  member(M, Metas),
                  indicador(M, PI) ),
            PIs),
    sort(PIs, Raices).

%!  raices_consultadas(+Archivo, -Raices:list) is det.
%
%   raices_consultadas_de/2 sobre los términos de Archivo, una ruta o una
%   especificación, como ejemplos('capitulo-33/experto.pl').
raices_consultadas(Archivo, Raices) :-
    absolute_file_name(Archivo, Ruta, [file_type(prolog), access(read)]),
    leer_archivo(Ruta, Leidos),
    raices_consultadas_de(Leidos, Raices).

%!  no_usados_del_ejemplo(+Archivo, -Ps:list) is det.
%
%   Ps son los predicados de Archivo, una ruta o una especificación, que no
%   se alcanzan ni desde sus puntos de entrada ni desde sus consultas %?-.
no_usados_del_ejemplo(Archivo, Ps) :-
    absolute_file_name(Archivo, Ruta, [file_type(prolog), access(read)]),
    leer_archivo(Ruta, Leidos),
    programa(Leidos, Clausulas, Raices0),
    raices_consultadas_de(Leidos, Raices1),
    append(Raices0, Raices1, Raices),
    no_usados_de(Clausulas, Raices, Ps).
