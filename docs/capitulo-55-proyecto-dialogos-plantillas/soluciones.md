# Soluciones del capítulo 55 — Proyecto: diálogos por plantillas

El código de esta página está en `ejemplos/capitulo-55/`: `soluciones.pl`
para los ejercicios 3, 4 y 5; `soluciones_agenda.pl` para el 6, el 7 y el 8;
`soluciones_analogia.pl` para el 9; `soluciones_guiones.pl` para el 10 y el
11; y `soluciones_aventura.pl` para el 12. Cada uno tiene sus pruebas y
ninguno modifica los archivos del capítulo: agregan cláusulas a los
predicados que el capítulo declara `multifile`, o definen predicados nuevos
que usan los del capítulo. Los ejercicios 1 y 2 se resuelven con los
archivos del capítulo. Todos son `% solo-local`, porque cargan otros
archivos.

## 1

Con `dialogo.pl` cargado, cada frase se responde en el estado que dejó la
anterior:

<!-- ejemplo: capitulo-55/dialogo.pl predicado: responder/4 -->
```prolog
%!  responder(+Frase:string, +Estado0, -Estado, -Respuesta:string) is det.
%
%   Respuesta es la respuesta de la agenda a Frase, si la agenda la
%   reconoce, o la de ELIZA si no; Estado es el estado que queda.
responder(Frase, dialogo(Eliza0, Agenda0), dialogo(Eliza, Agenda),
          Respuesta) :-
    (   atender(Frase, Agenda0, Agenda1, Respuesta0)
    ->  Eliza = Eliza0,
        Agenda = Agenda1,
        Respuesta = Respuesta0
    ;   Agenda = Agenda0,
        responder_eliza(Frase, Eliza0, Eliza, Respuesta)
    ).
```

Las respuestas, en orden, son:

| Frase | Respuesta | Por qué |
|---|---|---|
| Tú no me entiendes | Continúa, por favor. | ninguna regla tiene «entiendes»; el patrón de «eres» no coincide, y queda la regla `ninguna` |
| Necesito unas vacaciones | ¿Qué harías si consiguieras unas vacaciones? | regla `necesito`, primer turno |
| Tengo una cena con Luis el viernes a las 9 de la noche | Anotado: el viernes a las 21:00, una cena con Luis. | la agenda la reconoce; «de la noche» suma 12 |
| Mi hermana dice que exagero | Háblame más de tu familia. | regla `familia`; la frase empieza con «mi» y se recuerda |
| Estoy harta | ¿Por qué estás harta? | regla `estoy` |
| ¿Cuándo veo a Luis? | Ves a Luis el viernes a las 21:00. | pregunta de la agenda |
| Sí | Antes dijiste que tu hermana dice que exagero. ¿Tiene algo que ver con esto? | solo coincide `ninguna`, y hay un recuerdo |

La última respuesta muestra un límite del cambio de persona: «exagero» no
está en `verbo/2`, y vuelve sin cambiar, en lugar de «exageras». El
ejercicio 5 hace más fácil agregar verbos.

## 2

```prolog
%!  coincide(+Patron:list, +Palabras:list(atom)) is nondet.
```

Con los dos argumentos instanciados, `coincide/2` da una respuesta por cada
manera de repartir la frase entre los segmentos: es `nondet`, como muestra
el patrón `[X, y, Y]` de la
[sección 55.2](index.md#552-version-1-plantillas-con-segmentos), que coincide de dos maneras. El
modo con `Palabras` libre existe, pero no sirve: `append/3` con dos
argumentos libres genera listas de palabras sin nombre, cada vez más largas,
y la enumeración no termina.

`Patron` tiene que ser una lista completa. Con `Patron` libre, la segunda
cláusula lo liga a `[E|Es]`, `E` queda libre, `append/3` le da primero el
segmento vacío, y la llamada recursiva vuelve a encontrar un patrón libre:
cada nivel agrega un segmento vacío y ninguno termina. Es la actividad de la
[sección 55.2](index.md#552-version-1-plantillas-con-segmentos):

<!-- ejemplo: capitulo-55/plantillas.pl predicado: coincide/2 -->
```prolog
%!  coincide(+Patron:list, +Palabras:list(atom)) is nondet.
%
%   Palabras sigue el Patron: cada palabra del patrón aparece en su lugar,
%   y cada variable del patrón queda ligada a la lista de palabras que
%   ocupa su lugar, que puede ser vacía. Las alternativas dan segmentos
%   cada vez más largos a las primeras variables.
coincide([], []).
coincide([E|Es], Palabras) :-
    (   var(E)
    ->  append(E, Resto, Palabras)
    ;   Palabras = [E|Resto]
    ),
    coincide(Es, Resto).
```

```prolog
?- call_with_inference_limit(coincide(P, [hola]), 100000, R).
R = inference_limit_exceeded.
```

Por eso la regla por omisión tiene el patrón `[_]`: una lista de un
elemento, un solo segmento que abarca la frase entera.

## 3

Las dos reglas se agregan con el nombre del módulo delante, porque
`regla/4` es `multifile` en `eliza`:

<!-- ejemplo: capitulo-55/soluciones.pl fragmento: eliza:regla(no_puedo, 3, .. ¿No hay ninguna excepción?"] -->
```prolog
eliza:regla(no_puedo, 3, [_, no, puedo, X],
            [ ["¿Qué te impide ", X, "?"],
              ["¿Lo has intentado de verdad?"]
            ]).
eliza:regla(siempre, 4, [_, siempre, _],
            [ ["¿Puedes pensar en un ejemplo concreto?"],
              ["¿Siempre? ¿No hay ninguna excepción?"]
```

«Siempre estoy cansado» sigue el patrón de `estoy` (rango 3) y el de
`siempre` (rango 4). Las cláusulas nuevas quedan después de las del
capítulo, pero `elegir_regla/3` prueba los rangos de mayor a menor, y el
orden de escritura solo desempata entre reglas del mismo rango.
`primera_respuesta/2` responde desde el estado inicial:

<!-- ejemplo: capitulo-55/soluciones.pl predicado: primera_respuesta/2 -->
```prolog
%!  primera_respuesta(+Frase:string, -Respuesta:string) is det.
%
%   Respuesta es la respuesta de ELIZA a Frase, desde el estado inicial.
primera_respuesta(Frase, Respuesta) :-
    estado_inicial(E0),
    responder(Frase, E0, _, Respuesta).
```

```prolog
?- primera_respuesta("Siempre estoy cansado", R).
R = "¿Puedes pensar en un ejemplo concreto?".

?- primera_respuesta("No puedo dormir por mi trabajo", R).
R = "¿Qué te impide dormir por tu trabajo?".
```

## 4

`persona_prep//1` es `persona//1` con una cláusula más al principio. Las
otras tres usan los predicados auxiliares del módulo `persona` con su
nombre, `persona:palabra/2`, porque el módulo no los exporta:

<!-- ejemplo: capitulo-55/soluciones.pl predicado: persona_prep//1 reflejar_prep/2 -->
```prolog
%!  persona_prep(-Cambiadas:list)// is det.
%
%   Como persona//1, del módulo persona, con una regla más: después de una
%   preposición, mí pasa a ti y ti a mí.
persona_prep([P, Q|Qs]) -->
    [P, Pronombre],
    { preposicion(P),
      pronombre_tras_preposicion(Pronombre, Q) },
    !,
    persona_prep(Qs).
persona_prep(["yo", Q|Qs]) -->
    [tu, P],
    { persona:tras_tu(P) },
    !,
    { persona:palabra(P, Q) },
    persona_prep(Qs).
persona_prep([Q, N|Qs]) -->
    [D, N],
    { persona:determinante(D) },
    !,
    { persona:palabra(D, Q) },
    persona_prep(Qs).
persona_prep([Q|Qs]) -->
    [P],
    !,
    { persona:palabra(P, Q) },
    persona_prep(Qs).
persona_prep([]) -->
    [].

%!  reflejar_prep(+Palabras:list(atom), -Cambiadas:list) is det.
%
%   Cambiadas son las Palabras con la persona cambiada, con la regla de las
%   preposiciones.
reflejar_prep(Palabras, Cambiadas) :-
    phrase(persona_prep(Cambiadas), Palabras).
```

```prolog
?- reflejar_prep([para, mi, es, dificil], Q).
Q = [para, "ti", es, dificil].

?- reflejar_prep([lo, hago, por, ti], Q).
Q = [lo, haces, por, "mí"].
```

Después de «de» la regla no se puede aplicar: «de mi madre» lleva el
posesivo y «de mí» el pronombre, y sin tildes las dos son `[de, mi]`. Lo que
las distingue es lo que sigue, un sustantivo o nada; pero «de mí» también
puede ir seguido de otras palabras («se ríe de mí todo el tiempo»), y la
palabra siguiente no alcanza para decidir. La frase original, con su tilde,
sí lo decidiría: `escritura/3` conserva «mí», y una variante del cambio de
persona podría mirar la palabra escrita en lugar de la normalizada.

## 5

<!-- ejemplo: capitulo-55/soluciones.pl fragmento: verbo_regular(caminar). .. terminacion(ir, es). -->
```prolog
verbo_regular(caminar).
verbo_regular(comer).
verbo_regular(escribir).

%!  conjugada_inf(?Primera:atom, ?Segunda:atom) is nondet.
%
%   Primera y Segunda son la primera y la segunda persona del singular del
%   presente de un verbo de verbo_regular/1.
conjugada_inf(Primera, Segunda) :-
    verbo_regular(Infinitivo),
    atom_concat(Raiz, Clase, Infinitivo),
    terminacion(Clase, Terminacion),
    atom_concat(Raiz, o, Primera),
    atom_concat(Raiz, Terminacion, Segunda).

% terminacion(Clase, T): la segunda persona de un verbo de la clase Clase
% termina en T.
terminacion(ar, as).
terminacion(er, es).
terminacion(ir, es).
```

```prolog
?- conjugada_inf(camino, S).
S = caminas ;
false.

?- conjugada_inf(P, comes).
P = como ;
false.
```

`atom_concat/3` con el infinitivo dado y los otros dos argumentos libres
da todas las maneras de partirlo; `terminacion/2` deja solo la que termina
en `ar`, `er` o `ir`. Los verbos con cambio de vocal en la raíz («querer»,
«poder») no se pueden declarar así: su raíz en el presente no es la del
infinitivo, y siguen en `verbo/2`.

## 6

`nueva//1` reconoce las dos frases nuevas con los no terminales de la
agenda, escritos con el nombre del módulo: `agenda:nombre(A)` es el
`nombre//1` de `agenda.pl`. `atender_con_cancelar/4` prueba primero las
frases nuevas y, si no son ninguna, llama a `atender/4`:

<!-- ejemplo: capitulo-55/soluciones_agenda.pl predicado: nueva//1 atender_con_cancelar/4 nuevo_efecto/4 -->
```prolog
%!  nueva(?Frase)// is nondet.
%
%   Las dos frases nuevas: cancelar(Actividad, Dia) y cuando_es(Actividad).
nueva(cancelar(A, D)) -->
    [V],
    { memberchk(V, [cancela, borra]) },
    agenda:nombre(A),
    (   [del]
    ->  agenda:fecha_o_dia(D)
    ;   agenda:dia(D)
    ).
nueva(cuando_es(A)) -->
    [cuando, tengo],
    agenda:nombre(A).

%!  atender_con_cancelar(+Frase:string, +Agenda0:list, -Agenda:list,
%!                       -Respuesta:string) is semidet.
%
%   Como atender/4, con dos frases más: cancelar las citas de una actividad
%   en un día, y preguntar cuándo es una actividad.
atender_con_cancelar(Frase, Agenda0, Agenda, Respuesta) :-
    palabras(Frase, Palabras),
    (   once(phrase(nueva(Acto), Palabras))
    ->  nuevo_efecto(Acto, Agenda0, Agenda, Resultado),
        phrase(oracion(Resultado), Codigos),
        string_codes(Respuesta, Codigos)
    ;   atender(Frase, Agenda0, Agenda, Respuesta)
    ).

%!  nuevo_efecto(+Acto, +Agenda0:list, -Agenda:list, -Resultado) is det.
%
%   Resultado es el término de la respuesta a Acto, y Agenda la agenda que
%   queda.
nuevo_efecto(cancelar(nombre(_, P), D), Agenda0, Agenda,
             canceladas(D, Canceladas)) :-
    partition([C]>>( C = cita(D, _, _, _, _), de_actividad(P, C) ),
              Agenda0, Canceladas, Agenda).
nuevo_efecto(cuando_es(nombre(_, P)), Agenda, Agenda, cuando_es(Citas)) :-
    include(de_actividad(P), Agenda, Citas).
```

`partition/4` separa en una sola pasada las citas que se cancelan de las que
quedan. La frase admite «del martes» y «el martes»: después de «del», el día
va sin artículo, y `fecha_o_dia//1` es la parte de `dia//1` que no lo lee.

```prolog
?- atender_con_cancelar("Tengo una reunión con Pérez el martes a las 10", [], A1, _), atender_con_cancelar("Cancela la reunión del martes", A1, A, R).
A1 = [cita(dia(martes), hora(10, 0), nombre(una, "reunión"), nombre(ninguno, "Pérez"), ninguno)],
A = [],
R = "Cancelado: una reunión con Pérez el martes a las 10:00.".
```

## 7

La pregunta es la segunda cláusula de `nueva//1`, y su efecto, la segunda
de `nuevo_efecto/4`: `include/3` se queda con las citas cuya actividad,
sin tildes, es la palabra preguntada. No choca con la pregunta
`cuando(Persona)` de la agenda, que exige «veo a», «tengo que ver a» o «me
reúno con»:

```prolog
?- atender_con_cancelar("Tengo una clase el lunes a las 9", [], A1, _), atender_con_cancelar("¿Cuándo tengo la clase?", A1, _, R).
A1 = [cita(dia(lunes), hora(9, 0), nombre(una, "clase"), nadie, ninguno)],
R = "Tienes una clase el lunes a las 9:00.".
```

## 8

Las citas son términos sin variables, y se guardan como hechos con
`portray_clause/2`; se leen con `read_term/3`, que no ejecuta nada, como las
partidas del [capítulo 44](../capitulo-44-proyecto-aventura-de-texto/index.md),
y cada término se valida antes de aceptarlo:

<!-- ejemplo: capitulo-55/soluciones_agenda.pl predicado: guardar_agenda/2 cargar_agenda/2 leer_citas/2 es_cita/1 -->
```prolog
%!  guardar_agenda(+Archivo, +Agenda:list) is det.
%
%   Escribe las citas de Agenda en Archivo, una por línea, como hechos.
guardar_agenda(Archivo, Agenda) :-
    setup_call_cleanup(
        open(Archivo, write, Out, [encoding(utf8)]),
        forall(member(C, Agenda), portray_clause(Out, C)),
        close(Out)).

%!  cargar_agenda(+Archivo, -Agenda:list) is det.
%
%   Agenda son las citas de Archivo, leídas sin ejecutarlas. Produce un
%   error de dominio si un término no es una cita.
cargar_agenda(Archivo, Agenda) :-
    setup_call_cleanup(
        open(Archivo, read, In, [encoding(utf8)]),
        leer_citas(In, Agenda),
        close(In)).

%!  leer_citas(+In, -Citas:list) is det.
%
%   Citas son los términos que quedan por leer en In, validados.
leer_citas(In, Citas) :-
    read_term(In, T, []),
    (   T == end_of_file
    ->  Citas = []
    ;   (   es_cita(T)
        ->  Citas = [T|Cs],
            leer_citas(In, Cs)
        ;   domain_error(cita, T)
        )
    ).

%!  es_cita(@T) is semidet.
%
%   T es una cita bien formada, sin variables.
es_cita(cita(D, hora(H, M), A, Con, Lugar)) :-
    ground(D),
    ( D = dia(_) ; D = fecha(_, _) ),
    integer(H),
    integer(M),
    A = nombre(_, _),
    ( Con == nadie ; Con = nombre(_, _) ),
    ( Lugar == ninguno ; Lugar = nombre(_, _) ),
    !.
```

La prueba `guardar_y_cargar` guarda una agenda con dos citas en un archivo
temporal y comprueba que al cargarla se obtiene la misma lista; la prueba
`cargar_invalido` carga un archivo que contiene `hola.` y espera el error
de dominio.

## 9

Una sola cláusula más de `transformacion/3`, recursiva: aplica cualquier
operación, incluida otra `en_exterior/1`, a la segunda parte de una
relación:

<!-- ejemplo: capitulo-55/soluciones_analogia.pl archivo -->
```prolog
:- ensure_loaded(analogia).

transformacion(en_exterior(Op), D1, D2) :-
    partes(D1, R, A, B),
    transformacion(Op, B, B2),
    partes(D2, R, A, B2).

problema(anidado, dentro(circulo, encima(cuadrado, triangulo)),
         dentro(circulo, encima(triangulo, cuadrado)),
         dentro(rombo, encima(circulo, cuadrado)),
         [dentro(rombo, encima(circulo, cuadrado)),
          dentro(rombo, encima(cuadrado, circulo)),
          encima(circulo, cuadrado)]).
```

```prolog
?- resolver(anidado, N, Ops).
N = 2,
Ops = [en_exterior(invertir)].
```

La recursión termina aunque `Op` llegue libre: cada nivel de
`en_exterior/1` exige una relación un nivel más adentro del diagrama, y
`partes/4` falla con una figura. Con la sucesión más corta primero, la
explicación es una sola operación; la sucesión `[exterior(…)]` no sirve,
porque `exterior/1` pone una figura y aquí la parte exterior es una
relación.

## 10

El guion, sus palabras, una historia, los sustantivos nuevos y tres
oraciones se agregan a los predicados `multifile` de `guiones.pl`; el suceso
de ir se reutiliza:

<!-- ejemplo: capitulo-55/soluciones_guiones.pl fragmento: guion(consulta, .. sujeto(M), " le recetó ", un(R), " ", al(Q), ".". -->
```prolog
guion(consulta,
      [ ir(Paciente, Antes, Clinica),
        esperar(Paciente, Sala),
        atender(Medica, Paciente),
        recetar(Medica, Remedio, Paciente),
        ir(Paciente, Clinica, Despues)
      ],
      [ Paciente-paciente, Antes-casa, Clinica-clinica, Sala-sala,
        Medica-medica, Remedio-remedio, Despues-otro_lugar ]).

activa(clinica, consulta).
activa(medica, consulta).

historia(clinica, [ ir(luis, _, clinica), recetar(_, jarabe, _) ]).

sustantivo(paciente, m, "paciente", no).
sustantivo(clinica, f, "clínica", no).
sustantivo(sala, f, "sala de espera", no).
sustantivo(medica, f, "médica", no).
sustantivo(remedio, m, "remedio", no).
sustantivo(jarabe, m, "jarabe", no).

oracion(esperar(Q, S)) -->
    sujeto(Q), " esperó en ", el(S), ".".
oracion(atender(M, Q)) -->
    sujeto(M), " atendió ", al(Q), ".".
oracion(recetar(M, R, Q)) -->
    sujeto(M), " le recetó ", un(R), " ", al(Q), ".".
```

```prolog
?- historia(clinica, H), once(entender(H, _, E)), contar(E, T).
H = [ir(luis, casa, clinica), recetar(medica, jarabe, luis)],
E = [ir(luis, casa, clinica), esperar(luis, sala), atender(medica, luis), recetar(medica, jarabe, luis), ir(luis, clinica, otro_lugar)],
T = "Luis fue de su casa a la clínica. Luis esperó en la sala de espera. La médica atendió a Luis. La médica le recetó un jarabe a Luis. Luis fue de la clínica a otro lugar.".
```

La historia no dice quién recetó el jarabe ni a quién; la unificación con
el guion liga el paciente a Luis por el primer suceso, y la médica toma su
valor por omisión.

## 11

La gramática lee oraciones unidas por comas, que `palabras/2` descarta, o
por «y». La primera oración tiene sujeto; las siguientes pueden no tenerlo,
y entonces heredan el de la anterior, que viaja como argumento de
`mas_sucesos//2`:

<!-- ejemplo: capitulo-55/soluciones_guiones.pl predicado: relato//1 mas_sucesos//2 sujeto//2 comprender/2 -->
```prolog
%!  relato(-Sucesos:list)// is semidet.
%
%   Una historia en castellano: oraciones unidas por y o por comas, la
%   primera con sujeto. Una oración sin sujeto tiene el de la anterior.
relato([S|Ss]) -->
    [Sujeto],
    { \+ no_es_sujeto(Sujeto) },
    predicado(Sujeto, S),
    mas_sucesos(Sujeto, Ss).

%!  mas_sucesos(+Sujeto, -Sucesos:list)// is nondet.
%
%   Las oraciones que siguen, con Sujeto como sujeto si no nombran otro.
mas_sucesos(Sujeto0, [S|Ss]) -->
    (   [y]
    ->  []
    ;   []
    ),
    sujeto(Sujeto0, Sujeto),
    predicado(Sujeto, S),
    mas_sucesos(Sujeto, Ss).
mas_sucesos(_, []) -->
    [].

%!  sujeto(+Sujeto0, -Sujeto)// is nondet.
%
%   Un nombre como sujeto, o ninguno: entonces Sujeto es Sujeto0.
sujeto(_, Sujeto) -->
    [Sujeto],
    { \+ no_es_sujeto(Sujeto) }.
sujeto(Sujeto, Sujeto) -->
    [].

%!  comprender(+Texto:string, -Relato:string) is semidet.
%
%   Relato cuenta la historia de Texto completada con el primer guion que
%   la explica. Falla si Texto no es una historia o ningún guion la
%   explica.
comprender(Texto, Relato) :-
    palabras(Texto, Palabras),
    once(phrase(relato(Historia), Palabras)),
    once(entender(Historia, _, Entendida)),
    contar(Entendida, Relato).
```

```prolog
?- comprender("Juan fue a Leones, comió una hamburguesa y se fue.", R).
R = "Juan fue de su casa a Leones. Juan se sentó a una mesa. Juan le pidió una hamburguesa al mozo. El mozo le trajo una hamburguesa a Juan. Juan comió una hamburguesa. Juan le pagó la cuenta al mozo. Juan fue de Leones a otro lugar.".
```

«se fue» da `ir(juan, _, _)`, sin origen ni destino: el guion los completa
con el restaurante y con otro lugar. `sujeto//2` prueba primero leer un
nombre, y por eso `no_es_sujeto/1` excluye las palabras con que empieza un
predicado: sin esa lista, «se» se leería como el sujeto de «fue a …».

## 12

<!-- ejemplo: capitulo-55/soluciones_aventura.pl predicado: responder/4 aventura_con_eliza/1 -->
```prolog
%!  responder(+Frase:string, +Estado0, -Estado, -Respuesta:string) is det.
%
%   Si Frase es una orden de la aventura, la ejecuta y Respuesta es la del
%   juego; si no, Respuesta es la de ELIZA, en el estado Estado0.
responder(Frase, Estado0, Estado, Respuesta) :-
    entender(Frase, Orden),
    (   Orden == no_entendido
    ->  responder_eliza(Frase, Estado0, Estado, Respuesta)
    ;   Estado = Estado0,
        responder_orden(Orden, Respuesta)
    ).

%!  aventura_con_eliza(+In) is det.
%
%   Empieza una partida y conversa con las frases de In.
aventura_con_eliza(In) :-
    iniciar,
    estado_inicial(E0),
    conversar(In, responder, E0).
```

`entender/2` de la aventura responde `no_entendido` cuando la frase no es
una orden, y esa es la señal para pasarla a ELIZA; el módulo importa
`responder/2` de la aventura y `responder/4` de ELIZA con otros nombres,
porque define su propio `responder/4`. La prueba de
`soluciones_aventura.plt` conversa con «tomar el perchero», «estoy
aburrido», «biblioteca», «tomar la llave» y «adiós»: la primera y las dos
últimas órdenes van al juego y la segunda frase a ELIZA, que responde
«¿Por qué estás aburrido?». Los dos estados son distintos: el del juego en
la base de datos del módulo `estado`, el de ELIZA en el argumento del bucle.
