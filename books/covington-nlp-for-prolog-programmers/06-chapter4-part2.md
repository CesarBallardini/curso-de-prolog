# Chapter4_Part2

<!-- page 111 -->
**ee**

Conj oN

**ee**

Nn}

Nn!

|

|

|

| in the

garden

and

around

g

town

(d) ee

Conj

**oN**

N}

N}

|

|

| chased

4)

cats

and

climbed

4)

trees

()

<!-- page 112 -->
Figure 4.9 cont.

English Phrase Structure

Chap. 4

**PP -— _ PP Conj PP**

VP ->

VP Conj VP

Ve

**VConjV**

**and so on. But even these rules aren’t DCG parsable; they cause loops, as noted in**

Chapter 3, where a trick for handling them was suggested.

Challenging as this is, it is still not the whole story about conjunctions. Hudson (1988) points out that in a sentence like

John drank [> coffee at breakfast

] and [» tea at lunch ]. the conjoined elements, coffee at breakfast and tea at lunch, are not constituents (Hudson 1988). Apparently, this sentence arises through a process of ELLIPSIs (omission of understood material) from the complete sentence

[s John drank coffee at breakfast | and [s John drank tea at lunch }.

**or at least the properly conjoined VP**

John [yp drank coffee at breakfast | and [yp drank tea at lunch .

There is no standard approach to parsing ellipsis phenomena such as these, but you should be aware of them.

Exercise 4.5.1.1

Draw a tree for John drank coffee at breakfast and drank tea at lunch. Now try to do the

same thing with the second occurrence of drank omitted. What goes wrong?

Exercise 4.5.1.2

Why doesn’t a loop arise when parsing correlating (discontinuous) conjunctions such as

both... and and either... or?

Exercise 4.5.1.3

Add rules to your parser to parse the following sentences:

It is both very warm and quite dry.

John drank both coffee and tea.

<!-- page 113 -->
Do not attempt to handle any conjunctions other than both... and. 4.5.2 Sentential PPs

Traditional grammar recognizes numerous SUBORDINATING CONJUNCTIONS, such as before, after, when, whenever, and because, which allow a whole sentence to modify (describe) some part of another sentence. Examples:

I saw him after [s he left ].

The discussion after [gs he left | was surprising.

Here after he left modifies saw and discussion respectively.

Emonds (1976:172-176) and Radford (1988:134-137) argue convincingly that these “subordinating conjunctions” are not conjunctions at all, but rather prepositions of a special kind that take S rather than NP after them. Figure 4.10 shows the kind of structures that this entails.

There are two main reasons to view “subordinating conjunctions” as prepositions. First, some of them are prepositions (of the kind we are already familiar with) and can equally well take an NP instead of an S. Examples:

after [s he left

]

The discussion

after [np the meeting ]

was interesting.

I saw him | before [s he left

]

|

before [np the meeting }

Second, sentential PPs occur in the same positions as ordinary noun-phrase-containing PPs. We have just seen them at the ends of NPs and VPs. Both kinds of PPs also occur at the beginning of the sentence:

After he left

.

the discussion continued.

After the meeting

This means that our familiar rule S

~ NP VP must be rewritten as:

**S — (PP) NP VP**

and the rules for PP become:

**PP —+ PNP**

**PP —+ PS**

There is now a subcategorization problem with P because some Ps take only NP; some, such as whenever, take only S; and some take either NP or S. For the moment, we will ignore this.

<!-- page 114 -->
3For theoretical reasons the object of P may tum out to be not S but § with the null complementizer. In parsing, this makes no difference. S

**eg**

NP

VP

| | Pronoun Vv

NP

PP

**i**

Pronoun

P

Ss

**aan**

NP

VP

|

Pronoun

Vv

| I saw

him

after

he

left

(a)

S

**_**

NP

VP ee ee

**-_N**

**D**

N!}

**PP**

Copula

AdjP

**N**

P

S

Adj

**AN**

NP

VP

|

|

Pronoun

V

| the discussion

after

he

left

was

surprising

(b)

Figure 4.10 Examples of PP containing S.

Exercise 4.5.2.1

The sentence I heard about the discussion after the meeting is structurally ambiguous; after the meeting modifies either discussion or heard. Draw trees for its two structures.

Exercise 4.5.2.2

<!-- page 115 -->
Extend your parser to handle the sentences in Figure 4.10, as well as:

he left

the meeting

After

the discussion was surprising.

Do not attempt to account for subcategorization of prepositions.

**4.6 WHERE PS RULES FAIL**

4.6.1 Adverbs and ID/LP Formalism

Like adjectives, adverbs take degree specifiers in front of them. The rule that accounts for this is

AdvP

-—>

(Degree) Adv

and the resulting structures include

AdvP

AdvP

|

**YN**

**“"**

**mes**

Adv

quickly

very

quickly

and the like.

The odd thing about AdvPs in English is the variety of positions in which they occur. For example:

Quickly he chased him into the garden.

He quickly chased him into the garden.

He chased him quickly into the garden.

He chased him into the garden quickly.

There is good evidence that the first two of these adverb positions hang from S and the latter two hang from VP, so that the structures are as shown in Figure 4.11.

**This means that our S and VP rules need to be interspersed with optional AdvPs.**

Here is a stab at reformulating these rules:

**S — (AdvP) (PP) NP (AdvP) VP**

VP -»

V(NP) (AdvP) (PP) (NP) (AdvP) (PP) (S')

(highly dubious!)

<!-- page 116 -->
s This is unsatisfying; the VP rule, in particular, is a real mess. Even though we’ve left : out particles, the VP rule has seven optional elements and is therefore apparently the equivalent of 128 different DCG rules! In reality it’s not quite that complex, because some of the options are equivalent to each other; for instance, if you choose VP > V NP,

**Chap. 4**

RY

**oe**

**AdvP**

**NP**

**VP**

|

**ee**

**ee**

Adv

Pronoun

Vv

**NP**

**PP**

**aN**

Pronoun

**P**

**NP**

**YN**

**D**

**N}**

|

**N**

|

quickly

he

chased

him

into

the

garden

(a)

RY

**ae**

**NP**

**AdvP**

**VP**

|

**OL**

Pronoun

Adv

V

**NP**

.

**PP**

|

**ON**

Pronoun

**P**

**NP**

**AON**

**D**

**N!**

|

**N**

|

he

quickly

chased

him

into

the

garden

(b)

Figure 4.11 Adverbs occur in many different positions in the English sentence.

**it doesn’t matter whether you choose the first NP or the second. Still, the whole thing**

**is unwieldy.**

**What we would really like to Say is that adverbs are a fundamentally different**

**kind of thing than nouns or verbs. Instead of occupying fixed positions, AdvPs can go**

**anywhere as long as they hang from an S or VP node and do not interrupt another con-**

<!-- page 117 -->
stituent. That is, instead of having many different positions, the AdvP has an unspecified or “free” position. S

**ee**

NP VP SO Pronoun Vv NP AdvP PP | ws Pronoun Adv P

NP YN D

N!}

|

**N**

| he chased him quickly into the

garden 5 {c)

**a**

NP . VP ee Pronoun Vv NP PP

AdvP a

| Pronoun P NP

Adv YN D N} | N | he chased him into the garden

quickly

(d)

Figure 4.11 cont.

**But this is something that PS rules can’t express. Phenomena like adverb placement**

**led Gazdar, Klein, Pullum, and Sag (1985) and many others to replace PS rules with**

**ID/LP RuLEs. In ID/LP formalism, a rule such as**

**VP — __V, NP, PP, AdvP**

**says only that VP immediately dominates V, NP, PP, and AdvP; that’s why it’s called**

<!-- page 118 -->
an ID (IMMEDIATE DOMINANCE) rule. It doesn’t say in what order the V, NP, PP, and AdvP occur. The order is established by one or more LP (LINEAR PRECEDENCE) rules such as:

**V <NP**

V <PP

**NP**

< S$!

which say that V precedes NP, V precedes PP, NP precedes S!, and so on (when they hang from the same node). This is only a partial specification of the ordering. Constituents can occur anywhere as long as they don’t violate any LP rules. So if no position is specified for AdvP, AdvP can occur anywhere. ID/LP parsers have been developed (Kilbury 1984, Shieber 1984, Barton 1985, Leiss 1990).

Exercise 4.6.1.1

Extend your parser to handle all the sentences in Figure 4.11, plus the same sentences with

very quickly in place of quickly. You need not add rules for expansions of VP that do not

occur in these sentences.

Exercise 4.6.1.2

Convert the ID/LP rules

**VP — _V,NP, PP, AdvP**

V <NP

V < PP

NP < PP

into the complete set of equivalent PS rules.

4.6.2 Postposing of Long Constituents

There is a general tendency in English for long constituents to be POSTPOSED (placed at the very end of the sentence). This is obviously a practical thing to do; it lets the hearer parse as many constituents as possible, thereby obtaining context, before tackling the longest one.

Here’s an example. One reason our VP rule is so complicated is that we must parse both

Max [vp revealed [np the fact ] [pp at the meeting | ].

and

<!-- page 119 -->
Max [vp revealed [pp at the meeting | [Np the amazing fact that birds fly ] }. That is, we have both VP + V NP PP and VP - V PP NP. The NP comes at the end if it is exceptionally long.

If we could explain in some other way why the long NP comes at the end of the sentence, we could simplify the VP rule. And indeed this seems like something we could do in ID/LP formalism: specify “the longest daughter of VP comes last” and let this take precedence over the other LP rules. So far, so good.

But there are cases where constituents are actually broken up in order to put a long constituent last. In transformational grammar this is called EXTRAPOSITION FROM NP (Radford 1988:448-456). Some examples:

A new book came out about the anatomy of dinosaurs.

A problem arose that nobody expected.

John called people up who were from Boston.

Here about the anatomy of dinosaurs clearly modifies book, not came out, and the situation is analogous in the other two sentences.

The structures that we would like to assign these sentences are shown in Figure 4.12. The trouble is, these structures aren’t trees. They contain DISCONTINUOUS CONSTITUENTS that cannot be generated by PS rules.

The standard analysis of these sentences is to say that the PS rules generate them with the constituents unbroken, and another kind of tule, called a TRANSFORMATION, then moves a constituent to the end. On this analysis, the DEEP (untransformed) structure of

A problem arose that I hadnt foreseen.

is

[np A problem that I hadnt foreseen | arose.

and the postposing of that I hadnt foreseen is a separate process.

To parse sentences with extraposed constituents, the parser will have to be ready, after parsing what appears to be a whole sentence, to pick up an additional constituent at the end and insert it in the proper place. The extraposition grammars of Pereira (1981) were designed partly to solve this problem. Extraposed constituents can also be handled by using features to pass information from one node to another as we did with wh-questions in Chapter 3.

Exercise 4.6.2.1

Suggest, in some detail, a way of parsing the sentences discussed in this section. You need

not actually implement it.

4.6.3 Unbounded Movements

<!-- page 120 -->
We saw in Chapter 3 that, in questions, the word who always appears at the beginning of the sentence, and exactly one NP is missing later on. It is exactly as if [yp who ] had s

Lo

**NP**

**VP**

**D**

N!} V Particle PP Jn _—— AdjP N!} P

**NP**

**Adj**

**N**

**D**

**N}**

**PP**

**aoe,**

**N**

**P**

**NP**

**LN**

**D**

**N}**

|

**N**

| A new book came out about the

anatomy

of

4)

dinosaurs

(a) S

**aa**

**NP**

**VP**

**Jp**

**D**

**N}**

**v**

**si**

| > ae

**N**

Comp

RY

**oN**

**NP**

**VP**

**ON**

Pronoun

**4**

**NP**

| A problem arose that nobody

expected

4)

(b)

<!-- page 121 -->
Figure 4.12 Long constituents are postposed, often breaking up the larger constituents in which they belong.

**S**

**NP**

**VP**

**Name**

**V**

**NP**

Particle

**D**

**N}**

**si**

**N**

**Comp**

Copula

**Name**

John

called

4)

people

up

who

4)

were

from

Boston

(c)

Figure 4.12 cont.

**been moved from its original site to the beginning. Examples:**

**Who said Bill thought Joe believed Fido barked? (Max.)**

**Who did Max say ,, thought Joe believed Fido barked? (Bill.)**

**Who did Max say Bill thought ,, believed Fido barked? (Joe.)**

**Who did Max say Bill thought Joe believed ,, barked? (Fido.)**

**Here |, represents the missing NP.**

**This phenomenon, called wh-movement, occurs not only in questions, but also in**

**exclamations such as**

**What a noise Max said Fido made ,,!**

**and in relative clauses (sentences modifying NPs) as in:**

**the boy who(m) Fido chased ,, into the garden**

<!-- page 122 -->
Wh-movements can be nested, as in this double relative clause:

the boy who(m) the girl who(m) we saw ,, liked ,,

**— ee**

But they cannot cross over each other; at any point, the parser can assume that the most recent wh-word will definitely correspond to the next missing NP.

Wh-movement is an UNBOUNDED movement. This means that there can be any amount of structure between the original position of the moved word or phrase and the place it ends up. Thus PS rules cannot account for it. In Chapter 3 we parsed whquestions with the aid of features; this is a standard approach (cf. the ‘slash features’ of Gazdar, Klein, Pullum, and Sag 1985).

Some structures are ISLANDS, which means that even unbounded movements cannot — move material out of them. Conjoined structures of all types are islands. For example, even though

**You saw Max and who(m)?**

is grammatical (in a suitable context), it is not possible to perform wh-movement and get

*Who did you see Max and \,?

**because Max and who(m) is an island. Islands were discovered by Ross (1967).**

Exercise 4.6.3.1

Look back at the feature-based parser for wh-questions that we built in Chapter 3. Describe

a way to add the rule

NP -— __ both NP and NP

to this parser in such a way that [yp both NP and NP ] will be treated as an island.

**4.6.4 Transformational Grammar**

Rules that rearrange the structure of a tree are called TRANSFORMATIONS. They were introduced by Chomsky (1957), who experimented with PS rules and found them inadequate. Chomsky was the founder of modern generative grammar, and his introductory account of it is still worth reading.

Once transformations were introduced, linguists used them to account for all sorts of grammatical regularities, including:

e Agreement (Chapter 3) and case marking (Chapter 5), now handled with features.

<!-- page 123 -->
e The relation between active and passive sentences such as:

The dog eats the food.

The food is eaten by the dog.

Nowadays these are accounted for by lexical rules (Chapter 9) which create, from

every verb such as eat, an adjective such as eaten with the appropriate meaning.

e Various alternative word orders, such as That he succeeded surprised me versus It

surprised me that he succeeded, which are now treated as alternatives in the PS

```prolog
rules.
```

Transformational grammar does not lend itself to parsing. The reason is that every transformation is a tree-to-tree mapping and thus cannot be undone without knowing the tree structure. So the parser has to determine the tree structure before undoing any transformations. And if transformations are necessary to account for tree structure, this is impossible.

In practice, transformational parsers rely on a COVERING GRAMMAR, a set of PS rules that account for the structures after the transformations have applied. But if the sentence can be parsed with the covering grammar, then there is usually no need to undo the transformations—the parser can proceed with other kinds of analysis immediately. Because of this, transformational’ grammar is seldom used in natural language processing.

Since the 1970s, the trend has been to replace transformations with more specialized mechanisms, such as features. Emonds (1976) gives a good summary of transformational grammar as it was in its heyday. In Chomsky’s current theory, transformations remain as a means of accounting for certain movements, but they are defined in terms of more abstract principles, particularly GOVERNMENT (case assignment, Chapter 5) and BINDING (an abstract relation between specific positions in the sentence, such as the missing NP position and the moved wh-word). For an introduction to government and binding theory, see Sells (1985).

Exercise 4.6.4.1

Implement, with DCG rules, a covering grammar for a grammar that contains the rules

S

—+>

NP VP

NP

**+> DN**

VP

-—>

V/(NP) (PP)

PP

—+

PNP

**D > the**

**N -— _ dog, cat, garden**

**V —**

© slept, barked

P

—>

in

plus a transformation that optionally moves PP to the beginning of the sentence (as in In the

garden the dog barked). Note that a covering grammar does not undo the transformation; it

<!-- page 124 -->
merely parses a structure in which the transformation may have applied. 4.7 FURTHER READING

There is no place you can go to look up “the rules of English” for computer implementation, because linguists do not yet agree on what form these rules should take. One of the most comprehensive modern generative grammars is that of Gazdar, Klein, Pullum, and Sag (1985); the classic study of phrase structure is Jackendoff (1977); and the best introductory textbook, for our purposes, is probably Radford (1988). The classic handbook by Stockwell, Schachter, and Partee (1973) relies so heavily on transformations that it does not lend itself well to parser implementation.

The best way to extend a parser is to feed it some actual text and see where it breaks down, then add rules as needed. For guidance on how to analyze particular syntactic phenomena, see Matthews (1981) on the nature of syntactic structure, and Huddleston (1988), and Quirk et al. (1973, 1985) for detailed descriptions of English. These are DESCRIPTIVE handbooks of grammar; they contrast sharply with PRESCRIPTIVE handbooks designed for teaching English to foreigners or teaching native speakers to write more clearly. Prescriptive handbooks are almost useless to the parser builder.

**Among dictionaries, Hornby (1989) is especially useful because it specifies the**

kinds of complements required by each verb or noun.

