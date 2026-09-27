:- encoding(utf8).

% Capítulo 28 - Soluciones de los ejercicios 4 a 11.
%
% Usan los predicados de preguntar.pl, procesos.pl y fecha.pl, que este
% archivo carga. El ejercicio 5 retoma las reglas del sistema experto del
% capítulo 19.
%
% solo-local: leen del teclado, ejecutan procesos y consultan el entorno.
%
%?- edad_en(date(2005, 10, 3), date(2026, 9, 25), Edad).
%?- fecha_corta(date(2026, 9, 25), Texto).

:- ensure_loaded(preguntar).
:- ensure_loaded(procesos).
:- ensure_loaded(fecha).
:- use_module(library(process)).

% --- Ejercicio 4 ------------------------------------------------------------

%!  preguntar_opcion(+In, +Pregunta:string, +Opciones:list, -Elegida) is det.
%
%   Escribe Pregunta y las Opciones numeradas desde 1, y lee de In el número
%   de una; Elegida es esa opción.
preguntar_opcion(In, Pregunta, Opciones, Elegida) :-
    format("~w~n", [Pregunta]),
    forall(nth1(N, Opciones, Opcion),
           format("  ~d. ~w~n", [N, Opcion])),
    length(Opciones, Cantidad),
    preguntar_numero(In, "Opción", 1, Cantidad, N),
    nth1(N, Opciones, Elegida).

% --- Ejercicio 5 ------------------------------------------------------------

:- op(800, xfx, entonces).
:- op(790, fx, si).
:- op(780, xfy, y).

% regla(Nombre, si Condiciones entonces Conclusion): las reglas del
% capítulo 19, sin la del peso.
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
regla(r11, si ave y no_vuela y nada entonces pinguino).

% hipotesis(H): H es una de las conclusiones finales que se buscan.
hipotesis(guepardo).
hipotesis(tigre).
hipotesis(jirafa).
hipotesis(cebra).
hipotesis(pinguino).

:- dynamic respondido/2.

%!  identificar(+In, -Animal) is det.
%
%   Animal es la primera hipótesis que se prueba preguntando a la persona,
%   por In, los datos que ninguna regla concluye; desconocido si no se
%   prueba ninguna. Cada dato se pregunta una sola vez.
identificar(In, Animal) :-
    retractall(respondido(_, _)),
    (   hipotesis(H),
        probar(In, H)
    ->  Animal = H
    ;   Animal = desconocido
    ).

%!  probar(+In, +Meta) is nondet.
%
%   Meta se prueba con las reglas, o con la respuesta de la persona si
%   ninguna regla la concluye.
probar(In, A y B) :-
    !,
    probar(In, A),
    probar(In, B).
probar(_, Meta) :-
    respondido(Meta, Respuesta),
    !,
    Respuesta == si.
probar(In, Meta) :-
    regla(_, si _ entonces Meta),
    !,
    regla(_, si Condiciones entonces Meta),
    probar(In, Condiciones).
probar(In, Meta) :-
    atomic_list_concat(Palabras, '_', Meta),
    atomic_list_concat(Palabras, ' ', Texto),
    format(string(Pregunta), "¿~w?", [Texto]),
    preguntar_si_no(In, Pregunta, Respuesta),
    assertz(respondido(Meta, Respuesta)),
    Respuesta == si.

% --- Ejercicio 6 ------------------------------------------------------------

%!  primera_linea_de(+Programa:atom, +Argumentos:list, -Linea:string) is det.
%
%   Linea es la primera línea que escribe Programa con Argumentos.
primera_linea_de(Programa, Argumentos, Linea) :-
    salida_de(Programa, Argumentos, Salida, _),
    split_string(Salida, "\n", "\r", [Linea|_]).

% --- Ejercicio 7 ------------------------------------------------------------

%!  codigo_de(+Archivo, +Argumentos:list, -Codigo:integer) is det.
%
%   Codigo es el código de salida de swipl Archivo Argumentos. La salida
%   del programa se descarta.
codigo_de(Archivo, Argumentos, Codigo) :-
    process_create(path(swipl), [Archivo|Argumentos],
                   [stdout(null), stderr(null), process(Pid)]),
    process_wait(Pid, exit(Codigo)).

% --- Ejercicio 8 ------------------------------------------------------------

%!  edad_en(+Nacimiento, +Fecha, -Edad:integer) is det.
%
%   Edad son los años cumplidos en Fecha por una persona nacida en
%   Nacimiento; las dos son términos date/3.
edad_en(date(A1, M1, D1), date(A2, M2, D2), Edad) :-
    Anios is A2 - A1,
    (   M2-D2 @< M1-D1
    ->  Edad is Anios - 1
    ;   Edad = Anios
    ).

% --- Ejercicio 9 ------------------------------------------------------------

%!  proximo_habil(+Fecha, -Habil) is det.
%
%   Habil es el primer día después de Fecha que no es sábado ni domingo.
proximo_habil(Fecha, Habil) :-
    sumar_dias(Fecha, 1, Siguiente),
    day_of_the_week(Siguiente, N),
    (   N =< 5
    ->  Habil = Siguiente
    ;   proximo_habil(Siguiente, Habil)
    ).

% --- Ejercicio 10 -----------------------------------------------------------

%!  fecha_corta(+Fecha, -Texto:string) is det.
%
%   Texto es Fecha como "vie 25/09": las tres primeras letras del día, y el
%   día y el mes con dos cifras.
fecha_corta(date(Anio, Mes, Dia), Texto) :-
    dia_de_la_semana(date(Anio, Mes, Dia), Nombre),
    sub_atom(Nombre, 0, 3, _, Corto),
    format(string(Texto), "~w ~|~`0t~d~2+/~|~`0t~d~2+", [Corto, Dia, Mes]).

% --- Ejercicio 11 -----------------------------------------------------------

%!  directorio_de_datos(+Programa:atom, -Directorio:atom) is det.
%
%   Directorio es donde Programa guarda sus datos: dentro de %APPDATA% en
%   Windows, dentro de ~/.local/share en los demás sistemas. La ruta de
%   Windows se convierte a la forma de Prolog, con /.
directorio_de_datos(Programa, Directorio) :-
    (   current_prolog_flag(windows, true)
    ->  getenv('APPDATA', RutaDelSistema),
        prolog_to_os_filename(Base, RutaDelSistema)
    ;   getenv('HOME', Casa),
        directory_file_path(Casa, '.local/share', Base)
    ),
    directory_file_path(Base, Programa, Directorio).
