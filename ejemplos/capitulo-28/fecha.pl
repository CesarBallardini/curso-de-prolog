:- encoding(utf8).

% Capítulo 28 - Fecha y hora: la fecha de hoy, y cuentas con fechas.
%
% Una fecha es date(Anio, Mes, Dia). hoy/1 es el único predicado que depende
% del reloj; los demás son cuentas que dan siempre el mismo resultado. Los
% nombres de los días y de los meses están en tablas propias: los de
% format_time/3 dependen de la configuración regional del sistema.
%
% solo-local: los ejemplos del capítulo se ejecutan en la máquina propia.
%
%?- dias_entre(date(2026, 3, 1), date(2026, 9, 25), Dias).
%?- fecha_texto(date(2026, 9, 25), Texto).

%!  hoy(-Fecha) is det.
%
%   Fecha es la fecha de hoy, en la zona horaria del sistema.
hoy(date(Anio, Mes, Dia)) :-
    get_time(Ahora),
    stamp_date_time(Ahora, date(Anio, Mes, Dia, _, _, _, _, _, _), local).

%!  dia_absoluto(+Fecha, -N:integer) is det.
%
%   N es la cantidad de días desde el 1 de enero de 1970 hasta Fecha.
dia_absoluto(date(Anio, Mes, Dia), N) :-
    date_time_stamp(date(Anio, Mes, Dia, 0, 0, 0, 0, -, -), Segundos),
    N is round(Segundos / 86400).

%!  dias_entre(+Desde, +Hasta, -Dias:integer) is det.
%
%   Dias es la cantidad de días de Desde a Hasta: negativa si Hasta es
%   anterior.
dias_entre(Desde, Hasta, Dias) :-
    dia_absoluto(Desde, N1),
    dia_absoluto(Hasta, N2),
    Dias is N2 - N1.

%!  sumar_dias(+Fecha, +Dias:integer, -Resultado) is det.
%
%   Resultado es la fecha Dias días después de Fecha, o antes si Dias es
%   negativo. date_time_stamp/2 acepta un día fuera del mes, como el 61 de
%   enero, y lo convierte en la fecha que corresponde.
sumar_dias(date(Anio, Mes, Dia), Dias, date(A, M, D)) :-
    Dia1 is Dia + Dias,
    date_time_stamp(date(Anio, Mes, Dia1, 0, 0, 0, 0, -, -), Segundos),
    stamp_date_time(Segundos, date(A, M, D, _, _, _, _, _, _), 'UTC').

%!  dia_de_la_semana(+Fecha, -Nombre:atom) is det.
%
%   Nombre es el día de la semana de Fecha, en castellano.
dia_de_la_semana(Fecha, Nombre) :-
    day_of_the_week(Fecha, N),
    nth1(N, [lunes, martes, miércoles, jueves, viernes, sábado, domingo],
         Nombre).

%!  nombre_del_mes(+Mes:integer, -Nombre:atom) is det.
%
%   Nombre es el nombre del mes número Mes, en castellano.
nombre_del_mes(Mes, Nombre) :-
    nth1(Mes, [enero, febrero, marzo, abril, mayo, junio, julio, agosto,
               septiembre, octubre, noviembre, diciembre],
         Nombre).

%!  fecha_texto(+Fecha, -Texto:string) is det.
%
%   Texto es Fecha escrita en castellano: "viernes 25 de septiembre de
%   2026".
fecha_texto(date(Anio, Mes, Dia), Texto) :-
    dia_de_la_semana(date(Anio, Mes, Dia), NombreDelDia),
    nombre_del_mes(Mes, NombreDelMes),
    format(string(Texto), "~w ~d de ~w de ~d",
           [NombreDelDia, Dia, NombreDelMes, Anio]).

%!  fecha_iso(?Fecha, ?Texto:string) is det.
%
%   Texto es Fecha en el formato de ISO 8601, "2026-09-25". Con Texto dado,
%   lo lee y da la Fecha: nonvar/1, que el capítulo 32 presenta, elige el
%   sentido.
fecha_iso(date(Anio, Mes, Dia), Texto) :-
    (   nonvar(Texto)
    ->  parse_time(Texto, iso_8601, Segundos),
        stamp_date_time(Segundos, date(Anio, Mes, Dia, _, _, _, _, _, _),
                        'UTC')
    ;   format_time(string(Texto), '%F', date(Anio, Mes, Dia))
    ).
