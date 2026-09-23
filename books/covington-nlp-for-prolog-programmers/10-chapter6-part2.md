# Chapter6_Part2

<!-- page 190 -->
Exercise 6.5.5.1 Demonstrate the problem. Use the parser from the previous section with the grammar in this section, and show what goes wrong upon trying to parse see the dog.

Exercise 6.5.5.2 Solve the problem by adding subsumption checking, and demonstrate that your modified parser works correctly.

Exercise 6.5.5.3 Why does parse use the subsumption checker when calling complete but not when calling chart?

Exercise 6.5.5.4 With the grammar in this section, the modification suggested in Exercise 6.5.4.4 no longer works correctly. Explain why, and make the necessary changes.

Exercise 6.5.5.5 Modify the grammar by adding arguments to nodes to account for subject-verb number agreement and to build a representation of the tree. (This is simple; just copy the modified grammar from Exercise 6.2.0.3.)

Exercise 6.5.5.6 (Not for courses that skipped Chapter 5.) Combine Mini-GULP with this parser. Account for number agreement of subject and verb, and of determiner and noun, using GULP feature structures. (Easy—copy the rules from Exercise 6.2.0.4.)

**6.6 EARLEY’S ALGORITHM**

6.6.1 The Key Idea

Earley (1970) introduced a chart parsing algorithm with the following characteristics:

<!-- page 191 -->
e It parses n-word sentences in, at most, time proportional to n°, which is near the best possible performance. e It handles null constituents correctly. e It does not loop on left-recursive rules (A — A B). e It uses a combination of top-down parsing (“prediction”) and bottom-up parsing (“completion”). — e It is an ACTIVE CHART PARSER, i.e., the chart stores work in progress as well as completed work. e The parser does not backtrack; instead, it pursues all alternatives concurrently, and at the end, all alternative parses are in the chart.

Sec. 6.6

Earley’s Algorithm

177

The key idea of Earley’s algorithm is that the chart can store unfinished constituents

as well as constituents that have been completely parsed. To understand how this is

possible, recall that in DCG, the rule S + NP VP goes into Prolog as:

s(S1,S) :- np(S1,S2), vp(S2,8).

**Now consider the query**

?- s([the,dog,barked],[]).

Imagine combining the query with the rule, like this:

s([the,dog,barked],[]) :- np([the,dog,barked],S1), vp(S1,[]). This could be an Earley chart entry. Now imagine that the parser has processed the NP the dog. Then this same rule can be simplified to:

s([the,dog,barked],[]) :- vp([barked],[]). That is: If barked is a VP, then the dog barked is an S. And after the VP is parsed, the rule simplifies further to:

s((the,dog,barked],[]).

which indicates that the entire sentence has been parsed.

**6.6.2 An Implementation**

In Earley’s original notation, these three chart entries just mentioned would have the form:

**S—+eNPVP 0**

0

**S—+NPeVP 0**

2

**S—+NPVPe 0**

3 The dot in the PS rule indicates which subconstituent is to be parsed next. The two numbers are word counts; they indicate, respectively, the position of the beginning of the S, and the position of the dot, relative to the input string.

To implement Earley’s algorithm in Prolog, we will store chart entries in yet a different form, like this:

<!-- page 192 -->
chart (s, [the, dog, barked], [np, vp], [the, dog, barked]) . chart (s, [the, dog, barked], [vp], [barked]). chart (s, [the,dog,barked],[],[]). These save space by leaving out the predictable part of the Prolog clauses that we used initially. The four arguments are:

e The constituent originally being sought;

e The position at which that constituent was supposed to begin;

e The subconstituents (GOALS) currently being sought (we’ll call the first goal in each

list the CURRENT GOAL); and

e The CURRENT POSITION in the input string, where the current goal should begin.

Obviously, an Earley parser has many current goals, one corresponding to each chart entry at the current position. (The inefficient representation of positions is deliberate; see section 6.5.3.)

Earley’s algorithm parses entirely by manipulating the chart. This means that the parse procedure is very simple—put the input string and initial goal into the chart, let the parser do its thing, and then see whether it has produced a successful parse:

parse(C,S1,S) :-

clear_chart,

store(chart(start,S1,[C],S1)),

process(S1),

chart (C,S1,[],S).

Here process steps through the input string, calling the three parts of the parser at each position:

process([]) :- !.

process(Position) :-

predictor (Position),

scanner (Position,NewPosition),

completer (NewPosition),

process (NewPosition).

The three parts of the parser itself are:

e The PREDICTOR, which looks for rules that expand current goals, and uses them to

create new goals;

e The SCANNER, which accepts a word from the input string and uses it to satisfy

current goals; and

e The COMPLETER, which looks at the output of the scanner and determines which,

if any, larger constituents have been completed.

All three of these produce chart entries. For example, given

**chart (s, [the,dog,barked],**

<!-- page 193 -->
[np,vp], [the, dog, barked]) . the predictor will use NP + D N to produce

**chart (np, [the,**

**dog, barked], [d,n], [the,**

dog, barked]) .

Then the scanner will accept the, giving:

**chart (np, [the,**

dog, barked], [n], [dog, barked]) .

**Now the completer executes, but can’t do anything because nothing has been completed;**

then the predictor executes, but can’t do anything because there are no rules expanding n. So the scanner gets to execute again; it accepts dog, giving:

**chart (np, [the,**

dog, barked],[], [barked]).

**Now the NP is complete and the completer takes note of this fact, modifying the chart**

entry for S appropriately:

chart (s, [the, dog, barked], [vp], [barked]) .

In a similar way the predictor, scanner, and completer process the VP. Then the S is complete and the last thing put into the chart is:

chart (s, [the,dog,barked],[],[]).

Since S was the original goal and the input string is empty, the parse is complete. The predictor, scanner, and completer communicate mainly through the chart, except that each of them has to know the current position in the input string (and the scanner changes it). Here is a more precise description of what they do:

Predictor For each current goal at the current position, look up all the rules expanding it and use them to make more chart entries. (This creates additional current goals at the current position; do the same thing to all of them.)

<!-- page 194 -->
Scanner Accept a word from the input string and determine its category. Look for all chart entries for the current position whose active goal is that category. Make, from each of them, a new chart entry, removing the first goal and the first word of the input string.

Completer

Look for constituents that have just been completed,

and use them to complete higher-level constituents.

(Upon completing a constituent this way,

do the same thing with the result.)

Figure 6.8 shows, in detail, the process of parsing The dog chases the cat. For simplicity, lots of irrelevant syntax rules are ignored in the example. With a larger grammar, there would be somewhat more entries in the chart and more work at each stage.

Exercise 6.6.2.1

By hand, work through the process of parsing The dogs chase the cat near the elephant using

Earley’s algorithm and the grammar in Figure 6.1. Include all chart entries, including those

from rules that do not contribute to a successful parse. Show your results in the format of

Figure 6.8.

6.6.3 Predictor

The predictor looks at all the chart entries that apply to the current position in the input string, and constructs, from each of them, new chart entries expanding their current goals. This work is done by two predicates, predictor and predict, both of which use £ail to make execution backtrack through all possibilities:

predictor(Position) :-

chart (_,_, [Goal|_],Position),

% For every chart entry of this

predict (Goal,Position),

% kind do all possible

fail.

```prolog
% predictions
```

predictor(_).

% then succeed with no further

```prolog
   action.
oe
```

predict (Goal, Position) :-

oe

For every rule expanding Goal

rule(Goal, [H|T]),

store (chart (Goal, Position,

oP

[H|T],Position)),

%® make a new chart entry and

predict (H, Position),

make predictions from it too

fail.

predict(_,_).

oe

then succeed with no further

```prolog
  action.
oe
```

There are two predicates here because predict has to call itself in order to make further predictions from the chart éntries it creates.

<!-- page 195 -->
The alert reader will notice that predictor looks for chart entries at Position, and predict, which it calls, is constantly adding chart entries at the same Position. Start with:

Predict: chart (start, [the,dog,chases,the,cat],[s], [the ,dog,chases,the,cat] ).

**Use**

S + NP VP and NP > DN. chart (s, [the,dog,chases,the,cat] ,[ np,vp], [the,dog, chases, the,cat]). chart (np, [the,dog,chases,the,cat],[d,n], (the ,dog,chases,the,cat]).

Scan: Accept the. chart (np, [the,dog, chases, the,cat], [n], [dog, chases,the,cat]).

Complete: Nothing to do; no phrase has been completed.

Predict: Nothing to do; there are no rules expanding N.

Scan: Accept dog. chart (np, [the,dog, chases, the,cat],[],[chases,the,cat]).

Complete: An NP has now been parsed. chart (s, [the,dog,chases,the,cat], [vp], [chases,the,cat]).

Predict: Use VP — V and VP > V NP. chart (vp, [chases,the,cat],[v],[chases,the,cat]). chart (vp, [chases ,the,cat],[v,np], [chases,the,cat]).

Scan: Accept chases. chart (vp, [chases,the,cat],[],[the,cat]). chart (vp, [chases,the,cat], [np], [the,cat]).

Complete: According to VP — V, a VP and hence the S have now been parsed. chart (s, [the,dog,chases,the,cat],[],[the,cat]). chart (start, [the,dog,chases,the,cat],[],[the,cat]).

Predict: The other VP rule is still looking for an NP. Expand it... chart (np, [the, cat], [d,n], [the,cat]).

Scan: Accept the. chart (np, [the,cat], [In], [cat]).

Complete: Nothing to do—no phrase has been completed.

Predict: Nothing to do—there are no rules expanding N.

Scan: Accept cat. chart (np, [the,cat],[],[]).

Complete: Now the NP, and hence the VP and S, have been parsed. chart (vp, [chases,the,cat],[],[]). chart (s, [the,dog, chases, the,cat],[],[). chart (start, [the,dog,chases,the,cat],[],[]). All done.

<!-- page 196 -->
Figure 6.8 Earley’s algorithm in action.

Chap, 6

**Why doesn’t it get into a loop trying to process its own output? Or at least, why call**

predict recursively to process the new entries, if they would have been found by. backtracking anyway?

For two reasons. First, store (which we haven’t defined yet) uses asserta, not assertz, and thus the new entries are added before the one presently being looked at. Second, even if store didn’t do this, most Prologs would never see the new entries, because in most Prologs, newly added clauses cannot become alternatives for a query that is already in progress. Upon starting any query, Prolog determines which facts and rules can satisfy it, and any further rules that get asserted during the processing of the query will be ignored.

Exercise 6.6.3.1

Get the predictor working and show that it can execute the first part of the parse in Figure

6.8, up to the point where the scanner is needed. Temporarily use asserta in place of

```prolog
store.
                                               :
```

**6.6.4 Scanner**

The scanner is very simple:

scanner ([W|Words],Words) :-

chart (C, PC, [G|Goals], [W|Words])

,

oP

oe

for each current goal at

current position

```prolog
word(G,W),
                                    % 1f category of W matches it
store(chart(C,PC,Goals,Words)),
```

% make a new chart entry

```prolog
fail.
```

scanner ({_|Words],Words).

% then succeed with no further

```prolog
% action.
```

**Traditionally, the predictor predicts individual words. We do not do this here,**

because it would add a vast number of unnecessary predictions to the chart. Instead, the scanner determines the category of each word at the time the word is accepted. Exercise 6.6.4.1

Add the scanner to the predictor that you have already gotten working. Show that your

scanner and predictor can execute the first two steps of the parse in Figure 6.8, up to the

point where the completer is needed.

Exercise 6.6.4.2

Why doesn’t second clause of scanner have anonymous variables in place of Words?

**6.6.5 Completer**

<!-- page 197 -->
The completer looks at all chart entries at the current position that have no goals—.e., all completed constituents—and tries to use them to complete larger constituents. Normally the scanner produces one completed constituent (a single word, such as [y dog ]), and the completer tries to use this to complete something larger, such as an NP. Again, there are two predicates, because the completer has to call itself on its own output:

completer(Position) :oe chart (C,PC,[],Position), complete(C,PC, Position), fail. For every chart entry with no goals, complete all possible higher constituents, oe oe

oe oe then succeed with no further action. completer(_).

complete(C,PC,Position) :oe chart (CO,PCO, [ClGoals],PC), store (chart (C0, PCO, oe For every constituent that can be completed make a new chart entry, Goals,Position)), Goals == [], %* then fail here if Goals not empty, complete(C0,PC0,Position), % or process new entry the same way fail.

complete(_,_,_). % then succeed with no further oe action.

The difference is that, unlike predict, complete does not always call itself on its own output—it does so only if its output is itself a chart entry with no goals, and hence a completed constituent. Recall that the completer is responsible for creating

**chart (s, [the,dog, chases,the,cat],**

[vp], [chases,the,cat]).

when the NP is finished and then

chart (s, [the,dog,chases,the,cat],[],[]).

**when the VP is finished. Only the second of these completes a constituent and thereby**

justifies a recursive call to the completer.

Exercise 6.6.5.1

Get the completer working and add it to the predictor and scanner that you have already implemented. Test it. Use a grammar that does not include any left-recursive rules.

**6.6.6 How Earley’s Algorithm Avoids Loops**

**We haven’t defined store yet. Its definition is the key to the way Earley’s algorithm**

<!-- page 198 -->
keeps from looping on left-recursive rules. Specifically, store fails upon attempting to

Parsing Algorithms

Chap. 6

© put something in the chart that is already there:

store(chart(A,B,C,D)) :-

\+ chart (A,B,C,D),

```prolog
asserta(chart (A,B,C,D)).
```

Consider how the predictor handles the rules

**NP + DN**

**NP ->**

**NP Conj**

NP when parsing the dog and the cat. At the start, there is no way to tell which rule applies, so the predictor makes two chart entries:

chart (np, [the,dog,and,the, cat] ,{d,n], [the,dog,and,the,cat]). chart (np, [the,dog,and,the,cat], [np,conj,np], [the,dog,and,the,cat]). Recall that the predictor is supposed to apply to its own output, i.e., the chart entries that it generates. The first of these chart entries has d as its current goal; d is not a phrase; so no further predictions are made from it. The second chart entry has current goal np, which can be expanded by either of two rules, giving two more chart entries: chart (np, [the,dog,and,the,cat], [d,n], [the,dog,and,the,cat]). chart (np, [the,dog,and,the,cat], [Inp,conj,np], [the,dog,and,the,cat]). But these entries are already in the chart. This means that store fails, and the predictor doesn’t get to call itself recursively on them. Thus the rule is blocked.

To put it more succinctly: Earley’s algorithm will never predict a constituent at a position, if it has already predicted the same constituent at the same position.

But the completer is welcome to use the same chart entry more than once when completing a recursively embedded phrase. Thus long phrases such as the dog and the cat and the elephant are parsed with no problem. Exercise 6.6.6.1

Determine (by hand or using the computer) the chart entries for parsing the dog and the cat

and the elephant. Show them in the order in which they are added to the chart. 6.6.7 Handling Null Constituents

**As shown, our parser still has trouble with the rule D — %, which we represent as**

rule(d,[]).

because the predictor insists that the second argument of rule be a nonempty list.

**We have two choices. We can recast D > @ as word (d, []) and modify the**

<!-- page 199 -->
scanner to handle it; or we can leave it as it is and modify the predictor.

We choose the first of these, and add a clause for predict:

predict (Goal,Position) :-

```prolog
rule(Goal,[]),
store(chart (Goal,Position,[],Position)),
complete (Goal, Position, Position),
fail.
```

This comes between the two clauses already defined. This clause generates a new chart entry in the same way as the first clause, but then it calls the completer—necessary because a constituent has been completed, of course, and the completer now needs to work on it at this position in the input string. Normally the completer would not get to work until after the scanner had advanced the current position to the next word.

Exercise 6.6.7.1

Get an Earley parser working which includes the whole grammar in Figure 6.1.

Exercise 6.6.7.2

Add features to the nodes in the grammar to enforce subject-verb number agreement and

build a representation of the tree structure (as in Exercise 6.2.0.3).

**6.6.8 Subsumption Revisited**

Like all chart parsers, Earley’s algorithm needs a subsumption check. This turns out to be just a simple modification to store: instead of checking for pre-existing chart entries that match the new one, check for entries that subsume it.

store(chart(A,B,C,D)) :-

\+ (chart (A1,B,C1,D), subsumes_chk(A1,A), subsumes_chk(C1,C)),

asserta(chart (A,B,C,D)).

Here we save some time by looking only at A and C, which are the only parts of the chart entry in which uninstantiated arguments can appear.

Recall that subsumes_chk is not built in. If you need to define subsumes_chk for yourself but forget to do so, the parser will still work but the chart will contain superfluous entries, because all the calls to subsumes_chk will fail.

Exercise 6.6.8.1

Demonstrate the need for a subsumption check in your Earley parser, using the same gram-

mar as in Exercise 6.5.5.1. Then modify your parser to correct it.

Exercise 6.6.8.2

As you have done with all the other parsers, add arguments to the nodes to account for

subject-verb number agreement and to build a representation of the tree. (See Exercise

<!-- page 200 -->
6.2.0.3.)

Parsing Algorithms

Chap. 6

Exercise 6.6.8.3

(Not for courses that skipped Chapter 5. ) Combine Mini-GULP with the Earley parser,

Account for number agreement of subject and verb, and of determiner and noun, using

GULP feature structures. (Easy—copy the rules from Exercise 6.2.0.4.)

’ 6.6.9 Restriction

Earley’s algorithm can still loop on grammar rules where a daughter node has an argument that contains an argument of the mother node, like this:

a(X) --> a(f£(X)).

**Suppose X = b. Then the predictor will first predict a(b), then a(f£(b)), then**

**a(f£(£(b))), then a(£(f£(£(b)))), ad infinitum.**

Here’s a real-life example. Several grammatical theories equip each verb with an argument which is a list of constituents that should come after it:

**v(t)**

--> [sleep]; [bark]. v( [np] )

--> [see]; [chase]. v((np,np]) --> [give]. v(([np,pp]) --> [put].

Then a phrase-structure rule of the form

v(Y) --> v([XIY]), x.

```prolog
% (not a legal DCG rule)
```

picks apart these lists and generates the tight things in the right places (Figure 6.9). (This is essentially the same as the example of subcategorization lists at the end of Chapter 5.)

```prolog
                     v([])
           ee
        v( [pp] )
                                  pp
     ON
                             oO
v([np,pp])
                np
                             p
                                        np
             “oN
                                     AN
             d
                     n
                                     d
                                             n
             |
                     |
                                     }
                                             |
    put
            the
                   book
                            on
                                    the
                                           table
```

Figure 6.9 Parse tree with subcategorization lists.

**Here we’re using DCG notation for clarity, but this last rule is, of course, not**

<!-- page 201 -->
legal in DCG, because one of the constituents (X) is a variable. Nevertheless, Earley’s algorithm should be able to handle it, because as soon as the scanner accepts the verb, the value of X will be known.

Earley’s algorithm loops for a different reason—the occurrence of the argument Y within the argument [X|Y]. Starting with

chart (v([]),[sees,the, dog], [v([X]),X], [sees,the,dog]).

the predictor will generate, in succession,

chart (v([X]), [sees, the,dog], [v([X1,X]),X1], [sees,the,dog]). chart (v([X1,X]),[sees, the,

dog], [v([X2,X1,X]) ,X2], [sees,the,dog]). chart (v([X2,X1,X]), [sees,

the, dog], [v([X3,X2,X1,X]) ,X3], [sees,the,dog]). chart (v([X3,X2,X1,X]), [sees, the,

dog], [v([X4,X3,X2,X1,X]),X4], [sees,the,dog]).

ad infinitum, where X, X1, X2... represent the variables that correspond to X on successive invocations of the v (Y) rule.

Shieber (1986) proposes a solution that he calls RESTRICTION: make the predictor ignore arguments whose values are not fully instantiated. By “ignore” we mean, in the context of our parser, that anonymous variables will be substituted for these arguments. (This makes the predictor overpredict, but no harm results because the spurious predictions are not used further.) With restriction, sees the dog is parsed as follows:

Predict:

chart (v([]), [sees,the,dog],v(_), [sees, the, dog]) . Scan:

chart (v([np]), [sees,the,dog],[], [the,dog]). Complete:

```prolog
chart(v([np,np]),[sees,the,dog], [np], [the,dog]).
```

and so on. Restriction applies only to the predictor; the scanner and completer look back at the rules and fill in the missing arguments. Gerdemann (1989, 1991) explores other uses of restriction.

In this context it is helpful to think of parsing with arguments as a twofold process—accepting the input string and building the arguments of the nodes. These processes go on concurrently, working, as it were, at right angles to one another. Earley’s algorithm does a good job of loop-proofing the process of accepting the input string, but loops with argument-building are still possible. An important research topic at the moment is the discovery of linguistically motivated constraints on arguments.

Exercise 6.6.9.1

Demonstrate that Earley’s algorithm loops on the grammar shown.

Exercise 6.6.9.2 (small project)

Implement restriction and use it to make Earley’s algorithm handle this grammar success-

```prolog
fully.
```

<!-- page 202 -->
6.6.10 Improving Earley’s Algorithm

The implementation of Earley’s algorithm that we have developed is far from optimal. There are numerous ways to improve it from the standpoint of Prolog coding:!

e Represent positions in the sentence as numbers (word counts) rather than lists (as

in Section 6.5.3).

e Use first-argument indexing. The parser spends much of its time searching through

the chart or through the rules. Organize these so that they have distinctive first

arguments that will speed the retrieval of the desired information.

e Reduce the use of assert; see what happens if (part of) the chart is kept in a

list rather than stored in the knowledge base. This may be beneficial during some

kinds of processing but not others. Another tack is to improve the predictor. Except for the loop-check, the usual Earley predictor works just like a recursive-descent top-down parser. Like all top-down parsers, it makes plenty more predictions than are really necessary. Earley (1970) suggested letting the predictor look ahead to the next entry in the input string, and thereby narrow down the range of choices. Kilbury (1984) replaced the top-down predictor with one that works like a left-corner parser; Leiss ( 1990) discusses Kilbury’s proposal and then presents his own, which works like a left-corner parser with links, thereby avoiding many spurious predictions.

Exercise 6.6.10.1

(project)

Implement a good Earley parser in Prolog, making as many improvements as possible. 6.6.11 Earley’s Algorithm as an Inference Engine

Recall that when we introduced Earley’s algorithm, we presented chart entries as stored Prolog rules and facts. This leads us to suspect that Earley’s algorithm could serve as a general way to execute Prolog, instead of the normal search-and-backtracking process. And this suspicion is right. Pereira and Warren (1983) and Pereira and Shieber (1987:199-210) discuss “Earley deduction,” which they attribute to an unpublished 1975 note by David H. D. Warren.

The basic idea is that any inference engine can store LEMMAS, or previously proved results, in order to keep itself from repeating work upon backtracking. This is the equivalent of chart parsing pure and simple. An Earley inference engine is loop-proof because it never stores a lemma, nor tries to derive further lemmas from it, if the same lemma, or one that subsumes it, is already in the knowledge base. Thus, with Earley deduction, ancestor(X,Z) :- ancestor(X,Y), ancestor (Y,Z).

does not cause the infamous loop.

<!-- page 203 -->
'In this section I am indebted to Joseph Knapka, who experimented with a number of these proposed improvements.

There are differences between parsing and deduction, of course. In Earley deduction, there is no input string and hence no scanner. Instead, both the completer and the predictor need to look at every clause that is added to the chart.

The predictor looks at each rule newly added to the chart, and expands that rule’s first subgoal using every possible rule in the knowledge base, then does the same thing, if possible, to the results. Thus from

f(a) :- g(a). (newly added) g(X) :- h(X), 3 (X). Gn the knowledge base)

the predictor produces

```prolog
g(a)
```

:- h(a), Jj (a). and adds it to the chart.

The completer deletes subgoals by resolving them with facts. When a fact is added to the chart, the completer will resolve it against the first subgoal of every possible rule already in the chart, so that for example

h(a). (newly added) k(X) :- h(X), m(X). (already in the chart)

yields the new chart entry k(a) :- m(a).

The completer also works on newly added rules, resolving them against facts in the chart or in the knowledge base. If for example

K(X) :- A(X), m(X).

has just been added and

h(a).

is already in the chart or the knowledge base, the completer will produce k(a) :- m(a). just as in the previous example.

Figure 6.10 shows this process in action. Clauses are arranged in sets. First the predictor works on a set, producing the next set of new clauses; then the completer works on all the clauses in that set, producing the next set; then the predictor operates again; and so on.

Earley deduction is slower and requires more memory than ordinary Prolog deduction. Even with simple computations, the chart can become quite large, and the process of searching it, quite time-consuming. Further, even Earley deduction can loop on rules of the form

because neither X nor £ (X) subsumes the other, leading to the same problem as with grammars in the previous section.

<!-- page 204 -->
All this reminds us of the fact that Prolog was never meant to be a perfect inference engine in the first place; instead, it was a deliberate compromise between logical purity

**Parsing Algorithms — Chap. 6**

Knowledge base: 1. a(a,b). a(b,c) 3 a(X,Z)

```prolog
:- a(X,Y), a(Yy,Z).
```

Query: 4, start :- a(a,c).

Predictor: 5. a(a,c) :- a(a,Y0), a(Y0,c).

from 4 and 3 6. a(a,Y0) :- a(a,Y1), a(Y1,¥Y0).

from 5 and 3 (Loop checker intervenes here, to prevent deriving a redundant clause from 6 and 3.)

Completer: 7. a(a,c) :- a(b,c).

from 5 and 1 8. a(a,c).

**from**

**7 and 2**

9. start.

from 8 and 4 (This is a solution to the original query; computation could stop here, or continue in order to look for other solutions.)

Predictor: 10. a(b,c) :- a(b,Y2), a(¥2,¢c).

from 7 and 3 ll. a(b,Y2) :- a(b,Y3), a(¥3,¥2).

from 10 and 3 (Loop checker intervenes here, to prevent deriving a redundant clause from 11 and 3.)

Completer: 12, a(b,c) :- a(c,c).

**from 10 and**

2 13. a(b,Y2) :- a(c,Y2).

**from 11 and**

**3**

Predictor: 14. a(c,c) :- a(c,Y4), alv4,c).

**from 12 and**

**3**

1S. a(c,¥2) :- a(c,¥5), a(v5,¥2).

from 13 and 3 (Loop checker intervenes.)

Completer: No further action (nothing matches a(c,Y4) or a(c,Y5) ).

Predictor: No further action (no new clauses).

Figure 6.10 Earley deduction in action. This computation would loop in ordinary Prolog.

**and speed. By not storing lemmas or checking for loops, Prolog runs faster and in less**

**memory than more sophisticated inference engines.**

<!-- page 205 -->
Exercise 6.6.11.1 (project) Implement Earley deduction as an inference engine for Prolog clauses that do not contain cuts. Evaluate the performance of your implementation. 6.7 WHICH PARSING ALGORITHM IS REALLY BEST?

**6.7.1 Disappointing News about Performance**

**Table 6.1 presents a piece of sad news. It shows the times taken by the parsers in this**

**chapter to parse, 100 times, the 24 sentences generated by the grammar**

**S**

**—+**

**NP VP**

**NP +> DN**

**VP —+**

**VNP**

**PP**

—-+

**PNP**

**D ->**

the

**P**

-—+~-

**near**

**N -—**

**dog, cat**

**V —>_**

chases, sees

**which is a subset of the grammar in Figure 6.1.”**

**TABLE 6.1 COMPARISON OF SPEED OF VARIOUS PARSERS.**

Time (in seconds) to parse 24 sentences 100 times*

**ALS Prolog**

Quintus Prolog

Parser

20-MHz 80386

Sparcstation 1+

**DCG rules**

3.4

0.3 Top-down interpreter

6.0

1.2 Bottom-up (shift-reduce)

38.3

8.4 Left-corner (no links)

12.7

2.6 Left-corner (with links)

12.0

2.5 BUP (no links, no chart)

38.5

8.4 Chart (no completeness check)

47.2

20.5 Chart (with completeness check)

59.3

27.3 Chart (with subsumption check)

71.3

32.2 Earley (no subsumption check)

320.3

144.5 Earley (with subsumption check)

989.8

172.0

“Caution: These data were obtained with a very small grammar. See text before drawing any conclusions!

**The sad news is that as the algorithms get “better” the parsing gets slower and**

**slower. Top-down parsing is very fast; left-corner parsing is second best; but shift-**

**reduce parsing and all the chart parsers are regrettably slow, to the point that Earley’s**

**algorithm with subsumption is intolerable.**

<!-- page 206 -->
The procedure was to parse the set of 24 sentences once (to allocate memory), start timing, parse the same set 100 more times, and stop timing. The test routine performed a cut after parsing each sentence.

Parsing Algorithms

Chap. 6 What’s going on here? Several things:

**e LACK OF OPTIMIZATION. Recall that the parsers in this chapter were not designed**

**for speed. Only DCG and BUP compile the grammar rules into executable Prolog**

clauses; the others store the rules as Prolog facts and manipulate them at run time. Further, no attempt has been made to fully exploit first-argument indexing or to use the most efficient data structures. e SMALL GRAMMARS. These tests were run with a very small grammar. That’s one reason chart parsing comes out so badly. In the test sentences, there is little ambiguity and hence little benefit from using the chart. But the cost of constructing the chart is large, especially when it is built using assert. Pereira and Shieber (1987:196-210), Ross (1989:217-246), and Simpkins and Hancox (1990) present chart parsers in which the chart is passed along in arguments of procedures. In any case, the chart would be much more helpful with a larger grammar.

But Shann (1991) reports that even with large grammars, Earley’s algorithm remains quite slow; left-corner parsing and Tomita’s bottom-up algorithm run much faster. e SuBsuMPTION. A third factor is that subsumption checking is rather costly, for two reasons. First, the subsumption checker itself is inefficient (except in Quintus, where it is built in). Second, the subsumption check limits the use of first-argument indexing. Instead of looking directly at the chart for an entry that matches the current goal, the subsumption-checking parser must instead retrieve all the chart entries for the current position, one by one, and run them through the subsumption checker. This means that indexing can’t prevent some unnecessary entries from being retrieved.

<!-- page 207 -->
The lesson to be learned is that parsing isn’t easy. Both backtracking, and charts that reduce backtracking, are costly. But there is another way to approach this problem. Any nondeterministic parser can be improved by adding an ORACLE or TABLE that keeps it from trying grammar rules that won’t succeed. This is particularly the case with the shift-reduce parser, which otherwise spends too much time searching through all the tules. A parser with an oracle goes through a series of numbered states. In each state, the oracle looks ahead at the next word in the input string and tells the parser what grammar tule to use and what state to go into next. If this process were deterministic, it would be like the LR(1) parse tables commonly used by programming-language compilers (Aho and Ullman 1972:368~399), but as Nilsson (1986) points out, the language need not be deterministically parsable; Prolog can still backtrack if it needs to. Not only does an oracle reduce backtracking, it also enables a shift-reduce parser to handle null constituents (D > Y) without looping, because the parser can only “accept” a null constituent in places where the table allows one. For a clear exposition of shiftreduce parsing with an oracle, see Pereira (1985). In any case, the data in Table 6.1 should serve as a warning. Not every “efficient” parser is actually fast; testing is always appropriate. Exercise 6.7.1.1

What is the difference between table-driven (oracle-driven) parsing and tabular parsing?

Exercise 6.7.1.2 (project)

Take one of the parsing algorithms presented in this chapter and make it work as efficiently

as possible with a reasonably large grammar. Support your claims with actual tests.

Exercise 6.7.1.3

(project)

Test some published parsers written in Prolog for which efficiency is claimed, and see if

they are as fast as DCG with a moderately large grammar.

6.7.2 Complexity of Parsing

Earley’s algorithm made history because it proved that phrase-structure parsing could be done in POLYNOMIAL TIME, i.e., in time proportional to n*, where n is the length of the input string and k is some constant. Further, Earley proved that k < 3.

This is important because recursive-descent and shift-reduce parsers take, in the worst case, EXPONENTIAL TIME, i.e., time proportional to k” (which, for large n, is much greater than n°).

Recursive-descent and shift-reduce parsers take exponential time because they try out each possible parse tree separately. With some grammars, every string of n words can have k” different parse trees, of which only the last one can be used in further parsing. Earley’s algorithm gets around this limitation by trying all the parse trees concurrently, so that many of its actions apply to more than one parse tree.

Generally, polynomial-time algorithms reflect principled solutions to a problem, while exponential-time algorithms reflect brute-force combinatorial search. Thus, Earley’s algorithm shows that parsing can be done in a principled way, not just by trying all possible combinations one after another.

These famous results are less important than they appear, for several reasons. First, natural-language parsers never face large values of n. Even exponential-time parsers can be quick when n is small, and in real life, sentences of more than 30 words are uncommon. When long sentences do occur, they can usually be broken up into shorter sentences that are joined by words like and, and parsable separately.

Second, the n? and k” results apply only to the worsT CASE, i.e., the situation in which the parser “guesses wrong” as much as possible and uses the right rule only after trying all the wrong ones. It is common for a k”-time parser to take much less than k” time on any particular parse, because it is almost certain to guess right some of the time and thereby avoid unnecessary work.

<!-- page 208 -->
Third, and most importantly, the 73 result holds only for grammars in which nodes do not have arguments. Barton, Berwick, and Ristad (1987) proved that parsing, in the general case, is NP-coMPpLETE—that is, belongs to a class of problems that are believed to take exponential time—if grammars are allowed to have agreement features (i.e., arguments on nodes, such as singular and plural, together with agreement rules),

Parsing Algorithms

Cha and if words can be ambiguous (like deer, which is ambiguously singular or plural). A natural-language grammars do need these capabilities.

**On consideration, this is not unreasonable. There are sentences which even hum’**

beings cannot parse. Consider Barton, Berwick, and Ristad’s example:

BUFFALO BUFFALO BUFFALO BUFFALO BUFFALO

Give up? The structure is exactly like Boston cattle bewilder Boston cattle. No that I’ve told you this, you probably have no trouble parsing it. And this is a hallmark NP-complete problems: even though a solution cannot be found efficiently, neverthele if you find a solution somehow, it can be verified quickly. What buffaloes us here is, course, the multiple ambiguity of each of the words.

Progress in developing more efficient parsers, then, apparently depends on tw : things: the careful study of complexity in typical or average cases (not in the theoretic worst case, which is admittedly intractable), and the discovery of as-yet-unexploited: constraints on natural-language grammars.

: Exercise 6.7.2.1

Show that, with the grammar

NP —+

DWNy,g (and NP)

**NP — DN, (and NP)**

D

-—- - the

Nsg

—> — sheep, deer, quail (etc.)

**Ny — — Sheep, deer, quail (etc.)**

every NP containing n ambiguous nouns (such as the deer and the quail and the sheep) has

2” different parse trees. (Hint: What happens to the number of Parse trees every time an

ambiguous noun is added to the phrase?)

Exercise 6.7.2.2

Suppose that one parser takes 1.5” seconds to parse an n-word sentence, while another

parser takes 2.5 x n? seconds. For what values of n is the exponential-time parser faster?

(Compute some actual numbers and make a table.)

Exercise 6.7.2.3

(For students who know calculus.) Show that, for any constant k > 1 and for sufficiently

**large n, k" > n*. (Find the value at which k” = n* and then compare the rates at which k”**

and n* grow as n increases.)

Exercise 6.7.2.4

Examine some English sentences in an actual text (perhaps this book). How long is the

longest sentence that does not break up into conjoined shorter sentences? What can you

<!-- page 209 -->
observe about the statistical distribution of sentence length? Exercise 6.7.2.5

Consider the sentences:

There are pigs in the pen.

There is ink in the pen.

Clearly, pen needs two lexical entries, one with each of two meanings. What could be done

to guide the parser to the right lexical entry in each case, so that it doesn’t have to try both

of them? (Hint: Consider what it is like when you, as a human being, hear and understand

one of these sentences.)

6.7.3 Further Reading

Parsing is a big field, and this chapter has sampled only a small part of it. A vast number of different parsing techniques have been developed, some for natural language, some for programming languages, and some for both. Some good general surveys of naturallanguage parsing are Winograd (1983), Kay (1980), King (1983), Dowty, Karttunen, and Zwicky (1985), and Tomita (1991). On parsing in Prolog, see, besides the references given throughout this chapter, Dahl and Saint-Dizier (1985, 1988), Abramson and Dahl (1989), and Gal, Lapalme, Saint-Dizier, and Somers (1991).

In this chapter we have looked at parsers designed to handle arbitrary sets of PS rules. But human languages have a structure all their own. PS rules in human languages are constrained in ways that are not yet well understood, and human languages involve many phenomena that PS rules by themselves can’t handle. Marcus (1978, 1980) inaugurates an important line of research on parsers designed specifically for human languages. Marcus’ parser has no backtracking and limited lookahead; it gives special treatment to NP nodes; and its performance on structurally ambiguous sentences is surprisingly humanlike (see also Kac 1982). More recent “principle-based parsers” deduce the rules of grammar (PS rules, case assignment, etc.) from more abstract principles (Berwick, Abney, and Tenny 1991). Tomita (1986), with more modest goals, presents a bottom-up chart parser optimized to deal with the fact that natural-language utterances are short (usually under 30 words) but have a lot of structural ambiguity.

In many languages, word order is partly or completely variable. For example, the Russian translation of the dog sees the cat is sobaka vidit koshku with the three words in any order depending on the desired emphasis. PS rules do not work well for such languages, and a variety of other approaches have been taken; see Abramson and Dahl (1989:150-153), Covington (1990), and Kashket (1991).
