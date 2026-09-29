:- encoding(utf8).

% Capítulo 55 - Versión 4 de los diálogos: una agenda en castellano.
%
% acto//1 es una gramática sobre las palabras de una frase, sin mayúsculas
% ni tildes. Reconoce una cita para anotar («tengo una reunión con Pérez
% el martes a las 10 en la oficina», con los complementos en cualquier
% orden) y tres preguntas: qué hay un día, dónde hay que estar un día a una
% hora y cuándo se ve a alguien. atender/4 aplica el acto a una agenda, que
% es una lista de citas pasada en argumentos, y redacta la respuesta con
% otra gramática. Las fechas con número se validan con fecha_valida/3 del
% capítulo 21, y los nombres recuperan sus tildes con escritura/3 de la
% versión 2.
%
% solo-local: carga archivos de otros capítulos, y SWISH no admite módulos
% propios.
%
%?- atender("Tengo una reunión con Pérez el martes a las 10", [], A, R).

:- module(agenda,
          [ acto//1,
            atender/4
          ]).

:- use_module(persona, [escritura/3]).
:- use_module('../capitulo-44/lenguaje', [palabras/2]).
:- load_files(fechas21:'../capitulo-21/fechas', []).

% anio_agenda(A): las fechas con número son del año A.
anio_agenda(2026).

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

%!  estar// is nondet.
%
%   Las formas de preguntar dónde hay que estar.
estar -->
    [estoy].
estar -->
    [tengo, que, estar].

%!  ver// is nondet.
%
%   Las formas de preguntar cuándo se ve a alguien.
ver -->
    [veo, a].
ver -->
    [tengo, que, ver, a].
ver -->
    [me, reuno, con].

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

%!  nombre(?N)// is nondet.
%
%   Una palabra que no es una palabra de la gramática, con o sin artículo
%   delante: N es nombre(Articulo, Palabra), y Articulo es ninguno si no
%   lo hay.
nombre(nombre(A, P)) -->
    articulo(A),
    [P],
    { \+ reservada(P) }.

%!  articulo(?A)// is nondet.
%
%   Un artículo, o ninguno.
articulo(A) -->
    [A],
    { memberchk(A, [un, una, el, la]) }.
articulo(ninguno) -->
    [].

% reservada(P): P es una palabra de la gramática, no un nombre.
reservada(P) :-
    memberchk(P, [con, en, el, la, un, una, a, las, de, y]).

%!  dia(?D)// is semidet.
%
%   Un día: el nombre de un día de la semana, dia(Nombre), o una fecha del
%   año de la agenda, fecha(Mes, Dia), con o sin el artículo el.
dia(D) -->
    [el],
    !,
    fecha_o_dia(D).
dia(D) -->
    fecha_o_dia(D).

%!  fecha_o_dia(?D)// is semidet.
%
%   Un día de la semana, o el número de un día seguido de de y el mes.
fecha_o_dia(dia(Nombre)) -->
    [Nombre],
    { dia_semana(Nombre, _) },
    !.
fecha_o_dia(fecha(Mes, Dia)) -->
    [N, de, NombreMes],
    { atom_number(N, Dia),
      nth1(Mes, [enero, febrero, marzo, abril, mayo, junio, julio,
                 agosto, septiembre, octubre, noviembre, diciembre],
           NombreMes),
      anio_agenda(Anio),
      fechas21:fecha_valida(Anio, Mes, Dia) }.

% dia_semana(D, Texto): D es un día de la semana, que se escribe Texto.
dia_semana(lunes, "lunes").
dia_semana(martes, "martes").
dia_semana(miercoles, "miércoles").
dia_semana(jueves, "jueves").
dia_semana(viernes, "viernes").
dia_semana(sabado, "sábado").
dia_semana(domingo, "domingo").

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

%!  minutos(-M:integer)// is det.
%
%   Los minutos de una hora: y media, y cuarto, un número o nada.
minutos(30) -->
    [y, media],
    !.
minutos(15) -->
    [y, cuarto],
    !.
minutos(M) -->
    [N],
    { atom_number(N, M),
      between(0, 59, M) },
    !.
minutos(0) -->
    [].

%!  momento(+H0:integer, -H:integer)// is det.
%
%   De la tarde o de la noche suman 12 a una hora anterior a las 12.
momento(H0, H) -->
    [de, la, Parte],
    { memberchk(Parte, [tarde, noche]) },
    !,
    { H0 < 12
    ->  H is H0 + 12
    ;   H = H0
    }.
momento(H, H) -->
    [de, la, manana],
    !.
momento(H, H) -->
    [].

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

%!  cita(+Actividad, +Complementos:list, +Frase:string, -Cita) is semidet.
%
%   Cita es cita(Dia, Hora, Actividad, Con, Lugar), con los nombres escritos
%   como en Frase; Con y Lugar son nadie y ninguno si no se dicen. Falla si
%   Complementos no tiene exactamente un día y una hora, o repite uno.
cita(Actividad, Cs, Frase, cita(Dia, Hora, A, Con, Lugar)) :-
    forall(member(F, [dia, hora]), veces(F, Cs, 1)),
    forall(member(F, [con, en]), ( veces(F, Cs, N), N =< 1 )),
    memberchk(dia(Dia), Cs),
    memberchk(hora(Hora), Cs),
    comun(Frase, Actividad, A),
    opcional(con, Cs, Frase, nadie, Con),
    opcional(en, Cs, Frase, ninguno, Lugar).

%!  veces(+F:atom, +Cs:list, ?N:integer) is det.
%
%   N es la cantidad de complementos de Cs de la forma F(_).
veces(F, Cs, N) :-
    aggregate_all(count, ( member(C, Cs), functor(C, F, 1) ), N).

%!  opcional(+F, +Cs:list, +Frase:string, +Omision, -N) is det.
%
%   N es el nombre del complemento F(Nombre) de Cs, escrito como en Frase,
%   u Omision si Cs no lo tiene.
opcional(F, Cs, Frase, Omision, N) :-
    C =.. [F, N0],
    (   memberchk(C, Cs)
    ->  escrito(Frase, N0, N)
    ;   N = Omision
    ).

%!  comun(+Frase:string, +N0, -N) is det.
%
%   N es el nombre común N0 con la palabra escrita como en Frase.
comun(Frase, nombre(A, P), nombre(A, Texto)) :-
    escritura(Frase, [P], [E]),
    atom_string(E, Texto).

%!  escrito(+Frase:string, +N0, -N) is det.
%
%   N es el nombre N0 con la palabra escrita como en Frase: con tildes y,
%   si no lleva artículo, con mayúscula inicial, porque es un nombre propio.
escrito(Frase, nombre(A, P), nombre(A, Texto)) :-
    escritura(Frase, [P], [E]),
    (   A == ninguno
    ->  sub_atom(E, 0, 1, _, Inicial),
        sub_atom(E, 1, _, 0, Resto),
        upcase_atom(Inicial, Mayuscula),
        atomic_list_concat([Mayuscula, Resto], Texto0)
    ;   Texto0 = E
    ),
    atom_string(Texto0, Texto).

%!  oracion(+Resultado)// is det.
%
%   El texto de la respuesta Resultado, dirigido al usuario.
oracion(anotada(cita(D, H, A, Con, Lugar))) -->
    "Anotado: ",
    el_dia(D),
    " ",
    a_la_hora(H),
    ", ",
    que(A, Con, Lugar),
    ".".
oracion(ocupado(cita(D, H, A, Con, Lugar))) -->
    "Ya tienes ",
    que(A, Con, Lugar),
    " ",
    el_dia(D),
    " ",
    a_la_hora(H),
    ".".
oracion(del_dia(D, [])) -->
    "No tienes nada anotado ",
    el_dia(D),
    ".".
oracion(del_dia(D, [C|Cs])) -->
    mayuscula(el_dia(D)),
    ": ",
    citas_del_dia([C|Cs]),
    ".".
oracion(lugar(cita(D, H, A, Con, ninguno))) -->
    mayuscula(el_dia(D)),
    " ",
    a_la_hora(H),
    " tienes ",
    que(A, Con, ninguno),
    ", sin lugar anotado.".
oracion(lugar(cita(D, H, _, _, nombre(Ar, L)))) -->
    mayuscula(el_dia(D)),
    " ",
    a_la_hora(H),
    " estás en ",
    nombrar(nombre(Ar, L)),
    ".".
oracion(libre(D, H)) -->
    mayuscula(el_dia(D)),
    " ",
    a_la_hora(H),
    " no tienes nada anotado.".
oracion(con_quien(N, [])) -->
    "No tienes nada anotado con ",
    nombrar(N),
    ".".
oracion(con_quien(N, [C|Cs])) -->
    "Ves a ",
    nombrar(N),
    " ",
    cuandos([C|Cs]),
    ".".

%!  citas_del_dia(+Citas:list)// is det.
%
%   Las citas de un día, separadas por punto y coma.
citas_del_dia([cita(_, H, A, Con, Lugar)|Cs]) -->
    a_la_hora(H),
    ", ",
    que(A, Con, Lugar),
    (   { Cs == [] }
    ->  []
    ;   "; ",
        citas_del_dia(Cs)
    ).

%!  cuandos(+Citas:list)// is det.
%
%   El día y la hora de cada cita, separados por comas y y.
cuandos([cita(D, H, _, _, _)|Cs]) -->
    el_dia(D),
    " ",
    a_la_hora(H),
    (   { Cs == [] }
    ->  []
    ;   { Cs = [_] }
    ->  " y ",
        cuandos(Cs)
    ;   ", ",
        cuandos(Cs)
    ).

%!  que(+Actividad, +Con, +Lugar)// is det.
%
%   La actividad, con quién y dónde, si se saben.
que(A, Con, Lugar) -->
    nombrar(A),
    (   { Con == nadie }
    ->  []
    ;   " con ",
        nombrar(Con)
    ),
    (   { Lugar == ninguno }
    ->  []
    ;   " en ",
        nombrar(Lugar)
    ).

%!  nombrar(+N)// is det.
%
%   El nombre N con su artículo, si lo tiene.
nombrar(nombre(A, Texto)) -->
    (   { A == ninguno }
    ->  []
    ;   atomo(A),
        " "
    ),
    atomo(Texto).

%!  el_dia(+D)// is det.
%
%   El día D con su artículo: el martes, el 3 de octubre.
el_dia(dia(Nombre)) -->
    { dia_semana(Nombre, Texto) },
    "el ",
    atomo(Texto).
el_dia(fecha(Mes, Dia)) -->
    { nth1(Mes, [enero, febrero, marzo, abril, mayo, junio, julio, agosto,
                 septiembre, octubre, noviembre, diciembre], NombreMes),
      format(codes(Cs), "el ~d de ~w", [Dia, NombreMes]) },
    Cs.

%!  a_la_hora(+H)// is det.
%
%   La hora H con dos cifras de minutos: a la 1:00, a las 10:30.
a_la_hora(hora(H, M)) -->
    { (   H =:= 1
      ->  A = "a la"
      ;   A = "a las"
      ),
      format(codes(Cs), "~w ~d:~|~`0t~d~2+", [A, H, M]) },
    Cs.

%!  mayuscula(:Cuerpo)// is det.
%
%   El texto de Cuerpo con la primera letra en mayúscula.
mayuscula(Cuerpo) -->
    { phrase(Cuerpo, [C0|Cs]),
      char_code(Minuscula, C0),
      upcase_atom(Minuscula, Mayuscula),
      char_code(Mayuscula, C) },
    [C],
    Cs.

%!  atomo(+T:text)// is det.
%
%   Los códigos del texto T.
atomo(T) -->
    { atom_codes(T, Cs) },
    Cs.
