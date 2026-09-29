:- encoding(utf8).

% Capítulo 56 - Versión 1: órdenes reconocidas con plantillas.
%
% Un sistema de plantillas en dos etapas. Las reglas de simplificación
% reescriben la lista de palabras: quitan las que no aportan («por favor»,
% los artículos) y unifican los sinónimos («muestra» pasa a «lista»). Las
% plantillas relacionan la lista simplificada entera con el significado de
% la orden. Las palabras son strings en minúsculas y sin tildes.
%
%?- traducir("Muéstrame los archivos de la carpeta informes, por favor.", O).
%?- palabras("¿Cuánto ocupa notas.txt?", Ps).
%?- traducir("Borra los archivos .tmp", O).

%!  palabras(+Texto:string, -Palabras:list(string)) is det.
%
%   Palabras son las palabras de Texto en minúsculas y sin tildes, sin los
%   signos de pregunta y de exclamación, sin las comas y sin el punto
%   final. Un punto dentro de una palabra se conserva: «notas.txt».
palabras(Texto, Palabras) :-
    string_lower(Texto, Minusculas),
    string_chars(Minusculas, Cs0),
    maplist(sin_tilde, Cs0, Cs),
    string_chars(Limpio, Cs),
    split_string(Limpio, " ", " ¿?¡!,;", Partes0),
    exclude(==(""), Partes0, Partes),
    ultima_sin_punto(Partes, Palabras).

%!  ultima_sin_punto(+Ps0:list(string), -Ps:list(string)) is det.
%
%   Ps es Ps0 sin el punto con que termina su última palabra, que es el
%   punto final de la oración; una palabra que era solo ese punto
%   desaparece.
ultima_sin_punto(Ps0, Ps) :-
    (   append(Iniciales, [Ultima0], Ps0)
    ->  sin_punto_final(Ultima0, Ultima),
        append(Iniciales, [Ultima], Ps1),
        exclude(==(""), Ps1, Ps)
    ;   Ps = Ps0
    ).

%!  sin_tilde(+C0:char, -C:char) is det.
%
%   C es C0 sin tilde ni diéresis; la eñe pasa a ene.
sin_tilde(C0, C) :-
    (   sub_atom('áéíóúüñ', I, 1, _, C0)
    ->  sub_atom(aeiouun, I, 1, _, C)
    ;   C = C0
    ).

%!  sin_punto_final(+P0:string, -P:string) is det.
%
%   P es P0 sin el punto con que termina, si termina con uno.
sin_punto_final(P0, P) :-
    (   string_concat(P, ".", P0)
    ->  true
    ;   P = P0
    ).

% simplifica(Antes, Despues): la secuencia de palabras Antes se reescribe
% como Despues. Se prueban en este orden: la primera que aplica gana.
simplifica(["por", "favor"], []).
simplifica(["muestrame"], ["lista"]).
simplifica(["muestra"], ["lista"]).
simplifica(["elimina"], ["borra"]).
simplifica(["quita"], ["borra"]).
simplifica(["que", "archivos", "hay"], ["lista"]).
simplifica(["todos"], []).
simplifica(["el"], []).
simplifica(["la"], []).
simplifica(["los"], []).
simplifica(["las"], []).
simplifica(["archivos"], []).
simplifica(["archivo"], []).
simplifica(["carpeta"], []).
simplifica(["en"], ["de"]).

%!  simplificar(+Palabras:list(string), -Simples:list(string)) is det.
%
%   Simples es Palabras después de aplicar las reglas de simplificación en
%   cada posición, de izquierda a derecha. Lo que una regla produce vuelve
%   a simplificarse.
simplificar([], []).
simplificar([P|Ps], Simples) :-
    (   simplifica(Antes, Despues),
        append(Antes, Resto, [P|Ps])
    ->  append(Despues, Resto, Otra),
        simplificar(Otra, Simples)
    ;   Simples = [P|Ss],
        simplificar(Ps, Ss)
    ).

% plantilla(Palabras, Orden): la lista simplificada Palabras significa
% Orden. Las variables ocupan el lugar de una sola palabra.
plantilla(["salir"], salir).
plantilla(["lista"], listar(".", todos)).
plantilla(["lista", "de", C], listar(C, todos)).
plantilla(["cuantos", "hay", "de", C], contar(C, todos)).
plantilla(["copia", A, "a", D], copiar(archivo(A), a(D))).
plantilla(["mueve", A, "a", D], mover(archivo(A), a(D))).
plantilla(["borra", A], borrar(archivo(A))).
plantilla(["cuanto", "ocupa", A], tamano(archivo(A))).
plantilla(["busca", A], buscar(patron(A))).

%!  traducir(+Texto:string, -Orden) is semidet.
%
%   Orden es el significado de Texto según la primera plantilla que
%   coincide con sus palabras simplificadas. Falla si ninguna coincide.
traducir(Texto, Orden) :-
    palabras(Texto, Palabras),
    simplificar(Palabras, Simples),
    once(plantilla(Simples, Orden)).
