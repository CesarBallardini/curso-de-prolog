# Chapter8

<!-- page 247 -->
**Further Topics in Semantics**

**8.1 BEYOND MODEL THEORY**

There is much more to natural-language understanding than just translating English into logical formulas. Unfortunately, the area beyond simple model theory is a realm of fundamental mysteries and unsolved problems. Here computational linguistics becomes inseparably bound up with knowledge representation and the general question of how people think.

This chapter will briefly sketch three major topics that lie in this realm: language translation, word-sense disambiguation, and understanding of events. Coverage will be far from complete; parts of this chapter will have the atmosphere of a whirlwind tour. I shall refrain from going deeply into knowledge representation, since doing so would require another book at least as long as the present one.

**2 LANGUAGE TRANSLATION**

**8.2.1 Background**

<!-- page 248 -->
Attempts at computer translation of human languages are as old as computers themselves (Buchmann 1987). Practical techniques were foreseen by Trojanskij in 1933, and a wordby-word French-to-Spanish translation program was implemented by Booth and Ritchens in 1948. By 1955 “machine translation” (MT) was an up-and-coming technology heavi] supported by the U.S. Government. In 1966, however, a National Academy of Sciences committee declared MT to be impractical and most support for research was withdraw

The committee’s mistake was to expect instant results. In the 1950s and 1960s, many mathematical and clerical activities—banking, engineering calculations, and th like—had been computerized almost overnight. The committee failed to realize that MT was not simply a matter of applying computers to a mechanical procedure already we understood. Nobody really knows how human translators do their work; they certainly don’t just look up words in a dictionary and write down the equivalents in another language, which is what some of the earliest MT programs tried to do.

There has been a resurgence in MT since 1980, spurred by cheap computer power and advances in computational linguistics. One of the most successful projects is TAUM-. METEO, which translates Canadian weather reports from English into French (Thouin. 1982). 8.2.2 A Simple Technique The essential steps in language translation are ANALYSIS of the input, TRANSFER (restructuring), and GENERATION of the output. Since the earliest days of MT, there have been two rival approaches: to map one language onto another directly, or to translate the input into an INTERLINGUA (intermediate language) which can then be translated into the output language.

In what follows we will develop a translator that uses logical formulas as an interlingua. We will take advantage of the fact that semantic analyzers written in Prolog can be made REVERSIBLE, i.e., the same program can not only translate English into formulas, but also translate formulas back into English (or whatever language the parser handles). Then, to translate a sentence, one simply analyzes it in one language and re-generates it in the other.

For example, the semantic analyzer from Section 7.3.4, reproduced in Figure 8.1, is reversible:

**?- s (What, [every,**

dog, barked] ti). What = all (X,dog(X) , barked

(xX) )

?- s(all(X,dog(X),barked(X)),What, {]). What = [every,dog, barked] So in order to translate languages, all we have to do is build the semantic structure using a grammar for one language, and then turn the semantics back into a sentence using a grammar for the other language. What could be simpler? Exercise 8.2.2.1

Get the program in Figure 8.1 working (again) and verify that it is reversible. Use it to

translate

all (X,dog(X),all(¥,cat(¥),saw(X,Y)))

<!-- page 249 -->
into an English sentence. Sec. 8.2

Language Translation

235 2 % Semantics of sentences with quantifiers on NPs. s(Sem) --> np((X*Sco)*Sem), vp(X*Sco).

np(Sem) --> d((X*Res)*Sem), n(X*Res).

vp(Sem) --> v(Sem). vp(X* Pred) --> v(Y°X*Sco), np( (Y*Sco) *Pred).

**d((X*Res)**

*(X*Sco) *all(X,Res,Sco))

--> [every]. d((X*Res)

*(X*Sco) “some(X,Res,Sco)) --> [a]; [some].

n(X*dog(X)) --> [dog]. n(X*cat(X)) --> [cat].

v (X*meowed (X) )

--> [meowed]. v(Y°X*chased(X,Y)) --> [chased]. v(Y*X*saw(X,Y))

--> [saw].

Figure 8.1

Reversible semantic analyzer.

Exercise 8.2.2.2

(for discussion)

Under what conditions does a Prolog program fail to be reversible? That is, how can you

recognize a non-reversible program? Discuss.

**8.2.3 Some Latin Grammar**

In what follows we will turn the semantic analyzer into an English-to-Latin translation program.’ (We choose Latin rather than French, Spanish, or German because Latin grammar is quite a bit different from English, so that translating word by word is impossible.) To begin with, we need a DCG parser for Latin, shown in Figure 8.2. So that this can be merged with an English parser without conflict, all the node labels have been prefixed with x, so that instead of

s,

np, vp, we call the Latin nodes xs, xnp, xvp, and so on.

Table 8.1 shows some English sentences with their Latin equivalents. Looking both at the grammar and at the table, note that:

e Latin word order is different from English: the verb comes at the end of the

sentence, and one kind of determiner (here called xd2) follows rather than precedes

its noun.

e Case is marked on all nouns; ‘cat’ is felis in subject position but felem in object

position (and likewise ‘dog’ is canis or canem respectively).

e Determiners agree with nouns in case (omnis felis versus omnem felem).

<!-- page 250 -->
'T am indebted to R. A. O’Keefe for suggesting an exercise of this type; he is absolved of all responsibility for what is actually presented here.

Chap.

XS --> xnp(_,nom), xvp.

XVpP --> XV. Xvp --> xnp(_,acc), xv.

xnp (Gender,Case) --> xd(Gender,Case), xn(Gender,Case). xnp (Gender,Case) --> xn(Gender,Case), xd2 (Gender,Case).

xd(_,_)

--> []. xd(_,nom) --> [omnis]. xd(_,acc) --> [omnem].

xd2(masc,nom) --> [quidam]. xd2(masc,acc) --> [quendam]

. xd2(fem,nom)

--> [quaedam]. xd2 (fem,acc)

--> [quandam].

xn(masc,nom)

--> [canis]. xn(masc,acc)

--> [canem]. xn (fem,nom)

--> [felis]. xn(fem,acc)

--> [felem].

xv --> [ululavit]; [vidit]; fagitavit].

Figure 8.2 A parser for a few Latin sentences.

TABLE 8.1 SOME LATIN SENTENCES AND THEIR ENGLISH

EQUIVALENTS.

Felis ululavit.

A cat meowed. (= Some cat meowed.)

Felis quaedam ululavit.

A cat meowed. (= Some cat meowed.)

Omnis felis ululavit.

Every cat meowed.

Canis felem agitavit.

A dog chased a cat.

Canis quidam felem agitavit.

A dog chased a cat.

Canis quidam felem quandam agitavit.

A dog chased a cat.

Felis canem vidit.

A cat saw a dog.

Felis quaedam canem vidit.

A cat saw a dog.

Felis quaedam canem quendam vidit.

A cat saw a dog.

Omnis felis canem quendam agitavit.

Every cat chased some dog.

Omnis canis omnem felem agitavit.

Every dog chased every cat.

e Latin has arbitrary gender: felis ‘cat’ is normally feminine (unless you’re specifi-

cally talking about a male cat) and canis ‘dog’ is normally masculine.

e Some determiners are marked for gender as well as case: we get felis quaedam

(feminine) but canis quidam (masculine).

<!-- page 251 -->
e There is a null determiner, and it means ‘some’. Sec. 8.2

Language Translation

237 Purists will note that many details of Latin grammar are being glossed over; the word order is actually variable, the null determiner can also mean ‘the’, and there are several more ways of saying ‘some’. But we have enough Latin grammar here to make a start. Exercise 8.2.3.1

Get this parser working and verify that it parses all the Latin sentences in Table 8.1. Exercise 8.2.3.2

By hand, translate into English:

Felis canem agitavit.

Felis omnem canem vidit.

Canis quidam ululavit.

**8.2.4 A Working Translator**

Figure 8.3 shows the Latin parser with arguments added to make it build semantic representations just like those used by the English parser. This parser is reversible, like the English one:

?- xs(Sem, [felis,ululavit],[]). Sem = some (X,cat (X) ,meowed(X)

)

**?- xs (some**

(X, cat (X) ,meowed (xX) »What,[]). What = [felis,ululavit] There is some nondeterminism, because the Latin parser has two ways to say ‘some’ (the appropriate form of quidam or the null determiner); similarly, there is nondeterminism on the English side because some and a are treated as equivalent.

To translate a sentence, all we need to do is run it through one parser forward and then the other parser backward:

english_latin(E,L) :- s(Sem,E,[]) , xs(Sem,L,[]).

For example:

?- english_latin([a,cat,meowed] , What) . What = [felis,ululavit]

Exercise 8.2.4.1

Get the translation program working and use it to translate the sentences in Table 8.1.

Exercise 8.2.4.2

Will english_latin/2 also translate Latin into English? If so, is it more efficient in

<!-- page 252 -->
one direction than in the other? Explain.

s(Sem) --> xnp(_,nom, (X*Sco)*Sem), xvp(X*Sco)

.

xvp (Sem) --> xv(Sem). xvp(X*Pred) --> xnp(_,acc, (Y*Sco)*Pred), xv(Y°X*Sco).

xnp (Gender,Case,Sem) --> xd (Gender,

Case, (X*Res)*Sem), xn(Gender,Case,X*Res)

. xnp (Gender,Case,Sem) --> xn (Gender, Case, X”*Res) ,xd2 (Gender, Case, (X°Res) *“Sem).

xd(_,_, (X*Res) *(X*Sco) *some(X,Res,Sco))

--> []. xd(_,nom, (X*Res) *(X*Sco) *all(X,Res,Sco)) --> [omnis]. xd(_,acc, (X*Res) *(X*Sco)*all(X,Res,Sco)) --> [omnem].

xd2 (masc,nom, (X*Res) *(X*Sco) “some (X,Res,Sco)) --> [quidam] . xd2 (masc,acc, (X*Res) *(X*Sco) *some(X,Res,Sco)) --> [quendam]. xd2(fem,nom, (X*Res) *(X*Sco) *some(X,Res,Sco))

--> [quaedam]. xd2(fem,acc, (X*Res) *(X*Sco) *some(X,Res, Sco) )

--> [quandam] .

masc,nom,X*dog(X))

--> [canis].

masc,acc,X*dog(X))

--> [canem]. n (

( n (

( n(fem,nom, X*cat (X

)

)

--> [felis]. n(fem,acc,X*cat

(X)

--> [felem].

(

xX

)

xv (X*meowed (X) )

--> [ululavit]. xv (Y*X*chased(X,Y)) --> [agitavit]. v(Y¥*X*saw(X,Y))

--> [vidit].

Figure 8.3 Reversible semantic analyzer for Latin.

Exercise 8.2.4.3 (small project)

Implement your own translation program that will translate a comparable set of sentences

from English into some other language.

**8.2.5 Why Translation Is Hard**

Translation by reversible unification-based grammar is an up-and-coming technology. The general idea is to analyze a sentence into a feature structure (which can be more than just a semantic representation), manipulate the feature structure as appropriate to suit the target language, and then use it to generate a sentence. Estival (1990a,b) reports some research in this area. Of course many older techniques are also still being pursued.

But there is much more to translation that just the mapping of one grammar onto another. There are several main challenges:

e Words do not have exact equivalents in different languages. The common Spanish

<!-- page 253 -->
word simpdtico ‘friendly, easy to get along with’ has no exact English translation; Sec. 8.3

Word-Sense Disambiguation

239

it takes a while even to explain the concept in English. Many English words such

as picturesque lack equivalents in other languages.

e Even ina

single language, the same word means different things in different contexts.

This is the problem of worp SENSE DISAMBIGUATION; more about it in the next

```prolog
section.
```

e Different languages require different amounts of information to be expressed. In

Spanish, /legé means either ‘he arrived’ or ‘she arrived’, but in order to translate it

into English, you have to choose he or she on the basis of context and background

knowledge. Again, French, Spanish, and German distinguish ‘familiar’ and ‘polite’

forms of the word you; English has only one form. Japanese has ‘polite’ markers

**for nouns as well (which bad translations sometimes render as ‘honorable’). A**

translator translating from English into one of these languages must guess where

the ‘polite’ forms should go, based on background knowledge and knowledge of

the culture. This seems to paint a very gloomy picture of the prospects of MT. But in fact there are situations in which MT works well. For example, MT is quite practical if the languages are closely related (such as Norwegian and Swedish), so that substantial differences of culture or world-view are rare. MT also works well if the subject matter is restricted (e.g., Canadian weather reports, or certain kinds of business documents).

**Finally, MT works well if imperfect translations are tolerable. Computers don’t**

produce good translations, but they can grind out rough translations cheaply and quickly. These can be polished by a human translator, or used in their rough form by someone who needs only the gist of the text, not all the details. Exercise 8.2.5.1

Using a foreign language familiar to you, give an example of:

e a word that has no exact equivalent in English;

a simple instance in which the foreign language and English convey different amounts

of information while saying essentially the same thing (like Spanish llegé versus

English he arrived).

**3 WORD-SENSE DISAMBIGUATION**

<!-- page 254 -->
8.3.1 The Problem So far we have blithely assumed that each word has exactly one meaning. This assumption holds only in the simplest database-querying applications. In the English vocabulary as a whole, ambiguity runs rampant. The Concise Oxford Dictionary lists 54 senses of run, 38 senses of go, and even three senses of the seemingly unambiguous word bachelor. Ambiguities are of three main types: e Homonymy, in which two senses have no relationship that an ordinary speaker can recognize, so that they are in effect two words that sound alike. Example: the bark of a tree versus the bark of a dog. e POLYSEMY, in which the senses of a word are distinct but connected in the speaker’s mind, often by metaphor. There is great variation as to what relationships a par ticular speaker will recognize. Example: the kernel of a nut versus the kernel of an operating system. e ARGUMENT AMBIGUITY or THETA-ROLE AMBIGUITY, in which two senses denote’ essentially the same thing, but with a different mapping from syntax to semantic : arguments.

**a**

Example: Mary is cooking (subject = agent) versus The potatoes are cooking (subject = theme).

The amazing thing about ambiguity is that people hardly notice it. Research suggests — that the human mind resolves ambiguities by working on at least three levels:

e CONTEXTS Of SPECIALIZED VOCABULARIES. Many word senses belong to specific domains of discourse. For example, bark means one thing when you're talking about dogs and another when you’re talking about trees. e SELECTIONAL RESTRICTIONS, i.e., restrictions on the semantic arguments of a word. For example, arrest has different meanings depending on whether its object is a person or a physical change (arrest the burglar vs. arrest the decay). Selectional restrictions are particularly helpful with argument ambiguities, where context is little help. e INFERENCE FROM REAL-WORLD KNOWLEDGE. For example, Hirst (1987:80) points out that in order to disambiguate head in the sentence

Nadia swung the hammer at the nail and the head flew off we have to think about how hammers work, because not only does the hammer have a head, but so do the nail and Nadia.

The problem, of course, is that it’s hard to draw a line between selectional restrictions and real-world knowledge; further, there’s no limit to the amount of real-world knowledge or inference that may be required. Imagine, for instance, a detective novel that begins with the words The house blew it, found on a piece of paper at the scene of the crime, and in which the whole story is devoted to figuring out what those words mean (Weizenbaum 1976:187).

**8.3.2 Disambiguation by Activating Contexts**

<!-- page 255 -->
In this section we can do no more than sketch one approach to disambiguation—an approach that is admittedly inadequate, but suffices to give you a taste of the problem. Consider the sentences:

Sec. 8.3

Word-Sense Disambiguation

241

There are pigs in the pen.

**(pen = enclosure)**

There is ink in the pen.

**(pen = writing instrument)**

**The two senses of pen are distinguished by the prior context: pigs, which calls up the**

**context of farming, or ink, which calls up the context of writing. That is, pigs and ink**

**serve as CUES for the appropriate contexts. From the sentences**

**The pen is full of pigs.**

**The pen is full of ink.**

**we see that the cues need not precede the ambiguous words. These facts suggest a**

disambiguation algorithm:

**e Keep a list of CONTEXTS (specialized vocabularies) that are in use.**

**e Scan the sentence for words that serve as cues, and activate the appropriate context**

for each.

**e Then scan the sentence again, replacing each ambiguous word by a representation**

**of its meaning in the currently active context(s).**

**For simplicity, we’ll completely ignore parsing and semantic analysis; we'll view the**

sentence as a simple string of words. N: aturally, a more satisfactory disambiguator would take morphology, syntax, and semantics into account.

**First we need a table of cues, and also a table of ambiguous words indicating what**

**they mean in each context:**

% cue (?Word, ?Context) %

Word is a cue for Context

cue(farmer,

farm). cue (pigs,

farm). cue (ink,

writing). cue(airport,

aircraft).

( cue (carpenter, woodworking)

.

% mic (?Word, ?Meaning, ?Context) % Word has specified Meaning in Context

mic(pen,

pen_for_animals,

farm). mic(pen,

writing_pen,

writing). mic(plane,

plane_tool,

woodworking) . mic (plane,

airplane,

aircraft). mic(terminal, airport_terminal,

aircraft).

<!-- page 256 -->
( mic(terminal, computer_terminal, computer).

Further Topics in Semantics

**Chap.**

**g**

Here mic stands for meaning in context. The “meanings” such as pen_for_animals are merely symbols that stand for the various senses of a word.

Next we need a procedure to go through the sentence and activate all the context for which there are cues:

collect_cues (+Words,+Contexts,-NewContexts) de de de

scans Words looking for cues, and adding appropriate

contexts to Contexts giving NewContexts.

collect_cues([],Contexts,Contexts).

collect_cues([W|Words],Contexts,NewContexts) :-

cue (W,C),

\+ member (C,Contexts),

i 4

**collect_cues**

(Words, [C|Contexts] ,NewContexts) .

collect_cues([_|Words],Contexts,NewContexts) :-

**collect_cues**

(Words, Contexts,NewContexts).

The first clause is for the end of the list; the second is for activating a new context; and the third clause deals with words that are not cues, and cues for contexts already active. Here’s an example of what it does:

?- collect_cues([the,carpenter,put,the,pigs,in,the,pen],[],What). What = [woodworking,

farm]

Here the initial argument [] is a list of contexts already active, if any; it allows contexts to be carried along from sentence to sentence.

Once collect_cues has done its work, the next step is to go through the sentence again, disambiguating each ambiguous word by looking up its meaning in the active context or contexts:?

**% disambiguate_words**

(+Words, -DWords, +Contexts) %

goes through Words using Contexts to disambiguate them.

disambiguate_words([],[],_).

**disambiguate_words**

```prolog
([W|Words], [D|DWords],Contexts) :-
```

mic(W,D,C),

® W is ambiguous and means D in context C

member (C,Contexts),

**disambiguate_words**

(Words, DWords, Contexts) .

disambiguate_words([W|Words], [W|DWords],Contexts) :-

<!-- page 257 -->
?Recall that member is not built in, but is defined in Appendix A. Sec. 8.3

Word-Sense Disambiguation

243

\+ mic(W,_,_),

% W is not listed as ambiguous

disambiguate_words (Words, DWords ,Contexts). Here again we have three clauses: one for the end of the list, one for an ambiguous word that can be disambiguated in an active context, and one for words that are not ambiguous. The main procedure, then, looks like this,

disambiguate (Words, DWords ,Contexts) :-

collect_cues (Words, [] ,Contexts),

disambiguate_words (Words, DWords ,Contexts).

**and an example of a query is:**

?- disambiguate ( [there, are,pigs,in,the,pen] , DWords ,Contexts) . DWords = [there,are,pigs,in, the,pen_for_animals] Contexts = [farm]

Exercise 8.3.2.1

Get the disambiguation program working and use it to disambiguate the following sentences:

There are pigs in the pen.

There is ink in the pen.

The pen is full of pigs.

The pen is full of ink.

The carpenter built a pen for the pigs.

The carpenter used a plane.

The plane is at the airport.

The carpenter found a pig at the airport.

In which sentences does more than one context get activated?

Exercise 8.3.2.2

**What does the program in this section do with each of the following sentences? Why?**

The carpenter found a plane at the airport.

The plane is at the terminal.

Exercise 8.3.2.3

Extend the disambiguation program to disambiguate star in the following sentences:

The astronomer photographed the star.

The film publicist photographed the star.

<!-- page 258 -->
The star of the show was a previously unheard-of actress.

What does this program do with The astronomer married the star and with The astronomer

made a film about the star? Are these sentences unambiguous to human listeners?

**8.3.3 Finding the Best Compromise**

The algorithm developed so far assumes that cues are sharply distinct from the words: that need to be disambiguated. But this distinction does not hold up, because ambiguous words can serve as cues for each other. Consider the sentence:

The plane is at the terminal.

Without further context, most people interpret this as “The airplane is at the airport terminal’ even though plane and terminal are both ambiguous.

The reason that particular interpretation is preferred is that it activates only one specialized context, not two. Consider the possibilities:

Interpretation

Context list

‘The aircraft is at the airport terminal’

[aircraft]

‘The aircraft is at the computer terminal’

[aircraft, computers

]

‘The woodworking tool is at the airport terminal’

[woodworking, aircraft]

‘The woodworking tool is at the computer terminal’ [woodworking, computers]

Generally, the reading with the fewest active contexts is preferred.

Looking at disambiguation this way, a cue is a word that activates one context; an ambiguous word is a word that activates any of several contexts depending on which sense is chosen. This suggests a different disambiguation algorithm:

e Find all possible ways of disambiguating the sentence, activating the appropriate

contexts with each one.

e Choose the reading that has the fewest contexts active.

Finding one way of disambiguating the sentence is easy. First we list all the cues and ambiguous words in a single “meaning-in-context” (mic) table:

%

WORD

MEANING

CONTEXT mic(farmer,

farmer,

farm). mic(pigs,

pigs,

farm). mic(ink,

ink,

writing). mic(airport,

airport,

aircraft). mic(carpenter, carpenter,

woodworking)

. mic(pen,

pen_for_animals,

farm). mic(pen,

writing_pen,

writing).

( mic(plane,

plane_tool,

<!-- page 259 -->
woodworking) . Sec. 8.3

Word-Sense Disambiguation

245

mic(plane,

airplane,

aircraft). mic(terminal,

airport_terminal,

aircraft). mic(terminal,

computer_terminal, computer). The ambiguous words have multiple entries here; the cues have only one entry each.

Then we work through the sentence, and upon encountering a word that is in the mic table, choose a sense for it and add the appropriate context to the context list if it is not already there. Here’s the procedure that does all this: % disi (Words, DWwords, Contexts, NewContexts)

oe ®

Find 1 disambiguated reading of Words, placing it in DWords,

adding newly activated contexts to Contexts giving NewContexts. disl([],[],Contexts, Contexts) .

% end of list disi([W|Words], [D|DWords] , Contexts, NewContexts) i mic(W,D,C), member (C,Contexts) ,

6 W means D in a context already active dis1 (Words, DWords,Contexts,NewContexts) . disl([W|Words], [D| DWords] , Contexts, NewContexts) i mic(W,D,C), \+ member (C,Contexts),

```prolog
% W means D by activating a new context
```

disi (Words, DWords, [C|Contexts],NewContexts) . disi([WlWords], [W|DWords] ,Contexts,NewContexts) - \+ mic(W,_,_),

```prolog
%® Wis not ambiguous
```

disl (Words, DWords, Contexts,NewContexts) . Now the challenge is to compare ail the potential disambiguations and select the one with the fewest contexts active. Here we take advantage of a very high-level feature of Prolog, the built-in predicate setof.

<!-- page 260 -->
Recall that setof finds all the solutions to a query and places them in a list in alphabetical order. Thus if Kermit and Gonzo are animals, setof works like this: ?- setof(X,animal(X),L). L = [gonzo,kermit] To be precise, ?- setof(X,Goal, List) makes a sorted list of instantiations of x corresponding to solutions to Goal. Here x need not be a variable; it can be a structure that has one or more variables in common with Goal. For example: 2- setof(f£(X),animal(X),L). L = [£(gonzo),£(kermit) ] Further, the “alphabetical” order of the solutions is more than just alphabetical; it includes the ability to compare numbers and other types of terms. When structures have the same functor, they are “alphabetized” by arguments, first argument first, so that for example £(9,z) comes out before £(10,a) 3

**To get setof to put the disambiguations with the fewest contexts at the beginning**

**of the list, we will represent each disambiguation as a structure of the form**

reading(1, [there,are,pigs,in, the,pen_for_animals], [farm])

**where the first argument is the number of contexts. The whole main procedure of the**

program, then, is:

disambiguate (Words,Readings) :-

setof (reading (N, Contexts, DWords) ,

(dis1 (Words, DWords, [],Contexts), length(Contexts,N)),

Readings).

**Note that the middle argument of setof isa compound goal. The output of disambigu-**

**ate/2 looks like this:**

?- disambiguate ([the,plane,is,at,the,terminal],What) . What = {reading reading

, (aircraft , woodworking], [the,plane_tool,is,at,the, airport_terminal

, (aircraft], [the,airplane,is,at,the, airport_terminal]),

(1

(2 reading (2, [computer,aircraft], [the,airplane,is,at,the,computer_terminal]), reading (2

, (computer, woodworking], [the,plane_tool,is,at, the, computer_terminal

Exercise 8.3.3.1

Get this disambiguation program working and use it to disambiguate all the sentences in

Exercise 8.3.2.1, as well as The plane is at the terminal.

Exercise 8.3.3.2

What does this program do with The carpenter found a plane at the airport?

Exercise 8.3.3.3

Extend this disambiguation program to handle star in:

The astronomer photographed the star.

The film publicist photographed the star.

What does the program do with The astronomer made a film about the star? Is this a

reasonable thing to do? Explain.

<!-- page 261 -->
3The way in which setof compares terms is not standardized, and some Prologs may behave differently than described here. 8.3.4 Spreading Activation

Our programs so far make an unjustified assumption about contexts. They assume that the vocabulary is divided up into a set of discrete sub-vocabularies which we have labeled farm, aircraft and the like. This assumption does not stand up under examination. Why is farm a context while pig is not? Why does pig activate the context farm and not animal? It turns out that there is no good reason to divide words up into the particular contexts that we did, except that it happened to work well with our example sentences.

Instead, we need to look at relationships between the concepts that words stand for. Figure 8.4 shows a number of concepts arranged in a SEMANTIC NET. The net shows several relationships, of which ‘is a’ is the most important: a farmer is a person, a pig is a domesticated animal, and so on. Other important relations are contains and uses.

ANIMATE

PHYSICAL

~ BEING

OBJECT

is

is

is

is

ANIMAL

PEN

]

PERSON

**MAL**

(FORANIMALS)

[">

is

.

**omen**

VEHICLE

is

A

DOMESTICATED

TOOL

uses

ANIMAL

A

FARMER

.

s

1s

.

is

TAY

PIG

AIRPLANE

CARPENTER

aes

> WOODWORKING

TOOL

r

Uses

1s

'

AIRPORT

TERMINAL

PLANE

(TOOL)

Figure 8.4 A semantic network.

Every meaning of every word is a node in the net. The “context” for a meaning consists of the other nodes that are near it. The reason pig and jarmer seem to belong to the same context is that they are connected by a short path through the net. Neither of them is connected very closely to airplane, which is why airplane does not seem to belong to the same context.

<!-- page 262 -->
Semantic networks were introduced by Quillian (1967) for the purpose of disambiguating words. The key idea is that to activate a context, one activates not only the

Further Topics in Semantics

Chap. 8 particular word sense involved, but also the other senses that are close to it in the network. That is, activation sPREADS from one node to another. The most likely reading of an ambiguous sentence is the one that activates the smallest portion of the network — (thereby sticking to a relatively well-defined context).

To keep from activating the entire network at once, there have to be limits on how activation spreads: typically it can only spread along the arrows (so that pig activates animal but not vice versa) and/or can only spread a limited number of steps.

Semantic nets with spreading activation are not a complete solution to the disambiguation problem, but they are a good start. Selectional restrictions and real-world. knowledge also have to be taken into account. Still, there is good evidence that semantic nets model a portion of what the brain actually does when processing language, and semantic nets are an ongoing research topic in psycholinguistics as well as computational linguistics.

Exercise 8.3.4.1

Express Figure 8.4 as a set of Prolog clauses such as:

is (carpenter,person) .

uses (carpenter,woodworking_tool).

Exercise 8.3.4.2

Using the results of the previous exercise, define a predicate related/2 which will tell

you whether it is possible to get from one sense to another by following the arrows in

the network. For example, “?- related(pig,animal).’ should succeed but ‘?-

related(plane, carpenter) .’ should fail.

Exercise 8.3.4.3

Using the results of the previous two exercises, define near/2 which is like related/2

except that the two senses have to be no more than two nodes apart (that is, have no more than

one other node between them). For example, “?- near (carpenter, physical_ob-

ject) .’” should fail.

,

Exercise 8.3.4.4 (small project)

Implement a disambiguation program comparable to the one in the previous section, but

using spreading activation through a semantic net.

**8.4 UNDERSTANDING EVENTS**

8.4.1 Event Semantics

Consider the two sentences:

Mary believes Brutus stabbed Caesar.

<!-- page 263 -->
Mary saw Brutus stab Caesar. The first of these goes into logic straightforwardly as:

believes (mary, stabbed (brutus, caesar) )

That is, Mary believes the PROPOSITION that Brutus stabbed Caesar. So far, so good.

**Now try the second sentence. It’s tempting to translate it as**

saw (mary, stabbed (brutus, caesar) )

but, as Terence Parsons has pointed out, problems immediately arise.* Consider the context:

Mary saw Brutus stab Caesar,

but she didn’t know that the first man was Brutus,

nor that the second man was Caesar,

nor that he was stabbing him.

Clearly, Mary did not see the proposition or fact that Brutus stabbed Caesar. She saw an event, and we know (though she didn’t) that the event was a stabbing and the protagonists were Brutus and Caesar.

Events are a lot like discourse referents; we can represent them with EVENT MARK- ERS analogous to discourse markers. Then Brutus stabbed Caesar goes into Prolog as a set of facts rather than a single fact:

ae stab(e(34)). agent (e(34),brutus). theme (e(34),caesar).

ae

oe

Event e(34) is a stabbing

Brutus did it

Caesar was the victim

If we get more information, we can represent it as additional facts:

place(e(34),forum). instrument (e(34),knife).

And if Mary saw the event, we can record that fact too:

oe see(e(35)). experiencer(e(35),mary). theme (e(35),e(34)).

oe

ae

Event e(35) is an act of seeing

Mary experienced it

What she.saw was event e(34)

and so on. This is essentially the theory of Parsons (1990) implemented in Prolog.

The relations agent, theme, etc. are called THEMATIC RELATIONS Of THETA ROLES and go back originally to the work of Gruber (1965), Fillmore (1968), and Jackendoff (1972). Many linguists use thematic relations in a haphazard way; Table 8.2 shows the system I prefer, which is approximately that of Parsons. See also Dowty (1989).

<!-- page 264 -->
“This exact argument is taken from a talk given by Parsons in Tiibingen in 1987. See Parsons (1990).

Chap. TABLE 8.2 THEMATIC RELATIONS. AGENT Person or thing that causes or actively permits an event Max kicked Bill. General Motors raised prices.

THEME Person or thing affected or described Present in (almost?) every sentence Max kicked Bill. Felix is a cat. Clouds formed on the horizon.

GOAL Result, intended result, or destination I went to New York. We painted the house red. Max turned into a unicorn.

SOURCE Point of origin; opposite of goal. I came from New Haven. It changed from red to green.

BENEFACTIVE Person for whose benefit something is done We gave an award to the leader. They threw him a party.

EXPERIENCER Person who experiences or perceives something We slept. The noise surprised us. We heard it several times.

INSTRUMENT — Means with which something is accomplished T opened it with a crowbar. The wrench got it open. It was only soluble by induction.

**Crucially, each verb can have at most one argument in each theta role. No verb**

**ever has two different agents or themes at once. Other pieces of information such**

**as place, time, and manner can be doubled up, and Parsons calls them MODIFIERS.**

**An example of a sentence with two time modifiers is Call me [ on Tuesday time [ at**

**noon Jrime-**

Exercise 8.4.1.1

Consider the following sentences:

Fido chased Felix from Atlanta to Boston. Felix hated Boston. He went back to Atlanta on a train.

<!-- page 265 -->
(a) Identify all the thematic relations in each sentence.

(b) Encode the three sentences in Prolog in the manner described in this section,

assigning an event marker to each event. (Some fine details, such as the difference between

went and went back, will end up being ignored.)

8.4.2 Time and Tense

Every event occurs at a particular time which may or may not be known. The internal representation of a text should include the same information about time as the text itself. For example:

Fido barked at midnight. Then Felix howled.

bark(e(1)).

```prolog
% £irst event
```

agent (e(1),fido). time(e(1),midnight).

ae

occurred at midnight

oe

second event howl(e(2)). agent (e(2),felix). precedes (e(1),e(2)).

ae

```prolog
e(1) preceded e(2)
```

At midnight tells us when Fido barked (assuming for the moment that midnight picks out a time unambiguously; recall that there are 365 midnights every year). Then tells us that Felix’s howl came after Fido’s bark, and that no significant event intervened.

That’s not all. The verbs are in the past tense, which tells us that both e (1) and e(2) precede the speech act that describes them:

precedes (e(1),speech_act). precedes (e(2),speech_act).

What we have, in general, is a PARTIAL ORDERING of events—we know the relative order of some of them but not necessarily all of them.

**Different kinds of events relate to time in different ways. We have already implic-**

itly distinguished events that occur at specific times from sTATES, such as ‘Gold is an element,’ which we have viewed as timeless. Besides this, some events take (or seem to take) only a moment, while others occupy specific periods of time.

Table 8.3 shows a classification of verbs proposed by Vendler (1957) and subsequently refined by many other semanticists.> It is important to note that most events can be conceived of more than one way, and, in context, verbs are easily converted from one class to another.

Fleck (1988) argues convincingly that time as viewed by human beings is not normally a continuum. Humans prefer to divide a continuous stretch of time into a series of discrete states divided by events. Words like then and next tell us that there

<!-- page 266 -->
See especially Dowty (1979, ch. 2) and Fleck (1988, ch. 7). The felicitous substitution of the term STATE CHANGE for ACHIEVEMENT is due to Fleck.

Further Topics in Semantics

Chap.'8 TABLE 8.3 VENDLER’S FOUR CLASSES OF ENGLISH VERBS. STATE

John knows Latin.

Gold is an element. True timelessly or for a specified period. Not used in present participle (*John is knowing Latin).

ACHIEVEMENT

John found a penny. (STATE CHANGE)

Fido barked (once). Instantaneous; has no duration; cannot be prolonged or interrupted.

ACTIVITY

John sang songs.

Fido barked (continually). Can continue any length of time with no definite endpoint. Present tense usually expressed with —ing (John is singing songs). “When did it start?” and “When did it stop?” are appropriate questions. ACCOMPLISHMENT

John composed a symphony.

Fido hunted down a rabbit. Like an activity ending with a state change. Finishing is not the same thing as stopping. “How long did it take?” is an appropriate question.

**is no other event between the two events being referred to; rather than being timeless,**

states persist until an event changes them. Exercise 8.4.2.1 Reasoning with a partial ordering: Define before/2 such that before (e(1),e(2)) succeeds if e (1) is before

(2) in the partial ordering defined by precedes. Also define after. Can you define simultaneous in terms of precedes? Explain why or why not.

:

Exercise 8.4.2.2 Classify each of the following underlined verbs as denoting a state, an activity, a state change, or an accomplishment:

Fido chased Felix from Atlanta to Boston. They got there at sundown. Fido likes Boston. He met a famous person there.

Exercise 8.4.2.3 Cite evidence that find normally denotes a state change in English. Then give an example in which find is used to denote an activity or an accomplishment.

**8.4.3 Scripts**

**A SCRIPT is a representation of how an event is composed of sub-events. Given an**

<!-- page 267 -->
incomplete description of a birthday party, a shopping trip, or an election, for instance, you can immediately infer many sub-events that may not have been mentioned. If I tell you I got a scarf at Macy’s, you presume that I went there and paid for it.

Research on scripts was pioneered by Roger Schank and his students at Yale University in the 1970s and early 1980s (Charniak 1973; Schank 1975; Schank and Abelson 1977; Schank and Riesbeck 1981; for overview see especially Lehnert 1988). At that time, theoretical linguistics had little to say about semantics. Accordingly, Schank’s group had to invent their own semantic formalism, which they called CONCEPTUAL DE- PENDENCY (CD).

**An important goal of CD is to always represent the same event the same way**

**even though different words can be used to describe it. Accordingly, CD translates all**

verbs into a small set of PRIMITIVE ACTIONS, of which the ones that concern us here are PTRANS (transfer a physical object) and ATRANS (transfer ownership, possession, or some other abstract relationship).© Often, a single verb denotes a whole set of primitive actions connected in particular ways; commonly, one event is the CAUSE or INSTRUMENT of another.

Each PTRANS or ATRANS has four arguments: Actor, Object, Destination-From, and Destination-To (or, in modern terms, Agent, Theme, Source, and Goal). For brevity, we will express these as arguments of a Prolog functor, and we will ignore the distinction between names and common nouns. Here, then, are some CD encodings of simple sentences, with uninstantiated variables standing for unknowns:

John removed the book from the shelf.

ptrans (john, book, shelf,_).

( John went to New York.

ptrans (john, john,_,new_york). John came from the library.

```prolog
ptrans(john,john,library,_).
```

John became the owner of a house.

```prolog
atrans(_,house,_,john).
```

Given this kind of representation, applying a script is a simple matter: match up the events in the script with the events obtained from natural-language input, and let the script fill in any that are missing. Script application is especially easy in Prolog because pattern matching, variable instantiation, and backtracking are built in. Figure 8.5 shows a much-shortened Prolog translation of a Lisp program given by Cullingford (1981), and Figure 8.6 shows the results of using it.

Crucially, this is a “miniature” script applier, designed only to illustrate the idea; areal script applier would be much more powerful, and would be able to choose among appropriate scripts, verify that the chosen script is indeed suitable (e.g., by verifying that Macy’s is a store), provide alternative paths through a complex script, and construct more than just a list of events as output.

This in turn is only a preliminary to the real challenge, which is to derive scripts from knowledge of a more general kind. Relatively few real-world event sequences actually fit scripts that could be known in advance in enough detail to be useful. Accordingly,

<!-- page 268 -->
©The others are MTRANS (transfer information), PROPEL, EXPEL, INGEST, SPEAK, GRASP, MOVE, ATTEND (pay attention to something), and mBuILD (build a mental representation). In addition to actions, there are a variety of STATES in various versions of CD. oe Miniature script-applier based on McSAM (Cullingford 1981)

apply_script (+Events,-Result) AP AP oP takes a list of events and applies a script to them, giving a more detailed list of events.

apply_script (Events,Result) :script (Script), apply_aux(Script,Events,Result).

apply_aux([E|Script], [E]Events],[E]Result]) :apply_aux

(Script, Events,Result). % Event in script matches actual event, so use it

apply_aux([S|Script], [E|Events],[S|Result]) :- \+ (E = S), apply_aux (Script, [E|Events],Result). 6 Event in script matches no actual event, % so add it to the list.

apply_aux(Script,[],Script). % If events are used up, fill in the rest of the % script (which may be empty) and stop.

2 % Script for buying something at a store

script ([ptrans(Actor,Actor,_,Store),

’

ptrans (Actor,Item,_,Actor),

**atrans (Actor,Money,**

Actor, Store)

atrans (Store, Item, Store,Actor),

```prolog
ptrans(Actor,Actor,Store,_)]).
                                   dP dP dP oP
                                   oe
```

go to store,

get an item,

pay for it,

obtain ownership,

go away.

Figure 8.5 Simple script-applying program.

<!-- page 269 -->
Schank and his group have worked extensively on modeling goal-directed behavior, human responses to novel situations, and narrative themes (see Dyer 1983, who reviews earlier work). Computer programs that use Schank’s techniques can be viewed as expert systems for understanding particular kinds of events. They are often strikingly successful within their limited domains. For example, the program CYRUS (Kolodner 1984) could read incoming news stories from a wire service and use them to maintain its own database about the activities of then-Secretary of State Cyrus Vance. It could even refine its scripts by. exploiting patterns found in the data. Obviously, scripts and script generation are important; but just as obviously, they are not confined to the understanding of language, because the same mechanisms would be needed to understand events through, for instance, visual perception. Here, then, we 2 * "John went to Macy’s, got a scarf, and went home."

**?- apply_script**

([ptrans (john, john,_,macys),

```prolog
ptrans(john,scarf,_,john),
ptrans (john, john,_,home)],What)
                                 .
```

What = [ptrans(john,john,_401,macys), ptrans(john,scarf,_423,john), atrans (john,_481,john,macys), atrans (macys, scarf,macys,

john), ptrans (john, john,macys,

home) ]

2 6 "John went to Macy’s and spent $5 there."

**?- apply_script**

([ptrans (john, john,_,macys),

**atrans (john, ’$5’,john,macys)**

],What).

What = [ptrans(john,john,_401,macys), ptrans (john, _339,_ 341, john), atrans (john, ’'$5’,john,macys), atrans (macys,_339,macys,

john), ptrans (john, john,macys,_

385) ] % "John went from his home to Macy’s."

?- apply_script ([ptrans (john, john,home,macys) ],What) .

What = [ptrans (john, john,home,macys), ptrans (john,_135,_137,john), atrans(john,_149,john,macys), atrans(macys,_135,macys,

john), ptrans (john, john,macys,_181)

]

% "John got a scarf from Macy’s."

?- apply_script ([ptrans (john, scarf,macys, john) ],What) .

What = [ptrans(john,john,_211,_213), ptrans(john,scarf,macys,john), atrans (john, _237,john,_213), atrans (_213,scarf,_213,john), ptrans (john, john,_213,_269)

]

<!-- page 270 -->
Figure 8.6 Examples of using the script applier to convert partial narratives into complete ones.

Chap. have definitely crossed the border into knowledge representation and cognitive modeling and since this is a natural language processing textbook, here we must stop. Exercise 8.4.3.1 For each of the examples in Figure 8.6, express both the input and output of apply_script in English.

Exercise 8.4.3.2 Get apply_script working and show that it can process the incomplete narratives in- Figure 8.6, as well as other similar ones. Exercise 8.4.3.3 (open-ended project) Starting with the “miniature” Lisp programs in Schank and Riesbeck (1981), implement further Schankian techniques in Prolog. Build a working natural language understander for a limited domain.

Exercise 8.4.3.4 One of Schank’s criticisms of early natural language processing was that computational linguists wanted to do all the syntactic parsing of a sentence first, and only then begin to build a semantic representation. Schank pointed out that human beings have immediate access to the meaning of each part of a sentence as soon as they hear it; they don’t wait until the sentence is complete before interpreting it, and in fact if they did, some ambiguities would be excessively hard to resolve.

To what extent does this criticism apply to the newer parsing techniques presented in this and the previous chapter?

**8.5 FURTHER READING**

Numerous references have already been given in the text. In addition, Allen (1984) and many of the papers in Grosz et al. (1986) address semantic topics at length. Palmer (1990) presents a fine example of semantics implemented in Prolog for a specific domain (physics word problems). The literature of machine translation is large and varied; at one time several entire journals were devoted to it. Hutchins (1986) reviews the long history of the field, and Nirenburg (1987) presents examples of current work. On word-sense disambiguation and semantic nets, see Hirst (1987), several of the articles in Brachman and Levesque (1985), and all the articles in Evens (1988). Because of its data-driven nature and the acceptability of approximate results, word-sense disambiguation lends itself to neural network implementation, on which see Cottrell (1989). Wilks (1975) and Slator and Wilks ( 1991) explore disambiguation via selectional restrictions. Bartsch (1987) makes a pioneering effort to integrate word sense disambiguation with model-theoretic semantics. The literature on events, scripts, and plans was extensively surveyed in the text. Two sources of additional information are Allen (1983), on temporal reasoning, and Herzog and Rollinger (1991), on current techniques.
