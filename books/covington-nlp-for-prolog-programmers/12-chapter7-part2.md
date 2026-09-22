# Chapter7_Part2

<!-- page 230 -->
Chap. 7 will instantiate L to a list of all the values of X that occur in solutions to Goal. The list is sorted in alphabetical order and duplicates are removed. For example: dog(fido). dog (bucephalus) .

?- setof(X,dog(X),L). L = [bucephalus, fido] That’s almost what we need. The problem is that if Goal contains a variable other than X, setof will return only the solutions in which that variable has one particular value. On backtracking, setof will then let that variable have another value, and so on. With the knowledge base

we get:

?- setof(X,f£(X,Y),L). Ye=o

L = [a,b]

; Ye=d

L = [c,d]

;

What we want is to get all the values of X into a single list. Otherwise, there are some queries we can’t answer, such as how many dogs chase any cat (not necessarily the same cat).

Fortunately setof provides a way to work around this.* If we write

?- setof(X,Term*Goal,L).

%* here *~ does not denote lambda then setof works as before, except that all the variables in Term are allowed to take on all possible values, like this:

?- setof(X,Y°f(X,Y),L). L = [a,b,c,d]

(assuming the same knowledge base as before).

What we want, of course, is this kind of treatment for all the variables in Goal, so we simply write Goal*Goal. We’ll encapsulate this trick by defining the predicate solutions/3:

<!-- page 231 -->
*At least in ALS, Arity, and Quintus (UNIX) Prolog, and in the draft ISO standard; not in LPA Prolog 3.10 (Quintus Prolog for MS-DOS).

solutions (-X,+Goal,-List) HP dP oe oe

Returns, in List, all the values of X that satisfy Goal.

Free variables in Goal are allowed to take all possible values.

List contains no duplicates.

solutions (X,Goal,List) :-

```prolog
setof(X,Goal*Goal,List).
```

% here *~ does not denote lambda

**A few Prologs either do not have setof, or do not accept the Goal*Goal trick.**

These Prologs have, instead, a built-in predicate £indal1/3 that works like setof, but allows the free variables to take on all values, thus:

?- findall (X,£(X,Y),L). L = [a,b,c,d]

The trouble with findall is that it doesn’t remove duplicates. If we’re counting the cat-chasing dogs, we don’t want to count Fido twice merely because he chases two cats. So we’ll need to define solutions as:

solutions(X,Goal,List) :-

```prolog
findall(X,Goal,L),
remove_duplicates(L,List).
```

You will have to define remove_duplicates also. Exercise 7.4.2.1

Get solutions/3 working on your computer. Using a small knowledge base, verify that

it works correctly.

Exercise 7.4.2.2

Using solutions/3, define the following generalized quantifiers:

e two(X,Res, Sco), true if there are exactly two values of X that satisfy Res and

also satisfy Sco;

e three(X,Res,Sco) and four(X,Res,Sco), analogous to two;

e most (X,Res, Sco), true if more than half of the values of X that satisfy Res also

satisfy Sco.

Be sure you compare the number of values that satisfy Res to the number of values that

satisfy both Res and Sco (not just Sco by itself). If there are three dogs and two green

objects (not dogs) in the knowledge base, you would not want to conclude that two dogs

are green.

7.4.3, Who/What/Which Questions

**Now we can tackle questions that contain the “wH-words” who, what, which, and how**

<!-- page 232 -->
many. Syntactically, who and what are pronouns; roughly they mean ‘which person’ and

Chap. 7 ‘which thing’. Which and how many are determiners and are the words we will focus on here.

**We can handle which and how many like quantifiers, except that when they occur**

— in a query, the Prolog system will display the values on the screen rather than just testing the truth of a statement:

which(X,Res,Sco) :-

solutions (X, (Res,Sco),L),

```prolog
write(L),
nl.
```

how_many (X,Res,Sco) :-

solutions (X, (Res,Sco),L),

```prolog
length(L,N),
write(N),
nl.
```

The main syntactic peculiarity of wH-words is that they always occur at the beginning of the sentence. Of course, sometimes they would have been there anyway; structures like

Which cat saw a dog?

**How many cats saw a dog?**

are no problem. In other cases, however, the wH-word moves to sentence-initial position and takes the rest of its NP with it. Instead of

Fido chased which cat?

we normally get

Which cat did Fido chase ,,?

where, as in Chapter 3, ,, denotes a missing NP. The moved NP can be associated with its original position using the same techniques as in Chapter 3.

wH-words are also subject to scope ambiguities. In English, Which dogs chased a cat? can mean either ‘Which dogs chased one particular cat?’ or ‘Which dogs chased any cat (we don’t care which one)?’ These require the same techniques, and present the same puzzles, as the ambiguities of all and some already noted. Exercise 7.4.3.1

Extend your parser from Exercise 7.4.1.1 to answer queries such as:

Which cat saw Fido?

How many dogs chased some cat?

Fido chased how many cats?

You need not deal with scope ambiguities, nor with plurals whose determiner is anything

<!-- page 233 -->
other than which or how many. Exercise 7.4.3.2 (small project)

Extend your parser so that it also handles wH-movement and will answer queries such as:

**How many cats did Fido chase?**

Which cats did every dog see?

Again, you need not handle scope ambiguities, nor plurals with determiners other than which

or how many.

**7.5 FROM FORMULA TO KNOWLEDGE BASE**

**7.5.1 Discourse Referents**

**When we move from question answering to actually building a knowledge base from**

**English input, a problem immediately arises. Consider how to render the sentence**

**Max owns a dog.**

**into Prolog. A first guess would be to use the two facts:**

2 dog (X).

```prolog
% wrong!
```

owns (max,X).

**That’s not right; in Prolog, these facts say ‘Anything is a dog’ and ‘Max owns any-**

**thing.’ They would succeed with queries as bizarre as ‘?- dog (qwertyuiop) .’ and**

**‘?- owns (max,new_york) .’**

**Since the dog doesn’t have a name, we have to give it one. That is, we have to**

**recognize the dog as a DISCOURSE REFERENT (a thing that can now be talked about) and**

**give it a unique name (a DISCOURSE MARKER), such as x123 or x(123). Then what**

**we want to say is:**

dog(x(123)). owns (max,x(123)).

**We will also need some kind of TABLE OF IDENTITY so that if we ever find out this dog’s**

name, or find out that it is identical to some other dog with a different discourse marker, we can keep track of it properly.

**An even bigger problem arises with statements like Every farmer owns a dog. What**

**we want is something like this,**

dog (Y)

```prolog
:- farmer(X).
                 % wrong!
```

owns (X,Y) :- farmer(X).

<!-- page 234 -->
5See Karttunen (1969), an account still well worth reading. In this section I follow Covington, Nute, Goodman, and Schmitz (1988) and the sources cited there.

Chap but here the variables are obviously doing the wrong things. What we need is to generat a different discourse referent for each farmer’s dog. We can do this by letting the dog’ name be a structure that has the farmer’s name in it, like this:

:

dog (x(124,xX) )

```prolog
:- farmer(X).
```

owns (X,x(124,X)) :- farmer(X). Then if Max is a farmer, his dog is temporarily known as x (124,max); Bill’s dog is” *x(124,bil1); and so on. Each dog has a unique name. This is a form of SKOLEMIZA TION (Skolem 1920), the replacement of J-quantified variables with terms whose value depend on the values of all the other variables. In effect, we are changing

**(Wx) (farmer (x) —> (Ay)(dog(y) A owns (x, y)))**

into

**(Vx) (farmer (x) — (dog (f(x) A owns(x, f(x))))**

**where f is a function that maps each farmer onto (a name for) the appropriate dog.**

Exercise 7.5.1.1

Define a procedure generate_marker/1 which will create new discourse markers by

instantiating its argument to a different discourse marker every time it is called, thus:

```prolog
?- generate_marker (What).
What = x(1)
?- generate_marker (What) .
What = x(2)
?- generate_marker (What).
What = x(3)
```

and so on. (Hint: Use assert and retract.)

Exercise 7.5.1.2

Translate into Prolog facts and rules, by hand, using discourse markers where necessary:

**A dog barked.**

Felix chased a dog.

Felix chased every dog.

**A dog chased a cat.**

Exercise 7.5.1.3 (small project)

Write a program that will take the formulas

**some**

**(X, dog (X) , barked**

(X) )

some (X, dog (X) , chased (felix,X))

all (X, dog (X) , chased (felix,X))

<!-- page 235 -->
some (X,dog(X),some(Y, cat (Y) ,chased(X,Y)))

(which are, of course, representations of the sentences in the previous exercise) and translate

each of them into one or more Prolog clauses using discourse markers wherever appropriate.

7.5.2 Anaphora

ANAPHORA is the use of pronouns (ANAPHORS) to refer to people, places, or things previously mentioned. For example:

Max; photographed himself;.

Then he; photographed Sharon;

and she; photographed him;.

The subscripts 7, j,

... identify words that are COREFERENTIAL (refer to the same person).

In order for an anaphor to be understood, it must be matched up with the appropriate pre-existing discourse referent. This is called RESOLVING the anaphoric reference® and is often done by looking for the ANTECEDENT of the anaphor, i.e., the previous mention of the thing that the anaphor refers to. Anaphora resolution is still an area of ongoing research, but several important principles have emerged.

First, anaphors stand for discourse referents, not for words or phrases. Consider the example:

,

**Max found a trail and followed it.**

Clearly this means that Max found a trail and then followed the same trail. But if it were merely a substitute for the words a trail, then

**Max found a trail and followed a trail.**

would mean the same thing, which it doesn’t (in the latter sentence the two trails need not be the same). Evidently, then, an anaphor stands for the same referent, not merely the same words, as its antecedent.

Occasionally the antecedent of the anaphor is something that has not been mentioned, but has been brought to the hearer’s attention some other way. This is called PRAGMATIC ANAPHORA. For an example, imagine hearing a loud noise and asking someone, What was it? The antecedent of it is the noise, which has not been mentioned.

Second, the antecedent almost always precedes the anaphor. This is simple but important. The obvious way to search for the antecedent of an anaphor is to start with the most recently introduced discourse referent, and search backward until a suitable antecedent is found.

Occasionally the anaphor and antecedent are in reverse order; that is, the anaphor comes first. This is called BACKWARDS ANAPHORA or CATAPHORA and the classic example is:

Near him;, John; saw a snake.

<!-- page 236 -->
®Not to be confused with “resolution” in theorem proving.

Chap. 7 Cataphora apparently requires the pronoun and antecedent to be in the same sentenc with the pronoun more deeply embedded (farther from the S node at the top), as noted | by Ross (1967) and many others since (see Carden 1986).

Third, the gender and number of the anaphor restrict the set of possible antecedents, - In English, we use he/him to refer to singular males, she/her for singular females, it for singular inanimate objects, and they/them for plurals.’

This suggests a general algorithm for finding antecedents:

e Keep a list (or a series of Prolog facts) listing all the discourse referents, newest

first, and tagging each of them as masculine, feminine, or inanimate, and as singular

or plural.

e Upon finding an anaphor, search through the discourse referents to find the most

recent antecedent with appropriate gender and number. And in fact this strategy works well; Allen (1987:339-354) explores it at some length. Hobbs (1978) found that it is not usually necessary to search back very far, because 98% of all antecedents are within the current or the previous sentence.

There’s more. The form of the anaphor indicates whether the antecedent is in the same sentence. In English, intrasentential anaphors (REFLEXIVES) end in -self. For example:

John; saw himself.

John; saw him;.

(Gj #i)

Here we know that him in the second sentence cannot be coreferential with John because it does not end in -self.

Actually, “in the same sentence” is not quite the right criterion; the exact syntactic criteria are more complicated, and are not fully understood. Note the contrast between:

John; baked a cake for himself;.

(not him;)

John; saw a snake near him;/himself;.

The problem of formulating the exact conditions for the use of reflexives has been an important stimulus for research in generative grammar (Chomsky 1982:218 ff., 288 ff.).

Finally, semantics and real-world knowledge can help choose between possible antecedents, as in Jespersen’s macabre example:8

If the baby; does not thrive on raw milk;, boil it;.

Here you have to know that milk can be boiled and babies can’t.

7We will get to plural discourse referents in the next section.

8Jespersen (1954:143), cited by Hobbs (1978).

<!-- page 237 -->
: Sec. 7.5

From Formula to Knowledge Base

223 Computational linguists who are daunted by the challenges of anaphora can take solace in the fact that native speakers have problems too, especially when expressing themselves in writing. Unclear or misleading antecedents are a common problem in poorly written English.

Exercise 7.5.2.1

Consider the following short text:

Without considering whether he would offend vegetable growers, the pres-

ident said he hated broccoli and didn’t have to eat it if he didn’t want to. And

sure enough, they were offended. As a protest, they sent him a huge amount of it.

(a) Use subscripts to indicate the coreferential nouns and pronouns.

(b) Point out an instance of cataphora.

(c) What kinds of information do you rely on when identifying the antecedent of each anaphor? What kinds of indicators mentioned in the text are not necessary here?

Exercise 7.5.2.2

Consider now the much simpler text:

Cathy photographed Fred.

Then she photographed herself.

Finally Fred looked at Sharon and she photographed him.

which goes into formulas as:

photographed (cathy, fred) . photographed (she,herself). looked_at (fred, sharon). photographed (she,him).

Define a procedure resolve_anaphors/2 that will accept this series of formulas (in a Prolog list) and will replace all the anaphors with the names of their most likely referents, thus:

?- resolve_anaphors

( [photographed (cathy, fred) ,

photographed (she,herself)],What).

What = [photographed (cathy, fred) , photographed (cathy, cathy) ]

(and likewise for the complete list, and for other similar lists).

<!-- page 238 -->
As real-world knowledge, your procedure can assume that Cathy and Sharon are female and Fred is male. You can further assume that each formula corresponds to a single sentence, and that all anaphors refer to individuals that have been named (so that there is no need for discourse markers).

Chap. : 7.5.3 Definite Reference (the) Although we’ve analyzed lots of determiners, we still haven’t said anything about the What does an NP like the cat really mean?

The classic analysis, due to Bertrand Russell (1905), is that the is a quantifier (written 3! or 2) which means ‘there is exactly one.’ On this analysis, The king is bald” corresponds to the formula

(Alx : king (x))bald (x) and means ‘There is exactly one value of x which satisfies king (x) and also satisfies bald(x).’

But Russell’s analysis captures only part of the picture. Quite often, definite NPs (NPs with the) refer to discoutse referents already mentioned, thus:

**A dog; barked and a cat; howled.**

Then the dog; chased the cat; away. If the second sentence had said A dog chased a cat away it would have suggested that the second dog and cat are not the same as the first ones. Using the makes it clear that the dog and the cat are the ones already mentioned. It is as if the dog were an anaphor that can only refer to dogs.

It turns out that treating definite NPs as anaphors is a good idea, with the proviso that pragmatic anaphora is common, and that the antecedent is often in the hearer’s background knowledge (or assumed background knowledge) rather than in his or her immediate awareness. I can say the king of Lesotho without previously having mentioned him; you will react to this by assuming (if you did not know already) that Lesotho does indeed have a king. That is, you will ACCOMMODATE to my pragmatic anaphora by introducing a discourse referent with appropriate properties. Russell’s analysis of the does a good job of characterizing the effect of the in just this special case where no antecedent is available. Exercise 7.5.3.1

Modify resolve_anaphors from the previous exercise so that it will also resolve the

referents of NPs bound by the, treating them as anaphors whose referents must Satisfy a

particular predicate. This time, use the text:

Henry II knighted Robin Hood.

Then Friar Tuck petitioned the king

and the king knighted the friar too.

The formulas that correspond to the sentences are

knighted (henry iii, robin_hood).

the (X, king (X) petitioned (tuck,X)).

the (X,king(X),the(y, friar (Y),knighted(x,y) ).

and the relevant background knowledge is that Henry III is a king, Tuck is a friar, and Robin

Hood is neither one.

<!-- page 239 -->
.

The output from resolve_anaphors should contain the following formulas (in a list, of course):

knighted (henry_iii,robin_hood) . petitioned(tuck,henry_iii). knighted (henry_iii,tuck).

7.5.4 Plurals The correct semantics for natural-language plurals is still a matter of debate. Webber (1983) points out that in Three boys bought five roses, each plural NP has three readings:

© DISTRIBUTIVE (there were 3 boys and each bought 5 roses); @ COLLECTIVE (the 3 boys, as a group, bought a group of 5 roses); © CONJUNCTIVE (a total of 3 boys bought roses, and a total of 5 roses were bought). The distributive reading is what our quantifier rules already give us, and the conjunctive reading could be derived from it by a transformation not unlike quantifier raising. The collective reading is the interesting one because it introduces a new concept: SETS Or COLLECTIVES. The key idea is that at least on the collective reading of

Three men sang.

and possibly on all three readings, the set of three men is itself a discourse referent, with several attributes:

e ELEMENTS (although in this sentence they are not identified); ® CARDINALITY (the number of elements, in this case 3); and © DISTRIBUTED PROPERTIES, i.e., properties that all the elements share (in this case (Ax)man(x)). Figure 7.4 shows a strategy for representing collectives in a knowledge base. Note that collectives can be denoted by conjoined singulars (such as Curly, Larry, and Moe) as well as by plurals.

Exercise 7.5.4.1 Give formulas for the distributive and conjunctive readings of Three boys bought five roses.

Exercise 7.5.4.2

Consider the knowledge base:

<!-- page 240 -->
collective(x(4)). element (x(4),curly). element (x(4),larry). distprop(x(4),X*man(X)).

Semantics, Logic, and Model Theory

Chai

Curly, Larry, and Moe sang (together).

collective(x(1)). element (x(1),curly). element (x(1),larry). element (x(1),moe). cardinality (x(1),3). sang(x(1)).

Three men sang (together).

collective(x(2)). distprop (x (2) ,X*man(X)). cardinality(x(2),3). sang(x(2)).,

Some cats howled (. together).

collective(x(3)). distprop (x(3) ,X*cat (X)). howled (x(3)).,

Figure 7.4 Representation of collectives in a knowledge base.

This implies that Curly is a man, but the query *?- man(curly) .’ does not succeed

from it.

Define a predicate prove/1 that attempts to satisfy any query, not only by executing

it in Prolog in the usual way, but also by making inferences from distprop and element.

Your code should have the form

prove(Goal) :- call (Goal).

bprove(Goal) :- ... something else...

and the query ‘?~ prove(man (curly) ) .’ should succeed using the knowledge base

<!-- page 241 -->
above. Exercise 7.5.4.3

The middle knowledge base in Figure 7.4 asserts that the group of three men sang. What

would it mean if instead of sang (x (2) ) it said distprop (x(2) ,X*sang(X))? Using

this as a hint, how could you represent the distributive reading of Three million men sang

without using three million discourse markers?

**7.5.5 Mass Nouns**

If plurals are a puzzle, mass nouns such as water or gold are an even bigger puzzle. In sentences like

Gold is an element.

This ring is made of gold.

it makes sense to treat gold like a proper name: there is only one substance called gold in the entire universe, and these sentences make assertions about it (cf. Chierchia 1982). So they can be rendered in a knowledge base as something like this:

element (gold). made_of(x(5),gold).

% x(5) is discourse marker for the ring

**But in other instances a mass noun denotes a PoRTION of a substance (Parsons 1970). A**

portion is somewhat like a collective except that it has no elements and no cardinality. Instead it has a QUANTITY, which maps onto real numbers using standard units. Such an interpretation is necessary in order to represent sentences such as:

There is an ounce of water in the glass.

portion(x(1)) distprop(x(1),X*water(X)).

® x(1) is a portion of water quantity (x(1),29.6,mL).

```prolog
% comprising 29.6 milliliters
```

in(x(1),x(2))

%® and is in x(2), the glass.

Often, only relations between quantities are known, not actual values:

There is more water in the glass than in the cup.

Finally, note that mass nouns can often be CONVERTED (changed without alteration of form) into count nouns denoting kinds of the original substance: the wines of California, the heavy metals.

The semantics of mass nouns is an area of ongoing research. Ojeda (1991) and the papers in Pelletier (1979) describe a number of current approaches. Exercise 7.5.5.1

Identify the underlined noun in each of the following examples as either a count noun, a mass

<!-- page 242 -->
noun denoting a substance, or a mass noun denoting a portion of a substance. (Hint: Count

Ct

nouns distinguish singular from plural; mass nouns do not. Further, it makes sense “how much?” when the mass noun denotes a portion but not when it denotes a substan

Every cat eats meat.

We got some cat food at the store.

The cat food was mainly made of tuna.

Exercise 7.5.5.2 How might you express John has more money than Jack does in Prolog, sticking as ¢lg as possible to the formalism used in this section?

:

7.6 NEGATION

7.6.1 Negative Knowledge

So far we have said nothing about how to represent negative statements such as

Fido does not bark.

We’re handicapped by the fact that Prolog itself has no way to encode negative know edge. Extensions of Prolog that do so have been developed but are beyond the scope: this book.’ One approach is to proceed as follows: e Store negative facts in the knowledge base explicitly: neg (barks (fido) ) e Define a procedure that creates the COMPLEMENT of each query by adding neg if neg is absent, or removing it if it is present. e Answer each query by trying to prove both the query itself, and its compleme This gives any of four results: yes, no, don’t know (neither the query nor its com: plement succeeds), or contradiction (both the query and its complement succeed).

In a database-querying situation we can get by with something much simpler: NEGATION AS FAILURE, the approach used by Prolog itself. We can assume that a query is false if it cannot be proved true. This is sufficient to answer queries such as:

Ts there a dog that does not bark?

?- dog(X), \+ barks (xX).

and is the approach that will be used here.

Exercise 7.6.1.1

Assume that you are using an extension of Prolog with explicit negation as described above.

(a) What is the complement of barks (fido)? Of neg (barks (fido) )?

(b) Given the knowledge base

<!-- page 243 -->
*See Nute (1988); Covington, Nute, and Vellino (1988, ch. 11); Naish (1986); Pearce and Wagner (1991). barks (fido). howls (felix). neg (howls(leo)). neg (howls (felix)).

> what answer (‘yes,’ ‘no,’, ‘contradiction,’ or ‘don’t know’) should you get to each of the following queries?

?- barks (fido). ?- howls(fido). ?- howls(leo). ?- howls(felix).

Exercise 7.6.1.2 (project) Implement an extension of Prolog with explicit negation.

Exercise 7.6.1.3

Why is contradiction impossible in ordinary Prolog?

7.6.2 Negation as a Quantifier

Consider now the sentence:

No dog barks.

Here no is a quantifier, and we can render this sentence into logic as:

no(X,dog(X), barks (X) )

**(‘there is no X which is a dog and barks’).**

More formally, no (Var, Scope, Res) is true if and only if there is no value of Var that satisfies Scope and Res. In Prolog:

no(_,Scope,Res) :- \+ (Scope,Res).

To get the truth value we do not need to identify Var, nor to distinguish scope from Testrictor. We do these things only so that, during the structure-building process, no can be handled like the other quantifiers. Negation of the main verb (with not or does not) works like no except that it has the whole séntence within its scope, thus:

Max does not bark.

<!-- page 244 -->
no(_,true, barks (max) )

Chap Here true is the Prolog built-in predicate that always succeeds; we use it to express an “empty” restrictor with no content.

**As expected, no participates in scope ambiguities. An example:**

All dogs do not bark.

(1)

all (X,dog(X) ,no(_,true, barks (X)))

All dogs are non-barkers.

(2)

```prolog
no(_,true,all (X,dog(X) , barks (X)))
```

Not all dogs bark.

Ambiguities like these sometimes confuse native speakers, and some people are uneas with any quantifier raising that involves negation.

Exercise 7.6.2.1

What does All that glitters is not gold normally mean? Could it be interpreted as meanin

something else? Explain why it is ambiguous.

Exercise 7.6.2.2

Extend your parser from Exercises 7.4.1.1, 7.4.3.1, and 7.4.3.2 so that it can answer question

of the form:

Is it true that no dog barks?

Is it true that every cat chased no dog?

Is it true that no dog chased every cat?

Here you can treat is it true that as a prefix that turns any statement into a question.

Exercise 7.6.2.3

Does Doesn’t Fido bark? mean the same thing as Is it true that Fido does not bark? If not,

what does it mean, and what is the function of the negative marker (n’t)?

**7.6.3 Some Logical Equivalences**

Negation gives us many ways to create formulas that are logically equivalent to each other. The most obvious is DOUBLE NEGATION:

no(_,true,no(_,true,S)) =S§

where S is any formula. There are also interactions of negation with quantifiers:

some(V,R,no(_,true,S))

**= no(_,true,all(v,R,S$))**

Some dogs do not bark

<!-- page 245 -->
Not all dogs bark

li all (V,R,no(_,true,S))

```prolog
no(_,true,some(V,R,S) )
```

All dogs do not bark

It is not true that some dogs bark (All dogs are non-barkers)

(No dogs bark)

and perhaps most importantly of all, no(_,true,some(V,R,S)) =no(V,R,S)

Notice that this is not quantifier raising; no ambiguities or changes of meaning are involved. The formulas that we are interconverting have exactly the same truth conditions.

As long as negation occurs only in database queries, these alternative forms are not a practical problem; the inference engine will get the right answers with any of them. But if we want to store negative information in the knowledge base, it is important to convert each formula into a standard form so that the same information will always be expressed the same way.

What to use for a standard form is up to the implementor. One could choose to move all negatives to the outermost, or perhaps the innermost, possible position. Another possibility is to eliminate a quantifier: any system that has no and all can do without some, or if it has no and some it can do without all.

Exercise 7.6.3.1

Simplify the formula

```prolog
no(_,true,some(X,dog(X),no(_,true, bark(X) ) )
```

to the simplest logically equivalent form. (To avoid bumping into a discrepancy between

our definition of all and the standard one, assume that there is at least one dog in the

knowledge base.)

Exercise 7.6.3.2

Define a predicate simplify/2 that will do the previous exercise for you. That is, define

a predicate that will “simplify” a formula containing negation, as follows:

e Transform double negation, no (_,true,no(_,true,S) ),

into S.

e If no occurs in the scope of another quantifier, move it out and change the quantifier,

so that:

some (V,R,no(_,true,S)) becomes no(_,true,all(V,R,S)) and

```prolog
all(V,R,no(_,true,S)) becomes no(_,true,some(V,R,S));
```

e Do both of these things recursively; that is, before simplifying any formula, attempt

to simplify its scope.

Exercise 7.6.3.3

<!-- page 246 -->
Explain why a system that has no and all does not need some. 7.7 FURTHER READING

**Of the many available introductions to first-order logic, that of Barwise and Etchemen**

(1991) meshes especially well with the material covered in this chapter. It covers topi such as Skolemization that are left out of more traditional texts. McCawley (1981) also useful because of its length (Its explanations are fuller than usual) and because its emphasis on natural language semantics.

Aside from logic texts, books on semantics are of two kinds: some cover main word meanings (Palmer 1981) while others treat syntactic and logical issues. A g00 introduction of the latter type is Chierchia and McConnell-Ginet (1990).

**A good example of semantic analysis in action is Horn (1989), a comprehensiv**

but readable study of negation that treats many other phenomena along the way. Dow (1979) gives insightful analyses of a wide range of phenomena, many of which can easi be adapted into frameworks other than Dowty’s.

For an introduction to model theory, see Bach (1989). The classic paper on ge eralized quantifiers is Barwise and Cooper (1981), but Peres’ account (1991) is short and more accessible to the beginner.

