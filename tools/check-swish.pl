:- encoding(utf8).

% Asks exactly what SWISH asks before running a query: whether the goal, and
% everything that goal calls, is allowed by the sandbox.
%
% Driven by tools/check-swish.py, one process per example:
%
%     swipl -g "check('ejemplos/capitulo-01/familia.pl', [\"abuelo(juan, X)\"])" \
%           -t halt tools/check-swish.pl

:- use_module(library(sandbox)).
:- use_module(library(pengines_io), [pengine_io_goal_expansion/2]).

check(File, Queries) :-
    consult(File),
    findall(Query-Reason,
            ( member(Query, Queries), rejected(Query, Reason) ),
            Rejected),
    forall(member(Query-Reason, Rejected),
           format("  ~w~n      ~p~n", [Query, Reason])),
    Rejected == [].

% A query is rejected when safe_goal/1 throws (the usual case: the sandbox names
% the forbidden predicate) or when it fails without saying anything.
rejected(Query, Reason) :-
    term_string(Goal, Query),
    (   catch(safe_goal(Goal), Error, true)
    ->  nonvar(Error),
        Reason = Error
    ;   Reason = 'safe_goal/1 failed'
    ).

% SWISH does not run the program against the plain built-ins. It loads
% library(pengines_io), which replaces write/1, nl/0, tab/1, read/1, listing/1
% and friends with pengine_write/1, pengine_nl/0 and so on, so their output
% reaches the answer pane instead of a stream, and declares those replacements
% sandbox-safe.
%
% Here there is no pengine, so write/1 resolves to system:write/1, which the
% sandbox rightly refuses: it writes to a stream. Without the declarations
% below, every example that prints anything would be reported as impossible in
% SWISH, which is the opposite of the truth.
%
% So the predicates SWISH swaps out are declared safe. The list is spelled out
% one by one because library(sandbox) verifies each declaration at load time and
% refuses a rule with a variable head. It is the list of pengine_io_predicate/1
% in library/ext/pengines/pengines_io.pl, and `mismatch/1` below fails the load
% if the two ever drift apart.
%
% format/1,2 are in that list but need no declaration: library(sandbox) already
% allows them through safe_meta/2, which parses the format string and checks
% whatever it would call. Declaring them safe outright would be weaker than what
% Loaded so the declarations below can name the module each predicate really
% lives in: library(sandbox) refuses to declare a predicate it cannot see.
:- use_module(library(listing)).
:- use_module(library(readutil)).

sandbox:safe_primitive(system:write(_)).
sandbox:safe_primitive(system:writeln(_)).
sandbox:safe_primitive(system:writeq(_)).
sandbox:safe_primitive(system:write_canonical(_)).
sandbox:safe_primitive(system:write_term(_, _)).
sandbox:safe_primitive(system:print(_)).
sandbox:safe_primitive(system:nl).
sandbox:safe_primitive(system:tab(_)).
sandbox:safe_primitive(system:flush_output).
sandbox:safe_primitive(system:read(_)).
sandbox:safe_primitive(prolog_listing:listing).
sandbox:safe_primitive(read_util:read_line_to_string(_, _)).
sandbox:safe_primitive(read_util:read_line_to_codes(_, _)).

% The tracer. These are not declared by any library shipped with SWI-Prolog:
% they come from SWISH's own lib/trace.pl, which lives in the SWISH sources
% (https://github.com/SWI-Prolog/swish), so nothing installed locally can tell
% us they are allowed.
%
% Verified against the real service on 2026-09-20 by asking its pengines API to
% run `trace, abuelo(juan, X)` over a three-clause program: it answered
% "event":"success" with X = luis. The same request with shell/1 came back
% "permission_error", which is what makes that a meaningful test rather than an
% endpoint that runs anything.
%
% This matters for chapter 1, whose section on watching Prolog search is built
% on trace/0.
sandbox:safe_primitive(system:trace).
sandbox:safe_primitive(system:notrace).
sandbox:safe_primitive(system:tracing).
sandbox:safe_primitive(system:deterministic(_)).

% listing/1 and portray_clause/1 are meta-predicates, and safe_primitive/1
% refuses those by design. safe_meta/2 is the hook for them: it states which
% goals the meta-predicate will call, and these two call none.
sandbox:safe_meta(prolog_listing:listing(_), []).
sandbox:safe_meta(prolog_listing:portray_clause(_), []).

% Three of the predicates SWISH substitutes are left undeclared on purpose.
deliberately_undeclared(format(_),
    'library(sandbox) already allows it through safe_meta/2, which parses the format string').
deliberately_undeclared(format(_, _),
    'library(sandbox) already allows it through safe_meta/2, which parses the format string').
deliberately_undeclared(display(_),
    'an obsolete Edinburgh predicate; this book never uses it, so it stays out').

undeclared_substitution(Goal) :-
    pengine_io_goal_expansion(Goal, _),
    \+ deliberately_undeclared(Goal, _),
    \+ catch(sandbox:safe_primitive(_:Goal), _, fail),
    \+ catch(sandbox:safe_meta(_:Goal, _), _, fail).

% Warns at load time if SWISH substitutes a predicate this file neither declares
% nor deliberately leaves out, so a new SWI-Prolog release cannot quietly widen
% Stops the load if SWISH substitutes a predicate this file neither declares nor
% deliberately leaves out, so a new SWI-Prolog release cannot quietly widen the
% gap between what SWISH runs and what this checker allows. A checker that has
% fallen out of step must not report success. It goes last: a directive runs
% while the file loads, so the clauses it calls have to be in already.
:- (   findall(Goal, undeclared_substitution(Goal), Goals),
       Goals \== []
   ->  forall(member(Goal, Goals),
              format(user_error,
                     "ERROR: check-swish.pl neither declares nor excludes ~q, which SWISH replaces~n",
                     [Goal])),
       halt(1)
   ;   true
   ).
