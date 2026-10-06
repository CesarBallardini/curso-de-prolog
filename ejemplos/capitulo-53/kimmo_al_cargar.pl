:- encoding(utf8).

% Capítulo 53 - La versión 5 con las reglas compiladas al cargar.
%
% kimmo.pl compila nasal y nasal_n en cada llamada a regla/2, con una
% cláusula cuyo primer argumento es una variable: esa cláusula se prueba,
% y falla, también en cada llamada a las otras reglas. Este archivo carga
% kimmo.pl sin esa cláusula, y term_expansion/2 compila las dos reglas
% una sola vez, al cargar, como hechos de regla/2 con los mismos nombres.
% costo/1 cuenta las inferencias de generar «imposible»;
% kimmo_contado.pl mide la misma generación con kimmo.pl tal como está.
%
% solo-local: carga módulos.
%
%?- costo(N).

% Al cargar kimmo.pl, su cláusula que compila en cada llamada se
% reemplaza por ninguna cláusula. Al cargar este archivo, la línea
% reglas_al_cargar se reemplaza por un hecho dos_niveles:regla(Nombre,
% Patrones) por cada regla compilada.
term_expansion((dos_niveles:regla(_, _) :- member(_, [nasal, nasal_n]), _),
               []).
term_expansion(reglas_al_cargar, Clausulas) :-
    findall(dos_niveles:regla(Nombre, Patrones),
            ( member(Nombre, [nasal, nasal_n]),
              regla_dos_niveles(Nombre, Par, Op, Izquierda, Derechas),
              compilar(Par, Op, Izquierda, Derechas, Patrones) ),
            Clausulas).

:- ensure_loaded(kimmo).

reglas_al_cargar.

%!  generar_imposible(-Es:list) is det.
%
%   Es son las formas escritas de in+posible con todas las reglas.
generar_imposible(Es) :-
    reglas(Rs),
    findall(E,
            transducir(paralelo(Rs), [i, 'N', +, p, o, s, i, b, l, e], E),
            Es).

%!  costo(-Inferencias:integer) is det.
%
%   Inferencias es lo que cuesta generar «imposible», con las tablas
%   vacías y las reglas compiladas al cargar.
costo(Inferencias) :-
    abolish_all_tables,
    statistics(inferences, I0),
    generar_imposible(_),
    statistics(inferences, I1),
    Inferencias is I1 - I0.
