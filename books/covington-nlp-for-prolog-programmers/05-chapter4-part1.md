# Chapter4_Part1

<!-- page 91 -->
**English Phrase Structure**

**4.1 PHRASE STRUCTURE**

The main purpose of this chapter is to develop a rough-and-ready set of phrase-structure rules for parsing some of the major structures of English, and, perhaps more importantly, to illustrate how a set of rules is developed.

Developing a formal grammar is a lot like writing a computer program; there are many points at which you can do any of several things as long as you follow up the consequences of your decision consistently. There are many other places at which one choice is probably better than another, but it will take a lot of research to find out which is better, and the difference may never show up during the lifetime of one project.

The rules developed here are not coniplete, for two reasons. First, if we tried to cover all the PS rules of English, this chapter would be hundreds of pages long. Second, there are structures that cannot be parsed with phrase-structure rules alone; we will look at some of them and develop appropriate parsing mechanisms in the next chapter.

<!-- page 92 -->
The rules in this chapter incorporate many of the ideas of Radford (1988), Jackendoff (1977), and Gazdar, Klein, Pullum, and Sag (1985) but do not adhere strictly to any theory. In particular, for convenience I ignore the distinction between adjuncts and complements, although I think it is valid; see Radford for a clear and detailed presentation. Students who have been trained in transformational grammar should note that here—as almost always when parsing—we are analyzing surface structure and not attempting to capture deep generalizations.

4.1.1 Trees Revisited

Before developing PS rules we must look more deeply into their significance. Consider a syntactic tree like the one shown in Figure 4.1. The points where lines begin or end

S

**a**

NP

VP

**ee**

**oN**

N

V

NP

PP

**_——**

**—_**

N

P

NP

**AN**

D

**N**

the

dog

chased

a

cat

into

```prolog
                            i.
                                    san
Figure 4.1 A syntactic tree.
```

in a syntactic tree are called NopEs. Normally, nodes bear LABELS such as S, NP, VP, NP, or dog.

If two nodes are connected by a line, the upper node IMMEDIATELY DOMINATES the lower one. More generally, one node DOMINATES another if you can get from the first node to the second by following lines downward. For example, the first NP node dominates D, N, the, and dog.

Two nodes are said to be sisTERs if they are immediately dominated by the same node. For example, D and N are sisters in the tree above. Their MOTHER is NP; that is, they are DAUGHTERS of NP.

The words at the bottom of the tree diagram are the TERMINAL NODES. A CON- STITUENT consists of all the terminal nodes dominated (immediately or indirectly) by a particular nonterminal node.

A tree is equivalent to a LABELED BRACKETING of words into groups. For example, the tree shown at the top of page 79 could be written as

[s Lye [p @ p] [nN dog Nn] np] [vp [vy barked y] vp] s]

<!-- page 93 -->
Without loss of information, the labels could be omitted on either the opening or closing brackets (not both). Labeled bracketings are often used to indicate part of the structure Sec. 4.1

Phrase Structure

79

RY

**_———**

**NP**

**VP**

**AN**

|

**Pop**

**|**

a

dog

barked

of an example sentence, as in:

We thought [s it was raining ].

Exercise 4.1.1.1

In Figure 4.1, which nodes are dominated by VP? Which are immediately dominated by

VP?

Exercise 4.1.1.2

In Figure 4.1, identify the sisters of PP and the daughters of PP.

Exercise 4.1.1.3

Express Figure 4.1 as a labeled bracketing.

Exercise 4.1.1.4

Express [4 [p [c xxx yyy ] ] [p zzz] ] as a tree diagram.

**4.1.2 Constituents and Categories**

A tree gives two kinds of information about the sentence: it divides it intO CONSTITUENTS (phrases) and classifies these constituents into CATEGORIES such as NP, VP, and the like. For example,

© the is a constituent of type D; e dog is a constituent of type N; e the dog, a cat, and the garden are constituents of type NP; e chased a cat into the garden is a constituent of type VP; e the dog chased a cat into the garden is a constituent of type S.

**How do we know this is the right way to group the words in this sentence—that,**

<!-- page 94 -->
for example, into the garden really is a constituent and a cat into is not? Although none of them is infallible, there are several standard tests for constituency: e Any string of words that can be MOVED AS A UNIT is probably a constituent. Instead of The dog chased a cat into the garden you can say Into the garden the dog chased acat. This argues strongly that into the garden is a constituent. e Any string of words that can be DELETED is probably a constituent. Again, you can leave out into the garden without changing the grammatical or semantic relations in the rest of the sentence. This, too, argues that into the garden is a constituent. e Usually, the MEANING of a constituent is, in some sense, a unit. It makes sense to ask what into the garden means; it makes much less sense to ask what a cat into means.

The strongest argument for the correctness of any phrase-structure tree, however, is the fact that it is generated by a coherent system of rules that also accounts for many other facts about English syntax. The claims that a tree makes about categories are also important. For example, by labeling the cat, the dog, and the garden all with the label NP, this tree makes the claim that they are syntactically alike—they can all occur in the same positions. And indeed a cat chased the dog into the garden, or even the garden chased a cat into the dog, is a grammatical (if somewhat odd) sentence of English.

Exercise 4.1.2.1 List all the constituents that are identified by Figure 4.1.

Exercise 4.1.2.2 Cite at least two kinds of evidence | that a cat is a constituent in the sentence The dog chased a cat into the garden.

Exercise 4.1.2.3 Cite evidence that, in The dog chased a cat into the garden, the and a belong to the same category.

4.1.3 Structural Ambiguity

Many sentences are AMBIGUOUS, i.e., the same sentence can mean two or more different things. Usually the ambiguity is LExIcAL—that is, a word or idiomatic phrase within the sentence can have more than one meaning. For example, glasses can mean either spectacles or drinking-glasses. But some ambiguities are STRUCTURAL; they result from the existence of more than one tree structure for the same string of words. Figure 4.2 shows a striking example: J saw the boy with the telescope can mean either that the boy had the telescope, or that I did the seeing with the telescope, and sure enough, the rules of English allow two tree structures, one with each meaning. In one tree, with the telescope modifies boy (and thus the boy with the telescope

<!-- page 95 -->
is a constituent); in the other, with the telescope modifies saw.

S

**a**

**NP**

**VP**

**a**

**vl V**

**NP**

**_— |**

**D**

**N**

**PP**

**_——**

**P**

**NP a**

I

saw

the

boy

with

Le

**sree**

S

**a**

**NP**

**VP**

|

**es ee**

Pronoun

**V**

**NP**

**PP**

**_——**

**a**

I

saw

the

boy

with

**I**

**sacs**

Figure 4.2 The two meanings of this sentence correspond to two tree structures.

Exercise 4.1.3.1 Give the two meanings of each of the following sentences, and state whether the ambiguity is structural, lexical, or both. Explain how you know.

<!-- page 96 -->
By 1960 the Soviet Union had several satellites. The painter put on another coat. The judge threw the book at him. Visiting relatives can be tiresome. We like flying planes. 4.2 TRADITIONAL GRAMMAR

4.2.1 Parts of Speech

Many of the terms and concepts used in phrase-structure grammar come from a centuriesold tradition. The classification of words into “parts of speech” (nouns, verbs, adjectives, etc.) goes back to classical antiquity (Robins 1967) and was originally developed for Greek and Latin. It works reasonably well for English if some adjustments are made. This section will review traditional grammatical concepts briefly.

Table 4.1 illustrates the traditional parts of speech in English. The classification shown is neither complete nor entirely self-consistent. It is given mainly to illustrate the traditional terminology.

The first thing to note is that these categories are syntactic, not semantic. They are supposed to explain where each word can occur in the sentence; they are not a classification of word meanings. This is important because schoolbooks often say that “a noun denotes a person, place, or thing,” “a verb denotes an action or event,” and so forth. Such assertions are demonstrably false. Surely a sunset or a burglary is an event, but sunset and burglary are nouns, not verbs.

This does not mean that meaning is of no help in classifying words. Nouns do tend to refer to people, places, and concrete objects, and verbs do tend to refer to events, actions, or states. It’s just that this tendency is not absolute. It would be odd if mountain were a verb or if kick were not a verb.!

Even when words of different categories refer to the same thing, the meaning is packaged differently. The noun burglary and the verb burglarize denote the same kind of event, but there is a difference. The verb is marked for tense (past or present) and requires a subject and object; the noun does not. The noun, on the other hand, requires a determiner and can be made plural to denote more than one event of the same kind. In the Middle Ages, these differences in “packaging” were called modes of signifying (Covington 1984).

Exercise 4.2.1.1

Using traditional terminology, give the category of each word in each of the following

sentences:

Syntax and semantics are my favorite subjects.

We found him easily when he was ready.

I feel sick.

Exercise 4.2.1.2

A few grammar handbooks say that the sentence Hopefully, we’ll succeed either is ungram-

matical, or means “We will succeed in a hopeful manner’ (not “We hope we’ll succeed’ as

the speaker intends). Based on what Table 4.1 tells you about adverbs, critique this claim.

<!-- page 97 -->
'But mountain is a verb in Nootka, a Native American language in which almost every word has both noun and verb forms. English, like most European languages, tends to make other categories into nouns; we have nouns derived from verbs (destroy —> destruction), adjectives (red — redness), and even particles (out — outing). TABLE 4.1 TRADITIONAL SYNTACTIC CATEGORIES (PARTS OF SPEECH)

Nouns Proper (name): Joe, Frankenstein, America Common (ordinary)

Count (distinguishes singular from plural): dog/dogs, theory/theories

Mass (Noncount) (no plural): water, air, stuff, superiority Gerund of verb: singing, painting (as in painting is fun)

Pronouns Personal: he/him, she/her, it, we/us, you, they/them Reflexive: himself, herself, itself, ourselves... Demonstrative (Deictic): this, that (as in This is it) Indefinite: someone, everybody, nobody, something...

Determiners Articles: the, a (an) Demonstrative (Deictic): this, that (example: this house) Quantifiers: every, all, some, three Possessive pronouns: my, your, his, her, their

Adjectives

. Positive: big, good, exceptional Comparative: bigger, better Superlative: biggest, best Participle of verb: distracted, singing (as in a singing cowboy)

Verbs Intransitive (taking no object): sleep, yell, bark Transitive (taking one object): kick, emulate, destroy, read Ditransitive (taking two objects): give (as in give Joe the book) Copula (verb of being): be, am, is, are, was, were Modals (preceding another verb): may, might, can, could, will, would... Auxiliaries (preceding the verb, can follow a modal): be, is, are, has

**Adverbs**

Modifying a verb: quickly, slowly, today, here Modifying an adjective or adverb: very, extremely, slightly Modifying the whole sentence: hopefully, unfortunately

Prepositions With objects: in, before, after, below... (example: in the house) Without objects (Particles): up, down, in, out (example: Look it up)

Conjunctions Coordinating (joining constituents of same type)

Simple: and, or

Correlating: both... and, either... or, neither... nor Subordinating (joining embedded sentence to main sentence):

before, after, although, because, when, whenever

<!-- page 98 -->
Interjections: no! yes! oh! ouch! wham! bang! alas! 4.2.2 Grammatical Relations

Traditional grammar analyzes sentences, not by drawing constituency trees, but by identifying relationships that connect one word to another. For example, in The dog chased the cat into the garden, a traditional grammarian would say that:

dog is the sUBJECT of chased;

cat is the (DIRECT) OBJECT of chased;

into the garden MODIFIES (describes) chased;

garden is the object of the preposition into; and

the three occurrences of the modify dog, cat, and garden respectively;

Table 4.2 lists the traditional names for grammatical relations. As you can see, there is often some uncertainty whether a grammatical relation belongs to a word or to a whole phrase; some people say the object of chased is cat and others say it is the cat. In traditional grammar this uncertainty was never entirely cleared up.

TABLE 4.2 GRAMMATICAL RELATIONS IN TRADITIONAL

GRAMMAR

Subject: Noun phrase required to precede a verb.

Examples: Birds fly. All the students are listening.

Clause (embedded sentence) as subject: That he succeeded is amazing.

Predicate: The entire verb phrase.

Examples: Birds fly. All the students are playing soccer.

Object: Noun phrase required to follow a verb or preposition.

Object of preposition: in the house

Object of verb: John loves Mary. Asimov wrote two hundred books.

Indirect (first) object of two-object verb: John gave Bill the answers.

Direct (second) object of two-object verb: John gave Bill the answers.

Complement: Something other than an NP required after a verb.

Adjective as complement: He looked silly.

Clause (embedded sentence) as complement: We thought he was crazy.

Modifier: Any word or phrase that describes another.

Adjective modifying noun: big dogs

Adverb modifying verb: barks loudly

Clause modifying sentence: When they sang, we laughed.

<!-- page 99 -->
Grammatical relations can be defined in terms of phrase structure. For example, an object is an NP immediately dominated by VP or PP; a subject is an NP immediately dominated by S; and so forth (Chomsky 1965). Exercise 4.2.2.1

Using Table 4.2 as a guide, identify as many grammatical relations as possible in the

following sentences:

Three snails crept into the garden.

The slimy creatures gave us a sudden surprise.

When we saw them, we jumped.

**4.3 THE NOUN PHRASE AND ITS MODIFIERS**

**4.3.1 Simple NPs**

In constructing a set of phrase-structure rules we will begin with the NP. To a first approximation, the NP rule looks something like this:

**NP -> _ D (Adj) N (PP)**

This accounts for NPs such as:

the dog

the gray cat

the dog in the garden

the young boy with the telescope

The determiner can be null, as in our well-worn example [yp Birds ] fly. This is accounted for by the rule

**D—>**

**@**

**alongside D — the and the like.**

Most determiners are single words (the, a, some, every, five, and the like). For now, we'll ignore NPs in which an article and a quantifier occur together (e.g., [p the two |] boys), as well as the internal grammar of numbers such as three thousand Jour hundred twenty-two and complex quantifiers such as more than three. For interesting analyses of phrases such as these, see Jackendoff (1977).

**In Chapter 3 we saw that a determiner can consist of a complete NP followed by**

possessive °s, as in [np the junkman ]’s daughter. The NP can be of almost any type, but there seems to be a requirement that it end in a noun; you can say the queen of England’ crown but not *the boy who ran quickly’s prize. We can assume that this requirement is a matter of morphology (the ’s ending only goes on nouns) and thus that the PS rules need not account for it.

<!-- page 100 -->
,

English Phrase Structure

Chap. 4

Pronouns and proper names do not take determiners, nor do they normally take adjectives or prepositional phrases. To account for pronouns and proper names, we introduce two more PS rules:

NP

-—_

Pronoun

NP —+

Name along with the appropriate lexical entries such as:

Pronoun

->

I, me, you, he, him, she, they ...

Name ->

Joe, Bill, Jack, Mary, Fido, Felix ...

Exercise 4.3.1.1 Construct a parser that implements all the PS rules discussed in this section, except for possessives. Use it to parse the noun phrases birds, the dog, the gray cat, the dog in the garden, and the young boy with the telescope.

This parser must construct a parse tree as a Prolog structure. Your instructor will test it with queries such as:

?- np(Structure, [the,gray,cat],[]). Structure = np(d(the) ,adj (gray) ,n(cat))

Remember that there is nothing in DCG notation that corresponds to the parentheses indicating optionality in a PS rule. You will have to work out, and implement, all the alternative rules in full.?

In most of the subsequent exercises in this chapter you will add rules to this parser. It will ultimately contain over 100 DCG rules. Debugging a parser: If your parser fails to accept a phrase, first check that your rules include all the necessary vocabulary. For example, if

?- np(Str, (the, young, boy, with, the, telescope] ,{l). fails, check that the, young, boy, with, and telescope are in your DCG rules.

Q

Next try to parse parts of the phrase. For example, try

| ?- np(Str, [the,young,boy],[]). (which, according to the grammar, should also be a noun phrase) and

?- pp(Str, (with, the, telescope] »[]). This will help you localize the rules that you have written incorrectly.

**Sometimes you can render VP — V (NP) into DCG as ‘vp --> v, (np ;**

[]).’ where (np ;

<!-- page 101 -->
(1) means “accept an NP or a null constituent.’ But if you use this trick while building tree structure in the way described here, your trees will be littered with unmotivated null constituents.

Once the parse succeeds, you’re not through; you must verify that it gives the right

structure, and that if more than one parse is possible, all the structures are consistent with

the grammar.

4.3.2 Multiple Adjective Positions

A noun can take an indefinite number of adjectives in front of it, as long as the meanings add up to something coherent. For example:

the big dog

the big green dog

the big hairy green dog

the big fat hairy green dog

the big noisy fat hairy green dog

**This, then, calls for a recursive rule. But the complete NP is not recursive; the other**

**parts of the NP (particularly the determiner) are never multiple.**

**The solution is to introduce another level of constituent structure between N and**

NP. Jackendoff calls it N, N’, or N!; in Prolog we’ll call it n1. Then in place of

**NP -— D (Adj) N (PP)**

we can write:

**NP —- DN! (PP)**

**N! + Adj N!**

**Noo» N**

and get structures like the one in Figure 4.3.

**NP**

**_——**

**D**

**N!**

Adj

**N!**

**a**

**N**

|

Figure 4.3.

Recursion on the N!

constituent allows NPs to have multiple

the

big

black

dog

```prolog
adjectives.
```

<!-- page 102 -->
Exercise 4.3.2.1

Revise your parser to allow multiple adjectives and parse the big black noisy dog. It should

still parse the gray cat and all the other examples from before, but now it should give

structures that include N!.

4.3.3 Adjective Phrases

An adjective is not always a single word—sometimes it is a phrase, such as very big. The N! rule introduces adjective phrases, not just adjectives:

the very big dog

the very big, surprisingly fat dog

the very big, slightly underfed, annoyingly messy dog So we need to change the first N! rule to

N!

-»

AdjP N!

and define adjective phrase (AdjP) as:

AdjP

-—>

(Degree) Adj

where Degree —> very, slightly, extremely, etc.

Longer AdjPs come after the noun, not before it, and AdjPs that follow the noun can include prepositional phrases and other complements after the adjective:

a dog [adj similar to the first one |

We will not account for these here.

Exercise 4.3.3.1

Modify your parser to incorporate the rules just introduced, and to parse the examples given

(the very big dog, etc.). It should still parse all the examples from previous exercises, but

now the structures should include AdjP where applicable.

4.3.4 Sentences within NPs

An NP such as the fact that birds fly has an S within it, preceded by the COMPLEMENTIZER that. So we need to modify the NP rule again, and also define a new constituent S! (more commonly called S$, pronounced “S-bar”):

.

.

**NP -> DN! (PP)(S')**

**S' + Comp S**

Comp -— _ that

<!-- page 103 -->
We also need to add the familiar rules: S —+ NP VP VP — V/(NP)

**This will account for structures such as those in Figure 4.4.**

**S**

**NP**

**vP**

**D**

Nn! s!

**V**

**NP**

**~~**

**N**

**Comp**

**NP**

VP.

Pronoun Ly

| D |

Vv ee Ts

| | the fact that

1) birds

fly

surprised

**him**

(a) S

**NP**

**VP**

Pronoun Vv NP

**D**

**N}**

**PP**

Ss!

**NP _ Poss**

**N**

**P**

**NP**

**Comp**

RY

**Name**

**D**

**N!**

**NP**

**VP**

**N**

**D**

**N!**

**V**

**N**

nobody believed John *s statement at

the

meeting

that

4)

birds

fly

(b)

<!-- page 104 -->
Figure 4.4 Sentences that contain complex noun phrases.

Chap. 4

Exercise 4.3.4.1 Modify your parser to parse the sentences:

The fact that birds fly surprised him. The students challenged the quite unexpected statement at the conference that birds fly, Why do you get two parses for the second sentence? Is it genuinely ambiguous or is the grammar overgenerating?

**4.4 THE VERB PHRASE**

4.4.1 Verbs and Their Complements Verbs take many kinds of complements after them. For example: Verb Type of complement(s) Example slept None John slept. chased NP The dog chased the cat. gave NP+NP John gave us the information. gave NP+[ppto... ] John gave the information to

```prolog
us.
```

said §S! John said (that) birds fly. seemed AdjP John seemed very old. wanted to VP John wanted to leave. In Chapter 3 we looked briefly at the problem of SUBCATEGORIZATION, i.e., ensuring that a verb is not used with the wrong kind of complement. For now, we will ignore subcategorization and simply assume that the input to the parser is grammatical. To a first approximation, then, we need at least the following rules for VP:

VP

-—> V(NP) (PP) (NP) (PP) (S') VP — VAdjP VP

-—+> VtoVP and we need to introduce a null complementizer:

**Comp > @G**

This accounts for the structures in Figure 4.5, among others. But the first VP rule is far from satisfying, and we will return to subcategorization in Chapter 5. Exercise 4.4.1.1 Based on the PS rules introduced on this section, draw tree diagrams for the following sentences:

<!-- page 105 -->
Birds flew into the garden. Max announced at the meeting that the birds looked silly, The birds wanted to leave. NP

**VP**

| aN

**Name**

Vv

**PP**

**a**

**P**

**NP**

**AN**

**D**

**N!**

|

**N**

**Max**

spoke

at

the

meeting s

(a)

**ao**

**NP**

**VP**

**[|**

Name Vv

**NP**

**NP**

**ON**

Pronoun

**D**

N!

|

**N**

| Max gave

us

the

information s

(b)

**a**

**NP**

**VP**

**ee**

Name Vv

**NP**

**PP**

**ON**

**oN**

**D**

**N}**

**P**

**NP**

|

|

**N**

Pronoun

| Max gave the

information

to

everyone

<!-- page 106 -->
(c) Figure 4.5 Verbs with various kinds of complements. (Continues on page 92.) S

**ae**

NP VP ee Name Vv PP

NP JN en P NP D

**N!**

s! |

**SN**

Pronoun

AdjP

N!

Comp

Ss

|

|

**ON**

Adj

**N**

NP

VP

**YN**

|

**D**

N}

Vv

|

**N**

| Max revealed to everyone the

amazing

fact

that

4)

birds

fly

(d)

S oN

NP ‘VP aN

Name Vv

si

**ae**

Comp

‘

Ss

**oN**

NP

VP

**SN**

|

**D**

N}

**V**

|

**N**

| Max said g

i)

birds

fly

(e)

<!-- page 107 -->
Figure 4.5 cont. (Continues on page 93.)

s

**a**

NP

VP

|

**i**

Name

Vv

AdjP

**TaN**

Degree

Adj

Max

looked

very

silly

(f)

Figure 4.5

```prolog
cont.
```

Exercise 4.4.1.2

Extend your parser to parse the sentences in Figure 4.5 and the sentences in the previous

exercise. You need not include all expansions of the VP rule, as long as you include enough

to parse the sentences here, and you are prepared to add more as needed later on.

4.4.2 Particles

**A PARTICLE is a preposition without an object. Particles occur only with specific verbs**

which require them, such as look up or throw out. The same verbs also occur without the particles, with somewhat different meanings.

**When present, the particle occurs in either of two positions, as shown in Figure 4.6**

on page 94. Note that Joe looked up the tower is ambiguous (he either looked up the tower in a book, or looked upward along the tower), and that this ambiguity is structural; Figure 4.7 on pages 94 and 95 shows the two structures.

Exercise 4.4.2.1

Extend your parser to handle particles and to parse the sentences in Figures 4.6 and 4.7,

giving both structures for Joe looked up the tower. You need not provide for all the com-

binations of particles with other parts of the VP; just add enough VP rules to parse the

sentences needed for this exercise.

**4.4.3 The Copula**

The COPULA, or verb of being (is, are, etc.), takes an NP or AdjP as complement, as shown in Figure 4.8 on page 95.

Note (added 2008): In Fig. 4.8 we treat Copula as a separate syntactic category. There is a good case for treating the copula as a V with a particular subcategorization.

Exercise 4.4.3.1

<!-- page 108 -->
Extend your parser to parse the sentences in Figure 4.8.

**VP**

|

**ee ie**

Name

**V**

**NP**

Particle

**oN**

**D**

**N}**

Joe

threw

the

**ay**

out s

(a) a

**|**

**VP**

**Le**

Name Vv Particle

**NP**

**“oN**

**D**

**N!**

|

**N**

Joe threw out

**the. - Figure 4.6**

The particle occurs either after

(b)

the verb, or after the object. S ae

**|**

**VP**

**ee**

Name Vv Particle

**NP**

**“oN**

**D**

**N!**

| Joe looked

up

the

tower

(in the guidebook)

(a)

ary preposition or a particle.

<!-- page 109 -->
(Continues on Figure 4.7 Up can be either an ordin page 95.) NP

VP

Name

**V**

**PP**

**P**

**NP**

**D**

N!

**N**

Joe

looked

up

the

tower

(as he stood beneath it)

(b)

Figure 4.7 cont.

S

**NP**

VP

**D**

**N!**

Copula

AdjP

**N**

Degree

Adj

the

cat

is

very

fat

(a)

S

**NP**

VP

**D**

N!}

Copula

**NP**

**N**

**D**

N!}

AdjP

N!}

Adj

**N**

the

cat

is

**my**

favorite

pet

(b)

<!-- page 110 -->
Figure 4.8 The copula takes an NP or AdjP as complement.

**English Phrase Structure — Chap. 4**

**4.5 OTHER STRUCTURES**

**4.5.1 Conjunctions**

**Most occurrences of coordinatin g conjunctions such as and and or seem to be governed**

**by a rule**

**X + XConjx**

**where X is any kind of constituent whatever. That is, any two constituents of the same**

**kind can be joined by a conjunction to make a larger constituent. Figure 4.9 shows some**

**examples.**

**The rule X + X Conj X cannot be expressed directly in DCG notation; instead it**

**must be replaced by a set of rules**

**NP -> NP Conj NP**

**AdjP_**

-—»

**AdjP Conj AdjP**

**NP**

**NP**

**Conj**

**NP**

Name

Name

Fido

and

Felix

(a)

:

V

V

Conj

**v**

hates

and

detests

(b)

**AdjP**

**AdjP**

**Conj**

**AdjP**

Degree

Adj

Degree

Adj

very

hot

and

quite

dry

(c)

Figure 4.9 Conjunctions such as and take two constituents of the same kind and make

them into a larger constituent.

