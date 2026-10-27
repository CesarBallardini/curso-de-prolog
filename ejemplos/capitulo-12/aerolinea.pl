:- encoding(utf8).

% Capítulo 12 - Ejercicio 15: aerolínea.
%
% Las fechas son términos fecha(Anio, Mes, Dia): en ese orden, el orden
% estándar de los términos, que compara los argumentos de izquierda a
% derecha, es el orden cronológico, y @=< compara dos fechas.
%
%?- vuelo_completo(T, D).
%?- asientos_disponibles('IB750', fecha(2023, 1, 10), N).
%?- tramo_mas_popular(Desde, Hasta).
%?- cantidad_km('IB750', N).

% vuelo(T, Desde, Hasta, Precio): el vuelo T une Desde con Hasta y cuesta
% Precio.
vuelo('IB750', 'Bruselas', 'BsAs', 151000).
vuelo('IB752', 'Bruselas', 'BsAs', 148000).
vuelo('AR1132', 'Madrid', 'BsAs', 120000).

% vuelo_tramo(T, N, Desde, Hasta, Km): el tramo N del vuelo T une Desde con
% Hasta y tiene Km kilómetros.
vuelo_tramo('IB750', 1, 'Bruselas', 'Madrid', 1272).
vuelo_tramo('IB750', 2, 'Madrid', 'SanPablo', 9725).
vuelo_tramo('IB750', 3, 'SanPablo', 'BsAs', 1675).
vuelo_tramo('IB752', 1, 'Bruselas', 'Madrid', 1272).
vuelo_tramo('IB752', 2, 'Madrid', 'BsAs', 10040).
vuelo_tramo('AR1132', 1, 'Madrid', 'BsAs', 10040).

% vuelo_diario(T, D, Avion, Asientos): el vuelo T se realiza el día D con el
% avión Avion, que tiene Asientos asientos.
vuelo_diario('IB750', fecha(2023, 1, 10), 99765, 350).
vuelo_diario('IB752', fecha(2023, 2, 12), 88120, 300).
vuelo_diario('AR1132', fecha(2023, 1, 15), 77001, 280).
vuelo_diario('AR1132', fecha(2023, 2, 20), 77001, 280).
vuelo_diario('AR1132', fecha(2023, 3, 3), 77001, 280).

% segmento_vuelo_diario(T, N, D, Disponibles): el tramo N del vuelo T del
% día D tiene Disponibles asientos disponibles.
segmento_vuelo_diario('IB750', 1, fecha(2023, 1, 10), 312).
segmento_vuelo_diario('IB750', 2, fecha(2023, 1, 10), 350).
segmento_vuelo_diario('IB750', 3, fecha(2023, 1, 10), 312).
segmento_vuelo_diario('IB752', 1, fecha(2023, 2, 12), 0).
segmento_vuelo_diario('IB752', 2, fecha(2023, 2, 12), 0).
segmento_vuelo_diario('AR1132', 1, fecha(2023, 1, 15), 0).
segmento_vuelo_diario('AR1132', 1, fecha(2023, 2, 20), 0).
segmento_vuelo_diario('AR1132', 1, fecha(2023, 3, 3), 41).

%!  vuelo_completo(?T, ?D) is nondet.
%
%   El vuelo T del día D no tiene asientos disponibles en al menos uno de sus
%   tramos. El doble \+ prueba que existe ese tramo sin ligar su número: una
%   respuesta por vuelo y día, aunque haya varios tramos completos.
vuelo_completo(T, D) :-
    vuelo_diario(T, D, _, _),
    \+ \+ segmento_vuelo_diario(T, _, D, 0).

%!  asientos_disponibles(?T, ?D, ?N) is nondet.
%
%   N es el mínimo de los asientos disponibles en los tramos del vuelo T del
%   día D: ningún tramo tiene menos, y ningún tramo anterior tiene los
%   mismos.
asientos_disponibles(T, D, N) :-
    segmento_vuelo_diario(T, Tramo, D, N),
    \+ ( segmento_vuelo_diario(T, _, D, Otro),
         Otro < N ),
    \+ ( segmento_vuelo_diario(T, Anterior, D, N),
         Anterior < Tramo ).

%!  en_periodo(+D) is semidet.
%
%   La fecha D está entre el 1/1/2023 y el 28/2/2023, inclusive.
en_periodo(D) :-
    fecha(2023, 1, 1) @=< D,
    D @=< fecha(2023, 2, 28).

%!  ruta(?Desde, ?Hasta) is nondet.
%
%   Algún vuelo une Desde con Hasta y se realizó en el período. Cada ruta se
%   obtiene una vez, con el vuelo de menor identificador.
ruta(Desde, Hasta) :-
    vuelo(T, Desde, Hasta, _),
    \+ ( vuelo(Otro, Desde, Hasta, _),
         Otro @< T ),
    \+ \+ ( vuelo(T2, Desde, Hasta, _),
            vuelo_diario(T2, D, _, _),
            en_periodo(D) ).

%!  tramo_mas_popular(?Desde, ?Hasta) is nondet.
%
%   Todos los vuelos del período que unen Desde con Hasta estuvieron
%   completos: no hubo ninguno con asientos disponibles en todos sus tramos.
tramo_mas_popular(Desde, Hasta) :-
    ruta(Desde, Hasta),
    \+ ( vuelo(T, Desde, Hasta, _),
         vuelo_diario(T, D, _, _),
         en_periodo(D),
         \+ vuelo_completo(T, D) ).

%!  cantidad_km(?T, ?N) is nondet.
%
%   N es la suma de los kilómetros de todos los tramos del vuelo T.
cantidad_km(T, N) :-
    vuelo(T, _, _, _),
    km_desde(T, 1, N).

%!  km_desde(+T, +Tramo, -N) is det.
%
%   N es la suma de los kilómetros de los tramos del vuelo T a partir del
%   tramo de número Tramo. Los tramos se numeran desde 1 sin saltos.
km_desde(T, Tramo, 0) :-
    \+ vuelo_tramo(T, Tramo, _, _, _).
km_desde(T, Tramo, N) :-
    vuelo_tramo(T, Tramo, _, _, Km),
    Siguiente is Tramo + 1,
    km_desde(T, Siguiente, Resto),
    N is Km + Resto.
