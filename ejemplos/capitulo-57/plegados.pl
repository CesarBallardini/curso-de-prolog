:- encoding(utf8).

% Capítulo 57 - Dos plegados más, escritos en Lam.
%
% plegar1_der es el fold de Clocksin: pliega desde la derecha una lista no
% vacía, sin valor inicial; el acumulador empieza con el último elemento.
% plegar2_der pliega dos listas a la vez, como el fold2r de su ejercicio
% 2, y con él se escribe el producto interno de dos vectores.
%
% solo-local: carga funcional.pl, y SWISH no carga otros archivos.
%
%?- lam_plegados("maximo [3, 1, 4, 1, 5, 9, 2, 6]", V).
%?- lam_plegados("producto_interno [1, 2, 3] [4, 5, 6]", V).

:- ensure_loaded(funcional).

% plegados(Texto): las definiciones nuevas, en el lenguaje objeto.
plegados("plegar1_der f l = si vacia (cola l) entonces cabeza l \c
            sino f (cabeza l) (plegar1_der f (cola l)); \c
          mayor a b = si a > b entonces a sino b; \c
          maximo = plegar1_der mayor; \c
          plegar2_der f a xs ys = si vacia xs entonces a \c
            sino f (cabeza xs) (cabeza ys) \c
            (plegar2_der f a (cola xs) (cola ys)); \c
          producto_interno = plegar2_der (fun x y a -> x * y + a) 0").

%!  lam_plegados(+Texto:string, -Valor) is det.
%
%   Valor es el valor por necesidad de la expresión de Texto, con el
%   preludio y las definiciones de plegados/1.
lam_plegados(Texto, V) :-
    plegados(D),
    lam(Texto, D, V).
