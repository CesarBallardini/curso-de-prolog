# Guiones

Esta página contiene la sección
[55.8](index.md#558-guiones-completar-una-historia) del
[capítulo 54](index.md): el aplicador de guiones al estilo de McSAM,
`guiones.pl`. El archivo está en `ejemplos/capitulo-55/`, con sus pruebas;
no es un módulo ni carga otros archivos, y corre en SWISH.

## Guiones: completar una historia

Un guion describe una situación conocida como una sucesión de sucesos: en un
restaurante, el cliente llega, se sienta, pide, le traen la comida, come,
paga y se va. McSAM, en la versión de Sterling y Shapiro, representa cada
suceso con una lista cuyo primer elemento es una primitiva de la teoría de
dependencia conceptual de Schank (`ptrans` para un traslado, `ingest` para
comer); un ejercicio del libro propone reescribirlo con estructuras. Aquí
cada suceso es un término con un verbo como functor: `ir(Quien, Desde,
Hacia)`, `comer(Quien, Comida)`. Los papeles del guion son variables, y
cada una tiene un valor por omisión:

<!-- ejemplo: capitulo-55/guiones.pl predicado: guion/3 -->
```prolog
%!  guion(?Nombre, -Sucesos:list, -Papeles:list) is nondet.
%
%   Sucesos son los sucesos del guion Nombre, en orden, y Papeles los
%   pares Papel-Omision, donde Papel es una variable de los sucesos y
%   Omision el valor que toma si la historia no lo nombra.
guion(restaurante,
      [ ir(Cliente, Antes, Local),
        sentarse(Cliente, Mesa),
        pedir(Cliente, Comida, Mozo),
        traer(Mozo, Comida, Cliente),
        comer(Cliente, Comida),
        pagar(Cliente, Cuenta, Mozo),
        ir(Cliente, Local, Despues)
      ],
      [ Cliente-cliente, Antes-casa, Local-restaurante, Mesa-mesa,
        Comida-comida, Mozo-mozo, Cuenta-cuenta, Despues-otro_lugar ]).
guion(colectivo,
      [ ir(Pasajero, Antes, Parada),
        subir(Pasajero, Colectivo, Parada),
        pagar(Pasajero, Boleto, Chofer),
        viajar(Pasajero, Colectivo, Destino),
        bajar(Pasajero, Colectivo, Destino)
      ],
      [ Pasajero-pasajero, Antes-casa, Parada-parada,
        Colectivo-colectivo, Boleto-boleto, Chofer-chofer,
        Destino-destino ]).
```

Una historia es una lista de sucesos con variables donde el texto no dice
nada. «Juan fue a Leones, comió una hamburguesa y se fue» es:

<!-- ejemplo: capitulo-55/guiones.pl fragmento: historia(leones, [ ir(juan, _, leones), .. ir(_, _, _) ]). -->
```prolog
historia(leones, [ ir(juan, _, leones),
                   comer(_, hamburguesa),
                   ir(_, _, _) ]).
```

**Entender una historia** tiene tres pasos, los de McSAM. Primero, una
palabra de la historia activa un guion: `leones` activa el del restaurante,
por el hecho `activa(leones, restaurante)`. Después, los sucesos de la
historia se emparejan en orden con algunos de los sucesos del guion; la
unificación liga los papeles (`Cliente = juan`, `Local = leones`) y las
variables de la historia (el que come es el cliente). Por último, los
papeles que ningún suceso nombró toman su valor por omisión:

<!-- ejemplo: capitulo-55/guiones.pl predicado: entender/3 subsucesion/2 por_omision/1 -->
```prolog
%!  entender(+Historia:list, -Nombre, -Entendida:list) is nondet.
%
%   Entendida son los sucesos del guion Nombre, activado por una palabra
%   de Historia, con los sucesos de Historia emparejados en orden y los
%   papeles que Historia no nombra completados con su valor por omisión.
entender(Historia, Nombre, Entendida) :-
    palabra_de(Historia, Palabra),
    activa(Palabra, Nombre),
    guion(Nombre, Entendida, Papeles),
    subsucesion(Historia, Entendida),
    maplist(por_omision, Papeles).

%!  subsucesion(?Historia:list, ?Guion:list) is nondet.
%
%   Los sucesos de Historia unifican, en el mismo orden, con algunos de los
%   sucesos de Guion.
subsucesion([], _).
subsucesion([S|Ss], [S|Gs]) :-
    subsucesion(Ss, Gs).
subsucesion([S|Ss], [_|Gs]) :-
    subsucesion([S|Ss], Gs).

%!  por_omision(+Par) is det.
%
%   Si el papel de Par = Papel-Omision sigue libre, queda ligado a Omision.
por_omision(Papel-Omision) :-
    (   var(Papel)
    ->  Papel = Omision
    ;   true
    ).
```

`subsucesion/2` tiene tres cláusulas: la historia vacía termina; el primer
suceso de la historia unifica con el primero del guion; o el primero del
guion se saltea. El orden de las dos últimas decide qué emparejamiento se
prueba primero: el que usa el suceso del guion antes que el que lo saltea. En
la historia de Leones, el primer `ir/3` de la historia unifica con el primero
del guion, y el último, `ir(_, _, _)`, que no nombra a nadie, con el último:
entre ellos está `comer/2`, y el orden no deja otra posibilidad.

```prolog
?- historia(colectivo, H), entender(H, G, E).
H = [subir(ana, colectivo, parada), bajar(ana, colectivo, plaza)],
G = colectivo,
E = [ir(ana, casa, parada), subir(ana, colectivo, parada), pagar(ana, boleto, chofer), viajar(ana, colectivo, plaza), bajar(ana, colectivo, plaza)] ;
false.

?- historia(sin_guion, H), entender(H, G, E).
false.
```

Una historia sin ninguna palabra que active un guion no se entiende. Una
historia que activa un guion pero no sigue su orden tampoco:
`subsucesion/2` falla, y `entender/3` prueba con otra palabra de la
historia.

**Contar la historia entendida.** `contar/2` la redacta con una gramática,
una oración por suceso, en pasado. Los nombres propios se escriben con
mayúscula, y los sustantivos comunes llevan el artículo que les corresponde
por género y número, con las contracciones «al» y «del»:

<!-- ejemplo: capitulo-55/guiones.pl predicado: oracion//1 -->
```prolog
%!  oracion(+Suceso)// is det.
%
%   La oración que cuenta Suceso, en pasado.
oracion(ir(Q, D, H)) -->
    sujeto(Q), " fue ", desde(D), " ", hacia(H), ".".
oracion(sentarse(Q, M)) -->
    sujeto(Q), " se sentó a ", un(M), ".".
oracion(pedir(Q, C, M)) -->
    sujeto(Q), " le pidió ", un(C), " ", al(M), ".".
oracion(traer(M, C, Q)) -->
    sujeto(M), " le trajo ", un(C), " ", al(Q), ".".
oracion(comer(Q, C)) -->
    sujeto(Q), " comió ", un(C), ".".
oracion(pagar(Q, C, M)) -->
    sujeto(Q), " le pagó ", el(C), " ", al(M), ".".
oracion(subir(Q, C, P)) -->
    sujeto(Q), " subió ", al(C), " en ", lugar(P), ".".
oracion(viajar(Q, C, D)) -->
    sujeto(Q), " viajó en ", el(C), " hasta ", lugar(D), ".".
oracion(bajar(Q, C, P)) -->
    sujeto(Q), " bajó ", del(C), " en ", lugar(P), ".".
```

```prolog
?- historia(colectivo, H), entender(H, _, E), contar(E, T).
H = [subir(ana, colectivo, parada), bajar(ana, colectivo, plaza)],
E = [ir(ana, casa, parada), subir(ana, colectivo, parada), pagar(ana, boleto, chofer), viajar(ana, colectivo, plaza), bajar(ana, colectivo, plaza)],
T = "Ana fue de su casa a la parada. Ana subió al colectivo en la parada. Ana le pagó el boleto al chofer. Ana viajó en el colectivo hasta Plaza. Ana bajó del colectivo en Plaza." ;
false.
```

Los hechos `historia/2`, `activa/2`, `guion/3` y `sustantivo/4`, y las
reglas de `oracion//1`, están declarados `multifile`: un archivo aparte
puede agregar un guion con sus palabras y sus oraciones sin modificar
`guiones.pl`, como pide el ejercicio 10.

!!! question "Actividad"
    Predecir qué da `entender/3` con la historia
    `[traer(mozo, empanadas, luis), ir(luis, _, _)]`, y con
    `[ir(luis, _, _), traer(mozo, empanadas, luis)]`. Comprobarlo, y
    explicar con `subsucesion/2` a qué `ir/3` del guion se liga el suceso
    `ir/3` de cada historia.
