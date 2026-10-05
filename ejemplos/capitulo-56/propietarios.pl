:- encoding(utf8).

% Capítulo 56 - Propietarios y archivos compartidos.
%
% El proyecto 16 de Clocksin y Mellish pregunta por los dueños de los
% archivos: cuántos tiene una persona, de quién es uno, si dos personas lo
% comparten. El modelo de la carpeta agrega dos clases de términos:
%
%   propietario(Ruta, Usuario)     compartido(Ruta, Usuario)
%
% y las preguntas nuevas se suman a la gramática, al planificador y a la
% redacción de las respuestas por los predicados que esos archivos
% declaran multifile, sin modificarlos.
%
% solo-local: carga el programa del capítulo con ensure_loaded/1.
%
%?- responder_modelo("¿Cuántos archivos tiene David?", R).
%?- responder_modelo("¿Comparte Chris notas.txt con David?", R).

:- ensure_loaded(ordenes).

:- multifile pedido//1, plan/3, oracion/2.

% Las preguntas nuevas.
pedido(contar_de(U)) -->
    ["cuantos"],
    sustantivo(archivo, _, pl),
    ["tiene"],
    nombre(U).
pedido(listar_de(U)) -->
    ["que"],
    sustantivo(archivo, _, pl),
    ["tiene"],
    nombre(U).
pedido(propietario(archivo(R))) -->
    ["de", "quien", "es"],
    nombre(R).
pedido(comparten(archivo(R), U1, U2)) -->
    ["comparte"],
    nombre(U1),
    nombre(R),
    ["con"],
    nombre(U2).

%!  modelo_con_usuarios(-Modelo:list) is det.
%
%   Modelo es el modelo de ejemplo con los dueños de sus archivos y los
%   permisos que comparten algunos de ellos.
modelo_con_usuarios(Modelo) :-
    modelo_ejemplo(M0),
    append(M0,
           [ propietario("borrador.tmp", "david"),
             propietario("hola.pl", "chris"),
             propietario("informes/acta.txt", "david"),
             propietario("informes/notas.txt", "david"),
             propietario("informes/resumen.pdf", "bill"),
             propietario("notas.txt", "chris"),
             compartido("notas.txt", "david"),
             compartido("informes/acta.txt", "bill")
           ],
           Modelo).

% Los planes de las preguntas nuevas. Un usuario que no aparece en el
% modelo es un rechazo; un archivo, como en las demás órdenes, debe
% existir.
plan(contar_de(U), M, [informar(cantidad_de(U, N))]) :-
    usuario(U, M),
    aggregate_all(count, member(propietario(_, U), M), N).
plan(listar_de(U), M, [informar(archivos_de(U, Rs))]) :-
    usuario(U, M),
    findall(R, member(propietario(R, U), M), Rs0),
    msort(Rs0, Rs).
plan(propietario(archivo(R)), M, [informar(duenio(R, U))]) :-
    seleccion(archivo(R), M, _),
    (   memberchk(propietario(R, U0), M)
    ->  U = U0
    ;   U = nadie
    ).
plan(comparten(archivo(R), U1, U2), M, [informar(comparten(R, U1, U2, B))]) :-
    seleccion(archivo(R), M, _),
    usuario(U1, M),
    usuario(U2, M),
    (   U1 \== U2,
        acceso(R, U1, M),
        acceso(R, U2, M)
    ->  B = si
    ;   B = no
    ).

%!  usuario(+U:string, +Modelo:list) is det.
%
%   U es el dueño de un archivo de Modelo, o alguien con quien se comparte
%   uno.
%
%   @throws rechazo(no_es_usuario(U)) si U no aparece en Modelo.
usuario(U, M) :-
    (   (   memberchk(propietario(_, U), M)
        ;   memberchk(compartido(_, U), M)
        )
    ->  true
    ;   throw(rechazo(no_es_usuario(U)))
    ).

%!  acceso(+R:string, +U:string, +Modelo:list) is semidet.
%
%   U puede usar el archivo R: es su dueño, o R se comparte con U.
acceso(R, U, M) :-
    (   memberchk(propietario(R, U), M)
    ->  true
    ;   memberchk(compartido(R, U), M)
    ).

% Las respuestas a las preguntas nuevas.
oracion(cantidad_de(U, K), T) :-
    persona(U, P),
    cantidad(K, archivo, m, Q),
    format(string(T), "~s tiene ~s.", [P, Q]).
oracion(archivos_de(U, []), T) :-
    !,
    persona(U, P),
    format(string(T), "~s no tiene archivos.", [P]).
oracion(archivos_de(U, Rs), T) :-
    persona(U, P),
    atomic_list_concat(Rs, ', ', Rutas),
    format(string(T), "~s tiene ~w.", [P, Rutas]).
oracion(duenio(R, nadie), T) :-
    !,
    format(string(T), "~s no tiene dueño registrado.", [R]).
oracion(duenio(R, U), T) :-
    persona(U, P),
    format(string(T), "~s es de ~s.", [R, P]).
oracion(comparten(R, U1, U2, B), T) :-
    persona(U1, P1),
    persona(U2, P2),
    (   B == si
    ->  format(string(T), "Sí: ~s y ~s pueden usar ~s.", [P1, P2, R])
    ;   format(string(T), "No: ~s y ~s no comparten ~s.", [P1, P2, R])
    ).
oracion(rechazo(no_es_usuario(U)), T) :-
    persona(U, P),
    format(string(T), "~s no tiene archivos ni permisos en la carpeta.",
           [P]).

%!  persona(+U:string, -P:string) is det.
%
%   P es el nombre U con mayúscula inicial.
persona(U, P) :-
    sub_string(U, 0, 1, _, Inicial),
    sub_string(U, 1, _, 0, Resto),
    string_upper(Inicial, Mayuscula),
    string_concat(Mayuscula, Resto, P).

%!  responder_modelo(+Texto:string, -Respuesta:string) is semidet.
%
%   Respuesta es la respuesta a Texto sobre el modelo con usuarios. Falla
%   si Texto no se entiende.
responder_modelo(Texto, Respuesta) :-
    entender(Texto, Orden),
    modelo_con_usuarios(M),
    planificar(Orden, M, [Accion]),
    (   Accion = informar(Hecho)
    ->  oracion(Hecho, Respuesta)
    ;   oracion(Accion, Respuesta)
    ).
