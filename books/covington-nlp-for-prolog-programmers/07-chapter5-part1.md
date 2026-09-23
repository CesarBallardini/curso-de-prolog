# Chapter5_Part1

<!-- page 125 -->
**Unification-Based Grammar**

5.1 A UNIFICATION-BASED FORMALISM

5.1.1 The Problem In Chapter 3, we added FEATURES (arguments) to the nodes in a phrase-structure grammar in order to do a lot of different things. We used features to account for agreement and case marking, build syntactic trees and semantic representations, and even undo movements.

But we never put all these techniques together into a single grammar. Nor did we examine the role of features in contemporary linguistic theory. In this chapter we will do those things. In the process, we will develop an extension to Prolog that will make it much easier to use features in a grammar.

**5.1.2 What is UBG?**

A UNIFICATION-BASED GRAMMAR is any grammar that:

e encodes information in features and their values;

gives values to features only through unification, and not through any other kind

<!-- page 126 -->
of computation. By this criterion the grammars that used features in Chapter 3 were unification-based. So are many of the grammars used in present-day theoretical linguistics. It’s time to look at features from a theoretical viewpoint.

Recall, for example, three rules from Chapter 3:

s --> np(Number,nominative), vp(Number)

. vp(Number) --> v(Number), np(_,accusative). no(Number,Case) --> pronoun (Number,Case).

In unification-based grammar, the same rules are written:

NP

VP

case: nom

[ mum.

VP

4

NP

[ num: X ]

me

[ num: X ]

[ case: acc ]

NP

Pronoun

num: X

**>**

num: X

| case: C

case: C

Here every node except S has a FEATURE STRUCTURE, i.e., a set of features and values. The fact that S has no features is purely accidental; a more complete grammar would assign features to the S node as well.

Fig. 5.1 shows a syntactic tree annoted with features. Whenever a PS rule applies, the feature structures in the rule have to unify with the corresponding feature structures in the tree. For example, the first rule requires the NP and VP to have the same number and requires the NP to have case: nom.

Unification-based grammar is a relatively new development. Features are not; they go back to traditional grammar and are used freely by Chomsky (1965) and others. But unification did not appear on the linguistic scene until the 1980s.

Further, UBG is not, in itself, a theory of grammar. Rather, it is a framework on which some (not all) theories of grammar are based, just as vector arithmetic is a framework for many theories in physics. Some theories of grammar that use various kinds of UBG are Functional Unification Grammar (FUG, Kay 1985, stemming from work in the late 1970s), Lexical-Functional Grammar (LFG, Bresnan 1982), and Generalized Phrase Structure Grammar (GPSG, Gazdar, Klein, Pullum and Sag 1985).

In this chapter we will develop a UBG formalism similar to that of Shieber (1985), but somewhat adapted to bring it closer to Prolog. We will then implement UBG in Prolog and use it to analyze a variety of phenomena in English.

5.1.3 How Features Behave

<!-- page 127 -->
Features get where they are through several different processes, and although we are going to handle all of these processes through unification, we should start by distinguishing them and giving them names. Sec. 5.1 A Unification-Based Formalism

113 S

**NP**

VP case: nom ; num: pl [ num: pl |

**D**

**N**

**V**

**NP**

[ um: pl ] [ num: pl ] subcat: 2 case: acc mums P “P num: pl num: sg

Pronoun case: acc num: sg

The dogs scare

him

Figure 5.1 Example of a tree containing features.

Some features are properties of each word as listed in the dictionary. That is, the LEXICAL ENTRY of a word supplies many of its features. Provisionally, we can think of a lexical entry as a simple PS rule such as:

<!-- page 128 -->
Pronoun num: pl — them case: acc This says that them is a pronoun with plural number and accusative case. We’ll explore lexical entries further in Chapter 9.

Some features are put in place by AGREEMENT RULES—tules that require a feature on one node to match a feature on another. For example, a plural noun requires a plural determiner (you can’t say *one dogs), and a singular noun requires a singular determiner. More concisely, the noun and the determiner AGREE IN NUMBER. Here is a rule that makes them do so:

NP

**D**

**N**

**This is, of course, just the PS rule NP + D NP with features added. Here the X in the**

feature structures is a variable, and this rule requires it to have the same value in the three places where it occurs.

Some features get into the tree by ASSIGNMENT; that is, the grammar requires them to have particular values. For example, the direct object of the verb has to have accusative case, so that J see him is grammatical and */ see he is not. Here is a rule that assigns accusative case to the object:

**NP**

**VP**

**YT case: ace**

**]**

**This is just VP ~ V NP with case: acc added in the right place.**

Finally, some features get into place by PERCOLATION. That is, some of the features on a phrase are copies of the features of the main word in the phrase. For example, if the main verb in a VP is plural, then the VP itself is plural. The plural feature “percolates up” from the V to the VP. Here is the VP rule just given, but with percolation of the num feature added:

VP

Vv

**NP**

[ num: x |

**”**

[ num: x |

[ case: acc ]

**Notice that the VP gets its number from the verb, not from the object.**

Exercise 5.1.3.1

For each of the features in Figure 5.1, indicate whether the occurrence of the feature is best

explained as coming from the lexical entry or from assignment, agreement, or percolation.

Give justification for your claims.

**5.1.4 Features and PS Rules**

<!-- page 129 -->
Before the 1980s, generative grammars treated agreement, percolation, and the like as processes performed by transformational rules. That is, the PS rules would generate the tree and then the transformations would copy features from place to place. Today, however, the leading view is that all features can be accounted for by just one operation— UNIFICATION—which applies along with each PS rule. Sec. 5.1

**A Unification-Based Formalism**

115

**Recall that the purpose of each PS rule is to legitimize a particular part of the tree.**

For example, the rule

**NP**

**+> DN**

legitimizes the structure:

**NP**

**JN**

**D**

**N**

A grammar generates a tree if and only if every part of the tree is legitimized by some rule.

**The features on each node in the tree have to be unified with the features on the**

**corresponding node in the rule. For example, the rule**

**NP**

an

**D**

**N**

requires the structure [num: X] to be unified with the feature structures of the NP, D, and N. Thus it ensures that the NP, D, and N have matching num features, and thereby accomplishes both agreement and percolation. The actual value of the num feature, singular or plural, is supplied in this case by one or more lexical entries. It could also have been supplied by some other rule assigning a num value to the whole NP. Exercise 5.1.4.1

**Using the NP rule just given, plus the lexical entries**

**D—- the**

**N**

=>

dogs

[ num: pl ]

5

draw the complete tree for [yp the dogs }.

**5.1.5 Feature-Structure Unification**

**The features in a feature structure are identified only by name, not by position. Thus**

person: 2

|

and

number: plural

number: plural

person: 2

**are the same feature structure.**

**Two structures can be UNIFIED if they can be combined without contradiction. For**

example,

a: b

**a:b**

and

**aby unify to give**

**ed].**

**cd**

**ef**

<!-- page 130 -->
e: f This is much like Prolog unification; the main difference is that uninstantiated features are simply left out. Thus there is no need for an “anonymous variable.” Variables with names, however, work the same way as in Prolog. For example,

a: b

**a: X**

a: b

**E**

d

and

**E**

xX

unify to give

**“ ‘**

.

The second feature structure doesn’t give values for a and e, but it imposes a requirement that the values of a and e must be the same. This is a lot like what happens if you unify f£(b,d,_) with £(X,_,X) in Prolog. As in Prolog, we will stipulate that

like-named variables are the same if and only if they occur in the same struc-

ture or the same rule.

Feature-structure unification can, of course, fail. In such a case the grammar rule requiring the unification also fails, ie., cannot apply. For example, the feature structures

a: b

a: d

.

**od**

and

e: f

do not unify

(the unification fails) because a cannot have the values b and d simultaneously in the same feature structure.

**A big advantage of unification—one that we’ve already exploited in Prolog—is**

that it’s ORDER-INDEPENDENT. If you unify a set of feature structures, you’ll get the same result no matter what order you unify them in. This means that it is often possible to use a single unification-based grammar with many different parsing algorithms. It doesn’t matter which unifications get done first, as long as all the prescribed unifications are eventually performed. This gives great freedom to the programmer who is designing a parser.

The order-independence of unification also eliminates a vacuous question that arose in transformational grammar. Consider subject-verb agreement, for example. Does the number feature get copied from the subject onto the verb, or from the verb onto the subject? Obviously, it makes no difference. Yet a transformational grammar has to make the copying go in one particular direction; a unification-based grammar merely says that the number features of the subject and of the verb are equal.

Exercise 5.1.5.1

Unify the following feature structures, or indicate why the unification fails.

1.

number: sg

and

number: sg

case: acc

person: 3

**number: N**

cases nom

2.

;

and

person: 3

case: nom

<!-- page 131 -->
number: pl Sec. 5.2 A Sample Grammar

117

[ case: C

person: 3

3. | person: P

and

number: pl | number: sg

case: acc

[ a: b

a: Y 4.)

c ¥

and

ce: X Le: X

**eX**

[ a: b

a: Y

5. | c: ¥

and

ce. d Le f

**eX**

Exercise 5.1.5.2

Here are three feature structures:

**ex]**

**[es]**

**[ez]**

Unify the first (leftmost) structure with the second and show the result; then unify that with . the third. Then do the same thing again, taking the structures in the opposite order (right to left).

**5.2 A SAMPLE GRAMMAR**

**5.2.1 Overview**

**Now it’s time to build a real, working unification-based grammar (working in the sense**

that the rules will fit together properly and generate sentences; we won’t put it on the computer just yet). This grammar will be based on the PS rules:

**S —- NP VP**

VP -—

V/(NP)

NP

-—- _ Pronoun

**NP +> DN**

Pronoun

->

he, him, it, they, them

D_ —

the, a, two

**N - >**

dog, dogs, cat, cats

**V - _**

bark, barks, scare, scares

To this we will add features to enforce five constraints:

<!-- page 132 -->
e Number agreement of subject and verb; e Number agreement of determiner and noun;

Chap. 5 e Assignment of nominative case to subject; e Assignment of accusative case to object; e Subcategorization to distinguish verbs that do and do not take objects.

Exercise 5.2.1.1 Show why each of the five constraints just mentioned is needed. That is, for each constraint, give a sentence (with tree) that is generated by the PS rules but is ungrammatical because it violates the constraint.

5.2.2 Lexical Entries

First, the lexical entries. The pronouns are simple:

Pronoun case: nom

**—**

he num: sg

Pronoun case: acc

**> him**

num: sg

Pronoun [ num: sg ]

Pronoun case: nom

**—**

they num: pl

Pronoun case: acc

**>**

them num: pl

Notice that it has the same form in both nominative and accusative (you can say both it scares him and he scares it); we capture this fact by simply leaving out its case feature. Now for the nouns. Ideally, we'd like to have a rule that adds -s to the singular form of each noun to make the plural. That will have to wait until Chapter 9; in the meantime we will simply list both the singular and the plural form of each noun:

**N**

d [ num: sg |

7”

°8

**N**

**>**

<!-- page 133 -->
dogs [ num: pl |

**N**

t [ num: sg |

**>**

cal

**N**

[ num: pl |

**>**

cats

Notice that nouns are not marked for case. Determiners agree with nouns in number; that is, some determiners are singular and some are plural.

**D**

[ num: sg ]

**7**

4

**D**

t [ num: pl |

**~**

**wo**

**The goes with both singulars and plurals, so we leave its number feature unmarked:**

**D -—=**

_

the

**Next, the verbs. We use a feature called subcat(egorization) to distinguish verbs**

that take an object, such as scare, from verbs that don’t. Like nouns, verbs are marked for number, but this time the -s is absent in the plural. We ignore person agreement (I scare, you scare vs. he scares).

**V**

l num: sg |

**—**

barks subcat: 1 |

**V**

num: pl

**—**

bark subcat: 1 |

v

= num: sg

**>**

scares subcat: 2

**4**

num: pl

**— — scare**

subcat: 2 ]

Exercise 5.2.2.1

Write lexical entries (in the same form as those above) for she, elephant, every, all, chase, and chases.

**5.2.3 Phrase-Structure Rules**

**The phrase-structure rules are simple. Consider first the rule:**

**NP**

**D**

**N**

<!-- page 134 -->
Chap. 5 This accomplishes number agreement of D and N, as well as percolation of the number feature of the N up to the NP. (Or down from the NP to the N, depending on your point of view; in UBG it doesn’t matter.)

The pronoun rule is even simpler, except that it has to percolate case as well as number:

NP

Pronoun

case: C

**>**

case: C

num: X

num: X

There are two VP rules and the subcat feature determines which one any particular verb takes:

**VP**

**v**

;

**>**

subcat: ]

(for verbs without objects);

V

VP

**>**

subcat: 2

NP

(for verbs with objects).

num: X |

.

[ case: acc ]

[

num: X The second rule assigns accusative case to the object.

Finally, the S rule assigns nominative case to the subject and enforces subject-verb number agreement:

**"NP**

**vp**

S o>

case: nom

.

In this grammar, the S node itself has no features. As mentioned earlier, this is purely accidental; a more complete grammar would give features to the S, but in this grammar there happen to be none. Exercise 5.2.3.1

Add feature information to the rule PP + P NP so that, in combination with appropriate

lexical entries, it will generate

[pp for them ]

but not

[pp for he ]

[pp for they ]

<!-- page 135 -->
Write your rule in a form suitable to be added to the grammar we are developing. 5.2.4 How the Rules Fit Together

Unification-based rules work equally well when applied bottom-up, top-down, or in any other order. To work out by hand how the rules generate a particular sentence, it is probably easiest to proceed bottom-up.

Consider the sentence Two dogs bark. Does our grammar generate it? To find out, first look at the lexical entries for the three words, and fill in the part of the tree that they supply:

**D**

**N**

**v**

rl

- vl

subcat: I

[ num: Pp |

[ num: p ]

num: pl

Two

dogs

```prolog
bark.
```

**Next, group D and N together into an NP. Note that the NP — DN**

rule requires NP, D, and N to have the same num feature. So far, no problem:

**NP**

[ num: pl |

**D**

**N**

|

**v**

- pl

- pl

subcat: 1

[ num: P ]

[ num: P ]

num: pl

**Two**

dogs

```prolog
bark.
```

**Now we need a VP. The verb has subcat: I. Only one of the two VP rules matches**

<!-- page 136 -->
a verb with this feature, namely the rule VP — V, which percolates the num feature up from V to VP:

**NP**

**VP**

**V**

**D /**

**N 1**

subcat: I

[ num: Pp |

[ num: Dp ]

num: pl

**Two**

dogs

```prolog
bark.
```

**Finally, S > NP VP requires the NP and VP to agree in number (which they do), and**

**assigns case: nom to the NP (which has no visible effect because nouns are not marked**

for case). Here is the complete structure:

S

**NP**

**VP**

case: nom

[ num: pl |

**V**

**D**

**N**

subcat: 1

[ num: pl |

[ num: pl ]

num: pl

**Two**

**dogs**

```prolog
bark.
```

**Voila—the rules generate the sentence.**

**It makes equal sense to work top-down, starting with S — NP VP, except that**

**the process involves more suspense because there are lots of variables that don’t get**

**instantiated until the last moment. For example, applying the rules S > NP VP, then**

**NP -— DN, and then VP + V, you get**

<!-- page 137 -->
S

**“**

VP

case: nom

D

**N**

**b v ]**

[ num: X |:

[ num: X |

**| ee**

and when you get to the lexical entries, X finally gets instantiated as sg or pl. This illustrates a key advantage of unification-based grammar. You don’t have to know the values of the variables in order to manipulate them. As long as the right variables are made equal to each other, and the variables eventually get instantiated, everything comes out correct. Exercise 5.2.4.1 By working bottom-up, determine whether the grammar generates each of the following sentences. Show your steps. If the sentence turns out not to be generated, show precisely where the unification fails.

1. The dogs scare him.

2. It barks him.

3. The cats bark.

Exercise 5.2.4.2 By working top-down from S -> NP VP, show why the grammar does not generate each of the following sentences. That is, show your steps, and point out the feature conflict when it occurs.

1. It scares he.

2. It scare him.

**5.3 FORMAL PROPERTIES OF FEATURE STRUCTURES**

5.3.1 Features and Values

<!-- page 138 -->
A feature structure is a set of FEATURES (ATTRIBUTES) and VALUES. It contains at most one value for each feature. For example,

**ea**

contains the value b for the feature a, the value d for the feature c, and no value for the feature e. But

a: b

! E

C

(wrong!)

is not a feature structure, because it does not give a unique value for a. A feature is simply a name; no more, no less. A value can be either an atomic symbol (like a Prolog atom or number), or another feature structure. Some examples:

a: b

:

ch d:e

semantics: | ? red: chases fg

tense: present rr rn

person: 3 he | oI

syntax:

. “Tey

number: sg

Nested feature structures like these allow features to be grouped together. For example, it is often convenient to group all the features that percolate into a structure called agr(eement).'! Then instead of

**>**

him Pronoun pers: 3 num: sg

case. acc

we would write:

Pronoun

pers: 3 agr: | num: sg

case: acc

(The pronoun will also have other features that are not in the agr group; we just haven’t seen them yet.) Then—here’s the simplification—it becomes possible to percolate pers, num, and case all at once by just percolating agr, like this:

**NP**

Pronoun [ agr: X |

**~**

[ agr: x]

Here is a full description of feature structure unification as we now know it:

<!-- page 139 -->
'It is not entirely clear whether case belongs in the agr group. For now, it’s convenient to put it there. In English, case percolates but is not involved in agreement.

e To unify two feature structures, unify the values of all the features.

e If a feature occurs in one structure and not in the other, simply put it into the

resulting unified structure.

e If a feature occurs in both structures, unify its values:

e To unify values that are atomic symbols, check that they are equal; otherwise

the unification fails.

e To unify a variable with anything else, simply make it equal to that thing.

e To unify values that are feature structures, apply this whole process recursively.

Here are a couple of examples:

a:b

a:b

**C E**

c

.

.

d: e

**E**

x | and

**fg**

**unify to give | c: | fg**

hi

he i

a: Y

a: Pp

a: p

b: q

.

.

b: q

**E**

r | and

**fay]. unify to give**

**[dip**

Co]

**og**

cy

**og**

Without changing the computational power of the formalism, we can in fact allow values to be Prolog terms of any type. This is so because any Prolog term can be translated into a feature structure. For example, £ (a,b) could become

functor: f

argl: a

arg2: b

and the list [a,b,c] could be rendered as:

first: a

jirst: b

rest:

rst: C

**rest: E**

rest: nil

So we will frequently use Prolog terms as a substitute for feature structures, wherever this is more convenient. Naturally, we presume that Prolog terms unify by ordinary Prolog unification.

Exercise 5.3.1.1

<!-- page 140 -->
Unify each of the following pairs of feature structures, or indicate why the unification fails:

Unification-Based Grammar

Chap. 5

1

syntax: | category: noun

and

syntax: [ number: x |

number: plural

.

P

semantics: [ number: X ]

semantics: [ pred: dog ]

5.3.2 Re-entrancy Feature structures are RE-ENTRANT. Fortunately, this is a property we are familiar with from Prolog. What it means is that if two features have the same value, their values are the same object, not merely two objects that look alike.

To take a Prolog example, unify £(X,X) with f(a(b),_). The result is f£(a(b),a(b)). But the important thing is that the result doesn’t contain two a(b)’s; it contains two pointers to the same a(b). That is, its tree structure is something like

£

rather than:

Feature structures work the same way. If you unify

**ee and**

**[p: [a:b] |**

<!-- page 141 -->
then you get a structure where p and g have the same value, not just two identical-looking values. We will often write this as

p: [ a:b |

q: [ a:b |

but if we do so, something important is lost. To make it perfectly clear that the two instances of [a:b] are really one structure, we can give it an identifying number and write it only once, thus:

**8**

Here the first [1] serves as a label for the structure [a: b]. By writing [1] a second time, we indicate that the same structure is also the value of another feature.

We will use this notation when it is absolutely necessary to show that a structure is re-entrant. For the most part, however, re-entrancy will be easy to understand from context, especially if you are familiar with Prolog.

Here is a case where the notation with boxed numbers is helpful. Suppose we’re grouping agreement features into a structure called agr as proposed a couple of sections back, and now we want to construct an S — NP VP rule such that:

e the NP and VP share all their agr features, i.e., agree in person, number, and

whatever else is relevant; and

e the NP has the agr feature case: nom.

In effect, we want to combine the two rules

NP

VP

s

o>

[ agr: x |

[ agr: x |

NP

[ agr. [ case: nom ] ] VP

Ss

—->

into one. The trouble is that if we give the NP a feature written as agr: X, as in the first rule, there’s no good way to refer to something within agr, as is necessary in the second.

Boxed numbers come to the rescue. We can simply write:

NP

VP

[ agr: [1] [ case: nom | |

**[ agr: [J**

<!-- page 142 -->
This means: The agr features of the NP and of the VP are to be unified with each other, becoming a single structure known as [1]. In addition, [1] must unify with [case: nom]. This has the side effect of giving case: nom to the VP, which is harmless because verbs are not marked for case (though it does suggest a reason for not putting case in the agr group). Exercise 5.3.2.1

Unify the following pairs of feature structures. Use boxed numbers to indicate all re-

entrancy. For example,

**Ee and**

**[a [bc]**

**]**

**unify giving teed |.**

a: X77

**1, [ix**

and

**[a [p: 4] ]**

ec X

a: XJ

a [p: Y]

**2. fis**

and

c: X |

**b [ef]**

**5.3.3 Functions, Paths, and Equational Style**

**A PATH is a description of where to find something in a nested feature structure. For**

example, in the structure

qr

the path p : cc: d leads to the value e..

In mathematics, a PARTIAL FUNCTION is a function that yields a value for some arguments but not for others. We can view a path as a partial function which, given a feature structure, may or may not return a value. For example, in the structure above, p:c:d

has the value e, and q has the value r, but p: z: y has no value. _

This suggests a different way of writing unification-based grammar rules. Instead of using variables in feature structures, we can specify that the values of certain paths have to be equal. I call this “equational style.” For example, instead of

**NP**

Pp

VP

S

=>

**in**

**| per |**

num: X

num: X

case: nom

we can write

S

**—- NPVP**

**(NP pers) = (VP pers)**

**(NP num) = (VP num)**

**(NP case) = nom**

<!-- page 143 -->
That is, the NP’s pers equals the VP’s pers, and the NP’s num equals the VP’s num, and the NP’s case equals nom. This is the notation used by the computer program PATR-II (Shieber 1985).

**We are about to develop an extension of Prolog called GULP in which both con-**

ventional and equational styles can be used. Here are two ways of writing the above rule in GULP:

s --> np(pers:P..num:X..case:nom), vp(pers:P..num:X).

s --> np(NPfeatures), vp(VPfeatures),

{ NPfeatures = pers:P,

VPfeatures = pers:P,

NPfeatures = num:X,

VPfeatures = num:X,

NPfeatures = case:nom }.

In both versions, np and vp each have a single Prolog term as an argument. In the first version, each of these arguments is a feature structure. In the second, the arguments are variables (NPfeatures and VPfeatures) which must then be unified with several feature structures; for example, NPfeatures is unified, in succession, with [pers: P], [num: X], and [case: nom]. This won’t work in ordinary Prolog, of course, but GULP translates notations such as case:nom into structures that unify in the desired way.

**Crucially, both GULP and PATR-II allow you to use paths. For example, in PATR-**

II, you could describe

**NP**

[ agr. [ case. nom ] |

**by saying (NP agr case) = nom. In GULP, you could say that NP has the feature**

agr:case:nom.

Exercise 5.3.3.1

Identify all the paths in

a:b

**lie d: e**

gir

and give their values.

Exercise 5.3.3.2

Express

NP

VP

[ agr:

[ case: nom ] ]

[ agr: [1] ]

in PATR-II equational style. (Hint: You will need to mention the path NP agr case in one

<!-- page 144 -->
of the equations.)

Chap. 5 5.4 AN EXTENSION OF PROLOG FOR UBG 5.4.1 A Better Syntax for Features So far we have implemented features in Prolog as arguments to nodes in DCGs. This works well as long as there are only a few features. Clearly, however, a wide-coverage parser for a human language will have many features, perhaps dozens of them. Most rules mention only a few features, but argument positions have to be provided for every feature so that terms will unify properly. It is easy to end up with grammar rules such as S(_,_,_,_,Tns,_,_,s(Treel,Tree2),_,_,_) -->

```prolog
np(_,_,_,_,_,N,Pers,Treel,_,_,_),
vp(_,_,_,_,Tns,N, Pers,Tree2,_,_,_).
```

which are hard both to read and to type correctly.

To make features less cumbersome we need to do three things:

e Collect all the features into feature structures. Then each node will have only one

argument, a feature structure.

e Develop a convenient notation for writing feature structures in Prolog.

e Somehow get feature structures to unify properly. The notation for feature structures is not too hard. All that is necessary is to define the infix operators ‘:’ and ‘. .’ and write

case: nom

person: P

_ | pred: bark

```prolog
em.
     argl: fido
```

as Case:nom..person:P..sem: (pred:bark. -argl:fido). That is, ‘:’ joins a feature to a value, and ‘. .’ joins one feature-value pair to the next.2. The value of a feature can be any Prolog term, or another feature structure. This is known as GULP notation because it was first used in a program known as Graph Unification Logic Programming (Covington 1989). Fig. 5.2 shows further examples of GULP notation.

The next question is how to get feature structures to unify. There are two possibilities:

e We could write our own unifier that will handle feature structures written in GULP

notation; or

By using colons, we make the Prolog module system unavailable, but this is only a minor limitation; a different character could easily be used. Some Prologs may require you to use something other than the colon.

Tn Arity Prolog 4, a blank is required before each left parenthesis within a feature structure.
