:- encoding(utf8).

% Capítulo 38 - Solución del ejercicio 15: dos reglas más en la base del
% sistema experto, que crean un ciclo con una negación, y su corrección.
% Usa base/2, regla_clausula/2 y los evaluadores que carga experto.pl; el
% programa herbivoros(Version) es la base con las reglas nuevas.
%
% solo-local: carga experto.pl con ensure_loaded/1, y SWISH no permite
% cargar otro archivo.
%
%?- ciclos_negativos(herbivoros(ciclo), P).
%?- valor(con_hechos(herbivoros(ciclo), [tiene_pelo]), carnivoro, V).

:- ensure_loaded(experto).

% nueva(Version, Nombre, Regla): Version agrega Regla, llamada Nombre, a la
% versión puede_volar de la base.
nueva(ciclo, r14, si mamifero y no carnivoro entonces herbivoro).
nueva(ciclo, r15, si herbivoro y no tiene_cascos entonces carnivoro).
nueva(corregida, r14, si mamifero y no come_carne entonces herbivoro).

%!  con_herbivoros(+Version:atom, -Clausulas:list) is det.
%
%   Clausulas son las de la versión puede_volar de la base con las reglas
%   nuevas de Version, ciclo o corregida.
con_herbivoros(Version, Clausulas) :-
    must_be(oneof([ciclo, corregida]), Version),
    base(puede_volar, Base),
    findall(C,
            ( nueva(Version, _, Regla),
              regla_clausula(Regla, C) ),
            Nuevas),
    append(Base, Nuevas, Clausulas).

:- multifile generado/2.

%!  generado(+Programa, -Clausulas:list) is semidet.
%
%   El programa herbivoros(Version): las cláusulas de con_herbivoros/2.
generado(herbivoros(Version), Clausulas) :-
    con_herbivoros(Version, Clausulas).
