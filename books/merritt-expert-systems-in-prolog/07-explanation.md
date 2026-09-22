# Explanation

<!-- page 45 -->
It is often claimed that an important aspect of expert systems is the ability to explain their behavior. This means the user can ask the system for justification of conclusions or questions at any point in a consultation with an expert system. The system usually responds with the rules that were used for the conclusion, or the rules being considered that led to a question to the user.

## Value of Explanations to the User

The importance of this feature is probably overestimated for the user. Typically the user just wants the answer. Furthermore, when the user does want an explanation, the explanation is not always useful. This is due to the nature of the "intelligence" in an expert system.

The rules typically reflect empirical, or "compiled" knowledge. They are codifications of an expert's rules of thumb, not the expert's deeper understanding that led to the rules of thumb. For example, consider the following dialog with an expert system designed to give advice on car problems:

```prolog
Does the car start? no.
Does the engine turn over? yes.
Do you smell gas? yes.
Recommendation - Wait 5 minutes and try again.
why?
I used the rule:
If not start, and
engine_turn_over, and
smell_gas
Then recommend is 'Wait 5 minutes and try again.'.
```

The rule gives the correct advice for a flooded car, and knows the questions to ask to determine if the car is flooded, but it does not contain the knowledge of what a flooded car is and why waiting will help. If the user really wanted to understand what was happening, he/she would need a short dissertation on carburetors, how they behave, and their relationship to the gas pedal.

For a system such as this to have useful explanations, it would need to do more than parrot the rules used. One approach is to annotate the rules with deeper explanations. This is illustrated in chapter 10. Another approach being actively researched is to encode the deeper knowledge into the system and use it to drive both the inference and the explanations.

On the other hand, there are some systems in which the expert's knowledge is just empirical knowledge. In this case, the system's explanation is useful to the user. Classification systems such as the bird identification system fall in this category. The Bird system would explain an identification of a laysan albatross with the rule used to identify it. There is no underlying theory as to why a white albatross is a laysan albatross and a dark one is a black footed albatross. That is simply the rule used to classify them.

While an explanation feature might be of questionable value to the user of the system, it is invaluable to the developer of the system. It serves the same diagnostic purpose as program tracing for conventional programs. When the system is not behaving correctly, the expert can use the explanations to find the rules that are in error. The knowledge

<!-- page 46 -->
*Building Expert Systems in Prolog* engineer uses the explanations to better tune the knowledge base to have more realistic dialogs with the user.

## Types of Explanation

There are four types of explanations commonly used in expert systems. We will implement most of these in both the *Clam* shell and the *Native* shell:

- a rule trace, which reports on the progress of a consultation;

- explanation of how the system reached a given conclusion;

- explanation of why the system is asking a question;

- explanation of why not a given conclusion.

Since we wrote the inference engine for *Clam* it will not be difficult to modify it to include these features. The *Native* system currently uses Prolog's inference engine. In order to add explanation it will be necessary to write our own Prolog inference engine. Fortunately it is not difficult to write Prolog in Prolog. 4.1 Explanation in Clam

First, let's look at some examples of the explanation features of *Clam* using the Car system. Here is how the user turns on tracing for the consultation, and the results. The new trace information is in bold. It shows the sequence of rule firings as they are expected. Notice in particular that it reports correctly on the nesting of rules 2 and 3 within rule 1.

```prolog
          restart, load, list, trace, how, exit
consult,
:trace on
consult, restart, load, list, trace, how, exit
:consult
call rule 1
Does the engine turn over?
: no
call rule 2
Are the lights weak?
: yes
exit rule 2
call rule 3
Is the radio weak?
: yes
exit rule 3
exit rule 1
call rule 4
fail rule 4
call rule 5
fail rule 5
call rule 6
fail rule 6
problem-battery-cf-75
done with problem
```

Next we can look at the use of why explanations. The user would ask why and get the inference chain that led to the question. For example:

```prolog
...
Is the radio weak?
: why
rule 3
If
```

36

<!-- page 47 -->
*Chapter 4 - Explanation*

```prolog
radio_weak
Then
battery_bad 50
rule 1
If
not turn_over
battery_bad
Then
problem is battery 100
goal problem
...
```

Notice that the why explanation gives the chain of rules, in reverse order, that led to the question. In this case the goal problem led to rule 1 which led to rule 3.

The how explanations start with answers. For example, the system has just reported that the problem is the battery. The user wants to know how this result was derived.

```prolog
...
problem-battery-cf-75
done with problem
consult, restart, load, list, trace, how, exit
:how
Goal? problem is battery
problem is battery was derived from rules: 1
rule 1
If
not turn_over
battery_bad
Then
problem is battery 100
```

In this case the rule(s) which directly supported the result are listed. Next the user wants to know how battery_bad was derived.

```prolog
consult, restart, load, list, trace, how, exit
:how
Goal? battery_bad
battery_bad was derived from rules: 3 2
rule 3
If
radio_weak
Then
battery_bad 50
rule 2
If
lights_weak
Then
battery_bad 50
```

In this case there were two rules that supported the goal, and the system lists them both.

Figure 4.1 shows the difference between how and why questions. The why questions occur at the bottom of an inference chain, and the how questions occur at the top.

<!-- page 48 -->
*Building Expert Systems in Prolog*

goal ( problem is ?)

rule 1

rule 2

query user

rule 3

conclusion

problem is . . .

query user

why

rule 3, rule 1

how

rule 1

rule 2, 3

**Figure 4.1. Difference between how and why questions**

### Tracing

**The first explanation addition to Clam will be the rule tracing facility. It will behave**

**similarly to the Prolog box model traces, and inform the user when a rule is "call"ed,**

**"exit"ed, or "fail"ed. It will use a special predicate bugdisp to communicate trace**

information with the user. It will take as an argument a list of terms to be written on a line.

To make it a user option, bugdisp will only write if ruletrace is true. The user will have a new high level command to turn tracing on or off which will assert or retract ruletrace. We can then use bugdisp to add any diagnostics printout we like to the program.

```prolog
bugdisp(L) :-
ruletrace,
write_line(L),
!.
bugdisp(_).
write_line([]) :-
nl.
write_line([H|T]) :-
write(H),
tab(1),
write_line(T).
```

**Here is the new command added to the do predicate called by the command loop**

predicate, go. It allows the user to turn tracing on or off by issuing the command trace(on) or trace(off).

```prolog
do( trace(X) ) :-
set_trace(X),
!.
set_trace(off) :-
ruletrace,
retract( ruletrace ).
set_trace(on) :-
not ruletrace,
asserta( ruletrace ).
set_trace(_).
```

**38**

**Chapter 4 - Explanation**

<!-- page 49 -->
Now that we have the tools for displaying trace information, we need to add bugdisp calls in the predicate that recursively tries rules, fg. It is easy to determine in fg when a rule is called and when it has been successful. After the call to rule succeeds, the rule has been called. After the call to prove, the rule has been successfully fired. The new code for the predicate is added in bold.

```prolog
fg(Goal, CurCF) :-
rule(N, lhs(IfList), rhs(Goal, CF)),
bugdisp(['call rule', N]),
prove(N, IfList, Tally),
bugdisp(['exit rule', N]),
adjust(CF, Tally, NewCF),
update(Goal, NewCF, CurCF, N),
CurCF == 100,
!.
fg(Goal, CF) :-
fact(Goal, CF).
```

All that remains is to capture rules that fail after being called. The place to do this is in a second clause to prove, which is called when the first clause fails. The second clause informs the user of the failure, and continues to fail.

```prolog
prove(N, IfList, Tally) :-
prov(IfList, 100, Tally),
!.
prove(N, _, _) :-
bugdisp(['fail rule', N]),
fail.
```

### How Explanations

The next explanation feature to implement is *how*. The how question is asked by the user to see the proof of some conclusion the system has reached. The proof can be generated by either rederiving the result with extra tracing, or by having the original derivation stored in working storage. *Clam* uses the second option and stores derivation information with the fact in working storage. Each fact might have been derived from multiple rules, all concluding the same attribute value pair and combining certainty factors. For this reason, a list of rule numbers is stored as the third argument to fact. This is not the entire proof tree, but just those rules which conclude the fact directly.

```prolog
fact(AV, CF, RuleList)
```

A fact is updated by update, so this is where the derivation is captured. A new argument is added to update which is the rule number that caused the update. Note that the first clause of update adds the new rule number to the list of existing derivation rule numbers for the fact. The second clause merely creates a new list with a single element.

```prolog
update(Goal, NewCF, CF, RuleN) :-
fact(Goal, OldCF, _),
combine(NewCF, OldCF, CF),
retract( fact(Goal, OldCF, OldRules) ),
asserta( fact(Goal, CF, [RuleN | OldRules]) ),
!.
update(Goal, CF, CF, RuleN) :-
asserta( fact(Goal, CF, [RuleN]) ).
```

The call to update from fg is modified to fill in the new argument with a rule number:

```prolog
fg(Goal, CurCF) :-
rule(N, lhs(IfList), rhs(Goal, CF)),
...
```

<!-- page 50 -->
*Building Expert Systems in Prolog*

```prolog
update(Goal, NewCF, CurCF, N),
...
```

Now that the supporting rules for each derived fact are in working storage, we can answer a user's question about how a fact was derived. The simplest thing to do is to have how simply write the list of rules used. It is probably of more interest to the user to actually display the rules as well. The predicate list_rules does that.

```prolog
how(Goal) :-
fact(Goal, CF, Rules),
CF > 20,
pretty(Goal, PG),
write_line([PG, was, derived, from, 'rules: '|Rules]),
nl,
list_rules(Rules),
fail.
how(_).
```

The how predicate for negated goals is similar and uses the fact that negation is represented by a negative CF.

```prolog
how(not Goal) :-
fact(Goal, CF, Rules),
CF < -20,
pretty(not Goal, PG),
write_line([PG, was, derived, from, 'rules: '|Rules]),
nl,
list_rules(Rules),
fail.
```

The pretty predicate is used to convert av structures into a more readable list and visa versa.

```prolog
pretty(av(A, yes), [A]) :- !.
pretty(not av(A, yes), [not, A]) :- !.
pretty(av(A, no), [not, A]) :- !.
pretty(not av(A, V), [not, A, is, V]).
pretty(av(A, V), [A, is, V]).
```

The list_rules predicate writes a formatted listing of each rule used in deriving a given fact.

```prolog
list_rules([]).
list_rules([R|X]) :-
list_rule(R),
list_rules(X).
list_rule(N) :-
rule(N, lhs(Iflist), rhs(Goal, CF)),
write_line(['rule ', N]),
write_line(['If']),
write_ifs(Iflist),
write_line(['Then']),
pretty(Goal, PG),
write_line([' ', PG, CF]), nl.
write_ifs([]).
write_ifs([H|T]) :-
pretty(H, HP),
tab(5), write_line(HP),
write_ifs(T).
```

40

<!-- page 51 -->
*Chapter 4 - Explanation* We can use pretty in reverse, along with a predicate that reads a list of tokens from a line to provide a nicer interface to the user for how questions. In this way the user doesn't have to specify the internal form of the fact.

```prolog
how :-
write('Goal? '), read_line(X), nl,
pretty(Goal, X),
how(Goal).
```

The how command can now be added as part of the top level user interface:

```prolog
do(how) :-
how,
!.
```

The full how command as coded above just displays for the user the rules directly responsible for a fact. These rules themselves are likely based on other facts, which were derived as well. There are two ways of presenting this information:

- let the user ask further hows of the various rules' left hand side goals to delve deeper into the proof tree;

- have how automatically display the entire proof tree.

So far we have chosen the first. In order to implement the second choice, a predicate how_lhs needs to be written, which will trace the full tree by recursively calling how for each of the goals in the Iflist of the rule.

```prolog
list_rules([]).
list_rules([R|X]) :-
list_rule(R),
how_lhs(R),
list_rules(X).
how_lhs(N) :-
rule(N, lhs(Iflist), _),
!,
how_ifs(Iflist).
how_ifs([]).
how_ifs([Goal|X]) :-
how(Goal),
how_ifs(X).
```

The three choices of user interface for hows (just rule numbers, listings of direct rules, list of full proof tree) shows some of the problems with shells and the advantages of a toolbox approach. In a customized expert system, the options that make the most sense for the application can be used. In a generalized system the designer is faced with two unpleasant choices. One is to keep the system easy to use and pick one option for all users. The other is to give the flexibility to the user and provide all three, thus making the product more complex for the user to learn.

The how question is asked from the top level of an inference, after the inference has been completed. The why question is asked at the bottom of a chain of rules — when there are no more rules and it is time to ask the user. The user wants to know why the question is being asked.

<!-- page 52 -->
*Building Expert Systems in Prolog* In order to be able to answer this type of question, we must keep track of the inference chain that led to the question to the user. One way to do this is to keep an extra argument in the inference predicates that contains the chain of rules above it in the inference. This is done in findgoal and prove. Each keeps a separate argument, Hist, which is the desired list of rules. The list is initially the empty list at the top call to findgoal.

```prolog
findgoal(Goal, CurCF, Hist) :-
fg(Goal, CurCF, Hist).
fg(Goal, CurCF, Hist) :-
...
prove(N, IfList, Tally, Hist),
...
```

The prove predicate maintains the list by adding the current rule number on the head of the list before a recursive call to findgoal. The calls further down the recursion have this new rule number available for answers to why questions. Notice that both Prolog's recursive behavior and backtracking assure that the history is correct at any level of call.

```prolog
prove(N, IfList, Tally, Hist) :-
prov(IfList, 100, Tally, [N|Hist]),
!.
prove(N, _, _) :-
bugdisp(['fail rule', N]),
fail.
prov([], Tally, Tally, Hist).
prov([H|T], CurTal, Tally, Hist) :-
findgoal(H, CF, Hist),
min(CurTal, CF, Tal),
Tal >= 20,
prov(T, Tal, Tally, Hist).
```

Finally, we need to give the user the ability to ask the *why* question without disturbing the dialog. This means replacing the old reads of user input with a new predicate, get_user, which gets an answer from the user and processes it as a why command if necessary. Hist is of course passed down as an argument and is available for get_user to process. Also, rather than just displaying rule numbers, we can list the rules for the user as well.

The process_ans predicate first looks for command patterns and behaves accordingly. If it is a command, the command is executed and then failure is invoked causing the system to backtrack and re-ask the user for an answer.

Note that now that we are capturing and interpreting the user's response with more intelligence, we can give the user more options. For example, at the question level he/she can turn tracing on or off for the duration of the session, ask a how question, or request help. These are all easily added options for the implementer.

```prolog
get_user(X, Hist) :-
repeat,
write(': '),
read_line(X),
process_ans(X, Hist).
process_ans([why], Hist) :-
nl, write_hist(Hist),
!,
fail.
process_ans([trace, X], _) :-
set_trace(X),
!,
fail.
process_ans([help], _) :-
```

42

<!-- page 53 -->
*Chapter 4 - Explanation*

```prolog
help,
!,
fail.
process_ans(X, _).  % just return user's answer
write_hist([]) :-
nl.
write_hist([goal(X)|T]) :-
write_line([goal, X]),
!,
write_hist(T).
write_hist([N|T]) :-
list_rule(N),
!,
write_hist(T).
```

**4.2 Native Prolog Systems**

Since we wrote the inference engine for *Clam*, it was easy to modify it to add the code for explanations. However, when we use pure Prolog, we don't have access to the inference engine.

This problem is easily solved. We simply write a Prolog inference engine in Prolog. Then, having written the inference engine, we can modify it to handle explanations.

An inference engine has to have access to the rules. In Prolog, the clauses are themselves just Prolog terms. The built-in predicate clause gives us access to the rules. It has two arguments, which unify with the head of a clause and its body. A fact has a body with just the goal true.

Predicates that manipulate Prolog clauses are confusing to read due to the ambiguous use of the comma in Prolog. It can be either:

- an operator used to separate the subgoals in a clause; or

- a syntactic separator of functor arguments.

Prolog clauses are just Prolog terms with functors of ":-" and ",". Just for now, pretend Prolog used an "&" operator to separate goals rather than a "," operator. Then a clause would look like:

```prolog
a :- b & c & d.
```

Without the operator definitions it would look like:

```prolog
:-(a, &(b, &(c, d))).
```

The clause built-in predicate picks up the first and second arguments of the ":-" functor. It will find the entire Prolog database on backtracking. If patterns are specified in either argument, then only clauses that unify with the patterns are found. For the above clause:

```prolog
?- clause(Head, Body).
Head = a
Body = b & c & d
```

A recursive predicate working through the goals in Body would look like:

<!-- page 54 -->
*Building Expert Systems in Prolog*

```prolog
recurse(FirstGoal & RemainingGoals) :-
process(FirstGoal),
recurse(RemainingGoals).
recurse(SingleGoal) :-
process(SingleGoal).
```

The use of "&" was just to distinguish between the two commas in Prolog. To resolve ambiguous references to commas as in the first line of the above code, parenthesis are used. The first line should really be written:

```prolog
recurse( (FirstGoal, RemainingGoals) ) :-
...
```

See Clocksin & Mellish Section 2.3, *Operators* for a full discussion of operators.

Given the means to access and manipulate the Prolog database of facts and rules, a simple Prolog interpreter that proves a list of goals (goals separated by the "," operator) would look like:

```prolog
prove(true) :- !.
prove((Goal, Rest)) :-
clause(Goal, Body),
prove(Body),
prove(Rest).
prove(Goal) :-
clause(Goal, Body),
prove(Body).
```

Notice that prove mimics precisely Prolog's behavior. First it finds a clause whose head matches the first goal. Then it proves the list of goals in the Body of the clause. Notice that unification automatically occurs between the Goal for the head of the clause and the Body. This is because the Prolog clause is just a Prolog term. If it succeeds, it continues with the rest of the goals in the list. It it fails, it backtracks and finds the next clause whose head unifies with the Goal.

This interpreter will only handle pure Prolog whose clauses are asserted in the database. It has no provisions for built-in predicates. These could be included by adding a final catchall clause:

```prolog
prove(X) :- call(X).
```

For *Native* we do not intend to have Prolog built-in predicates, but we do intend to call ask and menuask. For the *Native* shell these are our own built-in predicates.

We will make some basic modifications to our Prolog interpreter to allow it to handle our own built-in predicates and record information for explanations. First, we write an intermediate predicate prov that calls clause. It can also check for built-in predicates such as ask and menuask in the system. If the goal is either of these, they are just called with real Prolog.

Next we add an extra argument, just as we did for *Clam*. The extra argument keeps track of the level of nesting of a particular goal. By passing this history along to the ask predicates, the ask predicates can now respond to why questions.

```prolog
prove(true, _) :- !.
prove((Goal, Rest), Hist) :-
prov(Goal, (Goal, Rest)),
prove(Rest, Hist).
prov(true, _) :- !.
```

44

<!-- page 55 -->
*Chapter 4 - Explanation*

```prolog
prov(menuask(X, Y, Z), Hist) :-
menuask(X, Y, Z, Hist),
!.
prov(ask(X, Y), Hist) :-
ask(X, Y, Hist),
!.
prov(Goal, Hist) :-
clause(Goal, List),
prove(List, [Goal|Hist]).
```

Notice that the history is a list of goals, and not the full rules as saved in *Clam*.

The next step is to modify the top level predicate that looks for birds. First add an empty history list as an argument to the top call of prove:

```prolog
solve :-
abolish(known, 3),
define(known, 3),
prove(top_goal(X), []),
write('The answer is '), write(X), nl.
solve :-
write('No answer found'), nl.
```

The processing of why questions is the same as in *Clam*.

```prolog
get_user(X, Hist) :-
repeat,
read(X),
process_ans(X, Hist),
!.
process_ans(why, Hist) :-
write(Hist),
!,
fail.
process_ans(X, _).
```

The dialog with the user would look like:

```prolog
?- identify.
nostrils : external_tubular? why.
[nostrils(external_tubular), order(tubenose), family(albatross),
bird(laysan_albatross)]
nostrils : external_tubular?
```

We can further use clause to answer how questions. In *Clam* we chose to save the derivations in the database. For native Prolog it is easier just to rederive the answer.

```prolog
how(Goal) :-
clause(Goal, List),
prove(List, []),
write(List).
```

It is also possible to ask whynot questions, which determine why an expected result was not reached. This also uses clause to find the clauses that might have proved the goals, and goes through the list of goals looking for the first one that failed. It is reported, and then backtracking causes any other clauses that might have helped to be explained as well.

```prolog
whynot(Goal) :-
clause(Goal, List),
write_line([Goal, 'fails because: ']),
explain(List).
```

<!-- page 56 -->
*Building Expert Systems in Prolog*

```prolog
whynot(_).
explain( (H, T) ) :-
check(H),
explain(T).
explain(H) :-
check(H).
check(H) :-
prove(H, _),
write_line([H, succeeds]),
!.
check(H) :-
write_line([H, fails]),
fail.
```

The whynot predicate has the same design problems as how. Do we automatically recurse through a whole failure tree, or do we let the user ask successive whynot's to delve deeper into the mystery. This version just gives the first level. By adding a recursive call to whynot in the second clause of check, it would print the whole story.

## Exercises

4.1 Implement whynot for *Clam*. 4.2 Have whynot give a full failure history. 4.3 Make sure the explanation facility can handle attribute object value triples in both

*Clam* and *Native*. 4.4 Decide whether you like the full rules presented in answer to why questions as in

*Clam*, or just the goals as in *Native*. Make both systems behave the same way. 4.5 Enhance the trace function so it displays the goals currently being sought by the

system. Have various levels of trace information that can be controlled by the trace

```prolog
command.
```

4.6 Using prove, implement a Prolog trace function. 4.7 Add a pretty printing predicate for *Native* to use when displaying Prolog rules.

46

*Chapter 4 - Explanation*

