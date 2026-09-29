% Run the plunit tests of one example under swipl-win, where XPCE is loaded.
%
%     swipl-win tools/run-windows.pl -- EXAMPLE.pl EXAMPLE.plt OUTPUT.txt
%
% swipl-win has no standard output that a shell can read, so the test report
% goes to OUTPUT.txt: the file becomes user_output and user_error before the
% example is loaded. The paths must be absolute, because swipl-win does not
% keep the working directory it was started from. The last line of OUTPUT.txt
% is "RESULT ok" or "RESULT fail". tools/run-windows.py calls this for every
% example that loads library(pce).

:- initialization(main, main).

main :-
    catch(run, _, true),
    halt.

run :-
    current_prolog_flag(argv, Argv),
    append(_, [Source, Tests, Output], Argv),
    open(Output, write, Out, [encoding(utf8)]),
    set_stream(Out, alias(user_error)),
    set_stream(Out, alias(user_output)),
    (   catch(( consult([Source, Tests]), run_tests ), Error,
              ( print_message(error, Error), fail ))
    ->  format(Out, "RESULT ok~n", [])
    ;   format(Out, "RESULT fail~n", [])
    ),
    close(Out).
