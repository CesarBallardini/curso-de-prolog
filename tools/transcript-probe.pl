:- encoding(utf8).

% Report what SWI-Prolog really answers to one query, in a form a script can
% read. Used by tools/check-transcripts.py to compare the book's transcripts
% against the interpreter.
%
% For each query the probe reports:
%
%   COUNT <n>   how many answers the query has
%   DET <bool>  whether the *last* answer left no choice point, which is what
%               decides whether the toplevel prints "answer." or "answer ;"
%               and waits for the reader
%   ERROR <t>   the formal part of the exception, when the query raises one
%
% deterministic/1 cannot be used here: the failure-driven loop that enumerates
% the answers is itself a choice point, so it would report false every time.
% call_cleanup/2 is the way in. Its cleanup runs at the moment the goal exits
% with nothing left to try, so a solution that finds the flag already fired is
% a solution after which the toplevel would print a full stop.

probe(Goal) :-
    State = state(0, pending, false),
    (   catch(sample(Goal, State), Error, report_error(Error))
    ->  true
    ;   true
    ),
    report(State).

sample(Goal, State) :-
    (   call_cleanup(Goal, nb_setarg(2, State, fired)),
        note(State),
        fail
    ;   true
    ).

note(State) :-
    arg(1, State, Before),
    Count is Before + 1,
    nb_setarg(1, State, Count),
    arg(2, State, Flag),
    (   Flag == fired
    ->  nb_setarg(3, State, true)
    ;   nb_setarg(3, State, false)
    ).

report(state(Count, _, Det)) :-
    (   Count =:= 0
    ->  format("COUNT 0~nDET true~n")
    ;   format("COUNT ~w~nDET ~w~n", [Count, Det])
    ).

report_error(Error) :-
    (   Error = error(Formal, _)
    ->  format("ERROR ~q~n", [Formal])
    ;   format("ERROR ~q~n", [Error])
    ).
