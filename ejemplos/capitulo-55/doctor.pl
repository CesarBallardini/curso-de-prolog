:- encoding(utf8).

% Capítulo 55 - El guion DOCTOR: ELIZA como la describe Weizenbaum.
%
% Un guion es una tabla de palabras clave. Cada clave tiene un rango y una
% lista de reglas de descomposición; cada regla de descomposición tiene
% una lista de reglas de reensamblado, que se usan por turno. Una
% descomposición es una lista de elementos: 0 abarca cualquier cantidad de
% palabras, un entero N > 0 exactamente N palabras, clase(C) una palabra
% de la clase C, alguna(Ps) una de las palabras Ps, y cualquier otra cosa
% esa misma palabra. Un reensamblado es una lista de textos y de números:
% el número N repite la N-ésima parte de la descomposición.
%
% La frase se recorre una vez: cada palabra se sustituye según
% sustituye/2 (el cambio de persona) y cada palabra clave entra en la pila
% de claves, arriba si su rango supera al de la que está arriba, abajo si
% no. Las reglas de la clave de arriba se aplican al texto sustituido.
% ir_a(K) en lugar de una regla, o de un reensamblado, pasa a las reglas
% de la clave K; nueva_clave abandona la clave y pasa a la siguiente de la
% pila. Las frases cuya clave principal es mi se guardan además en la
% memoria, para responder con ellas cuando la frase no tiene claves.
%
% solo-local: carga archivos de este capítulo y del 44, y SWISH no admite
% módulos propios.
%
%?- estado_doctor(E0), responder_doctor("Mi madre me cuida.", E0, _, R).

:- module(doctor,
          [ estado_doctor/1,
            responder_doctor/4,
            explorar/3,
            descomponer/3,
            reensamblar/4,
            doctor/1,
            doctor/0
          ]).

% Otros archivos pueden agregar claves, sustituciones y etiquetas.
:- multifile
    clave/3,
    sustituye/2,
    etiqueta/2.

:- use_module(library(assoc)).
:- use_module(eliza, [conversar/3]).
:- use_module(persona, [escritura/3]).
:- use_module('../capitulo-44/lenguaje', [palabras/2]).

% sustituye(P, Q): la palabra P del usuario se lee como Q, en la otra
% persona. La sustitución se hace en el recorrido, una vez por palabra.
sustituye(yo, "tú").
sustituye(mi, "tu").
sustituye(mis, "tus").
sustituye(tu, "mi").
sustituye(me, "te").
sustituye(te, "me").
sustituye(estoy, "estás").
sustituye(soy, "eres").
sustituye(eres, "soy").
sustituye(necesito, "necesitas").
sustituye(pareces, "parezco").

% etiqueta(P, C): la palabra P pertenece a la clase C.
etiqueta(madre, familia).
etiqueta(padre, familia).
etiqueta(hermano, familia).
etiqueta(hermana, familia).
etiqueta(esposa, familia).
etiqueta(hijos, familia).

% clave(P, Rango, Reglas): la palabra clave P, su rango y sus reglas de
% transformación, cada una Descomposicion-Reensamblados o ir_a(Clave).
clave(computadora, 50,
      [ [0] - [ ["¿Te preocupan las computadoras?"],
                ["¿Por qué mencionas las computadoras?"],
                ["¿Qué tienen que ver las máquinas con tu problema?"] ] ]).
clave(computadoras, 50, [ir_a(computadora)]).
clave(maquina, 50, [ir_a(computadora)]).
clave(parecido, 10,
      [ [0] - [ ["¿En qué sentido?"],
                ["¿Qué parecido ves?"],
                ["¿Qué te sugiere ese parecido?"] ] ]).
clave(iguales, 10, [ir_a(parecido)]).
clave(pareces, 10, [ir_a(parecido)]).
clave(porque, 3,
      [ [0, porque, 0] - [ ["¿Es esa la verdadera razón?"],
                           nueva_clave ] ]).
clave(mi, 2,
      [ [0, "tu", 0, clase(familia), 0]
        - [ ["Háblame más de tu familia."],
            ["¿Quién más en tu familia ", 5, "?"],
            ["Tu ", 4, "."],
            ["¿Qué más se te ocurre cuando piensas en tu ", 4, "?"] ],
        [0, "tu", 0]
        - [ ["Tu ", 3, "."],
            ["¿Por qué dices tu ", 3, "?"] ] ]).
clave(siempre, 1,
      [ [0] - [ ["¿Puedes pensar en un ejemplo concreto?"],
                ["¿En qué ocasión, en particular?"] ] ]).
clave(estoy, 0,
      [ [0, "estás", 0, alguna([triste, deprimido, deprimida, infeliz]), 0]
        - [ ["Lamento oír que estás ", 4, "."],
            ["¿Crees que venir aquí te ayudará a no estar ", 4, "?"] ],
        [0, "estás", 0]
        - [ ["¿Desde cuándo estás ", 3, "?"],
            ["¿Te parece normal estar ", 3, "?"] ] ]).
clave(soy, 0,
      [ [0, "eres", 0, alguna([triste, desdichado, desdichada, infeliz]), 0]
        - [ ["¿Crees que venir aquí te ayudará a no ser ", 4, "?"],
            ["¿Puedes explicar qué te hizo ", 4, "?"] ],
        [0, "eres", 0]
        - [ ["¿Por qué dices que eres ", 3, "?"] ] ]).
clave(necesito, 0,
      [ [0, "necesitas", 0]
        - [ ["¿Qué significaría para ti conseguir ", 3, "?"],
            ["¿Por qué necesitas ", 3, "?"] ] ]).
clave(quizas, 0,
      [ [0] - [ ["No pareces muy seguro."],
                ["¿Por qué ese tono de duda?"] ] ]).
clave(ninguna, 0,
      [ [0] - [ ["Continúa, por favor."],
                ["No estoy seguro de entenderte del todo."],
                ["¿Qué te sugiere eso?"] ] ]).

% memoria(Clave, Descomposicion, Reensamblados): cuando Clave es la clave
% principal de una frase, la frase se guarda reensamblada con uno de los
% Reensamblados, elegido por el largo de su última palabra.
memoria(mi, [0, "tu", 0],
        [ ["Hablemos más de por qué tu ", 3, "."],
          ["Antes dijiste que tu ", 3, "."],
          ["Pero tu ", 3, "."],
          ["¿Tiene eso algo que ver con que tu ", 3, "?"] ]).

%!  estado_doctor(-Estado) is det.
%
%   Estado es el de una conversación que empieza: ningún reensamblado
%   usado y la memoria vacía.
estado_doctor(doctor(Turnos, [])) :-
    empty_assoc(Turnos).

%!  responder_doctor(+Frase:string, +Estado0, -Estado,
%!                   -Respuesta:string) is det.
%
%   Respuesta es la respuesta del guion a Frase en el estado Estado0, y
%   Estado el que queda. Sin palabras clave, la respuesta es el recuerdo
%   más antiguo, si hay, o una de la clave ninguna.
responder_doctor(Frase, doctor(T0, M0), doctor(T, M), Respuesta) :-
    palabras(Frase, Palabras),
    explorar(Palabras, Texto, Pila),
    recordar_frase(Frase, Pila, Texto, M0, M1),
    (   Pila == [],
        M1 = [Recuerdo|M2]
    ->  Respuesta = Recuerdo,
        T = T0,
        M = M2
    ;   append(Pila, [ninguna], Claves),
        responder_con(Claves, Frase, Texto, T0, T, Respuesta),
        M = M1
    ).

%!  explorar(+Palabras:list(atom), -Texto:list, -Pila:list(atom)) is det.
%
%   Texto son las Palabras sustituidas y Pila las palabras clave de
%   Palabras, con la de mayor rango arriba.
explorar(Palabras, Texto, Pila) :-
    foldl(explorar_palabra, Palabras, Texto, [], Pila).

%!  explorar_palabra(+P:atom, -Q, +Pila0:list, -Pila:list) is det.
%
%   Q es P sustituida, y Pila es Pila0 con P arriba si P es una clave de
%   rango mayor que la de arriba, abajo si es una clave de rango menor o
%   igual, o sin cambios si P no es una clave.
explorar_palabra(P, Q, Pila0, Pila) :-
    (   sustituye(P, Q0)
    ->  Q = Q0
    ;   Q = P
    ),
    (   clave(P, Rango, _)
    ->  (   Pila0 = [Arriba|_],
            clave(Arriba, RangoArriba, _),
            Rango =< RangoArriba
        ->  append(Pila0, [P], Pila)
        ;   Pila = [P|Pila0]
        )
    ;   Pila = Pila0
    ).

%!  responder_con(+Claves:list, +Frase:string, +Texto:list, +T0, -T,
%!                -Respuesta:string) is det.
%
%   Respuesta sale de las reglas de la primera de Claves; si esa clave
%   pide nueva_clave, de las de la siguiente.
responder_con([K|Ks], Frase, Texto, T0, T, Respuesta) :-
    clave(K, _, Reglas),
    (   transformar(Reglas, K, Texto, T0, T1, Resultado),
        Resultado \== nueva_clave
    ->  T = T1,
        reensamblar(Frase, Resultado, Texto, Respuesta)
    ;   responder_con(Ks, Frase, Texto, T0, T, Respuesta)
    ).

%!  transformar(+Reglas:list, +K, +Texto:list, +T0, -T, -Resultado)
%!      is semidet.
%
%   Resultado es Reensamblado-Partes, con Reensamblado el que le toca a la
%   primera regla de descomposición que coincide con Texto y Partes la
%   descomposición, o nueva_clave. ir_a(Clave) sigue con las reglas de
%   Clave. Falla si ninguna regla coincide.
transformar([Regla|Reglas], K, Texto, T0, T, Resultado) :-
    (   Regla = ir_a(K2)
    ->  clave(K2, _, Reglas2),
        transformar(Reglas2, K2, Texto, T0, T, Resultado)
    ;   Regla = Descomposicion-Reensamblados,
        descomponer(Descomposicion, Texto, Partes)
    ->  turno(K-Descomposicion, Reensamblados, T0, T1, R),
        (   R = ir_a(K2)
        ->  clave(K2, _, Reglas2),
            transformar(Reglas2, K2, Texto, T1, T, Resultado)
        ;   R == nueva_clave
        ->  T = T1,
            Resultado = nueva_clave
        ;   T = T1,
            Resultado = R-Partes
        )
    ;   transformar(Reglas, K, Texto, T0, T, Resultado)
    ).

%!  turno(+Regla, +Reensamblados:list, +T0, -T, -R) is det.
%
%   R es el reensamblado al que le toca el turno en Regla, y T registra
%   que se usó uno más.
turno(Regla, Reensamblados, T0, T, R) :-
    (   get_assoc(Regla, T0, Usos)
    ->  true
    ;   Usos = 0
    ),
    length(Reensamblados, N),
    I is Usos mod N,
    nth0(I, Reensamblados, R),
    Usos1 is Usos + 1,
    put_assoc(Regla, T0, Usos1, T).

%!  descomponer(+Descomposicion:list, +Texto:list, -Partes:list) is semidet.
%
%   Partes son las partes de Texto, una por elemento de Descomposicion. 0
%   toma la parte más corta posible.
descomponer(Descomposicion, Texto, Partes) :-
    once(partes(Descomposicion, Texto, Partes)).

%!  partes(+Descomposicion:list, +Texto:list, -Partes:list) is nondet.
%
%   Partes es una manera de repartir Texto entre los elementos de
%   Descomposicion.
partes([], [], []).
partes([E|Es], Texto, [Parte|Partes]) :-
    parte(E, Texto, Parte, Resto),
    partes(Es, Resto, Partes).

%!  parte(+Elemento, +Texto:list, -Parte:list, -Resto:list) is nondet.
%
%   Parte es el comienzo de Texto que corresponde a Elemento, y Resto lo
%   que queda.
parte(0, Texto, Parte, Resto) :-
    !,
    append(Parte, Resto, Texto).
parte(N, Texto, Parte, Resto) :-
    integer(N),
    !,
    length(Parte, N),
    append(Parte, Resto, Texto).
parte(clase(C), [P|Resto], [P], Resto) :-
    !,
    etiqueta(P, C).
parte(alguna(Ps), [P|Resto], [P], Resto) :-
    !,
    memberchk(P, Ps).
parte(P, [P|Resto], [P], Resto).

%!  reensamblar(+Frase:string, +Resultado, +Texto:list, -Respuesta:string)
%!      is det.
%
%   Respuesta es el reensamblado de Resultado, Reensamblado-Partes, con
%   cada número reemplazado por su parte y las palabras escritas como en
%   Frase. Texto no se usa: la descomposición ya lo repartió.
reensamblar(Frase, Reensamblado-Partes, _, Respuesta) :-
    maplist(pieza_de(Frase, Partes), Reensamblado, Piezas),
    atomics_to_string(Piezas, Respuesta).

%!  pieza_de(+Frase:string, +Partes:list, +Elemento, -Pieza:string) is det.
%
%   Pieza es el texto de Elemento: él mismo, o la parte N si es un número.
pieza_de(Frase, Partes, Elemento, Pieza) :-
    (   integer(Elemento)
    ->  nth1(Elemento, Partes, Parte),
        escritura(Frase, Parte, Escritas),
        atomic_list_concat(Escritas, ' ', A),
        atom_string(A, Pieza)
    ;   Pieza = Elemento
    ).

%!  recordar_frase(+Frase:string, +Pila:list, +Texto:list, +M0:list,
%!                 -M:list) is det.
%
%   M es M0 con un recuerdo de Frase al final, si la clave principal de
%   Frase tiene memoria y su descomposición coincide; si no, M es M0.
recordar_frase(Frase, [K|_], Texto, M0, M) :-
    memoria(K, Descomposicion, Reensamblados),
    descomponer(Descomposicion, Texto, Partes),
    !,
    last(Texto, Ultima),
    atom_length(Ultima, Largo),
    length(Reensamblados, N),
    I is Largo mod N,
    nth0(I, Reensamblados, R),
    reensamblar(Frase, R-Partes, Texto, Recuerdo),
    append(M0, [Recuerdo], M).
recordar_frase(_, _, _, M, M).

%!  doctor(+In) is det.
%
%   Saluda y conversa con las frases de In, con el bucle de la versión 3.
doctor(In) :-
    format("¿Cómo estás? Cuéntame tu problema.~n"),
    estado_doctor(E0),
    conversar(In, responder_doctor, E0).

%!  doctor is det.
%
%   Conversa con el teclado.
doctor :-
    doctor(user_input).
