:- encoding(utf8).

% Capítulo 63 - Versión 3: marcos.
%
% Un marco describe una clase: marco(Clase, Padres, Ranuras), con la lista
% de las clases de las que hereda y valores por omisión Ranura-Valor. Las
% clases son fijas; los objetos están en la memoria de trabajo, como hechos
% objeto(Nombre, Clase, Ranuras), con los valores propios del objeto. El
% valor de una ranura es el propio, o el de la primera clase que lo define,
% buscando en profundidad y en el orden de los padres.
%
% Una regla puede usar la condición es(Objeto, Clase, Consultas), que pide
% un objeto de la Clase o de una subclase suya cuyas ranuras tienen los
% valores de las Consultas, y las acciones crear(Objeto, Clase, Ranuras) y
% poner(Objeto, Ranura, Valor). con_marcos/2 las traduce a condiciones y
% acciones del lenguaje del capítulo 60: el intérprete no cambia.
%
% solo-local: carga estrategias.pl con ensure_loaded/1, y SWISH no permite
% cargar archivos.
%
%?- es_un(procesador, C).
%?- valor_ranura(procesador, [], necesita_disipador, V).

:- ensure_loaded(estrategias).

% Otros archivos agregan clases.
:- multifile marco/3.

% marco(Clase, Padres, Ranuras): la Clase hereda de los Padres, en orden,
% y tiene los valores por omisión Ranuras.
marco(componente, [], [precio-0, consumo-0]).
marco(refrigerado, [], [necesita_disipador-si]).
marco(procesador, [componente, refrigerado], [consumo-65]).
marco(placa, [componente], [consumo-30]).
marco(memoria, [componente], [consumo-5]).
marco(placa_de_video, [componente], [consumo-200]).
marco(disipador, [componente], [consumo-3]).
marco(fuente, [componente], []).

%!  es_un(+Clase, ?Superclase) is nondet.
%
%   Superclase es la Clase misma o una clase de la que hereda, en
%   profundidad y en el orden de los padres.
es_un(Clase, Clase).
es_un(Clase, Superclase) :-
    marco(Clase, Padres, _),
    member(Padre, Padres),
    es_un(Padre, Superclase).

%!  es_de_clase(+Clase, +Superclase) is semidet.
%
%   Clase es Superclase o hereda de ella.
es_de_clase(Clase, Superclase) :-
    once(es_un(Clase, Superclase)).

%!  valor_ranura(+Clase, +Ranuras:list, +Ranura, -Valor) is semidet.
%
%   Valor es el de la Ranura en un objeto de la Clase con los valores
%   propios Ranuras: el propio si lo tiene, o el primero que define una de
%   sus clases. Falla si ninguna lo define.
valor_ranura(_, Ranuras, Ranura, Valor) :-
    memberchk(Ranura-Propio, Ranuras),
    !,
    Valor = Propio.
valor_ranura(Clase, _, Ranura, Valor) :-
    once(( es_un(Clase, Superclase),
           marco(Superclase, _, PorOmision),
           memberchk(Ranura-Heredado, PorOmision)
         )),
    Valor = Heredado.

%!  consultar(+Clase, +Ranuras:list, ?Consultas:list) is semidet.
%
%   Cada Ranura-Valor de Consultas tiene ese valor en un objeto de la Clase
%   con los valores propios Ranuras; un Valor libre queda ligado.
consultar(Clase, Ranuras, Consultas) :-
    maplist(consultar_ranura(Clase, Ranuras), Consultas).

%!  consultar_ranura(+Clase, +Ranuras:list, ?Consulta) is semidet.
%
%   Consulta es Ranura-Valor, y la Ranura tiene el Valor.
consultar_ranura(Clase, Ranuras, Ranura-Valor) :-
    valor_ranura(Clase, Ranuras, Ranura, Valor).

%!  fijar_ranura(+Ranuras0:list, +Ranura, +Valor, -Ranuras:list) is det.
%
%   Ranuras es Ranuras0 con Ranura-Valor en lugar del valor propio que
%   tuviera la Ranura.
fijar_ranura(Ranuras0, Ranura, Valor, [Ranura-Valor|Ranuras]) :-
    exclude(de_ranura(Ranura), Ranuras0, Ranuras).

%!  de_ranura(+Ranura, +Par) is semidet.
%
%   Par es un valor de la Ranura.
de_ranura(Ranura, Ranura-_).

%!  con_marcos(+Reglas0:list, -Reglas:list) is det.
%
%   Reglas son las Reglas0 con las condiciones es/3 y las acciones crear/3
%   y poner/3 traducidas al lenguaje del capítulo 60.
con_marcos(Reglas0, Reglas) :-
    maplist(regla_con_marcos, Reglas0, Reglas).

%!  regla_con_marcos(+Regla0, -Regla) is det.
%
%   Regla es Regla0 traducida. Cada objeto de una condición es/3 se busca
%   con un patrón objeto/3 la primera vez que aparece; las siguientes solo
%   consultan sus ranuras.
regla_con_marcos(Nombre :: Condiciones0 ---> Acciones0,
                 Nombre :: Condiciones ---> Acciones) :-
    foldl(condicion_con_marcos, Condiciones0, Partes, [], Objetos),
    append(Partes, Condiciones),
    maplist(accion_con_marcos(Objetos), Acciones0, Partes1),
    append(Partes1, Acciones).

%!  condicion_con_marcos(+Condicion, -Traduccion:list, +Objetos0:list,
%!                       -Objetos:list) is det.
%
%   Traduccion son las condiciones que reemplazan a Condicion. Objetos
%   tiene un término obj(Objeto, Clase, Ranuras) por cada objeto ya
%   buscado, con las variables de su clase y de sus ranuras.
condicion_con_marcos(Condicion, Traduccion, Objetos0, Objetos) :-
    (   Condicion = es(Objeto, Clase, Consultas)
    ->  (   buscado(Objeto, Objetos0, ClaseReal, Ranuras)
        ->  Traduccion = [Prueba],
            Objetos = Objetos0
        ;   Traduccion = [objeto(Objeto, ClaseReal, Ranuras), Prueba],
            Objetos = [obj(Objeto, ClaseReal, Ranuras)|Objetos0]
        ),
        Prueba = {es_de_clase(ClaseReal, Clase),
                  consultar(ClaseReal, Ranuras, Consultas)}
    ;   Traduccion = [Condicion],
        Objetos = Objetos0
    ).

%!  buscado(+Objeto, +Objetos:list, -Clase, -Ranuras) is semidet.
%
%   Objeto, idéntico a uno de Objetos, ya tiene un patrón objeto/3, con
%   las variables Clase y Ranuras.
buscado(Objeto, Objetos, Clase, Ranuras) :-
    member(obj(O, Clase, Ranuras), Objetos),
    O == Objeto,
    !.

%!  accion_con_marcos(+Objetos:list, +Accion, -Traduccion:list) is det.
%
%   Traduccion son las acciones que reemplazan a Accion. poner/3 necesita
%   que el objeto se haya buscado en una condición es/3.
accion_con_marcos(_, crear(Objeto, Clase, Ranuras),
                  [agregar(objeto(Objeto, Clase, Ranuras))]) :-
    !.
accion_con_marcos(Objetos, poner(Objeto, Ranura, Valor),
                  [{fijar_ranura(Ranuras, Ranura, Valor, Ranuras1)},
                   reemplazar(objeto(Objeto, Clase, Ranuras),
                              objeto(Objeto, Clase, Ranuras1))]) :-
    buscado(Objeto, Objetos, Clase, Ranuras),
    !.
accion_con_marcos(_, Accion, [Accion]).

% Marca los componentes que necesitan un disipador.
programa(disipadores, Reglas) :-
    con_marcos(
        [ marcar :: [es(C, componente, [necesita_disipador-si])]
               ---> [agregar(requiere_disipador(C))]
        ], Reglas).
