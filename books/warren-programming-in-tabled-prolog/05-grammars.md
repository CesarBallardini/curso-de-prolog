# Grammars
In this chapter we will explore how tabling can be used when writing DCG grammars in XSB. Tabling eliminates redundancy and handles grammars that would infinitely loop in Prolog. This makes the \`\`parser you get for free'' in XSB one that you might well want to use.

------------------------------------------------------------------------

- <a href="#node24.html" id="node23.html_tex2html434">An Expression Grammar</a>
- <a href="#node25.html" id="node23.html_tex2html435">Representing the Input String as Facts</a>
- <a href="#node26.html" id="node23.html_tex2html436">Mixing Tabled and Prolog Evaluation</a>
- <a href="#node27.html" id="node23.html_tex2html437">So What Kind of Parser is it?</a>
- <a href="#node28.html" id="node23.html_tex2html438">Building Parse Trees</a>
- <a href="#node29.html" id="node23.html_tex2html439">Computing First Sets of Grammars</a>
- <a href="#node30.html" id="node23.html_tex2html440">Linear Parsing of LL(k) and LR(k) Grammars</a>
- <a href="#node31.html" id="node23.html_tex2html441">Parsing of Context Sensitive Grammars</a>

------------------------------------------------------------------------

# An Expression Grammar
Consider the following expression grammar, expressed as a DCG. This is the \`\`natural'' grammar one would like to write for this langauge.

% file grammar.P\
:- table expr/2, term/2.\

expr --\> expr, \[+\], term.\
expr --\> term.\
term --\> term, \[\*\], primary.\
term --\> primary.\
primary --\> \['('\], expr, \[')'\].\
primary --\> \[Int\], {integer(Int)}.\

This grammar is left-recursive and would cause a problem for Prolog, but with the table declarations, XSB handles it correctly. Notice that we must table `expr/2` because the XSB parser adds 2 arguments to the nonterminal symbol `expr`. (An alternative would be to use the `auto_table` directive.) After compiling and loading this program, we can execute it:

\| ?- \[grammar\].\
\[Compiling ./grammar\]\
\[grammar compiled, cpu time used: 0.419 seconds\]\
\[grammar loaded\]\

yes\
\| ?- expr(\[1,+,2,\*,3,\*,'(',4,+,5,')'\],\[\]).\
Removing open tables.\

yes\
\| ?-\

Here the system answers \`\`yes'' indicating that the string is recognized. (The message \`\`Removing open tables'' is given when a query with no variables evaluates to true. It indicates that once the first successful execution path is found, computation terminates, and any tables that are not fully evaluated have been deleted.) This grammar is not only more elegant than the one we wrote in Prolog for the same langauge, it is more \`\`correct''. What I mean by that is that this grammar associates \`\`+'' and \`\`\*'' to the left, as is usual, rather than to the right as the did the Prolog grammar that we gave in an earlier chapter.

So far we've only seen DCG's that represent simple context-free grammars. The DCG representation is actually much more powerful and can be used to represent very complicated systems. As a first example, let's say we want to implement an evaluator of these integer expressions. We can add semantic arguments to the nonterminals above to contain the value of the subexpression recognized. The following grammar does this:

% file grammar.P\
:- table expr/3, term/3.\

expr(Val) --\> expr(Eval), \[+\], term(Tval), {Val is Eval+Tval}.\
expr(Val) --\> term(Val).\
term(Val) --\> term(Tval), \[\*\], primary(Fval), {Val is Tval\*Fval}.\
term(Val) --\> primary(Val).\
primary(Val) --\> \['('\], expr(Val), \[')'\].\
primary(Int) --\> \[Int\], {integer(Int)}.\

Recall that the braces are used to indicate that the enclosed calls are calls to Prolog predicates, not to nonterminals which recognize parts of the input string.

We can compile and run this program to evaluate the expression provided and have it return its integer value as follows:

\| ?- \[grammar\].\
\[Compiling ./grammar\]\
\[grammar compiled, cpu time used: 0.75 seconds\]\
\[grammar loaded\]\

yes\
\| ?- expr(Val,\[1,+,2,\*,3,\*,'(',4,+,5,')'\],\[\]).\

Val = 55;\

no\
\| ?-\

Notice that the string arguments are added *after* any explicit arguments. So we wrote what looked like a procedure definition for `expr` that had only one argument, but we get a definition that has 3 arguments, and that's the way we called it at the top-level prompt.

As mentioned, this grammar treats the operators as left associative, which is the usual convention for arithmetic expressions. While it doesn't matter semantically for the operations of \`\`+'' and \`\`\*'', which are associative operators anyway, were we to extend this evaluator to handle \`\`-'' or \`\`/'' (as is very easy), then this correct associativity would be critical.

------------------------------------------------------------------------

# Representing the Input String as Facts
In actuality, this way to process grammars with tabling is not as efficient as it might be. The reason is that the arguments to the tabled nonterminals consist of lists, and so each time a call is copied into the table, a long list may have to be copied. Also answers consist of tails of the list corresponding to the input string, and these may be long as well. We can use a slightly different representation for the input string to avoid this inefficiency.

Instead of representing the input string as a list, we will store it in the database, representing it by a set of facts. We will think of each word in the input sentence as being numbered, starting from 1. Then we will store the string as a set of facts of the form, `word(`*n*,*word*`)`, where *word* is the *n*<sup>*th*</sup> word in the input string. For example, the string used in the example above, `[1,+,2,*,3,*,'(',4,+,5,')']`, would be represented by the following facts:

word(1,1).\
word(2,+).\
word(3,2).\
word(4,\*).\
word(5,3).\
word(6,\*).\
word(7,'(').\
word(8,4).\
word(9,+).\
word(10,5).\
word(11,')').\

Recall that we said that the DCG translation translates lists in the body of DCG rules to calls to the predicate `'C'/3`, which is defined to process the list input. But we can redefine this predicate to look at the `word/2` predicate as follows:

'C'(I,W,I1) :- word(I,W), I1 is I+1.\

(We could alternatively use `word/3` facts and explicitly store the two consecutive integers, so no computation would be involved.) With this definition of `'C'/3`, we can use the same DCG for parsing but now, rather than using lists to represent positions in the input, the system uses integers.

% grammar.P\
:- table expr/3, term/3.\
'C'(I,W,I1) :- word(I,W), I1 is I+1.\

eval_string(String,Val) :- \
```prolog
retractall(word(\_,\_)),
assert_words(String,1,N),
abolish_all_tables,
expr(Val,1,N).
```
assert_words(\[\],N,N).\
assert_words(\[Word\|Words\],N,M) :- \
```prolog
    assert(word(N,Word)), N1 is N+1, assert_words(Words,N1,M).
```
expr(Val) --\> expr(Eval), \[+\], term(Tval), {Val is Eval+Tval}.\
expr(Val) --\> term(Val).\
term(Val) --\> term(Tval), \[\*\], primary(Fval), {Val is Tval\*Fval}.\
term(Val) --\> primary(Val).\
primary(Val) --\> \['('\], expr(Val), \[')'\].\
primary(Int) --\> \[Int\], {integer(Int)}.\

Here we've defined a predicate `eval_string` to take an input string as a list, assert it into the database as a set of `word/2` facts and then to call `expr` to parse and evaluate it. Notice that we need both to retract any facts previously stored for `word/2` and to abolish any tables that were created during previous evaluations of strings. This is because old tables are no longer valid, since the new input string changes the meanings of the integers that represent positions in the input string.

We can compile and call this predicate as follows:

\| ?- \[grammar\].\
\[Compiling ./grammar\]\
++Warning: Redefining the standard predicate: C / 3\
\[grammar compiled, cpu time used: 1.069 seconds\]\
\[grammar loaded\]\

yes\
\| ?- eval_string(\[1,+,2,\*,3,\*,'(',4,+,5,')'\],V).\

V = 55;\

no\
\| ?-\

The warning is to alert the user to the fact that a standard predicate is being redefined. In this case, that is exactly what we want to do, and so we can safely ignore the warning.

------------------------------------------------------------------------

# Mixing Tabled and Prolog Evaluation
We can extend this evaluator in the following interesting way. Say we want to add exponentiation. We introduce a new nonterminal, `factor`, for handling exponentiation and make it right recursive, since exponentiation is right associative.

:- table expr/3, term/3.\

expr(Val) --\> expr(Eval), \[+\], term(Tval), {Val is Eval+Tval}.\
expr(Val) --\> term(Val).\
term(Val) --\> term(Tval), \[\*\], factor(Fval), {Val is Tval\*Fval}.\
term(Val) --\> factor(Val).\
factor(Val) --\> primary(Num), \[^\], factor(Exp), \
```prolog
{Val is floor(exp(log(Num)\*Exp)+0.5)}.
```
factor(Val) --\> primary(Val).\
primary(Val) --\> \['('\], expr(Val), \[')'\].\
primary(Int) --\> \[Int\], {integer(Int)}.\

However, we don't table the new nonterminal. Prolog's evaluation strategy handles right recursion in grammars finitely and efficiently. In fact, Prolog has linear complexity for a simple right-recursive grammar, but with tabling it would be quadratic. Thus an advantage of XSB is that it allows tabled and nontabled predicates to be freely intermixed, so that the programmer can choose the strategy that is most efficient for the situation at hand.

------------------------------------------------------------------------

# So What Kind of Parser is it?
A pure DCG, one without extra arguments (and without look-ahead symbols which we haven't discussed at all), represents a context-free grammar, and the Prolog and XSB engines provide recognizers for it. A context-free recognizer is a program that, given a context-free grammar and an input string, responds \`\`yes'' or \`\`no'' according to whether the input string is in or is not in the language of the given grammar.

We noted that the recognizer that \`\`you get for free'' with Prolog is a recursive descent recognizer. The recognizer \`\`you get for free'' with XSB and tabling is a variant of Earley's algorithm, or an active chart recognition algorithm (ref Peter Norvig and B. Sheil.)

The worst-case complexity of the recognizer under XSB (with all recursive nonterminals tabled) is  *O*(*n*<sup>*k*+1</sup>) where *n* is the length of the input string and *k* is the maximum number of nonterminals and terminals on the right-hand-side of any rule. A little thought shows that this is consistent with the discussion of the complexity of datalog programs under XSB in Chapter ??. This is an example of a situation in which tabling turns an otherwise exponential algorithm (recursive descent) into a polynomial one (active chart recognition.)

Any grammar can be changed to another grammar that represents the same language but has two (or fewer) nonterminal symbols on the right-hand-side of every rule. This is the so-called Chomsky normal form. So if we transform a grammar into this form, then its worst-case complexity will be *O*(*n*<sup>3</sup>).

In fact, the folding and tabling that is done automatically by the XSB compiler when the `:- suppl_table.` and `:- edb word/2.` directives are given results in exactly the transformation necessary to transform a grammar to Chomsky normal form. So giving those directives guarantee the best worst-case complexity.

For unambiguous grammars, the complexity is actually *O*(*n*<sup>2</sup>). I find this an intriguing situation, which is particularly pleasant, since it is undecidable whether a context-free grammar is or is not ambiguous. So it will be undecidable to determine what the actual complexity of the algorithm is, given a grammar. But, no problem; the algorithm will automatically tune itself to the data (grammar in this case) to be more efficient in the unambiguous case.

These complexity results are very good and make the parser that \`\`you get for free'' with XSB quite a desirable parser.

------------------------------------------------------------------------

# Building Parse Trees
The desirable complexity results of the previous section hold for *recognition* of context-free languages. But often it is the case that one wants, given a string to construct the parse tree(s) for it. An easy way to do this is to add an argument to each nonterminal to contain the parse tree, and then add the necessary code to each rule to construct the appropriate tree. For example, the following rule from our expression example:

```prolog
expr(Val) --\> expr(Eval), \[+\], term(Tval), {Val is Eval+Tval}.
```
could become:

expr(Val,+(E1,T1)) --\> expr(Eval,E1), \[+\], term(Tval,T1), {Val is Eval+Tval}.\

We've added a second argument and in it constructed the parse tree for the entire expression phrase given the parse trees for the component expression and term phrases. All the other rules would be extended accordingly.

This is very easy to do and in almost all cases is the best way to construct the parse tree. However, from a complexity standpoint, it has certain drawbacks. It may cause us to lose the polynomial complexity we had. For example, consider the following grammar:

```prolog
:- auto_table.
s --\> b,\[c\]
```
```prolog
b --\> b,b.
b --\> \[a\].
```
Here nonterminal `s` generates a list of \`\`a''s followed by a single \`\`c''. If we compile this grammar with XSB, using the `auto_table` directive, we get a program that will recognize strings correctly in *O*(*n*<sup>3</sup>) time. But if we add parameters to construct the parse tree, thusly:

```prolog
:- auto_table.
s(s1(B,c)) --\> b(B), \[c\].
```
```prolog
b(b1(B1,B2)) --\> b(B1), b(B2).
b(b2(a)) --\> \[a\].
```
it may take exponential time. Now the string *a*<sup>*n*</sup>*c* has exponentially many parses (all bracketings of the length *n* string of \`\`a''s), so it will clearly take exponential time to produce them all. This is not so much of a problem; if there are exponentially many, there's no way to produce them all without taking exponential time. However, if we try to recognize the string *a*<sup>*n*</sup>, this will take exponential time to report failure. This is because the system will construct all the (exponentially many) initial parses from the nonterminal \`\`b'' and then each time fail when it doesn't find a terminating \`\`c'' in the input string.

One might think that we could easily just maintain two versions of the grammar: one with no parameters to do recognition, and one with a parse-tree parameter. Then we'd first recognize and if there were no parses, we'd simply report failure, and if there were parses, we'd reprocess the input string, this time using the parsing version of the grammar. But this doesn't always work either. For example, say we added a few rules to our grammar above to obtain:

```prolog
:- auto_table.
s --\> b,\[c\].
s --\> g,\[d\].
```
```prolog
b --\> b,b.
b --\> \[a\].
```
```prolog
g --\> g, \[a\].
g --\> \[a\].
```
Here, the input string of `[a,a,a,a,a,a,d]` has only one parse, but naively parsing it with the parse-annotated grammar will construct exponentially many initial segments of parses, which come from the first rule and the rules for the nonterminal \`\`b''. So if we are serious about this problem, we must be a little more sophisticated.

We still use a recognizer, but we must mix calls to it throughout the parser. So we'll assume we have the recognizer given just previously and we want an efficient parser. We must mix calls to the recognizer in with the calls to the parsing procedures. One problem is that the DCG syntax does not support what we need, so we will have to write the routines directly above:

```prolog
:- auto_table.
s(s(P,c),S0,S) :-
       b(S0,S1), 'C'(S1,c,S),
       b(P,S0,S1).
```
```prolog
s(s(P,d),S0,S) :-
       g(S0,S1), 'C'(S1,d,S),
       g(P,S0,S1).
```
```prolog
b(b(P1,P2),S0,S) :-
       b(S0,S1), b(S1,S),
       b(P1,S0,S1), b(P2,S1,S).
b(a,S0,S) :-
       'C'(S0,a,S).
```
```prolog
g(g(P),S0,S) :-
       g(S0,S1), 'C'(S1,a,S),
       g(P,S0,S1).
g(a,S0,S) :-
       'C'(S0,a,S).
```
Here for each rule, we first use the recognizer to see whether the rule will succeed. After we know it will succeed and have computed the exact substring that each nonterminal spans, then for each nonterminal we invoke the parsing routine to construct its parse.

Now as coded here, there will be multiple tabling: the `auto_table` directive will cause b/2, g/2, b/3, and g/3 all to be tabled. However, we don't really have to table the parsing nonterminals b/3 and g/3. Since they are always called with both the starting and ending string position known, they will not loop. This program has the desired property, that either it will fail in cubic time or it will succeed in cubic time and produce each parse in linear time.

------------------------------------------------------------------------

# Computing First Sets of Grammars
The previous examples show that XSB can process grammars efficiently, using them to determine language membership and the structure of strings. But XSB can also do other kinds of grammar processing. In the following, we use XSB to compute the FIRST sets of a grammar.

 , for any string of terminals and nonterminals , is defined to be the set of terminals that begin strings derived from , and if  derives the empty string then the empty string is also in  .   is the generalization to length *k* strings of terminals that are prefixes of strings derived from .

We will assume that a grammar is stored in a predicate `==>/2`, with the head of a rule as an atomic symbol and the body of a rule as a list of symbols. Nonterminals are assumed to be those symbols for which there is at least one rule with it as its head. (`==>/2` is declared as an infix operator.)

The predicate `first(SF,K,L)` is true if the list SF of grammar symbols derives a string whose first K terminal symbols are L.

% The definition of FIRST:\
% first(SentForm,K,FirstList) computes firsts for a context-free grammar.\
:- table first/3.\
first(\_,0,\[\]).\
first(\[\],K,\[\]) :- K\>0.\
first(\[S\|R\],K,L) :- K\>0,\
```prolog
(S ==\> B),
first(B,K,L1),
length(L1,K1),
Kr is K - K1,
first(R,Kr,L2),
append(L1,L2,L).
```
first(\[S\|R\],K,\[S\|L\]) :- K\>0,\
```prolog
\\ (S ==\> \_),    % S is a terminal
K1 is K-1,
first(R,K1,L).
```
The first rule says that the empty string is in   for any . The second rule says that the empty string is in   for  being the empty sequence of grammar symbols. The third rule handles the case in which the sequence of grammar rules begins with a nonterminal, `S`. It takes a rule beginning with S and gets a string `L1` (of length `K1`  `K`) generated by the body of that rule. It gets the remaining `K`-`K1` symbols from the rest of the list of input grammar symbols. And the fourth rule handles terminal symbols.

This is a relatively simple declarative (and constructive) definition of *FIRST*<sub>*k*</sub>. But without the table declaration it would not run for many grammars. Any left-recursive grammar would cause this definition to loop in Prolog.

------------------------------------------------------------------------

# Linear Parsing of LL(k) and LR(k) Grammars
(This section involves a more advanced topic in XSB programming, metainterpretation. It may be helpful to read the later section on metainterpreters if the going gets tough here.)

As discussed above, parsing context-free grammars with tabling results in an Earley-type parser. This is the parser we get when we write DCGs. We can also write an XSB program that takes a grammar as input (defined in a database predicate as in the example of `first/3`) and a string (defined by the database `word/3` predicate) and succeeds if the grammar accepts the string. With such processing we can compute and use the *FIRST* sets to make the grammar processing more deterministic. This is similar to what is done in LL(k) and LR(k) parsing, but there the emphasis is on compile-time analysis and complete determinacy. Here the approach is more interpretive and supports nondeterminacy. However, if the grammars are indeed of the appropriate form (LL(k) or LR(k)), the corresponding interpreters presented here will have linear complexity.

It is very easy to write a simple context-free grammar parser in XSB. Again, we assume that the grammar is stored in facts of the form `NT ==> Body` where `NT` is a nonterminal symbol and `Body` is a list of terminals and nonterminals.

:- table parse/3.\

% parse(Sym,S0,S) if symbol Sym generates the string from S0 to S.\
parse(Sym,S0,S) :-\
```prolog
word(S0,Sym,S).
```
parse(Sym,S0,S) :-\
```prolog
(Sym ==\> Body),
parseSF(Body,S0,S).
```
% parseSF(SF,S0,S) if sentential form SF generates the string from S0 to S.\
parseSF(\[\],S,S).\
parseSF(\[Sym\|Syms\],S0,S) :-\
```prolog
parse(Sym,S0,S1),
parseSF(Syms,S1,S).
```
The predicate `parse/3` recognizes strings generated by a single grammar symbol; the first clause recognizes terminal symbols directly and the second clause uses `parseSF/3` to recognize strings generated by the sentential form that makes up the body of a rule for a nonterminal. `parseSF/3` simply maps `parse/3` across the sequence of grammar symbols in its sentential form argument.

Were we not to add the table declaration, we would get a recursive descent recognizer. But with the table declaration, we get the Earley-type recognizer of XSB as described above. The tabling reflects right through the programmed recognizer.

Next we add look-ahead to this recognizer by computing `FIRST` sets and making calls only when the next symbols are in the first set of the sentential form to be processed. This will give us an LL(k)-like recognizer. Hovever, the form of `FIRST` we need here is slightly different from the one above. Here we want to include the context in which a `First` set is computed. For example, we may want to compute the `FIRST_2` set of a symbol `N`, but `N` only generates one symbol. The definition of `first` above would return a list of length one for that symbol. Here we want to take into account the context in which `N` is used. For example, we may know that in the current context `N` is immediately followed by another nonterminal `M`, and we know the `FIRST` of `M`. Then we can compute the `FIRST_2` of `N` in the following context of `M` by extending out the one symbol in `first` of `N` with symbols in `FIRST` of `M`.

The following definition of `firstK/3` computes such first sets.

:- table firstK/3.\

% firstK(+SF,+Follow,-First), where K = length(Follow)\
firstK(\[\],Follow,Follow).\
firstK(\[Sym\|SF\],Follow,First) :-\
```prolog
firstK(SF,Follow,SymFollow),
((Sym ==\> Body)
 -\>   firstK(Body,SymFollow,First)
 ;    First = \[Sym\|FirstTail\]
      append(FirstTail,\[\_\],SymFollow),
).
```
The predicate `firstK/3` takes a sentential form `SF`, a follow string `Follow`, and returns in `First` a first string of `SF` in the context of the follow string. The value of *k* is taken to be the length of the list `Follow`; this will be the length of the look-ahead.

We can now extend our parser to have a top-down look-ahead component, similar to an LL(k) recognizer:

TEST THIS SUCKER!\
:- table parseLL/4.    % without this, it is an LL(k)-like parser,\
```prolog
                    % but with it, what is it???
```
% parseLL(Sym,Follow,S0,S) if symbol Sym generates the string from S0 to S.\
parseLL(Sym,Follow,S0,S) :-\
```prolog
(Sym ==\> Body)
 -\> firstK(Body,Follow,First),
    next_str(First,S0),        % do the look-ahead, continuing only if OK
    parseLLSF(Body,Follow,S0,S)
 ;  word(S0,Sym,S).
```
% parseLLSF(SF,Follow,S0,S) if sentential form SF generates the string from S0 to S.\
parseLLSF(\[\],\_Follow,S,S).\
parseLLSF(\[Sym\|Syms\],Follow,S0,S) :-\
```prolog
firstK(Syms,Follow,SymFollow),
parseLL(Sym,SymFollow,S0,S1),
parseLLSF(Syms,Follow,S1,S).
```
next_str(\[\],\_).\
next_str(\['\$'\|\_\],S) :- \\ word(S,\_,\_).  % \$end of string\
next_str(\[Sym\|Syms\],S) :- word(S,Sym,S1),next_str(Syms,S1).\

The predicate `parseLL/4` recognizes a string generated by a grammar symbol, using lookahead. The condition tests whether `Sym` is a nonterminal, and if it is and can be rewritten as `Body`, it checks to see whether the next symbols in the input string belong to the first set of the body of that rule. If not, it needn't process that rule because it cannot succeed. For an LL(k) grammar, only one rule will ever apply; the others all will be filtered out by this lookahead. So in this case a rule is never tried unless it is the only rule that might lead to a parse. If the symbol is a terminal, it simply checks to see whether the symbol matches the input.

`parseLLSF/4` maps `parseLL/4` across a sequence of grammar symbols in a sentential form. It uses `firstK/3` to compute the follow strings of a symbol, which are needed in `parseLL` to compute the first strings in the correct context.

In this LL(k)-like parser, we tested that the next symbols were in the first set just before we called `parseLLSF`. We could also check the lookahead just before returning. This gives us an LR(k)-like parser, as follows:

% parseLR with tabling to get an lr(k)-like algorithm.  \

:- table parse/4.\
parseLR(Sym,Follow,Str0,Str) :-\
```prolog
word(Str0,Sym,Str),
next_str(Follow,Str).
```
parseLR(Sym,Follow,Str0,Str) :-\
```prolog
(Sym ==\> RB),
parseLRSF(RB,Follow,Str0,Str).
```
parseLRSF(\[\],Follow,Str,Str) :- \
```prolog
next_str(Follow,Str).
```
parseLRSF(\[Sym\|SF\],Follow,Str0,Str) :- \
```prolog
firstK(SF,Follow,SymFollow),
parseLR(Sym,SymFollow,Str0,Str1),
parseLRSF(SF,Follow,Str1,Str).
```
For this parser, we compute a follow string for a sentential form, and only return from parsing that sentential form if the next input symbols match that follow string. For an LR(k) grammar, the parser will not fail back over a successful return (unless the entire string is rejected.) This allows the parser to work in linear time.

The above program was written as a Prolog program, but we can write the identical program as a DCG and have the DCG transformation put in the string variables, as follows:

:- table parseLR/4.\
parseLR(Sym,Follow) --\> \[Sym\], look(Follow).\
parseLR(Sym,Follow) --\>\
```prolog
{(Sym ==\> RHS)},
parseLRSF(RHS,Follow).
```
parseLRSF(\[\],Follow) --\> look(Follow).\
parseLRSF(\[Sym\|SF\],Follow) --\>\
```prolog
{firstK(SF,Follow,SymFollow)},
parseLR(Sym,SymFollow),
parseLRSF(SF,Follow).
```
look(\[\]) --\> \[\].\
look(\[Word\|Words\]), \[Word\] --\> \[Word\], look(Words).\

This recognizer differs from an LR(k) recognizer in that it computes the look-ahead strings as needed. Also it processes each look-ahead string separately; i.e., `Follow` is a single string, not a set of strings. In an LR(k) recognizer, the lookahead tables are computed once and stored.

------------------------------------------------------------------------

# Parsing of Context Sensitive Grammars
Another more powerful form of grammars is the class of context sensitive grammars. They contain rules that have strings on both the left-hand-side and the right-hand-side, as opposed to context-free rules which require a single symbol on the left-hand-side. A constraint on context sensitive rules is that the length of the string of the left-hand side is at least one, and is less than or equal to the length of the string on the right-hand side. (Without this constraint, one gets full Turing computability and the recognition problem is undecidable.) As a simple example, consider the following context sensitive grammar:

```prolog
    1. S --\> aSBC
    2. S --\> aBC
    3. CB --\> BC
    4. aB --\> ab
    5. bB --\> bb
    6. bC --\> bc
    7. cC --\> cc
```
This grammar generates all strings consisting of a nonempty sequence of a's followed by the same number of b's followed by the same number of c's. Consider the following derivation:

```prolog
    S
    aSBC       rule 1
    aaBCBC     rule 2
    aaBBCC     rule 3
    aabBCC     rule 4
    aabbCC     rule 5
    aabbcC     rule 6
    aabbcc     rule 7
```
Even though in this simple example the rules fire in order, it's not difficult to see that rule 3 will have to fire enough times to move all the C's to the right over the B's, and then rules 4-7 will fire enough times to turn all the nonterminals into terminals.

The question now is how to represent this in XSB. We can think of the XSB DCG rules as running on a graph that starts as a linear chain representing the input string. Then each DCG context-free rule tells how we can add edges to that linear graph. For example, a DCG rule `a --> b,c.` tells us that if there is an arc from node X to node Y labeled by b and also an arc from node Y to node Z labeled by c, then we should add an arc from node X to node Z labeled by a. So the DCG rule in Prolog, `a(S0,S) :- b(S0,S1),c(S1,S).`, read right-to-left, says explicitly and directly that if there is an arc from S0 to S1 labeled b and an arc from S1 to S labeled c, then there is an arc from S0 to S labeled by a. We can think of DCG rules as rules that add labeled arcs to graphs. This is exactly the way that chart-parsing is understood.

Now we can extend this way of understanding logic grammars to context-sensitive rules. A context-sensitive rule, with say two symbols on the left-hand-side, can be seen also as a graph-generating rule, but in this case it must introduce a new node as well as new arcs. So for example, a rule such as `AB --> CD`, when it sees two adjacent edges labeled C and D, should introduce a new node and connect it with the first node of the C-arc labeling it A, and also connect it to the final node of the D-arc, labeling that new arc with B. So we add two new XSB rules for a context sensitive rule such as `AB --> CD`, as follows:

```prolog
a(S0,p1(S0)) :- c(S0,S1), d(S1,S).
b(p1(S0),S) :- c(S0,S1), d(S1,S).
```
which explicitly add the arcs and nodes. We have to introduce a new name for the new node. We choose to identify the new nodes by using a functor symbol that uniquely determines the rule and left-hand internal position, and pairing it with the name of the initial node in the base arc. So in this case, p1 uniquely identifies the (only) internal position in the left-hand-side of this rule. Other rules, and positions, would have different functors to identify them uniquely.

Now we can represent the context sensitive grammar above using the following XSB rules:

:- auto_table.\

s(S0,S) :- word(S0,a,S1),s(S1,S2),b(S2,S3),c(S3,S).\
s(S0,S) :- word(S0,a,S1),b(S1,S2),c(S2,S).\

c(S0,p0(S0)) :- b(S0,S1),c(S1,\_S).\
b(p0(S0),S) :- b(S0,S1),c(S1,S).\

word(S0,a,p1(S0)) :- word(S0,a,S1),word(S1,b,\_S).\
b(p1(S0),S) :- word(S0,a,S1),word(S1,b,S).\

word(S0,b,p2(S0)) :- word(S0,b,S1),word(S1,b,\_S).\
b(p2(S0),S) :- word(S0,b,S1),word(S1,b,S).\

word(S0,b,p3(S0)) :- word(S0,b,S1),word(S1,c,\_S).\
c(p3(S0),S) :- word(S0,b,S1),word(S1,c,S).\

word(S0,c,p4(S0)) :- word(S0,c,S1),word(S1,c,\_S).\
c(p4(S0),S) :- word(S0,c,S1),word(S1,c,S).\

% define word/3 using base word (separation necessary)\
word(X,Y,Z) :- base_word(X,Y,Z).\

% parse a string... assert words first, then call sentence symbol\
parse(String) :-\
```prolog
abolish_all_tables,
retractall(base_word(\_,\_,\_)),
assertWordList(String,0,Len),
s(0,Len).
```
% assert the list of words.\
assertWordList(\[\],N,N).\
assertWordList(\[Sym\|Syms\],N,M) :-\
```prolog
N1 is N+1,
assert(base_word(N,Sym,N1)),
assertWordList(Syms,N1,M).
```
We can run this grammar to parse input strings as follows:

warren% xsb\
XSB Version 1.7.2 (7/10/97)\
\[Sun, optimal mode\]\
\| ?- \[csgram\].\
\[csgram loaded\]\

yes\
\| ?- parse(\[a,a,b,b,c,c\]).\
++Warning: Removing incomplete tables...\

yes\
\| ?- parse(\[a,a,a,b,b,c,c,c\]).\

no\
\| ?- parse(\[a,a,a,a,b,b,b,b,c,c,c,c\]).\
++Warning: Removing incomplete tables...\

yes\
\| ?-\

So now we have generalized DCG's to include processing of context-sensitive grammars and languages. The builtin DCG notation doesn't support context sensitive languages, but we can write the necessary rules directly as XSB rules, as we did above. It is interesting to note that the XSB rules we generate for a single context-sensitive rule all have the same body, and that the logical implications

```prolog
p \<- r & s.
q \<- r & s.
```
are logically equivalent to the single implication:

```prolog
p & q \<- r & s.
```
So it would be very natural to extend the Prolog notation to support \`\`multi-headed'' rules, which would be compiled to a set of \`\`single-headed'', i.e., regular Prolog, rules. Were we to do this, we could write the context-sensitive rule:

```prolog
   AB --\> CD
```
as the single (multi-headed) XSB rule:

```prolog
   a(S0,p1(S0)), b(p1(S0),S) :- c(S0,S1), d(S1,S).
```
which looks very much like the original context sensitive rule. This suggests how we might want to extend the DCG notation to support context-sensitive rules through the support of multi-headed rules.

------------------------------------------------------------------------
