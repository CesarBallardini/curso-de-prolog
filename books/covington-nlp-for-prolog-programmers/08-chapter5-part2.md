# Chapter5_Part2

<!-- page 145 -->
[ num: sg |

;

= num:sg

[ num:

sg

subcat: 2

= num:sg..subcat:2..tense:present |. tense: present

| a: p

b: ta: p

= a:p..b:q..c:(d:p..e:f) [& ee

[

[ a:

b

**le d:e**

Poy

eT

**pg**

**= p:(a:b..c:(d:e..f:g)..h:i)..qir**

Lh:

i L gir

Figure 5.2 Examples of GULP notation.

e We could write a translator that will convert GULP feature structures into something

that the ordinary Prolog unifier handles in the desired way.

Johnson and Klein (1986) and others have taken the first approach; here we take the second.

All we really have to do is map names of features onto positions in a list. For example, if case, person, and number are the only features in our grammar, we can represent each feature structure as a list

[C,P,N]

where C stands for the case, P stands for the person, and N stands for the number. Then in order to unify

case: nom

case: nom

and

person: 3

number: sg

we sunply unify [nom,3,_] with [nom,_,sg] and everything comes out right.

So far, so good. Our translator will read a Prolog program, scan it for GULP feature structures, and convert them all into lists with each value in the right position. To keep these lists from being mistaken for ordinary lists in the translated program, we will mark them with the functor g_/1; the resulting structure will be called a g_-list. For example:

case:C..person:P..number:N

translatesto

```prolog
g_([C,P,N])
```

<!-- page 146 -->
**Every list will be long enough to accommodate all the features in the grammar; this**

**means that in most lists, many positions are never instantiated. For example:**

**case:C..number:N**

translatesto

```prolog
g_([C,_,N]).
```

**This assumes that case, person, and number are the only features in the grammar. If any**

**other features were ever used, there would have to be positions for them in every list.**

**Crucially, the order of the feature-value pairs does not matter; case:C. .number:N**

**translates to exactly the same thing as number:N..case:C.**

Exercise 5.4.1.1

**Write each of the following feature structures in GULP notation.**

**1, | mm s8**

case: acc

[ case: nom

2. | person: 3 L num: pl

**| case: C**

3. | person: P | num: sg

| a: b

d: e 4,

_|

**fs**

C.

**sj**

;

.

pred: chases

semantics: 5

tense: present ,

person: 3

syntax:

num: sg

Exercise 5.4.1.2 Lists are not necessarily the best internal representations for feature structures; they are just the simplest to build. Suggest some alternative data structures that could be used instead, and indicate how they would work.

**5.4.2 Translating a Single Feature Structure**

**What we want to build is a translator program, called Mini-GULP, which will accept**

**Prolog programs (including DCGs) that use GULP notation, and will translate the fea-**

**ture structures from GULP notation into g_-lists while leaving the rest of the program**

<!-- page 147 -->
unaltered.

The translator program will begin with the op declarations

:- op(600,xfy,'’:'’). :- op(601,xfy,’..').

so that as soon as it is loaded, all subsequent Prolog code, including input accepted through read/1, can use GULP notation.

At the beginning of the program to be translated, we will ask the user to supply a set of schemas that map features onto positions in a list. Some examples:

g_schema(case:X,

[X,_,_]). g_schema(person:X, [_,X,_]). g_schema(number:X, [_,_,X]).

Creation of schemas could easily be automated, and in the full GULP system, it is. Here, however, we’re trying to keep things simple.

Each schema then provides the translation of one feature-value pair, except that ‘g_/1’ is left out. For example:

?- g_schema (number:plural,What) ; What = [_,_,plural]

To translate a series of feature-value pairs, such as

case:nom..person:3..number:plural

all we need to do is translate the individual feature-value pairs, then unify the translations with each other, and add ‘g_/1’ at the beginning. That is, we need to obtain the translations

[nom,_,_] [_,3,_] {_,_,plural]

and unify them, thereby obtaining [nom,3,plural], and then add ‘g_’ giving g_([nom,3,plural]). So far, then, the translator needs two clauses:

oe

g_translate(+FeatureStructure,-g_(List)) (FIRST VERSION)

Translates FeatureStructure to internal representation g_(List). oe

oe

Case 1: A single feature-value pair oe g_translate(F:V,g_(List)) :-

```prolog
g_schema(F:V,List).
```

<!-- page 148 -->
Chap. 5

% Case 2: A series of feature-value pairs oe g_translate(First..Rest,g_(List)) :g_translate(First,g_(List)), g_translate(Rest,g_(List)).

This produces the translations that we want, such as:

?- g_translate(case:nom. -number:plural,What). What = g_([nom,_,plural])

The alert reader will have noticed that all functors that have special meaning for Mini- GULP begin with ‘g_’ to avoid conflict with anything in the user’s program. Exercise 5.4.2.1 Suppose a Prolog neophyte says, “I don’t understand how g_translate adds “g_’ to the translation. There isn’t a step in it to do that.” How would you respond?

Exercise 5.4.2.2 Get g_translate working. (Remember that the op declarations go in the translator program.) Then supply schemas for a grammar containing the features case, number, person, sem, pred, and arg! and give the translations produced by g_translate for:

case:nom case:acc..person:2 person:2..case:acc number:singular..sem: (pred: chases. .argl:fido)..person:3

What is unsatisfactory about the last of these?

Exercise 5.4.2.3 Modify g_translate so that if the input contains a feature for which there is no schema, an error message will be produced. (This modification is very helpful in doing the subsequent exercises, and in working with Mini-GULP generally. Everyone misspells a feature or leaves out a schema sooner or later.)

**5.4.3 Translating Terms of All Types**

So far, our translator has two serious limitations:

<!-- page 149 -->
e It won’t translate general Prolog terms, only feature structures. e It won’t accept a feature structure within a feature structure. For Mini-GULP to be useful, both of these problems have to be corrected. Let’s tackle the first one first.

The user’s program is nothing more than a series of terms, most of which have the principal functor *:-’ or ‘-->’. What we want to do is search through each term, translating all the feature structures wherever they occur, but otherwise leaving things unchanged. From this perspective, we need to look for four kinds of terms, not just two:

**e Feature-value pairs. We already know how to handle these, except that we need to**

translate the value, rather than just inserting it into the list unchanged. That will

take care of feature structures within feature structures.

e Sequences of feature-value pairs joined by ‘. .’. Just translate all the feature-value

pairs and merge the results, as we’re already doing.

e Structures. Break the structure up into functor and arguments, recursively translate

all the arguments, then reassemble the result.

e Variables and atomic terms. Leave these unchanged. Actually, we check for these

first, because a variable would match anything, and also because these involve the

least work.

**Note that this is fully recursive. A feature structure can occur inside any other kind**

of term, and any other kind of term can occur within a feature structure. Here are the clauses to implement it:

oe

g_translate(+FeatureStructure,-g_(List)) (SECOND VERSION) oe

Translates FeatureStructure to internal representation g_(List).

Case 1: A variable or atomic term oe de g_translate(X,X) :-

(var(X)

; atomic(X)), !.

oe

Case 2: A single feature-value pair oe g_translate(F:V,g_(List)) :-

ij

```prolog
g_translate(V,Translatedv),
g_schema(F:TranslatedV,List).
```

® Case 3: A series of feature-value pairs % g_translate(First..Rest,g_(List)) :-

1 a

```prolog
g_translate(First,g_(List)),
g_translate(Rest,g_(List)).
```

oe

<!-- page 150 -->
Case 4: A structure oe g_translate(Structure,Result) :-

Structure =.. [Functor|Args],

1

```prolog
g_translate_aux(Args,NewArgs) ,
```

% translate all args

Result =.. [Functor|NewArgs].

Here g_translate_aux/2 translates, in succession, all the elements in a list, like this:

g_translate_aux([T|Terms], [NewT|NewTerms]) :-

```prolog
g_translate(T,NewT),
g_translate_aux(Terms,NewTerms).
```

g_translate_aux([],[]).

Exercise 5.4.3.1

Why doesn’t g_translate need another clause to deal with lists?

Exercise 5.4.3.2

Get g_translate working and use it to translate the same feature structures as in Exercise

5.4.2.2.

5.4.4 Translating While Consulting

**We want the translator to accept programs like that shown in Fig. 5.3. We will write**

**a procedure called g_consult to load such programs into memory, translating GULP**

notation into g_-lists as it does so. The g_consult procedure will read terms from a file one by one and process them, thus:

e If the term is end_of_file, stop. (Recall that this is what read returns when

it hits end of file.)

e If the term is a g_schema, assert it into memory.

e If the term is a grammar rule (with principal functor ‘~->’), translate it, then pass

**it through the DCG rule translator and assert the result into memory.**

e If the term is anything else, translate it and then assert it.

The top level of this processing is easy:

oe

g_consult (+File) oe

Reads clauses from File, translating as appropriate.

g_consult (File) :-

```prolog
see(File),
repeat,
  read(Term)
             ,
  g_consult_aux(Term),
```

<!-- page 151 -->
* handle it appropriately de oe ae oe

**DCG parser for the grammar in Section 5.2.**

To be processed by Mini-GULP.

Demonstrates number agreement, case assignment,

and verb subcategorization.

).

). g_schema(case:X,

X,_,_]

[X,_ g_schema (num: X,

[_,X, g_schema(subcat:X,

[_,_

_]

,X))

pronoun(case:nom..num:sg) --> [he]. pronoun(case:acc..num:sg) --> [him]. pronoun (num:sg)

--> [it]. pronoun(case:nom..num:pl) --> [they]. pronoun(case:acc..num:pl) --> [them].

n(num:sg)

-->

[dog]; [cat]. n(num:pl)

-->

[dogs];[cats].

d(_)

-->

[the]. d(num:sg)

-->

[a]. d(num:pl1)

-->

[two].

)

)

)

**NON**

F PR

(num:sg..subcat:

(num:pl..subcat:

(num:sg..subcat:

(num:pl..subcat:

--> [barks].

--> [bark].

--> [scares].

--> [scare].

)

np(num:N) --> d(num:N), n(num:N). np(num:N..case:C) --> pronoun(num:N..case:C).

vp(num:N) --> v(subcat:1..num:N). vp(num:N) --> v(subcat:2..num:N), np(case:acc).

s --> np(case:nom..num:N), vp(num:N).

Figure 5.3. Example of a program to be input to Mini-GULP.

Term == end_of_file,

!

t seen.

g_consult(_) :-

% if something went wrong in previous clause seen,

<!-- page 152 -->
: write(’g_consult failed.’), nl. All the decision-making is relegated to g_consult_aux, which looks like this:3

g_consult_aux(end_of_file) :- !.

g_consult_aux(g_schema(X,Y)) :- ! “4 assertz(g_schema(X,Y)).

g_consult_aux((X-->Y)) :- ] cad g_translate((X-->Y),Rule), expand_term(Rule,NewRule),

```prolog
% DCG translator
```

assertz (NewRule).

g_consult_aux(Term) :g_translate(Term, TranslatedTerm) , assertz (TranslatedTerm).

**Now Mini-GULP is ready for use. The normal way to use it is as follows:**

1. Get into Prolog.

2. Type ‘?- consult(filename).’ to load Mini-GULP into memory. This executes the op declarations so that GULP syntax becomes legal.

3. Type *?- g_consult(filename).’ to translate and load your program.

4. Type whatever queries your program expects. For example, *?- s([two,cats,bark],[]).’ would be appropriate for the program in Figure 5.3.

,

Exercise 5.4.4.1

What happens if you g_consult the same file twice in succession?

Exercise 5.4.4.2

Get g_consult working and use it to translate and run the program in Figure 5.3. (Your translator program should now contain the op declarations, followed by g_translate, g_consult, and g_consult_aux.)

Exercise 5.4.4.3

Why is the second clause of g_consult necessary?

5.4.5 Output of Feature Structures

There’s still one thing missing: a neat way to output feature structures. This is important because many of our parsers will report their results by building a feature structure.

<!-- page 153 -->
3In ALS Prolog, expand_term/2 is called builtins :dcg_expand/2, and you have to consult (dcegs) to make it available.

Sticking with the program in Figure 5.3, let’s take a simple example. If you want to find out the features of [np him ], you can type

?- np(Features, [him],[]).

but you’ll merely get

Features = g_([acc,sg])

which doesn’t give the names of the features. In a large grammar with dozens of features, output in this format would be almost useless.

One way to get the computer to report names with the features is to use g_schema like this:

?- np(g_(Features),[him],[]), g_schema (FV, Features). FV = case:acc

; FV = num:sg ; no

Notice that ‘g_’ has been added in the first argument of np, so that Features is now just a list. Now we get the names and values of all the features, one at a time, as alternative solutions to the g_schema subgoal.

That’s still rather clumsy, but we can do better. The built-in predicate setof will gather all these alternative solutions into a list, like this:

?- np(g_(Features), [him],[]), setof(FV,g_schema(FV,Features),L). L = [case:acc,num:sg]

That’s almost what we need. The problem is that, in most feature structures in most real grammars, most of the features are uninstantiated, so in a larger grammar you’d get something like

[person:_001,case:acc, gender:_002,tense:_003,num:pl,sem:_004]

which is hardly ideal.

Let’s develop a predicate g_write/1 that outputs feature structures in readable form. Basically, here’s what g_write will do:

e Output a g_-list by converting it into a series of feature-value pairs (using g_write

recursively to write the values, and skipping the ones whose values are uninstan-

tiated).

e Output anything else by calling write/1.

**The alert reader will notice that this is only partly recursive: g write can handle**

<!-- page 154 -->
feature structures inside feature structures, and other terms inside feature structures, but

Chap. 5 not feature structures inside other kinds of terms. For most purposes, this is enough, and it greatly simplifies the program. Here, then, is g_write:

ae g_write(+g_(List)

) Produces legible output of a feature structure in internal form. Assumes all necessary schemas are present. ae oe oe Imperfect; limitations are noted in text.

g_write(g_(Features)) :-

! , write(‘(’), setof (FV,g_schema

(FV, Features) ,FVList) , g_write_aux(FVList), write(’)’).

g_write(X) :write(X).

g_write_aux([]) :ty

g_write_aux([_:V|Rest]) :var(V), | 77 g_write_aux(Rest).

g_write_aux([F:V|Rest]) :-

1 write(F), write(’:’), g_write(V), write(’..’), g_write_aux(Rest).

g_write_aux(X) :write(X).

This is good enough to output most feature structures, but (apart from not being completely recursive) it has a couple of flaws: it writes an extra ‘. .’ after the last featurevalue pair, and it fails to correctly write a variable or an empty list (and thus is not a perfect substitute for write). But at least we can now do things like this:

?- np(Features,[she],[]), g_write(Features)

. (person:3..number:singular..)

<!-- page 155 -->
and thus we will be able to look at the feature structures produced by more complex grammars. Exercise 5.4.5.1 Get g_write working. A good way to test it is to write a program that consists of a set of schemas such as:

g_schema(person:X, [X,_,

). g_schema (number:X, [_,X,_]).

[

.

_]

**_X,_]**

g_schema(sem:X,

—1_,%))

followed by some clauses such as:

testl :- g_write(person:1). test2 :- g_write(person:3..number:plural). test3 :- g_write(sem: (person:3)..number:singular) .

Then load the program through g_consult in order to turn all the feature structures into g_-lists, and see if g_write translates them back correctly when testi, test2, etc., are executed.

Exercise 5.4.5.2 Modify g_write so that ‘?-

_write([]) .’ will output ‘[]’ and‘?-

g_write(xX).’ will output a representation of an uninstantiated variable (something like _001, or whatever your Prolog normally produces).

Exercise 5.4.5.3 Modify g_write so that there will not be an extra ‘. .” after the last feature-value pair. Note that the last feature-value pair to be printed is not necessarily the last one in the g_-list, because features with uninstantiated values are skipped.

**5.5 UBG IN THEORY AND PRACTICE**

**5.5.1 A More Complex Grammar**

It’s time to look at, and implement, a more elaborate unification-based grammar. Here is a grammar based on the four PS rules:

NP -—

Fido, Felix, he, him, they, them

V -—_

chase, chases, sleep, sleeps

VP -—

V/(NP)

S

**—+ NP VP**

To these we will add features to handle the following things:

<!-- page 156 -->
e Case assignment (he chases me, not *him chases dD; e Subject-verb agreement (Fido sleeps, not *Fido sleep);

e Verb subcategorization (Fido chases Felix, not *Fido sleeps Felix);

e Semantics (we will build a primitive semantic representation of the sentence—too

primitive for practical use, but adequate to illustrate some techniques).

All together, the features that we use will be agr, sem, num, case, pred, argl, arg2, and subcat. So the parser has to start with a set of schemas:

g_schema(agr:X,

[X,_,_,_,_1_+_1_])

- g_schema(sem:X,

[_,X,_,_,_,_1_1_]). g_schema(num:X,

[_,_,X%,_,_1+,_,_]). g_schema(case:X,

[_,_,_,X,_,_,_,_]). g_schema (pred:X, [y+

X,_, _, _])g_schema(arg1:X,

[_,_,_,_,_,X,_,_]). g_schema(arg2:X,

[_,_,_,_,_,_,X,_]) g_schema(subcat:X, [_,_,_,_,_,_,_,X])

**Now for the grammar itself. Let’s look first at the lexical entries for the NPs.**

**These endow each NP with a semantic representation of sorts, plus a group of agr**

features (number, and case if case is marked).

NP

Fido

agr: [ num: sg }

sem: fido

NP

Felix

agr: [ num: sg ]

sem: felix

**|**

NP

he

num: S,

agr:

8

case: nom |

sem: he

NP

**agr: [mr 5g**

him

case: acc

sem: him

NP

**agr: [ur pl**

they

case: nom |

sem: they

**NP**

them

num: pl

agr:

case: acc |

<!-- page 157 -->
sem: them Sec. 5.5

**UBG in Theory and Practice**

143 They go into DCG with GULP straightforwardly:

np(agr: (num:sg)..sem:fido)

--> [fido]. np(agr: (num:sg)..sem: felix)

--> [felix]. np (agr: (num:sg..case:nom) ..sem:he)

--> [he]. np (agr: (num:sg..case:acc)..sem:him)

--> [him]. np (agr: (num:pl..case:nom) ..sem:they) --> [they]. np(agr: (num:pl..case:acc)..sem:them) --> [them].

**As before, we have two subcategories of verbs:**

**V**

| subcat: 1

—> — sleeps

agr: [ num: sg |

sem: sleeps

**V**

| subcat: 1

**> _ sleep**

agr: [ num: pl |

sem: sleep

**—**

**V**

subcat: 2

**>**

chases

agr: [ num: sg |

sem: chases

**LW**

**4**

T subcat: 2

—>

chase

agr: [ num. pl |

| sem: chase

|

**These, too, go into GULP straightforwardly:**

(

1..agr: (num:sg (

1l..agr: (num:pl (subcat:2..agr: (num:sg (

2..agr: (num:pl

)..sem:sleeps)

-->

[sleeps].

)..sem:sleep)

-->

[sleep].

)..sem:chases)

-->

[chases].

)..sem:chase)

-->

[chase].

**Notice that our approach to semantics here is extremely naive—we’re just writing each**

**word itself in place of its semantic representation. This is enough to show that we can**

**get the symbols to come out in the right places; we’ll explore semantics in depth in**

Chapters 7 and 8.

**The VP rules must enforce subcategorization and, if there is an object, assign**

**accusative case to it. Here’s what they look like, in UBG and in GULP:**

<!-- page 158 -->
**VP**

**ve**

5

[ subcat: 1

|

xX

**>**

x

.

.

agr:

sem: [ pred: P | |

**| sem: P|**

**VP**

**.**

**vo**

**NP**

agr: xX

**a**

[ subcat: 2

aer: [ case: ace ]

sem:

pred: P

agr: X

sr 42

‘

"|

arg2: A2

|

| sem:

P|

```prolog
sem.
```

vp (agr:X..sem: (pred:P)) -->

```prolog
v(subcat:1..agr:X..sem:P).
```

vp (agr:X..sem: (pred:P..arg2:A2)) -->

```prolog
v(subcat:2..agr:X..sem:P),
np(agr: (case:acc)..sem:A2).
```

Notice what these rules do. Besides enforcing subcategorization, percolating agr, and assigning case to the direct object, they also build a semantic representation. The semantics of the verb (P) and of the noun (A2) get combined into a structure representing the semantics of the VP, such as

pred: chases

arg2: fido

**if the VP is chases Fido. As you might guess, the S rule is going to add an arg/, so that**

Felix chases Fido will come out as:

. pred: chase

argl: felix

arg2: fido

The S rule itself takes the form

5

**NP**

VP

>

2

**[ sem: [Jf argi:ar**

J]

**| we) [ case: nom**

**|**

**ae**

Here the S has a single feature, sem, which is the same as the sem feature of the VP except that it also has to unify with arg]: Al (which is how the semantics of the subject gets into it). NP and VP share all their agr features and are required to contain case: nom. To express this rule in GULP, we have to use equational style:

s(Sfeatures) --> np(NPfeatures), vp(VPfeatures),

{ Sfeatures

= sem: (argl:Al), NPfeatures = sem:Al,

Sfeatures

= sem:S,

VPfeatures = sem:S,

NPfeatures = agr:X,

VPfeatures = agr:X,

NPfeatures = agr:case:nom

<!-- page 159 -->
}. Sec. 5.5

**UBG in Theory and Practice**

145 It’s also possible to use a style that is only partly equational, like this:

s(sem:S) --> np(agr:X..sem:Al), vp(agr:X..sem:S),

il

{

Ss

argl:Al,

X = case:nom }.

Here the second line means, “In addition to the value that S already has, S must be unified with arg1:A1,” and likewise for X and case:non.

**Notice that, since the sem of the S and of the VP are unified with each other,**

argl gets added to the sem of the VP as well as of the S. This is harmless and, in fact, correctly reflects the fact that the meaning of the verb is incomplete until the meaning of the subject is added.

To parse a sentence, issue a query such as:*

?- s(Features, [felix, chases,fido],[]), g_write(Features). (sem: (argl:felix..arg2:fido. -pred: chases)

)

**All you’re doing here is invoking a DCG parser in the usual way and telling it to parse**

[fido, chases, felix] and end up with []. The argument of s is Features, a GULP feature structure which is then printed out by g_write. In this grammar, the features of S contain a primitive semantic representation of the sentence.

You can equally well parse any other constituent, for example a VP, like this:

?- vp(Features, [chases,fido],[]),

_write (Features). (agr: (num:sg)..sem: (arg2:fido. -pred:chases) )

This highlights an important fact:

Unification-based grammar is not sentence based.

In UBG, the sentence is just one of many constituents that can be described and parsed. This contrasts sharply with transformational grammar, in which many transformations apply only to the whole S, and the grammar does not correctly generate NPs, VPs, etc., unless they are embedded in their proper places in sentences.

Exercise 5.5.1.1

Draw trees (with features) for the following sentences generated by this grammar:

1. Fido chases him.

<!-- page 160 -->
“The output as shown here assumes that the behavior of g-write has been cleaned up as suggested in the exercises. Otherwise there will be a redundant ‘..’ at the end.

2. They sleep.

3. He chases Fido.

In doing this by hand, it is probably best to work bottom-up. First write down the words

and apply the lexical entries. Then group the words into phrases, performing appropriate

unifications as you go.

Exercise 5.5.1.2

Get this grammar working, as a DCG parser, on your computer. Parse the three sentences

from the previous exercise, and give the features of the S.

Exercise 5.5.1.3

Modify this grammar so that every node has another feature, tree, whose value is a repre-

sentation of the parse tree below it. This will work very much like the tree-building parser

in Chapter 3. Parse the same three sentences again and show the value of tree for S.

Exercise 5.5.1.4

Construct and implement a UBG to parse sentences such as

Who did Max say ,, thought Fido barked?

(as in Section 3.4.5), constructing a representation of the tree in which who is associated

with (or moved into) the position of the missing NP.

**5.5.2 Context-Free Backbones and Subcategorization**

Lists

**So far, every UBG that we’ve worked with has had a CONTEXT-FREE BACKBONE—that**

is, if you strip away all the features, you get context-free PS rules.

Notice that the node labels themselves can be treated as features. Instead of

**NP**

case: nom

num: pl

we can write

cat: np

case: nom

num: pl

<!-- page 161 -->
So far so good; the grammar still has a context-free backbone if every node in every rule has a cat feature whose value contains no variables. (Normally the value of cat is an atomic symbol such as np, but Jackendoff (1977) and Gazdar et al. (1985) explore what can be accomplished by using feature structures there.)

Sec. 5.5

UBG in Theory and Practice

147

If we let cat be a variable, we pass into interesting territory. For one thing, we can handle verb subcategorization by giving each verb a feature which is a list of complement categories. Consider the rules:

cat: vp

cat: vp

;

| Sone Y

**”**

| sean [X | Y]

[ cat, x]

[cat:s]

**>**

**[ cat: np**

**] | Se ]**

The first rule is effectively VP + VP X, where X comes from the subcat list of the VP. It applies recursively, picking off values of X one by one until there are none left. Then the second rule, S > NP VP, is allowed to apply.

With these rules we use lexical entries such as the following:

cat: vp

subcat: [] |

—> _ bark(s)

(bark takes no complement)

cat: vp

subcat: [np]

**> chase(s)**

(chase takes one NP)

cat: vp

.

**| Sen [np,np]**

**> give(s)**

(give takes two NPs)

cat: vp

subcat: [np,s]

**> — tell(s)**

(tell takes an NP and an S)

The resulting structures are as shown in Fig. 5.4.

This analysis follows a proposal by Shieber (1985:27-32) except that we use Prolog notation for lists, and the subject of the verb is not listed among its complements. Note that a verb here is a VP, not a V. Note also that the elements of a subcategorization list could be feature structures.

Unfortunately we can’t implement this with a top-down DCG parser. The obvious way to approach it is to give all nodes the same label (let’s use z) and encode the real node labels in the cat feature, rendering the first rule thus: Z(cat:ivp..subcat:Y) --> Z(Cat:vp..subcat:[X|¥Y]), Z(cat:X). The problem is that, parsing top-down, this rule creates an endless loop. In order to parse z(cat:vp..subcat: [X|Y]), with x and y uninstantiated, this rule simply calls itself. We will return to this point in the next chapter.

<!-- page 162 -->
Are subcategorization lists a good idea? That depends. To use subcategorization lists is to claim (with Gross 1979) that verbs do not necessarily fall into classes and thus that the complements of each verb must be listed in its lexical entry. Many generative

**[ cat: s ]**

;

cat: vp [ cat: np ]

**| cr 0**

cat: vp

;

subcat: [s]

[ cat:

|

cat: vp

;

.

cat: vp

subcat: [np,s]

[ cat: np ]

[ cat: np ]

subcat: []

**Max**

told

**"us**

Fido

barks

Figure 5.4 Tree showing how subcategorization lists work.

linguists, however, believe (with Gazdar et al. 1985) that verbs fall into a finite, though possibly large, set of classes, and thus that subcategorization with numbers (as pointers to classes) is more appropriate.

Exercise 5.5.2.1

**|**

Using the rules developed in this section, draw trees for the sentences:

1. Fido chases Felix.

2. Felix gives Fido a hard time.

<!-- page 163 -->
Assume any other PS rules that are necessary. 5.5.3 Negative and Disjunctive Features

**The alert reader will notice that we have been ignoring the person feature of the English**

verb. There’s a good reason. Every regular present tense verb has two forms: with -s in the third person singular, and without -s elsewhere. Thus we get:

Singular

Plural

lst person

(1) _ bark

(we)

bark

2nd person

(you)

bark

(you)

bark

3rd person

(he, she, it)

barks

(they)

bark

**In UBG as formulated so far, the best we can do is list the form with -s once, and the**

form without -s three times:

**V**

_ | person: 3

**— _ barks**

a8" | num: Sg

**V**

[ agr: [ person: 2 ] ]

+>

bark

**V**

[ agr: [ person: 1 ] ]

**> — bark**

**v**

**— _ bark**

[ agr: [ num: pl ] ]

**It would be more convenient if we could collapse the last three of these into one rule**

like this:

**V**

agr: not person:3

**— _ bark**

num:sg

Here not means “This feature must ultimately have a value that will not unify with the value shown here.” This is called a NEGATIVE feature.

**Or consider the forms of the German word for “the” (der, die, das, etc.). A striking**

pattern emerges: the form is die whenever:

e the case is nominative or accusative (not genitive or dative), and

<!-- page 164 -->
e the gender is feminine or the number is plural (or both). We could sum this up as:

**D**

case: nom or acc

—>

die

agr: [ num: pl | or [ gen: fem |

**Here we’ve moved case outside the agr group, and or means “the actual value must**

unify with one of these values, or the other, or both.” Features joined with or are called DISJUNCTIVE features.

Obviously the Prolog unifier will not handle negative or disjunctive features. Johnson (1991) discusses them lucidly and offers an analysis based on classical logic, leading to a unifier based on a theorem-proving algorithm.

Exercise 5.5.3.1

Using negative and/or disjunctive features, write concise lexical entries for the English

copula:

Singular

Plural

1st person

(I)

**am**

(we)

are

2nd person

(you)

are

(you)

are

3rd person

(he, she, it)

is

(they)

are

Exercise 5.5.3.2

If negative and disjunctive features were implemented, what should be the result of unifying

each of the following pairs of feature structures? Explain your answers and relate them to

what you know about logic.

1. | person: not 3 ]

and

[ person: 2 |

**|**

**2. [ person: lor2|**

**and | person: 2 |**

**.[a:borc]**

**and**

**[a: cord]**

**4.[a:borc]**

**and**

**[a:notb**

**|**

Exercise 5.5.3.3

(project)

Implement a unifier for negative and/or disjunctive feature structures. (See Johnson (1991)

for guidance.)
