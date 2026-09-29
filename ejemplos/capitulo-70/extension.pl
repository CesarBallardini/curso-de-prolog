:- encoding(utf8).

% Capítulo 70 - Versión 1: planificar hacia atrás, extendiendo el plan.
%
% Las metas se logran en orden. Una meta que ya vale después del plan
% parcial queda protegida; una que no vale se logra con una acción que la
% agrega, puesta al final del plan después de planear sus precondiciones.
% Ninguna acción nueva puede borrar un hecho protegido. Cada acción gasta
% una unidad de una cota: sin ella, la búsqueda de las precondiciones
% puede no terminar (para liberar c hay que poner algo sobre c, y para
% eso c tiene que estar libre). planificar/5 prueba cotas crecientes y da
% los planes más cortos que el método construye.
%
% solo-local: carga regresion.pl.
%
%?- planificar(cubos, sussman, [sobre(c, b)], 4, Plan).
%?- planificar(cubos, sussman, [sobre(a, b), sobre(b, c)], 8, Plan).

:- module(extension,
          [ planificar/5,
            gastar/2,
            proteger/3,
            no_borra_ninguna/3,
            inconsistente/3
          ]).

:- use_module(regresion).
:- use_module(library(apply)).
:- use_module(library(lists)).

%!  planificar(+Mundo, +Inicio, +Metas:list, +Maximo:integer, -Plan:list)
%!      is nondet.
%
%   Plan, en el orden en que se ejecuta, tiene a lo sumo Maximo acciones y
%   lleva desde el estado inicial Inicio del Mundo a un estado donde valen
%   todas las Metas. Los planes se dan de menor a mayor longitud.
planificar(Mundo, Inicio, Metas, Maximo, Plan) :-
    \+ inconsistente(Mundo, Metas, []),
    between(0, Maximo, N),
    planear(Mundo, Inicio, Metas, [], _, [], Hechas, N, 0),
    reverse(Hechas, Plan).

%!  planear(+Mundo, +Inicio, +Metas:list, +Protegidas0:list,
%!          -Protegidas:list, +Hechas0:list, -Hechas:list, +Cota0,
%!          -Cota) is nondet.
%
%   Hechas, al revés, extiende Hechas0 y logra las Metas una por una, sin
%   borrar ningún hecho protegido. Cada acción agregada gasta una unidad
%   de Cota0, y Cota es lo que queda.
planear(_, _, [], Protegidas, Protegidas, Hechas, Hechas, Cota, Cota).
planear(Mundo, Inicio, [Meta|Metas], Protegidas0, Protegidas, Hechas0,
        Hechas, Cota0, Cota) :-
    resolver(Mundo, Inicio, Meta, Protegidas0, Protegidas1, Hechas0, Hechas1,
             Cota0, Cota1),
    planear(Mundo, Inicio, Metas, Protegidas1, Protegidas, Hechas1, Hechas,
            Cota1, Cota).

%!  resolver(+Mundo, +Inicio, +Meta, +Protegidas0:list, -Protegidas:list,
%!           +Hechas0:list, -Hechas:list, +Cota0, -Cota) is nondet.
%
%   Meta vale después de Hechas: porque vale siempre, porque es una prueba
%   que se cumple, porque ya vale después de Hechas0, o porque una acción
%   la logra. En los dos últimos casos Meta pasa a estar protegida.
resolver(Mundo, _, Meta, Ps, Ps, Hechas, Hechas, Cota, Cota) :-
    Mundo:siempre(Meta).
resolver(Mundo, _, Meta, Ps, Ps, Hechas, Hechas, Cota, Cota) :-
    es_prueba(Mundo, Meta),
    call(Mundo:Meta).
resolver(Mundo, Inicio, Meta, Ps0, Ps, Hechas, Hechas, Cota, Cota) :-
    \+ es_prueba(Mundo, Meta),
    vale(Mundo, Inicio, Meta, Hechas),
    proteger(Meta, Ps0, Ps).
resolver(Mundo, Inicio, Meta, Ps, [Meta|Ps], Hechas0, Hechas, Cota0,
         Cota) :-
    \+ es_prueba(Mundo, Meta),
    gastar(Cota0, Cota1),
    Mundo:agrega(Meta, Accion),
    lograr(Mundo, Inicio, Accion, Ps, Hechas0, Hechas, Cota1, Cota).

%!  lograr(+Mundo, +Inicio, +Accion, +Protegidas:list, +Hechas0:list,
%!         -Hechas:list, +Cota0, -Cota) is nondet.
%
%   Hechas es Hechas0 más las acciones que logran las precondiciones de
%   Accion, y Accion al final. Accion no borra ningún hecho protegido.
lograr(Mundo, Inicio, Accion, Ps, Hechas0, [Accion|Hechas1], Cota0,
       Cota) :-
    no_borra_ninguna(Mundo, Accion, Ps),
    Mundo:puede(Accion, Pre),
    \+ inconsistente(Mundo, Pre, Ps),
    planear(Mundo, Inicio, Pre, Ps, _, Hechas0, Hechas1, Cota0, Cota),
    no_borra_ninguna(Mundo, Accion, Ps).

%!  gastar(+Cota0, -Cota) is semidet.
%
%   Queda por lo menos una acción en Cota0, y Cota es una menos. La cota
%   sin_cota no se gasta nunca.
gastar(sin_cota, sin_cota) :-
    !.
gastar(Cota0, Cota) :-
    Cota0 > 0,
    Cota is Cota0 - 1.

%!  proteger(+Hecho, +Protegidas0:list, -Protegidas:list) is det.
%
%   Protegidas agrega Hecho a Protegidas0, si no estaba.
proteger(Hecho, Ps, Ps) :-
    member(H, Ps),
    H == Hecho,
    !.
proteger(Hecho, Ps, [Hecho|Ps]).

%!  no_borra_ninguna(+Mundo, +Accion, +Protegidas:list) is semidet.
%
%   Accion no borra ninguno de los hechos Protegidas.
no_borra_ninguna(Mundo, Accion, Ps) :-
    forall(member(H, Ps), preservada(Mundo, H, Accion)).

%!  inconsistente(+Mundo, +Nuevos:list, +Protegidas:list) is semidet.
%
%   Un conjunto imposible del Mundo está contenido en Nuevos más
%   Protegidas, y toca por lo menos uno de los Nuevos. Las variables
%   libres se toman como objetos desconocidos: una prueba sobre ellas no
%   se da por cumplida.
inconsistente(Mundo, Nuevos, Ps) :-
    \+ \+ ( append(Nuevos, Ps, Todos),
            numbervars(Todos, 0, _),
            Mundo:imposible(Imposible),
            member(H, Nuevos),
            member(H, Imposible),
            implicados(Imposible, Mundo, Todos) ).

%!  implicados(+Hechos:list, +Mundo, +Todos:list) is semidet.
%
%   Cada uno de los Hechos está en Todos, o es una prueba sin variables
%   que se cumple.
implicados([], _, _).
implicados([H|Hs], Mundo, Todos) :-
    (   es_prueba(Mundo, H)
    ->  ground_sin_desconocidos(H),
        call(Mundo:H)
    ;   member(H, Todos)
    ),
    implicados(Hs, Mundo, Todos).

%!  ground_sin_desconocidos(+Termino) is semidet.
%
%   Termino no tiene objetos desconocidos: ningún subtérmino '$VAR'(N)
%   de los que deja numbervars/3.
ground_sin_desconocidos(Termino) :-
    \+ ( sub_term(S, Termino),
         compound(S),
         S = '$VAR'(_) ).
