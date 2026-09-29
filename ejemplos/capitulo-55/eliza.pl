:- encoding(utf8).

% Capítulo 55 - Versión 3 de los diálogos: ELIZA.
%
% Tres agregados a la versión 2. Cada regla tiene un rango, y gana la de
% rango mayor que coincide con la frase, no la primera escrita: una
% palabra importante, como computadora, pesa más que una familiar. Cada
% regla tiene varias respuestas, que se turnan. Y las frases que hablan de
% algo propio (mi ...) se recuerdan, para volver sobre ellas cuando ninguna
% regla tiene nada que decir. El estado de la conversación, los turnos y
% los recuerdos, viaja en un argumento; conversar/3 es el bucle, que lee de
% un stream y recibe como argumento el predicado que responde.
%
% solo-local: carga archivos de otro capítulo, y SWISH no admite módulos
% propios.
%
%?- estado_inicial(E0), responder("Estoy cansado", E0, _, R).

:- module(eliza,
          [ estado_inicial/1,
            responder/4,
            conversar/3,
            eliza/1,
            eliza/0
          ]).

:- use_module(library(assoc)).

:- meta_predicate
    conversar(+, 4, +).

:- multifile
    regla/4.
:- use_module(plantillas, [coincide/2, rellenar/2]).
:- use_module(persona, [reflejar_pieza/3]).
:- use_module('../capitulo-44/lenguaje', [palabras/2]).

%!  regla(?Id, ?Rango:integer, ?Patron:list, ?Respuestas:list) is nondet.
%
%   La regla Id, de rango Rango, responde a las frases que siguen Patron
%   con una de las plantillas de Respuestas, por turno. Las reglas con
%   cuerpo generan un patrón por cada palabra de una clase.
regla(maquinas, 5, [_, M, _],
      [ ["¿Te preocupan las máquinas?"],
        ["¿Por qué mencionas las computadoras?"],
        ["¿Qué tienen que ver las máquinas con lo que te pasa?"]
      ]) :-
    maquina(M).
regla(me_dice, 4, [X, me, dice, que, Y],
      [ ["¿Qué piensas de que ", X, " te diga que ", Y, "?"],
        ["¿Y tú crees que ", Y, "?"]
      ]).
regla(creo, 3, [_, creo, que, X],
      [ ["¿Por qué crees que ", X, "?"],
        ["¿Estás seguro de que ", X, "?"]
      ]).
regla(estoy, 3, [_, estoy, X],
      [ ["¿Por qué estás ", X, "?"],
        ["¿Desde cuándo estás ", X, "?"]
      ]).
regla(eres, 3, [_, eres, X],
      [ ["¿Qué te hace pensar que soy ", X, "?"],
        ["¿Te gusta creer que soy ", X, "?"]
      ]).
regla(miedo, 3, [_, miedo, de, X],
      [ ["¿Qué te asusta de ", X, "?"],
        ["¿Desde cuándo tienes miedo de ", X, "?"]
      ]).
regla(necesito, 3, [_, necesito, X],
      [ ["¿Qué harías si consiguieras ", X, "?"],
        ["¿Por qué necesitas ", X, "?"]
      ]).
regla(familia, 2, [_, F, _],
      [ ["Háblame más de tu familia."],
        ["¿Quién más de tu familia te preocupa?"]
      ]) :-
    familiar(F).
regla(porque, 2, [_, porque, _],
      [ ["¿Es esa la verdadera razón?"],
        ["¿Qué otras razones se te ocurren?"]
      ]).
regla(no, 1, [no],
      [ ["¿Por qué no?"],
        ["Eso suena un poco negativo."]
      ]).
regla(ninguna, 0, [_],
      [ ["Continúa, por favor."],
        ["Cuéntame más."],
        ["Entiendo. ¿Y qué más?"]
      ]).

% maquina(M): la palabra M nombra una máquina.
maquina(computadora).
maquina(computadoras).
maquina(maquina).
maquina(maquinas).
maquina(programa).

% familiar(F): la palabra F nombra a un familiar.
familiar(madre).
familiar(padre).
familiar(hermano).
familiar(hermana).
familiar(hijo).
familiar(hija).

% memoria(Patron, Plantilla): una frase que sigue Patron se recuerda con
% el texto de Plantilla, para usarlo cuando ninguna regla coincida.
memoria([_, mi, X], ["Antes dijiste que tu ", X,
                     ". ¿Tiene algo que ver con esto?"]).

%!  estado_inicial(-Estado) is det.
%
%   Estado es el de una conversación que empieza: ningún turno usado y
%   ningún recuerdo.
estado_inicial(eliza(Turnos, [])) :-
    empty_assoc(Turnos).

%!  responder(+Frase:string, +Estado0, -Estado, -Respuesta:string) is det.
%
%   Respuesta es la respuesta a Frase en el estado Estado0, y Estado el
%   estado que queda: el turno de la regla elegida avanza y, si Frase se
%   recuerda, su recuerdo queda al final. Si solo coincide la regla
%   ninguna y hay recuerdos, la respuesta es el primero, que se descarta.
responder(Frase, eliza(Turnos0, Recuerdos0), eliza(Turnos, Recuerdos),
          Respuesta) :-
    palabras(Frase, Palabras),
    elegir_regla(Palabras, Id, Plantillas),
    (   Id == ninguna,
        Recuerdos0 = [Recuerdo|Recuerdos1]
    ->  Respuesta = Recuerdo,
        Turnos = Turnos0
    ;   turno(Id, Plantillas, Turnos0, Turnos, Plantilla),
        texto(Frase, Plantilla, Respuesta),
        Recuerdos1 = Recuerdos0
    ),
    recordar(Frase, Palabras, Recuerdos1, Recuerdos).

%!  elegir_regla(+Palabras:list(atom), -Id, -Plantillas:list) is det.
%
%   Id es la regla de mayor rango cuyo patrón siguen Palabras; entre las
%   de igual rango, la primera escrita. Sus variables quedan ligadas a las
%   palabras de la frase en Plantillas.
elegir_regla(Palabras, Id, Plantillas) :-
    aggregate_all(set(R), regla(_, R, _, _), Rangos),
    reverse(Rangos, Descendentes),
    once(( member(Rango, Descendentes),
           regla(Id, Rango, Patron, Plantillas),
           coincide(Patron, Palabras) )).

%!  turno(+Id, +Plantillas:list, +Turnos0, -Turnos, -Plantilla) is det.
%
%   Plantilla es la plantilla de Plantillas a la que le toca el turno en la
%   regla Id, y Turnos registra que la regla se usó una vez más.
turno(Id, Plantillas, Turnos0, Turnos, Plantilla) :-
    (   get_assoc(Id, Turnos0, Usos)
    ->  true
    ;   Usos = 0
    ),
    length(Plantillas, Cantidad),
    I is Usos mod Cantidad,
    nth0(I, Plantillas, Plantilla),
    Usos1 is Usos + 1,
    put_assoc(Id, Turnos0, Usos1, Turnos).

%!  texto(+Frase:string, +Plantilla:list, -Texto:string) is det.
%
%   Texto es Plantilla rellenada, con la persona de las palabras de Frase
%   cambiada y sus tildes recuperadas.
texto(Frase, Plantilla, Texto) :-
    maplist(reflejar_pieza(Frase), Plantilla, Piezas),
    rellenar(Piezas, Texto).

%!  recordar(+Frase:string, +Palabras:list(atom), +Recuerdos0:list,
%!           -Recuerdos:list) is det.
%
%   Recuerdos son Recuerdos0 con el recuerdo de Frase al final, si Frase
%   sigue el patrón de memoria/2; si no, Recuerdos es Recuerdos0.
recordar(Frase, Palabras, Recuerdos0, Recuerdos) :-
    (   memoria(Patron, Plantilla),
        coincide(Patron, Palabras)
    ->  texto(Frase, Plantilla, Recuerdo),
        append(Recuerdos0, [Recuerdo], Recuerdos)
    ;   Recuerdos = Recuerdos0
    ).

%!  conversar(+In, :Responder, +Estado0) is det.
%
%   Lee frases de In, una por línea, y escribe la respuesta que da
%   call(Responder, Frase, Estado0, Estado, Respuesta), hasta que la frase
%   es una despedida o In se termina.
conversar(In, Responder, Estado0) :-
    format("> "),
    read_line_to_string(In, Linea),
    (   (   Linea == end_of_file
        ;   despedida(Linea)
        )
    ->  format("Adiós. Gracias por conversar.~n")
    ;   call(Responder, Linea, Estado0, Estado, Respuesta),
        format("~w~n", [Respuesta]),
        conversar(In, Responder, Estado)
    ).

%!  despedida(+Linea:string) is semidet.
%
%   Linea es una despedida: su primera palabra es adiós o chau.
despedida(Linea) :-
    palabras(Linea, [P|_]),
    memberchk(P, [adios, chau]).

%!  eliza(+In) is det.
%
%   Saluda y conversa con las frases de In.
eliza(In) :-
    format("Hola. Cuéntame qué te preocupa.~n"),
    estado_inicial(E0),
    conversar(In, responder, E0).

%!  eliza is det.
%
%   Conversa con el teclado.
eliza :-
    eliza(user_input).
