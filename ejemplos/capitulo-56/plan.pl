:- encoding(utf8).

% Capítulo 56 - Versión 3: del significado al plan.
%
% planificar/3 recibe el significado de una orden y un modelo de la
% carpeta de trabajo, y devuelve el plan: la lista de acciones que la
% cumplen, o un rechazo con su motivo. El modelo es una lista de términos
%
%   carpeta(Ruta)                  archivo(Ruta, Bytes, Fecha)
%
% con rutas relativas a la carpeta de trabajo, separadas por /. El
% planificador no toca el disco: es puro, y corre igual sobre un modelo
% escrito a mano que sobre el que la versión 4 lee de una carpeta real.
% Las acciones son copiar(De, A), mover(De, A), borrar(Ruta),
% ejecutar(Ruta), informar(Hecho) y salir.
%
%?- planificar_ejemplo(copiar(archivo("notas.txt"), a("informes")), Plan).
%?- planificar_ejemplo(borrar(archivo("../secreto.txt")), Plan).
%?- planificar_ejemplo(buscar(patron("notas.txt")), Plan).

% Otros archivos pueden agregar planes y maneras de seleccionar archivos.
:- multifile plan/3, seleccion/3.

%!  modelo_ejemplo(-Modelo:list) is det.
%
%   Modelo es una carpeta de trabajo con dos subcarpetas y seis archivos.
modelo_ejemplo([ carpeta("informes"),
                 carpeta("respaldo"),
                 archivo("borrador.tmp", 40, "2026-08-30"),
                 archivo("hola.pl", 96, "2026-09-01"),
                 archivo("informes/acta.txt", 300, "2026-09-10"),
                 archivo("informes/notas.txt", 120, "2026-09-12"),
                 archivo("informes/resumen.pdf", 2048, "2026-09-15"),
                 archivo("notas.txt", 80, "2026-09-20")
               ]).

%!  planificar_ejemplo(+Orden, -Plan:list) is det.
%
%   Plan cumple Orden sobre el modelo de ejemplo.
planificar_ejemplo(Orden, Plan) :-
    modelo_ejemplo(M),
    planificar(Orden, M, Plan).

%!  planificar(+Orden, +Modelo:list, -Plan:list) is det.
%
%   Plan es la lista de acciones que cumplen Orden sobre Modelo, o
%   [rechazo(Motivo)] si la orden no se puede cumplir. Una orden que nombra
%   una ruta fuera de la carpeta de trabajo se rechaza antes de examinar
%   el modelo.
planificar(Orden, Modelo, Plan) :-
    (   sub_term(R, Orden),
        string(R),
        \+ ruta_segura(R)
    ->  Plan = [rechazo(fuera_de_la_carpeta(R))]
    ;   catch(plan(Orden, Modelo, Plan), rechazo(Motivo),
              Plan = [rechazo(Motivo)])
    ).

%!  ruta_segura(+R:string) is semidet.
%
%   R es una ruta relativa que no sale de la carpeta de trabajo: no empieza
%   con /, no nombra una unidad, no usa \ y no tiene el componente «..».
ruta_segura(R) :-
    \+ string_concat("/", _, R),
    \+ sub_string(R, _, _, _, ":"),
    \+ sub_string(R, _, _, _, "\\"),
    split_string(R, "/", "", Partes),
    \+ memberchk("..", Partes).

%!  plan(+Orden, +Modelo:list, -Plan:list) is det.
%
%   Plan cumple Orden sobre Modelo.
%
%   @throws rechazo(Motivo) si la orden no se puede cumplir.
plan(salir, _, [salir]).
plan(listar(C, F), M, [informar(lista(C, Nombres))]) :-
    carpeta_existente(C, M),
    findall(N, elemento(C, F, M, N), Ns),
    msort(Ns, Nombres).
plan(contar(C, F), M, [informar(cantidad(C, F, N))]) :-
    carpeta_existente(C, M),
    archivos_en(C, F, M, Rs),
    length(Rs, N).
plan(copiar(O, a(D)), M, Plan) :-
    trasladar(copiar, O, D, M, Plan).
plan(mover(O, a(D)), M, Plan) :-
    trasladar(mover, O, D, M, Plan).
plan(borrar(O), M, Plan) :-
    seleccion(O, M, Rs),
    findall(borrar(R), member(R, Rs), Plan).
plan(tamano(O), M, [informar(tamano(Rs, Total))]) :-
    seleccion(O, M, Rs),
    findall(B, ( member(R, Rs), memberchk(archivo(R, B, _), M) ), Bs),
    sum_list(Bs, Total).
plan(fecha(O), M, Plan) :-
    seleccion(O, M, Rs),
    findall(informar(fecha(R, F)),
            ( member(R, Rs), memberchk(archivo(R, _, F), M) ),
            Plan).
plan(buscar(patron(P)), M, [informar(encontrados(P, Rs))]) :-
    findall(R, ( member(archivo(R, _, _), M),
                 base(R, N),
                 pasa(patron(P), N) ),
            Rs0),
    msort(Rs0, Rs).
plan(ejecutar(archivo(R)), M, [ejecutar(R)]) :-
    seleccion(archivo(R), M, _),
    (   string_concat(_, ".pl", R)
    ->  true
    ;   throw(rechazo(no_ejecutable(R)))
    ).

%!  seleccion(+Objeto, +Modelo:list, -Rutas:list(string)) is det.
%
%   Rutas son los archivos de Modelo que Objeto nombra.
%
%   @throws rechazo(no_existe(R)) si el archivo o la carpeta R no existe.
%   @throws rechazo(ninguno(C, F)) si ningún archivo de C pasa el filtro F.
seleccion(archivo(R), M, [R]) :-
    (   memberchk(archivo(R, _, _), M)
    ->  true
    ;   throw(rechazo(no_existe(R)))
    ).
seleccion(archivos(C, F), M, Rs) :-
    carpeta_existente(C, M),
    archivos_en(C, F, M, Rs),
    (   Rs == []
    ->  throw(rechazo(ninguno(C, F)))
    ;   true
    ).

%!  trasladar(+Op, +Objeto, +D:string, +Modelo:list, -Plan:list) is det.
%
%   Plan copia o mueve (según Op) los archivos de Objeto a D. Si D es una
%   carpeta, cada archivo conserva su nombre; si no, D es el nombre nuevo
%   de un único archivo. Ningún archivo existente se sobrescribe.
trasladar(Op, O, D, M, Plan) :-
    seleccion(O, M, Rs),
    maplist(destino(O, D, M), Rs, Ds),
    maplist(accion(Op), Rs, Ds, Plan).

%!  destino(+Objeto, +D:string, +Modelo:list, +R:string, -Nuevo:string)
%!      is det.
%
%   Nuevo es la ruta que toma el archivo R al llevarlo a D.
%
%   @throws rechazo(no_es_carpeta(D)) si son varios archivos y D no es
%           una carpeta.
%   @throws rechazo(ya_existe(Nuevo)) si Nuevo ya es un archivo.
destino(O, D, M, R, Nuevo) :-
    (   es_carpeta(D, M)
    ->  base(R, N),
        dentro(D, N, Nuevo)
    ;   O = archivo(_)
    ->  carpeta_de(D, Padre),
        carpeta_existente(Padre, M),
        Nuevo = D
    ;   throw(rechazo(no_es_carpeta(D)))
    ),
    (   memberchk(archivo(Nuevo, _, _), M)
    ->  throw(rechazo(ya_existe(Nuevo)))
    ;   true
    ).

%!  accion(+Op, +R:string, +D:string, -Accion) is det.
%
%   Accion es Op(R, D): copiar(R, D) o mover(R, D).
accion(Op, R, D, Accion) :-
    Accion =.. [Op, R, D].

%!  carpeta_existente(+C:string, +Modelo:list) is det.
%
%   @throws rechazo(no_existe(C)) si C no es una carpeta de Modelo.
carpeta_existente(C, M) :-
    (   es_carpeta(C, M)
    ->  true
    ;   throw(rechazo(no_existe(C)))
    ).

%!  es_carpeta(+C:string, +Modelo:list) is semidet.
%
%   C es la carpeta de trabajo o una carpeta de Modelo.
es_carpeta(C, M) :-
    (   C == "."
    ->  true
    ;   memberchk(carpeta(C), M)
    ).

%!  archivos_en(+C:string, +F, +Modelo:list, -Rs:list(string)) is det.
%
%   Rs son las rutas de los archivos que están directamente en la carpeta
%   C y cuyo nombre pasa el filtro F.
archivos_en(C, F, M, Rs) :-
    findall(R, ( member(archivo(R, _, _), M),
                 en_carpeta(R, C, N),
                 pasa(F, N) ),
            Rs).

%!  elemento(+C:string, +F, +Modelo:list, -N:string) is nondet.
%
%   N es el nombre de un archivo de C que pasa el filtro F, o, sin
%   filtro, el de una subcarpeta de C seguido de /.
elemento(C, F, M, N) :-
    member(archivo(R, _, _), M),
    en_carpeta(R, C, N),
    pasa(F, N).
elemento(C, todos, M, N) :-
    member(carpeta(R), M),
    en_carpeta(R, C, N0),
    string_concat(N0, "/", N).

%!  en_carpeta(+R:string, +C:string, -N:string) is semidet.
%
%   La ruta R está directamente en la carpeta C, con el nombre N.
en_carpeta(R, C, N) :-
    carpeta_de(R, C),
    base(R, N).

%!  carpeta_de(+R:string, -C:string) is det.
%
%   C es la carpeta que contiene la ruta R: "." si R no tiene /.
carpeta_de(R, C) :-
    split_string(R, "/", "", Partes),
    reverse(Partes, [_|Inversas]),
    reverse(Inversas, Iniciales),
    (   Iniciales == []
    ->  C = "."
    ;   atomic_list_concat(Iniciales, '/', A),
        atom_string(A, C)
    ).

%!  base(+R:string, -N:string) is det.
%
%   N es el último componente de la ruta R.
base(R, N) :-
    split_string(R, "/", "", Partes),
    last(Partes, N).

%!  dentro(+C:string, +N:string, -R:string) is det.
%
%   R es la ruta del nombre N dentro de la carpeta C.
dentro(C, N, R) :-
    (   C == "."
    ->  R = N
    ;   atomics_to_string([C, "/", N], R)
    ).

%!  pasa(+F, +N:string) is semidet.
%
%   El nombre N pasa el filtro F: todos, o patron(P) con * en lugar de
%   cualquier secuencia de caracteres.
pasa(todos, _).
pasa(patron(P), N) :-
    string_chars(P, Ps),
    string_chars(N, Ns),
    once(comodin(Ps, Ns)).

%!  comodin(+Patron:list(char), +Nombre:list(char)) is nondet.
%
%   Nombre sigue Patron: cada * cubre cero o más caracteres, y cada otro
%   carácter se cubre a sí mismo.
comodin([], []).
comodin(['*'|Ps], Ns) :-
    append(_, Resto, Ns),
    comodin(Ps, Resto).
comodin([C|Ps], [C|Ns]) :-
    C \== '*',
    comodin(Ps, Ns).
