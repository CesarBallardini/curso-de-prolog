:- encoding(utf8).

% Pruebas de acuerdo.pl: el ejemplo de juguete (P = 23, G = 5), el primo
% del grupo 14, el acuerdo con exponentes aleatorios, las claves
% derivadas y el canal: ida y vuelta, y alteraciones detectadas.

:- use_module(rsa, [primo/1]).

%!  canal(-Claves) is det.
%
%   Claves son las claves de sesión de un acuerdo nuevo en el grupo 14.
canal(Claves) :-
    secreto_aleatorio(X),
    secreto_aleatorio(Y),
    publico(rfc3526_14, Y, B),
    compartido(rfc3526_14, X, B, S),
    claves_de_sesion(S, Claves).

:- begin_tests(acuerdo).

test(juguete, true(A-B-S1-S2 == 8-19-2-2)) :-
    publico(juguete, 6, A),
    publico(juguete, 15, B),
    compartido(juguete, 6, B, S1),
    compartido(juguete, 15, A, S2).

test(grupo_14_seguro) :-
    grupo(rfc3526_14, P, 2),
    2048 =:= msb(P) + 1,
    primo(P),
    Q is (P - 1) // 2,
    primo(Q).

test(acuerdo, true(S1 == S2)) :-
    secreto_aleatorio(X),
    secreto_aleatorio(Y),
    publico(rfc3526_14, X, A),
    publico(rfc3526_14, Y, B),
    compartido(rfc3526_14, X, B, S1),
    compartido(rfc3526_14, Y, A, S2).

test(publico_trivial, [fail]) :-
    compartido(juguete, 6, 1, _).

test(claves_distintas, true(Kc \== Ka)) :-
    claves_de_sesion(2, claves(Kc, Ka)),
    atom_length(Kc, 64).

test(claves_rfc_5869, true(Kc == Kc1)) :-
    claves_de_sesion(12345, claves(Kc, _)),
    crypto_data_hkdf('3039', 32, Bs, [info(cifrado), algorithm(sha256)]),
    hex_bytes(Kc1, Bs).

test(flujo_largo, true(L == 70)) :-
    flujo(clave, abc, 70, Bs),
    length(Bs, L).

test(flujo_prefijo, true(A == B)) :-
    flujo(clave, abc, 70, Bs),
    flujo(clave, abc, 32, A),
    length(B, 32),
    append(B, _, Bs).

test(cifrar_involucion, true(Bs == [1, 2, 3, 250])) :-
    cifrar(clave, abc, [1, 2, 3, 250], C),
    cifrar(clave, abc, C, Bs).

test(ida_y_vuelta, true(T == "Inscripción aceptada en ssl")) :-
    canal(Claves),
    sellar(Claves, "Inscripción aceptada en ssl", M),
    abrir(Claves, M, T).

test(nonce_distinto, true(C1 \== C2)) :-
    canal(Claves),
    sellar(Claves, "igual", mensaje(_, C1, _)),
    sellar(Claves, "igual", mensaje(_, C2, _)).

test(alterado, [fail]) :-
    canal(Claves),
    sellar(Claves, "Pagar 100 pesos a Ana", M0),
    alterar(M0, 6, '100', '900', M),
    abrir(Claves, M, _).

test(alterado_sin_mac, true(T == "Pagar 900 pesos a Ana")) :-
    canal(Claves),
    sellar(Claves, "Pagar 100 pesos a Ana", M0),
    alterar(M0, 6, '100', '900', M),
    abrir_sin_mac(Claves, M, T).

test(acordar, true(CA == CB)) :-
    acordar(rfc3526_14, CA, CB).

test(acordar_distinto, true(C1 \== C2)) :-
    acordar(rfc3526_14, C1, _),
    acordar(rfc3526_14, C2, _).

test(otras_claves, [fail]) :-
    canal(C1),
    canal(C2),
    sellar(C1, "secreto", M),
    abrir(C2, M, _).

:- end_tests(acuerdo).
