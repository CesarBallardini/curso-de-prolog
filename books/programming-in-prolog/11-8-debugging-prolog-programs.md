# 8 Debugging Prolog Programs

<!-- page 201 -->
Debugging Prolog Programs

```prolog
By this point you will have used and modified many of the example programs de-
scribed earlier, and you will have written programs of your own. It is now relevant
to consider what to do when your program does not behave as intended. Such prob-
lems with programs are known as "bugs", and the process of removing bugs from
programs is known as "debugging". We believe that a convenient approach to pro-
gramming is what could be described as "preventative programming". To paraphrase
an old proverb, "an ounce of careful programming is worth a pound of debugging".
In this chapter we shall attempt to describe some techniques for debugging, but we
shall start with a discussion of how to try to prevent bugs from infesting your pro-
grams. We realise that such a problem is unsolved in general, but we simply wish to
convey some informal techniques that have helped other Prolog programmers.
    As with any creative activity, whether musical composition, literature, or archi-
tecture, computer programming offers a multitude of methods for expressing how to
represent and manipulate the objects and relationships that are found in a particular
problem. In general, there will be a number of ways to represent or manipulate some
item of information in a program. Every time the programmer decides to use one of
the ways in the program, we say that the programmer has made a design decision.
    Novices faced with the task of making design decisions for the first time often
feel confused. An understanding of the choices available will help them, and it is
important for a tutor to explain programming techniques in general. This is because
the art of making design decisions in programming is a discipline in its own right. We
attempted to give the flavour of this problem in Section 1.1 when we discussed the
different ways to understand the meaning of clauses. This is a matter of representing
objects and relationships. Also, in Section 7.7 the problem also became apparent
when we described three different ways to sort a list of objects. This is a matter of
different ways to manipulate objects and relationships.
```

<!-- page 202 -->
```prolog
    We hope that this book provides help about making design decisions in two
ways. First, by containing a number of example programs, it should convey some
idea of the solutions that practising programmers have obtained. Second, this chapter
should provide some advice and direction that is specific to Prolog.
```

## 8.1 Laying out Programs

```prolog
Assuming that the programmer has decided how to represent and manipulate the
objects and relationships in the problem, the next step is to ensure that the layout and
syntax of the program is clear and easily read. The collection of clauses for a given
predicate is called a procedure. In the examples in this book, you may have noticed
that each clause in a procedure has started on a new line, and there is one blank
line between procedures. For example, one way to define the set equality predicate
(representing sets as lists) is to use three predicates, each of which is defined by a
twoline procedure:
    eqset(X, X) :- !.
    eqset(X, Y) :- eqlist(X, Y).
    eqlist([], []).
    eqlist([X|Ll], L2) :- delete(X, L2, L3), eqlist(Ll, L3).
    delete(X, [X|Y], Y).
    delete(X, [Y|L1], [Y|L2]) :- delete(X, LI, L2).
This is not necessarily the best definition of set equality, but it points out how to lay
out procedures. Notice that the clauses for each procedure are grouped together, and
procedures are separated by a blank line. Notice also that the body of each rule is
short enough to fit on one line. Another convention that is adopted by many Prolog
programmers is to write each clause on a single line if the entire clause will fit on a
line. Otherwise, write the head of the clause and the ":-" on the first line, and write
each goal of a conjunction indented on a separate line. For example, a program to
generate all permutations of a list:
    permute([], []).
    permute(L, [H|T]) :-
            append(V, [H|U], L),
            append(V, U, W),
            permute(W, T).
The definition uses a backtracking append, so that another permutation Y is generated
from X each time an attempt is made to re-satisfy permute(X, Y). What we should
notice here is the way the conjuncts in the second clause are laid out on the page.
```

<!-- page 203 -->
```prolog
    The main point is to decide on consistent conventions, whatever the conventions
may be. In general, it is wise to add comments, to group terms appropriately, to use
round brackets when in doubt about operator precedences, and to use plenty of white
space (spaces and blank lines) in consistent ways. Comments should indicate how
the arguments of a structure (or clause) are interpreted: what order they come in,
and what data structures (constants or structures) are expected to fill each argument.
Also, it is wise to write comments on the way that variables are expected to become
instantiated as the clause becomes satisfied.
    For more global organisation of the program, it is helpful to divide the program
into reasonably self-contained parts, for example, where all of the list processing
procedures would appear in the same file. A Prolog procedure that uses more than
about five to ten rules may be hard to read, so consider whether it can be broken up
naturally by the definition of some subsidiary predicates. If a program uses many
facts, such as the simplification rules in Section 7.12, then all of the facts should
belong together in the same file. A lot of facts is generally easier to read than a lot of
rules, and although even a few rules may be difficult to understand, many pages of a
particular fact can be understood because the semantics of facts are less complex.
    Another issue that affects the ease in which Prolog programs can be read is the
use of semicolon ("or") and exclamation ("cut"). The problems with excessive use of
the "cut" were introduced in Chapter 4. You should always consider whether it may
be worthwhile avoiding a ";" by defining extra clauses. For instance, the following
program:
    nospy(X) :-
        check(X,Functor,Arity,A), !,
        ( spypoint(_,Functor,A), !,
        ( deny(spypoint(Head,Functor,Arity),_),
        makespy(Head,Body), deny(Head,Body),
        write('Spypoint on '), prterm(Functor,Arity),
        write(' removed.'), nl,
        fail; true ) ; write('There is no spypoint on '),
        write(X), put(46), nl), !.
is an example of what not to do. It is much harder to understand than:
    nospy(X) :-
            check(X, Functor, Arity, A), !,
            try_remove(X, Functor, Arity, A).
    try_remove(_, Functor, Arity, A) :-
            spypoint(_. Functor, A), !,
            remove_spy(Functor, Arity, A).
    try_remove(X,
                    _)
```

<!-- page 204 -->
```prolog
            writefThere is no spypoint on '),
            write(X), put(46), nl, !.
    remove_spy(Functor, Arity, A) :-
            deny(spypoint(Head, Functor, Arity),_),
            makespy(Head, Body),
            deny(Head, Body),
            write('Spypoint on '),
            prterm(Functor, Arity),
            write(' removed.'), nl, fail.
    remove_spy(_,
                   _).
which does exactly the same thing. When you really do want to use "or", it is helpful
to arrange the conjunction of goals so that the "or" stands out from the rest of the
goals, and to place brackets around the goals so that the scope of the "or" is made
explicit.
    Throughout this book we have emphasised the importance of thinking of many
problems in terms of boundary conditions together with a general rule. Whenever
possible, we write boundary conditions before all the other clauses of a procedure.
This makes it easy to see what the boundary conditions are, and also provides some
measure of protection against circular definitions. However, there are some cases
where it is desirable to place the boundary condition after the other clauses of a
procedure. Obviously, "catchall" rules, as seen several times previously, need to be
placed at the end of the procedure.
    When reading a Prolog procedure, it is helpful to look each time for the follow-
ing key properties of the procedure.
•
   Look at how each predicate and variable in the procedure is spelled. Mis-spelling
   is a common mistake.
•
```

`Look for the` *number of components* `of each functor that is mentioned in the`

```prolog
   procedure. Ensure that the number of components (and their order) is consistent
   with your design decisions.
•
   Locate all of the operators in the clauses, and determine their precedence, asso-
   ciativity, and where their arguments are. You can determine this from operator
   declarations and the presence of brackets. When in doubt, add extra brackets.
   Also, to check whether an operator behaves in the way you expect, try printing
   out some sample terms using write_canonical.
•
   Notice the scope of each variable, and locate all the likenamed variables within
   the scope. Notice which variables will "share" when one of them becomes in-
   stantiated. Notice whether variables in the head of the clause appear in the body
   of the clause.
```

<!-- page 205 -->
```prolog
• Try to determine what variables are instantiated or uninstantiated at the time the
   clause will be used.
•
   Locate the clause(s) that constitute the boundary condition(s). Determine whether
   all the conceivable boundary conditions have been accounted for.
Once you can "dissect" a procedure in this way, your understanding of the procedure
will improve.
```

## 8.2 Common Errors

```prolog
In this section we list a number of problems that both beginning and experienced Pro-
log programmers encounter. The problems fall into two categories: errors of syntax,
```

`and errors of` *control flow.*

```prolog
    Once the programmer has decided what program to write, and how to lay it out
on the printed page (or terminal display screen), there is the problem of getting the
program into a file or typing it straight into the top level of a Prolog system. The
main problem encountered here is ensuring that the syntax of the program is correct.
Here we list a number of common syntactic errors. If these errors are not detected by
the programmer, Prolog may provide an error message when an attempt is made to
consult the program.
•
   A common syntax error is forgetting to add the dot"." at the end of a clause. A
   dot must also always follow any term that is read by the read predicate. You must
   also leave at least one white space character after the dot. So beware of ending a
   file with the dot of the last clause — make sure that there is a [i] at the very end.
•
   Some special characters belong in pairs. There are the round brackets "(" and
   ")" for grouping terms, the square brackets "[" and "]" for the list notation, and
   the curly brackets "{" and "}" for the grammar rule notation (Chapter 9). Also,
   the single quotes ""' for atoms, belong in pairs. The composite brackets "/*" and
   "*/" surround comments. Ensure that there are neither too few or too many of
   each kind of bracket.
•
   Beware of mis-spelled words, especially the names of built-in predicates. These
   can cause unexpected failures, because mis-spelled predicates are unlikely to
   match with any clauses in the database. Or, they may unexpectedly match with
   clauses that happen to have the same name as the mis-spelled one.
•
   Operators are another source of possible errors. Use round brackets when in
   doubt, to make the associativity of an operator explicit. Use write_canonical to
   experiment with the operators you have defined.
```

<!-- page 206 -->
```prolog
When considering the list notation, test yourself on the following questions and an-
swers:
```

`• How do [a,b,c] and [X|Y] match?` *(X is instantiated to* `a,` *and* `Y` *is instantiated to*

```prolog
[b,c]).
```

`• Do [a] and [X|Y] match?` *(Yes.* `X` *is instantiated to* `a,` *and* `Y` *is instantiated to []).*

```prolog
• Do [] and [X|Y] match? (no).
•
   Is [X,Y|Z] meaningful? (yes).
• Is [X|Y,Z] meaningful? (no).
•
```

`Is [X| [Y|Z]] meaningful?` *(Yes, it is the same as* `[X,Y|Z] j.`

```prolog
•
```

`How do [a,b] and [A|B] match? (A` *is instantiated to* `a,` *and* `B` *is instantiated to*

```prolog
•
   Is there more than one way to match them? (No, never).
When dealing with lists, or any other structure for that matter, it is important to stress
the helpfulness of the "tree diagrams" that we introduced in Chapter 2.
    Even if you are certain that a program is free from syntax errors, the program
can still exhibit unexpected behaviour when an attempt is made to satisfy goals in
the program. Typical symptoms are a program which seems to run without stopping
(an "infinite loop"), the response no appearing unexpectedly, or variables being in-
stantiated to unexpected terms. Usual sources of such errors are:
•
   Circular definitions, which were mentioned in Chapter 3.
•
   Not enough boundary conditions, or some other under-specification of the prob-
   lem.
• Useless procedures that redefine built-in predicates.
•
   Supplying the wrong number of arguments to a functor. This is not considered a
   syntax problem because the number of arguments of a functor depends on what
   the functor is used for.
•
   Unexpectedly reaching the end of a file when using the read predicate.
One particularly insidious type of error is demonstrated by the following program to
test list equality:
    eq([], [])•
    eq([X|L], M) :- del(X, M, N), eq(L, N),
```

<!-- page 207 -->
```prolog
    del(X, [X|Y], Y).
    del(X, [YjLl], [Y|L2]) :- del(X, LI, L2).
Do you see the mistake? The second clause of eq is terminated by a comma. Although
this is probably a typing error, the above program has legal syntax because the term
following the comma is taken as the next goal! The above program is identical to the
following program, which is certainly not a program to test list equality :
```

eq([], [])•

```prolog
    eq([X|L], M) :- del(X, M, N), eq(L, N), del(X, [X|Y], Y).
    del(X, [Y|L1], [Y|L2]) :- del(X, LI, L2).
A variation on this theme is the following:
```

eq([], [])•

```prolog
    eq([X|L], M) :- del(X, M, N). eq(L, N).
    del(X, [X|Y], Y).
    del(X, [Y|L1], [Y|L2]) :- del(X, LI, L2).
Do you see the mistake? The second clause of eq has its goals separated by a dot.
Again, this is likely to be a typing error, but the program as typed above has legal
syntax, and is identical to the following, which again is not what was intended:
```

eq([], [])•

```prolog
    eq([X|L], M) :- del(X, M, N).
    eq(L, N).
    del(X, [X|Y], Y).
    del(X, [Y|L1], [Y|L2]) :- del(X, LI, L2).
Beware of the following fallacies about the nature of backtracking:
Fallacy: One of the reasons for backtracking is so that Prolog can return to a previous
match and do it again in some other way. Fact: When Prolog searches the database
in an attempt to match a goal against something in the database (a fact or the head
of a rule), the match either succeeds or fails. Prolog does not backtrack to a "match"
and try to match another way, because there is only one way to match a particular
goal with a particular clause in the database.
Fallacy: The list notation [X|Y] can match against any segment of a list, and can take
apart lists in several different ways. The behaviour of append(X, Y, [a,b,c,d]) is due
to this. Fact: In [X|Y], X matches only the head of a list, and Y matches only the tail.
The append goals are able to find different partitions of lists because of backtracking,
not because of matching.
```

<!-- page 208 -->
## 8.3 The Tracing Model

```prolog
There are various ways of looking at the method by which Prolog attempts to satisfy
goals. We have introduced a model in terms of the "flow of satisfaction" through
boxes representing goals. Here we present the model of Prolog execution used by
a number of debugging aids, such as the trace facility. This model is largely due to
our colleague Lawrence Byrd, and for this reason the model is known as the Byrd
Box model. Although Prolog systems differ in the debugging aids provided (and the
Prolog standard does not specify what they should be), the following description
should roughly correspond to what happens with many Prolog systems.
    When the trace facility is used, the Prolog system prints out information about
the sequence of goals in order to show where the program has reached in its execu-
tion. However, in order to understand what is happening, it is important to understand
when and why the goals are printed. In a conventional programming language, the
key points of interest are the entries to and exits from functions. But Prolog permits
non-deterministic programs to be written, and this introduces the complexities of
backtracking. Not only are clauses entered and exited, but backtracking can suddenly
reactivate them in order to generate an alternative solution. Furthermore, the cut goal
"!" indicates which goals are committed to having only one solution. One of the ma-
jor confusions that novice programmers face is what actually occurs when a goal fails
and the system suddenly starts backtracking. We hope this has been adequately ex-
plained in the previous chapters. However, the previous chapters discussed not only
control flow, but also how variables are instantiated, how goals match against clause
heads in the database, and how subgoals are satisfied. The tracing model describes
the execution of Prolog programs in terms of four kinds of events that occur:
CALL. A C A L L event occurs when Prolog starts trying to satisfy a goal. In our
diagrams, this is when an arrow enters a box from the top.
EXIT. An EXIT event occurs when some goal has just been satisfied. In our diagrams,
this is when the arrow emerges from the bottom of a box.
REDO. A REDO event occurs when the system comes back to a goal, trying to
resatisfy it. In our diagrams, this is when the arrow retreats back into a box from the
bottom.
FAIL. A FAIL event occurs when a goal fails. In our diagrams, this is when the arrow
retreats upwards out of a box.
The debugging aids tell us about when events of these four kinds occur in the exe-
cution of our programs. These events will take place for all of the various goals that
Prolog considers during the execution. So that we can distinguish which events are
happening to which goals, each goal is given a unique integer identifier, its
                                                             invocation
```

<!-- page 209 -->
```prolog
number. Below we shall show some goals together with their invocation numbers in
square brackets.
    Let us now take a look at an example. Consider the following definition of the
predicate descendant:
    descendant^, Y) :- offspring(X, Y).
    descendant(X, Z) :- offspring(X, Y), descendant(Y, Z).
This piece of program derives descendants of a person, provided that there are off-
spring facts in the database, such as
    offspring(abraham, ishmael).
    offspring(abraham, isaac).
    offspring(isaac, esau).
The first clause of descendant states that Y is a descendant of X if Y is an offspring of
X. The second clause states that Z is a descendant of X if Y is an offspring of X and if
Z is a descendant of Y. We shall consider the question:
    ?- descendant(abraham. Answer), fail.
and we shall follow the control flow to see when the various kinds of events occur.
It is important that you try to follow the trace we are about to look at by thinking
about the flow of satisfaction entering and leaving the boxes for the goals. We will
periodically display the current state in diagram form.
    The first goal in the question is followed by a fail. The purpose of this is to
force all possible backtracking behaviour out of the descendant goal. The question
as a whole can therefore never succeed. However, the point of this trace is to observe
the execution flow induced by the failure of the second goal (the fail). We begin with
(as yet unentered) boxes for the two goals:
                descendant(abraham,Answer)
                fail
The first event is that the descendant goal is CALLed. This is invocation number 1
(shown in square brackets).
```

<!-- page 210 -->
```prolog
    [1] CALL: descendant(abraham,Answer)
    [2] CALL: offspring(abraham,Answer)
We have matched the first clause of the descendant procedure and this results in a
C A L L of a goal for offspring. The situation is now as follows, with the arrow moving
downwards:
              descendant(abraham, Answer)
```

(1)

```prolog
           fail
We continue:
    [2] EXIT: offspring(abraham,ishmael)
Immediate success on the first clause, and so the goal EXITs.
    [1] EXIT: descendant(abraham,ishmael)
And thus we have satisfied the first descendant clause.
    [3] CALL: fail
    [3] FAIL: fail
    [1] REDO: descendant(abraham,ishmael)
Then we try to satisfy fail, and, as might be expected, this goal FAILs. The arrow
retreats back out of the fail box and back into the descendant box above. Here is a
picture of where we are now. The arrow is retreating upwards out of the fail box.
Continuing:
    [2] REDO: offspring(abraham,ishmael)
    [2] EXIT: offspring(abraham,isaac)
```

<!-- page 211 -->
```prolog
An alternative clause is chosen for the offspring goal, and so the arrow can move
down out of this box again.
    [1] EXIT: descendant(abraham,isaac)
    [4] CALL: fail
    [4] FAIL: fail
    [1] REDO: descendant(abraham,isaac)
Again, fail causes us to reject this solution and to start backtracking. Notice that this
was a completely new invocation of fail (we entered it afresh from "above").
    [2] REDO: offspring(abraham,isaac)
    [2] FAIL: offspring(abraham,Answer)
This time, offspring cannot offer us another match and so we continue backtracking,
the arrow retreating upwards out of the offspring box.
    [5] CALL: offspring(abraham,Y)
What has happened here is that Prolog has chosen the second descendant clause and
this is a completely new offspring invocation corresponding to the first subgoal:
The arrow is now moving downwards again. Continuing:
    [5] EXIT: offspring(abraham,ishmael)
    [6] CALL: descendant(ishmael,Answer)
This provides a solution with which we now recursively call descendant. This gives
us a new invocation of descendant.
    [7] CALL: offspring(ishmael,Answer)
```

<!-- page 212 -->
```prolog
              descendant(abraham, Answer)
               (2)
          fait
    [7] FAIL: offspring(ishmael,Answer)
    [8] CALL: offspring(ishmael,Y2)
    [8] FAIL: offspring(ishmael,Y2)
    [6] FAIL: descendant(ishmael,Answer)
Ishmael has no offspring (in this example), and so the offspring subgoals in both
descendant clauses fail, thus failing the descendant goal.
    [5] REDO: offspring(abraham,ishmael)
Back we go for an alternative.
    [5] EXIT: offspring(abraham,isaac)
    [9] CALL: descendant(isaac,Answer)
    [10] CALL: offspring(isaac,Answer)
    [10] EXIT: offspring(isaac,esau)
We get a new invocation of descendant and the offspring subgoal succeeds:
Continuing:
    [9] EXIT: descendant(isaac,esau)
    [I] EXIT: descendant(abraham,esau)
    [11] CALL: fail
    [II] FAIL: fail
    [1] REDO: descendant(abraham,esau)
    [9] REDO: descendant(isaac,esau)
```

<!-- page 213 -->
```prolog
  [1]
              descendant(abraham,esau)
              (2)
         fail
This provides a final solution to the initial question, but the fail forces backtracking
again and so back we come along the REDO paths.
    [10] REDO: offspring(isaac,esau)
    [10] EXIT: offspring(isaac,jacob)
    [9] EXIT: descendant(isaac,jacob)
    [1] EXIT: descendant(abraham,jacob)
The offspring subgoal has another alternative which produces another result for the
initial descendant goal. As can be seen, this is Abraham's last possible descendant,
however there is a certain amount of work left to be done. Let us continue to follow
the control flow as it backtracks unsuccessfully back to the beginning.
    [12] CALL: fail
    [12] FAIL: fail
    [1] REDO: descendant(abraham,jacob)
    [9] REDO: descendant(isaac,jacob)
    [10] REDO: offspring(isaac,jacob)
    [10] FAIL: offspring(isaac,Answer)
    [13] CALL: offspring(isaac,Y3)
```

<!-- page 214 -->
```prolog
We are now trying the second clause for descendant.
    [13] EXIT: offspring(isaac,esau)
    [14] CALL: descendant(esau,Answer)
Recur again.
    [15] CALL: offspring(esau,Answer)
    [15] FAIL: offspring(esau,Answer)
    [16] CALL: offspring(esau,Y4)
    [16] FAIL: offspring(esau,Y4)
    [14] FAIL: descendant(esau,Answer)
    [13] REDO: offspring(isaac,esau)
    [13] EXIT: offspring(isaac,jacob)
    [17] CALL: descendant(jacob,Answer)
Try jacob.
    [18] CALL: offspring(jacob,Answer)
    [18] FAIL: offspring(jacob,Answer)
    [19] CALL: offspring(jacob,Y5)
    [19] FAIL: offspring0'acob,Y5)
    [17] FAIL: descendant(jacob,Answer)
    [13] REDO: offspring(isaac,jacob)
    [13] FAIL: offspring(isaac,Y3)
    [9] FAIL: descendant(isaac,Answer)
    [1] FAIL: descendant(abraham,Answer)
```

*no*

```prolog
And that's the end of that. We hope that this exhaustive example has provided an
understanding of the control flow involved in the execution of a Prolog program.
You should have noticed that for any goal there is always only one C A L L and FAIL,
although there may be arbitrarily many REDOs and corresponding EXITs. In the
next section, we look at the trace messages for a more complicated example: append.
Exercise 8.1: In the above model, no mention is made of how the cut goal "!" is
handled. Extend the model to account for the action of cut.
```

## 8.4 Tracing and Spy Points

```prolog
When you find that your program doesn't work (because it generates an error, just
says "no" or produces the wrong answer), you will want to find out quickly where
```

<!-- page 215 -->
```prolog
the mistakes are so that you can correct them. This section describes a set of builtin
predicates that allow you to "watch" your program running. Using these, you can
give your program the same task again, and watch to see where it starts going wrong.
What you will see is when the various events of the tracing model take place, as
we saw with descendant in the last section. The exact facilities that the debugging
predicates provide will depend on the particular Prolog implementation, but the fol-
lowing should give some guide about the sorts of options, so that you can make sense
of what your system provides. In any case, you are strongly advised to consult the
documentation for your Prolog system before you start using these facilities.
    The basic principle behind tracing and spy points is that the programmer is
informed about the satisfaction of certain goals that arise in the running of his pro-
gram. The programmer can decide, first, what goals he or she wishes to be informed
about, and second, how much he or she wants to interact with how goals are sat-
isfied. The first decision involves deciding what combination of exhaustive tracing
and spy points to use. Basically, exhaustive tracing involves information being given
about all goals, and spy points enable the programmer to get only information about
certain predicates that he or she has specified. However, these options can be mixed
in various ways. Section 6.13 outlines the relevant built-in predicates that are of use
here. To set a spy point on a predicate, we use predicate spy (and to remove a spy
point, we use nospy). To start exhaustive tracing, we use trace (and to turn it off, we
use notrace).
    The second decision involves deciding on the level of leashing that is to be
used. In unleashed tracing, information about the goals is displayed on the terminal
and the program keeps on running. In leashed tracing, as well as the information
being displayed, the programmer is asked at each point which option to take. It may
then be possible to specify changes in the level of tracing, alterations from the normal
flow of the program and various other options. Your Prolog system may provide an
independent choice of leashed or unleashed tracing for each of the four kinds of
events:
•
   When an attempt is first made to satisfy a goal: when the goal is encountered for
   the first time (a C A L L event),
•
   When a goal has successfully been satisfied (an EXIT event),
•
   When an attempt is about to be made to re-satisfy a goal (a REDO event), and
•
   When a goal is about to fail, because all attempts to re-satisfy it have failed (a
   FAIL event).
For instance, a reasonable choice would be to specify that CALL and REDO events
are leashed and EXIT and FAIL events are unleashed. We gave a more detailed de-
scription of these four events in the satisfaction of goals in Section 8.3.
```

<!-- page 216 -->
```prolog
    Now let us consider the information that is given to you when an event occurs
for a goal you are interested in. First of all, the goal itself is shown, together with an
indication of which kind of event has occurred and perhaps an invocation number. If
tracing for this event type is unleashed, this is all that is provided. Otherwise, Prolog
will also ask you to specify one of a set of options about what should be done next.
A session with exhaustive, unleashed tracing would look something like:
    ?- [user].
    append([],Y,Y).
    append([A|B],C,[A|D]) :- append(B,C,D).
    /* type the end of file character here */
```

*yes*

```prolog
?- append([a],[b],X).
```

*CALL append ([a], [b],_43)* *CALL append ([],[b],_103)* *EXIT append([],[b],[b])* *EXIT append ([a] r [b],[a r b])* *X = [a,b] ;* *REDO append([a],[b], fab])* *REDO append ([J, [b], [b])* *FAIL append ([] r [b] r _103)* *FAIL append} [a] r [b],_43)* *no*

```prolog
?- append(X,Y,[a]).
```

*CALL append(_37,_38, [a])* *EXIT append([] r [a],[a])* *X=[],*

<!-- page 217 -->
*Y=[a];* *REDO append([],[a] r [a])* *CALL append(_93,_38,[])* *EXIT append ([],[],[])* *EXIT append ([a], [], [a])* *X=[a],Y=[];* *REDO append ([a], [], [a])* *REDO append ([], [], [])* *FAIL append(_93,_38, [])* *FAIL append (_3 7,_38,[a])* *no*

```prolog
Here, all four events for all goals are being shown on the display. However, the
programmer is not given any chance to make the program pause at any point, change
the amount of tracing half way through, or affect the way it runs in any other way.
These facilities are what leashed tracing provides.
    Before we go on to discuss leashed tracing, we should make some remarks
about how Prolog shows your goals when you are tracing. Now, actually the way
your goals are shown by the tracing facilities is not necessarily the same as if they
were output using write. This is because you are allowed to provide your own special
purpose definitions for showing the goals in your program. You can use this facility
to output some of the common structures used in your program in ways that are
clearer or more concise than write would normally produce. The way the facility
works is as follows. The standard way of printing your goals is actually by using the
built-in predicate print, with one argument. Predicate print works as if it is defined
as follows:
    print(X) :- portray(X), !.
    print(X) :- write(X).
Now, the predicate portray is not a built-in predicate, and so you can provide clauses
for it yourself. If your clauses allow the goal portray(X) to be satisfied for one of
your goals X, then it will be assumed that that provides all the necessary output.
Otherwise, the goal will be output using write instead. So if for some reason you did
not want to ever see the third arguments of append goals, you could make sure of
this by providing the clause:
    portray(append(A, B, C)) :-
            write('append('), write(A), write(','),
            write(B), write(7),
            write('<foo>)').
Whenever a goal X involving append occurs, this clause will cause the goal portray(X)
to succeed, and so it will provide the only output. For a goal involving any other
predicate, portray(X) will fail, and X will be output using write. If the above clause
was in the database, part of the above example session would look like the following:
    ?- append([a],[b],X).
```

<!-- page 218 -->
*CALL append([a], [b],<foo>)* *CALL append([],[b],<foo>)* *EXIT append(U,[b],<foo>)* *EXIT append ([a],[b], <foo>)* *X=[a,b] ;* *REDO append ([a], [b],<foo>)* *REDO append([],[b],<foo>)* *FAIL append([],[b],<foo>)* *FAIL append([a], [b],<foo>)* *no*

```prolog
Now for a discussion of leashed tracing. If you have specified leashed tracing for
events of some type you will be asked to specify what should be done next when an
event of this type occurs. This will look something like the following at the terminal:
    ?- append([a], [b], X).
```

*CALL append([a],[b],_43) ?*

```prolog
The program stops after typing out the "?". You are now supposed to reply by speci-
fying one of a set of possible options. If the option you specify involves the program
continuing as usual, it will then run on as far as the next leashed event for a predicate
being traced, and again ask you, with something like:
```

*CALL append([],[b],_103) ?*

```prolog
There is likely to be an option to display a list of available options at the terminal.
Here are some of the options that may be available:
```

### 8.4.1 Examining the Goal

```prolog
The first set of options involve looking at the goal in various ways. As we have seen,
the standard is for a goal to be shown using print, which gives your portray clauses a
chance to show things in a special way. However, you may start to have doubts about
the correctness of your portray clauses, or just want to see a goal written in the normal
way for a change. Hence Prolog will allow you to either write or write_canonical the
current goal as a possible option. In this case, the program will not run any further,
but you will be asked for another option that will specify how the program should
continue. A typical interaction might be:
    ?- append([a], [b], X).
```

*CALL append([a],[b],<foo>)*

*?*

```prolog
write
```

*CALL append}[a], [b],_103) ?*

```prolog
Usually you will only want to use write as an alternative way of looking at a goal. You
might want to use write_canonical when the goal involves many operators, and you
have forgotten what their various precedences are. In such a case, write_canonical
will enable you to see the nesting of functors unambiguously.
```

<!-- page 219 -->
### 8.4.2 Examining the Ancestors

```prolog
The ancestors of a goal are those goals to which its satisfaction will eventually con-
tribute. In our box diagrams, these are the goals whose boxes enclose the goal under
consideration. Thus every goal has an ancestor which is one of the goals in the orig-
inal question, the one that it is helping to satisfy. Also, whenever a rule is used, each
of the goals introduced by the rule body has as an ancestor the goal that matched the
rule head. Let us look at some examples of ancestors. Consider the following simple
program to reverse a list (described in Section 7.5):
    rev([], []).
    rev([H|T], L) :- rev(T, Z), append(Z, [H], L).
    append([], X, X).
    append([A|B], C, [A|D]) :- append(B, C, D).
If we ask the initial question:
    ?- rev([a,b,c,d], X).
                                                                (A)
then, because of the second clause of rev, there will be two subgoals to satisfy. Each
of these has the goal in the question as its immediate ancestor. The subgoals are:
    rev([b,c,d], Z)
                                                                (B)
    append(Z, [a], X).
                                                                (C)
Since the second clause will be used again to satisfy (B), again two subgoals will be
introduced:
    rev([c,d], Zl)
                                                                (D)
    append(Zl, [a], Z)
                                                                (E)
Each of (D) and (E) has both (A) and (B) as ancestors. Note that goal (Q is not an
ancestor of these, because they are only contributing immediately to the satisfaction
of (B), which contributes to the satisfaction of (A). Goals (D) and (E) are not con-
tributing in any way to the satisfaction of (C). When the satisfaction of this question
has progressed fairly far, a goal of the form:
    append([c], [b], Y)
will appear. At this stage, the goal and its ancestors might be displayed as follows:
```

*This is Goal A.*

```prolog
rev([a,b,c,d], _46)
rev([b,c,d], [d|_50])
```

*This is Goal B.*

```prolog
appended,c], [b], [d|_51])
append([c], [b], _52)
```

<!-- page 220 -->
```prolog
Before you read any further, you should make sure that you understand why these
are all ancestors of the goal, and why there are not any more ancestors. There is
one peculiarity with the way the ancestors are shown here, which may be reflected in
your Prolog system. There are two possible ways of printing out an ancestor: as it was
when an attempt was first made to satisfy it, or as it stands now, with any variables as
they are now instantiated. Here we have adopted the second course. When the goal
(B) was first encountered, the second argument of rev was uninstantiated. However,
that argument is shown with a value in the ancestor list. This is because by now the
variable that was in that position has become instantiated. By now we have found out
that the first element of the reverse of [b,c,d] is d.
    By looking at the ancestors of the current goal, you can get a fair idea what
your program is up to, and why is is doing what it is. One of the options that a Prolog
system may provide at a leashed event for a goal is for some of the current ancestors
to be printed out. So if your program seems to be spending a lot of time somewhere
and you suspect that it may be in a loop, a good strategy is to interrupt the execution,
turn on full tracing and then take a look at the ancestors to see where you are.
```

### 8.4.3 Altering the Degree of Tracing

```prolog
Another set of options that may be available at a leashed event concerns changing
how much tracing is going on. Some of the more coarse controls that you can exercise
are:
•
   Removing all spy points. This has the same effect as invoking the goal nodebug.
•
   Turning exhaustive tracing off. This has the same effect as invoking the goal
   notrace.
•
   Turning exhaustive tracing on. This has the same effect as invoking the goal trace.
The goals nodebug, notrace and trace were all described in Section 6.13.
    With all of these, your program will subsequently carry on running until it
reaches a goal that you wish to trace, given your new conditions. Depending on what
version of Prolog you use, more local controls of tracing may be available. These
help you quickly to get over bits of the program's execution that are of little interest,
so that you can concentrate on where the bugs seem to be. Possible options here are:
•
   "creep": Carry on with the program, doing exhaustive tracing, until you are
   prompted again (at the next leashed event).
•
   "skip": Carry on with the program, and produce no trace messages at all until
   another event occurs involving the current goal.
```

<!-- page 221 -->
```prolog
•
   "leap": Carry on with the program, producing no trace messages until either a
   spy point is reached or an event occurs involving the current goal.
The first of these is what you will want to use if you want to follow the program
closely at this point. The second is used when you are not worried about how a
certain goal is satisfied, and just want to move on quickly to what happens afterwards.
The third is used when there may be a lot of uninteresting work going on in the
satisfaction of a goal, but somewhere in the middle a goal that is of interest (which
has a spy point) will occur. Hence you want to ignore everything until either that
spy point is reached or (if the program is faulty) if the current goal succeeds or fails
without ever reaching the spy point. Here is an example of the use of "creep" and
"skip". Let us assume that there is a bug in the naive sort program given in Section
7.7, but that we are confident that our program to generate permutations is all right.
If you remember, the definition of sort started as follows:
    sort(X, Y) :- permutation(X, Y), sorted(Y), !.
We can use the "skip" option to avoid having to look at the gory details of how
permutation works, and produce a trace that starts as follows:
```

*CALL sort([3,6,2,9,20],_45)*

*?*

```prolog
creep
```

*CALL permutation([3,6,2,9,20],_45)*

*?*

```prolog
skip
```

*EXIT permutation ([3,6,2,9,20], [3,6,2,9,20]) ?*

```prolog
creep
```

*CALL sorted([3,6,2,9,20]) ?*

```prolog
creep
```

*CALL sorted(0,[3,6,2,9,20])*

*?*

```prolog
creep
```

*CALL 0<3 ?*

```prolog
...and so on.
```

### 8.4.4 Altering the Satisfaction of the Goal

```prolog
The following options enable you to alter how your program works. You can use
these to repeat things that you want to look at in more detail, avoid choices which
you know to be irrelevant and force the program to consider choices that it might not
otherwise find. These can greatly speed up debugging, because they mean that you
can subject the difficult parts of the program to repeated scrutiny without having to
run the whole thing again.
•
   "retry": If you specify the option "retry" at an event for some goal, Prolog will
   go back to where it was when it originally CALLed the goal. Everything will be
   exactly as it was when the goal was first encountered (except for any additions
   to the database that may have been made). Hence you can look at what happens
   in the satisfaction of the goal once again. A common technique is to combine the
   use of the "retry" and "skip" options. If you are not sure whether a bug occurs
```

<!-- page 222 -->
```prolog
   in the satisfaction of some goal, you can "skip" over its satisfaction to start with.
   This means that you will not have to wade through lots of output about a goal
   that is satisfied completely correctly. If there is a bug, and the goal either fails or
   produces the wrong result, you can afterwards use the "retry" option to go back
   and look more closely.
•
   "or": This option is just like the EE) you type in to ask for alternative solutions to
   a question. If you are at an EXIT for a goal, you can also ask for alternatives. So
   if you know that the first answer found will not allow the rest of the program to
   succeed, you can immediately ask for another solution to be found. This means
   that you will be able to get more quickly to the part of the program that has the
   bug. The alternative would be to have to watch the eventual failure after the first
   alternative was found.
•
   "fail": This is mainly to be used at a C A L L event for a goal. If you know that
   the goal is going to fail eventually, and the goal is of no interest to you, you can
   cause it to fail immediately by using this option.
Here is an example of these various options being used to move around the satisfac-
tion of the question:
    ? member(X,[a,b,c]), member(X,[d,c,e]).
```

*CALL member(_44, [a,b,c]) ?*

```prolog
creep
```

*EXIT member (a,[a,b,c]) ?*

```prolog
or
```

*REDO member (a, [a,b,c]) ?*

```prolog
creep
```

*CALL member(_44,[b r c]) ?*

```prolog
fail
```

*FAIL member(_44,[b,c]) ?*

```prolog
creep
```

*FAIL member(_44 r [a,b,c]) ?*

```prolog
retry
```

*CALL member(_44,[a,b,c]) ?*

```prolog
creep
```

*EXIT member(a,[a,b,c]) ?*

```prolog
creep
```

*CALL member (a, [d,c,e]) ?*

```prolog
fail
```

*FAIL member(a, [d,c,e]) ?*

```prolog
creep
```

*REDO member(a,[a,b,c]) ?*

```prolog
creep
```

*CALL member(_44,[b,c]) ?*

```prolog
creep
```

*EXIT memberfb, [b,c]) ?*

```prolog
or
```

*REDO member(b,[b,c]) ?*

```prolog
creep
```

*CALL member(_44,[c]) ?*

```prolog
fail
```

*FAIL member(_44,[c]) ?*

```prolog
retry
```

*CALL member(_44,[c]) ?*

```prolog
creep
```

*EXIT member(c,[c]) ?*

```prolog
creep
```

*EXIT member(c,[b,c]) ?*

```prolog
creep
```

*EXIT member(c, [a,b,c]) ?*

```prolog
creep
```

*CALL member(c,[d,c,e]) ?*

```prolog
creep
```

<!-- page 223 -->
*CALL member(c,[c,e]) ?*

```prolog
creep
```

*EXIT member(c, [c,e]) ?*

```prolog
creep
```

*EXIT member(c,[d,c,e]) ?*

```prolog
or
```

*REDO member(c,[d,c f e]) ?*

```prolog
creep
```

*REDO member(c,[c,e]) ?*

```prolog
creep
```

*CALL member(c,[e]) ?*

```prolog
creep
```

*CALL member(c,U) ?*

```prolog
creep
```

*FAIL member(c,[]) ?*

```prolog
creep
```

*FAIL member(c,[e]) ?*

```prolog
creep
```

*FAIL member(c,[c,e]) ?*

```prolog
retry
```

*CALL member(c,[c,ej)* `?`

```prolog
creep
```

*EXIT member(c, [c,e]) ?*

```prolog
creep
```

*EXIT member(c,[d,c,e]) ?*

```prolog
creep
```

### 8.4.5 Other Options

```prolog
Other options that may be open to you at a leashed event are:
•
   "break": This causes the current execution to be suspended and a new copy of the
   Prolog interpreter to be made available to you. You can use this to ask questions
   about what clauses you have, to set spy points, or anything else that you want.
   When you exit from the interpreter (by typing the end-of-file character), your
   previous program will be resumed.
•
   "abort": This causes all your current running programs to be abandoned, and you
   get "thrown back" to the Prolog interpreter, ready to give the next question.
•
   "halt": This causes you to leave Prolog completely. You might want to use this
   as soon as you discover a bug, because you want to edit a file that contains the
   bugridden program.
```

### 8.4.6 Summary

```prolog
In conclusion then, there are three things to think about when you start to look at
your program as it runs:
 1. Which goals do you want to look at? If you look at everything (use exhaustive
   tracing with trace), you may become overwhelmed by the amount of informa-
   tion that appears on your terminal. On the other hand, if you just look at what
   happens to a few predicates (setting spy points with spy), you may miss where
   the program is going wrong. The best solution is probably a compromise, with
```

<!-- page 224 -->
```prolog
  careful use of spy points to narrow down the search, and then exhaustive tracing
   at the end to isolate the bug.
2. How much do you want to control the program's progress from the terminal?
  If you have all event types unleashed, you will have no control at all over the
  program, which will rapidly run past the faulty bits before you can notice and
  look in more detail. On the other hand, if you have all event types leashed, you
  will get thoroughly fed up telling the program to keep going at each event.
3. Do you want to provide special output facilities for your goals? This will be
  useful if some of the goals will contain huge structures of little interest, which
   will only distract from the arguments that you are really interested in. In this
   case, you can provide a portray facility that suppresses this information.
```

## 8.5 Fixing Bugs

```prolog
When you have watched your faulty program working and discovered something
wrong with it, you will want to fix the bug and try the program again. Assuming that
your program is of a reasonable size, you will already have it stored in disc files. At
this point, you will need to use an editor program to change what is in those files.
There are two possibilities now:
 1. Your computer system may allow you to use an editor and then return to Prolog
   with exactly the same database as before. You may be able to do this directly,
   e.g. by running the editor in a different window and then returning to the Prolog
   program. Alternatively, Prolog may allow you to save the current state of the
   database in a special file and then restore it again later. You then save your current
   state, exit from Prolog, change your program, run Prolog again and restore the
   previous database state. Having returned to where you were before, but with one
   or more program files changed, all you need to do is consult these files again to
   replace the old definitions with new ones.
 2. If your Prolog system does not allow you to return to a previous state after using
   an editor, after changing your program files you will have to run Prolog and
    consult all your program files from scratch.
You can make this process easier by having a single file containing commands to
Prolog to consult all the files of your program. You can then read in the whole pro-
gram by just asking Prolog to consult the first file. For instance, if you asked Prolog
to consult a file containing:
    ?- [filel, file2, file3].
```

<!-- page 225 -->
```prolog
    ?- [file4, file5, file6].
then as a result each of filel, file2, file3, file4, file5, file6 will be read in.
    In some circumstances, the change to your program may seem so minimal that
you can enter it from the terminal, by a consult(user). However, you should beware
of doing this too often. If you are not careful, you will forget all the little changes
you have made this way and run across the same bugs when you run your program
in a later session. Also, since you will want eventually to incorporate the changes
into your program files, it is rather a waste to have to type them in at the terminal as
well. So do not be tempted into entering clauses from the terminal by the prospect of
getting the program to work quickly.
    To show how consult can be used to change a program from the terminal, here
is a small example session where this is done by a particularly careless programmer.
The session starts with the programmer having no clauses in the database, so he
enters some from the keyboard...
    ?- consult(user).
    append([A)B], C, [A|D]):- append(A, C, D).
    append([], X, X).
    reverse([], []).
    reverse([A)B], C) :- reverse(B, D), append(D, [A], C).
    /* the end of file character is typed here*/
```

*yes*

```prolog
Now the programmer tries some goals...
    ?- reverse([a,b,c,d,e], X).
```

*no*

```prolog
?- append([a,b,c,d,e], [f], X).
```

**no**

```prolog
?- append([], [a,b,c], X).
```

*X = [a,b,c]* *yes*

```prolog
It doesn't seem to be working. Try redefining append.
    ?- consult(user).
    append([A|B], C, [A|D]):- append(B, C, D).
    /* the end of file character is typed here */
```

<!-- page 226 -->
*yes*

```prolog
Now try again...
    ?- reverse([a,b,c,d], X).
```

*no*

```prolog
Now reverse doesn't work. Try a longer definition...
    ?- consult(user).
    append([], X, X).
    append([A|B], C, [A|D]) :- append(B, C, D).
    /* the end of file character is typed here */
```

*yes*

```prolog
Now try again...
    ?- reverse([a,b,c,d,e], X).
```

*X = [e,d,c,b,a]* *yes*

```prolog
In this session, the programmer starts by entering clauses for the predicates append
and reverse from the terminal. Of course, the programmer could have typed these
into a file first and then told Prolog to consult that file, but for an example of this
small size that might not have been worthwhile. Unfortunately, there is a mistake
in the first clause for append. The goal contains an A where there should be a B.
This mistake is revealed when the system cannot answer the append and reverse
questions. Somehow, the programmer realises that the definition of append is wrong
(in a real session, this would probably happen after use was made of the debugging
aids). So he decides to replace his existing definition with a new one, using consult.
Unfortunately, in the new definition, he forgets to specify the boundary condition (the
[] case). So the program still does not work. At this point, the original two-clause
definition of append has been replaced by a new one-clause definition, which is not
complete. The programmer sees what he has done, and can rectify the situation by
simply adding a new clause to the existing definition. This is achieved with another
use of consult. The program now works.
    In conclusion, when you are making changes to a program, exercise the same
care that you take when you write the first version of a program. Make sure that what
you add is still compatible with your conventions about which variables should be
instantiated when and what arguments are used for what purposes. Above all, take
the opportunity to look over the program again: there may be some other mistakes in
it!
```
