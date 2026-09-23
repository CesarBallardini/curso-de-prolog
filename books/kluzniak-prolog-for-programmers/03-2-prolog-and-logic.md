# 2. Prolog and Logic

<!-- page 52 -->
## 2.1 Introduction

“Prolog” stands for “Programmation en logique” (programming in logic). Static interpretation of procedures (see Section 1.3.4) is possible because Prolog can also be viewed as a system for proving theorems expressed in logic. Adopting this viewpoint can provide the programmer with new insights about the nature of his task.

In this chapter we attempt to introduce the fundamentals of this aspect of Prolog in an intuitive manner. Full appreciation of the subject is possible only for people with a solid background in mathematical logic, and we assume your knowledge oflogic is very elementary. Consequently, the presentation is often not suf¿ciently precise, and sometimes the tenninology is a little unconventional: we are interested in Prolog rather than logic. The chapter is a shortcut, so in some places you will ¿nd it heavy going. A more detailed, but still non-technical treatment can be found in Kowalski (1979b). Another relevant book is Robinson (1979). See also van Emden and Kowalski (1979).

## 2.2 Formulae and Their Interpretations

[NTERPRETATIONS

Below is a pair of formulae written in the language of predicate logic (also known as ¿rst-order logic or predicate calculus): (2-I)

Vx D(Z. x. x) (2.2)

<!-- page 53 -->
VxVyVzD(x,y,z)=>D(S(x).y.S(z)). The basic building blocks of such formulae are predicates. A predicate consists of a predicate symbol (e.g. D), optionally followed by arguments—a list of terms in parentheses, separated by commas. A term is a variable (e.g. x, y, z), or a functor (e.g. Z, S) with an optional list of arguments, which are terms. Terms denote objects in some universe (more on this presently) and predicates stand for relations between these objects.

A single predicate is a formula. A larger formula can be built from simpler ones by means of logical connectives. The commonly used connectives, listed in order of decreasing priority, are —the negation (“not”), written as H —the conjunction (“and”), written as /\ —the disjunction (“or”), written as V —the implication, written as => Parentheses can be used to increase clarity or ovenide priority.

A formula (i.e. also a subformula) can be pre¿xed by a number of quanti¿ers, whose priority is lower than that of the connectives. A quanti- ¿er can be —the existential quanti¿er, written as ix and read as “there exists an x”. —the universal quanti¿er, written as Vx and read as “for all x”, or “for

any x”. The formula pre¿xed by a quanti¿er is called its scope, and the quanti¿ed variable is local to this scope (an occurrence of its name outside the scope does not denote the same object). In this chapter we shall deal only with hilly quanti¿ed fomrulae; i.e. our formulae will not contain unquanti¿ed variables.

Our example formulae can be read as

“for any object—call it x—the object Z is in relation D with x and x” and

“for any three (not necessarily distinct) objects—call them x, y and

z—if x, y and z are in relation D, then so are objects S( x ), y and

S( z )”. In practice, it is more convenient to use a slightly abbreviated reading, in which the second formula is

“for all x, y and z, D( x, y, z ) implies D( S( x ), y, S( z ) )”.

<!-- page 54 -->
Formulae of this kind are purely formal statements. One cannot discuss whether they are true or false, because no particular meaning is attributed to the functors and predicate symbols. To talk about a formula‘s meaning, we must give it an interpretation. An interpretation is a de¿nition of a universe (the set of objects which can be denoted by terms) and a decision to let predicate symbols and functors denote particular relations and functions de¿ned in this universe.

A concrete interpretation maps a (fully quanti¿ed) f0lTl‘ll1IEl to a statement which is true or false, depending on what it says about relations between objects. Somewhat imprecisely, we shall say that a formula is true (or false) in an interpretation. Of course, some formulae are true in all interpretations (the formula true is a trivial example, and A V H A is another); others are false in all interpretations (e.g. false, A /\ H A). The ¿rst kind of fomiulae are called tautologies; fomiulae of the second kind are called inconsistent.

As an example, consider the following two interpretations of fom1ulae (2.1) and (2.2). The ¿rst interpretation is the following: —the universe is the set of natural numbers (positive integers); —Z stands for the number 1 (one); —S stands for the function S(x) = 2x; —D(x, y, z) is true if and only if xy = z. Our formulae now become the true statements

“for any natural number x, Ix = x” and

“for all natural numbers x, y and z, xy = z implies 2xy = 22”. Another interpretation is: —the universe is the set of non-negative integers; —Z stands for the number 0 (zero); —S stands for the successor function S(x) = x+1; —D(x,y,z) is true if and only if x+y = z. The fomiulae are now

“for any non-negative integer x, 0+x = x” and

“for all integers x, y and z, x+y = z implies (x+1)+y = 2+1”.

If an interpretation maps a formula into a true statement, then this interpretation is called a model of this formula. We can also speak about a model of a set of for-mu1ae—an interpretation in which all of them are true.

<!-- page 55 -->
Our two interpretations are models of the example fomiulae. If Z stood for I in the second interpretation, then it would not be a model. When an interpretation interests us as a model, fomrulae which are true (or false) in that interpretation will be referred to as true (or false) in the model.

All interpretations are models of tautologies. Inconsistent formulae have no models.

When we want to talk about a particular model, we prefer to use symbols which have some mnemonic value. The formula (2.3)

Vh Vt conscarcdr( .( h,t ), h, t ) can be interpreted as

“for all integers h and t, the difference between h+t and h is t". but this is better written as

Vh Vt difference( +( h,t ), h, t ). The similarity is interesting, though: looking for other models of our statement of a problem often provides illuminating insights into its nature.

Notice that the “natural” interpretation of formula (2.3) is very down-to-earth. A list constructor can be thought of as a function mapping two objects (a head and a tail) into a third object: the universe can be a set of data structures.

## 2.3 Formal Reasoning

The notion of logical consequence allows us to perform formal reasoning, i.e. reasoning which takes into account only the syntactic fonn of fomrulae and disregards their interpretations. We say that formula a is a logical consequence of a set of formulae B, B’, B" . .. if all models of the set [3, B’, 5"

are also models ofa. It is a fundamental fact of logic that there exist inference rules, which are correct recipes for deriving logical consequences (conclusions) of other formulae (premises), provided the latter have a certain form. The inference rules are usually quite simple, but we can use them as elementary steps in long derivations. This is the backbone of mathematics: a set of formulae (axioms) de¿nes a theory, which is the set of all formulae (called theorems) true in all models of the axioms; a formal derivation of a new theorem is called its proof. (The name axioms is often reserved for a minimal set of theorems specifying the theory of interest. We ¿nd it more convenient to use the name for any “given” set of theorems accepted without proofs.)

Some inference niles are relatively trivial applications of the de¿nitions of logical connectives. A well-known example is the modus ponens:

“from any formula ct and from any formula of the form a => B, derive

<!-- page 56 -->
the formula B”. Now the de¿nition of implication can be stated as follows: if at and B are arbitrary formulae, then, in any interpretation, ct => B is false if and only if a is true and B is false in that interpretation. Hence, any model of both a and at => B must also be a model of B.

Two other simple rules are

“a :> B is equivalent to H a V B,

(i.e. one can be derived from the other)” and one of the De Morgan laws

“H ( a /\ B ) is equivalent to H a V H B”. Do convince yourself of their validity—we will need them presently!

Armed with a number of inference rules, we can attempt to derive a formula directly or by means of a technique known as reductlo ad absurdum. To derive formula at from a set of axioms, assume that H at is a theorem: if the resulting theory is inconsistent, then a is a theorem. A theory is inconsistent if it contains an inconsistent fomiula. In this method of proof we often show inconsistency by ¿nding a formula B such that we can derive

**B/\"À-**

It is worth noting that all formulae are theorems of an inconsistent theory. This is because, there being no models of the theory, no formula is false in any of the models. (This might not have sounded too convincing, but notice that if we can derive false, then we can derive any formula a using modus ponens and false :> at. For any at, the fomiulafalse => at is a tautology, because it is equivalent to H false V at, that is to say true V at.) Consequently, if the set of formulae

Ha:

B

Bf

is inconsistent, then at is certainly a theorem, regardless of whether the set B, B’,

is consistent or not.

## 2.4 Resolution and Horn Clauses

We shall be interested in an inference rule which we shall call the rule of resolution (Robinson I965). It says

<!-- page 57 -->
“from H ct V B and from a V -y derive B V -y”. Its validity is not hard to explain. In any model of H a V B and a V -y, either H a is false or a is false. In the ¿rst case B must be true (or else H a V B would not be true), in the second y must be true. If a model of H a V B and a V 7 must also be a model ofB or a model of -y, then—by de¿nition of disjunction—it is a model of B V -y.

There are two interesting special cases of this rule. One is

“from H a V B and from a derive B”, and the other is

“from H a and from a derive E1”. Here |:| stands for the empty formula, which must be treated as equivalent to false if this f0l'l'l'l of the rule is to be valid.

The rule of resolution is useful for reductio ad absurdum proofs when our formulae are written in a restricted form called clausal form. A clause is a disjunction of literals. A literal is either a predicate (called positive literal) or a negated predicate (called negative literal). All clauses are pre¿xed by universal quanti¿ers, one for each variable in the clause.

We shall limit our attention to Horn clauses, which have at most one positive literal each. Here is a set of four Hom clauses (the predicates are all nullary):

**AVHBVHC**

**BVHD**

C

D Now, if we want to prove that A can be derived from these clauses, we can use the rule of resolution to show that by adding the Hom clause

HA to our set of formulae, we obtain an inconsistent set of clauses. The proof can be canied out in the following four steps (we use parentheses to make things more clear):

1. fromHAandfromAV(HBVHC)deriveHBVHC

2. fromHBVHCandfromBVHDderiveHCVHD

3. fromHCVH Dand fromCderiveH D

4. fromH Dand fromDderive|]

<!-- page 58 -->
Notice that this type of reductio ad absurdum proof is successful when we derive the empty clause [1 (i.e. false). The special cases of the resolution rule are used to shorten formulae, while the general rule is used to generate formulae which can be shortened. Now, if in an application of the resolution rule both the premises have one positive literal each, then the conclusion must also have one positive literal (do you see why?). Hence, the proof cannot be successful unless at least one of the clauses has no positive literals. However, if one of the premises has only negative literals, then so has the conclusion. If only one of the initial clauses has this fonn, then the proofcan be made particularly simple (Kowalski and Kuehner 1971; Hill 1974). One of the premises in the ¿rst step is the clause without positive literals. If this step cannot derive the empty clause, then the second step must use the only other clause without positive literals, i.e. the conclusion of the preceding step, and so on. If—as in the example——all our axioms have positive literals, then the negated theorem must have none and the ¿nal proof has the form ofan orderly chain, in which each step provides a premise for the immediately succeeding one. In each step, we shall call the premise without positive literals the current resolvent.

Each step consists in cancelling a negative literal Hx in the current resolvent, by replacing it with the negative literals of a clause having A as its only positive literal. The resolvent shrinks when one of its literals is cancelled with a unit clause, which has only a single positive literal.

Because a clause is a disjunction of literals, it can be written as an implication. By the De Morgan law (see Section 2.3) A V ( H B V H C ) is

equivalent

**to A V H (B /\ C).**

This,

in tum,

is

equivalent

to B /\ C => A.

By analogy, we can write

B/\C=> to denote "B V "C (i.e. a Hom clause with no positive literals). The empty consequent represents false, since false (or its equivalent) is the only formula at such that a V (H B V H C) is equivalent to H B V H C, for all B and C.

Similarly, we shall denote A, a Hom clause with no negative literals, by

=>A Here, the empty premise represents true: A is equivalent to true => A. An empty clause has no literals and can be written

=> i.e. true => false, which is equivalent to false.

It is preferable to write the implication from right to left:

<!-- page 59 -->
A(=B/\C to suggest the reading

“to prove A, prove B and C”.

Recalling that our resolvents have no positive literals, we can now write the resolution rule as

**“from (I a /\ B and from at <2 -y derive <2 -y /\ B”**

where B, y or both may be empty (in that case we do not write a /\). This is a rather mechanical prescription: to get rid of at, ¿nd an implication whose consequent is a and replace a with its premises. This is clearly justi¿ed: since at can be proven by proving y, then at A B can be proven by provingy A B.

A clause being always pre¿xed with universal quanti¿ers for each of its variables, it is convenient not to write the quanti¿ers. Our fomrulae from Section 2.2 are two Hom clauses, written as

**D(Z,x,x)<:**

**D(S(x).y.$(z))<=D(x.y.z)**

Let us see whether these clauses are consistent with

**<=D(S(Z).x.S($(Z)))**

The clause can be thought of as a query whether there exists an x which is in relation D with S(Z) and S(S(Z)). It is equivalent to

**VX'“D(5(Z).X.5(5(Z))).**

and since this is the negation of what we are trying to prove, our derived fonnula—if we succeed—will be

3xD(S(Z),x,S(S(Z))) (if a is not false for all x, then there must be at least one x for which a is true).

The rule of resolution, in the form presented above, is useless for this example. In fact, it could only be used for nullary predicates, because the argument for its validity does not apply to premises such as

**VxHA(x)VHB(x)**

and

**VyA(Z)VHC(y).**

Fortunately, we can also employ a simple inference rule called the substitution rule. It says

<!-- page 60 -->
“from Vx a( x ) derive a(r), where -r is an arbitrary temi”. Here, a(x) means that the fomiula a contains occurrences of variable x. a(-r) stands for a formula which looks exactly like 0:, except that all occurrences of x have been replaced by occurrences of term 1-. An example of the rule's application is

“from Vx D( S( Z ), x, S( x ) ) derive

**D($(Z).3($(Z)).$(S(S(Z)))"**

The substitution rule is valid, of course. In every model of Vx a(x), a is true for any object x (that is what the quanti¿er says!): hence, it is true for any particular object.

It should now be clear that

“from Vx a( x ) and Vy B( y ) derive Vz a( z ) /\ B( z )” is also a valid inference rule. It can be looked on as an application of the substitution rule: in all models of Vx a(x) and Vy B(y), a(1-) and B(1-) are true for any 1-, hence (by the de¿nition of conjunction) a(-r) /\ B(-r) is true for any 1-, and therefore Vz a(z) /\ B(z) is true.

The substitution rule allows us to match different formulae by using appropriate variable substitutions. For example, we can easily show that H D(x, y, z) is inconsistent with D(Z, Z, Z), because we can derive H D(Z, Z, Z) from the ¿rst formula by substituting Z for x, y and z. We shall denote such substitutions by

**x1-Z,y1-Z,z1-Z.**

Our ability to match formulae allows us to apply to the problem at hand implications which express general rules. This is best illustrated with our running example. (We use apostrophes to distinguish between variables similarly named, but quanti¿ed in different scopes or used in different applications of a formula.)

1. Match <= D(S(Z), x, S(S(Z)))

and D(S(x‘), y’, S(z')) <= D(x‘, y’, z’)

by substituting x‘ 1- Z, y‘ 1- x, z‘ 1- S(Z).

2. From <: D(S(Z), x, S(S(Z)))

and D(S(Z), x, S(S(Z)) <= D(Z, x, S(Z))

derive <= D(Z, x, S(Z)) by the rule of resolution.

3. Match <= D(Z, x, S(Z)) and D(Z, x”, x”) <=

by substituting x” 1- x, x 1- S(Z).

4. From <= D(Z, S(Z), S(Z)) and D(Z, S(Z), S(Z)) <2

**derive I] (the empty resolvent) by the rule of resolution.**

A noteworthy feature of this example is that the term S(Z), ¿nally substituted for the x in

<!-- page 61 -->
<=D(S(Z),x,S(S(Z))) can be thought of as a counterexample to the disproved hypothesis that this formula is consistent with the others. We leamed in effect that, in any model of the two clauses playing the role of axioms,

“it is not true that Vx H D( S( Z ), x, S( S( Z ) ) ), because

H D( S( Z ), x, S( S( Z ) ) ) is false when x is S( Z )”. But this is the same as saying that our question

“does there exist an x such that D( S( Z ), x, S( S( Z ) ) )” is answered with

“yes, S( Z ) is such an x”. Recall our two interpretations from Section 2.2. In the ¿rst we asked whether there is an x such that 2x = 4, and the answer is that 2 is such an x. In the second interpretation, the question whether there is an x such that I + x = 2 was answered by 1.

The various substitutions were used to narrow the set of interesting objects to those objects for which the formula being disproved is not true. Indeed, it

is evident that for all x other than S(Z), the fomiula H D(S(Z), x, S(S(Z))) is true in both interpretations. It is so in all models of the two original formulae. but we shall not attempt to justify it directly. Our example would be an “indirect” justi¿cation if we could be certain that the substitutions did not “lose” other objects satisfying the disproved formula. Such certainty would be of practical value, because the answer to our query (i.e. our counterexample) can be a term containing variables. We want it to be as general as possible. in the sense that the set of all terms obtainable by substituting something for its variables should be the set of all answers.

It is a fundamental fact of resolution theory that the algorithm of uni¿cation (as presented in Section 1.2.3, but extended with the occur check) ¿nds the most general set of substitutions needed to match two literals. “Most general" means that it is contained by all sets of substitutions which make the literals match. When we match A(x) and H A(y), both x 1- y and y 1- x are possible—we treat them as indistinguishable. In a sense, this is the minimal necessary set of substitutions.

<!-- page 62 -->
We used uni¿cation in our example, so we did not lose any solutions. Notice, however, that our discussion is concemed with the effects of the substitution rule; as we shall see, different proofs can come up with different solutions. Try the conscarcdr and append examples from Chapter 1 to get a feeling for this kind of proof. You may use in¿x notation for functors—it does not matter. The intersection example might be a little more dif¿cult: read on.

## 2.5 Strategy

Disjunction being commutative, we can apply the rule of resolution to any literal in the current resolvent: in our examples, we always chose the leftmost one. The choice does not affect our ability to ¿nish the proof, as we must be able to cancel all the literals before obtaining the empty resolvent. As it tums out, the desirable properties of uni¿cation mentioned in the previous section ensure that the order in which the cancelling of literals is perfomied does not inÀuence the ¿nal outcome of the proof. The length of a proof, however, can be affected by the choice of literals very strongly indeed. We shall discuss this matter at the end of this section.

In our examples, at most one clause could be used to cancel a literal in each step. In general, a number ofclauses can be applicable (after suitable matching) to a given literal. Choosing the right clause could be important, because some of them can lead into “blind alleys”. After many steps, we may tum up with a resolvent to which the rule of resolution cannot be applied (because there are no matching clauses for its literals), even though another choice of clause at an earlier step might have speedily led to the empty resolvent.

The situation is illustrated by Fig. 2.1b, which shows part of the sear-ch space for the problem listed in Fig. 2.1a. The space is tree-shaped: each path from the root to a leaf represents a possible derivation sequence; its nodes are labelled with the successive resolvents. Some of the paths are successful, some end in failure.

Notice that several subtrees occur more than once. This effect would be less pronounced if the resolvents reÀected the history of substitutions, but we did not feel up to creating such a drawing for predicates with arguments. Try it for the application of intersect traced in Section 1.3.3. (Figure 2.5 will show you how to do it.)

Prolog always tries to use the leftmost literal, so its search space is considerably smaller, as illustrated in Fig. 2.1c. Whenever it is presented with a number of applicable clauses, the system always attempts the ¿rst one ¿rst. When it encounters failure, it backtracks and tries another path. In effect, it executes an orderly preorder search of the search space tree.

Figure 2.1c also illustrates the effect of a cut: a part of the search space is shom off, but one must be aware that this part may contain solutions! While this is not important in the example (if we expect a yes! no answer), in general different solutions may represent essentially different instantiations (i.e. substitutions) of variables in the root of the tree.

<!-- page 63 -->
This is not in contradiction to our earlier statements about “the desirable properties of uni¿cation”. As evidenced by Fig. 2.2, by choosing different literals we change only the order in which things are proved, but the general structure of the proof is not changed. It is convenient to represent the structure of a proof by means of a proof tree (do not confuse it with the search space), as illustrated in Fig. 2.3. The ¿rst tree shows the proofs of the preceding ¿gure, which all used B and C to prove A, and F to prove B. The other proof trees represent classes of proofs obtained through a different choice of clauses: the proofs are carried out quite differently.

Structurally different proofs use different subsets of the available clauses for performing various subproofs, so the “counterexamples” of Section 2.4--which are descriptions of sets of objects for which the clauses used cannot all be true—may turn out to be diÀ'erent. Therefore, not all solutions are the same.

Proof trees are interesting also because they reÀect the invocation tree when clauses are treated as procedures. As long as there are no failures, the conventional procedure activation stack can be regarded as an equally conventional stack used for preorder traversal of the proof tree, or—if failure is imminent—of a quasi-proof tree which has a failure

101

A“==

BAC

A"-=

D

B‘==

Dt\E

B<:=

F

C<=

C"==

FAD

D-1::

F-¢=

1¢=A

The axioms

The (negated) theorem

FIG. 2.1

<!-- page 64 -->
(a) A search space: the source formulae. (b) A search space: an initial part of the complete space. (Choice of literals denoted by an arc, choice of clauses by a dot.) (c) A search space: Prolog search space has no choices for literals. (Solution one is found, the others could be found on backtracking. ! marks the subspaces made unreachable by executing a cut at the end of A's ¿rst clause.) (continued) “___n___“_r9__m_;°___I_ 1“?OO Dar? Zu__r__ur_6__ € _ O_L__“____~“___ O__L_h_r__m_r__À_r{ _____Ur Or__“_r__“_r“TO____h___ <r rtr ____. “__‘___m__wt

**______**

**n_£_h_____mrmr**

U_'__h_r “___“__I"___O__"_________ {U

B ur>mr _ or _‘_Ur W’! IUrWr3 Ur ‘_ Wr ‘_ << << m/\< m_r___"___ ‘__ “__r___mr m_r__O__ ‘__ _“_r__m___IU3 “_r__m___ ¿r’? ‘__I: /A___V\ /A_V\ /_\/\_v\

**II**

__________

**___I**

**__**

**_**

.. “_I__m_r__n___ q|__m______ur __._ n_r__“_____m_r:2mi’Or__“_____m_'mt, mrÀr

**_____**

**/_\**

____m______________G_

**__Ndi**

**K**

**_**

**,mr**

**U**

**DDDUD**

**Ur**

<!-- page 65 -->
___6___

(cl

"A

I

**e\**

**/“By 1C**

--Dv--Ev-1C

-FvHC

I

Us

I

HEV -rc

WC

I

I

I

tail

Bl

HFVHD

HD

FIG. 2.1 (Continued)

in its rightmost leaf -(see Fig. 2.4). Backtracking to the nearest choice point in the search space may reopen an attempt to prove a node in a ¿nished branch of the quasi-proof tree, i.e. to reactivate a terminated procedure (this would happen if D had a second clause in our example). Obviously, this cannot be done with a single simple stack: the matter is discussed in Chapter 6.

<!-- page 66 -->
The word strategy refers to the way in which a theorem-prover (whether automatic or human) ¿nds its way through a search space. In logic programming literature the preferred term is control. It is not all a question of choosing the order of clauses and literals. Some logic programming systems employ no backtracking, choosing to cover the search space in a breadth-¿rst manner. This helps avoid problems caused by misapplied generators and left recursion (see Fig. 2.5 and Section 3.5.2). There is, of course, the problem of potentially exponential memory requirements. Prolog’s appetite for memory is at most roughly linear in number of attempted derivation steps. This is paid for with the cost of backtracking: the time complexity is still exponential.

HA

HBVHC

HFvHC

"B

**B//////\\\\\\a**

**l**

A*¢:'Bt\C

HC

HF

HF

B<:: F

**1**

**1**

**--**

**|:1**

**1:1**

**El**

**F‘:**

The clauses

used

lhe tree

ot

possible proot

paths

in these

proofs

FIG. 2.2

Choice of literals with ¿xed choice of clauses from Fig. 2.1. (Prolog would choose the left.most path, but only after some backtracking caused by choosing the ¿rst clause of B.)

A

A

A

B

C

B

C

D

F

E]

F

F

0

**El**

I

El

El

**El**

El

FIG. 2.3

<!-- page 67 -->
Proof tr'ees for the example of Fig. 2.1. (The leftmost tree represents the proofs of Fig. 2.2. Backtracking would cause Prolog to build each tree in tum, from left to right.)

A

**/\**

**El**

**as**

FIG. 2.4 A quasi-proof tree, representing a failing attempt to prove B by using its ¿rst clause. (The right son of A was not generated.)

Mle,.ll..l2.xlll e<-I ' l'(—-.12.!) E] Mte..l2.xl e<-2 ' l‘(—x U Mte.xl x<-.le,l'l ' x(—.le,l-ll U Mle,l') "<"‘°- ll’ '

**Mle .te tn<=**

lI(__(¢_[1;

**Mle,.ia,l)l %Mle,l)**

**if-ll .-IL-12. Ill**

U e'l‘)

e

I

Th; gpagg

The

<!-- page 68 -->
clauses FIG. 2.5 Prolog search space for an in¿nite generator. (The example is member.)

There have been attempts to decrease this cost by means of a more sophisticated backtracking strategy (Bruynooghe 1978, Pereira and Porto 1980b, 1982, Bruynooghe and Pereira 1981).

The more ambitious scheme, appropriately called “intelligent backtracking”, attempts to retain subproofs (which would otherwise have been discarded) in order to avoid recomputing them again and again. In other words, it attempts to take advantage of the multiplicity of identical subtrees in a search space (compare Fig. 2.1b).

A simpler approach, called “selective backtracking”, consists in analysing which variable instantiations caused the failure. It is then possible to backtrack directly to the nearest point where one of these instantiations was made or where the computation would take an entirely different course. In some cases this can save us a lot of thrashing about in a failureinfested region of the tree's crown.

Unfortunately, these interesting ideas have not inÀuenced Prolog implementations. They require a further complication of the already complex runtime data structures and they do not mesh well with side-effects of system procedures. The fact that Prolog can be used as a practical language is still largely due to our dexterity in ¿ghting exponential complexity with the cut.

Attempts to modify Prolog’s strategy so that it would incorporate parallelism or coroutining have been a little more successful. Parallelism consists in growing various branches of a proof tree (or even several trees) simultaneously. It is dif¿cult, not only because it raises tricky technical problems, but because we still lack suf¿cient understanding of its effects on both time!space complexity and the number of solutions gained or lost. Several very different approaches have been documented, but none of them seems to answer all pertinent questions. Some of the references are (Clark and Gregory 1983, Shapiro 1983b, Conery and Kibler 1983, Wise 1984, Eisinger et al. 1982).

Coroutining is just that: switching control between several active procedures. In terms of our drawings, coroutining is a non-trivial traversal of a proof tree. Roughly, it is a matter of choosing a different order of literals (a different path in Fig. 2.2). It is possible to demonstrate spectacular improvements in the perfomiance of some programs when they are executed in coroutining fashion. A simple example is the naive naive sort (see Section 1.3.5):

```prolog
sort( List, Sorted ) :- permute( List, Sorted ),
                    ordered( Sorted ).
```

<!-- page 69 -->
When the execution ofpermute is interleaved with that of ordered so that the latter can cause failure as soon as the ¿rst out-of-order element is produced by the fomier, the program's behaviour compares very favourably with that shown when each pemiutation must be completed before ordered is called. When the initial sequence of a permutation is rejected, all other permutations starting with the same sequence can at once be rejected as well, resulting in a signi¿cant reduction of the search space.

Section 9.2 contains two short examples of coroutining Prolog programs. Coroutining comes in many Àavours: some of the references are (Clark et al. 1979, Clark et al. 1982, Porto 1982, Colmerauer et al. 1983). Unfortunately, most of these schemes are of restricted utility (Kluiniak 1981). The problem is that coroutines do not mesh well with backtracking. We comment on this at greater length in (Kluiniak and Szpakowicz 1984).
