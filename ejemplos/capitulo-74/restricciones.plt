:- encoding(utf8).

:- use_module(library(clpfd)).

:- begin_tests(restricciones).

test(cuatrimestre) :-
    oferta(cuatrimestre, O),
    once(horario_clpfd(O, [], H)),
    horario_valido(O, H).

test(cuatrimestre_momentos) :-
    oferta(cuatrimestre, O),
    once(horario_clpfd(O, [modelo(simple), etiquetar(momentos)], H)),
    horario_valido(O, H).

test(facultad_14_pares) :-
    oferta(facultad(14), O),
    once(horario_clpfd(O, [modelo(simple)], H)),
    horario_valido(O, H).

test(facultad_15_conteo, [fail]) :-
    oferta(facultad(15), O),
    horario_clpfd(O, [], _).

test(facultad_21, [fail]) :-
    oferta(facultad(21), O),
    horario_clpfd(O, [modelo(simple)], _).

test(dominio_del_aula, [true(Dom == 1..1)]) :-
    oferta(cuatrimestre, O),
    modelo(O, simple, H, _),
    memberchk(asignada(am1-1, A, _, _), H),
    fd_dom(A, Dom).

test(dominio_del_momento, [true(Dom == 12..18)]) :-
    oferta(cuatrimestre, O),
    modelo(O, simple, H, _),
    memberchk(asignada(bd-1, _, S, _), H),
    fd_dom(S, Dom).

test(propaga_el_fin, [true(F == 8)]) :-
    oferta(cuatrimestre, O),
    modelo(O, simple, H, _),
    memberchk(asignada(log-1, _, 7, F), H).

test(modelo_desconocido, [error(type_error(_, otro))]) :-
    oferta(cuatrimestre, O),
    modelo(O, otro, _, _).

test(conteo_sin_modelo, [fail]) :-
    oferta(facultad(15), O),
    findall(C, clase(O, C, _, _, _, _), Cs),
    findall(asignada(C, _, _, _), member(C, Cs), H),
    maplist(con_momento(O), H),
    conteo(O, H).

test(medir, [true(Hay == si)]) :-
    medir_clpfd(facultad(6), [], r(Hay, _)).

test(medir_sin_horario, [true(Hay == no)]) :-
    medir_clpfd(facultad(18), [], r(Hay, _)).

%!  con_momento(+Oferta, +Asignada) is det.
%
%   El momento de Asignada es una variable de la semana de Oferta.
con_momento(Oferta, asignada(_, _, S, _)) :-
    momentos(Oferta, N),
    Ultimo is N - 1,
    S in 0..Ultimo.

:- end_tests(restricciones).
