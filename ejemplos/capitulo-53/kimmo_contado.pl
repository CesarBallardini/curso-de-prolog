:- encoding(utf8).

% Capítulo 53 - Lo que cuesta compilar las reglas en cada llamada.
%
% kimmo.pl compila nasal y nasal_n en cada llamada a regla/2. costo/1
% cuenta las inferencias de generar «imposible» con kimmo.pl tal como
% está, y compilaciones/1 cuenta las veces que kimmo.pl compila una regla
% en esa generación: nasal_contada y nasal_n_contada repiten las de
% kimmo.pl contando con flag/3 cada compilación. kimmo_al_cargar.pl mide
% la misma generación con las reglas compiladas al cargar.
%
% solo-local: carga módulos.
%
%?- costo(N).
%?- compilaciones(N).

:- ensure_loaded(kimmo).

% contada(Regla, Nombre): Nombre es la Regla de kimmo.pl compilada en
% cada llamada y contada.
contada(nasal, nasal_contada).
contada(nasal_n, nasal_n_contada).

% Cada regla contada tiene su cláusula, con el nombre en la cabeza: la
% indexación por el primer argumento no prueba esta cláusula en las
% llamadas a las otras reglas, y no cambia lo que cuestan.
dos_niveles:regla(nasal_contada, Patrones) :-
    flag(compilaciones, N, N + 1),
    dos_niveles:regla(nasal, Patrones).
dos_niveles:regla(nasal_n_contada, Patrones) :-
    flag(compilaciones, N, N + 1),
    dos_niveles:regla(nasal_n, Patrones).

%!  reglas_de(+Momento, -Rs:list) is det.
%
%   Rs son las reglas de kimmo.pl, con nasal y nasal_n tal como están
%   (Momento es kimmo) o contadas (Momento es contando).
reglas_de(Momento, Rs) :-
    reglas(Todas),
    findall(R,
            ( member(R0, Todas),
              \+ contada(_, R0),
              (   Momento == contando,
                  contada(R0, R1)
              ->  R = R1
              ;   R = R0
              ) ),
            Rs).

%!  generar_imposible(+Rs:list, -Es:list) is det.
%
%   Es son las formas escritas de in+posible con las reglas Rs.
generar_imposible(Rs, Es) :-
    findall(E,
            transducir(paralelo(Rs), [i, 'N', +, p, o, s, i, b, l, e], E),
            Es).

%!  costo(-Inferencias:integer) is det.
%
%   Inferencias es lo que cuesta generar «imposible», con las tablas
%   vacías, con kimmo.pl tal como está.
costo(Inferencias) :-
    reglas_de(kimmo, Rs),
    abolish_all_tables,
    statistics(inferences, I0),
    generar_imposible(Rs, _),
    statistics(inferences, I1),
    Inferencias is I1 - I0.

%!  compilaciones(-N:integer) is det.
%
%   N es la cantidad de veces que kimmo.pl compila nasal o nasal_n al
%   generar «imposible» con las tablas vacías.
compilaciones(N) :-
    reglas_de(contando, Rs),
    abolish_all_tables,
    flag(compilaciones, _, 0),
    generar_imposible(Rs, _),
    flag(compilaciones, N, N).
