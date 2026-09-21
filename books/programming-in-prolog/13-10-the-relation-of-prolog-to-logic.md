# 10 The Relation of Prolog to Logic

<!-- page 251 -->
The programming language Prolog was invented by Alain Colmerauer and his associates around 1970. It was the first attempt at the design of a practical programming language that would enable a programmer to specify tasks in logic, instead of in terms of conventional programming constructs about *what* the machine should do *when.* This motivation explains the name of the language, for "Prolog" means Programming in *Logic.*

In this book we have emphasised mainly how one can use Prolog as a tool for doing practical tasks, and we have not discussed the ways in which Prolog is a step towards the ultimate goal of a "logic programming" system. In this chapter, we intend to redress the balance by considering briefly how Prolog is related to logic and the extent to which Prolog programming is really like "programming in logic".

## 10.1 Brief Introduction to Predicate Calculus

If we wish to discuss how Prolog is related to logic, we must first establish what we mean by logic. Logic was originally devised as a way of representing the form of arguments, so that it would be possible to check in a formal way whether or not they are valid. Thus we can use logic to express propositions, the relations between propositions and how one can validly *infer* some propositions from others. The particular form of logic that we will be talking about here is called the Predicate Calculus. We will only be able to say a few words about it here. There are scores of good basic introductions to logic you can turn to for background reading.

<!-- page 252 -->
If we wish to express propositions about the world, we must be able to describe the objects that are involved in them. In Predicate Calculus, we represent objects by *terms.* A term is of one of the following forms:

- A *constant symbol.* This is a symbol that stands for a single individual or concept. We can think of this as a Prolog atom, and we will use the Prolog syntax. So `greek, agatha,` and `peace` are constant symbols.

- A *variable symbol.* This is a symbol that we may want to stand for different individuals at different times. Variables are really only introduced in conjunction with quantifiers, which are discussed below. We can think of them as Prolog variables and will use the Prolog syntax. Thus X, Man, and `Greek` are variable symbols.

- A *compound term.* A compound term consists of a *function symbol,* together with an ordered set of terms as its *arguments.* The idea is that the compound term represents some individual that depends on the individuals represented by the arguments. The function symbol represents how the first depends on the second. For instance, we could have a function symbol standing for the notion of "distance" and two arguments. In this case, the compound term stands for the distance between the objects represented by the arguments. We can think of a compound term as a Prolog structure with the function symbol as the functor. We will write Predicate Calculus compound terms using the Prolog syntax, so that, for instance, wife(henry) might mean Henry's wife, distance(pointl, X) might mean the distance between some particular point and some other place to be specified, and classes(mary, dayafter(W)) might mean the classes that Mary teaches on the day after some day W to be specified. Thus in Predicate Calculus the ways of representing objects are just like the ways available in Prolog. In order to express propositions about objects we must be able to express relationships between objects. We do this with *predicate symbols.* An *atomic proposition* consists of a predicate symbol, together with an ordered sequence of terms as its *ar-* *guments.* This is just like the kind of thing that can appear as a Prolog goal. So, for example, the following are atomic propositions:

```prolog
human(mary)
likes(man, wine)
owns(X, donkey(X))
```

<!-- page 253 -->
In Prolog, a structure can serve either as a goal, or as an argument to another structure, or both. This is not the case in Predicate Calculus, where a rigid separation is made between function symbols, which are functors that are used to construct arguments, and predicate symbols, which are functors that are used to construct propositions. We can make compound propositions from atomic propositions in various ways. It is here that we begin to find things that do not have direct analogues in Prolog. There are several ways in which we can make more complicated propositions out of simpler ones. First, we can use the *logical connectives.* These are ways of expressing the familiar notions "not", "and", "or", "implies" and "is equivalent to". The following table summarises the connectives and their meanings. In this summary, *a* and *p* are meant to represent any propositions. We give both the traditional Predicate Calculus (PC) syntax and the syntax that we shall use in programs because it is easy to type on an ordinary computer.

Connective

PC

Computer

Meaning

~ a

"not a"

Negation

-> a.

Conjunction a A P

Disjunction

a V j ?

Implication *a D P*

Equivalence *a = [3*

a 8*,p*

"a and *P"*

*aUP*

"*a* or *p"*

*a->p*

*"a* implies *P"*

*a <-> P*

*"a* is equivalent to /?'

Thus, for example,

```prolog
man(fred) # woman(fred)
```

could be used to represent the proposition that Fred is a man or Fred is a woman. The expression

```prolog
man(john) -> human(john)
```

might represent the proposition that John's being a man implies his being human (if John is a man then he is human). The notions of implication and equivalence are sometimes a little hard to grasp at first. We say that a implies [i if, whenever a is true so is *p.* We say that *a* is equivalent to *p* if *a* is true in exacdy those circumstances when *P* is true. In fact, these notions can be defined in terms of "and", "or", and "not", for:

*a*-> *P* means the same as

*(~a)* # *P*

*a* <-> *P* means the same as

*(a & P) #* (~a *& ~p)*

*a* <-> *P* also means the same as *(a -> P) & (p* -> a).

<!-- page 254 -->
So far, we have not made it clear what it means when variables appear inside a proposition. In fact, the meaning is only defined when such variables are introduced by quantifiers. Quantifiers provide a means of talking about sets of individuals and what is true of them. Predicate Calculus provides two quantifiers. If v represents any variable and *P* any proposition, we can summarise them as follows:

PC

Computer Meaning

V *v.P* aLl(v,/))

*"P* is true whatever v stands for."

3 *v.P* exists(v,P) "There is something that v can

stand for such that *P* is true."

The first of these is called the *universal quantifier* because it talks about everything in the Universe ("for all v,..."). The second is called the *existential quantifier* because it talks about the existence of some object(s) ("there exists v such that ..."). As examples of uses of the quantifiers, for instance,

```prolog
all(X, man(X) -> human(X) )
```

means that, whatever X we choose, if X is a man, then X is a human. We can read this as, "for all X, if X is a man, then X is human." Or, in English, simply "every man is human". Similarly,

```prolog
exists(Z, father(john, Z) & female(Z))
```

means that there is something that Z can stand for such that John is the father of Z and Z is female. We can read it as "there exists a Z such that John is the father of Z and Z is female", or in English, simply "John has a daughter". Notice that this statement does not rule out the possibility that John has more than one daughter. Here are some more complicated Predicate Calculus formulae for your amusement:

```prolog
all(X, animal(X) -> exists(Y, motherof(X, Y)) )
all(X, pcform(X) <-> (atomic(X) # compound(X))).
```

## 10.2 Clausal Form

<!-- page 255 -->
As we saw in the last section, Predicate Calculus formulae expressed in terms of -> (implication) and <-> (equivalence) can be rewritten in terms of & (conjunction), # (disjunction) and ~ (negation). In fact, there are many more identities of this form, and we would not sacrifice any expressive power if we were to completely avoid using #, ->, <->, and exists(X,P), for instance. As a result of the redundancy, there are many ways of writing down the same proposition. If we wish to carry out formal manipulations on Predicate Calculus formulae, this turns out to be very inconvenient. It is much nicer if everything we want to say can only be expressed in one way. So we will now consider how a Predicate Calculus proposition can be translated into a special form, *clausal form,* where there are fewer different ways of saying the same thing. In fact, it will turn out that a Predicate Calculus proposition in clausal form is very much like a set of Prolog clauses. So an investigation of clausal form is essential for an understanding of the relation between Prolog and logic.

In Appendix B we give a Prolog program that automatically translates a Predicate Calculus formula into clausal form. There is one difference between our discussion here and the actual program in Appendix B. To make certain manipulations easier, PC variables are represented as atoms when given as input to the program. Thus, when using the program in Appendix B to process, for example, the formula

```prolog
(person(X) # ~mother(X, Y)) # -person(Y),
```

it will be necesary to write this as

```prolog
(person(x) # ~mother(x, y)) # ~person(y).
```

The conversion of a Predicate Calculus formula into normal form has six main stages. *Stage 1. Removing Implications* We start by replacing occurrences of -> and <-> in accordance with the definitions given in Section 10.1. As a result of this definition, we would expect:

```prolog
all(X, man(X) -> human(X) )
```

to be transformed to:

```prolog
all(X, ~man(X)) # human(X)).
```

*Stage 2. Moving negation inwards* This stage is involved with cases where

is applied to a formula that is not atomic. If such a case is detected, an appropriate rewrite is made. Thus, for instance,

```prolog
~(human(caesar) & living(caesar))
```

is transformed to:

```prolog
~human(caesar) # ~living(caesar)
```

Also,

```prolog
~all(Y, person(Y))
```

is transformed to:

```prolog
exists(Y, ~person(Y)).
```

The validity of this stage results from the following identities:

~(a & /j)

means the same as (~a) # ~8)

~exists(v,P) means the same as all(v, P)

~all(v,P)

means the same as exists(v,7>). After Stage 2, negation will only be applied directly to atomic formulae. We call an atomic proposition, or an atomic proposition preceded by a

<!-- page 256 -->
a *literal.* The next few stages will treat literals as single items, and the significance of which literals are negated will only be important at the end. *Stage 3. Skolemising* The next stage involves removing the existential quantifiers. This is done by introducing new constant symbols, *Skolem constants*, in the place of the variables introduced by the existential quantifiers. Instead of saying that there exists an object with a certain set of properties, one can create a name for one such object and simply say that it has the properties. This is the motivation behind introducing Skolem constants. Skolemising does more damage to the logical properties of a formula than the other transformations we discuss. Nevertheless, it has the following important property. There is an interpretation for the symbols of a formula that makes the formula true if and only if there is an interpretation for the Skolemised version of the formula. For our purposes, this form of equivalence is enough. Thus, for example,

```prolog
exists(X, female(X) & motherof(X, eve) )
```

is changed by Skolemisation to

```prolog
female(gl97) & motherof(gl97, eve)
```

where gl97 is some new constant not used elsewhere. Constant gl97 represents some female whose mother is Eve. It is important that we use a different symbol from any used previously, because

```prolog
exists(X, female(X) & motherof(X, eve) )
```

is not saying that some particular person is Eve's daughter, but only that there is such a person. It may turn out that gl97 will correspond to the same person as some other constant symbol, but that is extra information that is not conveyed by this proposition.

When there are universal quantifiers in a formula, Skolemisation is not quite so simple. For instance, if we Skolemised

```prolog
all(X, human(X) -> exists(Y, motherof(X, Y ) ) )
```

("every human has a mother") to

```prolog
all(X, human(X) -> motherof(X, g2) )
```

we would be saying that every human has the *same* mother — the thing denoted by g2. When there are variables introduced by universal quantifiers, Skolemisation must instead introduce function symbols, to express how what exists *depends* on what the variables are chosen to stand for. Thus the above example should Skolemise to

```prolog
all(X, human(X) -> motherof(X, g2(X)) )
```

<!-- page 257 -->
In this case, the function symbol g2 corresponds to the function in the world that, given any person, returns as its value the mother of that person. *Stage 4. Moving universal quantifiers outwards* This stage is very simple. We just move any universal quantifiers to the outside of the formula. This does not affect the meaning. As an example,

```prolog
all(X, man(X) -> all(Y, woman(Y) -> likes(X, Y)))
```

is transformed to

```prolog
all(X, all(Y, man(X) -> (woman(Y) -> likes(X, Y)))).
```

Since every variable in the formula is now introduced by a universal quantifier at the outside of the formula, the quantifiers themselves no longer provide any extra information. So we can abbreviate the formula by simply leaving the quantifiers out. We just need to remember that every variable is introduced by an implicit quantifier that we have left out. Thus we can now represent:

```prolog
all(X, alive(X) # dead(X))
    & all(Y, likes(mary, Y) # impure(Y))
```

as:

```prolog
(alive(X) # dead(X)) & (likes(mary, Y) # impure(Y)).
```

The formula means that, whatever `X` and `Y` we choose, either `X` is alive or `X` is dead, and either Mary likes `Y` or `Y` is impure. *Stage 5. Distributing "&" over "#"* At this stage, our original Predicate Calculus formula has changed a lot. We no longer have any explicit quantifiers, and the only connectives left are & and # (apart from where literals are negated). We now put this in a special normal form, *conjunctive* *normal form,* where conjunctions no longer appear inside disjunctions. Thus we can convert the whole formula into a bundle of &'s, where the things joined together are either literals or literals joined by #'s. Suppose *A, B* and C stand for literals. We can make use of the following identities:

*(A&B) ff C* is equivalent to *(A* # C) & *(B ff C)*

*(AffB)&C*

is equivalent to (A & *C) ft (B* & C) As an example of what happens, the formula:

holiday(X) #

<!-- page 258 -->
(work(chris, X) & (angry(chris) # sad(chris))) (For every X, either X is a holiday, or, both Chris works on X and Chris is angry or sad) is equivalent to:

```prolog
(holiday(X) # work(chris, X)) &
    (holiday(X) # (angry(chris) # sad(chris)))
```

(For every `X,` first, `X` is a holiday or Chris works on `X,` and second, either `X` is a holiday or Chris is angry or sad). *Stage 6. Putting into clauses* The formula we have now is in general made up of a collection of &'s relating things which are either literals or composed of literals by #'s. Let us look first at the top level of this, not looking in detail at the #'s. We might have something like:

(A & *B)* & (C & (D & *E))* where the letters stand for complex propositions, but having no &'s in them. Now all this nesting of structure is unnecessary, because all the propositions

(A & *B) & (C & (D & E))*

*A & ((B & C) & (D & E))*

(A&B)& ((C *& D) & E)* mean the same thing. Although structurally the formulae are different, they have the same meaning. This is because, if I assert that some set of propositions are all true, then it does not matter how I group them together when I do so. It does not matter, for instance, whether I say "*A* is true, and so are *B* and *C* or "*A* and *B* are true, and so is C". So the bracketing is unnecessary to the meaning. We can just say (informally):

*A&B&C&D&E.* Secondly, the order in which we write these formulae also does not matter. It does not matter whether I say "A is true and so is *B"* or *"B* is true and so is A". They both mean the same. Finally, we do not really need to specify the &'s between the formulas, because we know in advance that the top level of the formula is made up with &'s. So, really, we can be much more concise about the import of the formula we are given just by saying that it consists of the *set* {A, *B, C, D, E}.* By calling this a set, we are saying that the order does not matter. The set *{A, B, C, D, E]* is exactly the same as *{B,* A, C, *E, D}, {E, D, B,* C, A}, and so on. The formulae that end up in this set, when we convert a formula to Clausal form, are called *clauses.* So any Predicate Calculus formula is equivalent (in some sense) to a set of clauses.

Let us now look in more detail at what these clauses are actually like. We said that they are made up of literals joined together by disjunctions. So in general, if the letters *V* through Z stand for literals, a clause will be something like:

<!-- page 259 -->
*((VUW)UX)U(Y#Z).* Now we can do the same trick that we played with the top level of the formula. Once o aain the bracketing is irrelevant to the meaning, and the order is also unimportant. So we can simply say that the clause is the set of literals { V, *W, X, Y, Z}* (implicitly disjoined).

Now our original formula has reached clausal form. Moreover the rules used for this have not altered whether there is an interpretation that makes it true or not. The clausal form consists of a collection of clauses, each of which is a collection of literals. A literal is either an atomic formula or a negated atomic formula. This form is quite concise, since we have left out things like implicit conjunctions, disjunctions and universal quantifiers. We must obviously remember the conventions about where these have been missed out when we look to see what something in clausal form means.

Let us look at some formulae (as they would be produced by Stage 5) to see what they look like in clausal form. First of all, look at the example used before:

```prolog
(holiday(X) # work(chris, X)) &
    (holiday(X) # (angry(chris) # sad(chris))).
```

This gives rise to two clauses. The first contains the literals:

```prolog
holiday(X), work(chris, X)
```

and the second contains the literals:

```prolog
hotiday(X), angry(chris), sad(chris).
```

As another example, the formula:

```prolog
(person(adam) & person(eve)) &
    ((person(X) # ~mother(X, Y)) # -person(Y))
```

gives rise to three clauses. Two of them contain one literal each,

```prolog
person(adam)
```

and

```prolog
person(eve).
```

The other one has three literals:

```prolog
person(X), ~mother(X, Y), -person(Y).
```

To bring this section to a close, let us just consider one more example, and the various stages as it is translated into clausal form. We start with the formula:

```prolog
all(X, all(Y, person(Y) -> respect(Y, X)) -> king(X))
```

<!-- page 260 -->
which says that, if everybody respects somebody then that person is a king. That is, for every X, if every Y that is a person respects X, then X is a king. When we remove implications (Stage 1) we get:

```prolog
all(X, ~(all(Y, -person(Y) # respects(Y, X))) ft king(X))
```

Moving negation inwards (Stage 2) leads us to:

```prolog
all(X, exists (Y, person(Y) & ~respects(Y, X)) # king(X))
```

Next, Skolemising (Stage 3) translates this to:

```prolog
all(X, (person(fl(X)) & ~respects(fl(X), X)) # king(X))
```

where fl is a Skolem function. Now comes the stage of removing universal quantifiers (Stage 4), which leads to:

(personal(X)) & ~respects(fl(X), X)) `ft` king(X). We now put this into conjunctive normal form (Stage 5), where conjunctions do not appear within disjunctions, thus:

(person(fl(X)) # king(X)) & (~respects(fl(X), X) # king(X)).

This amounts (stage 6) to two clauses. The first has the two literals:

person (fl(X))

```prolog
king(X)
```

and the second has the literals:

~respects(fl(X), X)

```prolog
king(X) .
```

## 10.3 A Notation for Clauses

We need a way of writing something down in clausal form, and this is what we will now present. First of all, something in clausal form is a collection of clauses. As good a convention as any is to write down the clauses one after the other, remembering that the order is actually irrelevant. Within a clause there is a collection of literals, some negated and some not negated. We will adopt the convention of writing the unnegated literals first and the negated ones second. The two groups will be separated by the sign ":-". The unnegated literals will be written separated by ;'s (remembering, of course, that the order is not important), and the negated literals will be written without their ~'s and separated by commas. Finally, a clause will be terminated by a full stop. In this notation, a clause with the `n` negated literals `~Qi, ~Q2, • • ~Qn` and the `m` unnegated literals Pi, `P?,`...,

`P m` would be written as:

```prolog
PuPi)
      . • -; Pm
               Qh Qh • • •/ Qn-
```

<!-- page 261 -->
Although we have introduced our convention for writing out clauses as something arbitrary, it actually has some mnemonic significance. If we write a clause including the disjunctions, with the negated literals separated from the unnegated ones, it will look something like:

```prolog
(Pi # P 2 # • • • # Pm) # (~Ql # ~Q2 # • • • # ~Qn)
```

which is equivalent to:

```prolog
(Pi # P 2 # • • • # P m ) M Q i
                                &Q2&...&Qn)
```

which is equivalent to:

```prolog
(Ql &
        & . . . & Qm) -> (Pi # P 2 ft • • • # Pm)
```

If we write "," for "and", and ";" for "or", and ":-" for "is implied by" (following the Prolog convention), the clause naturally comes out as:

```prolog
Pit P2i • • Pm. > Qlt Q2i • •
                            Qn-
```

Given these conventions, the formula about Adam and Eve:

```prolog
(person(adam) & person(eve)) &
    ((person(X) # ~mother(X, Y)) # -person(Y))
```

comes out as:

```prolog
person(adam):- .
person(eve) : - .
person(X) :- mother(X, Y), person(Y).
```

This is beginning to look rather familiar. This really looks like a Prolog definition for what it is to be a person. However, other formulae give rise to more puzzling things. The example about holidays ends up as:

```prolog
holiday(X); work(chris, X) : - .
holiday(X); angry(chris); sad(chris) : - .
```

which does not so obviously correspond to something in Prolog. We shall see why this is in a later section.

In Appendix B we present a Prolog program to convert clauses to this special notation. Written according to our convention, the clauses produced at the end of the last section come out as:

```prolog
person(fl(X)); king(X):-.
king(X) :- respects(fl(X), X).
```

<!-- page 262 -->
## 10.4 Resolution and Proving Theorems

```prolog
Now that we have got a way of putting our Predicate Calculus formulas into a nice
tidy form, we should consider what we can do with them. An obvious thing to in-
vestigate, when we have a collection of propositions, is whether anything interesting
follows from those propositions. That is, we may investigate what consequences the
propositions have. We shall call those propositions that we are taking as true for the
sake of argument our axioms or hypotheses, and those propositions that we find to
follow from them our theorems. This is consistent with the terminology used to de-
scribe one view of Mathematics: a view which sees the work of a mathematician
as involving the derivation of more and more interesting theorems from some exact
axiomatisation of what sets and numbers are. In this section, we will look briefly at
the activity of deriving interesting consequences from our given propositions, that is,
we will look at the activity of theorem proving.
    There was a great deal of activity in the 1960's as people began to investigate the
possibility that digital computers could be programmed to prove theorems automati-
cally. It was this area of scientific endeavour, which is still progressing healthily, that
gave rise to the ideas behind Prolog. One of the fundamental breakthroughs made at
this time was the discovery of the resolution principle by J. Alan Robinson, and its
```

`application to mechanical theorem proving. Resolution is a` *rule of inference.* `That is,`

```prolog
it tells us how one proposition can follow from others. Using the resolution principle,
we can prove theorems in a purely mechanical way from our axioms. We only have
to decide which propositions to apply it to, and valid conclusions will be produced
automatically.
    Resolution is designed to work with formula; in clausal form. Given two clauses
related in an appropriate way, it will generate a new clause that is a consequence of
them. The basic idea is that if the same atomic formula appears both on the left hand
side of one clause and the right hand side of another, then the clause obtained by
fitting together the two clauses, missing out the duplicated formula, follows from
them. For example:
```

*From:*

```prolog
sad(chris); angry(chris) :-
    workday(today), raining(today).
```

*and:*

```prolog
unpleasant(chris) :- angry(chris), tired(chris).
```

*follows:*

```prolog
sad(chris); unpleasant(chris) :-
    workday(today), raining(today), tired(chris).
```

<!-- page 263 -->
```prolog
In English, if today is a workday and it is raining, then Chris is sad or angry. Also,
if Chris is angry and tired, he is unpleasant. Therefore, if today is a workday, it is
raining and Chris is tired, then Chris is sad or unpleasant.
    In fact, we have over-simplified in two ways here. Firstly, things are actually
more complicated when the clauses contain variables. Now the two atomic formulae
do not have to be identical, they only have to "match". Also, the clause that follows
from the first two is obtained from the two fitted together (with the duplicated for-
mula removed) by an extra operation. This operation involves "instantiating" the
variables just enough so that the two matching formulae are identical. In Prolog
terms, if we had the two clauses as structures and matched together the appropriate
substructures, the result of fitting them together afterwards would be the representa-
tion of the new clause. Our second simplification is that in general resolution one is
allowed to match several literals on a right hand side against several on a left hand
side. Here, we shall only consider examples where one literal is chosen from each
clause.
Let us look at one example of resolution involving variables:
    (1)
              person(fl(X»; king(X) :-.
    (2)
              king(Y) :- respects (fl(Y), Y).
    (3)
              respects(Z, arthur) :- person(Z).
The first two of these are what we obtained as the clausal form of our formula saying
"if every person respects somebody then that person is a king". We have renamed
the variables for ease of explanation. The third expresses the proposition that every
person respects Arthur. Resolving (2) with (3) (matching the two respects literals),
gives us:
    (4)
              king(arthur):- person(fl(arthur)).
(Y in (2) matched with arthur in (3), and Z in (3) matched with fl(Y) in (2)). We can
now resolve (1) with (4), to give:
    (5)
              king(arthur); king(arthur) :-.
This is equivalent to the fact that Arthur is a king.
    In the formal definition of resolution, the process of "matching" that we have re-
ferred to informally is called unification. Intuitively, some atomic formulae are unifi-
able if, as Prolog structures, they can be matched together. Actually, we will see in
a later section that the matching in most Prolog implementations is not exactly the
same as unification.
    How can we use resolution to try and prove a specific thing? One possibility
is that we can keep on applying resolution steps to our hypotheses and look to see
if what we want appears. Unfortunately, we cannot guarantee that this will happen,
```

<!-- page 264 -->
```prolog
even if the proposition we are interested in really does follow from the hypotheses.
In the above example, for instance, there is no way of deriving the simple clause
king(arthur) from the clauses given, even though it is clearly a consequence. So must
we conclude that resolution is not powerful enough for what we want? Fortunately,
the answer is "no", for we can rephrase our aims in such a way that resolution is
guaranteed to be able to solve our problem if it is possible.
    The important formal property that Resolution has is that of being refutation
complete. This means that, if a set of clauses are inconsistent then Resolution will be
able to derive from them the empty clause:
Also, since Resolution is correct, it will only be able to derive the empty clause in
this circumstance. A set of formulae is inconsistent if there is no possible interpre-
tation for the predicates, constant symbols and function symbols that makes them
simultaneously express true propositions. The empty clause is the logical expression
of falsity — it represents a proposition that cannot possibly be true. So Resolution
can be guaranteed to tell us when our formulae are inconsistent by deriving this clear
expression of contradiction.
How can these particular properties of resolution help us? Well, it is a fact that
   If the formulae {Ai, A2,...,
                           An] are consistent, then formula B is a conse-
    quence of formulae {Ai, A2, • •., An} exactly when the formulae {Ai, A2,
    ..., An, ->£?} are inconsistent.
So, if our hypotheses are consistent, we just need to add to them the clauses for the
negation of what we want to prove. Resolution will derive the empty clause exactly
when the proposition follows from the hypotheses. We call the clauses that we add
to the hypotheses the goal statements. Note that the goal statements do not look in
any way different from the hypotheses — all of them are just clauses. So, if we are
presented with a set of clauses Ai, A2,...,
                                    An, and are told that the task is to show
them to be inconsistent, we cannot actually tell whether this is in order to show that:
    -•Ai follows from A2,...,
                          An, or that
```

`~`*i A*`2 follows from` *A\, A :i ,...,*

```prolog
                              An, or that
    -i A3 follows from Ai, A2, A4,...,
                                  An,
    ... and so forth.
It is a matter of emphasis which statements we actually consider to be the goal state-
ments, because in a Resolution system all these tasks are equivalent.
    In our example about Arthur being king, it is easy to see how we can obtain the
empty clause if we add the goal statement:
    (6)
              :- king(arthur).
```

<!-- page 265 -->
```prolog
(this is the clause for ~king(arthur)). We saw before how the clause
    (5)
              king(arthur); king(arthur) : - .
was derived from the hypotheses. Resolving (5) with (6) (matching either of the
atomic formulae in (5)), we obtain:
    (7)
              king(arthur) :-.
Finally, resolving (6) with (7) gives us:
So resolution has shown that as a consequence, Arthur is a king.
    The completeness of Resolution is a nice mathematical property. It means that if
some fact follows from our hypotheses, we should be able to prove its truth (by show-
ing the inconsistency of its negation and the hypotheses) using Resolution. However,
when we say that Resolution will be able to derive the empty clause, we mean that
there is a sequence of Resolution steps, each involving axioms or clauses derived in
previous steps, which ends in the production of a clause with no literals. The only
trouble is to find the sequence of steps. For, although Resolution tells us how to de-
rive a consequence from two clauses, it does not tell us either how to decide which
clauses to look at next or which literals to "match". Usually, if we have a large num-
ber of hypotheses, there will be many possibilities for each. Moreover, each time we
derive a new clause, it too becomes a candidate to take part in further resolutions.
Most of the possibilities will be irrelevant for the task at hand, and if we are not care-
ful we may spend so much time on irrelevances that we will never find the solution
path.
    Many refinements of the original resolution principle have been proposed to
address these issues. The next section considers some of these.
```

## 10.5 Horn Clauses

```prolog
We shall look now at refinements designed for resolution when all the clauses are
of a certain kind — when they are Horn clauses. A Horn clause is a clause with
at most one unnegated literal. It turns out that, if we are using a clausal theorem
prover to determine the values of computable functions, it is only strictly necessary
to use Horn clauses. Because resolution with Horn clauses is also relatively simple,
they are an obvious choice as the basis of a theorem prover which provides a practical
programming system. Let us consider briefly what Resolution theorem proving looks
like if we restrict ourselves to Horn Clauses.
    First, there are two kinds of Horn Clauses: those with one unnegated literal and
those with none. Let us call these two types headed and headless Horn Clauses. The
```

<!-- page 266 -->
```prolog
two types are exemplified by the following (remember that we write the unnegated
literals on the left hand side of the ":-"):
    bachelor(X) :- male(X), unmarried(X).
    :- bachelor(X).
In fact, when we consider sets of Horn Clauses (including goal statements), we need
only consider those sets where all but one of the clauses are headed. That is, any
soluble problem (theorem-proving task) that can be expressed in Horn Clauses can
be expressed in such a way that:
•
   There is one headless clause;
•
   All the rest of the clauses are headed.
Since it is arbitrary how we decide which clauses are actually the goals, we can
decide to view the headless clause as the goal and the other clauses as the hypotheses.
This has a certain naturalness.
    Why do we only have to consider collections of Horn Clauses that conform to
this pattern? First, it is easy to see that at least one headless clause must be present
for a problem to be soluble. This is because the result of resolving two headed Horn
Clauses is itself a headed Horn Clause. So, if all the clauses are headed, we will only
be able to derive other headed clauses. Since the empty clause is not headed, we will
not be able to derive it. The second claim — that only one headless clause is needed
— is slightly more difficult to justify. However, it turns out that, if there are several
headless clauses among our axioms, any Resolution proof of a new clause can be
converted into a proof using at most one of them. Therefore, if the empty clause
follows from the axioms, it follows from the headed ones together with at most one
of the headless ones.
```

## 10.6 Prolog

```prolog
Let us now summarise how Prolog fits into this scheme of things. As we saw before,
some of our formulae turned into clauses that looked remarkably like Prolog clauses,
whereas others looked somewhat peculiar. Those that turned into Prolog-like clauses
were, in fact, those whose translation was into Horn clauses. When we write a Horn
clause according to our conventions, at most one atomic formula appears on the left
of the ":-". In general, clauses may have several such formulae (these correspond to
the literals which are unnegated atomic formulae). In Prolog, we can express directly
only the Horn clauses. The clauses of a Prolog program correspond to headed Horn
clauses in a certain kind of theorem prover. What in Prolog corresponds to the goal
statement? Quite simply, the Prolog question:
    ?- Ai, A2,
                   An.
```

<!-- page 267 -->
```prolog
corresponds exactly to the headless Horn Clause:
```

*:- Ai, A 2 , ...,*

*A n .*

```prolog
We saw in the last section that, for any problem we want to solve with Horn Clauses,
it suffices to have exactly one headless clause. This corresponds to the situation in
Prolog, where all the clauses of the "program" are headed and only one (headless)
goal is considered at any one time.
    A Prolog system is based on a resolution theorem prover for Horn clauses. The
```

`particular strategy that it uses is a form of` *linear input resolution.* `When this strategy`

```prolog
is used, the choice of what to resolve with what at any time is restricted as follows.
We start with the goal statement and resolve it with one of the hypotheses to give
a new clause. Then we resolve that with one of the hypotheses to give another new
clause. Then we resolve that with one of the hypotheses, and so on. At each stage, we
resolve the clause last obtained with one of the original hypotheses. At no point do
we either use a clause that has been derived previously or resolve together two of the
hypotheses. In Prolog terms, we can see the latest derived clause as the conjunction
of goals yet to be satisfied. This starts off as the question, and hopefully ends up as
the empty clause. At each stage, we find a clause whose head matches one of the
goals, instantiate variables as necessary, remove the goal that matched and then add
the body of the instantiated clause to the goals to be satisfied. Thus, for instance, we
can go from:
    :- mother(john, X), mother(X, Y).
and
    mother(U, V) :- parent(U, V), female(V).
to:
    :- parent(john, X), female(X), mother(X, Y).
In fact, Prolog's proof strategy is even more restricted than general linear input res-
olution. In this example, we decided to match the first of the literals in the goal
clause, but we could equally well have matched the second. In Prolog, the literal to
be matched is always selected in the same way: it is always the first one in the goal
clause. In addition, the new goals derived from the use of a clause are placed at the
front of the goal clause. This just means that Prolog finishes satisfying a subgoal
before it goes on to try anything else.
    So much for what happens when Prolog has decided what clause to match
against the first goal. But how does it organise the investigation of alternative clauses
to satisfy the same goal? Basically, Prolog adopts a depth-first strategy, rather than a
breadth-first one. This means that it only considers one alternative at a time, follow-
ing up the implications under the assumption that the choice is correct. For each goal,
```

<!-- page 268 -->
```prolog
it chooses the clauses in a fixed order, and it only comes to consider the later ones
if all the earlier ones have failed to lead to solutions. The alternative strategy would
be one where the system kept track of alternative solution paths simultaneously. It
would then move around from one alternative to another, following it up for a short
time and then going on to something else. This latter, breadth-first, strategy has the
advantage that, if a solution exists, it will be found. The Prolog depth-first strategy
can get into "loops" and hence never follow up some of the alternatives. On the other
hand, it is much simpler and less space-consuming to implement on a conventional
computer.
    Finally, a note about how Prolog matching sometimes differs from the unifica-
tion used in Resolution. Most Prolog systems will allow you to satisfy goals like:
    equal(X, X).
    ?- equal(foo(Y), Y).
that is, they will allow you to match a term against an uninstantiated subterm of itself.
In this example, foo(Y) is matched against Y, which appears within it. As a result, Y
will stand for foo(Y), which is foo(foo(Y)) (because of what Y stands for), which is
foo(foo(foo(Y))), and so on. So Y ends up standing for some kind of infinite structure.
Note that, whereas they may allow you to construct something like this, most Prolog
systems will not be able to write it out at the end. According to the formal definition
of Unification, this kind of "infinite term" should never come to exist. Thus Prolog
systems that allow a term to match an uninstantiated subterm of itself do not act
correctly as Resolution theorem provers. In order to make them do so, we would
have to add a check that a variable cannot be instantiated to something containing
itself. Such a check, an occurs check, would be straightforward to implement, but
would slow down the execution of Prolog programs considerably. Since it would
only affect very few programs, most implementors have simply left it out1.
```

## 10.7 Prolog and Logic Programming

```prolog
In the last few sections, we have seen how Prolog is based on the idea of a theorem
prover. As a result of this, we can see that our programs are rather like our hypotheses
about the world, and our questions are rather like theorems that we would like to
```

<!-- page 269 -->
1 The Prolog standard states that the result is *undefined* if a Prolog system attempts to match a term against an uninstantiated subterm of itself, which means that programs which cause this to happen will not be portable. A portable program should ensure that wherever an occurs check might be applicable the built-in predicate unify_with_occurs_check/2 is used explicitly instead of the normal unification operation of the Prolog implementation. As its name suggests, this predicate acts like =/2 except that it fails if an occurs check detects an illegal attempt to instantiate a variable.

```prolog
have proved. So programming in Prolog is not so much like telling the computer
what to do when, but rather like telling it what is true and asking it to try and draw
conclusions. The idea that programming should be like this is an appealing one,
and has led many people to investigate the notion of logic programming, that is,
programming in logic as a practical possibility. This is supposed to contrast with
using a conventional programming language such as FORTRAN or LISP, where one
specifies tasks much more clearly in terms of what the computer should do and when
it should do it.
    The advantages of logic programming should be that computer programs are
easier to read. They should not be cluttered up with details about how things are
to be done — they will be more like specifications of what a solution will look like.
Moreover, if a program is rather like a specification of what it is supposed to achieve,
it should be relatively easy, just by looking at it (or, perhaps, by some automatic
means) to check that it really does do what is required. In summary, the advantages
of a logic programming language would result from programs having a declarative
semantics as well as a procedural one. We would know what a program computes,
rather than how it computes it. We will not be able to look at logic programming
in general here. The interested reader is referred to Robert Kowalski's book Logic
for Problem Solving published by North Holland in 1979, and Christopher Hogger's
book Introduction to Logic Programming published by Academic Press in 1984.
    Let us briefly look at Prolog as a candidate logic programming language, and
see how well it shapes up. First, it is clear that some Prolog programs do represent
logical truths about the world. If we write:
    mother(X, Y):- parent(X, Y), female(Y).
we can see this as saying what it is to be a mother (it is to be a female parent). So this
clause expresses a proposition that we are hypothesising to be true, as well as saying
how to show that somebody is a mother. Similarly, the clauses:
    appendQ], X, X).
    append([A|B], C, [A|D]):- append(B, C, D).
say what it is for one list to be concatenated to the front of another. If the empty list
is put on the front of some list X, then the result is just X. On the other hand, if a
non-empty list is appended on the front of a list, then the head of the result is the
same as the head of the list being put on the front. Also, the tail of the result is the
same list as would be obtained by appending the tail of the first list onto the front
of the second. These clauses can definitely be seen as expressing what is true about
the append relation, as well as how one might actually set about appending two lists
together.
    So much for some Prolog programs, but what possible logical meaning can we
give to clauses like these?
```

<!-- page 270 -->
```prolog
    memberl(X, List) :- var(List), !, fail.
    memberl(X, [X|_]).
    memberl(X, [_|List]) :- memberl(X, List).
    print(O) :- !.
    print(N) :- write(N), Nl is N - 1 , print(Nl).
    noun(N) :-
            name(N, Namel), append(Name2, [115], Namel),
            name(RootN, Name2), noun(RootN).
    implies(Assum, Concl) :-
            asserta(Assum),
            call(Concl),
             retract(Concl).
The problem comes with all those built-in predicates that we use in our Prolog pro-
grams. A goal such as var(List) does not say anything about lists or membership,
but refers to a state of affairs (some variable being uninstantiated) that may hold
at some time during the proof. The "cut" similarly says something about the proof
of a proposition (which choices may be ignored), rather than about the proposition
itself. These two goals can be regarded as ways of expressing control information
about how the proof is to be carried out. Similarly, something like write(N) does
not have any interesting logical properties, but presupposes that the proof will have
reached a certain state (with N instantiated) and initiates a communication with the
user. The goal name(N, Namel) is saying something about the internal structure of
what, in Predicate Calculus, would be an indivisible symbol. In Prolog, we can con-
vert symbols to character strings, convert structures to lists and convert structures
to clauses. These operations violate the simple self-contained nature of Predicate
Calculus propositions. In the last example, the use of asserta means that the rule is
talking about adding something to the set of axioms. In logic, each fact or rule states
an independent truth, independent of what other facts and rules there may be. Here
we have a rule that violates that principle. Also, if we use this rule, we will be in a
position of having a different set of axioms at different times of the proof! Finally,
the fact that the rule envisages Concl being used as a goal means that a logical vari-
able is being allowed to stand for a proposition appearing in an axiom. This is not
something that could be expressed in Predicate Calculus at all, but is reminiscent of
what higher-order logic can provide.
    Given these examples, we can see that some Prolog programs can only be un-
derstood in terms of what happens when and how they tell the system what to do. As
an extreme case, the program for gensym given in Chapter 7 can hardly be given any
declarative interpretation at all.
```

<!-- page 271 -->
```prolog
    So does it make sense to regard Prolog as a logic programming language at all?
Can we really expect any of the advantages of logic programming to apply to our
Prolog programs? The answer to both these questions is a qualified "yes", and the
reason is that, by adopting an appropriate programming style, we can still extract
some advantages from the relation of Prolog to logic. The key is to decompose our
programs into parts, confining the use of the non-logical operations to within a small
set of clauses. As an example, we saw in Chapter 4 how some uses of the cut could
be replaced with uses of not. As a result of such replacements, a program containing
a number of cuts can be reduced to one with the cut only used once (in the definition
of not). Use of the predicate not, even though it does not capture exactly the logical
"-i", enables one to recapture part of the underlying logical meaning of a program.
Similarly, confining the use of the predicates asserta and retract to within the def-
initions of a small number of predicates (such as gensym and findall) results in a
program that is clearer overall than one where these predicates are used freely in all
sorts of contexts.
    The ultimate goal of a logic programming language has not, then, been achieved
with Prolog. Nevertheless, Prolog provides a practical programming system that has
some of the advantages of clarity and declarativeness that a logic programming lan-
guage would offer. Meanwhile the work goes on to develop improved versions of
Prolog that are truer to the logic than what we currently have available. Among the
highest priorities of workers in this area is to develop a practical system that does not
need the cut and has a version of not that exactly corresponds to the logical notion
of negation.
    For more information on the theory of logic programming, you should con-
sult Logic for Problem Solving, by Robert Kowalski, published by North-Holland in
1979; and Introduction to Logic Programming, by Christopher Hogger, published by
Academic Press in 1984.
```
