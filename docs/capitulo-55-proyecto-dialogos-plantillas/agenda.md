# Una agenda en castellano

Esta página contiene la sección
[55.5](index.md#555-version-4-una-agenda-en-castellano) del
[capítulo 55](index.md): la versión 4 de los diálogos, `agenda.pl`, que
anota citas dictadas en castellano y responde preguntas sobre ellas. El
archivo está en `ejemplos/capitulo-55/`, con sus pruebas, y carga
`persona.pl` y archivos de los capítulos
[21](../capitulo-21-gramaticas-dcg/index.md) y
[44](../capitulo-44-proyecto-aventura-de-texto/index.md).

## Una agenda en castellano

El proyecto 15 de Clocksin y Mellish pide analizar frases como «Smith will be
in his office at 3 pm for a meeting», resumirlas en quién, qué, dónde y
cuándo, guardar ese resumen y responder preguntas como «Where is Smith at 3
pm?». La agenda de la versión 4 hace eso en castellano, dirigida al usuario:
anota «tengo una reunión con Pérez el martes a las 10 en la oficina» y
responde «¿qué tengo el martes?», «¿dónde estoy el martes a las 10?» y
«¿cuándo veo a Pérez?». Aquí una plantilla ya no alcanza: los complementos
van en cualquier orden, y el día y la hora tienen su propia sintaxis. La
frase se analiza con una gramática sobre las palabras, como en la
[sección 21.10](../capitulo-21-gramaticas-dcg/index.md#2110-el-proyecto-un-lenguaje-de-comandos):

<!-- ejemplo: capitulo-55/agenda.pl predicado: acto//1 complementos//1 complemento//1 -->
```prolog
%!  acto(?Acto)// is nondet.
%
%   Las palabras de Acto: anotar(Actividad, Complementos) para una cita,
%   que_hay(Dia), donde(Dia, Hora) o cuando(Persona) para una pregunta.
acto(anotar(Actividad, Complementos)) -->
    [tengo],
    nombre(Actividad),
    complementos(Complementos).
acto(que_hay(Dia)) -->
    [que, tengo],
    dia(Dia).
acto(donde(Dia, Hora)) -->
    [donde],
    estar,
    complementos(Complementos),
    { permutation(Complementos, [dia(Dia), hora(Hora)]) }.
acto(cuando(Persona)) -->
    [cuando],
    ver,
    nombre(Persona).

%!  complementos(?Cs:list)// is nondet.
%
%   Una sucesión de complementos, en cualquier orden.
complementos([C|Cs]) -->
    complemento(C),
    complementos(Cs).
complementos([]) -->
    [].

%!  complemento(?C)// is nondet.
%
%   Un complemento de una cita: con(Persona), en(Lugar), dia(Dia) u
%   hora(Hora).
complemento(con(P)) -->
    [con],
    nombre(P).
complemento(en(L)) -->
    [en],
    nombre(L).
complemento(dia(D)) -->
    dia(D).
complemento(hora(H)) -->
    hora(H).
```

`complementos//1` acepta cualquier sucesión de complementos, y
`cita/4` comprueba después que haya exactamente un día y una hora, y a lo
sumo una persona y un lugar. El día es el nombre de un día de la semana o una
fecha como «el 3 de octubre», que se valida con `fecha_valida/3` del
[capítulo 21](../capitulo-21-gramaticas-dcg/index.md). `fechas.pl` no es un
módulo: la agenda lo carga en un módulo propio con
`load_files(fechas21:'../capitulo-21/fechas', [])`, como el puente del
[capítulo 43](../capitulo-43-proyecto-resolver-ecuaciones/index.md), para
que sus predicados no se mezclen con los de la agenda. La hora admite «a las
10», «a las 10 y media», «a las 10:30», «a la una» y «de la tarde»:

<!-- ejemplo: capitulo-55/agenda.pl predicado: hora//1 -->
```prolog
%!  hora(?H)// is semidet.
%
%   Una hora, hora(Horas, Minutos): a las 10, a las 10 y media, a las 10
%   y cuarto, a las 10:30 o a la una, seguida o no de de la mañana, de la
%   tarde o de la noche.
hora(hora(H, M)) -->
    (   [a, la, una]
    ->  { H0 = 1 }
    ;   [a, las, N],
        { atom_number(N, H0),
          between(0, 23, H0) }
    ),
    minutos(M),
    momento(H0, H).
```

```prolog
?- phrase(acto(A), [donde, estoy, a, las, '9', de, la, noche, el, '3', de, octubre]).
A = donde(fecha(10, 3), hora(21, 0)) ;
false.

?- phrase(acto(A), [tengo, una, clase, el, '31', de, septiembre, a, las, '9']).
false.
```

`atender/4` analiza la frase, aplica el acto a la agenda y redacta la
respuesta. La agenda es una lista de citas que entra y sale por argumentos,
como el estado de ELIZA; `atender/4` falla si la frase no es de la agenda,
y la versión 5 depende de esa falla:

<!-- ejemplo: capitulo-55/agenda.pl predicado: atender/4 efecto/5 -->
```prolog
%!  atender(+Frase:string, +Agenda0:list, -Agenda:list,
%!          -Respuesta:string) is semidet.
%
%   Frase es una frase de la agenda: Agenda es Agenda0 con la cita anotada
%   al final,
%   o Agenda0 si la frase pregunta o la cita choca con otra, y Respuesta es
%   la respuesta. Falla si Frase no es una frase de la agenda.
atender(Frase, Agenda0, Agenda, Respuesta) :-
    palabras(Frase, Palabras),
    once(phrase(acto(Acto), Palabras)),
    efecto(Acto, Frase, Agenda0, Agenda, Resultado),
    phrase(oracion(Resultado), Codigos),
    string_codes(Respuesta, Codigos).

%!  efecto(+Acto, +Frase:string, +Agenda0:list, -Agenda:list,
%!         -Resultado) is semidet.
%
%   Resultado es el término de la respuesta a Acto; Agenda es la agenda que
%   queda. Falla si Acto es anotar y la cita no tiene exactamente un día y
%   una hora, o repite un complemento.
efecto(anotar(Actividad, Cs), Frase, Agenda0, Agenda, Resultado) :-
    cita(Actividad, Cs, Frase, Cita),
    Cita = cita(Dia, Hora, _, _, _),
    (   member(Otra, Agenda0),
        Otra = cita(Dia, Hora, _, _, _)
    ->  Agenda = Agenda0,
        Resultado = ocupado(Otra)
    ;   append(Agenda0, [Cita], Agenda),
        Resultado = anotada(Cita)
    ).
efecto(que_hay(Dia), _, Agenda, Agenda, del_dia(Dia, Citas)) :-
    findall(H-C, ( member(C, Agenda), C = cita(Dia, H, _, _, _) ), Pares),
    keysort(Pares, Ordenados),
    pairs_values(Ordenados, Citas).
efecto(donde(Dia, Hora), _, Agenda, Agenda, Resultado) :-
    (   member(C, Agenda),
        C = cita(Dia, Hora, _, _, _)
    ->  Resultado = lugar(C)
    ;   Resultado = libre(Dia, Hora)
    ).
efecto(cuando(nombre(_, P)), Frase, Agenda, Agenda, con_quien(N, Citas)) :-
    escrito(Frase, nombre(ninguno, P), N),
    findall(C, ( member(C, Agenda),
                 C = cita(_, _, _, nombre(_, Texto), _),
                 palabras(Texto, [P]) ),
            Citas).
```

```prolog
?- atender("Tengo una reunión con Pérez el martes a las 10", [], A, R).
A = [cita(dia(martes), hora(10, 0), nombre(una, "reunión"), nombre(ninguno, "Pérez"), ninguno)],
R = "Anotado: el martes a las 10:00, una reunión con Pérez.".
```

Los nombres se guardan con la escritura que tenían en la frase, recuperada
con `escritura/3` de la versión 2, y un nombre sin artículo, como «Pérez»,
se escribe con mayúscula porque es un nombre propio. Las respuestas son el
resumen de Clocksin y Mellish redactado en una oración: `oracion//1`
genera el texto como una lista de códigos, con la técnica de las respuestas
de la aventura del
[capítulo 44](../capitulo-44-proyecto-aventura-de-texto/lenguaje.md#ordenes-y-respuestas-en-castellano):
un término por respuesta, una regla por término, y no terminales auxiliares
para el día, la hora y los nombres con su artículo. Una cita a la misma hora
del mismo día que otra no se anota: la respuesta es «Ya tienes …».

!!! question "Actividad"
    Predecir qué responde `atender/4` a «Tengo una clase el lunes a las 9 y
    a las 10», a «Tengo un café a las 5 de la tarde con Ana en el bar el
    viernes» y a «¿Dónde estoy el viernes a las 17?» después de la segunda.
    Comprobarlo, y explicar la primera respuesta con `cita/4`.
