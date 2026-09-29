:- encoding(utf8).

% Capítulo 65 - El motor de la derivación rebatible.
%
% Una base de conocimiento tiene cuatro clases de reglas. Los hechos y las
% reglas estrictas son cláusulas comunes, y su cabeza puede ser un átomo o
% su negación fuerte, neg Atomo. Una regla rebatible se escribe
% Cabeza :~ Cuerpo y vale salvo que otra regla la derrote; una presunción
% es una regla rebatible de cuerpo true. Un refutador se escribe
% Cabeza :^ Cuerpo: no permite concluir nada, solo impide que se aplique
% una regla rebatible de cabeza contraria. superior(R1, R2) declara que la
% regla R1 prevalece sobre la regla R2.
%
% derivable/2 prueba una meta con esas reglas. Su primer argumento es el
% criterio de superioridad, una lista: [] no compara las reglas;
% especificidad hace prevalecer la regla más específica, y declarada, las
% superioridades declaradas con superior/2. Con anticipacion, un rival
% rebatible o un refutador deja de derrotar si otra regla, superior a él,
% lo refuta: es la anticipación (preemption) de d-Prolog.
%
% solo-local: examina la base con clause/2 y predicate_property/2 sobre
% metas que se conocen al ejecutar, y SWISH no lo permite.

:- module(rebatible,
          [ op(1100, xfx, :~),
            op(1100, xfx, :^),
            op(900, fy, neg),
            estricto/1,
            derivable/2,
            respuesta/3,
            rival/4,
            supera/3,
            contrario/2,
            partes/3,
            predefinido/1,
            regla_estricta/2,
            regla_rebatible/3
          ]).

:- use_module(library(error)).
:- use_module(library(lists)).

:- dynamic user:(:~)/2, user:(:^)/2, user:(neg)/1, user:superior/2.
:- discontiguous user:(:~)/2, user:(:^)/2, user:(neg)/1.

%!  estricto(+Meta) is nondet.
%
%   Meta se deriva de los hechos y las reglas estrictas de la base.
estricto(Meta) :-
    must_be(callable, Meta),
    estricto(raiz, Meta).

%!  derivable(+Criterio:list, +Meta) is nondet.
%
%   Meta se deriva de la base con las reglas estrictas y las rebatibles,
%   sin que ninguna regla usada quede derrotada. Criterio es una lista con
%   algunos de especificidad, declarada y anticipacion.
derivable(Criterio, Meta) :-
    must_be(list(oneof([especificidad, declarada, anticipacion])), Criterio),
    must_be(callable, Meta),
    derivable(Criterio, raiz, Meta).

%!  estricto(+Base, +Meta) is nondet.
%
%   Meta se deriva de Base con las reglas estrictas. Base es raiz, la base
%   entera, o cuerpo(C), los literales de la conjunción C más las reglas
%   estrictas de la base, sin sus hechos. Un predicado importado de otro
%   módulo se llama en la raíz; en un cuerpo, solo vale como literal.
estricto(Base, (A, B)) :-
    !,
    estricto(Base, A),
    estricto(Base, B).
estricto(_, true) :-
    !.
estricto(_, Meta) :-
    predefinido(Meta),
    !,
    call(user:Meta).
estricto(raiz, Meta) :-
    externo(Meta),
    !,
    call(user:Meta).
estricto(raiz, Meta) :-
    propio(Meta),
    clause(user:Meta, Cuerpo),
    estricto(raiz, Cuerpo).
estricto(cuerpo(C), Meta) :-
    literal_de(Meta, C).
estricto(cuerpo(C), Meta) :-
    regla_estricta(Meta, Cuerpo),
    estricto(cuerpo(C), Cuerpo).

%!  derivable(+Criterio:list, +Base, +Meta) is nondet.
%
%   Meta se deriva de Base: por las reglas estrictas, o por una regla
%   estricta o rebatible cuyo cuerpo se deriva y que no tiene rival.
derivable(Cr, Base, (A, B)) :-
    !,
    derivable(Cr, Base, A),
    derivable(Cr, Base, B).
derivable(_, _, true) :-
    !.
derivable(_, _, Meta) :-
    predefinido(Meta),
    !,
    call(user:Meta).
derivable(_, Base, Meta) :-
    estricto(Base, Meta).
derivable(Cr, Base, Meta) :-
    regla_estricta(Meta, Cuerpo),
    derivable(Cr, Base, Cuerpo),
    \+ rival(Cr, Base, (Meta :- Cuerpo), _).
derivable(Cr, Base, Meta) :-
    regla_rebatible(Base, Meta, Cuerpo),
    derivable(Cr, Base, Cuerpo),
    \+ rival(Cr, Base, (Meta :~ Cuerpo), _).

%!  rival(+Criterio:list, +Base, +Regla, -Rival) is nondet.
%
%   Rival derrota a Regla en Base. A cualquier regla la derrota su cabeza
%   contraria, si se deriva en forma estricta (Rival es estricto(Literal)),
%   o una regla estricta de cabeza contraria cuyo cuerpo se deriva. A una
%   regla rebatible la derrotan además una regla rebatible o un refutador
%   de cabeza contraria cuyo cuerpo se deriva, si Regla no los supera y
%   no están anticipados.
rival(_, Base, Regla, estricto(Contrario)) :-
    partes(Regla, Cabeza, _),
    contrario(Cabeza, Contrario),
    estricto(Base, Contrario).
rival(Cr, Base, Regla, (Contrario :- Cuerpo)) :-
    partes(Regla, Cabeza, _),
    contrario(Cabeza, Contrario),
    regla_estricta(Contrario, Cuerpo),
    derivable(Cr, Base, Cuerpo).
rival(Cr, Base, (Cabeza :~ Cuerpo), (Contrario :~ Cuerpo2)) :-
    contrario(Cabeza, Contrario),
    regla_rebatible(Base, Contrario, Cuerpo2),
    derivable(Cr, Base, Cuerpo2),
    \+ supera(Cr, (Cabeza :~ Cuerpo), (Contrario :~ Cuerpo2)),
    \+ anticipado(Cr, Base, (Contrario :~ Cuerpo2)).
rival(Cr, Base, (Cabeza :~ Cuerpo), (Contrario :^ Cuerpo2)) :-
    contrario(Cabeza, Contrario),
    user:(Contrario :^ Cuerpo2),
    derivable(Cr, Base, Cuerpo2),
    \+ supera(Cr, (Cabeza :~ Cuerpo), (Contrario :^ Cuerpo2)),
    \+ anticipado(Cr, Base, (Contrario :^ Cuerpo2)).

%!  anticipado(+Criterio:list, +Base, +Rival) is semidet.
%
%   Con anticipacion en Criterio, Rival, una regla rebatible o un
%   refutador, queda anticipado: su cabeza contraria se deriva en forma
%   estricta, o la concluye una regla estricta cuyo cuerpo se deriva, o una
%   regla rebatible que supera a Rival y cuyo cuerpo se deriva.
anticipado(Cr, Base, Rival) :-
    memberchk(anticipacion, Cr),
    partes(Rival, Cabeza, _),
    contrario(Cabeza, Contrario),
    (   estricto(Base, Contrario)
    ;   regla_estricta(Contrario, Cuerpo),
        derivable(Cr, Base, Cuerpo)
    ;   regla_rebatible(Base, Contrario, Cuerpo),
        derivable(Cr, Base, Cuerpo),
        supera(Cr, (Contrario :~ Cuerpo), Rival)
    ),
    !.

%!  supera(+Criterio:list, +Regla1, +Regla2) is semidet.
%
%   Regla1 prevalece sobre Regla2 según Criterio: porque superior/2 lo
%   declara, o porque es más específica, es decir, el cuerpo de Regla2 se
%   deriva del de Regla1 y no a la inversa.
supera(Cr, R1, R2) :-
    memberchk(declarada, Cr),
    user:superior(R1, R2),
    !.
supera(Cr, R1, R2) :-
    memberchk(especificidad, Cr),
    partes(R1, _, C1),
    partes(R2, _, C2),
    derivable(Cr, cuerpo(C1), C2),
    !,
    \+ derivable(Cr, cuerpo(C2), C1).

%!  respuesta(+Criterio:list, +Meta, -Respuesta) is det.
%
%   Respuesta resume lo que la base dice de Meta, sin variables:
%   contradiccion, definitivamente_si, definitivamente_no,
%   presumiblemente_si, presumiblemente_no o sin_conclusion.
respuesta(Criterio, Meta, Respuesta) :-
    must_be(ground, Meta),
    contrario(Meta, Contrario),
    (   estricto(Meta), estricto(Contrario)
    ->  Respuesta = contradiccion
    ;   estricto(Meta)
    ->  Respuesta = definitivamente_si
    ;   estricto(Contrario)
    ->  Respuesta = definitivamente_no
    ;   derivable(Criterio, Meta)
    ->  Respuesta = presumiblemente_si
    ;   derivable(Criterio, Contrario)
    ->  Respuesta = presumiblemente_no
    ;   Respuesta = sin_conclusion
    ).

%!  contrario(+Literal, -Contrario) is det.
%
%   Contrario es la negación fuerte de Literal, o el átomo que Literal
%   niega.
contrario(neg Atomo, Contrario) :-
    !,
    Contrario = Atomo.
contrario(Atomo, neg Atomo).

%!  partes(?Regla, ?Cabeza, ?Cuerpo) is semidet.
%
%   Regla, estricta (:-), rebatible (:~) o refutador (:^), tiene esa
%   Cabeza y ese Cuerpo.
partes((Cabeza :- Cuerpo), Cabeza, Cuerpo).
partes((Cabeza :~ Cuerpo), Cabeza, Cuerpo).
partes((Cabeza :^ Cuerpo), Cabeza, Cuerpo).

%!  regla_estricta(+Cabeza, -Cuerpo) is nondet.
%
%   Cabeza :- Cuerpo es una regla estricta de la base, no un hecho.
regla_estricta(Cabeza, Cuerpo) :-
    propio(Cabeza),
    clause(user:Cabeza, Cuerpo),
    Cuerpo \== true.

%!  regla_rebatible(+Base, ?Cabeza, ?Cuerpo) is nondet.
%
%   Cabeza :~ Cuerpo es una regla rebatible de la base. En el cuerpo de
%   otra regla no valen las presunciones, porque son datos, no reglas.
regla_rebatible(raiz, Cabeza, Cuerpo) :-
    user:(Cabeza :~ Cuerpo).
regla_rebatible(cuerpo(_), Cabeza, Cuerpo) :-
    user:(Cabeza :~ Cuerpo),
    Cuerpo \== true.

%!  literal_de(?Literal, +Conjuncion) is nondet.
%
%   Literal unifica con uno de los literales de Conjuncion.
literal_de(Literal, (A, B)) :-
    !,
    (   literal_de(Literal, A)
    ;   literal_de(Literal, B)
    ).
literal_de(Literal, Literal).

%!  predefinido(+Meta) is semidet.
%
%   Meta es un predicado del sistema, como una comparación o \+.
predefinido(Meta) :-
    predicate_property(user:Meta, built_in).

%!  externo(+Meta) is semidet.
%
%   Meta es un predicado que la base importa de otro módulo.
externo(Meta) :-
    predicate_property(user:Meta, imported_from(_)).

%!  propio(+Meta) is semidet.
%
%   Meta es un predicado definido en la base misma.
propio(Meta) :-
    predicate_property(user:Meta, defined),
    \+ predicate_property(user:Meta, imported_from(_)),
    \+ predicate_property(user:Meta, built_in).
