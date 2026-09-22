:- encoding(utf8).

% Capítulo 4 - Términos compuestos.
%
% Una ficha reúne varios datos en un solo término: la mascota, su fecha de
% nacimiento y su propietario. Contiene otros términos, y para extraer sus
% componentes no se requiere ningún mecanismo nuevo: es suficiente la
% unificación.
%
%?- registro(F).
%?- registro(F), especie(F, gato).

% registro(F): F es la ficha de una mascota.
registro(ficha(mascota(gato, felix), fecha(2021, 5, 3), ana)).
registro(ficha(mascota(perro, rocco), fecha(2019, 11, 20), luis)).
registro(ficha(mascota(gato, gaturro), fecha(2023, 2, 14), eva)).

% especie(F, E): E es la especie de la mascota de la ficha F.
especie(ficha(mascota(E, _), _, _), E).

% nombre_de(F, N): N es el nombre de la mascota de la ficha F.
nombre_de(ficha(mascota(_, N), _, _), N).

% nacio_en(F, A): A es el año en que nació la mascota de la ficha F.
nacio_en(ficha(_, fecha(A, _, _), _), A).

% propietario_de(F, P): P es el propietario de la mascota de la ficha F.
propietario_de(ficha(_, _, P), P).
