:- encoding(utf8).

% Capítulo 38 - Las reglas del sistema experto leídas como datos: ¿tienen
% un significado claro?
%
% Las reglas son las del capítulo 33 con la negación no de su ejercicio 13:
% r11 y r12 dicen no vuela. base/2 convierte cada regla en una cláusula de
% Prolog, con \+ en lugar de no, y el programa base(Version) es la base de
% esa versión; con_hechos(Programa, Hechos) le agrega observaciones. Los
% evaluadores de semantica.pl la examinan: estratos/2 dice si la base es
% estratificada, y bien_fundado/3 da qué hipótesis son verdaderas y cuáles
% quedan indefinidas con unas observaciones. Dos versiones agregan una
% regla r13, «un ave que no es pingüino ni avestruz vuela»: la versión
% vuela concluye vuela, que r11 y r12 usan negado; la versión puede_volar
% concluye otra cosa.
%
% solo-local: carga semantica.pl con ensure_loaded/1, y SWISH no permite
% cargar otro archivo.
%
%?- estratos(base(original), E).
%?- ciclos_negativos(base(vuela), P).
%?- diagnostico(vuela, [tiene_plumas, nada, peso(30)], R).

:- ensure_loaded(semantica).

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

%!  base(+Version:atom, -Clausulas:list) is det.
%
%   Clausulas son las reglas de la base, más las que agrega Version
%   (original, vuela o puede_volar), como cláusulas Conclusion :- Cuerpo.
base(Version, Clausulas) :-
    must_be(oneof([original, vuela, puede_volar]), Version),
    findall(R, regla(_, R), Reglas),
    findall(R, agregada(Version, _, R), Agregadas),
    append(Reglas, Agregadas, Todas),
    maplist(regla_clausula, Todas, Clausulas).

%!  regla_clausula(+Regla, -Clausula) is det.
%
%   Clausula es Regla, si Condiciones entonces Conclusion, escrita como la
%   cláusula Conclusion :- Cuerpo.
regla_clausula(si Condiciones entonces Conclusion, Conclusion :- Cuerpo) :-
    condiciones_cuerpo(Condiciones, Cuerpo).

%!  condiciones_cuerpo(+Condiciones, -Cuerpo) is det.
%
%   Cuerpo es Condiciones con , en lugar de y, y \+ en lugar de no.
condiciones_cuerpo(Condiciones, Cuerpo) :-
    (   Condiciones = (A y B)
    ->  Cuerpo = (CuerpoA, CuerpoB),
        condiciones_cuerpo(A, CuerpoA),
        condiciones_cuerpo(B, CuerpoB)
    ;   Condiciones = (no A)
    ->  Cuerpo = (\+ A)
    ;   Cuerpo = Condiciones
    ).

:- multifile generado/2.

%!  generado(+Programa, -Clausulas:list) is semidet.
%
%   Los programas de este archivo: base(Version), las cláusulas de base/2,
%   y con_hechos(Programa, Hechos), las del programa Programa más un hecho
%   por cada uno de Hechos.
generado(base(Version), Clausulas) :-
    base(Version, Clausulas).
generado(con_hechos(Programa, Hechos), Clausulas) :-
    clausulas(Programa, Reglas),
    findall(H :- true, member(H, Hechos), Nuevas),
    append(Reglas, Nuevas, Clausulas).

%!  diagnostico(+Version:atom, +Observaciones:list, -Resultado) is det.
%
%   Resultado es resultado(Verdaderas, Indefinidas): las hipótesis
%   verdaderas y las indefinidas en el modelo bien fundado de la base de
%   Version con Observaciones como hechos.
diagnostico(Version, Observaciones, resultado(Verdaderas, Indefinidas)) :-
    bien_fundado(con_hechos(base(Version), Observaciones), V, I),
    findall(H, ( hipotesis(H), ord_memberchk(H, V) ), Verdaderas),
    findall(H, ( hipotesis(H), ord_memberchk(H, I) ), Indefinidas).
