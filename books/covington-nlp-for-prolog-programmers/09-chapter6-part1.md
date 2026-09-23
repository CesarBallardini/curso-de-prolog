# Chapter6_Part1

<!-- page 165 -->
**Parsing Algorithms**

**6.1 COMPARING PARSING ALGORITHMS**

So far, all our parsers have relied on Prolog’s built-in DCG translator as discussed in Chapter 3. In this chapter we will implement a number of parsing algorithms for ourselves. Parts of this chapter are heavily indebted to Pereira and Shieber (1987), who describe several algorithms in more detail.

We will take advantage of the fact that, in Prolog, backtracking is automatic. This makes Prolog ideal for implementing parsers and seeing clearly how they work. Most parsers need to backtrack, but most programming languages make backtracking rather hard to implement. This means that, in ordinary programming languages, the core of any parser is likely to be hidden under a large, cumbersome backtracking mechanism.

All our parsers will use the grammar shown in Figure 6.1, except for certain rules that particular parsing algorithms can’t handle.

**6.2 TOP-DOWN PARSING**

<!-- page 166 -->
Let’s start with top-down recursive-descent parsing. This is the same algorithm used by the DCG system, but we will implement it differently. The DCG system is a COMPILER for

Parsing Algorithms

Chap. 6 ©

**— NP VP**

**NP**

**NP**

**> DN**

**—> NP Conj NP**

(not for top-down parsers)

VP —>

**VNP (PP)**

**PP**

**~> PNP**

wee) — ©

(not for bottom-up parsers) — the, all, every

—>

near

Conj —>

and

**— dog, dogs, cat, cats, elephant, elephants**

Figure 6.1

A sample grammar for — chase, chases, see, sees, amuse, amuses

experimenting with parsers.

grammar rules—it translates them directly into executable Prolog clauses. For example,

So

—>

Mp, vp.

goes into memory as something like this:

```prolog
8(LI,L) :- np(LLL2), vp(L2,L).
```

What we’re going to build is an INTERPRETER for grammar rules. Instead of executing the rules directly, it will store them as facts in a knowledge base and look them up as needed. Execution will be a little slower, but the parser will be much easier to modify. We’ll represent PS rules as

rule(s, [np,vp]). rule(np,[d,n]). rule(d,[]).

and the like. Lexical entries will look like this:

word (d,the) word (n, dog)

```prolog
word(n,dogs).
```

word(n,cat)

```prolog
word(n,cats).
```

word(v, chase) .

**word**

(v, chases).

<!-- page 167 -->
This format works conveniently with a variety of parsing algorithms; we’ll be able to transfer the set of rules with little or no change from one parser to another. Now recall how top-down parsing works. To parse The dog barked, the parser, in effect, says to itself:

— I’m looking for an S. — To get an S, I need an NP and a VP. — To get an NP, I need a D and an N. — To get a D, I can use the ... Got it. — To get an N, I can use dog ... Got it. — That completes the NP. — To get a VP, I needa V. — To get a V, I can use barked ... Got it. — That completes the VP. — That completes the S.

To get a feel for what’s going on, try drawing the tree as you work through these steps. Figure 6.2 shows the order in which a top-down parser discovers the various parts of the tree.

START ™, Za SA WA

V

**ie**

Figure 6.2 Top-down parsing. The parser

discovers the nodes of the tree in the order The dog

chased

Cat

shown by the arrows.

<!-- page 168 -->
Like the DCG system, our parser will work through the input string, accepting words one by one. Let C represent the kind of constituent the parser is looking for at any particular moment (an S, NP, V, or whatever). Then the algorithm to parse a constituent of type C is:

e If C is an individual word, look it up in the lexical rules and accept it from the

input string.

e Otherwise, look in the PS rules to expand C into a list of constituents, and parse

those constituents one by one.

Or, putting it into Prolog:

oe

parse(?C,?S1,?S) oe de oe

Parse a constituent of category C

starting with input string $1 and

ending up with input string Ss.

parse(C, [Word|S],S) :-

```prolog
word(C,Word).
```

parse(C,S1,S) :-

```prolog
rule(C,Cs),
parse_list(Cs,S1,S).
```

Here parse_list is just like parse except that it takes a list of constituents and parses all of them:

parse_list([ClCs],S1,S) :-

```prolog
parse(C,S1,S2),
parse_list(Cs,S2,S).
```

parse_list([],S,S).

That’s the whole parser. The query to parse a sentence looks like this:

?- parse(s, [the,dog,barked],[]).

Notice that backtracking, where needed, occurs automatically.

Exercise 6.2.0.1

Get this parser working and equip it with all the grammar rules in Figure 6.1 except for

**NP — NP Conj NP. Use it to parse sentences such as All dogs amuse the elephant.**

Exercise 6.2.0.2

<!-- page 169 -->
In this parser, why is D ~ @ encoded as a PS-rule rather than as a lexical entry? Exercise 6.2.0.3

By adding arguments to nodes (as in Chapter 3, section 3.4), make the parser enforce subject-verb number agreement and build a representation of the parse tree. (Hint: This is easy; only the rules need to be modified.)

Exercise 6.2.0.4

(Not for courses that skipped Chapter 5.) Combine Mini-GULP with this parser. Account for number agreement of subject and verb, and of determiner and noun, using GULP feature structures.

Exercise 6.2.0.5 Modify the parser so that it always builds a representation of the parse tree, even with the rules in their original form (without arguments). (Hint: Add extra arguments to parse and parse_list.)

6.3 BOTTOM-UP PARSING

6.3.1 The Shift-Reduce Algorithm

A familiar limitation of top-down parsers is that they loop on LEFT-RECURSIVE rules of the form A — A B (“to parse an A, parse an A and then ...”). Yet, as we saw in Chapter 4, such rules occur in natural language; one example is NP — NP Conj NP, where Conj is a conjunction such as and or or. One way to handle left-recursive rules is to parse BOTTOM-UP. A bottom-up parser accepts words and tries to combine them into constituents, like this:

— Accept a word ... it’s the. — The isaD. — Accept another word ... it’s dog. — Dog is anN. — D and N together make an NP. — Accept another word ... it’s barked. — Barked is a V. — V by itself makes a VP. — NP and VP make an S.

<!-- page 170 -->
Again, try drawing a tree while working through these steps. (During most of the process it will of course be a set of partial trees not yet linked together.) You’ll find that you encounter the various parts of the tree in the order shown by the arrows in Figure 6.3.

**Parsing Algorithms**

**Chap. 6**

**VP**

**D**

**N**

**V**

**NP**

**D**

**N**

**START ~~,**

**\**

**The**

**dog**

**chased**

**the**

**cat**

Figure 6.3 Bottom-up parsing. The parser discovers the nodes of the tree in the order shown by the arrows.

**Because its actions are triggered only by words actually found, this parser does not**

loop on left-recursive rules. But it has a different limitation: it cannot handle rules like

**D+>g@**

**because it has no way of responding to a null (empty, missing) constituent. It can only**

**respond to what’s actually there.**

**The bottom-up algorithm that I’ve just sketched is often called SHIFT-REDUCE pars-**

**ing. It consists of two basic operations: to sHiFT words onto a stack, and to REDUCE**

**(simplify) the contents of the stack. Here’s an example:**

Step

Action

Stack

Input string

(Start)

the dog barked 1

Shift

the

dog barked 2

Reduce

**D**

dog barked 3

Shift

**Ddog**

barked 4

Reduce

DN

_

barked 5

Reduce

**NP _ barked**

6

Shift

**NP barked**

7

Reduce

**NP V**

8

Reduce

**NP VP**

9

Reduce

<!-- page 171 -->
Ss

**So the shift-reduce algorithm is as follows:**

1. Shift a word onto the stack.

**2. Reduce the stack repeatedly using lexical entries and PS rules, until no further**

reductions are possible.

**3. If there are more words in the input string, go to Step 1. Otherwise stop.**

**A noteworthy feature of shift-reduce parsing is that it has no expectations. That**

**is, you can give it an input string and say, “What kind of constituent is this?” and get**

**an answer. You do not have to say “Parse this as an S” or “Parse this as an NP.”**

Exercise 6.3.1.1

By hand, using the grammar in Figure 6.1, do shift-reduce parsing on the following input

strings:

:

. the dogs amuse the elephants

see the cat near the dog

the dogs and the cats

**Pepe**

the dogs the dogs the dogs

What happens in the last of these?

**6.3.2 Shift-reduce in Prolog**

Efficient shift-reduce parsing in Prolog requires a couple of subtle techniques. The first of these is to build the stack backward. That is, shift words from the beginning of the input string to the beginning of the stack, so that they end up in reverse order, thus:

Start:

[]

**(the,**

dog, barked] Shift:

[the]

[dog, barked] Reduce:

{[d]

[dog, barked] Shift:

[dog,d]

[barked] Reduce:

[n,d]

[barked] Reduce:

[np]

[barked] Shift:

[barked, np]

[] Reduce:

[v,np]

[] Reduce:

[vp, np]

[] Reduce:

[s]

C]

This is efficient because all the action is at the beginning of each list; there is no need to work all the way along a list to get to.the end.

**The second subtlety is that the “reduce” step goes a lot faster if the rules, too, are**

stored backward. For example,

**NP**

**> DWN**

<!-- page 172 -->
goes into Prolog as

brule([n,d|X],[np|X]). Here brule stands for “backward rule.” The first argument, [n, 4|X], directly matches the stack to which this rule applies, and [np |X] is what the stack becomes after reduction. With the rule written this way, unification does all the work.

So the “reduce” step in the parser is very simple: if there is an applicable rule, use it, and then try to reduce again; otherwise leave the stack unchanged. The rest of the parser is even simpler; the whole thing is shown in Figure 6.4. Exercise 6.3.2.1

Using the parser in Figure 6.4, what is the effect of each of the following queries? Consider

all possible solutions.

```prolog
?- parse([the,dog,chases,the,cat],[s]).
?- parse([the,dog,chases,the,cat], [What]).
?- parse([the,dog, chases,the,cat] ,What).
```

Exercise 6.3.2.2

Why isn’t there a cut in the first clause of reduce?

Exercise 6.3.2.3

Extend the parser in Figure 6.4 to contain all the grammar rules in Figure 6.1 except for

**D — 9. Then use it to parse the input strings from Exercise 6.3.1.1.**

Exercise 6.3.2.4

Add features to the shift-reduce parser to enforce subject-verb number agreement and: build

a representation of the parse tree. As before, only the rules need to be modified.

Exercise 6.3.2.5

(Not for courses that skipped Chapter 5.) Combine Mini-GULP with this parser. Account

for number agreement of subject and verb, and of determiner and noun, using GULP feature

```prolog
structures.
```

Exercise 6.3.2.6

**What, exactly, does a shift-reduce parser do if it tries to use a rule like D > @?**

**6.4 LEFT-CORNER PARSING**

**6.4.1 The Key Idea**

<!-- page 173 -->
Left-corner parsers are often described as bottom-up, but left-corner parsing is actually a combination of bottom-up and top-down strategies. This technique was popularized oe

Bottom-up shift-reduce parser

**parse**

(+S, ?Result)

parses input string S, where Result of AP oP

is list of categories to which it reduces.

parse(S,Result) :-

```prolog
shift_reduce(S,[],Result).
shift_reduce(+S,+Stack,
                         ?Result)
```

parses input string S, where Stack is a ae oe

list of categories parsed so far.

shift_reduce(S,Stack,Result) :-

shift (Stack,S,NewStack,S1),

```prolog
% fails if S = []
```

reduce (NewStack, ReducedStack),

shift_reduce(S1,ReducedStack,

Result).

shift_reduce([],Result,Result).

% shift (+Stack,+S,-NewStack,

-NewS) %

shifts first element from S onto Stack.

shift (X, [H|Y], [HIX],Y).

reduce (+Stack, ~-ReducedStack) ae oe oe

repeatedly reduces beginning of Stack

to form fewer, larger constituents.

reduce (Stack, ReducedStack) :-

brule (Stack, Stack2),

reduce (Stack2,ReducedStack)

.

reduce (Stack, Stack) .

% Phrase structure rules

brule([vp,np!X],{[s|X]). brule([n,d|X],[np|X]). brule([np,v|lX],[vp|X]).

brule([Word|X], [Cat|X]) :- word(Cat,Word)

.

2 % Lexicon

word(d,the).

word(n,dog).

```prolog
word(n,dogs).
```

word(n,elephant).

```prolog
word(n,elephants).
```

word(v,chase).

```prolog
word(v,chases).
```

word(v,see).

```prolog
word(v,sees).
```

% etc.

<!-- page 174 -->
Figure 6.4 Shift-reduce parser.

Parsing Algorithms — Chap. 6 by Rosenkrantz and Lewis (1970) and Aho and Ullman (1972:310-314), all of whom attribute it to Iroris (1961).

The key idea is to accept a word, figure out what kind of constituent it marks the beginning of, and then parse the rest of that constituent top-down. The tree is thus discovered starting at the lower left corner, as shown in Figure 6.5.

**START ™,**

S

V

The

Figure 6.5 Left-corner parsing. Note that

some nodes are visited twice, once working

dog

chased

the

Cat

top-down and once working bottom-up.

Like a top-down parser, a left-corner parser is always expecting a particular constituent and therefore knows that only a few of the grammar rules are relevant. This can give it an efficiency advantage over straight bottom-up parsing.

**But like a bottom-up parser, the left-corner parser can handle rules like A > A B**

without looping, because it starts each constituent by accepting a word from the input string.

6.4.2 The Algorithm The algorithm consists of two parts: accepting and identifying a word, and then completing the constituent.

To parse a constituent of type C:

1. Accept a word from the input string and determine its category. Call its category

W.

**2. Complete C. If W = C, you’re done. Otherwise,**

<!-- page 175 -->
e Look at the rules and find a constituent whose expansion begins with W. Call

that constituent P (for “phrase’”’). For example, if W is Determiner, use the rule

**NP -—> D N and let P be Noun Phrase.**

e Recursively left-corner-parse all the remaining elements of the expansion of P.

(This is the top-down part of the strategy.)

e Last, put P in place of W, and go back to the beginning of step 2 (i.e., start

over trying to complete C).

All of this is easier to describe in Prolog than in English. Rules will be represented as they were with our top-down parser:

rule(s, [np,vp]). rule(np,[d,n]).

```prolog
% etc.
```

word(n,dog).

```prolog
word(n,dogs).
```

word(n,cat).

```prolog
word(n,cats).
                % etc.
```

and so on. To tackle any constituent, the parser first accepts a word, then completes the constituent, thus:

oe

parse(+C,+S1,-S) oP Ae ae

Parse a constituent of category C

starting with input string S1 and

ending up with input string S.

parse(C, [Word!S2],S) :-

word(W,Word),

complete(W,C,S2,S).

Again, we have parse_list, which parses a list of constituents:

parse_list([C|Cs],S1,S) :-

```prolog
parse(C,S1,S2),
parse_list(Cs,S2,S).
```

parse_list([],S,S).

The only nontrivial procedure is complete, defined as follows:

oe

complete (+W,+C,+S1,-S) oe oe

Verifies that W can be the first subconstituent

of C, then left-corner-parses the rest of C.

complete(C,C,S,S).

```prolog
% if C=wW, do nothing.
```

<!-- page 176 -->
complete(W,C,S1,S) :rule(P, [W|Rest]), parse_list(Rest,S1,S$2), complete(P,C,S2,S).

Exercise 6.4.2.1 Get this parser working with all the grammar rules from Figure 6.1 except D > @.

Exercise 6.4.2.2 Add arguments to the nodes in the rules so that this parser will build a representation of the tree and enforce subject-verb number agreement. (Easy—just copy the modified rules from Exercise 6.2.0.3.)

Exercise 6.4.2.3 Modify this parser so that it builds a representation of the tree by itself, without requiring any arguments in the rules.

Exercise 6.4.2.4 (Not for courses that skipped Chapter 5.) Combine Mini-GULP with this parser. Account for number agreement of subject and verb, and of determiner and noun, using GULP feature structures. (Easy—copy the rules from Exercise 6.2.0.4.)

Exercise 6.4.2.5 Modify complete so that it can handle null constituents in the portion of the tree that it encounters top-down. Then modify the grammar so that the only rule expanding NP is NP — DN PP where PP > @. In your modified parser, rule (pp, []) should allow the parser to skip the PP without trying to parse it.

Exercise 6.4.2.6 What does the left-corner parser do when asked to “generate a sentence” by a query such as the following?

?- parse(s,What,[]).

Recall that this query does indeed generate a sentence with the original top-down parser. 6.4.3 Links

| As described so far, the left-corner parser is only partly able to handle rules that introduce null constituents, such as D > Q, If the null constituent is encountered while parsing top-down, there is no problem. The left-corner parser works just like a top-down parser. This is the situation with rules of the form

**A —> BC**

**Cc > @**

<!-- page 177 -->
**because the C gets parsed top-down. All that is necessary is to tell parse/3 that if**

it’s looking for a C, it can simply skip ahead without parsing anything. This could be accomplished by encoding the rules as

rule(a,[b,c]). rule(c,[]).

and adding the following clause to parse:

parse(C,$2,S) :-

rule(W,[]),

complete(W,C,S2,S).

**That is: “If W is a category that can be a null constituent, then it is permissible to**

‘complete’ a W at any time by doing nothing.”

Unfortunately, this is not what we need for English. Our best-established null constituent is the null determiner, which occurs at the beginning of a noun phrase and will therefore be parsed bottom-up. That is, the rules are

S

—->

**NP VP**

NP

—+>

**DN**

**D-—>**

G6

and these tell the parser to accept the null determiner as the very first step of parsing an S or NP.

8

With rules like these, the parser loops. The problem arises whenever it tries a parse that does not succeed. Suppose the parser is looking for a VP but the VP isn’t there. This means the parser can’t accept the first word of the VP, which could only be a verb. Instead, it “accepts” a null determiner and hypothesizes the structure:

VP

**_—**

?

NP

**LN**

|

**N**

0)

**Next it tries to complete the NP by parsing the N top-down. But suppose the N isn’t there**

<!-- page 178 -->
either. The parse ought to have failed by now, but in fact the parser has an alternative:

Chap. 6. it can “accept” another null determiner and try to complete another phantom NP. And of course this will again fail the same way, and the same action will occur over and over,

The problem is that, like a bottom-up parser, the left-corner parser is allowed to “accept” null constituents anywhere it wants to. The solution is to constrain the parser by adding a table of Linxs. Besides solving the null-constituent problem, the links make the parser more efficient.

The table of links specifies what kinds of constituents can appear at the beginning of what. For example, from the rules

S

—+ NP VP

**NP +> DN**

VP —+

**VNP**

we can infer the links:

link(np,s). link(d,np). link(d,s). link(v,vp)

. link (X,X).

The last of these says that any constituent can begin with itself; it applies when, for example, the parser is looking for an N and is also about to accept an N.

**We modify parse/3 so that there has to be a link between the constituent it is**

looking for and the word it is trying to accept, thus:

parse(C, [Word|S2],S) :-

word (W,Word),

link(W,C),

complete(W,C,S2,S).

parse(C,S2,S) :-

rule(W,[]),

% for null constituents

link(W,C),

complete(W,C,S2,S).

This solves the problem because now the parser can only accept a null determiner if it’s already looking for an S or an NP. It can’t “accept” null determiners willy-nilly in arbitrary locations.

**A left-corner parser can still loop on a set of rules of the form**

A —+

**BA**

**Bs**

**@**

<!-- page 179 -->
but in this case the looping is really the fault of the rules, not of the parser. These rules really do specify an infinite number of different parses for each string: an A can consist of a null B followed by another A, or of two null Bs followed by another A, or of three null Bs followed by another A, ad infinitum. So infinite backtracking is really the correct thing to do with a grammar of this form. When the grammar specifies an infinite number of parses, one can hardly fault the parser for trying to find them all.

Exercise 6.4.3.1

**Add D —**

@ to your left-corner parser and observe what happens. Try to parse both gram-

matical and ungrammatical sentences.

Exercise 6.4.3.2

Construct a table of links for the entire grammar in Figure 6.1. Add the table of links to

your parser and demonstrate that the entire grammar can now be parsed.

Exercise 6.4.3.3

Define a predicate generate_links/0 that looks at the rules in a grammar, generates

the links automatically, and asserts them into memory.

Exercise 6.4.3.4

**Even**

**in grammars without null constituents, links can make the parser more efficient. Give**

an example of how this

is so.

**6.4.4 BUP**

**Perhaps the best-known implementation of left-corner parsing in Prolog is BUP, devel-**

oped by Matsumoto, Tanaka, Hirakawa, Miyoshi, and Yasukawa (1983).

**In BUP, each PS rule goes into Prolog as a clause whose head is not the mother**

node, but rather the leftmost daughter. Thus

**NP — DWN PP**

becomes

d(c,S1,S) :- parse(n,S1,S2), parse(pp,S2,S3), np(C,S3,S).

**That is: “If you’ve just completed a D, then parse an N and PP. Then call the procedure**

**for dealing with a completed NP.” Here C is the higher constituent that the parser is**

**trying to complete, and S1, $2, S3, and S are the input string at various stages.**

**In addition to a clause for each of the PS rules, BUP needs a “terminating clause”**

for every kind of constituent, for example:

<!-- page 180 -->
np(np,S,S). n(n,S,S). d(d,S,S). vp(vp,S,S). vi(v,S,S). s(s,S,S).

Chap. 6 Each of these means something like, “If you’ve just accepted an NP and an NP is what — you were looking for, you’re done.”

**BUP gets its efficiency from the fact that the hard part of the search—i.e., figuring**

out what to do with a newly completed leftmost daughter—is handled by Prolog’s fastest search mechanism, namely the mechanism for finding a clause given the predicate.

**Figure 6.6 shows a complete, working BUP parser, without links. Note that, as**

required by most Prologs, all the clauses with a particular predicate are grouped together. Matsumoto and colleagues use the names goal and dict for the predicates that we have called, respectively, parse and word. Their full BUP implementation includes

% BUP left-corner parser, without links, without chart

oe

parse(+C,+S1,-S) oe oe

Parse a constituent of category Cc starting with input

string Sl and ending up with input string S.

parse(C,S1,S) :-

word(W,S1,S2),

P=.. [W,C,S2,S],

call (P).

% PS rules and terminating clauses

np(C,S1,S) :- parse(vp,S1,S2), s(C,S$2,S).

```prolog
% S --> NP VP
```

np(np,X,X).

;

oe d(C,S1,S) :- parse(n,$1,82), np(C,S2,S8).

**NP --> DN**

d(d,X,X).

v(C,S1,S) :- parse(np,S$1,S2), vp(C,S2,S).

.

```prolog
%& VP --> V NP
```

vi(v,X,X).

s(s,X,X).

ca vp(vp,X,X).

2 pp(pp,X,X). n(n,X,X).

% Lexicon

word (d, [the|X],X). word (n, [dog|X],X). word(n,

[cat |X],X). word(v, [chases|X],X).

```prolog
  % etc.
Figure 6.6 A working BUP parser.
```

<!-- page 181 -->
Sec. 6.5

Chart Parsing

167

links and a chart (see next section). For subsequent developments, see also Okunishi et al. (1988).

Exercise 6.4.4.1 Add rules to the parser in Figure 6.6 to cover the complete grammar from Figure 6.1, except for D — %. Demonstrate that the parser works.

Exercise 6.4.4.2 In your parser from the previous exercise, add arguments to nodes to enforce subject-verb number agreement and build a representation of the tree during parsing.

Exercise 6.4.4.3 Add links to BUP by putting calls to link/2 in each phrase structure rule as well as in the clause for goal itself.

Exercise 6.4.4.4 (small project) The slow part of BUP is now the execution of ‘=..’ and call/1

in parse. Eliminate them. This requires major rearranging because now W (in parse) cannot be the predicate of the procedure that gets called; instead it must be an argument. Use first-argument indexing to good advantage. Compare the speed of the old and new parsers.

Exercise 6.4.4.5

(project) Write a program that accepts a set of PS rules, in whatever notation you find most convenient, and generates a BUP parser for them.

**6.5 CHART PARSING**

**6.5.1 The Key Idea**

Consider the rule

**VP — V NP (PP)**

**This goes into DCG as two rules:**

vp --> v, np. Vp --> V, Np, pp.

**Now consider the query:**

<!-- page 182 -->
?- vp([chased,the,cat,into,the,garden],[]).

Parsing Algorithms

Chap. 6

The parser tries the first rule, works through the structure

VP

**ae**

**V**

**NP**

**AN**

**ro**

chased

the

cat

and then realizes it hasn’t used up all the words. So it backs up, forgets all the work it has just done, chooses the second VP rule, and parses the same structure again. Then it goes ahead and parses the PP, giving:

VP

**eee**

V

NP

PP

**oO**

**—_**

**N**

P

NP

**—_**

chased

the

**cat**

into

**I**

**sae**

**Crucially, the parser had to parse the same V and NP twice. And that could have been**

**a lot of work—tecall how complicated an NP can be.**

**A CHART PARSER Of TABULAR PARSER is a parser.that remembers substructures that**

it has parsed, so that if it has to backtrack, it can avoid repeating its work. For example, the first time through, a chart parser would make a record that the cat is an NP. The second time through, when looking for an NP at the beginning of the cat into the garden, it would look at its records (the CHART) before using the NP rule. On finding [np the cat | in the chart it would not have to work through the process of parsing the NP.

**6.5.2 A First Implementation**

To save each constituent, the parser must record:

e what kind of constituent it is;

e where it begins; and

<!-- page 183 -->
e where it ends. One way to represent this information is to store, in the knowledge base, clauses such as:

chart (np, [the,cat,into,the, garden], [into, the, garden]) .

**This means: “If you remove an NP from the beginning of the cat into the garden you’re**

left with into the garden.” That is, the cat is a noun phrase.

The two lists represent positions in the input string. This is not the most concise or efficient way to represent positions, but it is the most readable to human eyes, and we will stick with it through most of this chapter.

**Now let’s modify our original top-down parser (Section 6.2) to use a chart. To do**

this, we modify parse/3 so that it looks like this:

parse(C, [Word|S],S) :-

```prolog
word(C,Word).
```

parse(C,S1,S) :-

chart (C,S1,S).

parse(C,S1,S) :-

```prolog
rule(C,Cs),
parse_list(Cs,S1,S),
asserta(chart(C,S1,S)).
```

The first clause deals with individual words, as in the original top-down parser. It’s faster to look up single words in the lexicon than to try to get them into the chart.

The second clause says, “If what you’re looking for is already in the chart, don’t parse it.” The third clause, using rule, is like the original except that it asserts a fact into the chart at the end.

Also, we need a way to discard the chart before starting a new sentence:

clear_chart :- abolish(chart/3).

Otherwise the chart would become cluttered with obsolete information. So now the usual query to parse a sentence looks like this:

?- clear_chart,

```prolog
parse(s, [the, dog, chased, the, cat,near,the,elephant],[]).
```

Finally, there is a minor technical problem to be dealt with. Normally, a chart parser will look at the chart before any clauses of chart have been asserted. In some Prologs, this causes an error message, which can be prevented by including, at the beginning of the program, a line such as

:- unknown (_,fail).

```prolog
% in Quintus Prolog
```

‘?ERROR’ (2,_) :- fail.

```prolog
%® in LPA (Quintus DOS) Prolog
```

<!-- page 184 -->
to tell the Prolog system that queries to nonexistent predicates should simply fail, rather than raising error conditions. It is not sufficient to declare chart as dynamic, because when clear_chart abolishes chart, it will abolish the dynamic declaration too.

Exercise 6.5.2.1

Get the chart parser working and use it to parse The dog chases the cat near the elephant.

What information is in the chart at the end of the parse?

Exercise 6.5.2.2

Modify your chart parser to display a message whenever the second clause of parse succeeds.

This will let you know when the chart is actually saving the parser some work. Parse The

dog chases the cat near the elephant again. What output do you get?

Exercise 6.5.2.3. (small project)

Chart parsers need not be top-down. Implement a bottom-up (shift-reduce) chart parser.

6.5.3 Representing Positions Numerically

We noted that storing whole lists in the chart, as in

chart (np, [the, cat, into, the, garden], [into,the,garden]).

is inefficient. The lists represent positions in the input string; they can be replaced by word counts (0 for the beginning of the string, 1 for the position after the first word, and so on), so that chart entries look like this:

chart (np,0,2).

**That is: “The NP begins when 0 words have been accepted, and ends when 2 words**

have been accepted.” Numbers are more efficient than lists because they are smaller, can be compared more quickly, and can be distinguished by first-argument indexing.

**If we do this, we can get rid of the input “string” altogether, and replace it by a**

set of facts about what words are in what positions. For example:

c(the,0,1). c(dog,1,2). c(sees,2,3). c(the,3,4). c(cat,4,5). c(near,5,6). c(the,6,7). c(elephant,7,8).

<!-- page 185 -->
It’s quicker to look these up than to repeatedly pick a list apart.

All this requires almost no change to the parser. The only difference is that parse/3 uses a slightly different method to accept a word:

parse(C,S1,S) :-

chart (C,S1,S).

parse(C,S1,S) :-

```prolog
c(Word,S1,S),
```

% this is the only change

```prolog
word(C,Word).
```

parse(C,S1,S) :-

```prolog
rule(C,Cs),
parse_list(Cs,$1,8),
asserta(chart(C,S1,8S)).
```

In one brief test, making this change sped up the parser about 30% with a simple grammar. If the grammar is more complex, the speed-up could be greater. On the other hand, it takes time to convert each sentence into a set of c/3 clauses.

Having introduced this technique, we will now put it aside, because in the rest of this chapter, it is much more important for the examples to be readable than for them to run fast. Converting the various chart parsers to use numeric positions is left as an exercise for the implementor.

Exercise 6.5.3.1

Get this parser working and measure the speed-up on your computer. To do this, you will

probably have to parse the same sentence hundreds or thousands of times; be sure to clear

the chart in between.

**6.5.4 Completeness**

As implemented so far, the chart parser can remember what it found, but it can’t remember what it failed to find. For example, it can remember that the cat is an NP, but it can’t remember that the cat is not a PP. This means that with a complex grammar, the parser can waste more time than it saves.

To parse any constituent, the parser first looks at the chart. If the chart doesn’t contain the constituent that it’s looking for, then the parser proceeds to do all the work that it would have done if there had been no chart in the first place. In such a case the chart doesn’t save it any work.

This situation arises mainly with fairly large grammars. Here is a simple example. Consider the phrase-structure rules

**VP -—»**

**VWNP (PP) (Adv)**

**NP + DN(PP)**

**PP > PNP**

<!-- page 186 -->
**This is really four VP rules—with and without PP and with and without Adv—as well**

as two NP rules, with and without PP.

Suppose the parser is parsing [yp saw the boy yesterday ]. Two different rules allow a PP to come after boy. Accordingly, the parser will make two attempts to find a PP at that position, and both attempts will fail. Each attempt will consist of a fair bit of work (invoking PP —» P NP, then looking at lexical entries for P, and failing to find yesterday among them). If, the first time through, the chart could record that a PP is definitely not present at that position, the second attempt to find one would be unnecessary.

There is also another reason why the chart needs to store negative information: unwanted alternatives. Every parse that can be found in the chart can also be found without using the chart. This means that, upon backtracking, the parser can often get the same constituent more than one way, and the number of alternatives to try grows exponentially.

**A much better approach is to use the chart only if it is complete for a particular**

**constituent type in a particular position. That is, if you’re looking for an NP at the**

beginning of the cat near the elephant, use the chart only if it is known to contain all possible NPs in that position. Otherwise, ignore the chart and parse conventionally. And if, when parsing conventionally, you fail to find what you’re looking for, then assert that the chart is complete for that constituent in that position, because there are no more alternatives to be found.

**We can record completeness by asserting facts such as**

complete(np, [the,cat,into,the,garden]).

Modified to work this way, parse looks like this:

parse(C, [Word|S],S) :-

```prolog
word(C,Word).
```

parse(C,S1,S) :-

```prolog
complete(C,S1),
| oF
chart (C,S1,S).
```

parse(C,S1,S) :-

```prolog
rule(C,Cs),
parse_list(Cs,S$1,S2),
asserta(chart(C,S1,S82)),
$2 = S.
```

parse(C,S1,_) :-

```prolog
asserta(complete(C,S1)),
fail.
```

<!-- page 187 -->
The first clause is as before. The second clause is as before except that it requires the chart to be complete, and if the chart is complete, it performs a cut so that the Sec. 6.5

Chart Parsing

**173**

**subsequent clauses won’t be used. The third clause is as before except that it passes S2**

**to parse_list uninstantiated, in an attempt to get as many alternatives into the chart**

**as possible, and then checks afterward whether S2=S. The last clause asserts that the**

chart is complete if all the other clauses have failed.

**It is also necessary to modify clear_chart to erase complete as well as**

**chart, thus:**

clear_chart :- abolish(chart/3), abolish(complete/2).

Exercise 6.5.4.1

Demonstrate the problem of unwanted alternatives. Using the parser from Section 6.5.2

(without completeness checking), execute the query:

```prolog
?- parse(s, [the,dog, chases, the,cat,near,the,elephant],[]),
   write(y),
   fail.
```

**How many y’s do you get? Why?**

Exercise 6.5.4.2

Modify the parser to include the completeness check and try the same query.

Exercise 6.5.4.3

**Why can’t there be a cut in the second clause of parse if the parser does not check for**

completeness? That is, in the parser in Section 6.5.2, why couldn’t that clause have been

as follows?

```prolog
parse(C,S1,S) :- chart(C,S1,S), !.
```

(Hint: Parse the dog chases the cat near the elephant.)

Exercise 6.5.4.4

As implemented, the chart parser tries to parse single-word categories (N, V, etc.) with

**chart and rule as well as with word. We can make parse faster by changing its first**

clause to:

```prolog
parse(C, [Word|S],S) :-
   word(C,_),
    | 4
   word(C,Word).
```

**What does this do to the search process? How does it affect the way we have rendered**

**D— 6?**

<!-- page 188 -->
6.5.5 Subsumption

If nodes have arguments, chart parsing runs into another problem. Suppose the parser is looking for np (X) and the chart contains np (singular) at the right position.. Should the parser use this chart entry? Definitely not. Doing so would instantiate X to the value | singular, which might be wrong.

To illustrate this problem is not particularly easy; there are no simple examples in English. It’s the kind of thing that crops up suddenly in the middle of a large project after dozens of other rules have worked correctly.

For the determined reader, however, here is a somewhat contrived example. Recall that one way to handle verb subcategorization is to assign the verbs to numbered classes. Consider, then, the following PS rules. For legibility, they are written in DCG format,

— although in our actual parser they would be clauses of rule/2.

:

vp --> verbal(0). vp --> verbal(X), rest_of_vp(X).

rest_of_vp(1}) --> np. rest_of_vp(2) --> np, np.

```prolog
% etc.
```

verbal (X) --> v(X).

v(0) --> [sleep]. v(l) --> [see]. v(2) --> [give].

```prolog
% etc.
```

Assume the usual expansions of np. Now execute the query:

?- clear_chart, parse (vp, [see, the, dog], []).

This parse should succeed, but it doesn’t. The first VP rule looks for a verbal (0) and, of course, doesn’t find it. So the chart is marked as complete for verbal (0) in that position:

complete (verbal (0), [see,the,dog]).

Now the second VP rule looks for verbal (X) in the same position, with X uninstantiated. And verbal (X) matches the stored verbal (0), so the parser thinks the chart is complete for verbal (X) as well.

The problem, of course, is that unifying verbal (X) with the stored verbal (0) is the wrong thing to do. The parser should instead check whether the stored category SUBSUMES the one it is looking for. We say that term A subsumes term B if and only if:

e A can be unified with B;

e When this is done, B is no more instantiated than it was before.

<!-- page 189 -->
For example, f (X,b) subsumes f (a,b), but f£(a,b) does not subsume £ (X,b) because performing the unification would instantiate X. Sec. 6.5

Chart Parsing

175

The Quintus Prolog built-in predicate subsumes_chk/2 succeeds if its first argument subsumes its second argument. With subsumption checking added, the second clause of parse becomes:

parse(C,S1,S) :complete(C0,S1), subsumes_chk(C0,C), !, co =¢C, chart (C,S1,S). Figure 6.7 gives an implementation of subsumes_chk for other Prologs. AP dP oP Subsumption checker. Based on code by R. A. O’Keefe in shared Edinburgh (later Quintus) library.

subsumes_chk(?T1,?T2) A dP dP oO Succeeds if term T1 subsumes T2, 1.e., Tl and T2 can be unified without further instantiating T2.

subsumes_chk(T1,T2) :- \+

( numvars(T2), \+ (TL = T2) ).

numvars (+Term) a dP de Instantiates each variable in Term to a unique term in the series vvv(0), vvv (1), vvv(2)...

numvars (Term) :- numvars_aux(Term,0,_).

numvars_aux(Term,N,N) :- atomic(Term), !.

numvars_aux(Term,N,NewN) :var(Term), !, Term = vvv(N), NewN is N+l1.

numvars_aux(Term,N,NewN) :- Term =.. List, numvars_list (List,N,NewN) .

numvars_list([],N,N).

numvars_list([Term|Terms],N,NewN) :numvars_aux(Term,N,NextN), numvars_list (Terms,NextN,NewN) .

Figure 6.7 Implementation of subsumes_chk for Prologs in which it is not built in.
