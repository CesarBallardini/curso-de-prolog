:- encoding(utf8).

:- begin_tests(soluciones_revision).

test(ejercicio_5, [true(Avisos == [aviso(texto:4, encabezado_ajeno, suma/3)])]) :-
    encabezados_ajenos(encabezado_ajeno, Avisos).

% Un no terminal, un predicado de otro módulo y una línea que continúa la
% anterior se leen bien.
test(ejercicio_5_declarado, [true(Ps == [palabras/3, message/3, p/1])]) :-
    findall(P, ( member(C, [ "%!  palabras(-Ps:list)// is det.",
                             "%!  prolog:message(+Mensaje)// is semidet.",
                             "%!  p(+X)\n%!      is det." ]),
                 declarado(C, P) ),
            Ps).

% Inscripciones no tiene encabezados ajenos.
test(ejercicio_5_inscripciones, [true(Avisos == [])]) :-
    archivos(inscripciones, Fs),
    maplist(leer_archivo, Fs, PorArchivo),
    maplist(encabezados_ajenos_de, PorArchivo, Avisos0),
    append(Avisos0, Avisos).

test(ejercicio_10_raices, [true(Rs == [caso/2, como/2, identificar/2,
                                       por_que_no/2])]) :-
    raices_consultadas(ejemplos('capitulo-33/experto.pl'), Rs).

% Desde sus tres consultas, experto.pl alcanza todo salvo consultar/1.
test(ejercicio_10, [true(Ps == [consultar/1])]) :-
    no_usados_del_ejemplo(ejemplos('capitulo-33/experto.pl'), Ps).

:- end_tests(soluciones_revision).
