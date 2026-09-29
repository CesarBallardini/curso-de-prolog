# Soluciones del capítulo 53 — Proyecto: morfología del castellano

El código de esta página está en `ejemplos/capitulo-53/`, en cinco archivos
con sus pruebas: `soluciones.pl` (ejercicios 2, 3, 5, 6, 8 y 9),
`soluciones_imperfecto.pl` (4), `soluciones_voseo.pl` (7),
`soluciones_reglas.pl` (10 y 11) y `soluciones_adivinar.pl` (12). Cada uno
carga la versión 4, `paralelo.pl`, y con ella las versiones 2 y 3; la
versión 2 se consulta con el nombre de su módulo, `reglas:forma/2`. Las
palabras y las reglas nuevas se agregan con cláusulas de los predicados que
el léxico (`lexico.pl`), la versión 2 y la versión 3 declaran `multifile`, sin modificar
esos archivos. Como los archivos agregan cosas distintas —un tiempo, una
persona, dos reglas—, cada uno se carga solo.

<!-- ejemplo: capitulo-53/soluciones.pl fragmento: :- use_module(lexico). .. :- ensure_loaded(paralelo). -->
```prolog
:- use_module(lexico).
:- ensure_loaded(paralelo).
```

## 1

«Imagen» es llana terminada en n: con la e del plural pasa a esdrújula, y
la tilde aparece en la a. «Feliz» termina en z: la epéntesis agrega la e y
la ortografía escribe c ante ella. «Llegar» tiene la raíz «lleg», y ante
la é del pretérito la g se escribe gu. «Volver» lleva el acento en la raíz
ante «en», una sola vocal sin tilde: diptonga. «Dormir» es un verbo en -ir
de la clase `o_ue`, y en la tercera persona del pretérito la o se cierra en
u. «Siguen» se analiza generando: «sig» ante e se escribe «sigu»:

```prolog
?- reglas:forma(P, nombre("imagen", femenino, plural)).
P = "imágenes" ;
false.

?- reglas:forma(P, adjetivo("feliz", masculino, plural)).
P = "felices" ;
false.

?- reglas:forma(P, verbo("llegar", preterito, 1, singular)).
P = "llegué" ;
false.

?- reglas:forma(P, verbo("volver", presente, 3, plural)).
P = "vuelven" ;
false.

?- reglas:forma(P, verbo("dormir", preterito, 3, singular)).
P = "durmió" ;
false.

?- reglas:forma("siguen", A).
A = verbo("seguir", presente, 3, plural) ;
false.
```

Todas terminan en `false.` porque `forma/2` de la versión 2 recorre todos
los análisis del léxico, y después de la respuesta quedan otros por
probar.

## 2

Las palabras nuevas son hechos, y las reglas son las mismas. «Nariz» sigue
a «luz»; «razón», a «camión»; «origen», a «examen»; y «cortés», a
«inglés», aunque es invariable en género:

<!-- ejemplo: capitulo-53/soluciones.pl fragmento: lexico:nombre("nariz", femenino). .. lexico:adjetivo("cortés", invariable). -->
```prolog
lexico:nombre("nariz", femenino).
lexico:nombre("razón", femenino).
lexico:nombre("origen", masculino).
lexico:adjetivo("cortés", invariable).
```

```prolog
?- reglas:forma(P, nombre("razón", femenino, plural)).
P = "razones" ;
false.

?- forma(P, nombre("razón", femenino, plural)).
P = "razones" ;
false.

?- reglas:lexica(nombre("origen", masculino, plural), S).
S = [o, r, i, 'J', e, n, +, s] ;
false.
```

La g de «origen» está ante e, así que su forma subyacente es `'J'`: en
«orígenes» sigue ante e y se escribe g. Las pruebas comparan los plurales
de las cuatro palabras en las dos versiones: «narices», «razones»,
«orígenes», «corteses».

## 3

«Empezar» junta un cambio de la raíz y uno ortográfico: la e acentuada de
«empez» diptonga en el presente, y la z se escribe c ante la é del
pretérito. «Colgar» diptonga la o, y su g se escribe gu ante é. Las dos
reglas son independientes —una actúa en `lexica/2` y la otra en la
ortografía— y por eso se combinan sin una regla nueva:

<!-- ejemplo: capitulo-53/soluciones.pl fragmento: lexico:verbo("empezar", e_ie). .. lexico:verbo("colgar", o_ue). -->
```prolog
lexico:verbo("empezar", e_ie).
lexico:verbo("colgar", o_ue).
```

```prolog
?- conjugacion("empezar", presente, Fs).
Fs = ["empiezo", "empiezas", "empieza", "empezamos", "empezáis", "empiezan"].

?- conjugacion("empezar", preterito, Fs).
Fs = ["empecé", "empezaste", "empezó", "empezamos", "empezasteis", "empezaron"].

?- conjugacion("colgar", presente, Fs).
Fs = ["cuelgo", "cuelgas", "cuelga", "colgamos", "colgáis", "cuelgan"].

?- conjugacion("colgar", preterito, Fs).
Fs = ["colgué", "colgaste", "colgó", "colgamos", "colgasteis", "colgaron"].
```

`conjugacion/3` es la del [ejercicio 9](#9).

## 4

Un tiempo nuevo es una tabla de terminaciones más, agregada como una
cláusula de `terminacion/5`; ser e ir se listan con otra de
`irregular/5`:

<!-- ejemplo: capitulo-53/soluciones_imperfecto.pl fragmento: lexico:terminacion(Conj, imperfecto, Persona, Numero, T) :- .. "iban"]). -->
```prolog
lexico:terminacion(Conj, imperfecto, Persona, Numero, T) :-
    imperfecto(Conj, Ts),
    persona(I, Persona, Numero),
    nth1(I, Ts, T).

lexico:irregular(Lema, imperfecto, Persona, Numero, Forma) :-
    imperfecto_irregular(Lema, Formas),
    persona(I, Persona, Numero),
    nth1(I, Formas, Forma).

% imperfecto(Conj, Ts): las terminaciones del imperfecto.
imperfecto(a, ["aba", "abas", "aba", "ábamos", "abais", "aban"]).
imperfecto(e, ["ía", "ías", "ía", "íamos", "íais", "ían"]).
imperfecto(i, ["ía", "ías", "ía", "íamos", "íais", "ían"]).

% imperfecto_irregular(Lema, Formas): las seis formas, listadas.
imperfecto_irregular("ser", ["era", "eras", "era", "éramos", "erais",
                             "eran"]).
imperfecto_irregular("ir", ["iba", "ibas", "iba", "íbamos", "ibais",
                            "iban"]).
```

`acento_en_la_raiz/1` decide el cambio de la raíz por la terminación: «aba»
tiene dos vocales y «ía» lleva tilde, así que en ninguno de los dos casos
el acento cae en la raíz. «Hacía» tiene dos análisis, porque la primera y
la tercera persona del singular del imperfecto son la misma forma:

```prolog
?- forma(P, verbo("contar", imperfecto, 1, plural)).
P = "contábamos" ;
false.

?- forma("hacía", A).
A = verbo("hacer", imperfecto, 3, singular) ;
A = verbo("hacer", imperfecto, 1, singular).

?- forma(P, verbo("ser", imperfecto, 1, plural)).
P = "éramos" ;
false.
```

## 5

Con la condición antes de la llamada recursiva, la variante genera igual
que `escribir/2`, pero en sentido inverso no encuentra nada:

<!-- ejemplo: capitulo-53/soluciones.pl predicado: escribir_antes/2 -->
```prolog
%!  escribir_antes(?Subyacente:list, ?Escrita:list) is nondet.
%
%   Ejercicio 5: escribir/2 reducida a la letra k, con cada condición
%   antes de la llamada recursiva. Genera bien; en sentido inverso no
%   encuentra la forma subyacente de «tocar».
escribir_antes([], []).
escribir_antes([k|S], [q, u|E]) :-
    reglas:frontal(S),
    escribir_antes(S, E).
escribir_antes([k|S], [c|E]) :-
    \+ reglas:frontal(S),
    escribir_antes(S, E).
escribir_antes([L|S], [L|E]) :-
    \+ memberchk(L, [k, c, q]),
    escribir_antes(S, E).
```

```prolog
?- escribir_antes([t, o, k, a, r], E).
E = [t, o, c, a, r] ;
false.

?- escribir_antes(S, [t, o, c, a, r]).
false.
```

Con la forma escrita ligada y la subyacente libre, la c de «tocar» solo
puede venir de la segunda cláusula de k. Allí `\+ reglas:frontal(S)` se
evalúa con `S` libre: `frontal([V|_])` unifica `S` con una lista que empieza
por e, la prueba tiene éxito, y la negación falla. La cláusula no se aplica
nunca en ese sentido, aunque la letra siguiente sea una a. Puesta después de
la llamada recursiva, la misma condición examina un `S` ya ligado a
`[a, r]`. El encabezado declara entonces un solo modo, con la forma
subyacente de entrada:

```prolog
%!  escribir_antes(+Subyacente:list, -Escrita:list) is det.
```

## 6

La clase nueva es una cláusula de `diptongo/3`, y el verbo, un hecho del
léxico:

<!-- ejemplo: capitulo-53/soluciones.pl fragmento: lexico:verbo("jugar", u_ue). .. reglas:diptongo(u_ue, u, [u, e]). -->
```prolog
lexico:verbo("jugar", u_ue).
reglas:diptongo(u_ue, u, [u, e]).
```

```prolog
?- conjugacion("jugar", presente, Fs).
Fs = ["juego", "juegas", "juega", "jugamos", "jugáis", "juegan"].

?- conjugacion("jugar", preterito, Fs).
Fs = ["jugué", "jugaste", "jugó", "jugamos", "jugasteis", "jugaron"].
```

La u de «jugué» no es la de la raíz: es la de la ortografía, que escribe
gu la g subyacente ante é, como en «llegué».

## 7

La persona `vos` es otro valor del argumento Persona: siete cláusulas de
`terminacion/5` y cuatro de `irregular/5`.

<!-- ejemplo: capitulo-53/soluciones_voseo.pl fragmento: lexico:terminacion(a, presente, vos, singular, "ás"). .. lexico:irregular("ir", preterito, vos, singular, "fuiste"). -->
```prolog
lexico:terminacion(a, presente, vos, singular, "ás").
lexico:terminacion(e, presente, vos, singular, "és").
lexico:terminacion(i, presente, vos, singular, "ís").
lexico:terminacion(a, preterito, vos, singular, "aste").
lexico:terminacion(e, preterito, vos, singular, "iste").
lexico:terminacion(i, preterito, vos, singular, "iste").
lexico:terminacion(fuerte, preterito, vos, singular, "iste").

lexico:irregular("ser", presente, vos, singular, "sos").
lexico:irregular("ir", presente, vos, singular, "vas").
lexico:irregular("ser", preterito, vos, singular, "fuiste").
lexico:irregular("ir", preterito, vos, singular, "fuiste").
```

Las terminaciones del presente llevan tilde, así que para
`acento_en_la_raiz/1` el acento no cae en la raíz y la vocal no cambia:

```prolog
?- forma(P, verbo("contar", presente, vos, singular)).
P = "contás" ;
false.

?- forma(P, verbo("pedir", presente, vos, singular)).
P = "pedís".

?- forma("tenés", A).
A = verbo("tener", presente, vos, singular).

?- forma("fuiste", A).
A = verbo("ser", preterito, 2, singular) ;
A = verbo("ser", preterito, vos, singular) ;
A = verbo("ir", preterito, 2, singular) ;
A = verbo("ir", preterito, vos, singular).
```

«Fuiste» tiene cuatro análisis: dos verbos por dos personas. La condición
de `raiz_verbal/7` se formuló sobre la terminación, y no sobre la persona;
por eso vale para una persona que no existía cuando se escribió.

## 8

<!-- ejemplo: capitulo-53/soluciones.pl predicado: candidatos/2 -->
```prolog
%!  candidatos(+Palabra:string, -Subyacentes:list) is det.
%
%   Ejercicio 8: Subyacentes son las formas subyacentes que las reglas de
%   la versión 4 admiten para Palabra, sin el léxico.
candidatos(Palabra, Subyacentes) :-
    reglas(Rs),
    string_chars(Palabra, Letras),
    findall(S, transducir(paralelo(Rs), S, Letras), Subyacentes).
```

```prolog
?- candidatos("toqué", Ss).
Ss = [[t, +, o, k, +, é], [t, +, o, k, é], [t, +, o, +, k, +, é],
      [t, +, o, +, k, é], [t, o, k, +, é], [t, o, k, é],
      [t, o, +, k, +, é], [t, o, +, k, é]].
```

«Luces» tiene 26, «toqué» 8 y «camiones» 260; las pruebas lo verifican.
Las ocho de «toqué» son la misma sucesión de letras, `t o k é`, con o sin
un límite en cada uno de los tres lugares entre letras: las reglas saben
cómo se escribe cada sonido, pero no dónde termina la raíz. En «luces» y
«camiones» se agregan otras fuentes de ambigüedad: la e puede ser de la
raíz o agregada, y una vocal con tilde en la forma subyacente puede
perderla. Solo el léxico decide. Sin la regla `limite`, nada impediría
dos límites seguidos, y como un límite no escribe nada, cada lugar
admitiría cualquier cantidad: las formas subyacentes serían infinitas, y
`transducir/3` no terminaría.

## 9

<!-- ejemplo: capitulo-53/soluciones.pl predicado: conjugacion/3 -->
```prolog
%!  conjugacion(+Lema:string, +Tiempo, -Formas:list(string)) is semidet.
%
%   Ejercicio 9: Formas son las seis formas de Lema en el Tiempo, en el
%   orden de las personas: yo, tú, él, nosotros, vosotros, ellos. Falla si
%   Lema no es un verbo del léxico.
conjugacion(Lema, Tiempo, Formas) :-
    verbo(Lema, _),
    !,
    findall(F,
            ( terminacion(a, Tiempo, Persona, Numero, _),
              once(forma(F, verbo(Lema, Tiempo, Persona, Numero))) ),
            Formas).
```

`conjugacion/3` es `semidet`: para un lema del léxico da una sola lista, y
para otro falla. El corte después de `verbo/2` descarta la alternativa de
un lema que tuviera dos clases; `once/1` toma la única forma de cada
persona, sin dejar alternativas pendientes. Un lema que no es verbo falla,
en lugar de devolver una lista vacía que parecería una conjugación sin
formas:

```prolog
?- conjugacion("casa", presente, Fs).
false.
```

## 10

La regla `ye` tiene la forma de las del capítulo: patrones que impiden
escribir y fuera del contexto, y uno que impide escribir i dentro de él.

<!-- ejemplo: capitulo-53/soluciones_reglas.pl fragmento: lexico:verbo("leer", regular). .. [vocal, limite, par([i]:[i]), vocal]-medio -->
```prolog
lexico:verbo("leer", regular).
lexico:verbo("creer", regular).
lexico:verbo("averiguar", regular).

dos_niveles:par([i]:[y]).
dos_niveles:par([u]:['ü']).

% Ejercicio 10: i se escribe y si y solo si está entre una vocal, con un
% límite, y otra vocal.
dos_niveles:regla(ye,
                  [ [no(limite), par([i]:[y])]-medio,
                    [par([i]:[y])]-inicio,
                    [no(vocal), limite, par([i]:[y])]-medio,
                    [limite, par([i]:[y])]-inicio,
                    [par([i]:[y]), no(vocal)]-medio,
                    [par([i]:[y])]-final,
                    [vocal, limite, par([i]:[i]), vocal]-medio
```

```prolog
?- forma(P, verbo("leer", preterito, 3, singular)).
P = "leyó".

?- forma(P, verbo("leer", preterito, 1, plural)).
P = "leimos" ;
false.

?- reglas:forma(P, verbo("leer", preterito, 3, singular)).
P = "leió" ;
false.
```

Las pruebas verifican que «vivieron» y «sigues» no cambian. La primera
persona del plural sale sin tilde: «leímos» la necesita para marcar que i
y e no forman diptongo. El par `[i]:['í']` ya existe, pero la regla
`poner_tilde` lo prohíbe fuera de su contexto —vocales seguidas de n y un
límite—, y una regla nueva no puede permitir lo que otra prohíbe, porque las
reglas se aplican todas y basta una para rechazar. Hay que modificar
`poner_tilde`, agregándole el contexto nuevo en sus dos direcciones. La
versión 2 no tiene la regla y escribe «leió».

## 11

<!-- ejemplo: capitulo-53/soluciones_reglas.pl fragmento: dos_niveles:regla(dieresis, .. dos_niveles:solo_ante_frontal(par([u]:['ü']), Ps). -->
```prolog
dos_niveles:regla(dieresis,
                  [ [no(par([g]:[g])), par([u]:['ü'])]-medio,
                    [par([u]:['ü'])]-inicio
                  | Ps ]) :-
    dos_niveles:solo_ante_frontal(par([u]:['ü']), Ps).
```

```prolog
?- findall(P, forma(P, verbo("averiguar", preterito, 1, singular)), Ps).
Ps = ["averigüé"].

?- forma(P, verbo("averiguar", presente, 1, singular)).
P = "averiguo" ;
false.

?- reglas:forma(P, verbo("averiguar", preterito, 1, singular)).
false.
```

La regla `g` ya prohíbe g seguida de una u escrita u ante e o i: esa u se
leería como la de «guerra», que no suena. Por eso sin `dieresis` la
versión 4 tampoco genera nada. La versión 2 tiene la misma prohibición en
la segunda cláusula de g de `escribir/2`, y ninguna cláusula que escriba ü:
la forma subyacente `averigu+é` no tiene forma escrita.

## 12

<!-- ejemplo: capitulo-53/soluciones_adivinar.pl predicado: adivinar/2 -->
```prolog
%!  adivinar(+Palabra:string, -Analisis) is nondet.
%
%   Analisis es verbo(Lema, Tiempo, Persona, Numero) para un verbo
%   regular, que puede no estar en el léxico, del que Palabra sería una
%   forma. Da cada análisis una vez.
adivinar(Palabra, verbo(Lema, Tiempo, Persona, Numero)) :-
    reglas(Rs),
    string_chars(Palabra, Letras),
    findall(Lema0-Tiempo0-Persona0-Numero0,
            ( transducir(inversa(paralelo(Rs)), Letras, Subyacente),
              append(Raiz, [+|Letras1], Subyacente),
              Raiz \== [],
              \+ memberchk(+, Raiz),
              string_chars(T, Letras1),
              terminacion(Conj, Tiempo0, Persona0, Numero0, T),
              infinitivo(Conj, Inf),
              string_chars(Inf, LetrasInf),
              append(Raiz, LetrasInf, SubInf),
              transducir(paralelo(Rs), SubInf, LetrasLema),
              string_chars(Lema0, LetrasLema) ),
            Analisis0),
    sort(Analisis0, Analisis),
    member(Lema-Tiempo-Persona-Numero, Analisis).
```

```prolog
?- adivinar("bloguearon", A).
A = verbo("bloguear", preterito, 3, plural).

?- adivinar("chateamos", A).
A = verbo("chatear", presente, 1, plural) ;
A = verbo("chatear", preterito, 1, plural).

?- adivinar("cuentas", A).
A = verbo("cuentar", presente, 2, singular).
```

«Chateamos» es presente o pretérito, como cualquier verbo en -ar. Para
«cuentas» la respuesta es un verbo inexistente: la raíz «cuent» tiene un
diptongo que solo el léxico explica, porque la clase `o_ue` es una
propiedad de «contar» y no de la forma escrita. Sin el léxico, las reglas
reconstruyen la ortografía, no la historia de cada palabra.
