:- encoding(utf8).

:- begin_tests(soluciones_yale).

% Con la especificidad sola, la descarga y la persistencia se derrotan: no
% se sabe si el arma está cargada, y la regla causal del disparo no se
% aplica.
test(especificidad,
     [true(H == [inicio-definitivamente_si-definitivamente_si,
                 descarga-sin_conclusion-presumiblemente_si,
                 espera-sin_conclusion-presumiblemente_si,
                 disparo-sin_conclusion-presumiblemente_si])]) :-
    historia([especificidad], [descarga, espera, disparo], H).

test(declarada,
     [true(H == [inicio-definitivamente_si-definitivamente_si,
                 descarga-presumiblemente_no-presumiblemente_si,
                 espera-presumiblemente_no-presumiblemente_si,
                 disparo-presumiblemente_no-presumiblemente_si])]) :-
    historia([declarada], [descarga, espera, disparo], H).

% Sin descarga, la historia es la del disparo de Yale.
test(sin_descarga,
     [true(H == [inicio-definitivamente_si-definitivamente_si,
                 espera-presumiblemente_si-presumiblemente_si,
                 disparo-presumiblemente_si-presumiblemente_no])]) :-
    historia([declarada, especificidad], [espera, disparo], H).

test(despues, [true(S == result(e, s0))]) :-
    despues(e, s0, S).

:- end_tests(soluciones_yale).
