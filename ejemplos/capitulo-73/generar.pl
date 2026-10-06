:- encoding(utf8).

% Capítulo 73 - Versión 1: generar y probar.
%
% La versión más directa: generar un horario completo, con un momento y un
% aula para cada clase, y probarlo con horario_valido/2. Si la prueba
% falla, la vuelta atrás cambia la última clase generada y prueba de
% nuevo. El programa es correcto, porque la prueba es la definición de
% horario válido, pero examina los candidatos de a uno, y su cantidad es
% (momentos x aulas) elevado a la cantidad de clases.
%
% solo-local: carga otros archivos, y SWISH no permite cargar otro archivo.
%
%?- candidatos(materias([am1, alg], 3, 2), K).
%?- ensayos(materias([am1, alg], 3, 2), K).

:- module(generar,
          [ generar_y_probar/2,
            candidatos/2,
            ensayos/2
          ]).

:- reexport(oferta).

%!  generar_y_probar(+Oferta, -Horario:list) is nondet.
%
%   Horario es un horario válido de Oferta. Genera cada horario posible y
%   lo prueba entero.
generar_y_probar(Oferta, Horario) :-
    generar(Oferta, Horario),
    horario_valido(Oferta, Horario).

%!  generar(+Oferta, -Horario:list) is multi.
%
%   Horario da a cada clase de Oferta un momento de la semana y un aula,
%   sin verificar nada más.
generar(Oferta, Horario) :-
    findall(C, clase(Oferta, C, _, _, _, _), Clases),
    momentos(Oferta, N),
    Oferta = oferta(_, _, Aulas, _),
    length(Aulas, NA),
    maplist(candidata(N, NA), Clases, Horario).

%!  candidata(+N:integer, +NA:integer, +Clase, -Asignada) is multi.
%
%   Asignada pone Clase en uno de los N momentos y una de las NA aulas.
candidata(N, NA, Clase, asignada(Clase, A, S, F)) :-
    Ultimo is N - 1,
    between(0, Ultimo, S),
    between(1, NA, A),
    F is S + 1.

%!  candidatos(+Nombre, -K:integer) is det.
%
%   K es la cantidad de horarios que generar/2 puede producir para la
%   oferta de ejemplo Nombre: (momentos x aulas) elevado a la cantidad de
%   clases.
candidatos(Nombre, K) :-
    oferta(Nombre, Oferta),
    aggregate_all(count, clase(Oferta, _, _, _, _, _), C),
    momentos(Oferta, N),
    Oferta = oferta(_, _, Aulas, _),
    length(Aulas, NA),
    K is (N * NA) ^ C.

%!  ensayos(+Nombre, -K:integer) is semidet.
%
%   K es la cantidad de horarios que generar_y_probar/2 prueba en la
%   oferta de ejemplo Nombre hasta encontrar el primero válido. Falla si
%   la oferta no tiene ningún horario.
ensayos(Nombre, K) :-
    oferta(Nombre, Oferta),
    nb_setval(ensayos, 0),
    once(( generar(Oferta, Horario),
           nb_getval(ensayos, K0),
           K1 is K0 + 1,
           nb_setval(ensayos, K1),
           horario_valido(Oferta, Horario) )),
    nb_getval(ensayos, K).
