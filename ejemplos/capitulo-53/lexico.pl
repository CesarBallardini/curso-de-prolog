:- encoding(utf8).

% Capítulo 53 - El léxico: las palabras que las reglas no pueden inventar.
%
% Cada entrada da el lema, escrito como string para conservar las tildes,
% y la clase de flexión que las reglas necesitan. Lo que ninguna regla
% predice se lista entero: las formas de ser y de ir, la primera persona
% en -go, y la raíz del pretérito irregular.
%
% solo-local: es un módulo, y SWISH no admite módulos propios.
%
%?- nombre(N, femenino).
%?- verbo(V, o_ue).

:- module(lexico,
          [ nombre/2,
            adjetivo/2,
            verbo/2,
            irregular/5,
            preterito_fuerte/2,
            terminacion/5,
            infinitivo/2,
            persona/3
          ]).

:- use_module(library(lists)).

% Otros archivos pueden agregar entradas al léxico.
:- multifile nombre/2, adjetivo/2, verbo/2, irregular/5,
             preterito_fuerte/2, terminacion/5.

% nombre(Lema, Genero): Lema es un sustantivo del género Genero.
nombre("casa", femenino).
nombre("libro", masculino).
nombre("sofá", masculino).
nombre("mes", masculino).
nombre("árbol", masculino).
nombre("luz", femenino).
nombre("lápiz", masculino).
nombre("pez", masculino).
nombre("camión", masculino).
nombre("canción", femenino).
nombre("examen", masculino).
nombre("imagen", femenino).

% adjetivo(Lema, Clase): Lema es un adjetivo en masculino singular. La
% clase o_a cambia la o final por a; agrega_a agrega una a para el
% femenino; invariable tiene una sola forma para los dos géneros.
adjetivo("rojo", o_a).
adjetivo("verde", invariable).
adjetivo("azul", invariable).
adjetivo("feliz", invariable).
adjetivo("joven", invariable).
adjetivo("inglés", agrega_a).
adjetivo("alemán", agrega_a).

% verbo(Lema, Clase): Lema es un verbo en infinitivo. La clase dice qué
% vocal de la raíz cambia cuando recibe el acento: regular, e_ie
% (pensar, piensa), o_ue (contar, cuenta) o e_i (pedir, pide).
verbo("hablar", regular).
verbo("comer", regular).
verbo("vivir", regular).
verbo("tocar", regular).
verbo("llegar", regular).
verbo("cazar", regular).
verbo("vencer", regular).
verbo("proteger", regular).
verbo("pensar", e_ie).
verbo("entender", e_ie).
verbo("sentir", e_ie).
verbo("contar", o_ue).
verbo("volver", o_ue).
verbo("dormir", o_ue).
verbo("pedir", e_i).
verbo("seguir", e_i).
verbo("elegir", e_i).
verbo("tener", e_ie).
verbo("hacer", regular).
verbo("poner", regular).
verbo("salir", regular).
verbo("ser", regular).
verbo("ir", regular).

%!  irregular(?Lema, ?Tiempo, ?Persona, ?Numero, ?Forma) is nondet.
%
%   Forma es la forma de Lema con esos rasgos, listada entera: la
%   conjugación regular no se aplica a ellos. El pretérito de ser y el de
%   ir son la misma lista.
irregular("tener", presente, 1, singular, "tengo").
irregular("hacer", presente, 1, singular, "hago").
irregular("poner", presente, 1, singular, "pongo").
irregular("salir", presente, 1, singular, "salgo").
irregular("ser", presente, 1, singular, "soy").
irregular("ser", presente, 2, singular, "eres").
irregular("ser", presente, 3, singular, "es").
irregular("ser", presente, 1, plural, "somos").
irregular("ser", presente, 2, plural, "sois").
irregular("ser", presente, 3, plural, "son").
irregular("ir", presente, 1, singular, "voy").
irregular("ir", presente, 2, singular, "vas").
irregular("ir", presente, 3, singular, "va").
irregular("ir", presente, 1, plural, "vamos").
irregular("ir", presente, 2, plural, "vais").
irregular("ir", presente, 3, plural, "van").
irregular(Lema, preterito, Persona, Numero, Forma) :-
    member(Lema, ["ser", "ir"]),
    fui(Persona, Numero, Forma).

% fui(Persona, Numero, Forma): el pretérito que comparten ser e ir.
fui(1, singular, "fui").
fui(2, singular, "fuiste").
fui(3, singular, "fue").
fui(1, plural, "fuimos").
fui(2, plural, "fuisteis").
fui(3, plural, "fueron").

% preterito_fuerte(Lema, Forma): Forma es la primera persona del
% singular de un pretérito con raíz propia; las otras personas usan esa
% raíz con las terminaciones sin tilde: tuve, tuviste, tuvo...
preterito_fuerte("tener", "tuve").
preterito_fuerte("hacer", "hice").
preterito_fuerte("poner", "puse").

% terminaciones(Conjugacion, Tiempo, Ts): Ts son las terminaciones de la
% conjugación en a, e o i, o del pretérito fuerte, para las seis personas,
% en el orden de persona/3. También los sufijos son entradas del léxico.
terminaciones(a, presente, ["o", "as", "a", "amos", "áis", "an"]).
terminaciones(e, presente, ["o", "es", "e", "emos", "éis", "en"]).
terminaciones(i, presente, ["o", "es", "e", "imos", "ís", "en"]).
terminaciones(a, preterito, ["é", "aste", "ó", "amos", "asteis", "aron"]).
terminaciones(e, preterito, ["í", "iste", "ió", "imos", "isteis", "ieron"]).
terminaciones(i, preterito, ["í", "iste", "ió", "imos", "isteis", "ieron"]).
terminaciones(fuerte, preterito, ["e", "iste", "o", "imos", "isteis", "ieron"]).

% persona(I, Persona, Numero): el lugar I de una lista de terminaciones.
persona(1, 1, singular).
persona(2, 2, singular).
persona(3, 3, singular).
persona(4, 1, plural).
persona(5, 2, plural).
persona(6, 3, plural).

%!  terminacion(?Conj, ?Tiempo, ?Persona, ?Numero, ?T:string) is nondet.
%
%   T es la terminación de la conjugación Conj (a, e, i o fuerte) en ese
%   tiempo, persona y número.
terminacion(Conj, Tiempo, Persona, Numero, T) :-
    terminaciones(Conj, Tiempo, Ts),
    persona(I, Persona, Numero),
    nth1(I, Ts, T).

% infinitivo(Conj, Terminacion): la terminación del infinitivo.
infinitivo(a, "ar").
infinitivo(e, "er").
infinitivo(i, "ir").
