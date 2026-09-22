# Chapter3_Part2

<!-- page 71 -->
Chap. 3

**A count noun has a singular and a plural (dog, dogs). A mass noun, such as water**

or stuff, has no plural, and usually refers to an indefinite amount of a substance.

The difference is important because different types of nouns take different determiners.

Some examples:

TYPE OF NOUN

EXAMPLE

SUITABLE DETERMINERS

singular count

dog, theory

a(n), the, one, every

plural count

dogs, theories

Y, the, two, all

singular mass

water, stuff

@, the, all

plural mass

(does not exist)

Your parser should accept a dog, the theory, two dogs, etc., but reject *a dogs, *one theories,

“every stuff, *two water, and the like.

**3.4.3 Case Marking**

**Some English pronouns are marked for CASE. This means that the pronoun has a different**

**form before the verb than after it. For example:**

**He sees him.**

*Him sees he.

She sees her.

*Her sees she.

They see them.

***Them see they.**

The forms that come before the verb, he, she, and they, are called NOMINATIVE, and the forms that come after the verb, him, her, and them are called ACCUSATIVE.>

**“Before the verb” and “after the verb” is not a very good way of describing where**

**these forms occur. Instead, we can say, much more precisely and accurately, that:**

**S—> NP VP _ introduces a nominative, and**

**VP + VNP _ introduces an accusative.**

**To account for this with DCG rules, we’ll add a second argument for case, alongside the**

**argument for number. The rules for the pronouns will then be:**

pronoun(singular,nominative) --> [he]; [she]. pronoun (singular,accusative) --> [him]; [her]. pronoun (plural,nominative)

--> [they]. pronoun (plural, accusative)

--> [them]. and we need to change the NP rules:

np (Number, Case)

--> pronoun(Number,Case)

. np (Number,_)

-->

d, n(Number)

.

<!-- page 72 -->
5Her is also a possessive determiner corresponding to his, your, my, etc. Don’t let this confuse you. The second of these says that nouns are not marked for case. Because there is no case marking on determiners, nouns, or verbs, the D, N, and V rules can be exactly the same as in the previous section. But we need to change the S rule and the VP rule:

s

--> np(Number,nominative), vp(Number).

vp (Number) --> v(Number), np(_,accusative).

**Now the parser accounts for case marking of pronouns.**

Exercise 3.4.3.1

Incorporate these changes into the rules from the previous section, and verify that it accepts

He sees them and They see her but not *Them see he or *They see they.

Exercise 3.4.3.2

**Should the rule PP — P NP specify a nominative or an accusative NP? Cite examples from**

English to justify your conclusion, then add this rule to your parser, with appropriate case

```prolog
marking.
```

3.4.4 Subcategorization

**The structure of the English VP depends on the particular verb. Different verbs require**

different things after them. For example:

VERB

COMPLEMENT EXAMPLE

sleep, bark None

(The cat) slept.

chase, see

**One NP**

(The dog) chased the cat.

give, sell

Two NPs

(Max) sold Bill his car.

say, claim

Sentence

(Max) claimed the cat barked.

If these requirements are not met, the sentence is ungrammatical; you can’t say The dog chased or John said the cat unless the missing part can be clearly understood from the context.

**This means we can’t really account for the VP with a single rule of the form**

**VP — V (NP) (NP) (S). Instead we need at least four rules,**

VP —>

**V**

VP

—-+

**VNP**

VP

-—+

**VNP NP**

VP —>

**VS**

<!-- page 73 -->
plus a way of associating the right rule with each verb.

One possibility is to eliminate the concept of “verb” from the grammar, and instead, use four different categories (call them V1, V2, V3, and V4). The VP rules would then be:

VP

~>

Vi

VP

-—>

V2 NP

VP ->

V3 NP NP

**VP > V4S**

and the lexicon would say that bark is a V1, chase is a V2, and so on.

Notice that if we do this, we are claiming that there is no relationship at all between V1, V2, V3, and V4; no more than between N and P. We will be claiming that bark, chase, sell, and say are four totally different kinds of words. There will be no way to write a rule that applies equally to all four of them.

That isn’t satisfactory. There are two good reasons to put all four kinds of verbs into a single category called V:

e Only V’s are marked for tense and number and can serve as the head of a VP.

e Morphologically, all four kinds of V’s are alike (they take -s in the third person

singular, -ed in the past, and so on). The morphological part of the parser, which

we haven’t implemented yet, should not distinguish between different kinds of V’s.

What we need is a way to have things both ways: treat the various kinds of V’s alike and treat them differently. That is, we need a category V, divided into suBCATEGORIES.

One way to do this is—you guessed it—to add an argument to the V. Then rules that care about this feature can specify its value, and rules that don’t care about it can put an anonymous variable in place of it. Here goes:

Vv

**c<<<**

**BORE**

**<<**

**sss**

1) --> [barked];[slept].

2) --> [{chased]; [saw].

3) --> [gave];[sold].

4) --> [said]; [thought].

(To keep the example from becoming too complicated, we’ve dropped the agreement features. A real parser would, of course, keep them.) Now v(1) means a verb of class 1, v(2) means a verb of class 2, etc., and v (__) means a verb of any class. It turns out that v(_) does not occur in any syntactic rules, but only in the morphological part of the grammar. Exercise 3.4.4.1

Construct a complete, working parser that implements subcategorization of verbs. Make it

<!-- page 74 -->
accept the sentences

The cat slept.

The dog chased the cat.

The girl gave the dog a bone.

The boy said the dog chased the cat.

but reject sentences in which verbs have the wrong kinds of complements, such as:

*The cat slept the dog.

*The dog chased.

*The girl gave the dog chased the cat.

*The boy said the cat.

3.4.5 Undoing Syntactic Movements

You can even use arguments to pick up a word from one position and put it down somewhere else. This surprising ability turns out to be needed when parsing English questions. Consider a complicated sentence such as:

Max said Bill thought Joe believed Fido barked.

This sentence contains four NPs, Max, Bill, Joe, and Fido, and we can ask a question by substituting who for any of them:®

Who said Bill thought Joe believed Fido barked? (Max.) Who did Max say ,, thought Joe believed Fido barked? (Bill.) Who did Max say Bill thought |, believed Fido barked? (Joe.) Who did Max say Bill thought Joe believed ,, barked? (Fido.)

The first sentence simply puts who in place of Max. In each of the others:

e Exactly one NP is missing from somewhere in the sentence (it is denoted by ‘,’). e Who did has been added at the beginning. e The sentence means exactly what it would have meant if who had appeared in place of the missing NP.

We would like the parser to move who back into the NP position with which it is associated. To do this, we will use arguments to implement a HOLDING LIST on which

<!-- page 75 -->
Like most native speakers, we will ignore the difference between who (old nominative) and whom (old accusative). For speakers who still distinguish them, the difference between who and whom is exactly the same as the difference between he and him. who can be stored. A rule that finds a sentence-initial who will put it on the holding list, and a rule later on that needs an NP but can’t find one will use the stored occurrence of who.’

To implement a holding list, each rule needs two arguments, one for input and one for output—that is, one to receive the holding list and one to output the (possibly changed) holding list to the next rule.

Only two rules need special treatment here.

In addition to the normal rule S — NP VP, we need a rule to parse sentences that begin with who:

s(In,Out) --> [who,did], np([wholIn],Outl), vp(Out1,Out).

That is: In is the input received by the whole sentence (probably an empty list). This rule accepts the words who did, then passes [who| In] as input to the NP. The output of the NP is Out 1, which gets passed as input to the VP. Finally, the output of the VP is Out, which is also the output of the whole sentence.

**Then, in order to allow NPs to be missing, we need an NP rule that accepts no**

words, but instead uses the who that it received in its input:

np([who|Out],Out) --> [].

**That is: One way to parse an NP is to accept who from the holding list rather than from**

the input string.

The remaining rules do not modify the holding list; they just pass it along unchanged from each step to the next. Rules for small constituents that cannot contain an NP do not need arguments, which is why v has no arguments here.

s(In,Out) --> np(In,Out1), vp(Out1,Out).

np(X,X) --> [max]; [joe]; [bill]; [f£1ido].

% Proper names are complete NPs

vp(X,X) --> v. vp(In,Out) --> v, np(In,Out). vp(In,Out) --> v, s(In,Out).

v --> [saw]; [said]; [thought]; [believed]; [barked]. v --> [see];[say]; [think];

[believe]; [bark].

In a who-question, this list will never have more than one member. The ability to stack more than one who(m) is needed for parsing nested relative clauses. For example:

The boy whom, the girl whom, we saw \12 liked \, ......

<!-- page 76 -->
Holding lists go back to the work of Woods (1970), if not earlier, and are discussed in detail by Wanner and Maratsos (1978). To parse a sentence, you must give the initial and final values of the holding list—namely [] and []—as extra arguments of s in the query, like this:

?- s([],[], [who,did,max,see],[]). yes

Holding lists are the basis of the “extraposition grammars” of Pereira (1981), who develops a useful extension of DCG notation for them. Their counterpart in unificationbased grammar is “slash features” (Gazdar, Klein, Pullum, and Sag 1985).

Exercise 3.4.5.1

Take the parser just given, get it working, and show that it parses

Who did Max say thought Joe believed Fido barked?

Who did Max say Bill thought believed Fido barked?

Who did Max say Bill thought Joe believed barked?

but does not accept *Who did Max say Joe saw Fido? or the like.

Exercise 3.4.5.2

Modify this parser so that, using another argument, it generates a tree structure. However, the

tree should not show the actual order of the words; instead, it should show who in the position

of the missing NP. For example, the tree for Who did Bill think said Fido barked? should be:

S

**aN**

NP

VP

**oN**

V

S

**a**

NP

VP

**oO**

Vv

S

**AN**

NP

VP

|

Bill

think

who

said

Fido

vale

**3.4.6 Separating Lexicon from PS Rules**

<!-- page 77 -->
It is often convenient to separate the descriptions of individual words (the LEXICON) from the PS rules. This is easy to do. Just write something like:

Definite-Clause Grammars

Chap. 3

n--> [X],

{ noun(xX) }.

noun(dog).

noun(cat).

noun (gardener).

There are two advantages to doing this. First, because of indexing, it is much faster to

search through the facts

noun(dog). noun(cat).

(etc.) than through rules of the form

n --> [dog]. n --> [cat].

Second, and more importantly, words can be defined by rules as well as by facts. Here is a LEXICAL RULE that creates a noun ending in -ness from every adjective:

oe

noun (+N) ae oe

Strips the suffix "ness" from N and

looks for a corresponding adjective.

noun(N) :-

name (N,Nchars) ,

append (Achars, "ness",Nchars) ,

name (A,Achars) ,

```prolog
adjective(A).
```

% adjective (?A) ae

Lexicon of adjectives

adjective(flat). adjective(green)

. adjective(blue).

(Recall that append is not built in.)

<!-- page 78 -->
This rule is not exactly right—it doesn’t change y to 7 when forming words such as ugliness—but it’s a start. The calls to name and append are time-consuming but unavoidable. In a complete working system, it might be better to modify the tokenizer so that some morphological analysis is done before the words are converted into atoms. Exercise 3.4.6.1 Modify this lexical rule so that it changes final y to i before -ness. That is, the rule should produce correct spellings of words like ugliness and sliminess. Include a way to deal with exceptions such as dryness (not *driness). Demonstrate that your implementation can correctly answer queries such as:

?- n([ugliness],[]).

using the rule adjective (ugly) plus the lexical rule.

Exercise 3.4.6.2 The lexical rule given so far expects the noun to be instantiated. That is, a query like noun(flatness) will succeed but noun(X) (with X uninstantiated) will fail. This means that the rule, as shown, is of no use in generating sentences. Rewrite it so that it will work with uninstantiated as well as instantiated arguments.

**3.5 BUILDING SEMANTIC REPRESENTATIONS**

3.5.1 Semantic Composition

Syntactic structure is not the only kind of output that a parser can produce. For natural language understanding we also need a semantic representation—that is, a representation of meaning. DCG parsers can produce semantic representations too. To demonstrate this, we’ll work with a tiny subset of English in which the only noun phrases are proper names (Fido, Felix), thereby postponing some complicated questions about the semantics of NPs. The syntax that we will use is as follows:

S

**—+ NP VP**

**NP**

-—_

Fido

**NP**

-—_

Felix

VP —-

V/(NP)

**V**

-—-~

chased

**V =.**

slept

**We will represent the meanings of sentences in first-order predicate logic, so that Fido**

chased Felix will be chased(fido, felix) and Felix slept will be slept(felix). What about the meanings of individual words? Proper nouns are no problem, since they are logical individuals:

Fido

= _ fido

Felix

felix

<!-- page 79 -->
To represent verbs, we will use lambda expressions, just as we did with keyword systems in Chapter 2. Recall that a lambda expression is simply a formula with an argument

Definite-Clause Grammars

Chap. 3

missing. Thus if

**Felix slept = slept (felix)**

then

**slept = (Ax) slept(x)**

**where x indicates that the value of x is to be supplied from elsewhere.**

So far, so good, but the verb chased needs two arguments, a subject and an object. We will represent it with one lambda expression inside another:

**chased = (Ay)(Ax)chased (x,y)**

This means, in effect, “Give me a value for y, such as felix, and I'll give you another lambda expression that needs only a value for x, such as (Ax)chases (x, felix).”

The next task is to combine the meanings of the individual words and thereby obtain the meanings of constituents. The parser will do this by supplying arguments to lambda expressions. For example, fido combines with (Ax)slept(x) to give slept (fido). Figure 3.6 shows how this works. Meaning seems to flow upward through the tree, as the meanings of smaller constituents get combined to give the meanings of larger constituents and ultimately of the whole S. But how can meaning flow upward when parsing proceeds top-down? The same way structures were built top-down, even though the actual information in them was only acquired at the bottommost (and therefore last) level. The parser will work with partly instantiated structures and instantiate the details when they finally become available.

**Now for the implementation. Each predicate will have an argument for the semantic**

**representation. We will represent lambda expressions in Prolog with the operator *, just**

as in Chapter 2, so the rules for specific words will be:

np (fido)

~-> [fido]. np(felix)

-->s [felix].

v(X*slept (X))

-~-> [slept]. v(Y* (X*chased(X,Y))) --s [chased]. Then it is simple to write phrase-structure rules that combine their arguments in the desired ways:

<!-- page 80 -->
s(Pred) --s np (Subj), vp (Subj*Pred). vp (Subj*Pred) --> v(Subj*Pred). vp(Subj*Pred) --s v(Obj*(Subj*Pred)), np(Obj).

S

chased (fido, felix)

**NP**

VP fido

(Ax)chased (x, felix)

V

NP

(Ay) (Ax)chased (x, y)

felix

Figure 3.6

Semantic representations are

;

;

built by combining the meanings of the Fido

chased

Felix — individual constituents.

The parser will then accept queries such as:

?- s(Semantics, [fido, chased, felix],[]). Semantics = chased(fido, felix)

?- s(Semantics, [felix,slept],{[]). Semantics = slept (felix)

Notice that the semantics also goes part of the way toward ensuring that chased has an object and slept does not. Unlike the original phrase-structure grammar, the parser does not accept *Fido slept Felix, and although it accepts *Fido chased, it produces a partly uninstantiated semantic representation that could easily be rejected by some other part of a natural language processing system.

This is a demonstration of SEMANTIC COMPOSITION, building the semantic representation of each constituent from those of its subconstituents. The technique shown here barely scratches the surface. We will return to semantic representations in Chapter 7, but first, there are many syntactic issues to be addressed.

Exercise 3.5.1.1

<!-- page 81 -->
According to this grammar, what is the semantic representation of *Fido chased?

Chap. 3

Exercise 3.5.1.2

Get the parser working and add the words saw, barked, Max, and Mary. Generate semantic

representations for Fido barked and Mary saw Max.

Exercise 3.5.1.3

Modify the parser described above so that it builds both syntactic and semantic representa-

tions. (Use one argument for each.)

**3.5.2 Semantic Grammars**

**A SEMANTIC GRAMMAR is something intermediate between a keyword or template sys-**

**tem and a phrase-structure grammar. Semantic grammars use phrase-structure rules, but**

**words are classified by their function in a particular situation (such as computer com-**

**mands or database queries) rather than general syntactic principles. Representations of**

**meaning are built by any of several techniques, including the method described in the**

previous section.

**Figure 3.7 shows some analyses of sentences that might be assigned by semantic**

**grammars in various situations. There are no “right” or “wrong” analyses; the goal is**

command

action

object

parameters

source

destination

diskdrive

diskdrive

**4™N**

copy

files

**from We to**

drive

B

query

action

test

**ee**

test

test

test

test

comparison

value

**operator “**

show programmers

in

Florida

with

salary

over

20,000

Figure 3.7 Semantic grammars assign arbitrary analyses to fit the purposes of a partic-

<!-- page 82 -->
ular computer program. purely to build something that works for a specific purpose. Parsing is often preceded by simplification just as in a template or keyword system.

Exercise 3.5.2.1

Reimplement your keyword system from Chapter 2 as a semantic grammar.

**3.6 OFFBEAT USES FOR DCG RULES**

**Some people use DCG rules not just for parsing, but also to define almost any predicate**

that works through a list item by item. I do not advocate this practice, but you should be aware of it. Here is a predicate that counts the elements in a list:

count_off(N) --> [_], count_off(M), { N is M+1l }. count_off(0) --> [].

More precisely, this predicate accepts a specified number of elements from the beginning of the list, thus:

?- count_off(N,[a,b,c],[]). N = 3

?- count_off(N,[a,b,c,d,e,fl,[e,f]). N= 4

?- count_off(2,[a,b,c,d,e],What). What = [c,d,e]

**Since this predicate has nothing to do with parsing, the use of DCG notation tends to**

obscure rather than clarify how it works, and count_off would be better off written in plain Prolog:

count_off(N, [_|Rest],Tail) :- count_off(M,Rest,Tail), N is M+1. count_off(0,Tail,Tail).

(Note that count_off(0) --> [] doesn’t mean “do this at the end of the list”; it means “do this without accepting anything from the list,” although in fact it is the only rule that can apply when the list 1s empty.)

Exercise 3.6.0.1

Use DCG rules to implement a predicate that accepts a list of numbers and computes their

```prolog
sum.
```

<!-- page 83 -->
Chap. 3

Exercise 3.6.0.2

**Is ‘dog --> "dog".’a legal DCG rule? If so, what does it mean and how might you**

use it?

Exercise 3.6.0.3 (project)

Write a program that breaks a string of characters into words by using DCG rules. That is,

it should convert "this is it" to [this, is,it] or the like.

This is a reasonable thing to do, because breaking a string into words is a kind of

parsing. The phrase-structure rules might include the following, or something similar:

Token

->» — Special-character

Token

->

Alphanumerics

Alphanumerics

—>

Alphanumeric—character Alphanumerics

**Alphanumerics > @**

Alphanumeric-character

—>

a

Alphanumeric-character

—>

b

**Alphanumeric-character > ¢**

For detailed advice see Appendix B.

**3.7 EXCURSUS: TRANSITION-NETWORK PARSERS**

**DCG parsers are equivalent in power to an older parsing technique called AUGMENTED**

**TRANSITION NETWORKS (ATNs). This section will briefly review ATNs as well as the**

**simpler transition networks from which they are derived. There is little point in imple-**

**menting an ATN in Prolog, since DCGs do the same job better, but it is useful to know**

**how ATNs and DCGs correspond.**

.

**3.7.1 States and Transitions**

**A TRANSITION NETWORK is a parser that has a number of distinct sTaTES and proceeds**

**from state to state in a manner controlled by the input string.**

**Figure 3.8 shows a transition network that parses the dog, the big dog, the cat,**

**and nothing else. Circles represent states and arcs represent transitions. A small ar-**

**row shows where to start, and a double circle indicates a state in which parsing can**

stop.

**To parse a sentence, the parser must get from the initial state to a state in which**

**it can stop. This is done by following the arcs and accepting, from the input string, the**

**words that are on the arc labels. An unlabeled arc is called a suMP ARC and allows a**

**state transition without accepting any input. So the process by which this network parses**

**the dog is:**

<!-- page 84 -->
the

big

dog TING TN

**©**

**@**

**@**

**a**

Figure 3.8 A finite-state transition

cat

```prolog
                                      network.
Start in state 1.
Go to state 2 accepting the.
```

Go to state 3 via the jump arc.

Go to state 4 accepting dog.

Stop.

Because it has a finite number of states, this is a FINITE-STATE TRANSITION NET- WORK (FSTN) or FINITE AUTOMATON.

A transition network is DETERMINISTIC if it cannot backtrack, and NONDETER- MINISTIC if it can. More formally, a network is deterministic if, at every step, the choice of arcs is uniquely determined by the next word in the input string. In natural language processing, we work with networks in which nondeterminism is allowed, and we will assume that they are implemented in such a way that backtracking is possible.

A FINITE-STATE TRANSDUCER is an FSTN in which each of the transitions can produce output as well as accepting input. Figure 3.9 shows a finite-state transducer that can translate the big dog and the cat (but almost nothing else) into Spanish. The arc label the:el means “input the and output e/,” and likewise for the other labels. Thus, this network translates the dog to el perro; the big dog to el gran perro; and the cat to el gato. By reversing the roles of the input and output, we could just as easily get it to translate Spanish into English.

the-el

big:gran

dog:perro TN TN TOO

**@)**

**@)**

**@**

Figure 3.9 A finite-state transducer that

cat: gato

translates English phrases into Spanish.

<!-- page 85 -->
A finite-state transition network can contain CYCLES; that is, an arc can loop back to the state that it started in, or even to an earlier state. This enables the network to accept arbitrarily long strings. Figure 3.10 shows a network that accepts the dog the big dog the big big dog the big big big dog

(etc.).

Although the number of states is finite, the number of words in the input string of this network is not bounded.

big

the

**dog**

**TN TONNE OGN**

CG)

**@)**

Figure 3.10 This finite-state transition

network can accept arbitrarily long strings.

Finite-state transition networks are easy to implement in conventional programming languages, but they are clearly not adequate for human language; they provide no way to recognize constituent structure. Nonetheless, they have their uses in implementing templatelike systems (Chapter 2) and in analyzing morphology (Chapter 9).

Exercise 3.7.1.1 List the steps that the network in Figure 3.8 goes through when parsing the cat.

Exercise 3.7.1.2 Does the network in Figure 3.8 parse the big cat? Explain.

Exercise 3.7.1.3 Does the network in Figure 3.8 accept the big (with no words following)? Explain.

Exercise 3.7.1.4 Are the networks in Figures 3.8 and 3.10 deterministic?

Exercise 3.7.1.5 List the steps that the transducer in Figure 3.9 goes through when translating the dog into Spanish.

<!-- page 86 -->
Exercise 3.7.1.6 Can the network in Figure 3.10 accept an infinitely long string? What is the difference between accepting an infinitely long string, and accepting arbitrarily long strings? 3.7.2 Recursive Transition Networks

**A RECURSIVE TRANSITION NETWORK (RTN) is one in which a state transition can either**

accept a word, or execute (call) another entire network. In particular, a network can call itself, either directly or indirectly (for example, S can call VP and VP can call S). This makes it possible to parse sentences within sentences. It also means that the number of states available to the parser is no longer finite, because any number of recursive invocations of the same network could be in use at the same time.

**Figure 3.11 shows an RTN that parses sentences such as The gardener said the**

butler thought the dog barked (compare Section 3.1.3 above). By using recursion, this network parses an S within an S. Here the lexicon is shown separate from the transition network. This is standard practice, but the lexicon could, of course, be rendered as a transition network if we wanted to do so.

**NP**

**VP**

**NP:**

**oe)**

**®**

**VP:**

**@**

**@)**

Lexicon:

D:

the

N:

dog, cat, butler, gardener

V:

said, thought, barked

Figure 3.11 A recursive transition network.

**RTNs are essentially equivalent to phrase-structure rules or DCG rules without**

<!-- page 87 -->
arguments. There is, however, a minor difference. RTNs can contain cycles that allow ‘ unlimited repetition (Fig. 3.12); DCG rules and ordinary PS rules cannot. This is not a serious problem, because any network containing a cycle can be replaced by a set of PS rules that use recursion. For example, the network in Figure 3.12 can be replaced by the rules

**NP > DN**

**NO > Adj N!**

**N+ N**

**which, of course, go into DCG straightforwardly.**

**Adj**

**D**

**N**

**a**

**a**

**a**

**@**

**@)**

Figure 3.12 A cycle in an RTN.

**These three rules generate the same sequences as the original network (D N, D**

**Adj N, D Adj Adj N, etc.), but the tree structure is not the same. The rules introduce**

N! constituents which the original network does not. Fortunately, there are linguistic reasons for thinking that these NV! constituents are real, and thus that the cycle in the network is not really appropriate for describing the structure of English. Exercise 3.7.2.1

List the steps that the RTN in Figure 3.11 goes through when parsing each of these sentences:

The dog barked.

The butler said the gardener thought the dog barked.

Exercise 3.7.2.2

Construct a definite-clause grammar that is equivalent to the RTN in Figure 3.11.

Exercise 3.7.2.3

List the steps that the network in Figure 3.12 goes through when parsing the big big big dog

(assuming an appropriate lexicon).

Exercise 3.7.2.4

Diagram the tree structure of the big big big dog using the PS rules given in this section.

**3.7.3 Augmented Transition Networks (ATNs)**

**We saw earlier that the real power of DCGs comes from the ability to have arguments**

**on the nodes. The equivalent of a DCG with arguments is an AUGMENTED TRANSITION**

**NETWORK (ATN), which is like an RTN except that:**

e Each subnetwork can have REGISTERS (memory locations) in which information can

be stored.

e Each arc can have actions associated with it. These actions include storing, re-

trieving, and testing register values, and adding items to, or retrieving items from,

<!-- page 88 -->
a holding list. e Data can be transferred between the registers of a subnetwork and the registers of the network from which it was called. For example, register values associated with a noun can be copied into the registers of the NP in which the noun occurs.

There are several different notations for ATNs, with different abstract instruction sets, and, compared to DCGs, all of them are cumbersome. Woods (1970) and Bates (1978) expound ATNs in detail. Pereira and Warren (1980) show that all ATNs can be translated into DCGs, and that, in general, the DCGs are more concise, more readable, and potentially faster to execute. Figure 3.13 shows a simple ATN that enforces subject-verb agreement. Here are the steps that it goes through when parsing The dog sees the cats (ignoring backtracking):

Start in state 1 of S network. Call NP network. Start in state 1 of NP network. Accept D (the). Proceed to state 2 of NP network. Accept N (dog, NUM=SINGULAR)._ Set register NUM of NP = SINGULAR. Proceed to state 3 of NP network and exit. Set register NUM of S = SINGULAR. Proceed to state 2 of S network. Call VP network. Start in state 1 of VP network. Accept V (sees, NUM=SINGULAR).

<!-- page 89 -->
Set register NUM of VP = SINGULAR. Proceed to state 2 of VP network. Call NP network. Start in state 1 of NP network. Accept D (the). Proceed to state 2 of NP network. Accept N (cats, NUM=PLURAL). Set register NUM of this NP = PLURAL. Proceed to state 3 of NP network and exit. Proceed to state 3 of VP network and exit. Test that Num of S = NUM of VP (the test succeeds; both have the value SINGULAR). Proceed to state 3 of S network and exit.

**NP**

**VP**

**Set NUM of S__ Test NUM of S**

**= NUM of NP**

**= NUM of VP**

**S: ~~**

**©**

**®**

**N**

**D**

**Set NUM of NP**

**= NUM of N**

**NP:**

**@**

**®**

Vv

Set NUM of VP

= NUM of V

**NP**

**TTS**

**TOS**

**VP:**

**@**

**@)**

**“.—_7”**

Lexicon:

D: the

N: dog, cat, mouse

**NUM = SINGULAR**

**dogs, cats, mice NUM = PLURAL**

V: chases, sees

**NUM = SINGULAR**

chase, see

**NUM = PLURAL**

Figure 3.13 An augmented transition network that enforces subject-verb agreement.

**Figure 3.14 shows an ATN that parses questions such as Who did the gardener**

think chased the cat? using a holding list. A striking difference between ATNs and DCGs is that ATNs lack the concept of unification. Thus, in place of simply trying to instantiate variables, ATNs have to perform lots of separate assignments and comparisons. In Chapter 5 we will explore the usefulness of unification in grammatical analysis.

Exercise 3.7.3.1

Is the network in Figure 3.13 deterministic? Explain.

Exercise 3.7.3.2

**Construct DCGs equivalent to the networks in Figures 3.13 and 3.14.**

<!-- page 90 -->
**who**

Place who on

did

NP

VP holding list nn ee ee re @

**@)**

**@)**

**@)**

**NP:**

**@**

**@)**

Retrieve who

from holding list

**a**

**er aa**

**VP:**

**oe)**

**@)**

**NX._7”**

Lexicon:

D: the

. N: dog, cat, butler, gardener V: say, said, think, thought, bark, barked

Figure 3.14 An augmented transition network that parses wh-questions.

Exercise 3.7.3.3

List the steps that the network in Figure 3.14 goes through when parsing the sentence Who did the butler say thought the dog barked?

