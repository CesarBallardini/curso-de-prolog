:- encoding(utf8).

% Capítulo 39 - El intérprete del sistema experto, con tablas.
%
% Las reglas son las del capítulo 33 con la negación no: r11 y r12 dicen
% no vuela. La versión vuela de la base agrega r13, «un ave que no es
% pingüino ni avestruz vuela», que crea un ciclo positivo con r4 (ave,
% vuela, ave) y dos negativos con r11 y r12; la versión puede_volar
% concluye otra cosa y no los crea. Es el análisis de la sección 38.7.
%
% probar_sin_tabla/3 es el intérprete de arriba hacia abajo del capítulo
% 33, con \+ para la negación: con la versión vuela entra en el ciclo
% positivo y no termina. cierto/3 es el mismo intérprete tabulado, con
% tnot/1 para la negación: cada conclusión se prueba una vez por conjunto
% de observaciones, los ciclos positivos terminan y los negativos dejan
% indefinidas las conclusiones que dependen de ellos. diagnostico/3 separa
% las hipótesis verdaderas de las indefinidas.
%
%?- diagnostico(original, [tiene_plumas, nada, peso(30)], R).
%?- diagnostico(vuela, [tiene_plumas, nada, peso(30)], R).
%?- diagnostico(vuela, [tiene_pelo, come_carne, color_leonado, manchas_oscuras], R).

:- op(800, xfx, entonces).
:- op(790, fx, si).
:- op(780, xfy, y).
:- op(770, fy, no).

% regla(Nombre, si Condiciones entonces Conclusion): las Condiciones, unidas
% con y, permiten concluir Conclusion.
regla(r1,  si tiene_pelo entonces mamifero).
regla(r2,  si da_leche entonces mamifero).
regla(r3,  si tiene_plumas entonces ave).
regla(r4,  si vuela y pone_huevos entonces ave).
regla(r5,  si mamifero y come_carne entonces carnivoro).
regla(r6,  si mamifero y tiene_cascos entonces ungulado).
regla(r7,  si carnivoro y color_leonado y manchas_oscuras entonces guepardo).
regla(r8,  si carnivoro y color_leonado y rayas_negras entonces tigre).
regla(r9,  si ungulado y cuello_largo y manchas_oscuras entonces jirafa).
regla(r10, si ungulado y rayas_negras entonces cebra).
regla(r11, si ave y no vuela y nada entonces pinguino).
regla(r12, si ave y no vuela y peso(P) y P > 50 entonces avestruz).

% agregada(Version, Nombre, Regla): la versión Version de la base agrega la
% regla Regla, llamada Nombre.
agregada(vuela, r13, si ave y no pinguino y no avestruz entonces vuela).
agregada(puede_volar, r13,
         si ave y no pinguino y no avestruz entonces puede_volar).

% hipotesis(H): H es una de las conclusiones finales que el sistema busca.
hipotesis(guepardo).
hipotesis(tigre).
hipotesis(jirafa).
hipotesis(cebra).
hipotesis(pinguino).
hipotesis(avestruz).

%!  regla_de(+Version:atom, ?Nombre, ?Regla) is nondet.
%
%   Regla, llamada Nombre, es una regla de la base en la versión Version:
%   original, vuela o puede_volar.
regla_de(_, Nombre, Regla) :-
    regla(Nombre, Regla).
regla_de(Version, Nombre, Regla) :-
    agregada(Version, Nombre, Regla).

%!  probar_sin_tabla(+Version:atom, +Observaciones:list, +Condicion)
%!      is nondet.
%
%   Condicion se prueba con las reglas de Version y las Observaciones, de
%   arriba hacia abajo y sin tablas. Con un ciclo en las reglas, puede no
%   terminar.
probar_sin_tabla(Version, Os, A y B) :-
    probar_sin_tabla(Version, Os, A),
    probar_sin_tabla(Version, Os, B).
probar_sin_tabla(_, _, X > Y) :-
    X > Y.
probar_sin_tabla(Version, Os, no A) :-
    \+ probar_sin_tabla(Version, Os, A).
probar_sin_tabla(_, Os, Meta) :-
    atomica(Meta),
    member(Meta, Os).
probar_sin_tabla(Version, Os, Meta) :-
    atomica(Meta),
    regla_de(Version, _, si Condiciones entonces Meta),
    probar_sin_tabla(Version, Os, Condiciones).

%!  probar(+Version:atom, +Observaciones:list, +Condicion) is nondet.
%
%   Condicion se prueba con las reglas de Version y las Observaciones. Cada
%   conclusión se busca en la tabla de cierto/3, y la negación es tnot/1.
probar(Version, Os, A y B) :-
    probar(Version, Os, A),
    probar(Version, Os, B).
probar(_, _, X > Y) :-
    X > Y.
probar(Version, Os, no A) :-
    tnot(cierto(Version, Os, A)).
probar(Version, Os, Meta) :-
    atomica(Meta),
    cierto(Version, Os, Meta).

:- table cierto/3.

%!  cierto(+Version:atom, +Observaciones:list, ?Meta) is nondet.
%
%   Meta es una observación, o la conclusión de una regla de Version cuyas
%   condiciones se prueban. Las respuestas que dependen de un ciclo
%   negativo quedan indefinidas.
cierto(_, Os, Meta) :-
    member(Meta, Os).
cierto(Version, Os, Meta) :-
    regla_de(Version, _, si Condiciones entonces Meta),
    probar(Version, Os, Condiciones).

%!  atomica(+Condicion) is semidet.
%
%   Condicion no es una conjunción, una negación ni una comparación.
atomica(Condicion) :-
    Condicion \= (_ y _),
    Condicion \= (no _),
    Condicion \= (_ > _).

%!  diagnostico(+Version:atom, +Observaciones:list, -Resultado) is det.
%
%   Resultado es resultado(Verdaderas, Indefinidas): las hipótesis
%   verdaderas y las indefinidas con las reglas de Version y las
%   Observaciones.
diagnostico(Version, Os, resultado(Verdaderas, Indefinidas)) :-
    must_be(oneof([original, vuela, puede_volar]), Version),
    findall(H-V,
            ( hipotesis(H),
              valor(cierto(Version, Os, H), V) ),
            Valores),
    findall(H, member(H-verdadero, Valores), Verdaderas),
    findall(H, member(H-indefinido, Valores), Indefinidas).

%!  valor(+Meta, -Valor) is det.
%
%   Valor es verdadero, falso o indefinido: el de Meta, tabulada y sin
%   variables, como en juego.pl.
valor(Meta, Valor) :-
    findall(Condicion, call_delays(Meta, Condicion), Condiciones),
    (   Condiciones == []
    ->  Valor = falso
    ;   memberchk(true, Condiciones)
    ->  Valor = verdadero
    ;   Valor = indefinido
    ).
