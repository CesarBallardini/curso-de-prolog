:- encoding(utf8).

% Capítulo 44 - Versión 1 de la aventura: el mundo como hechos.
%
% El mundo es un observatorio abandonado. Todo lo que no cambia durante la
% partida está en hechos: los nombres, las salas, las puertas y las
% propiedades de los objetos. El estado inicial también está en hechos,
% inicio/1, escrito con los mismos términos que usará el estado del juego
% (versión 2). Los predicados de datos son multifile: otro archivo agrega
% salas u objetos con cláusulas mundo:sala(...), sin tocar este.
%
% solo-local: SWISH no admite módulos propios.
%
%?- conecta(P, vestibulo, S).

:- module(mundo,
          [ nombre/3,
            sala/2,
            puerta/3,
            fijo/1,
            recipiente/1,
            luz/1,
            llave_de/2,
            oscura/1,
            inicio/1,
            meta/1,
            final/1,
            conecta/3,
            objeto/1
          ]).

:- multifile
    nombre/3,
    sala/2,
    puerta/3,
    fijo/1,
    recipiente/1,
    luz/1,
    llave_de/2,
    oscura/1,
    inicio/1.

% nombre(X, G, Texto): la sala, la puerta o el objeto X se llama Texto, un
% sustantivo de género G (m o f).
nombre(vestibulo, m, "vestíbulo").
nombre(biblioteca, f, "biblioteca").
nombre(taller, m, "taller").
nombre(sotano, m, "sótano").
nombre(cupula, f, "cúpula").
nombre(puerta_biblioteca, f, "puerta de la biblioteca").
nombre(puerta_taller, f, "puerta del taller").
nombre(trampilla, f, "trampilla").
nombre(escalera, f, "escalera").
nombre(perchero, m, "perchero").
nombre(escritorio, m, "escritorio").
nombre(llave, f, "llave de bronce").
nombre(catalogo, m, "catálogo de estrellas").
nombre(linterna, f, "linterna").
nombre(banco, m, "banco de trabajo").
nombre(baul, m, "baúl").
nombre(lente, f, "lente").
nombre(telescopio, m, "telescopio").

% sala(S, Descripcion): S es una sala, y Descripcion es lo que se ve en ella.
sala(vestibulo, "Un vestíbulo con baldosas gastadas y olor a humedad.").
sala(biblioteca, "Estantes hasta el techo, casi todos vacíos.").
sala(taller, "Herramientas oxidadas cuelgan de las paredes.").
sala(sotano, "Un sótano bajo, de paredes de piedra.").
sala(cupula, "La cúpula de metal está abierta hacia el cielo.").

% puerta(P, S1, S2): el paso P une las salas S1 y S2, en los dos sentidos.
puerta(puerta_biblioteca, vestibulo, biblioteca).
puerta(puerta_taller, vestibulo, taller).
puerta(trampilla, taller, sotano).
puerta(escalera, biblioteca, cupula).

% fijo(O): el objeto O no se puede llevar.
fijo(perchero).
fijo(escritorio).
fijo(banco).
fijo(baul).
fijo(telescopio).

% recipiente(O): el objeto O puede contener otros objetos.
recipiente(escritorio).
recipiente(banco).
recipiente(baul).
recipiente(telescopio).

% luz(O): el objeto O se enciende y alumbra.
luz(linterna).

% llave_de(L, P): hace falta llevar L para abrir P.
llave_de(llave, puerta_taller).

% oscura(S): la sala S no tiene luz propia.
oscura(sotano).

% inicio(H): el hecho H del estado vale al empezar una partida.
inicio(aqui(vestibulo)).
inicio(esta_en(perchero, vestibulo)).
inicio(esta_en(escritorio, biblioteca)).
inicio(esta_en(llave, escritorio)).
inicio(esta_en(catalogo, biblioteca)).
inicio(esta_en(banco, taller)).
inicio(esta_en(linterna, banco)).
inicio(esta_en(baul, sotano)).
inicio(esta_en(lente, baul)).
inicio(esta_en(telescopio, cupula)).
inicio(cerrada(puerta_taller)).
inicio(cerrada(trampilla)).
inicio(cerrada(baul)).

% meta(H): la partida se gana cuando vale el hecho H.
meta(esta_en(lente, telescopio)).

% final(Texto): Texto es lo que se muestra al ganar la partida.
final("Con la lente en su lugar, el telescopio muestra el cielo nocturno.").

%!  conecta(?P, ?S1, ?S2) is nondet.
%
%   El paso P lleva de la sala S1 a la sala S2, en cualquiera de los dos
%   sentidos en que está escrito.
conecta(P, S1, S2) :-
    puerta(P, S1, S2).
conecta(P, S1, S2) :-
    puerta(P, S2, S1).

%!  objeto(?O) is nondet.
%
%   O es un objeto: tiene nombre y no es una sala ni un paso.
objeto(O) :-
    nombre(O, _, _),
    \+ sala(O, _),
    \+ puerta(O, _, _).
