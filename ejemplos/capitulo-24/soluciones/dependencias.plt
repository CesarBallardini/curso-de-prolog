:- encoding(utf8).

:- begin_tests(dependencias).

test(datos, true(Ms == [])) :-
    dependencias(datos, Ms).

test(reglas, true(Ms == [datos])) :-
    dependencias(reglas, Ms).

test(informes, true(Ms == [datos, reglas])) :-
    dependencias(informes, Ms).

test(comandos, true(Ms == [datos, informes, reglas])) :-
    dependencias(comandos, Ms).

test(horarios, true(Ms == [datos, informes])) :-
    dependencias(horarios, Ms).

% use_module/2 con la lista vacía no importa nada en dependencias.
test(sin_importar, true(Ms == [])) :-
    dependencias(dependencias, Ms).

:- end_tests(dependencias).
