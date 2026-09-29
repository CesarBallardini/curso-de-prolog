:- encoding(utf8).

% Capítulo 74 - Las búsquedas del capítulo 40, aplicadas al cubo.
%
% visitados.pl y profundizacion.pl del capítulo 40 no son módulos, y los
% dos definen inicial/2, meta/2 y sucesor/5: cada uno se carga con
% load_files/2 en un módulo propio, sin copiarlo. Esos tres predicados se
% declaran multifile antes de la carga, y este archivo les agrega las
% cláusulas de dos problemas. En cubo(Cubo), el estado inicial es Cubo, la
% meta es el cubo resuelto y cada sucesor es un cuarto de vuelta. En
% pieza(Etapa, Cubo, Criterios), del resolvedor por etapas, la meta es un
% cubo que unifica con alguno de Criterios y cada sucesor aplica un
% candidato de Etapa, que es un giro o una macro compilada. Las cláusulas
% de las jarras siguen ahí y no se usan. cubo.pl se carga en el módulo
% user, donde lo cargan también las otras versiones.
%
% solo-local: carga archivos de otro capítulo.
%
%?- resuelto(C), aplicar([r, u], C, C1), en_anchura(C1, Plan, K).
%?- resuelto(C), aplicar([r, u], C, C1), profundizando(C1, Plan).

:- module(capitulo40,
          [ en_anchura/3,
            profundizando/2,
            colocar_pieza/4
          ]).

:- multifile
    anchura40:inicial/2,
    anchura40:meta/2,
    anchura40:sucesor/5,
    iterativa40:inicial/2,
    iterativa40:meta/2,
    iterativa40:sucesor/5.

:- load_files(user:cubo, [if(not_loaded)]).
:- load_files(anchura40:'../capitulo-40/visitados', []).
:- load_files(iterativa40:'../capitulo-40/profundizacion', []).

anchura40:inicial(cubo(C), C).
anchura40:meta(cubo(_), C) :-
    user:resuelto(C).
anchura40:sucesor(cubo(_), C, M, C1, 1) :-
    user:cuarto_de_vuelta(M),
    user:mover(M, C, C1).

iterativa40:inicial(cubo(C), C).
iterativa40:inicial(pieza(_, C, _), C).
iterativa40:meta(cubo(_), C) :-
    user:resuelto(C).
iterativa40:meta(pieza(_, _, Criterios), C) :-
    memberchk(C, Criterios).
iterativa40:sucesor(cubo(_), C, M, C1, 1) :-
    user:cuarto_de_vuelta(M),
    user:mover(M, C, C1).
iterativa40:sucesor(pieza(Etapa, _, _), C, Ms, C1, 1) :-
    user:candidato(Etapa, Ms, C, C1).

%!  en_anchura(+Cubo, -Plan:list, -Expandidos:integer) is semidet.
%
%   Plan es una de las secuencias más cortas de cuartos de vuelta que
%   resuelven Cubo, hallada en anchura con el registro de estados vistos
%   del capítulo 40; Expandidos es la cantidad de nodos expandidos.
en_anchura(Cubo, Plan, Expandidos) :-
    anchura40:buscar(anchura, cubo(Cubo), Plan, _, Expandidos).

%!  profundizando(+Cubo, -Plan:list) is semidet.
%
%   Plan es una de las secuencias más cortas de cuartos de vuelta que
%   resuelven Cubo, hallada por profundización iterativa, sin registro de
%   estados vistos. No termina si Cubo no tiene solución.
profundizando(Cubo, Plan) :-
    once(iterativa40:iterativo(cubo(Cubo), Plan)).

%!  colocar_pieza(+Etapa, +Cubo, +Criterios:list, -Plan:list) is semidet.
%
%   Plan es una de las listas más cortas de candidatos de Etapa que llevan
%   Cubo a un cubo que unifica con alguno de Criterios, hallada por
%   profundización iterativa. Cada elemento de Plan es la lista de giros de
%   un candidato. No termina si ninguna lista sirve.
colocar_pieza(Etapa, Cubo, Criterios, Plan) :-
    once(iterativa40:iterativo(pieza(Etapa, Cubo, Criterios), Plan)).
