# 4 Backtracking and the "Cut"

<!-- page 87 -->
Let us summarise what we learned in Chapters 1 and 2 about what can happen to a goal:

1. An attempt can be made to satisfy a goal. When we satisfy a goal, we search the database from the top. Two things can happen:

a) A unifying fact (or rule head) can be found. In this case, we say the goal

has been matched. We mark the place in the database, and instantiate any

previously uninstantiated variables that have unified. If we matched against

a rule, we shall first have to attempt to satisfy the subgoals introduced by

the rule. If the goal succeeds, we then attempt to satisfy the next goal. In our

diagrams, this is the goal in the next box below the arrow. If the original goal

appears in a conjunction, this will be the goal to its right in the program.

b) No unifying fact (or rule head) can be found. In this case, we say the goal has

failed. We then attempt to re-satisfy the goal in the box above the arrowhead.

If the original goal appears in a conjunction, then this will be the goal on its

left in the program.

<!-- page 88 -->
2. We can attempt to re-satisfy a goal. First of all, we attempt to re-satisfy each of the subgoals in turn, the arrow retreating up the page. If no subgoal can be re-satisfied in a suitable way, we attempt to find an alternative clause for the goal itself. In this case, we must make uninstantiated any variables that became instantiated when the previous clause was chosen. This is what we mean by "undoing" all the work previously done by this goal. Next, we resume searching the database, but we begin the search from where the goal's place-marker was previously put. As before, this new "backtracked" goal may either succeed or fail, and either step (a) or (b) above would occur. This chapter will look at backtracking in more detail. It will also look at a special mechanism that can be used in Prolog programs: the "cut". The cut allows you to tell Prolog which previous choices it need not consider again.

## 4.1 Generating Multiple Solutions

The simplest way a set of facts can allow multiple solutions to a question is when there are several facts that will match against the question. For instance, if we have the following facts in which father(X, Y) means that the father of X is Y:

```prolog
father(mary, george).
father(john, george).
father(sue, harry).
father(george, edward).
```

The question

```prolog
?- father(X, Y).
```

will have several possible answers. If we prompt with a semicolon, Prolog will give us the following:

*X=mary, Y=george*

*X=john, Y=george*

*X=sue, Y=harry*

*;*

*X=george, Y=edward* It finds these answers by searching through the database to find the facts and rule about father in the order in which they were given. Prolog is not particularly clever about this. It does not remember anything about what it has shown before. So if we ask

```prolog
?- father(_, X).
```

(for which X is X a father?) we will get:

*X=george*

*X=george*

*X=harry*

<!-- page 89 -->
*X=edward* with *george* repeated twice because George is the father of both Mary and John. If Prolog has two ways of showing the same thing, it treats them as two different solutions.

Backtracking happens in exactly the same way if the alternatives are embedded more deeply in the processing. For example, one rule in a definition of "one of the children of X is Y" might be

```prolog
child(X, Y) :- father(Y, X).
```

Then, the question

```prolog
?- child(X, Y).
```

would give

*X=george, Y=mary*

*;*

*X=george, Y=john*

*;*

*X=harry, Y=sue*

*X-edward, Y=george* Because father(Y, X) has four solutions, so does child(X, Y). Moreover, the solutions are generated in the same order. All that is different is that the order of the arguments is different, as is specified in the definition of child. Similarly, if we defined father(X) meaning that X is a father,

```prolog
father(X) :- father(_, X).
```

then the question

```prolog
?- father(X).
```

would evoke:

*X=george*

*X=george*

*X=harry*

*X=edward* If we mix facts and rules, the alternatives follow again in the order in which things are presented. Thus we might represent that adam is a person, anything is a person if it has a mother, and eve is a person. Also, various people have various mothers:

```prolog
person(adam).
person(X) :- mother(X, Y).
person (eve).
mother(cain, eve).
mother(abel, eve).
mother(jabal, adah).
mother(tubalcain, zillah).
```

In this case, if we asked the question

```prolog
?- person(X).
```

<!-- page 90 -->
the answers would be: *X=adam* *X=cain*

*;* *X=abel* *X=jabal* *X=tubalcain*

*;* *X=eve* Let us look now at a more interesting case where there are two goals, each of which has several solutions. Let us imagine we are planning a party and want to speculate about who might dance with whom. We can start writing a program as follows: possible_pair(X, Y) :- boy(X), girl(Y). boy(john). boy(marmaduke). boy(bertram). boy(charles).

```prolog
girl(griselda).
```

girl(ermintrude). girl(brunhilde). This program says that X and Y form a possible pair if X is a boy and Y is a girl. Now let's see what possible pairs there are: ?- possible_pair(X, Y). *X = john, Y = griselda* *X = john, Y = ermintrude* *X = john, Y = brunhilde* *X = marmaduke, Y = griselda*

*;* *X = marmaduke, Y = ermintrude*

*;* *X = marmaduke, Y = brunhilde*

*;* *X = bertram, Y = griselda*

*;* *X = bertram, Y = ermintrude* *X = bertram, Y = brunhilde* *X = charles, Y = griselda*

*;* *X = charles, Y = ermintrude*

*;* *X = charles, Y = brunhilde*

<!-- page 91 -->
You should make sure that you understand why Prolog produces the solutions in this order. First of all, it satisfies the goal boy(X), finding john, the first boy. Then it satisfies girl(Y), finding griselda, the first girl. At this point, we ask for another solution by typing ";" to cause backtracking. Prolog attempts to re-satisfy what it did last, which is the girl goal within the satisfaction of the possible_pair goal. It finds the alternative girl ermintrude, and so the second solution is john and ermintrude. Similarly, it generates john and brunhilde as the third solution. The next time it tries to re-satisfy girl(Y), Prolog finds that its place-marker is at the end of the database, and so the goal fails. Now it tries to re-satisfy boy(X). The place-marker for this was placed at the first fact for boy, and so the next solution found is the second boy (marmaduke). Now that it has re-satisfied this goal, Prolog looks to see what is next: it must now satisfy girl(Y) from the start again. So it finds griselda, the first girl. The next three solutions now involve marmaduke and the three girls. Next time we ask for an alternative, the girl goal cannot be re-satisfied again. So another boy is found, and the search through girls starts again from scratch. And so on. Eventually, the girl goal fails and there are also no more solutions to the boy goal either. So the program can find no more pairs.

These examples are all very simple. They just involve the specification of many facts or the use of rules to access those facts. Because of this, they can only generate a finite number of possible solutions. Sometimes we might want to generate an infinite number of possibilities: not because we want to consider them all, but because we may not know in advance how many we need. In this case we need a recursive definition (discussed in the previous chapter).

Consider the following definition of what it is to be a positive integer1. The goal is_integer`(N)` will succeed providing `N` is instantiated to a positive integer. If `N` is not instantiated at the time the goal is considered, then an is_integer`(N)` goal will cause a positive integer to be chosen, and `N` will be instantiated to it:

/* 1 */

```prolog
                  is_integer(0).
/* 2 */
                  is_integer(X):- is_integer(Y), X is Y + 1.
```

If we ask the question

```prolog
?- is_integer(X).
```

we will get as the possible answers all the integers in ascending order (0, 1, 2, 3, ...), one at a time. Each time we force backtracking to occur (perhaps by typing semicolon), is_integer will succeed with its argument instantiated to a new integer. So in principle this short definition generates an infinite number of answers. Why? The sequence of events that leads to the first three solutions is shown in Figures 4.1, 4.2, and 4.3.

1 By positive integer w e mean a whole number not less than 0. You should satisfy yourself

<!-- page 92 -->
that there are an infinite number of these.

Fig. 4.1. The first solution

Fig. 4.2. The second solution

<!-- page 93 -->
At each stage, the lowest (1) is where another choice will be made next. Initially, we have a choice between fact 1 and rule 2 to answer the question. If we choose fact 1, no more choices have to be made, and we get *X=0.* Otherwise we choose rule 2 and have a choice how to satisfy the goal it introduces. If we choose fact 1, we end up with the answer *X=l;* otherwise we use rule 2 and must again choose how to satisfy the subgoal produced. And so on. At each stage, the first thing Prolog does is to pick fact 1. Only on backtracking does it undo the last choice. Each time it does this, it goes back to where it last chose fact 1, and instead chooses rule 2. Once it has decided to use rule 2, a new subgoal is introduced. Fact 1 is the first possibility for satisfying it.

<!-- page 94 -->
Most Prolog rules will give rise to alternative solutions if they are used for goals that contain a lot of uninstantiated variables. For instance, the relation of membership of a list (from Chapter 3):

```prolog
member(X, [X|_]).
member(X, [_|Y]) :- member(X, Y).
```

will generate alternatives. If we ask

```prolog
?- member(a, X).
```

(notice X in the question is uninstantiated) then the successive values of X will be partially-defined lists where a is the first, second, third, (and so on) member. See if you can see why this is.

A further result of allowing this definition of member to backtrack is that the question

```prolog
?- member(a, [a,b,r,a,c,a,d,a,b,r,a]).
```

actually can succeed five times. Clearly, there are some applications of member where we only need it to succeed once, if at all, and then discard the other four choices. We can tell Prolog to discard choices in this way by using the "cut".

## 4.2 The "Cut"

This section looks at a special mechanism that can be used in Prolog programs the "cut". The "cut" allows you to tell Prolog which previous choices it need not consider again when it backtracks though the chain of satisfied goals. There are two reasons why it may be important to do this:

- Your program will operate faster because it will not waste time attempting to satisfy goals that you can tell beforehand will never contribute to a solution;

- Your program may occupy less of the computer's memory space because more economical use of memory can be made if backtracking points do not have to be recorded for later examination.

In some cases, including a "cut" may mean the difference between a program that will run and a program that will not.

Syntactically, a use of "cut" in a rule looks just like the appearance of a goal which has the predicate "!" and no arguments. As a goal, this succeeds immediately and cannot be re-satisfied. However, it also has side-effects which alter the way backtracking works afterwards. The effect is to make inaccessible the place markers for certain goals so that they cannot be re-satisfied.

<!-- page 95 -->
Let us see how this works in an example. Imagine that you are running a library and have a Prolog database containing information about what books there are, who has borrowed what, and when books are due back. One thing you might be concerned about is which of the library facilities should be open to which people. Some facilities, which we might call basic facilities, should be open to everyone. These include the use of the reference library and the enquiries desk. On the other hand, the library might want to be selective about which people are allowed to use additional facilities, such as actually borrowing books or using inter-library loans. One rule that might be made is that, if a person has a book overdue, then the additional facilities will not be available to the person until the book is returned. Here is part of a program that uses this rule:

```prolog
facility(Pers, Fac) :-
    book„overdue(Pers, Book),
    i
    basic_facility(Fac)
facility(Pers, Fac) :- general_facility(Fac).
basic_facility( reference).
basic_facility(enquiries).
additional_facility(borrowing).
additional_facility(inter_library_loan).
general_facility(X) :- basic_facility(X).
generaLfacility(X) :- additionaLfacility(X).
```

Then we need a database of clients and their borrowing habits, of which only two are shown here:

```prolog
client('A. Jones').
client('W. Metesk')
book_overdue('C. Watzer', bookl0089).
book_overdue('A. Jones', book29907).
```

Why is there a cut in this program and what effect does it have? Let us assume that we wish to run through all our clients and find out what facilities are open to them. Thus we give Prolog the question:

```prolog
?- client(X), facility(X, Y).
```

<!-- page 96 -->
Prolog will start by finding the first client, 'A. Jones'. Let us assume that this client has several overdue books. In order to find what facilities are open to him, Prolog will start by using the first clause for facility. This introduces a new goal to see whether he has any overdue books. After a short search among the book_overdue facts, the fact about the first overdue book for A. Jones is found (the second fact for

Fig. 4.4. Just before the cut is encountered

<!-- page 97 -->
this predicate). The next goal encountered is the "cut". This goal succeeds, and the effect is to commit the system to all the decisions made since the first facility clause was chosen. We can show the situation just before the cut is encountered in a diagram as shown in Figure 4.4. When the cut is encountered, it "cuts" the flow of satisfaction line so that if it is forced to retreat beyond this point it will have to take a short cut, as seen in Figure 4.5. Fig. 4.5. The cut commits to the solutions so far, but the flow of satisfaction is altered so that if basic_facility fails, then backtracking takes a shortcut to re-satisfy the client goal

The effect of the cut in the facility rule (clause 1) is to commit the system to every choice it has made since it chose that rule. The flow of satisfaction path has been changed so as to avoid all the place markers between the facility goal and the cut goal inclusive. Thus if backtracking later causes a retreat back past this point, the facility goal will immediately fail.

<!-- page 98 -->
Because of the cut, the system will not consider alternative solutions for the goal book_overdue('A. Jones', Book). This is quite reasonable as we are only interested in whether the client has *any* overdue book, not what *all* the books are. Neither will the system consider clause 2 for facility, because the choice of the rule that the cut appears in is also bypassed on backtracking. This is again reasonable here, because we don't want to generate solutions that say that all facilities are open to A. Jones. In summary, the effect of the cut in this example is to say:

*If a client is found to have an overdue book, then only allow the client the*

*basic facilities of the library. Don't bother going through all the client's*

*overdue books, and don't consider any other rule about facilities.* In this example, the cut committed the system to all the decisions made from it back to the facility goal. This is called the *parent goal* of the cut goal, because it is the goal that caused the use of the rule containing the cut. In our diagrams, the parent goal is always the goal whose box is the smallest one enclosing the "!" box. The formal definition of the effect of the cut symbol is as follows:

When a cut is encountered as a goal, the system thereupon becomes

committed to all choices made since the parent goal was invoked.

All other alternatives are discarded. Hence an attempt to re-satisfy

any goal between the parent goal and the cut goal will fail.

There are several ways of describing what has happened to the choices that are affected by a cut. One can say that the choices are cut or frozen, that the system commits itself to the choices made or that the alternatives are discarded. One can also look at the cut symbol as being rather like a fence that separates goals. In this conjunction of goals,

```prolog
foo :- a, b, c, !, d, e, f.
```

Prolog will quite happily backtrack among goals a, b, and c, *until* the success of; c causes the "fence" to be crossed to the right to reach goal d. Then, backtracking: can occur among d, e, and f, perhaps satisfying the entire conjunction several times. However, if d fails, causing the "fence" to be crossed to the left, then no attempt will be made to re-satisfy goal c: the entire conjunction of goals will fail, and the goal foo will also fail.

<!-- page 99 -->
One further note before we go on to see more examples of the cut in use. We \ have said that if the cut appears in some rule and the cut goal is satisfied then Pro-; log becomes committed to all choices made since the parent goal was invoked. This < means that the choice of that rule, and all other choices made since then, become fixed. We will see later that it is possible to provide alternatives within a single rule using the built-in predicate ";" (meaning "or"). The choices introduced by this facility are affected in exactly the same way. That is, when a cut goal is satisfied, all "or" choices that have been made since the rule was chosen are fixed.

## 4.3 Common Uses of the Cut

We can divide the common uses of "cut" into three main areas:

- The first concerns places where we want to tell the Prolog system that it has found the right rule for a particular goal. Here, the cut says, "if you get this far, you have picked the correct rule for this goal."

- The second concerns places where we want to tell the Prolog system to fail a particular goal immediately without trying for alternative solutions. Here, we use the cut in conjunction with the `fail` predicate to say, "if you get to here, you should stop trying to satisfy this goal."

- The third concerns places where we want to terminate the generation of alternative solutions through backtracking. Here, the cut says, "if you get to here, you have found the only solution to this problem, and there is no point in ever looking for alternatives."

We will now look at some examples of these three uses. You should bear in mind, however, that the cut has a single meaning in all these applications. The division into three main areas of use is purely for tutorial reasons, and to show what kinds of reasons you might have for putting cuts into your programs.

### 4.3.1 Confirming the Choice of a Rule

Often in a Prolog program, we wish to associate several clauses with the same predicate. One clause will be appropriate if the arguments are of one form, another will be appropriate if the arguments are of another form, and so on. Often we can specify which rule should be used for a given goal by providing patterns in the rule heads that will only match goals of the right types. However, this may not always be possible. If we cannot tell in advance what forms the arguments may take, or if we cannot specify an exhaustive set of patterns, we may have to compromise. This means giving rules for some specific argument types and then giving a "catchall" rule at the end for everything else.

As an example of this, consider the following program. The rules define the predicate `sum_to` such that giving Prolog the goal `sum_to(N,` X) with `N` having an integer value, causes X to be instantiated to the sum of the numbers from 1 to N. Thus, for instance, it produces the following:

```prolog
?- sum_to(5, X).
X = 15
```

<!-- page 100 -->
*no*

because 1+2+3+4+5 is 15. Here is the program.

```prolog
sum_to(l, 1) :- !.
sum_to(N, Res) :-
        N1 is N - 1,
        sum_to(Nl, Resl),
        Res is Resl + N.
```

This is a recursive definition. The idea is that the boundary condition occurs wherf the first number is 1. In that case, the answer is also 1. The second clause introduce! a recursive sum_to goal. However, the first number of the new goal is one less thai the original one. The new goal that this goal will invoke will have its first argumen one less again. And so on until the boundary condition is reached. Since the firs arguments are always getting smaller, the boundary condition must be reached even tually (assuming that the original goal has a first argument not less than 1), and th program will terminate.

j

The interesting thing about this program is how we have handled the two cases when the number is 1, and when it is something else. When we defined predicate that talked about lists, it was easy to specify the two cases that would normally arisj when the list was [] and when it was of the form [A | B]. With numbers, things ar not so easy, because we cannot specify a pattern that will only match an integer n<j equal to 1. The solution adopted in this example is to provide a pattern for the "I

```prolog
't
```

case and just to leave a variable to match against anything else. We know from th way Prolog searches through the database that it will try to match the number again! 1 first and will only try the second rule if this fails. So the second rule should oni be used for numbers not equal to 1.

J

However, this is not the whole story. If Prolog ever backtracks and comes t| reconsider the choice of rule when applied to the number 1, it will find that tl| second rule is applicable. As far as it can see, both rules provide alternatives for tl) goal sum_to(l, X). We must tell it that on no account is the second rule ever to h tried if the number is 1. One way of doing this is to put a cut in the first rule (a|| shown). This tells Prolog that, once it has got this far in the first rule, it must neve* remake the decision about which rule to use for the sum_to goal. It will only get this far if the number is in fact 1. Let us see what this looks like in terms of the flow oI satisfaction. If we call sum_to(l,X) in the context:

```prolog
go :- sum_to(l, X), foo(apples).
?- go.
```

<!-- page 101 -->
```prolog
go
```

(1)

```prolog
                     Fig. 4.6. The goal foo(apples) fails
and the goal foo(apples) fails, then at the point of failure we will have the situation
shown in Figure 4.6.
When Prolog tries to re-satisfy the goals in reverse order, it will find that two of the
goals cannot be re-satisfied because the flow of satisfaction path has been re-routed.
Hence it will correctly avoid trying alternative ways of satisfying sum_to(l,X).
Exercise 4.1: What happens if the "cut" is left out here and backtracking gets round
to reconsidering the sum_to goal? What alternative results, if any, are produced, and
```

why?

```prolog
    The last example showed how "cut" can be used to make Prolog behave sensibly
when we cannot distinguish between all the possible cases by specifying patterns in
the heads of the rules. A more usual situation in which we cannot specify patterns to
decide which rule to use arises when we want to provide extra conditions, in the form
of Prolog goals, which will decide on the appropriate rule. Consider the following
alternative form of the above example:
    sum_to(N, 1) :- N =< 1, !.
    sum_to(N, R) :-
            N1 is N - 1,
            sum_to(Nl, Rl),
            R is Rl + N.
```

<!-- page 102 -->
```prolog
In this case, we say that the first rule is the one to choose if the number provided is
less than or equal to one. This is slightly better than the previous formulation, because
it means that the program produces an answer (rather than running on indefinitely)
if the first argument is given as 0 or a negative number. If the condition is true, the
result I can be produced immediately, and no more recursive goals are necessary.
Only if the condition is not true do we want ever to try the second rule. We must tell
Prolog that once it has proved N =< 1, it must never reconsider the choice about what
rule to choose. This is what the cut does.
    It is a general principle that uses of cut to tell Prolog when it has picked the only
correct rule can be replaced by uses of \+. This is a Prolog built-in predicate, which
means that its definition is already provided when you start your Prolog session. It
is also already declared as a prefix operator. So you can use it in your own programs
without having to write down a definition each time (built-in predicates are described
more fully in Chapter 6). Predicate \+ is defined in such a way that the goal \+X
succeeds only if X, when seen as a Prolog goal, fails. So \+X means that "X is not
satisfiable as a Prolog goal". As an example of replacing cuts with uses of \+, the
two possibilities given for the sum_to definition can be rewritten as:
    sum_to(l, 1).
    sum_to(N, R) :-
            \+(N = 1),
            N1 is N - 1,
            sum_to(Nl, Rl),
            R is N + Rl.
or
    sum_to(N,l) :- N =< 1.
    sum_to(N,R) :-
            V(N =< 1),
            N1 is N - 1,
            sum_to(Nl, Rl),
            R is N + Rl.
In fact, Prolog provides suitable built-in predicates to substitute for both of these
uses. For example, we can replace \+(N=l) by N\=l, and \+(N=<l) by N>1. In gen-
eral, we will not be able to do this with all the conditions we dream up.
    It is good programming style to replace cuts by the use of \+. This is because
programs containing cuts are in general harder to read than programs not containing
them. If one can localise all occurrences of cut to inside the definition of \+, then the
program will be easier to understand. However, the definition of \+ involves trying
```

<!-- page 103 -->
```prolog
to show that the goal it is given can be satisfied. Therefore, if we have a program of
the general form:
```

*A :- B, C.* *A :- \+B, D.*

```prolog
Prolog may well end up trying to satisfy B twice. It will have to try to satisfy B when
it looks at the first rule. Also, if it ever backtracks and considers the second rule, it
will have to try to satisfy B again to see if \+fl can be satisfied. This duplication could
be very inefficient if the condition B was rather complicated. This would not be the
case if instead we had:
    A :- B, !, C.
```

*A :- D.*

```prolog
So one must sometimes weigh up the advantages of a clear program against those
of a program that will run quickly. The discussion of efficiency leads us to our last
example of the cut being used to fix the choice of a rule. Consider the definition of
append from Chapter 3:
    append([], X, X).
    append([A|B], C, [A|D]) :- append(B, C, D).
If we are always using append for the case where we have two known lists and want
to know what list consists of the first appended onto the front of the second, we may
feel that it is inefficient that when backtracking gets to reconsider how to deal with
a goal like append([],[a,b,c(d],X) it must try to use the second rule, even though the
attempt is bound to fail. We know in this context that if the first list is [] then the
first rule is the only correct one, and this information can be given to Prolog by a use
of the cut. In general, Prolog implementations will be able to make better use of the
available storage if they are told things like this than if they have to keep a record of
apparent choices that are not really there. So we could rewrite our definition as:
    appendtf], X, X) :- !.
    append([A|B], C, [A|D]) :- append(B, C, 0).
Assuming our restricted use of append, this does not affect at all which solutions
the program finds. It only increases the space and time efficiency to some extent. In
exchange for this, we are liable to find that other kinds of uses of append will no
longer work as expected, as is shown in Section 4.4.
```

<!-- page 104 -->
### 4.3.2 The "cut-fail" Combination

```prolog
In the second major application area, the cut is used in conjunction with the built-in
fail predicate. This is another built-in predicate, like \+. It has no arguments, which
means that the success of the goal fail does not depend on what any variables stand
for. Indeed, fail is defined in such a way that as a goal it always fails and causes
backtracking to take place. This is just like what happens if we try to satisfy a goal
for a predicate with no facts or rules. When fail is encountered after a cut, the normal
backtracking behaviour will be altered by the effect of the cut. In fact, the particular
combination "cut-fail" turns out to be quite useful in practice.
    Let us consider how we might use this combination in a program to calculate
how much tax somebody should pay. One thing we might want to know is whether
the person is an "average taxpayer". In this case, the calculations might be quite
simple and not have to involve considering lots of special cases. Let us define a
predicate average_taxpayer, where average_taxpayer(X) means that X is an average
taxpayer. For instance, Fred Bloggs, who is married with 2 children and works in a
bicycle factory, might be considered quite average. However, the managing director
of an oil company may be earning too much, and a student may be earning too
little for the same kinds of tax calculations to be appropriate. We should start by
considering a possible special case. It may be that special tax laws apply to somebody
who is a native of another country, because he may have obligations to that country
as well. Therefore, however average he may be in other respects, a foreigner will not
be classed as an average taxpayer. We can start writing rules about this as follows:
    average_taxpayer(X) :- foreigner(X), fail.
    average_taxpayer(X) :- . . .
```

`In this extract,` *which is not correct yet*`, the first rule attempts to say, "if X is a for-`

```prolog
eigner then the goal average_taxpayer(X) should fail". The second rule is to apply
the general criterion for being an average taxpayer for the cases when X is not a
foreigner. The trouble is that if we asked the question:
    ?- average_taxpayer(widslewip).
about a foreigner called widslewip, the first rule would match and the foreigner goal
would succeed. Next, the fail goal would initiate backtracking. In attempting to re-
satisfy the average_taxpayer goal, Prolog would find the second rule and start ap-
plying the general criterion to widslewip. Now it is quite likely that he would pass
the further tests, being average in other ways, in which case the question would
incorrectly be answered "yes". So our first rule has been completely ineffective in
rejecting our friend as an average taxpayer.
```

<!-- page 105 -->
```prolog
    Why is this? The answer is that during backtracking Prolog tries to re-satisfy
every goal that has succeeded. So in particular it will investigate alternative ways of
satisfying the goal
    ?- average_taxpayer(widslewip).
In order to stop Prolog finding alternatives for this, we need to "cut" the choice
(freeze the decision) before failing. We can do this by inserting a cut before the fail
goal. A slightly more comprehensive definition of average_taxpayer incorporating
this change is shown here:
    average_taxpayer(X) :- foreigner(X), !, fail.
    average_taxpayer(X) :-
            spouse(X, Y),
            gross_income(Y, Inc),
            Inc > 3000,
            !, fail.
    average_taxpayer(X) :-
            gross_income(X, Inc),
            2000 < Inc, 20000 > Inc.
    gross_income(X, Y) :-
            receives_pension(X, P),
            P < 5000,
            !, fail.
    grossJncome(X, Y) :-
            gross_salary(X, Z),
            investment_income(X, W),
            YisZ + W.
    investmentJncome(X, Y):- ...
Note the use in this program of several other "cut-fail" combinations. In the second
rule for average_taxpayer we say that the attempt to show that someone is an average
taxpayer can be abandoned if we can show that that person's spouse earns more than
a certain amount. Also, in the definition of the predicate gross_income we say (in the
first rule) that if somebody receives a pension that is below a certain amount then,
whatever their other circumstances, we will consider them not to have any gross
income at all.
    An interesting application of the "cut-fail" combination is in the definition of
the predicate \+. Most Prolog implementations provide this already defined, but it
is interesting to consider how we can provide rules for it. We require that the goal
```

<!-- page 106 -->
```prolog
\+P, where P stands for another goal, succeeds if and only if the goal P fails. This is
not exactly in accord with our intuitive notion of "not true": it is not always safe to
assume that something is not true if we are unable to prove it. However, here is the
definition:
    \+P :- call(P), !, fail.
    \+P.
The definition of \+ involves invoking the argument P as a goal, using the built-in
predicate call. Predicate call simply treats its argument as a goal and attempts to
satisfy it. We want the first rule to be applicable if P can be shown, and the second
to be applicable otherwise. So we say that if Prolog can satisfy call(P) it should
thereupon abandon satisfying the \+ goal. The other possibility is that Prolog cannot
show call(P). In this case, it never gets to the cut. Because the call(P) goal failed,
backtracking takes place, and Prolog finds the second rule. Hence the goal \+P will
succeed when P is not provable.
    As with the first use of "cut", we can replace uses of "cut-fail" with uses of
\+. This involves rather more reorganisation of the program than before, but does not
introduce the same inefficiency. If we were to rewrite our average_taxpayer program,
it would start off something like:
    average_taxpayer(X) :-
            \+foreigner(X),
            \+((spouse(X, Y), gross_income(Y, Inc), Inc > 3000)),
            gross_income(X, Incl),
Note that in this example, we have to enclose a whole conjunction of goals inside thei
\+. In order to show unambiguously that the commas join the goals into a conjunction
(rather than separating multiple \+ arguments), we have enclosed the \+ argument in;
an extra set of brackets.
```

### 4.3.3 Terminating a "generate and test"

```prolog
Now we come to look at the last major use of "cut" in Prolog programs: to terminate
a "generate and test" sequence. Very often a program will have parts that conform
to the following general model. There will be a sequence of goals that can succeed
in many ways, and which generates many possible solutions on backtracking. Af-
ter this, there are goals that check whether a solution generated is acceptable for
some purpose. If these goals fail, backtracking will lead to another solution being
```

<!-- page 107 -->
```prolog
proposed. This will be tested for appropriateness, and so on. This process will stop
when either an acceptable solution is generated (success), or when no more solutions
can be found (failure). We can call the goals that are yielding all the alternatives the
"generator" and those that check whether a solution is acceptable the "tester". Let
us consider an example of this: a program to play the game Noughts and Crosses,
also known as Tic-Tac-Toe. In case you haven't come across this game, it involves
two players taking turns to occupy squares on a 3 by 3 board. One player occupies
squares with pieces marked o, and the other one with pieces marked x. To illustrate,
here is a board part way through a game:
To represent a board, we can use a 9-component structure b (for "board"), using
the constants x and o to represent the pieces. If a square is empty, we will mark it
with an e. The components of the board can be ordered in rows from left-to-right, so
for example, the above pictured board is represented like this: b(e,o,e,e,x,o,e,x,e).
The object of the game is to get three of one's own pieces in a (vertical, horizon-
tal or diagonal) line before the other player does. There are eight ways to make a
line of pieces. We can represent the lines of a board in the following way, where
line(B,X,Y,Z) instantiates the arguments X,Y,Z to the three squares that make up a line
in board B:
    line(b(X,Y,Z,_,
                       ), X, Y, Z).
    line(b(
              X,Y,Z
                       ),X, Y, Z).
    line(b(
              ,_,_,_,X,Y,Z), X, Y, Z).
    line(b(X
              Y
                   Z
                       ), X, Y, Z).
    line(b(_,X,_,_,Y,_,_,Z,_), X, Y, Z).
    line(b(_,_,X
                 Y
                      Z), X, Y, Z).
    line(b(X
                Y
                      ,Z), X, Y, Z).
    line(b(
             X,_,Y,_,Z
                       ), X, Y, Z).
By now you should immediately recognise that X is a variable denoting a board po-
sition, and x is a constant naming the x-shaped pieces.
```

<!-- page 108 -->
```prolog
    We shall next look at the game from the point of view of the player who puts
o's on the board. The predicate forced_move is used to answer the question, "Is the
o-player forced to put a piece in a particular position?" This will be the case if the
o-player cannot immediately win (we do not deal with this here), but the x-player is
threatening to win on its next move:
    forced_move(Board) :-
            line(Board, X, Y, Z),
            threatening(X, Y, Z),
Notice that the "cut" here means that one threat is enough to force a move. We now
need to determine whether a row of squares constitutes a threat. This will be the case
if two of the squares are x's and one is empty. There are three possibilities for these
threatening patterns. A suitable definition is:
    threatening(e, x, x).
    threatening(x, e, x).
    threatening(x, x, e).
For instance, in the position shown below, the o-player is forced to play in the indi-
cated square, because if it does not, the x-player will be able to fill the second column
and win in the next turn: The program works by trying to find a line, two of whose
                                The centre column matches threatening(x,x,e)...
```

X

X I

0

```prolog
                                          ... so o must play here
squares are occupied by crosses, and the other of which is empty. If it can, it reports
a forced move situation.
    In the clause for forced_move, the goal line(Board,X,Y,Z) serves as a "genera-
tor" of possible lines. This goal can succeed in many ways, with the variables X,Y,Z
instantiated to one of the possible lines of squares. Once a possible line has been
suggested by line, it is necessary to see whether the opponent is threatening to claim
```

<!-- page 109 -->
```prolog
this line. This is the purpose of the "tester" goal: threatening(X,Y,Z), which looks for
one of three threatening patterns of squares. The basic idea of the program is very
simple. First, line proposes a line, and then threatening looks to see whether that line
is threatening. If so, the original forced_move goal succeeds. Otherwise, backtrack-
ing occurs and line comes up with another possible line. Now this is tested also, and
maybe backtracking occurs again to find another line. If we get to the point when
line can generate no more lines, then the forced_move goal will correctly fail (there
is no forced move).
    Now consider what happens if this program, as part of a larger system, success-
fully finds a forced move. Suppose that somewhere later on during the move calcula-
tion a failure occurs, and Prolog eventually backtracks to re-satisfy the forced_move
goal. We do not wish line to start producing more possible lines to be checked. This
makes no sense, because it cannot possibly be useful to find alternative forced moves.
If we have found one of them, theft we cannot do anything better than carry it out:
failure to do so would guarantee losing the game. Most of the time, there will be no
alternative anyway, and forced_move will search through all the untried lines in vain,
before itself failing. However, in the case of forced moves, we know that even if there
is an alternative solution, it cannot be of any use in a context where a failure occurred
in spite of the first solution. We can prevent Prolog from wasting time searching for
different forced moves by putting a "cut" at the end of the clause. This has the effect
of freezing the last successful line solution. Including the "cut" amounts to saying
"when I look for forced moves, it is only the first solution that is important."
Let us look at another example of a program that works by a "generate and test"
method. We came across the idea of integer division in Section 2.5. Most Prolog
systems provide this facility automatically, but here is a program for integer division
that only uses addition and multiplication.
    divide(Nl, N2, Result) :-
            is_integer(Result),
            Productl is Result * N2,
            Product2 is (Result + 1) * N2,
            Productl =< Nl, Product2 > Nl,
This rule uses the predicate isjnteger (as defined before) to generate the number
Result which is the result of dividing Nl by N2. For instance, the result of dividing
27 by 6 is 4, because 4 * 6 is less than or equal to 27, and 5 * 6 is greater than 27.
    The rule uses isjnteger as a "generator", and the rest of the goals provide the
appropriate "tester". Now we know in advance that, given specific values of Nl and
N2, divide(Nl,N2,Result) can only succeed for one possible value for Result. For
although isjnteger can generate infinitely many candidates, only one will ever get
```

<!-- page 110 -->
```prolog
past the tests. We can indicate this knowledge by putting a cut at the end of the
rule. This says that if we ever successfully generate a Result that passes the tests
for being the result of the division, we need never try any more. In particular, we
need never reconsider any of the choices that were involved in looking for rules
for divide, isjnteger, and so on. We have found the only solution, and there is no
point in ever looking for another. If we did not put in the cut here, any backtracking
would eventually start finding alternatives for is_integer again. So we would carry
on generating possible values for Result again. None of these other values would be
the correct result of the division, and so we would continue generating indefinitely.
```

## 4.4 Problems with the Cut

```prolog
We have already seen that we must sometimes take into account the way Prolog
searches the database and what state of instantiation our goals will have in deciding
the order in which to write the clauses of a Prolog program. The problem with in-
troducing cuts is that we have to be even more certain of exactly how the rules of
the program are to be used. For, whereas a cut when a rule is used one way can be
harmless or even beneficial, the very same cut can cause strange behaviour if the rule
is suddenly used in another way. Consider the modified append from the last section:
    append([], X, X) :- !.
    append([A|B], C, [A|D]) :- append(B, C, D).
When we are considering goals like:
    ?- append([a,b,c],[d,e], X)
and
    ?- append(fa,b,c], X, Y)
the cut is quite appropriate. If the first argument of the goal already has a value, then
all the cut does is to reaffirm that only the first rule will be relevant if the value is [].
However, consider what happens if we have the goal
    ?- append(X, Y, [a,b,c]).
This goal will match the head of the first rule, giving:
    X=[], Y-[a,b,c]
but now the cut is encountered. This will freeze all the choices we have made, and so
if we ask for another solution, the answer will be no even though there actually are
other solutions to the question.
```

<!-- page 111 -->
```prolog
    Here is another interesting example of what can happen if a rule containing a cut
is used in an unexpected way. Let us define a predicate number_of_parents, which
can express information about how many parents somebody has. We can define it as
follows:
    number_of_parents(adam, 0):-!.
    number_of_parents(eve, 0) :-!.
    number_of_parents(X, 2).
That is, the number of parents is 0 for adam and eve, but two for everybody else.
Now if we are always using our definition of number_of_parents to find the number
of parents of given people, this is fine. We will get
    ?- number_of_parents(eve, X).
```

*X=0* *no*

```prolog
?- number_of_parents(john, X).
```

*X=2* *no*

```prolog
and so on, as required. The cut is necessary to prevent backtracking ever reaching the
third rule if the person is adam or eve. However, consider what will happen if we use
the same rules to verify whether given people have given numbers of parents. All is
well, except that we get:
    ?- number_of_parents(eve, 2).
```

*yes*

```prolog
You should work out for yourself why this happens. It is simply a consequence of the
way Prolog searches through the database. Our implementation of "otherwise" with
a cut simply does not work properly any more. There are two possible modifications
we could make to recover from this:
    number_of_parents(adam, N):-!, N = 0.
    number_of_parents(eve, N) :- !, N = 0.
    number_of_parents(X, 2).
or
    number_of_parents(adam, 0).
```

<!-- page 112 -->
```prolog
    number_of_parents(eve, 0).
    number_of_parents(X, 2) :- \+(X=adam), \+(X=eve).
Of course, these will still not work properly if we give goals such as
    ?- number_of_parents(X, Y).
expecting backtracking to enumerate all the possibilities. So the moral is:
```

*If you introduce cuts to obtain correct behaviour when the goals are of one* *form, there is no guarantee that anything sensible will happen if goals of* *another form start appearing.*

```prolog
It follows that it is only possible to use the cut reliably if you have a clear policy
about how your rules are going to be used. If you change this policy, all the uses of
cut must be reviewed.
```
