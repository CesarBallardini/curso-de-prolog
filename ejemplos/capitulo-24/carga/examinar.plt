:- encoding(utf8).

:- begin_tests(examinar).

test(interfaz_de_relaciones, true(Ps == [aprobo/2])) :-
    interfaz(relaciones, Ps).

test(interfaz_de_examinar, true(Ps == [importados/3, interfaz/2])) :-
    interfaz(examinar, Ps).

test(importados_de_relaciones, true(Ps == [aprobo/2])) :-
    importados(usa_relaciones, relaciones, Ps).

test(importados_de_reglas, true(Ps == [aprobada/3])) :-
    importados(relaciones, reglas, Ps).

test(nada_importado, true(Ps == [])) :-
    importados(usa_relaciones, reglas, Ps).

% predicate_property/2 se presenta en el capítulo 33.
test(origen, true(M == relaciones)) :-
    predicate_property(usa_relaciones:aprobo(_, _), imported_from(M)).

test(clase, true(C-L == user-library)) :-
    module_property(relaciones, class(C)),
    module_property(lists, class(L)).

:- end_tests(examinar).
