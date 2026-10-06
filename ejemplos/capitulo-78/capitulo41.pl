:- encoding(utf8).

% Capítulo 78 - La poda alfa-beta y la profundización progresiva del
% capítulo 41, en un módulo.
%
% profundizacion.pl del capítulo 41 no es un módulo: se carga dentro del
% módulo capitulo41, sin copiarlo. Trae alfabeta/6, profundizar/6 y el
% ta-te-ti. Las búsquedas llaman a la descripción del juego, inicial/2,
% jugada/4, turno/3, fin/3, valor_final/3, evaluar/3 y completa/4, dentro de
% ese módulo; declararlas multifile antes de cargar el archivo permite que
% nim.pl y kalah.pl agreguen las cláusulas de sus juegos sin tocar el
% capítulo 41.
%
% solo-local: carga un archivo de otro capítulo, y SWISH no permite cargar
% otro archivo.
%
%?- inicial(tateti(3), P), alfabeta(tateti(3), P, 2, J, V, N).

:- module(capitulo41,
          [ alfabeta/6,
            profundizar/6,
            inicial/2,
            jugada/4,
            turno/3,
            fin/3,
            valor_final/3,
            evaluar/3
          ]).

:- multifile
    inicial/2,
    jugada/4,
    turno/3,
    fin/3,
    valor_final/3,
    evaluar/3,
    completa/4.

:- load_files(capitulo41:'../capitulo-41/profundizacion', []).
