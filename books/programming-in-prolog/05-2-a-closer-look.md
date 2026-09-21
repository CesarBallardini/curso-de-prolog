# 2 A Closer Look

<!-- page 39 -->
In this chapter we provide a more complete discussion of the parts of Prolog that were introduced in the previous chapter. Prolog provides ways to structure data as well as ways to structure the order in which attempts are made to satisfy goals. Structuring data involves knowing the syntax by which we can denote data. Structuring the order in which goals are solved involves knowing about backtracking.

## 2.1 Syntax

The syntax of a language describes how we are allowed to fit words together. In English, the syntax of the sentence "I see a zebra" is correct, but the syntax of "zebra see I a" is not correct. In the first chapter, we did not discuss the syntax of Prolog explicitly, but we simply showed what some parts of Prolog looked like. Here we will summarise the syntax of those parts of Prolog we have seen thus far.

Prolog programs are built from *terms.* A term is either a *constant,* a *variable,* or a *structure.* We saw each of these terms in the previous chapter, but we did not know them by these names. Each term is written as a sequence of *characters.* Characters are divided into four categories as follows:

```prolog
A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
a b c d e f g h i j k l m n o p q r s t u v w x y z
0 1 2 3 4 5 6 7 8 9
+ - * / \ ~ A < > : . ? @ # $ 8.
```

<!-- page 40 -->
The first row consists of upper-case letters. The second row consists of lower-case letters. The third row consists of digits. The fourth row consists of sign characters. There are actually more sign characters than those shown in the fourth row, but others have special uses discussed below. Each kind of term, whether it is a constant, variable, or structure, has different rules for how characters are put together to form its name. Now we shall summarise each kind of term.

### 2.1.1 Constants

Constants *name* specific objects or specific relationships. There are two kinds of constants: atoms, and numbers. Examples of atoms are the names that were given in the last chapter:

```prolog
likes mary john book wine owns jewels can_steal
```

The special symbols that Prolog uses to denote questions "?-" and rules ":-" are also atoms. There are two kinds of atoms: those made up of letters and digits, and those made up from signs. The first kind must normally begin with a lower-case letter, as did all the ones we saw in the previous chapter. Those atoms made from signs normally are made up from signs only. Sometimes it may be necessary to have an atom beginning with a capital letter or a digit. If an atom is enclosed in single quotes ""', then the atom may have *any* characters in its name. Finally, the underline character "_" may be inserted in the middle of an atom to improve legibility. The following are further examples of atoms:

```prolog
a void = 'george-smith' --> george_smith ieh2304
```

The following are *not* examples of atoms:

```prolog
2304ieh george-smith Void _alpha
```

Numbers are the other kind of constant. We have not discussed how to do arithmetic in Prolog, but this will be introduced later in this chapter. Here are some examples of numbers:

```prolog
-17 -2.67e2 0 1 99.9 512 8192 14765 67344 6.02e-23
```

Most of these are familiar. The "e" notation is used to denote a power of 10. So, for example, the number -2.67e2 is -2.67 x 102 or just -267; 6.02e-23 is 6.02x 10"23.

<!-- page 41 -->
In addition to these numbers, Prolog programmers have added libraries to define features such as arithmetic operations on rational numbers and numbers of arbitrary precision, but we will not be needing these in this book.

### 2.1.2 Variables

The second kind of term used in Prolog is the *variable.* Variables look like atoms, except they have names beginning with a capital letter or an underline sign "_". A variable should be thought of as standing for some object that we are unable or unwilling to name at the time we write the program. This corresponds roughly to the use of a pronoun in English. In the example Prolog clauses we have seen so far, we have used variables with names such as X, Y, and Z. However, the names can be as long as you like, for example:

```prolog
Answer Input Gross_Pay _3_blind_mice A_very_long_variable_name
```

Sometimes one needs to use a variable, but its name will never be used. For example, if we want to find out if anyone likes John, but we do not need to know just who it is, we can use the *anonymous variable.* The anonymous variable is written as a single underline character. Our example is written in Prolog as:

```prolog
?- likes(_, john).
```

Several anonymous variables in the same clause need not be given consistent interpretations. This is a characteristic peculiar to the anonymous variable. It is used to save having to dream up different variable names when they will not be used elsewhere in the clause.

### 2.1.3 Structures

The third kind of term with which Prolog programs are written is the *structure.* Structures are called "compound terms" in Standard Prolog, but in this book we use the word "structure" because it is shorter and more easily distinguished from other kinds of terms. A structure is a single object consisting of a collection of other objects, called *components.* The components are grouped together into a single structure for convenience in handling them.

One example of a structure in real life is an index card for a library book. The index card will contain several components: the author's name, the title of the book, the date when it was published, the location where it can be found in the library, and so forth. Some of the components can be broken down into further components. For example, the author's name consists of some initials and a surname.

<!-- page 42 -->
Structures help to organise the data in a program because they permit a group of related information to be treated as a single object (a library card) instead of as separate entities. The way that you decompose data into components depends on what problem you want to solve, and later on we will give advice on how to do this.

Structures are also useful when there is a common kind of object, of which many may exist. Books, for example. In Chapter 1 we discussed the fact

```prolog
owns(john, book).
```

to denote that John owns some particular book. If we later said

```prolog
owns(mary, book).
```

this means that Mary owns the same object that John owns, because it has the same name. There is no other way of telling objects apart, except by their name. We could say:

```prolog
owns(john, wuthering_heights).
owns(mary, moby_dick).
```

to specify more carefully what books John and Mary own. However, in large programs, it may become confusing to have many different constants with no context to tell what they mean. Someone reading this Prolog program may not know that we meant `wuthering_heights` to be the name of the book written by the author Emily Bronte who flourished in Yorkshire, England during the 19th Century. Perhaps they will think that John has named his pet rabbit "wuthering-heights", say. Structures can help to provide this context.

A structure is written in Prolog by specifying its *functor* and its *components.* The functor names the general kind of structure, and corresponds to a datatype in an ordinary programming language. The components are enclosed in round brackets and separated by commas. The functor is written just before the opening round bracket. Consider the following fact, that John owns the book called *Wuthering Heights,* by Emily Bronte:

```prolog
owns(john, book(wuthering*_heights, bronte)).
```

Inside the owns fact we have a structure by the name of book, which has two components, a title and an author. Since the book structure appears *inside* the fact as one of the fact's arguments, it is acting as an object, taking part in a relationship. If we like, we can also have another structure for the author's name, because there were three Bronte writers we wish to distinguish:

```prolog
owns(john, book(wuthering_heights, author(emily, bronte))).
```

Structures may participate in the process of question-answering using variables. For example, we may ask if John owns any book by any of the Bronte sisters:

```prolog
?- owns(john, book(X, author(Y, bronte))).
```

<!-- page 43 -->
If this is true, X will then be instantiated to the title that was found, and Y will be instantiated to the first name of the author. Or, we may not need to use the variables, so we can use anonymous ones:

```prolog
?- owns(john, book(_, author(_, bronte))).
```

Remember that the anonymous variables never co-refer with any other variable, even other anonymous variables.

We could improve the book structure by adding another argument indicating *which copy* the book is. For example, a third argument, where we would insert an integer, would provide a way of uniquely identifying a book:

```prolog
owns(john, book(ulysses, author(james, joyce), 3129)).
```

which we could use to represent *John owns the 3,129th copy of Ulysses, by James* *Joyce.*

If you have guessed that the syntax for structures is the same as for Prolog facts, you are correct. A predicate (used in facts and rules) is actually the functor of a structure. The arguments of a fact or rule are actually the components of a structure. There are many advantages to representing Prolog programs themselves as structures. It is not important to know why just now, but do keep in mind that all parts of Prolog, even Prolog programs themselves, are made up of constants, variables, and structures.

## 2.2 Characters

The names of constants and variables are built up from strings of characters. Although each kind of name (atom, integer, variable) has special rules about what characters may make it up, it is helpful to know what all the characters are that Prolog recognises. This is because a character can be treated as an item of data in its own right. In Standard Prolog, a character is actually an atom of length 1. It is most common to use input and output operations on characters; this will be discussed in Chapter 5.

Prolog recognises two kinds of characters: printing characters and non-printing characters. Printing characters cause a symbol to appear on your computer terminal's display. Non-printing characters do not cause a symbol to appear, but cause an action to be carried out. Such actions include printing a blank space, beginning new lines of text, or perhaps making a beeping sound. The following are all the printing characters that can be used

```prolog
A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
```

<!-- page 44 -->
```prolog
a b c d e f g h i j k l m n o p q r s t u v w x y z
0 1 2 3 4 5 6 7 8 9
! " # $ % & ' ( ) = - ~ A | \ { } [ ] _ ' @ + ; * : < > , . ? /
```

You should recognise this as a more complete set than the one given at the beginning of this chapter. Some of the characters have special meanings. For example, the round brackets are used to enclose the components of a structure. However, we shall see in later chapters that all the characters may be treated as information by Prolog programs. Characters may be printed, read from the keyboard, compared, and take part in arithmetic operations.

## 2.3 Operators

Sometimes it is convenient to write some functors as *operators.* This is a form of syntax that makes some structures easier to read. For example, arithmetic operations are commonly written as operators. When we write the arithmetic expression "x + y * z", we call the "plus" sign and the "multiply" sign *operators.* If we had to write the arithmetic expression "x + y * z" in the normal way for structures, it would look like this: +(x,*(y,z)), and this would be a legal Prolog term. The operators are sometimes easier to use, however, because we have grown accustomed to using them in arithmetic expressions ever since our schooldays. Also, the structure form requires that round brackets be placed around the functor's components, which may be awkward at times.

It is important to note that the operators do not "cause" any arithmetic to be carried out. So in Prolog, 3+4 does not mean the same thing as 7. The term 3+4 is another way to write the term +(3,4), which is a data structure. Later we shall explain a way in which structures can be interpreted as though they represent arithmetic expressions, and evaluated according to the rules of arithmetic.

First we need to know how to read arithmetic expressions that have operators in them. To do this, we need to know three things about each operator: its *position,* its *precedence,* and its *associativity.* In this section we will describe how to use Prolog operators with these three things in mind, but we will not go into very much detail at this point. Although many different kinds of operators can be made up, we shall deal only with the familiar atoms +, -, *, and /.

<!-- page 45 -->
The syntax of a term with operators depends in part on the position of the operator. Operators like plus (+), hyphen (-), asterisk (*), and slash (/) are written between their arguments, so we call them *infix* operators. It is also possible to put operators before their arguments, as in "-x + y", where the hyphen before the x is used in arithmetic to denote negation. Operators that come before their arguments are called *prefix* operators. Finally, some operators may come after their argument. For example, the factorial operator, used by mathematicians, comes after the number you want to find the factorial of. In mathematical notation, the factorial of x is written "x!", where the exclamation sign is used to denote factorial. Operators that are written after their arguments are called *postfix* operators. So, the position of an operator tells where it is written with relationship to its arguments. It turns out that the operators that we will use in the next section are all *infix* operators.

Now precedence. When we see the term "x + y * z", and assume that it can be interpreted as an arithmetic expression, we know that to evaluate it, we must multiply y and z first, then add x. This is because we were taught in school that mutiplications and divisions are done before additions and subtractions, except where brackets are used for grouping. On the other hand, the structure form +(x,*(y,z)) makes explicit the rule that the multiplication is done before the addition. This is because the "*" structure is an argument of the "+" structure, so if we actually wanted the computer to carry out the calculation, the "*" has to be carried out first in order for "+" to know what its arguments are. So when using operators, we need rules that tell us the order in which operations are carried out. This is what *precedence* tells us about.

The precedence of an operator is used to indicate which operation is carried out first. Each operator that is used in Prolog has a *precedence* class associated with it. The precedence class is an integer that is associated with an operator. The exact value of the integer depends on the particular version of Prolog you are using, and we will give details in Chapter 5. However, it is always true that an operator with a higher precedence has a precedence class that is closer to 1. If precedence classes range from 1 to 255, then an operator in the first precedence class is carried out first, before operators belonging to the 129th (say) precedence class. In Prolog the multiplication and division operators are in a higher precedence class than addition and subtraction, so the term a-b/c is the same as the term -(a,/(b,c)). The exact association of operators to precedence classes is not important at the moment, but it is worth remembering the relative order in which operations are carried out.

<!-- page 46 -->
Finally, consider how different operators associate. How they associate comes to our attention when we have several operators of the same precedence. When we see the expression "8/2/2", does this mean "(8/2)/2" or "8/(2/2)"? In the first case, the expression could be interpreted to mean 2, and in the second case, 8. To be able to distinguish between these two cases, we must be able to tell whether an operator is *left associative* or *right associative.* A left associative operator must have the same or lower precedence operations on the left, and lower precedence operations on the right. For example, all the arithmetic operations (add, subtract, multiply, and divide) are left associative. This means that expressions like "8/4/4" are read as "(8/4)/4". Also, "5+8/2/2" is read as "5+((8/2)/2)'\

In practice, people tend to use round brackets for expressions that may be difficult to understand because of the precedence and associativity rules. In this book we will also try to make it as clear as possible by using lots of round brackets, but it is still important to know the syntax rules for operators so your understanding of operators is complete.

Remember that a structure made up of arithmetic operators is like any other structure. No arithmetic is actually carried out until commanded by the "is" predicate described in Section 2.5.

## 2.4 Equality and Unification

One noteworthy predicate is equality, which is an infix operator written as "=". When an attempt is made to satisfy the goal

```prolog
?- X = Y.
```

(pronounced "X equals Y"), Prolog attempts to *unify* X and Y, and the goal succeeds if they unify. We can think of this act as *trying to make* X *and* Y *equal.* The equality predicate is *built-in*, which means that it is already defined in the Prolog system. The equality predicate works as though it were defined by the following fact:

X = X. Within a use of some clause, X always equals X, and we exploit this property when defining the equality predicate in the way shown.

Given a goal of the form X=Y, where X and Y are any two terms which are permitted to contain uninstantiated variables, the rules for deciding whether X and Y are equal are as follows:

- If X is an uninstantiated variable, and if Y is instantiated to any term, then X and Y are equal. Also, X will become instantiated to whatever Y is. For example, the following question succeeds, causing X to be instantiated to the structure rides(student, bicycle):

```prolog
?- rides(student, bicycle) = X.
```

- Integers and atoms are always equal to themselves. For example, the following goals have the behaviour shown:

policeman =

policeman succeeds

paper

=

pencil

fails

1066

=

1066

succeeds

1206

=

1583

<!-- page 47 -->
fails

- Two structures are equal if they have the same functor and number of components, and all the corresponding components are equal. For example, the following goal succeeds, and causes X to be instantiated to bicycle:

```prolog
rides(student, bicycle) = rides(student, X)
```

Look closely: this is not a question about rides; it is a question about =.

Structures can be "nested" one inside another to any depth. If such nested structures are tested for equality, the test may take more time to carry out, because there is more structure to test. The following goal

```prolog
a(b, C, d(e, F, g(h, i, J))) = a(B, c, d(E, f, g(H, i, j)))
```

would succeed, and causes B to be instantiated to b, C to c, E to e, F to f, H to h, and J to j. What happens when we attempt to make two uninstantiated variables equal? This is just a special case of the first rule above. The goal succeeds, and the two variables *share.* If two variables share, then whenever one of them becomes instantiated to some term, the other one automatically is instantiated to the same term. A more technical way to say this is that the variables *co-refer:* that is, they refer to the same thing. So, in the following rule, the second argument will be instantiated to whatever the first argument is:

```prolog
equal(X, Y) :- X = Y.
```

An X = Y goal will always succeed if either argument is uninstantiated. An easier way to write such a rule is to take advantage of the fact that a variable equals itself, and write:

```prolog
equal(X, X).
```

Exercise 2.1: Say whether the following goals would succeed, and which variables, if any, would be instantiated to what values:

```prolog
pilots(A, london) = pilots(london, pans)
point(X, Y, Z) = point(Xl, Yl, Zl)
letter(C) = word(letter)
noun(alpha) = alpha
'studenf = student
f(X, X) = f(a, b)
f(X, a(b, c)) = f(Z, a(Z, c))
```

<!-- page 48 -->
## 2.5 Arithmetic

Many people use computers to do operations on numbers. Arithmetic operations are useful for comparing numbers and for calculating results. In this section we will see examples of each kind.

First, consider comparing numbers. Given two numbers, we can tell whether one number is equal to the other, or less than the other, or greater than the other. Prolog provides certain built-in predicates for comparing numbers. Actually these predicates evaluate terms that are treated as arithmetic expressions. The arguments could be variables instantiated to integers, or they could be integers written as constants, or they could be more general expressions. Here we will use these predicates just for comparing numbers, but later we'll use them in general arithmetic expressions. Note that we are allowed to write them as infix operators:

`X =:=Y X` and `Y` stand for the same number

`X =\=Y X` and `Y` stand for different numbers

```prolog
X < Y
```

`X` is less than `Y`

```prolog
X > Y
```

`X` is greater than `Y`

`X =< Y X` is less than or equal to `Y`

`X >= Y X` is greater than or equal to `Y` Note that the "less than or equal to" symbol is *not* written as "<=" as in many programming languages. This is done so that the Prolog programmer is free to use the "<=" atom, which looks like an arrow, for other purposes.

As these comparison operators are predicates, one might think it possible to write a Prolog fact as follows,

```prolog
2 > 3.
```

in order to assert that 2 is actually greater than 3. A fact like this one is perfectly wellformed Prolog. However, Prolog will not allow further facts to be added to predicates that are "built in" to Prolog. This prevents you from changing the meaning of built-in predicates in unexpected ways. In Chapter 6 we shall describe many of the built-in predicates, including all those we have met thus far.

As a first example of using numbers, suppose we have a database of the reigns of the Sovereign Princes of Wales in the 9th and 10th Centuries. The predicate `reigns` is defined such that the goal `reigns(X,Y,Z)` is true if the prince named `X` reigned from year `Y` to year `Z.` The list of facts in the database looks like this:

```prolog
reigns(rhodri, 844, 878).
reigns(anarawd, 878, 916).
reigns(hywel_dda, 916, 950).
reigns(Lago_apJdwal, 950, 979).
```

<!-- page 49 -->
```prolog
reigns(hywel_apJeuaf, 979, 985).
reigns(cadwallon, 985, 986).
reigns(maredudd, 986, 999).
```

Now suppose we want to ask who was on the Welsh throne during a particular year. We could define a rule, which given a name and a date, would search the database, and compare the given date aginst the dates of the reign. Let us define the predicate prince(X,Y), which is true if the prince named X was on the throne during year Y:

X was a prince during year Y if:

X reigned between years A and B, and

Y is between A and B, inclusive.

Now the first goal will be satisfied by using the `reigns` database above. The second goal is satisfied if `Y` is equal to `A,` or `Y` is equal to `B,` or `Y` lies between `A` and `B.` You can test for this by testing if `Y >= A` and `Y =< B.` Translating all this into Prolog, we obtain:

```prolog
prince(X, Y) :-
    reigns(X, A, B),
    Y >= A,
    Y =< B.
```

Here are some questions one might ask, with the answers that Prolog gives:

```prolog
?- prince(cadwallon, 986).
yes
?- prince(rhodri, 1979).
no
?- prince(X, 900).
X=anarawd
yes
?- prince(X, 979).
X=lago_ap_idwal
X=hywel_ap_ieuaf
yes
```

Notice the use of variables in the latter examples. Make sure you know how Prolog's searching mechanism allows questions like these to be answered.

<!-- page 50 -->
Arithmetic can also be used for calculating. For example, if we know the population and ground area of a country, we can calculate the population density of the country. The population density tells us how crowded the country would be if all the people were evenly spread throughout the country. Consider the following database about the population and area of various countries in 1976. We will use the predicate `pop` to represent the relationship between a country and its population. Nowadays, the populations of countries are generally quite large numbers. So, we will represent population figures in millions: `pop(X, Y)` means "the population of country `X` is about `Y` million people". The predicate `area` will denote the relationship between a country and its area (in millions of square miles). The numbers given here are not exact, but they will do for the purpose of demonstrating arithmetic:

```prolog
pop(usa, 203).
pop(india, 548).
pop(china, 800).
pop(brazil, 108).
area(usa, 3).
area(india, 1).
area(china, 4).
area(brazil, 3).
```

Now to find the population density of a country, we must use the rule that the density is the population divided by the area. This can be represented as the predicate `density,` where the goal `density(X,Y)` succeeds for country `X` having `Y` as the population density of that country. A Prolog rule for this is:

```prolog
density(X, Y) :-
    pop(X, P),
    area(X, A),
    Y is P / A.
```

The rule is read as follows:

The population density of country X is Y, if:

The population of X is P, and

The area of X is A, and

Y is calculated by dividing P by A.

<!-- page 51 -->
The "is" operator is new. The "is" operator is an infix operator. Its right-hand argument is a term which is interpreted as an arithmetic expression. To satisfy an "is", Prolog first evaluates its right-hand argument according to the rules of arithmetic. The answer is unified with the left-hand argument to determine whether the goal succeeds. In the above example, `Y` is unknown when the "is" is encountered, and it is up to the "is" to evaluate the expression, and let `Y` stand for the value. This means that the values of all the variables on the right of an "is" must be known.

We need to use the "is" predicate any time we require to evaluate an arithmetic expression. Remember that something like P/A is just an ordinary Prolog structure having the same "shape" as a structure like author(emily, bronte). But if we interpret a structure as an arithmetic expression, there is a special operation that can be applied to the structure: that of actually carrying out the bits of arithmetic and calculating the result. This is called *evaluating* the arithmetic expression. Not all structures can be evaluated as arithmetic expressions. Clearly we cannot evaluate structures such as the author one, because author is not defined here as an arithmetic operation.

Getting back to the population density example, it is not hard now to see that typical questions and their answers are:

```prolog
?- density(china, X).
X=200
yes
?- density(turkey, X).
no
```

In the first question, the *X=200* is Prolog's answer, meaning 200 people per square mile. The second question failed, because the population of Turkey could not be found in our example database.

Depending on what computer you use, various arithmetic operators can be used on the right-hand side of the "is" operator. All Standard Prolog systems, however, will have the following, as well as many more:

X + Y

the sum of X and Y

X - Y

the difference of X and Y

X * Y

the product of X and Y

X / Y

the quotient of X divided by Y

X / / Y

the integer quotient of X divided by Y

X mod Y the remainder of X divided by Y This list together with the above list of comparison operators should tell you nearly all you need for doing simple arithmetic problems.

## 2.6 Summary of Satisfying Goals

<!-- page 52 -->
Prolog performs a task in response to a *question* from the programmer (you). A question provides a *conjunction* of goals to be *satisfied.* Prolog uses the known *clauses* to satisfy the goals. A fact can cause a goal to be satisfied immediately, whereas a rule can only reduce the task to that of satisfying a conjunction of *subgoals.* However, a clause can only be used if it *unifies* the goal under consideration. If a goal cannot be satisfied, *backtracking* will be initiated. Backtracking consists of reviewing what has been done, attempting to *re-satisfy* the goals by finding an alternative way to satisfying them. Furthermore, if you are not content with an answer to your question, you can initiate backtracking yourself by typing a semicolon when Prolog informs you of a solution. In this section, we present a diagrammatic notation for showing how and when Prolog attempts to satisfy and re-satisfy goals.

### 2.6.1 Successful satisfaction of a conjunction of goals

Prolog attempts to satisfy the goals in a conjunction, whether they appear in a rule body or in a question, in the order they are written (left to right). This means that Prolog will not attempt to satisfy a goal until its neighbour on the left has been satisfied. And, when it has been satisfied, Prolog will attempt to satisfy its neighbour on the right. Consider the following simple program about family relations:

```prolog
female(mary).
parent(C, M, F) :- mother(C, M), father(C, F).
mother(john, ann).
mother(mary, ann).
father(mary, fred).
father(john, fred).
```

Let us look at the sequence of events that leads to answering the question:

```prolog
?- female(mary), parent(mary, M, F), parent(john, M, F).
```

<!-- page 53 -->
This question is to find whether `mary` is a sister of john. To do this Prolog needs to satisfy the following sequence of subgoals shown in Figure 2.1. We represent goals as boxes distributed down the page. An arrow starting from the top of the page indicates which goals have already been satisfied. Boxes that lie below the arrowhead represent goals that Prolog has not yet considered. Boxes that the arrow has passed through indicate goals that have been satisfied. As a program runs, the arrow moves up and down the page as Prolog turns its attention to the various goals. We call this the *flow of satisfaction.* In the example, the arrow starts at the top of the page, as shown above. It will extend downwards, moving through the three boxes as the three goals are satisfied. So the final situation will be as shown in Figure 2.2. Notice that values have now been found for the variables `M` and `F.` This diagram shows the coarse structure of what has happened, but it fails to show *how* these three

Fig. 2.1. A sequence of subgoals not yet satisfied

Fig. 2.2. The sequence of subgoals has been satisfied. Note that variables have been instantiated

goals were satisfied. We can show this by putting more detail inside the boxes. Let us concentrate on how the second goal is satisfied. Satisfying a goal involves searching the database for a *unifying* clause, then marking the place in the database, and then satisfying any subgoals.

<!-- page 54 -->
We can show this for the second goal by indicating in the parent box which clause was chosen and which subgoals had to be satisfied. The clause chosen is shown by a number in brackets, here (1). This number indicates which clause *out* *of the set of clauses for the appropriate predicate* has been chosen. So the number 1 indicates that the first clause for the predicate has been chosen. This is enough information to mark the place in the database. The subgoals are shown in small boxes inside the box for the goal. At the point when the `parent` clause has been chosen, the situation looks like Figure 2.3.

```prolog
parent(john, M, F)
```

Fig. 2.3. The number (1) indicates that the first clause for the predicate has been chosen. The subgoals are shown in small boxes inside the box for the goal.

<!-- page 55 -->
The arrow has entered the `parent` box and passed through the brackets indicating that a clause has been chosen. The clause has introduced two subgoals, involving `mother` and `father,` shown as the small boxes inside the goal box. At this point, the arrow must pass through these two smaller boxes, emerge from the current `parent` box and then pass through the second `parent` box in order for the question to succeed.

When the arrow passes through the smaller boxes, the same steps of choosing a clause and satisfying the clause's subgoals must be performed. In this example, both of these goals succeed by finding facts in the database, which give instantiations for variables M and F. So in Figure 2.4 we see a more detailed picture of the situation when the question succeeds.

<!-- page 56 -->
Note that to be precise we should have shown the details of how the goals female(mary) and parent(john, ann, fred) were satisfied. However, this would have been too much detail to fit onto one page. This example shows the general pattern of how Prolog attempts to satisfy goals in a case where the conjunction of goals sueceeds. The arrow moves down the page, passing through the boxes in turn. When it enters a box, a clause is chosen and its position marked. If the clause unifies with the goal and the clause is a fact, then the arrow can leave the box. This happened for the mother and father goals. On the other hand, if the clause unifies with the goal and the clause is a rule then new boxes are created for the subgoals and the arrow must then pass through all of these before it can leave the original box.

### 2.6.2 Consideration of goals in backtracking

When a failure is generated (because all the alternative clauses for a goal have been tried, or because you type a semicolon), the "flow of satisfaction" passes *back* along the way it has come. This involves retreating back into boxes that have previously been left in order to *re-satisfy* the goals. When the arrow gets back to a place where a clause was chosen (represented by a number in brackets), Prolog attempts to find an alternative clause for the appropriate goal. First, it makes uninstantiated all variables that had been instantiated in the course of satisfying the goal. Then, it searches through the database from where the place-marker was put. If it finds another unifying possibility, it marks the place, and things continue as in Section 2.6.1 above.

Note that work on any goals "below" this (even if such goals were tackled under the previous alternative) will always start from scratch. Prolog will try to satisfy, and not to re-satisfy them. If no other unifying possibility can be found, the goal fails, and the arrow retreats further until it comes to another place-marker.

In our example, if the goal parent(john, `ann,` fred) failed, the arrow would retreat upwards from the parent(john, `ann,` fred) box. Then it is necessary to reenter the big parent(mary, `ann,` fred) box from below, to attempt to re-satisfy this goal, as shown in Figure 2.5. Now after this point, it is necessary to retreat further. The arrow needs to reach the place where the clause for the father goal was chosen. First of all, all variablesjhat became instantiated as the result of using this clause are set back to uninstantiated. This means that `F` in the father goal becomes uninstantiated again. Then Prolog looks through the database, starting after the first father clause (the one marked), trying to find an alternative clause for this goal. Assuming that `mary` has only one father (a not unreasonable assumption), this will not succeed. So the arrow will have to retreat further. It retreats upwards, out of the father`(mary, F)` box (this goal has failed) and back into the mother(mary, ann) box (to attempt to re-satisfy this goal). We get the situation shown in Figure 2.6.

<!-- page 57 -->
We can see from these examples the general pattern of how goals are reconsidered in backtracking. When a goal fails, the arrow retreats upwards out of the box for the failing goal and back into the box for the goal above. The arrow continues retreating until it reaches a place marker. All variables that were instantiated as a result of

Fig. 2.5. What happens if a goal fails

the previous choice of clause are reset to uninstantiated. Then Prolog searches the database for a clause after the place marker. If it finds a clause that unifies with the goal, then a new place mark is recorded, boxes for the subgoals are created and the arrow starts moving downwards again. Otherwise, the arrow continues to retreat upwards, in search of another place marker.

### 2.6.3 Unification

The rules for deciding whether a goal unifies with the head of a use of a clause are as follows. Note that in the use of a clause, all variables are initially uninstantiated.

- An uninstantiated variable will unify with any object. As a result, that object will be what the variable stands for.

<!-- page 58 -->
- Otherwise, an integer or atom will unify with only itself.

```prolog
  female(mary)
1
     parent(mary, ann, F)
 (1)
                     father(mary, F)
     parent(john, ann, F)
      Fig. 2.6. Attempting to re-satisfy a goal
```

- Otherwise, a structure will unify with another structure with the same functor and number of arguments, and all the corresponding arguments must unify.

A noteworthy case in unification is one in which two uninstantiated variables are unified. In this case, we say that these variables *share* (or *co-refer).* 1\vo sharing variables are such that as soon as one is instantiated, so is the other (with the same value). If you have noticed a similarity between unification and making arguments equal (Section 2.4), then you are correct. This is because the "=" predicate attempts to make its arguments equal by unifying them. Now we can bring together what we have discussed about operators, arithmetic, and unification. Suppose the following facts are in the database:

```prolog
sum(5).
sum(3).
sum(X + Y).
```

<!-- page 59 -->
Consider the question

```prolog
?- sum(2 + 3).
```

Now, which one of the facts above will unify with the question? If you think it is the first one, then you should go back and read about structures and operators. In the question the argument of the sum structure is a structure having the plus sign as its functor, and having the 2 and 3 as its components. In fact, the goal shown will unify with the third fact, instantiating X to 2, and Y to 3. On the other hand, if we actually wanted to compute a sum, we would use the "is" predicate. We would write

```prolog
?- X is 2 + 3.
```

or, just for fun, we could define a predicate add that relates two integers with their sum:

```prolog
add(X, Y, Z) :- Z is X + Y.
```

In this definition, X and Y must be instantiated.
