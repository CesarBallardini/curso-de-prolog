# Chapter7_Part1

<!-- page 210 -->
**Semantics, Logic, and Model**

**Theory**

**7.1 THE PROBLEM OF SEMANTICS**

Semantics is the level at which language makes contact with the real world. This means that semantics is at once the most important part of natural language processing, and the most difficult. Many problems in computational semantics have, as yet, no widely accepted solutions. In principle, an entirely adequate theory of semantics would require a complete theory of human thought.

The goals of this chapter are more modest. In it, we will focus on how to translate English into Prolog or something close to it, mainly in order to answer database queries. Even though Prolog is not powerful enough to represent human knowledge as a whole, it is adequate and convenient for the kinds of information commonly stored in computers. Practically all computer databases map onto Prolog in a simple way.

<!-- page 211 -->
The techniques used here are somewhat ad hoc, but there is a strong emphasis on the underlying logical theory. The model-theoretic semantics is largely based on the Discourse Representation Theory of Kamp (1981; for a readable exposition see Spencer-Smith 1987, and for an implementation, Covington, Nute, Goodman, and Schmitz 1988). 7.2 FROM ENGLISH TO LOGICAL FORMULAS

**7.2.1 Logic and Model Theory**

To describe the meanings of natural-language utterances, we need a precise way to describe the information that they contain. We can get this from logic and set theory; it’s called MODEL-THEORETIC SEMANTICS. It relies on MODELS, which are precisely defined knowledge bases.

Consider a simple formula such as chases (fido, felix) (‘Fido chases Felix’). This formula is part of a logical language. A MopEL for the language consists of a DOMAIN D, which is the set of individual people and things that can be talked about, plus an INTERPRETATION FUNCTION I which maps everything in the language onto something in the domain. Specifically:

e I maps logical constants (proper names) onto individual members of D. For in-

stance, I(fido) is Fido.

e I maps predicates onto sets of tuples of elements of D. For example, I(green) picks

**_ out the 1-tuples consisting of elements of D that are green. I(chases) picks out all**

**the pairs (x, y) of elements of D such that x chases y. Similarly, I would map a**

three-place predicate onto a set of ordered triples, and so on.

Now we can define, in a precise way, what it means for a formula to be true:

**e A formula of the form predicate (arg,,arg,,...) is true if and only if (I(arg 1)>**

I(arg,),...) € I(predicate).

For example, chases (fido, felix) is true when (I(fido), I(felix)) € I(chases).

**e A formula that contains quantifiers or connectives such as =, A, V, V, 4 is true if**

it meets the conditions given by the definitions of the connectives and quantifiers

(Table 7.1).

TABLE 7.1.

LOGIC SYMBOLS.

Symbol

Readas

Example

Meaning

=

not

aP

P is not true

A

and

**PAQ**

**P is true and**

Q is true

v

or

PVQ

P is true or Q is true, or both

**>**

implies

P—>Q

if P is true then so is Q

(either P is false or Q is true, or both)

Vv

for all

(Wx)P

P is true for all values of x

4

forsome

(dx)P

P is true for at least one value of x

Xr

lambda

(Ax) p

the formula is incomplete and has no

truth value until a value is

<!-- page 212 -->
supplied for x

Chap. 7° For example, the definition of A says that P A Q is true if and only if P and O are both true. The definition of V Says that (Vx)P is true if and only if P is true for all possible values of x (i.e., true no matter which element of D we assign to x) Compared to other ways of evaluating logical formulas, model theory has two important advantages. First, it assigns meanings to all parts of every formula, rather than just assigning truth values to complete sentences. Second, model theory works with knowledge bases (models) without making any claims about the real world as a whole. This is important because it corresponds closely to computer manipulation of a database. Exercise 7.2.1.1 Given the model D = {Fido, Felix, Max} I(fido) = Fido I(felix) = Felix I(max) = Max (animal) = {{Fido), (Felix)} I(chases) = {(Fido, Felix), (Max, Fido)} determine whether each of the following formulas is true or false, and show how you obtained each result: animal (max) animal (fido) animal (fido) “ chases (max, fido) animal (max) — animal (fido) (¥x) (animal (x) + chases (x, max))

Exercise 7.2.1.2 Assume that it is true that Fido shows Felix to Max, and that shows is a three-place predicate. Supply I(shows).

<!-- page 213 -->
7.2.2 Simple Words and Phrases Table 7.2 shows logical formulas that represent a number of simple English words and phrases, along with a way of representing these formulas in Prolog. As in Chapters 2 and 3, we represent lambda as ~, which is right-associative so that Y°X* formula = Y* (X* formula). The first thing to note is that names are logical constants (‘Max’ = max), but common nouns, like adjectives, are predicates (‘dog’ = (Ax)dog(x)). Being a dog, like being green, is a property, not a thing. This has to do with the distinction between sense and reference. A name can tefer to only one individual, so we translate it directly into a logical constant.! But a ‘At least for the moment. Montague (1973) and others argue that even names should be treated as denoting sets of properties, TABLE 7.2 REPRESENTATIONS OF SIMPLE WORDS AND PHRASES.

Type of

Logical

As written

constituent

representation

in Prolog

Proper noun

Logical constant Max

max

max Fido

fido

fido

**Common noun**

1-place predicate dog

(Ax)dog (x)

X*dog(X) professor

(Ax) professor (x)

X“professor (X)

Adjective

1-place predicate green

(Ax) green (x)

X* green (X) big

(Ax)big (x)

X*big(X)

~ Noun with

1-place predicates adjectives

joined by ‘and’ green dog

(Ax)(green(x) A dog(x)) — X* (green(X) ,dog(X))

Verb phrase

1-place predicate

(Ax) barked (x) barked chased Felix

(Ax) chased (x, felix)

X“barked(X)

X°chased(X, felix)

Transitive verb

2-place predicate chased

(Ay)(Ax)chased (x, y)

Y°X* chased

(X,Y)

Copular verb phrase

1-place predicate is a dog is green

(Ax)dog (x)

(Ax) green (x)

**X*dog(X)**

**X*green(X)**

Prepositional phrase

1-place predicate with Max

(Ax) with (x, max)

X°with(X,max)

Preposition

2-place predicate with

(Ay)(Ax)with (x, y)

**Y°X*with (X,Y)**

**common noun such as ‘dog’ can refer to many different individuals, so its translation is**

<!-- page 214 -->
the property that these individuals share. The referent of ‘dog’ in any particular utterance is the value of x that makes dog (x) true. Second, note that different verbs require different numbers of arguments. The intransitive verb ‘barked’ translates to a one-place predicate (Ax)barked(x). A transitive verb translates to a two-place predicate; a ditransitive verb such as give translates to a three-place predicate such as (Az) (Ay) (Ax) give(x, y, z). These arguments are filled in, step by step, as you progress up from verb to VP and then S, thus: Verb

chases

(Ay) (Ax)chases (x, y) Verb phrase

chases Felix

(Ax) chases (x, felix) Sentence

Fido chases Felix

chases (fido, felix)

**We saw this process in action in Chapter 3.**

Some sentences correspond to formulas with logical connectives in them: Fido does not chase Felix — chases (fido, felix) Fido and Felix are animals

animal (fido) A animal (felix) Note in Table 7.2 that the copula (is) is unusual among verbs because it has no semantic representation. To put this another way, is X means the same thing as X. The representation for ‘is a dog’ is the same as for ‘dog.’ Last, note that Table 7.2 does not cover the whole of English. Neither does firstorder predicate logic. Here are some examples where first-order logic is not sufficient to represent English:

e Predicate with a predicate as argument:

**Max has an unusual property.**

(Ap)(p(max) A unusual (p))

e Predicate with a whole proposition as an argument:

Fido believes Felix is human. believes (fido, human (felix))

e Context in which reference is blocked:

John is looking for a unicorn.

5 (It’s not clear how to represent “a unicorn” here. Any formula that contains (dx) ...unicorn(x) is wrong because this unicorn need not exist.) We will not try to deal with such cases here, but they are all-pervasive; you cannot analyze much natural-language text without running into them. Fortunately, if you confine yourself to texts whose information content can be represented in a computer database, first-order logic or something close to it is usually sufficient. Exercise 7.2.2.1 Using Tables 7.1 and 7.2, represent each of the following sentences as a logical formula:

Max is angry.

Fido chased Felix.

Felix did not chase Fido.

<!-- page 215 -->
Either Felix is green, or Fido is blue, or both. Sec. 7.2

From English to Logical Formulas

201

Fido is a dog and Felix is a cat.

If Max is angry then Fido is angry.

Fido is a green dog.

Fido is either a dog or a cat, but not both.

**7.2.3 Semantics of the N' Constituent**

**Now let’s do something practical. Recall the syntax rules:**

**N! + Adj**

**N!**

**N! + N**

The N' constituent is a common noun together with zero or more adjectives, but no determiner, such as big green dog or fat professor.

Let’s implement the semantics of the N!. Adjectives and common nouns alike translate to one-place predicates. What we want to do is combine all the predicates in the N!, joining them with A (‘and’). From

big

= . (Ax)big (x)

green

=

(Ax)green(x)

dog

=

(Ax)dog(x)

we want to get:

**big green dog = (Ax) (big (x) A green (x) A dog(x)).**

Switching to Prolog notation, we want to combine X*big(X), X°green(X), and X“dog(X) to get X* (big (X) , green (x) , dog (X)). Crucially, we have to ensure that the variables get unified with each other; it would be quite unsatisfactory if we got (big (X),green(Y),dog(Z)).

**All this is easy to accomplish through arguments on DCG rules. First the lexical**

entries for particular words:

adj (X*big(X))

--> [big]. adj (X*brown(X))

--> [brown]. adj (X*little(X)) --> [little]. adj (X*green(X))

--> [green].

n(X*dog(X)) --> [dog]. n(X*cat (X)) --> [cat].

**Now for the PS rules. The rule**

**NV! > Nis easy to handle, since in this case the semantics**

of the whole N! is the same as that of the noun:

<!-- page 216 -->
nl(Sem) --> n(Sem).

Chap. 3 Finally, here is the rule that combines an adjective with an NI: n1(X*(P,Q)) --> adj(X*P), nl(X*Q). Notice that this rule is recursive. After combining one adjective with an N!, it can. combine another adjective with the resulting N!, and so on, as shown in Figure 7.1,

n°

X° (big (X) ,green(X) ,dog(X))

Adj

N}

X*big(X)

X* (green (X) ,dog(X))

Adj

N!

X* green (X)

X"dog (X)

**N**

X*dog (X)

big

green

7

dog

Figure 7.1

Constructing the semantics of an N!.

Exercise 7.2.3.1

What would happen if, in place of

```prolog
n1(X*(P,Q)) --> adj(x*P), n1(x*Q).
```

the last rule were written as follows?

```prolog
ni((P,Q)) --> adj(P), n1(Q).
```

Exercise 7.2.3.2

Using the rules just given, get a small parser working and show that it generates the correct

<!-- page 217 -->
semantics for the phrases cat, big cat, big brown dog, and big green cat. Exercise 7.2.3.3

Extend this small parser so that:

e It handles NPs whose determiner is a or an, so that, for example, the semantics of a

big green dog is the same as that of big green dog.

e It handles sentences of the form Name is NP, such as Felix is a big brown cat, and

generates correct semantics, in this case

(big (felix) , brown (felix) ,cat (felix) ).

7.3 QUANTIFIERS (DETERMINERS)

7.3.1 Quantifiers in Language, Logic, and Prolog

Determiners in natural language correspond to quantifiers in formal logic; we shall use the terms quantifier and determiner almost interchangeably.2 Table 7.3 shows some sentences that contain quantifiers and their semantic representations.

The alert reader will notice that the quantifier 3 normally goes with the connective A, and V with —. In our Prolog renditions of the logical formulas, the connectives are implicit. We write all (X,Goall,Goal2) to mean that all values of X which satisfy Goal1 also satisfy Goal2. A predicate to test this, in database queries, can be defined as follows:

all(_,Goal1l,Goal2) :-

\+ (Goall, \+ Goal2).

That’s very simple: verify that there is no way to satisfy Goal1 that cannot be extended (by instantiating more variables) to satisfy Goal2. The argument X is not actually used; we include it only so that al1 will have the same argument structure as other quantifiers to be defined later on.

But wait a minute—what if there is no way to satisfy Goall at all? Then all(X,Goall,Goal2) succeeds, and that’s probably not what we want. In logic, (Vx)(p(x) — q(x)) is true in the situation where p(x) is always false. But in natural language, we don’t want to claim that all unicorns are green is true when there are no unicorns in the knowledge base. Accordingly, we should modify all to test that there is indeed at least one solution to Goal1, and then cut to prevent pointless backtracking:

ae

all (-X,+Goall,+Goal2) ae oe

Succeeds if all values of X that satisfy Goall

also satisfy Goal2.

<!-- page 218 -->
2Some authors say that a quantifier consists of a determiner plus its restrictor; that is, a determiner by itself is not a complete quantifier, but only an ingredient for making one. On this view, for example, ‘most dogs’ is a quantifier but ‘most’ is not. See the next section.

Chap. 7

all(_,Goall,Goal2) :- \+ (Goall, \+ Goal2), Goall,

i}

**The definition of some is even simpler, because all we have to do is find one solution**

**of Goall and Goal2. Again, we use a cut to prevent pointless backtracking:**

some (~X,+Goall,+Goal2) AP dP oe Succeeds if there is a value of X that satisfies Goall and Goal2.

some (_,Goall,Goal2) :- Goall, Goal2,

Exercise 7.3.1.1 Referring to Table 7.3 as needed, express each of the following sentences as a logical formula, and as the Prolog representation of that formula.

All unicorns are animals. One or more unicorns are purple. A cat chased Fido. Every cat chased Fido. Every cat is an animal. Every cat chased a dog.

Exercise 7.3.1.2 When al1/3 succeeds, does it instantiate its first argument? If so, explain how.

Exercise 7.3.1.3 What is the purpose of the cut in some/3?

Exercise 7.3.1.4

Given the knowledge base

<!-- page 219 -->
dog(fido). cat (felix). cat (leo). animal (leo). animal (felix). animal (fido). Sec. 7.3 Quantifiers (Determiners)

**205**

TABLE 7.3 QUANTIFIERS DETERMINE THE OVERALL SEMANTIC STRUCTURE OF THE SENTENCE.

Sentence

Representations

Fido barked. barked (fido) barked (fido)

A dog barked. (Ax) (dog (x) A barked (x)) some (X,dog(X) ,barked(X))

Every dog barked. (Vx)(dog (x) —> barked(x)) all(X,dog(X) , barked (X))

Fido chased a cat. (Ax) (cat(x) A chased (fido, xy) i. some (X,cat (X) ,chased(fido,X))

Fido chased every cat. (Vx) (cat(x) + chased (fido, x)) all (X, cat (X) , chased (fido,X)) A dog chased a cat. (Ax) (dog (x) A (Ay) (cat (y) A chased (x, y))) some (X,dog(X) ,some(Y, cat (Y) ,chased(X,Y))) A dog chased every cat. (Ax) (dog (x) A (Vy)(cat(y) > chased (x, y))) some (X,dog(X) ,all(Y,cat(¥) ,chased(X,Y))) Every dog chased a cat. (¥x)(dog (x) > (Ay)(cat(y) A chased(x, y))) all(X,dog(X) ,some(Y,cat(Y) , chased (X »Y))) Every dog chased every cat. (Wx)(dog(x) > (Vy) (cat(y) — chased(x, y))) all(X,dog(X) ,all(¥,cat(¥) , chased (X,Y) ))

predict (without using the computer) the outcomes of the queries:

?- some (X,dog(X),animal (

X)) 2?- all (X,cat (X),animal (xX

) ?- all (X,animal (X),cat

(X) xX

).

).

Then use the computer to confirm your results.

**7.3.2 Restrictor and Scope**

**We noted already that J is somehow associated with A and V with >. In fact, in Prolog,**

**we left out the latter connective and treated each quantifier as a relationship between a**

**quantified variable and two Prolog goals.**

Let’s pursue this idea further. Consider the formulas

**(Ax) (cat (x) A animal (x))**

“At least one cat is an animal.’ (Wx)(cat(x) + animal(x))

<!-- page 220 -->
‘Every cat is an animal.’ These can be written another way. Let (Vx : cat(x)) mean ‘For all x such that x is q > cat.’ Then, using this notation, we can write:

(Ax : cat(x))animal(x)

‘At least one cat is an animal.’

(Vx : cat(x))animal(x)

‘Every cat is an animal.’

Notice that the connectives A and — have disappeared.

**a**

In this new notation, cat(x) is called the RESTRICTOR (or RANGE) of the quantifier dx or Vx; it restricts the set of values of x that the quantifier can pick out. The rest of

— the formula, here animal(x), is the scope of the quantifier; it is the proposition that is ~ supposed to be true for the appropriate values of x.

From this perspective we can look at each quantifier as a relation between quantified variable, scope, and restrictor:

e (Ax) means that at least one value of x that makes the restrictor true will also make

the scope true;

e (Yx) means that every value of x that makes the restrictor true will also make the

scope true.

More precisely, for any quantified variable x, the quantifier is a relation between the set of values of x that satisfy the restrictor, and the set of values of x that satisfy both the restrictor and the scope.

It’s easy to invent other quantifiers, such as:

e (two x), meaning that exactly two of the values of x that satisfy the restrictor also

satisfy the scope;

e (most x), meaning that more than half of the values of x that satisfy the restrictor

also satisfy the scope;

or whatever you like. These are called GENERALIZED QUANTIFIERS and are essential for analyzing natural language.

**We can represent generalized quantifiers in Prolog with three-place predicates such**

**as two (X,Goall,Goal2), most (X,Goall,Goal2), and so forth. Now it is ob-**

vious why X has to be an argument (even though some and al1-didn’t use it): quantifiers

: like two and most have to count the values of X that satisfy the goals, and they have to

| make sure they are indeed counting values of X rather than values of some other variable. Exercise 7.3.2.1

Rewrite each of your formulas from Exercise 7.3.1.1 in restrictor-scope format

(in logical notation; the Prolog is already in restrictor-scope format).

Exercise 7.3.2.2

Consider the knowledge base:

dog (fido).

cat (felix).

**TR ee**

<!-- page 221 -->
ee eS Sec. 7.3

Quantifiers (Determiners)

207

cat (leo). chases (fido, felix) . chases (fido,leo). ~ How many solutions are there to the query *?- dog(X),cat(Y),chases (X,Y) .’? How many dogs are cat-chasers? Why aren’t these the same number, and what does this tell us about the right way to implement generalized quantifiers? Exercise 7.3.2.3 Define the generalized quantifier two in Prolog using setof (see section 7.4.2.) Exercise 7.3.2.4 In ordinary English, does two mean ‘exactly 2’ or does it mean ‘2 or more’? Discuss and cite evidence.

. 7.3.3: Structural Importance of Determiners Determiners affect more of the semantic structure than the syntactic structure would suggest. Consider for example Fido chases every cat. On the syntactic level, every modifies cat. You might therefore expect that on the semantic level, when every is converted into anall(...,...,...) structure, only cat will be inside it. But such an expectation would be wrong. On the semantic level, every has scope over the entire sentence, even though syntactically it only modifies cat. Figure 7.2 shows part of the process by which the semantic structure is built up. Or consider Every dog chases a cat, which we represent as: all (X,dog(X),some (Y,cat(Y),chases (X,Y))) Here the constituent every dog gives rise to an all structure that contains not only the representation of the NP (where every occurs), but also the representation of the VP. Does this mean that our enterprise of building semantic structures constituent-byconstituent is doomed? No; it means only that some careful use of lambda expressions is required. Exercise 7.3.3.1 Draw diagrams like Figure 7.2 for the sentences:

Every cat chased Fido.

Some dog chased every cat.

<!-- page 222 -->
7.3.4 Building Quantified Structures Now for the implementation. Despite their complexity, the semantic Structures that we need can still be built through unification of arguments in DCG rules.

Chap. 7

Ss

```prolog
all(Y,cat(¥) ,chased(fido,Y))
```

NP

VP fido

```prolog
            all(Y,cat(Y) ,chased(X,Y))
    Vv
                                       NP
chased (X,Y)
                                 all(Y,cat(Y),...)
                            D
                                                   N
                      all(...,...,...)
                                                  cat (Y)
```

Fido

chased

every

cat

Figure 7.2. The quantifier all dominates the semantic representation, even though syntactically it

belongs only to the last NP. (This structure is incomplete; all Jambdas are left out.)

Our representation of verbs and common nouns will be the same as before. For brevity we will omit the N! node. This gives us some lexical entries:

n(X*dog(X)) --> [dog]. n(X*cat(X)) --> [cat].

v (X*meowed (X) )

--> [meowed]. v(Y°X*chased(X,Y)) --> [chased]. v(Y°X*saw(X,Y) )

--> [saw].

\

The key question at this point is how to represent determiners. For our purposes, a determiner is something that takes a scope and a restrictor, and puts them together. So the semantic representation of every determiner will have the form (X*Res) * (X*Sco) “Formula—that is, “Give me a restrictor and a scope and I'll make a formula out of them.” The variable x is explicit here so that the corresponding variables in different terms will be unified. Thus we get the lexical entries:

d((X*Res) *(X*Sco) *all(X,Res, Sco))

<!-- page 223 -->
--> [every]. d((X*Res) *(X*Sco) “some(X,Res,Sco)) --> [a]; [some]. Sec. 7.3

Quantifiers (Determiners)

209

**Now that we know what a determiner is, what’s an NP? The same thing as a**

determiner, except that the restrictor has been supplied, as in the structure:

NP

(X* Sco) “all (X,dog(X) , Sco)

**ee**

D

**N**

(X*Res) *(X*Sco) “all (X, Res, Sco)

X*dog (X)

every

dog The D and NP are alike except that the NP is only awaiting the scope, not the restrictor. The grammar rule for NP is np ((X*Sco)*Pred) --> d( (X*Res) *(X*Sco) *Pred) , n(X*Res).

or, more concisely,

np(Sem) --> d((X*Res)*Sem), n(X*Res).

There are two VP rules. If the verb has no object, then the semantics of the VP is the same as that of the V:

vp(Sem) --> v(Sem). That gives us [vp meowed] = X*meowed(X) and the like.

**But if there is an object NP within the VP, the verb becomes the scope of that NP,**

thus:

vp(X*Pred) --> v(Y*X*Sco), np ((Y*Sco) *Pred) . This accounts for structures such as:

VP

X*some (Y, cat (Y)

, chased (X,Y) )

**ee**

4

NP

Y*X*chased (X,Y)

(Y*Sco) “some (Y, cat (Y) , Sco)

chased

some cat

**Finally, the S rule takes the NP (which is waiting for a scope) and the VP (which**

is waiting for an argument), and puts them together:

<!-- page 224 -->
s(Sem) --> np((X*Sco)*Sem), vp (X*Sco). This accounts for structures like this:

S

all (X,dog(X),some(Y,cat (Y) ,chased(X,Y)))

**ae**

**NP**

VP (X*Sco) “all (X,dog(X),Sco)

X*some(Y,cat (Y),chased(X,Y))

every dog

chased some cat

**Notice how things have changed: in Chapters 3 and 5 we treated the subject as an**

**argument of the VP, and now we’re doing it the other way around, so that determiners**

— (and NPs containing them) will always have control of the overall semantic structure. That’s enough to handle many common sentence structures. Figure 7.3 shows, in detail, how the structure of Every dog chased some cat is built up. One last problem remains. We can no longer represent proper names as constants; instead, they have to be structures that accept a VP as scope. Instead of

np(fido) --> [fido].

**we have to write**

np((fido*Sco)*Sco) --> [fido].

**Here (fido*Sco) *Sco is an expression that receives X*Sco from the verb phrase,**

**instantiates the lambda variable to fido, and returns Sco with no other changes.**

Exercise 7.3.4.1 Get a parser working that uses the grammar rules introduced in this section, plus other rules as necessary, in order to generate correct semantic representations for the sentences:

<!-- page 225 -->
Fido barked. A dog barked. Every dog barked. Fido chased Felix. A dog chased Felix. Felix chased a cat. Every dog chased Felix. Felix chased every cat. A dog chased every cat. Every dog chased a cat. (A) FOOL (O99 ‘soy’A)SeWOS, (ODS_A) LY (SOU_LA) N

**d**

RY

‘Treop ul ‘amMonys onueules SuIpng ¢"Z aNdIy (((A‘X) peseyp‘ (A) Feo’) oulos ‘ (xX) Hop’xX) TTe 402

auos

paspys

sop

Kana ((A‘X) peseypo ‘ (A) FeO‘A) ouOSs_ xX (09S ‘ (Xx) Hop ’X) TTB, (ODS LX) dA

dN (095 ‘ (A) Je9‘K) eUOS, (ODS A) (A‘X)paeseud XA

(x)6oplx (009 ‘seYu’xX) TTB, (ODS LX) . (Seu_xX) dN

A

**N**

<!-- page 226 -->
d 7.3.5 Scope Ambiguities

The alert reader will have noticed that A dog chased every cat is ambiguous. Here are its two readings:

A dog chased every cat =

(1)

some (X,dog(X),all(Y,cat(Y),chased(X,Y)))

‘There is a dog that chased all cats’

(2)

```prolog
all(¥,cat(Y),some(X,dog(X) , chased (X,Y) ) )
```

‘Each cat was chased by some dog (not necessarily the same dog)’

The first of these

is what our rules so far generate. The second can be derived from the first by a transformation known as QUANTIFIER RAISING:

**some**

(X, dog

(X),all(Y,cat(Y),chased(X,Y))) y all(Y,cat (Y),some(X,dog(X),chased(X,Y)))

or, more generally:

Q1(V1L,R1,Q2(V2,R2,82))

(QUANTIFIER RAISING FROM SCOPE) J Q2(V2,R2,Q1(V1,R1,82)

)

where Q1 and Q2 stand for the quantifiers? and R2 does not contain any variable other than V2.

It’s also possible to raise a quantifier from the restrictor, like this:

Someone who sees every dog laughs. =

(1)

some (X,all(Y,dog(Y),sees(X,¥Y)), laughs (X) )

‘There is someone who sees all the dogs and laughs’

(2)

all (Y,dog(Y),some(X,sees (X,Y), laughs (X)))

‘For each dog, there is someone who sees it and laughs’

This time the general schema is:

Q1(V1,02(V2,R2,S2),81)

(QUANTIFIER RAISING FROM RESTRICTOR) 4 Q2 (V2,R2,Q1(V1,R1,S2))

<!-- page 227 -->
30f course real Prolog does not allow a variable in this position.

Sec. 7.3

Quantifiers (Determiners)

213 Actually these two schemas are instances of a more general pattern. In fact almost any

quantifier anywhere within the scope or restrictor—no matter how deep down—can be raised to have scope over the entire sentence. Here’s how to do it:

e Pick the quantified structure to be raised; call it

Q(V,R,S).

e Replace Q(V,R,S) with S. Call the resulting formula F.

e The result of raising is then Q(V,R,F). That describes how to raise one quantifier from anywhere in the sentence. In real life, more than one quantifier can be moved, because quantifier raising is recursive. There is considerable debate as to how far the recursion should be allowed to go.

In principle, a sentence with n quantifiers could have n! (1-factorial) readings. To see that this is so, consider that you can choose any of the n quantifiers to be raised to the topmost position. Having done this, you can then raise any of the n — 1 quantifiers not yet raised; then any of the n — 2 remaining, and so on, yielding n x (n—1) x (n—2) x--alternatives.

In practice, we don’t get this many, for several reasons. Some readings are blocked because they leave variables unbound (that is, they put variables outside the scope or restrictor of the quantifiers that bind them). Other readings are logically equivalent (for example, raising one all past another all has no effect on the truth conditions of the sentence). Still others are blocked by structural principles. For example, Hobbs and Shieber (1987) point out that in English, it is not permissible to take a quantifier from outside an NP and put it between two quantifiers that originated in that NP.

Further, there are differences in the ease with which various quantifiers can be raised. Specifically, each almost always raises; some, all, and every can raise but need not do so; any tends not to raise; and numerals generally do not raise.

The especially alert reader will now notice that quantifier raising is what we’ve been doing all along. The whole point of Figures 7.2 and 7.3 was that quantifiers get raised out of individual NPs so that they have scope over the complete sentence. So it makes sense to build an initial semantic representation with the quantifiers still in the NPs, and then require that they be raised far enough to give well-formed logical formulas, with further raising then being optional.

That is in fact now the standard approach to quantifier scoping (Cooper 1983, Hornstein 1984, Chierchia and McConnell-Ginet 1990 chapter 3). Hobbs and Shieber (1987) give an algorithm that raises quantifiers from NP positions, generating all and only the scopings that are structurally possible in English. Exercise 7.3.5.1

Give formulas for the two readings of Every man loves a woman.

Exercise 7.3.5.2

Explain why quantifier raising has no effect on the truth conditions of Every dog chased

<!-- page 228 -->
every cat. Exercise 7.3.5.3

Express the sentence

Everyone who hates a dog loves two cats.

as a formula. Derive two more formulas from it (by raising from the scope and from the

restrictor respectively) and explain the meaning of the sentence that corresponds to each of

your three formulas.

Exercise 7.3.5.4

Implement quantifier raising from scope and from restrictor. That is, implement a predicate

raise_quantifier/2 which, when given a formula, will perform raising from the

scope or from the restrictor, whichever is possible, and will also have a solution in which

no raising is performed. For example:

?- raise_quantifier(some(X,dog(X),all(Y,cat(Y), chased (X,Y)),What).

What = all (Y,cat(Y),some(X,dog(X),chased(X,Y))) ;

What = some(X,dog(X),all(Y,cat(Y¥),chased(X,Y)),What).

When given the formula from the previous exercise, raise_quantifier should get all

three readings. You need not check whether variables are left unbound (in these examples

they won’t be).

Exercise 7.3.5.5

Define a predicate interpret /2 that parses a sentence using your parser, then optionally

applies quantifier raising, so that if you give it [every, dog, chased, a,cat] you get

two alternative formulas.

**7.4 QUESTION ANSWERING**

**7.4.1 Simple Yes/No Questions**

**We have now implemented enough semantics to be able to answer, from a knowledge**

base, plain-English questions such as:

**Did Fido chase Felix?**

**Did every cat meow?**

**Did every dog chase a cat?**

**All we need to do is change the grammar rules so that questions can be parsed. To do**

**this, we replace the S rule**

<!-- page 229 -->
s(Sem) --> np((X*Sco)*Sem), vp(X*Sco). with one appropriate for questions,

s(Sem) --> [did], np((X*Sco)*Sem), vp(X*Sco).

and we add the “plain” forms of the verbs (without final -ed), thus:

v (X*meowed

(X) )

--> [meowed]; [meow]. v(Y°X*chased(X,Y)) --> [chased]; [chase]. v(Y°X*saw(X,Y))

--> [saw]; [see].

**Now Did every dog chase a cat? translates directly into the query**

?- all(X,dog(X),some(Y,cat (Y),chased(X,Y)).

which can be answered from a suitable knowledge base.

Exercise 7.4.1.1 Using the grammar rules presented so far, the definitions of some and all, and the knowledge base

cat (felix).

```prolog
cat(leo).
```

dog(fido).

dog (bucephalus).

( saw(felix,fido). saw(leo, felix). chased(fido, felix). chased (bucephalus, leo).

write a Prolog program that will accept and answer the questions

Did Leo see Felix?

Did every cat see a dog?

Did a cat see a dog?

Did every dog chase a cat?

and others of similar form. You need not handle scope ambiguities.

7.4.2 Getting a List of Solutions

To go further and answer questions that contain which or how many, we will need a way to get a list of solutions to a Prolog query. Two approaches are possible. The built-in predicate setof/3 returns a list of all solutions to a query. More precisely,

?- setof(X,Goal,L).

