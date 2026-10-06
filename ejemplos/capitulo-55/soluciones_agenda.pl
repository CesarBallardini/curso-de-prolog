:- encoding(utf8).

% Capítulo 55 - Soluciones de los ejercicios 6, 7 y 8: cancelar citas,
% preguntar cuándo es una actividad, y guardar y cargar la agenda.
%
% atender_con_cancelar/4 prueba primero las dos frases nuevas y después
% atender/4 de la versión 4. Los no terminales de la agenda se usan con el
% nombre del módulo delante: agenda:nombre(N) es nombre//1 del módulo
% agenda.
%
% solo-local: carga archivos de este capítulo y de otros, y SWISH no admite
% módulos propios.
%
%?- atender_con_cancelar("Cancela la reunión del martes", [], A, R).

:- module(soluciones_agenda,
          [ atender_con_cancelar/4,
            guardar_agenda/2,
            cargar_agenda/2
          ]).

:- use_module(agenda).
:- use_module('../capitulo-44/lenguaje', [palabras/2]).

%!  nueva(?Frase)// is nondet.
%
%   Las dos frases nuevas: cancelar(Actividad, Dia) y cuando_es(Actividad).
nueva(cancelar(A, D)) -->
    [V],
    { memberchk(V, [cancela, borra]) },
    agenda:nombre(A),
    (   [del]
    ->  agenda:fecha_o_dia(D)
    ;   agenda:dia(D)
    ).
nueva(cuando_es(A)) -->
    [cuando, tengo],
    agenda:nombre(A).

%!  atender_con_cancelar(+Frase:string, +Agenda0:list, -Agenda:list,
%!                       -Respuesta:string) is semidet.
%
%   Como atender/4, con dos frases más: cancelar las citas de una actividad
%   en un día, y preguntar cuándo es una actividad.
atender_con_cancelar(Frase, Agenda0, Agenda, Respuesta) :-
    palabras(Frase, Palabras),
    (   once(phrase(nueva(Acto), Palabras))
    ->  nuevo_efecto(Acto, Agenda0, Agenda, Resultado),
        phrase(oracion(Resultado), Codigos),
        string_codes(Respuesta, Codigos)
    ;   atender(Frase, Agenda0, Agenda, Respuesta)
    ).

%!  de_actividad(+P:atom, +Cita) is semidet.
%
%   La actividad de Cita, sin tildes, es la palabra P.
de_actividad(P, cita(_, _, nombre(_, Texto), _, _)) :-
    palabras(Texto, [P]).

%!  nuevo_efecto(+Acto, +Agenda0:list, -Agenda:list, -Resultado) is det.
%
%   Resultado es el término de la respuesta a Acto, y Agenda la agenda que
%   queda.
nuevo_efecto(cancelar(nombre(_, P), D), Agenda0, Agenda,
             canceladas(D, Canceladas)) :-
    partition([C]>>( C = cita(D, _, _, _, _), de_actividad(P, C) ),
              Agenda0, Canceladas, Agenda).
nuevo_efecto(cuando_es(nombre(_, P)), Agenda, Agenda, cuando_es(Citas)) :-
    include(de_actividad(P), Agenda, Citas).

%!  oracion(+Resultado)// is det.
%
%   El texto de la respuesta a una frase nueva.
oracion(canceladas(D, [])) -->
    "No tienes nada de eso anotado ",
    agenda:el_dia(D),
    ".".
oracion(canceladas(_, [C|Cs])) -->
    "Cancelado: ",
    citas([C|Cs]),
    ".".
oracion(cuando_es([])) -->
    "No tienes nada de eso anotado.".
oracion(cuando_es([C|Cs])) -->
    "Tienes ",
    citas([C|Cs]),
    ".".

%!  citas(+Citas:list)// is det.
%
%   Cada cita con su actividad, su día y su hora, separadas por punto y
%   coma.
citas([cita(D, H, A, Con, Lugar)|Cs]) -->
    agenda:que(A, Con, Lugar),
    " ",
    agenda:el_dia(D),
    " ",
    agenda:a_la_hora(H),
    (   { Cs == [] }
    ->  []
    ;   "; ",
        citas(Cs)
    ).

%!  guardar_agenda(+Archivo, +Agenda:list) is det.
%
%   Escribe las citas de Agenda en Archivo, una por línea, como hechos.
guardar_agenda(Archivo, Agenda) :-
    setup_call_cleanup(
        open(Archivo, write, Out, [encoding(utf8)]),
        forall(member(C, Agenda), portray_clause(Out, C)),
        close(Out)).

%!  cargar_agenda(+Archivo, -Agenda:list) is det.
%
%   Agenda son las citas de Archivo, leídas sin ejecutarlas. Produce un
%   error de dominio si un término no es una cita.
cargar_agenda(Archivo, Agenda) :-
    setup_call_cleanup(
        open(Archivo, read, In, [encoding(utf8)]),
        leer_citas(In, Agenda),
        close(In)).

%!  leer_citas(+In, -Citas:list) is det.
%
%   Citas son los términos que quedan por leer en In, validados.
leer_citas(In, Citas) :-
    read_term(In, T, []),
    (   T == end_of_file
    ->  Citas = []
    ;   (   es_cita(T)
        ->  Citas = [T|Cs],
            leer_citas(In, Cs)
        ;   domain_error(cita, T)
        )
    ).

%!  es_cita(@T) is semidet.
%
%   T es una cita bien formada, sin variables.
es_cita(cita(D, hora(H, M), A, Con, Lugar)) :-
    ground(cita(D, hora(H, M), A, Con, Lugar)),
    ( D = dia(_) ; D = fecha(_, _) ),
    integer(H),
    integer(M),
    A = nombre(_, _),
    ( Con == nadie ; Con = nombre(_, _) ),
    ( Lugar == ninguno ; Lugar = nombre(_, _) ),
    !.
