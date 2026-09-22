# 1. An Introduction to Prolog

<!-- page 12 -->
Prolog is an unconventional language. In particular, its data structures are quite different from those found in other programming languages. As it is dif¿cult to talk about a computation without understanding the sort of data that can be processed, we shall discuss data structures at some length before coming to the question of how to do anything with them. I-lave patience.

## 1.1 Data Structures

1.1.1. Constants

Constants are the primitive building blocks of data structures. Constants have no structure, so they are often called “atoms.” They represent only themselves—they can be thought of as identical with their names.

In Basic or Fortran, I951 is a constant. The integer variable J is not, because it represents both a memory cell and—in certain contexts—a value. The value is something quite different from the variable itself.

One is accustomed to treating I95] as a number greater than I948, but this is because in programming languages constants usually belong to certain types. The usual properties of integer constants (their ordering, ability to be used in arithmetic operations, etc.) are taken for granted by virtue of their belonging to the type Integer, just as in Pascal blue is a successor of red when one writes

<!-- page 13 -->
colour = ( red, blue, green ) Such type de¿nitions impose a certain structure on the otherwise undifferentiated universe of individual symbolic constants, each of which has only one attribute: its name.

The interpretation of a constant rests solely with the programmer. I95l can be the price of a computer, the weight of a truck, the time of day or a year of birth. One can always multiply it by 4, but this seldom makes sense when it represents a ear‘s registration number. The constant blue is less burdened with inadequate interpretations, but one might wish not to have the colours ordered. Constants are the primitives, and collecting them into types should only be done when necessary.

In Prolog, as in other symbolic languages (such as Lisp) there is no need to declare constants or group them into types. One can use them freely, simply by writing down their names.

A legal constant name is one of the following: —A sequence of digits, possibly pre¿xed by a minus sign; by convention,

such constants are called Integers (e.g. 0, -7, I951);

--An identi¿er, which may contain letters, digits and underscores but

must begin with a lower case letter (e.g. q. aName. number_9); —A symbol which is a nonempty sequence of any of the following char-

acters:

+

—

1-

/

<

=

>

.

?

$

&

(rt)

#

\

—- —Any one of the characters

,

or

;

or

! —The symbol [] (pronounced “nil"); —A quoted name, written according to the Pascal convention for strings:

an arbitrary sequence of characters enclosed in apostrophes, an

apostrophe being represented by two consecutive apostrophes (e.g.

‘Can"t do this.‘ consists of I4 characters).

All of these constants are purely symbolic and have no inherent interpretation. However, some primitive operations in Prolog do treat them in a special way: —Arithmetic operations interpret integers as representations of integer

values (they can also create new integers): —Comparison operations interpret integers as integer values. and all

other constants as representations of the sequences of characters form-

ing their names (these are lexicographically ordered by the underlying

collating sequence); —Input/output operations interpret all symbols as sequences of charac-

<!-- page 14 -->
ters forming their names.

Each occun'ence of a constant's description (name) is treated as referring to the same constant, but of course we are free to interpret each separately.

1.1.2. Compound Objects

An important aspect of the expressive power of a programming language is its ability to directly describe various data structures. Of the popular and widely used languages, Pascal is the most powerful in this respect, but it has several shortcomings. (This is not a criticism of Pascal: our point of view does not take into account important design objectives such as a safe type mechanism.)

Firstly, type de¿nitions in Pascal are overspeci¿ed. It is impossible to program general algorithms which process stacks or trees regardless of the type of their elements. (Records with variants are only a rough approximation to generic data types found in some more recent programming languages.)

Secondly, those data structures which change their form dynamically can only be built with pointers. One must therefore deal with the structures at a very low level: the level of representation rather than the conceptual level at which many other things are done in Pascal. Programs using pointers are en'or-prone and hard to understand, because operations on such data structures are encoded rather than directly expressed.

The third shortcoming has a similar effect. Ironically, Pascal types are also underspeci¿ed. in that there is no way to directly express certain quite natural constraints on the arguments of operations. One cannot say that the function POP can only be applied to a non-empty stack; one can only write a piece of code (hopefully con'ect) which checks the argument.

It is interesting that these shortcomings are not shared by Prolog data types (or rather by their counterparts, since “type” is not really a Prolog concept). And yet Prolog data structures are very simple. Let us look at the details.

FuNCTORS

To describe a compound object, it is not enough to list its components. The ordered pair (I9, 24) can be an object of the type

rectangle = record

height, width : integer

<!-- page 15 -->
end as well as an object of the type

timcofday = record

hour, minute : integer

end

The complete description of a compound object must include a de¿nition of its structure. Structure is de¿ned principally by describing the way in which the object and its components are intenelated. Describing these intenelationships often consists in simply giving a type name to an aggregate of components (as in the example above). It is the programmer's responsibility to interpret this name in terms of real-world relations between entities being modelled by the program.

In conventional programming languages, the structure of a compound object is usually described in a declaration associating the object with a type de¿nition. The type de¿nition lists the name of the object—component relationship (type name) and, possibly, additional information about the structure (types) of the components. The object is described by its name (or the name of a pointer). The name's de¿nition is textually remote from its occunences.

A different approach is taken in Prolog. Here, the type name is an integral part of all the occurrences of the object's description. The notation is very simple: a description of a compound object is the type name followed by a parenthesized sequence of descriptions of its components, separated by commas. We write either

```prolog
rectangle( I9, 24 )
```

or

```prolog
timeofday( I9, 24 ).
```

The notation is similar to that used for writing functions in mathematics. Terminology reÀects this similarity. The type-name is called a functor, and the components are called arguments. There is more to it than super¿cial similarity of two simple syntactic conventions. One can certainly regard a type such as rectangle as a function mapping components into compound objects. From this point of view it is not surprising that we can have functors with no arguments: these are simply constants. Sometimes it is also useful to have oneargument functors. For example, the integer 2 can be represented by the object successor(successor(zero)) (the fact that 2 > I > 0 is evident from its structure).

From the discussion above, it should be obvious that the important attributes of a functor are both its name and its arity (i.e. the number of arguments it takes). In Prolog, we can use both

```prolog
timeofday( I7, I3 )
```

<!-- page 16 -->
and

```prolog
timeofday( I7I3 )
```

in the same program. Even if the intended interpretation is the same, these are two different objects: one has two components, and the other has one. There are also two different functors, both named timcofday. Whenever we speak of a functor in a context which gives no indication of its arity, the arity must be given explicitly. The usual notation is to write it after a slash: timcofday/2 or timcofday/I.

The lexical rules for forming functor names are the same for all arities. but integers can only be constants. Thus

I23( a, b ) is incorrect, but

‘l23’( a, b ) is perfectly all right. Also, [] is only a constant.

Oruscr Dsscatrrtous

Descriptions of constants and compound objects are referred to as tenns. Usually, the objects themselves are also called terms: this causes no confusion in practice, but in this chapter we shall try to distinguish between the two meanings.

The arguments of a temt are arbitrary terms. For example, one can write a term describing a “record”:

```prolog
customer( name( john, smith ),
          address( strect( north_ave ), number( I73 ) ) ).
```

Of the various functors in this example, the outermost, customer/2, can be said to de¿ne the general structure of the temi. It is called the main functor, or principal functor. Similarly, name/2 is the main functor of the ¿rst argument.

Here is another example of a common data structure. A list can be de¿ned as either the empty list, or a list constructed of any object (a head) and a list (a tail). A list of the ¿rst three letters in the alphabet could then be descn'bed by the term

```prolog
cons( a, cons( b, cons( c, emptylist ) ) ).
```

The following term would be a description of the two-element list constructed of the above list and a list containing the integer zero:

```prolog
cons( cons( a,cons( b,cons( c,emptylist ) ) ),cons( 0,emptylist ) )
```

<!-- page 17 -->
Even this small example demonstrates that nested parentheses can be dif¿cult to read. Prolog therefore provides syntactic sugar to hide this standard or canonic form of terms. Instead of writing

```prolog
successor( successor( zero ) )
```

one can choose to use successor as a pre¿x functor and write

successor successor zero. Alternatively, successor can be made a post¿x functor:

zero successor successor.

Functors with two arguments can be declared as in¿x functors, e.g.

&( a, b ) can be written as

a & b. The term

a & b & c would be ambiguous, so an in¿x functor is either left-associative or rightassociatlve (or non-associative. in which case the term is incorrect). If & is right associative, the term‘s standard form is

**&(a.&(b.¢));**

if & is left-associative, then the term stands for

&(&(a,b),c). We can use parentheses to stress or override associativity. If & is rightassociative, then

**a&b&c**

is equivalent to

a & ( b & c ) but not to

( a & b ) & c, which stands for

<!-- page 18 -->
&( &( a, b ). C ) regardless of associativity.

To make parentheses even less frequent, pre¿x, post¿x and in¿x functors are given priorities. Functors with lower priority take precedence over those with a higher priority (a Prolog-I0 convention, different from that used in other programming languages and mathematics). For example, if the priority of 1- is lower than that of +, then

3 1- 4 + 5

and

5 + 3 1' 4 denote

**+(*(3.4).5)**

and

+(5."'(3.4)) We can use parentheses to stress or override priorities, by writing

(31-4)+5

or

31-(4+5).

Pre¿x, post¿x and in¿x functors are usually referred to by the generic name operators. Remember that these are not operators in any conventional sense: they are only a syntactic convenience.

Operator names may not be quoted. If an operator is to be written in standard form or with a different number of arguments, it must be quoted. If + is an in¿x functor,

a+ b,

'+‘(a,b)

and

’+‘(a,b,c) are correct terms, but

+

and

+( a, b ) are not.

It is also possible to declare mixed operators, i.e. functors such as the minus sign, which is both pre¿x and in¿x in ordinary arithmetic. Details about declaring pre¿x, post¿x and in¿x functors can be found in Sections 5.I and 5.7.3.

For the time being, we shall only use in¿x functors to write terms representing lists. However, instead of

a cons b cons c cons emptylist we shall use a more concise notation, modelled after Lisp. The empty list will be denoted by the constant l] (pronounced “nil“), and the constructing functor — by the right-associative in¿x functor ./2. Our two lists are then written as

a.b.c.[] and

<!-- page 19 -->
( a.b.c.[] ).0.[] The convention is arbitrary, in that any constant and two-argument functor would do in place of [] and the dot. It is more convenient than others, because these are the symbols expected by several built-in procedures.

(You can write such terms after feeding Prolog with

```prolog
:- op( 800, xfy,
                 ).
```

However, a minor technical dif¿culty makes it impossible to use the period as a functor when it is immediately followed by a white space character, such as blank, tab or new line. This is a nuisance, and Prolog provides special syntactic sugar for lists: it is somewhat confusing, so we will put it off until Chapter 4.)

Sraruos

Characters are constants whose names consist of single characters. One can use quoted names for characters which are not correct identi¿ers (e.g. ‘ ’, ’(', ’3’; and ‘x’ is equivalent to x).

Strings are lists of characters. One can also write them in double quotes. For example

"string"

and stand for

s.t.r.i.n.g.[]

and

‘

**"‘.[]**

(Actually, the convention adopted in this book is different from that of Prolog-I0. There, a string denotes a list of ASCII codes and not a list of characters, so "string" stands for

ll5. I I6. I I4. I05. I l0.l03.[]. Similarly, in Prolog- I0 operations for reading and writing characters deal directly with ASCII codes. We refuse to accept these conventions.)

1.1.3. Variables

Objects discussed so far are all, in a sense, constant. Their structure is ¿xed, we know everything about them and cannot learn anything new. A programming language in which one could specify only such fully de- ¿ned objects would hardly be interesting. One must be able to use objects whose complete form is de¿ned dynamically during a computation.

<!-- page 20 -->
In Prolog, the simplest such as-yet-unknown objects are called variables (do not confuse them even for a moment with the variables of conventional programming languagesl). The term denoting a variable is called a variable name (this is also usually called a variable: as with terms and objects, we shall try to maintain the distinction throughout chapter I). A variable name is written as an identi¿er starting with an upper case letter or an underscore (e.g. Q, Number_9, _nnn).

A variable is an object whose structure is totally unknown. As a computation progresses, the variable may become instantiated, i.e. a more precise description of the object may be determined. The term embodying this description is called the variable‘s instantiation. An instantiated variable is identical with the object described by its instantiation, so it ceases to be a variable, although the object can still be referred to through the variable’s name. (In general, a variable may be instantiated also to another variabIe—we shall soon see the meaning of this.)

There is also an altemative terminology. One says that a free (or unbound) variable becomes bound to another term and is henceforth indistinguishable from that term (which is called its binding). The variable becomes ground if its binding contains no variables. This terminology brings to mind the process of binding formal parameters to actual parameters. If the formal parameters were not allowed to change their value (as in pure Lisp, say), the similarity would be very close indeed. except that a binding need not be ground.

intuitively, Prolog variables are somewhat like the variables used in mathematics. When we say that

**fl!) = 6’ + 3x**

is a function of one variable, we mean that the equation allows us to determine the function‘s value for any (one) given argument. The variable denotes a single (albeit arbitrary) substitution and is not in itself an object to which values can be assigned.

You can also regard a Prolog variable as an “invisible” pointer. When not free, the pointer is automatically dereferenced in all contexts, so it is impossible to distinguish it from the referenced object: in particular, it is impossible to exchange the object for something else.

1.1.4. Tenns

<!-- page 21 -->
If one thinks of a type as a set of objects, then a term is also a de¿nition of a type. The term VariabIe3 describes the set of all objects, because a variable can be instantiated to anything. On the other hand, one can have a very precise type speci¿cation. For example, the term a.b.c.[] describes a set containing only one object: the list of length 3, whose ¿rst element is a, whose second element is b and whose third element is c. There is a wide range of choices between these extremes. I0

I An Introduction to Prolog

We describe objects by de¿ning those of their properties which we ¿nd interesting in a given context. We do so by using variable names to denote objects (in particular: components of other objects) whose exact form is either unknown or unimportant. Our descriptions thus denote sets of objects satisfying the explicitly formulated properties.

A few examples should make it clear:

I. painting( Painter, 'Saskia’ )

—all ‘Saskia‘s of an unknown artist

2. painting( rembrandt, Picture )

**-all pictures by Rembrandt**

3. painting( rembrandt, picture(Title,l646) )

—alI pictures painted by Rembrandt in I646

4. Head.Tail

—alI non-empty lists

5. One.Two.Three.[]

—alI lists of three elements

6. One.Two.l3.Tail

—all lists containing at least three elements, such that the third ele-

ment is the number I3.

Actually, our comments in examples 4 and 6 are somewhat imprecise, as they reÀect an intended interpretation. Since a variable name denotes an arbitrary object, the type Head.Tail contains more than true lists: the object one.two also answers this description. Similarly, the term in example I describes objects such as painting(59, ‘Saskia’). Term notation does not allow us to express directly our wish to consider only paintings whose ¿rst arguments are the names of painters. This is in keeping with the principle that the type of a compound object is de¿ned primarily by the intenelationship between the object and its components, rather than by the types of the components. The restriction is not necessarily a bad thing: we shall see that a procedure popping an element off a stack is most naturally written so that it can handle all stacks, whatever the types of their elements. If one considers it important to restrict the types of components, one can do it easily enough (we shall see how), but only consciously and only when needed.

<!-- page 22 -->
As a computation progresses, variables in various terms may become instantiated. As a result, more is known about the objects described by these terms. We extend our terminology so that we can talk about instantiating terms and terms which are instantiations of other tenns. For example, f(X).Tail is an instantiation of Head.Tail; and it may, in due course, be further instantiated to a yet more precise description. As we shall see,

l.2. Operations

I I

such a multi-step approximation to a desired description is very characteristic of Prolog.

We have proposed to regard a term as a type de¿nition, i.e. a description of a class of objects, or altematively as a description of a single, as yet unde¿ned object. These are two sides of the same coin. A single object whose fomr is known only in general outline can be thought of as a representative of the class of all objects having that form. A term denotes a set by virtue of denoting any one of its possible instantiations.

A comment on the role of variable names. They are used as handles on the objects they denote. Through a name we can, at any moment, look at what we have actually leamed about the shape of the object. For example, no matter what the instantiation of Head.Tail, the variable name Head denotes the ¿rst element of this list. The term X.X.Tail is also quite legal in Prolog and denotes a list whose ¿rst and second elements are the same object.

Notice that we said “the same object,“ not “identical objects." It is important to note that different compound objects can share components. In general, Prolog temrs describe data structures which can be represented as directed acyclic graphs (DAGs). If we use an arrow to denote the relation of “being built of" (X —> Y means that Y is a component of X), then Fig. I.l illustrates the object denoted by

```prolog
one( two( A.B ), three( A.B. C ), B ).
```

Sometimes one is not interested in certain objects and needs no name to refer to them. Such terms can be denoted by anonymous variables, each of which is written as an underscore. For example

a._._.b.[]

describes a list of length four whose ¿rst and last elements are a and b. The second and third elements can be any two different objects, or the same object: we don't care.

## 1.2 Operations

<!-- page 23 -->
The majority of operations in a Prolog program are calls to procedures de¿ned by the user. Standard operations—addition, comparisons, input! output etc.—are used relatively infrequently. For uniformity, every operation is written as if it were a procedure call, and the principal property of all standard operations is only that they need not (and must not) be de- I2

I An Introduction to Prolog

it

**\**

**@")*:E‘""—iE**

**‘kg;**

**®m—B‘E\**

FIG. l.I

Recurring components of an object.

¿ned by the user. Standard operations are accordingly called built-in procedures (or system procedures).

Procedure calls are written according to the usual practice. The procedure name is followed by an optional list of terms—actual parameters, enclosed in parentheses and separated by commas, e.g.

```prolog
show( painting(rembrandt,X), etching(rembrandt,X) ).
```

The “procedure name" is often called a predicate symbol (sometimes shortened to predicate). Like functors, a predicate symbol has two attributes: a name and an arity. Two distinct procedures can share the same name, provided one has a different number of parameters than the other.

<!-- page 24 -->
Procedure calls (and, as we shall see, procedure de¿nitions) have the same syntax as temis. This notational uniformity is useful when programs are dynamically modi¿ed (as is normally the case during an interactive session), but it may be confusing for the uninitiated. We shall try to help by reserving the word "argument" for components of terms: procedures will be said to have parameters.

l.2. Operations

I3

Some versions of Prolog-—including those described in this bookcarry this uniformity to the point of allowing the user to use pre¿x, post¿x and in¿x notation for predicate symbols (such symbols are also called “operators"). This is achieved exactly as for functors, but a number of frequently used symbols are usually predeclared to give the language a more conventional Àavour. A case in point is the built-in procedure is, whose name is written in in¿x notation. It expects its second parameter to be an "expression": a term representing the abstract syntax tree of an integer arithmetic expression; the tree is evaluated and the result is retumed through the ¿rst parameter. The two-argument functors + , -, 1-, I and mod are predeclared as in¿x functors with conventional priorities and associativity. so one can write

VisX—7—Y1=Zmod(2+X) to instantiate V to an integer (provided the instantiations of X, Y and Z are integers or “expressions”).

Sequences of procedure calls use commas for separators, for example:

```prolog
buy( picture(rembrandt,Title), Price ),
  NewPrice is Price 1- I35/I00,
    seII( picture(rembrandt,Title), NewPrice ),
      drink( beer )
```

(We shall enlarge on this in Sections 1.2.2 and I.3.I.)

We shall need two built-in procedures for our examples: — nl/0 terminates an output line;

**-- write/I outputs a temr (variables are written as XI, X2, etc.); for**

example, if A and B are uninstantiated, then

write( f('an id',g(A,B),7,A) ), nl

writes

```prolog
f( an id, g( XI, X2 ), 7, XI ).
```

More precise descriptions of system procedures can be found in Chapter 5. We shall now see how to de¿ne user procedures.

1.2.1. The Simplest Fonn of a Procedure

Try to think of a procedure which computes the head and the tail of a list: we shall call it carcdr. What should its speci¿cation be like?

<!-- page 25 -->
Let the list be the ¿rst parameter and let the second and third parameters retum its head and its tail. Head and tail are de¿ned only for non- I4

I An Introduction to Prolog

empty lists, so the ¿rst parameter‘s type is described by the term Head.Tail (Ql .Q2 would do just as well, but it is better to use meaningful names). This type speci¿cation is most naturally written in the procedure heading, thus

carcdr( Head.Tail,

) If a list is denoted by Head.Tail, then Head denotes its head and Tail denotes its tail. We can therefore write

```prolog
carcdr( Head.Tail, Head, Tail ).
```

The fullstop temrinates the speci¿cation. It is rather concise, but it contains all the necessary infomration; the procedure is called carcdr and has three parameters; the ¿rst parameter must be a non-empty list, the second parameter is to become the head, and the third is to become the tail of this list.

It turns out that what we have written is also the complete de¿nition of this procedure in Prolog. The call

```prolog
carcdr( l.2.3.[], H, T)
```

instantiates H to

I

and T to 2.3.[]. (Recall that l.2.3.[] is really

-(I.-(Z.-(3.lI)))

.)

Actually, our de¿nition is somewhat more general, because—as we have already pointed out—Head.Tail need not be a list, as no conditions are imposed on the form of its tail. But this does not matter: there is no misunderstanding about the desired effect of, say

```prolog
carcdr( timeofday( I2, 30 ).any( Object,”at all" ). F, S ).
```

What we have here is a general procedure for getting at the ¿rst and second arguments of a term whose main functor is ./2.

We shall now specify the reverse of carcdr: a procedure which retums, via its third parameter, a list constructed of its ¿rst and second parameters. We shall call it cons.

We do not really mind if the ¿rst two parameters are not lists, so there are no restrictions on their types:

cons( Object, Another,

) If Object describes an object and Another describes an object, then applying the list constructor to the two gives us a third object, whose description is Object.Another. This term is suf¿cient as a speci¿cation of the third parameter, so we get

```prolog
cons( Object, Another, Object.Another ).
```

<!-- page 26 -->
I .2. Operations

I5

Here, again, we have a complete de¿nition of this procedure. But notice that the order of parameters has no meaning in itself, so we might as well have decided to pass the constructed list through the ¿rst parameter:

```prolog
cons( Object.Another, Object, Another ).
```

Variable names have no inherent meaning either, so cons is really the same as carcdr. Indeed, when we read out the speci¿cation of carcdr, we cheated a little: “the parameter must be,“ or “the parameter is to become"-these distinctions were not present in the speci¿cation.

While both carcdr and cons could be so named to reÀect their intended use, they are both really a single procedure

```prolog
conscarcdr( Head.Tail, Head, Tail ).
```

This is not very surprising, as cons is the reverse of the coin of which carcdr is the face.

Now the call

```prolog
conscarcdr( l.2.3.[I. H, T)
```

instantiates H to I and T to 2.3.[] and the call

```prolog
conscarcdr( L, a, b.[] )
```

instantiates L to a.b.[ ]. But how is it done? We shall come to that, as soon as we have cleared up a point of syntax.

1.2.2. Directives

In versions of Prolog deriving from Prolog-I0, the syntax of a simple procedure de¿nition such as our conscarcdr example need not necessarily differ from that of a procedure call. The meaning is de¿ned by context.

Such Prolog systems function in two modes: the command mode and the de¿nition mode. Command mode is the default.

<!-- page 27 -->
In command mode, the system reads and executes directives. The directives are read in from the user’s terminal or from a ¿le. Each directive is terminated by a fullstop (the character., immediately followed by a white space character, including newline), and is either a query or a command. A query is a procedure call or a sequence of procedure calls separated by commas. Roughly, its execution consists ofexecuting its call and printing the resulting variable instantiations (see the end of Section I.2.3 for a more precise description). For example, if conscarcdr has been lb

I An lntroduction to Prolog

de¿ned, then after reading the query

```prolog
conscarcdr( l.2.3.[], H, T ).
```

the system writes

**H =l**

T=2.3.[] (The actual printout might be in the special syntax used for lists; see Section 4.2.1.)

A command has the form of a query pre¿xed by the symbol :-. Its calls are executed but the variable instantiations are not written out automatically. To get the same printout with a command, one would write

```prolog
:- conscarcdr( l.2.3.[], H, T),
    write(‘H = ’), write( H ), nl,
    write(’T = '), write( T ), nl.
```

The terminology is somewhat Àuid: directives are often called goal statements, while queries and commands are not always recognized under those names. (Sometimes there are also slight syntactic differences. We try to follow the original de¿nition of Prolog-l0, but in this book the standard is set by the version of Prolog described in Chapter 7.)

De¿nition mode is entered upon executing the system procedure consult/l or reconsult/l. (The argument is the name of the ¿le from which procedure de¿nitions are to be read; user is the name of the user's terminal. The details are in Section 5.11.) ln this mode, the system accepts procedure de¿nitions, which are also terminated by fullstops. Our de¿nition of conscarcdr is an example, but see Section l.3.l for the complete syntax. Commands are allowed and properly executed in this mode, but queries are not. De¿nition mode is exited when the system encounters the de¿nition

```prolog
end.
```

A note about comments in Prolog. A comment starts with a % character (not contained in a string or quoted name) and extends till the end of line. Be careful not to place a comment immediately after a dot that terminates a clause: a fullstop is required.

As a point of interest, all directives and the basic building blocks of procedures (called clauses—we will describe them in due time) are simply single terms. Standard operator declarations include the in¿x functor , (comma) and the pre¿x functor :-. so the directive

```prolog
:- p( 2, X ), write( X ), nl.
```

is really the term

<!-- page 28 -->
‘I-‘( '.'( P( 2. X ). '.'( write( X ). nl ) ) )-

l.2. Operations

I7

This data structure is interpreted as a directive, so you need not worry about these things unless you are an advanced Prolog hacker.

There is one important point, though probably you will ¿nd it obvious. The actual parameters of procedure calls are the current instantiations of terms directly written in the call. Thus

```prolog
:- conscarcdr( a.b.[], H, T ), conscarcdr( L, H, T ), write( L ), nl.
```

will print out

a.b.[]

1.2.3. Uni¿cation

Since we succeeded in packing the whole de¿nition of conscarcdr into its heading—the part specifying its name and formal parameters—we can expect that its execution boils down to applying a suf¿ciently powerful and general parameter-passing mechanism. This mechanism is implemented by a term-matching operation called uni¿cation.

We will describe this operation by a pidgin—PascaI algorithm. The function UNIFY is applied in tum to each formal and actual parameter pair. Ifit retums true for all such pairs of terms, we say that uni¿cation is suocesful (or succeeds); otherwise uni¿cation fails. Uni¿cation fails when the terms describing the parameters do not match. In a very general sense this means that the types of actual parameters are incompatible with those of the fomral parameters. function UNIFY ( var Actual, Formal : term ) : boolean; var success : boolean; be-gin success:= true;

if Formal is a variable then

Formal is instantiated to Actual

else

if Actual is a variable then

Actual is instantiated to Formal

else

if the main functors of Formal and Actual have

different names or arities then success:= false

else

while success and unmatched arguments remain do

success:= UNIFY( next argument of Actual,

next argument of Fomral );

<!-- page 29 -->
UNlFY:= success end; I8

I An Introduction to Prolog

Notice that if we treat both the call and the procedure heading as terms, then the process of matching successive pairs of parameters is subsumed by the loop in UNIFY. We extend our terminology accordingly, and say that—like a pair of terms—a call and a procedure heading do or do not match. Altematively, we say that they do or do not unify (are or are not uni¿able). The algorithm uni¿es matching terms. Uni¿ed terms are indistinguishable, so they describe the same object.

If both Formal and Actual describe variables, then uni¿cation binds them together. Variables which are bound together also represent the same object: both their names refer to the same variable. (It is pointless to ask whether the formal becomes an instantiation of the actual or the other way round. Our algorithm implements the latter case, but this is not observable from the outside. You can envisage a set of bound-together variables as a chain of invisible pointers.)

Time for a very detailed analysis of a simple example: the procedure

```prolog
p( A. b( c. A ) )
```

called with the query

```prolog
p(X.b(X,Y)).
```

Figure l.2 shows the situation immediately before uni¿cation. The horizontal line separates objects local to the directive and objects local to

caller

callee

FIG. l.2

<!-- page 30 -->
Uni¿cation: before matching.

I .2. Operations

I9

the procedure. Note that objects—including variables—are accessible both directly through their names and as components of other objects.

The ¿rst pair of parameters is matched by binding X and A together. The variables will behave as if they had merged into a simple object (somewhat like two drops of water). This object is accessible under two different names (Fig. l.3).

The second pair of parameters is uni¿ed in two phases. First, c becomes the instantiation of the “amalgamated” variables X and A. They cease to exist as variables, but c is now also accessible through the name A inside the procedure and through the name X outside (Fig. 1.4).

In the second phase Y is instantiated to the instantiation of A. The object c is now accessible as c, A, X and Y (Fig. l.5).

The procedure p now terminates, but its local object c remains, being accessible from the outside as X or Y. The instantiation of b( X, Y ) is b( c, c ) (Fig. 1.6).

It is convenient to use a special notation for showing the effects of uni¿cation. We shall write

A <— B.[] instead of “A is instantiated to B.[]”; and

A <-> B instead of “A and B are bound together.”

**/Q.if?**

**Q**

- z::.':.'

FIG. l.3

<!-- page 31 -->
Uni¿cation: the ¿rst pair of parameters is matched. /

G. l.4 Uni¿cation: the ¿rst pair of b‘s arguments is matched

caller I g 4 callee

FIG. l.$ Uni¿cation: matching was successful. El l l X

-(

<!-- page 32 -->
I'D FIG. l.6 Uni¿cation: the callee is terminated.

I .2. Operations

2|

Here are some example calls to our procedure

```prolog
conscarcdr( Head.Tail, Head, Tail ).
```

l. conscarcdr( element.[], Car, Cdr )

Head <— element, Tail <— [],

Car <— element, Cdr <- [].

2. conscarcdr( L, one.two.[], 3.4.5.[] )

L <— Head.Tail, Head <— one.two.[],

Tail <- 3.4.5.[].

Hence the instantiation of L is

(one.two.[] ).3.4.5.[]

3. conscarcdr( A.B, 2, 2.[] )

A <-> Head, B <-> Tail,

Head <— 2 (and hence also A <—- 2 ),

Tail <— 2.[] (and hence also B <— 2.[] ).

The instantiation of A.B is now

2.2.[].

4. conscarcdr( A.B.C, I0, [] )

A <—> Head, Tail <— B.C,

Head <— I0, failure.

Uni¿cation fails. This is not surprising, as the ¿rst actual parameter

describes a list of at least two elements, while the list constructed of

the second and third actual parameters would have only one element.

We shall wind this up with four general remarks.

First, we want to stress that the uni¿cation algorithm treats actual and formal parameters absolutely symmetrically. This results in a very characteristic property of Prolog: there is no difference between formal parameters used to bring information into a procedure and those used to carry information out of a procedure. The direction of information Àow changes from call to call, as in examples l and 2 above. We can even make a parameter serve both for input and for output. An example is the call

```prolog
conscarcdr( A.2.[], l, B) .
```

Here, Head <— A and Tail <—- 2.[]; then Head <- l ( and therefore A <— l ) and B <— 2.[] . The result is that the ¿rst formal parameter was used both for obtaining information (that 2.[]) and for yielding information (that I).

<!-- page 33 -->
This multi-way functioning of procedure parameters sometimes makes it possible to use procedures in unexpected ways. Whenever we Z2

I An Introduction to Prolog

shall say that a procedure does this and this, we shall not worry about what it does after an “unreasonable” call. But you might ¿nd thinking about these things a useful exercise.

The second remark: effects of uni¿cation such as merging two variables are quite consistent with the interpretation of terms as descriptions of types. We shall illustrate this with a very simple example. The following two procedures accept only three-¿eld records whose neighbouring ¿elds are identical:

¿rst2( record( Fieldl2, Fieldl2, FieId3 ) ).

```prolog
last2( record( Fieldl, Field23, Field23 ) ).
```

Each of these procedures can be thought of as imposing a constraint on a description of the record type. The constraints are not mutually inconsistent, so the directive

```prolog
:- ¿rst2( record( Fl,F2,F3 ) ),
  last2( record( FI,F2,F3 ) ),
  write( record( FI,F2,F3 ) ), nl.
```

writes out the description of a record whose three ¿elds are identical:

```prolog
record( XI, XI, XI ).
```

Similarly, the query

¿rst2( record( F l,F2,¿eld ) ), last2( record( F l,F2,¿eld ) ). is answered with

Fl = ¿eld

F2 = ¿eld

Third, the convention that only the most interesting aspects of an object are captured in a type description tumed out to be quite useful. Example 3 would not have worked if the type of the ¿rst formal parameter had speci¿ed that the tail must be a proper list. The term A.B would not have been accepted.

The fourth, and last, remark. If you follow the uni¿cation algorithm carefully, you will notice that it can create cyclic data structures. For example, if the procedure

```prolog
same( X, X ).
```

is invoked with

<!-- page 34 -->
same( f( V ), V ), write( V ), nl.

I.2. Operations

Z3

then we are in trouble. First, X <— f(V); then V <—X, that is to say V <— f(V). As a result, f becomes its own component and the printout will be potentially in¿nite:

f(f(f(f(f(f(f(f(f(f(f(f( .... Such cyclic structures can also cause trouble during uni¿cation. If we write

same( f( V ), V), same( f( W), W), same( V, W ),... then the uni¿cation algorithm will not terminate for the third procedure call (this will probably manifest itself as recursion stack overÀow): f matches f, their ¿rst arguments are both f, and their ¿rst arguments are both f, and so on.

All this could be avoided if a variable were not uni¿able with a term in which that variable occurs. The uni¿cation algorithm is borrowed from automatic theorem proving (see Chapter 2). The original algorithm contains this occur cheek, but most versions of Prolog do not, as it considerably increases the algorithm’s time complexity. Fortunately, cyclic stnictures seldom occur in practice, and one learns to live with the knowledge that terms are not always DAGs if one blunders badly. One version ofProlog (Prolog II; see Section 9.2) is built to take advantage of cyclic data structures. They are called in¿nite trees and are treated as bona ¿de representations of graphs arising in the real world. If one is careful, one can use such stnictures even in more conventional Prolog systems: an example is the calltree program listed in Appendix A.4.

1.2.4. Clauses

If we want a procedure which computes the fourth element of a list, we can write

```prolog
fourth( _._._.E4._, E4 ).
```

But this method is useless if we want the n-th (or even the hundredth) element.

After parameters are passed, a procedure can—just as in other languages—execute a sequence of operations. For example, a procedure which prints the fourth element of a list would be:

```prolog
fourth( _._....E4._ ) :- write( E4 ). nl.
```

<!-- page 35 -->
Its body is a sequence of calls, separated by commas and pre¿xed by a :-. As you see, a command is like a procedure without a heading.

A procedure heading, possibly followed by a body, is called a clause. We shall now see how to use clauses for less trivial tasks.

## 1.3 Control

1.3.1. The General Fonn of a Procedure

What happens when uni¿cation fails?

Part of the answer is that a procedure can consist of a number of clauses. All these clauses must have headings with the same predicate symbol, but the parameter speci¿cations may differ. When uni¿cation of a call with the ¿rst clause's heading is successful, the ¿rst clause executes its body (if any). When uni¿cation fails, its effects are undone: all variables which were instantiated by the attempt at uni¿cation are restored to their original, unbound state. The call is then matched against the heading of the second clause. If this is successful, the second clause is executed; otherwise the third clause is attempted and so on. To execute a procedure is thus to execute the ¿rst of its clauses whose head matches the call (but see the next section for a re¿nement of this statement). Roughly, the matching clause contains code for that particular combination of parameter types.

An elementary example is provided by an extended version of the procedure carcdr of Section l.2.l.

```prolog
carcdr( Head.Tail, Head, Tail ).
```

carcdr( l], _, _ ) :- write( ‘can“t crack empty list‘ ), nl.

Here is a somewhat less trivial example, an immortal classic of introductory Prolog courses. It is a procedure which appends a list at the end of another list:

```prolog
append( Hd.Tl, List, Hd.TlAndList ) :-
                                 append( Tl, List, TlAndList ).
append( []. List, List ).
```

All terms written in a clause are local to that clause. Both occurrences of List in the ¿rst clause refer to the same variable, which has nothing to do with the variable named List in the second clause. The second clause might as well have been

```prolog
append( ll. QI4, Q14 ).
```

<!-- page 36 -->
As in other programming languages with recursion, activation of a clause is accompanied by creation of new instances of all its local objects.

I .3. Control

Z5

The tenns appearing in the clause describe these instances. Before an attempt to unify a call with a clause heading can be made, a new instance of the clause is created. When uni¿cation fails, the instance is destroyed.

Armed with this knowledge, we can now watch the effects of calling append in the query

```prolog
append( a.b.[], c.d.[], Result ).
```

**For clarity, we shall use X ‘, X etc., to denote different instances of a**

variable named X.

The original call will successfully activate the ¿rst clause, after the following instantiations:

Hd‘ <- a, Tl’ <— b.[], List’ <— c.d.[],

Result <— a.TIAndList' (because Hd' is now a). This clause will execute the call

```prolog
append( b.[], c.d.[]. TlAndList‘ ),
```

activating a second instance of the ¿rst clause:

Hd" <— b, TI” <— [], List" <— c.d.[],

TlAndList’ <— b.TlAndList“ . In this instance, the body is

```prolog
append( []. c.d.[], TlAndList“ ) .
```

This call does not match the ¿rst clause‘s heading, so the second clause is used:

List"' <— c.d.[], TlAndList" <—- c.d.[] . The third instance of append has no calls to execute, so it returns to the second instance. The second instance is done with its body, so it retums to the ¿rst instance, which also terminates. The variable Result was instantiated to a.TlAndList’,

and TlAndList’

to b.TlAndList”,

and TlAndList" to c.d.[]. Therefore, the query can be answered with

Result = a.b.c.d.[]

It is sometimes useful to represent the state of a computation by the sequence of calls which must be executed. The sequence is often called the current resolvent (see Section 2.4). If we use our procedure in the directive

```prolog
:- append( a.b.[], c.d.[], Result ), write( Result ), nl.
```

<!-- page 37 -->
then the successive resolvents are as follows: Z6

I An Introduction to Prolog

append(a.b.[],c.d.[],ResuIt), write(Result), nl.

append(b.[ ],c.d.[ ],TlAndList’), write(a.TlAndList’), nl.

append([],c.d.[],TlAndList"), write(a.b.TlAndList"), nl.

write(a.b.c.d.[]), nl. ?':'*1""!*’:"‘ E. When no calls remain, the directive is terminated.

Here is the procedure to ¿nd the n-th element of a list. Its ¿rst parameter is n and the second a list. The third parameter retums the n-th element of the list; if the element does not exist, the constant ? is retumed and an error message is printed. It is assumed that the ¿rst parameter is not negative (we will leam how to check this in the next section). The procedure is

```prolog
nth( 0, _, ? ) :- write( ‘nth( 0...... )??' ), nl.
nth( N, [], ? ) :- write( ‘nth( ..,too short,.. )??’ ), nl.
nth( I, El.-. El ).
nth( N, _.Tail, El ) :- M is N — I, nth( M, Tail, El ).
```

Do trace its execution for a few examples.

1.3.2. Baektraclring

But what if a call matches none of the clause headings? An example is the call

```prolog
conscarcdr( notalist, something, other )
```

This suggests the answer. If none of the clauses ¿ts the call, then evidently the call is wrong: its set of actual parameters does not conform to any of the type speci¿cations describing parameters acceptable to the procedure.

<!-- page 38 -->
As in other modem programming languages, such an erroneous call does not abnormally terminate a program's execution but activates an error-handling mechanism. In contrast to other languages, however, the error is not necessarily handled by an active procedure present on the activation stack. Prolog uses a more general method and takes into account even those procedures which retumed to their caller after successful termination. Procedure instances are looked at, one by one, in reverse order of their activation. The nearest such procedure instance—call it p— which contains as-yet-unactivated clauses matching its call is assumed to be able to handle the situation. The computation is undone: its state is made to appear as if the heading of p‘s most recently activated clause did not match its call, and p is given a chance to execute other clauses.

This process is called backtracking, and a call which does not match any clause heading is said to fail. Backtracking closely resembles our behaviour in systematically searching for a solution to a problem. If we end up in a blind alley, we get back to the nearest point at which we could have applied another approach, and apply it. If no approach seems to be working at that point, we retum to the previous point in which we apparently made a wrong choice, and so on.

In implementation terms, each time a selected clause is not the last in its procedure, a record is pushed onto a special stack of fail points (also called choice points). The record contains all information necessary to restore the state of the computation. When a procedure fails, the topmost fail point is popped off the stack, the state described by it is restored and the computation proceeds with the next clause.

It is important to note that not all effects of a computation are obliterated on backtracking. Some system procedures do things which cannot be undone, such as writing infonnation on a terminal screen. We say that these procedures have side-effects.

Using our description of backtracking, try to follow the execution of procedure p in the following example:

**P =- q(X). writ¢(t1'yins(X)). nl.**

female( X ), write( ok ), nl.

```prolog
p :- write( ‘Sorry!’ ), nl.
q( X ) :- writer( X ).
q( ? ) :- write( ‘No more writers.’ ), nl.
writer( hesse ).
writer( mann ).
writer( grass ).
female( austen ).
female( sand ).
```

You should get the following printout:

```prolog
trying( hesse )
trying( mann )
trying( grass )
No more writers.
trying( ?)
Sorry!
```

<!-- page 39 -->
You may have noticed from this example that error handling is somewhat inadequate as a metaphor for backtracking. This is the subject of the next section. 1.3.3. I-low to Use Backtracking

When a procedure instance is backtracked to, it behaves as if its most recently activated clause did not match its call. We can therefore use backtracking to implement extended type checking.

Recall from Section l.l.4 that we found it impossible to write terms which could describe properties such as “the object is a painter's name” or “the tail is a properly constructed list.” In other words, while rather powerful in certain respects, this kind of type speci¿cation is weak in others. This can be remedied by using procedures which do additional type checking and either fail or successfully terminate, depending on the outcome. If we want procedure q to accept only properly constructed representations of paintings, we can write

```prolog
q( painting( Painter, Name ) ):-
  ispainter( Painter ), process( painting( Painter,Name ) ).
ispainter( rembrandt ).
ispainter( velasquez ).
```

Here, the role of ispainter is similar to the declaration of an enumeration type in Pascal.

Prolog has several built-in procedures which can be used to check properties of objects. For example, one can check whether the object denoted by Something is an integer, by seeing whether the call

```prolog
integer( Something )
```

succeeds or fails.

A number of built-in procedures implement comparison operations. Like is, procedures for comparing integer values “evaluate” terms resembling conventional arithmetic expressions. The procedures are <, =<, =:= (equality), =\= (inequality), >= and >. Their names are predeclared as in¿x predicate symbols. For example the call

**7*2+5=:=I+3*6**

will be successful. There are also procedures comparing non-integer constants according to their lexicographic ordering: @<, @= <, @> = , @>. For example,

alpha @> beta is a failing call.

<!-- page 40 -->
Equality of constants can be determined by means of the procedure = (= is predeclared as in¿x). The procedure is most easily expressed in Prolog

X=X. It can be used for any two terms, but of course it does more than checking equality. It may cause its parameters to become equal, as it attempts to unify them. For example,

```prolog
a(b.X)=a(Y.¢)
```

will succeed after instantiating

X <— c, Y <— b . Note that 7=7 succeeds, but 5+2=2+5 fails, as these are different terms.

Remember that all these procedures do not yield a Boolean result: they only succeed or fail.

When we are interested in the structure of a compound object, we can use a recursive procedure which does nothing but “accepting” the object. Here is a version of carcdr which works only for true lists and fails for objects such as a.b.c (but not for objects with variable tails, which match ll)-

```prolog
carcdr( Head.Tail, Head, Tail ) :- islist( Tail ).
islist( [] ).
islist( _.L ) :- islist( L ).
```

Such type checking can be quite general. For example, we can process objects differently according to whether they are or are not members of a set represented by a list:

```prolog
process( Obj, Set ) :- member( Obj, Set ),
                    yes-action( Obj ).
process( Obj, _ ) :- no_action( Obj ).
member( El, El.Tail ).
member( El, _.Tail ) :- member( El, Tail ).
```

Try to trace the execution of process for a couple of simple calls, and notice how member is called with successively shorter tails of the list, until it ¿nds a tail whose head is uni¿able with the ¿rst parameter.

<!-- page 41 -->
The fact that the ¿rst clause of member expresses uni¿ability rather than equality has very interesting consequences. The most obvious is that the procedure can be used to retrieve information from a dictionary represcnted by a list. The call member( phone( krull, Number ),

```prolog
phone( mann,II ).phone( hesse,5 ).phone( krull,II ).[] )
```

**instantiates Number to ll.**

When this information-retrieving effect is coupled with backtracking, the result is rather striking. Consider the procedure intersect( Ll, L2 ) :- member( E, Ll ), member( E, L2 ). When given two sets represented by lists, the procedure terminates successfully if the sets intersect and fails if they are disjoint. Here is a trace of what happens when we call it with intersect( a.b.c.d.[], c.d.[] ), write( ok ), nl. I. intersect(a.b.c.d.[],c.d.[]), write(ok), nl. (this activates the procedure:

Ll <— a.b.c.d.[], L2 <— c.d.[]

2. member(E,a.b.c.d.[]), member(E,c.d.[]), write(ok), nl. (activates the ¿rst clause of member:

E<->El’,El’<—a)

3. member(a,c.d.{]), write(ok), nl. (only the second clause matches the call)

4. member(a,d.[]), write(ok), nl. (only the second clause matches the call)

5. member(a.[]). write(ok), nl. (the call to member fails, nearest “handler” is in the procedure activated in step 2, so we backtrack to that situation)

6. member(E,a.b.c.d.[]), member(E,c.d.[]), write(ok), nl. (the second clause now:

E <—> El‘, Tail‘ <— b.c.d.[])

7. member(E,b.c.d.[]), member(E,c.d.[]), write(ok), nl. (the ¿rst clause:

E <—> El”, El” <- b)

8. member(b,c.d.[]), write(ok), nl.

9. member(b,d.[]), write(ok), nl. I0. member(b,[]), write(ok), nl. (failure, backtracking to step 7) ll. member(E,b.c.d.[]), member(E,c.d.[]), write(ok), nl. (the second clause now:

E <—> El”’, Tail”' <— c.d.[]) I2. member(E,c.d.[]),member(E,c.d.[]), write(ok), nl. (the ¿rst clause:

<!-- page 42 -->
E <—> El””, El”” <— c)

l.3. Control

3]

I3. member(c,c.d.[]), write(ok), nl.

(the ¿rst clause) I4. write(ok), nl. I5. nl. Success.

Notice how the ¿rst call to member in intersect is used as a “backtrack driven" generator of successive elements on the list. A terminated procedure can be reactivated if the effects of its execution prove unsatisfactory. It can retum several results—or behave in several ways—and its ¿nal effect is determined not only by its actual parameters, but also by what happens to the computation later on. It is this multiplicity of possible behaviours that we have in mind when we say that, in general, a Prolog procedure is nondeterministic. (This does not mean that its behaviour cannot be predicted to the smallest detail.)

If one wants to see all the results produced by a nondeterministic procedure, one can force Prolog to backtrack by calling an unde¿ned procedure (the call will fail, because there is no matching clause). It is customary to use the name fail, both for readability and because Prolog makes it impossible to declare a procedure with this name. To print the elements of a list, one can write

```prolog
:- member( E, a.b.c.[] ), write( E ), nl, fail.
```

Altematively, one can use a query. After answering a query, the system accepts a single printing character from the terminal. If the character is a semicolon, it backtracks; otherwise it terminates the query. When all the possibilities are exhausted, the word no is printed and the system reads another directive. For example,

user:

```prolog
        female( W ).
system: W = austen
user:
        ;
system: W = sand
user:
        ;
system: no
```

If a successful query contains no non-anonymous variables (i.e. no instantiations to show), the answer is yes.

Our intersect example does more than check for common elements. If the elements are not ground, the sets are modi¿ed. For example,

```prolog
intersect( one.X.three.l]. I.Y.[] )
```

<!-- page 43 -->
succeeds after binding Y to one. This has a natural explanation. Since Y is unknown, we cannot say that the sets do not intersect, but by binding Y we ensure that the computation will fail if the supposition that Y is one will turn out to be unacceptable. We shall then assume that X is I, that X and Y are the same object, etc., etc.

1.3.4. Static Interpretation of Procedures

Detailed simulation of a program is not a very attractive way of leaming its meaning. We insisted on doing it to help you understand what happens inside the computer and to introduce techniques which can sometimes be useful for debugging, when things are not happening the way they should. But it is often quite clear what should happen, as many Prolog procedures can be read without giving a thought to details of execu¿on.

A clause which has no body is called a unit clause. It is a direct de¿nition of a relation between its parameters. The clause

```prolog
phone( hermann, 5 ).
```

says that hermann and 5 are in the relation phone. Other clauses can extend the relation to other objects:

```prolog
phone( mann, ll ).
phone( hesse, 5 ).
phone( krull, II ).
```

Unary relations can be thought of as expressing properties of objects:

```prolog
red( herring ).
red( square ).
```

Nullary relations can denote general facts:

```prolog
tired.
debugging.
```

A look at the clauses of phone tells that the call

```prolog
phone( siddhartha, N )
```

will fail, and the call

```prolog
phone( Who, 5 )
```

<!-- page 44 -->
will nondeterministically produce hermann and (after a failure) hesse. Note that the calls can be read as “establish whether the actual parameters are in the relation phone, i.e. succeed if they are in the relation, or instantiate them so that they will be in the relation and succeed, or fail.”

Somewhat less trivially, the unit clause

```prolog
conscarcdr( Head.Tail, Head, Tail ).
```

can be used to establish whether the ¿rst parameter is a list formed of the second and third parameters. It is self-evident that l. conscarcdr( a, b, c ) fails, because the objects are certainly not in the

relation;

2. conscarcdr( A.2.B, l, C.[] ) succeeds, because there does exist a list

of at least two elements whose second element is 2, such that its head

is I and its tail is a one-element list—the list is I.2.[] and the tail is 2.[ ];

3. conscarcdr( A, B, B.[] ) succeeds, because there do exist objects A

and B such that A is a list constructed of B and B.[]—A is B.B.[] and

B can be any object.

Nonunit clauses are indirect de¿nitions of relations. Thus

**F; 1'11- ri-**

:'I',“.""’'-II"

append(

append(

```prolog
append( T, L, TL ).
```

can be read as

“L is L appended to [],” and

“H.TL is L appended to H.T tfTL is L appended to T.” It is usually convenient to flavour this a little with the intended meaning, as in

“a list L appended to an empty list is L itself,” and

“a list L appended to a non-empty list H.T is formed of the head of

that list, H, and the result of appending L to its tail, T.”

And. most spectacularly.

```prolog
intersect( Ll, L2 ) :- member( E,Ll ), member( E,L2 ).
```

reads:

**“Ll and L2 intersect ifan object E is a member of Ll and a member**

of L2”. in other words

“two lists intersect if they have a common member.”

<!-- page 45 -->
You will ¿nd more about this in Chapter 2. But note here that this interpretation does not fully explain procedures such as process of Section l.3.3—this is further discussed in Section 4.3.l. 1.3.5. The Order of Calls and Clauses

In practice, static interpretation is not always suf¿cient to explain a program's behaviour. It cannot account for the order of calls in a clause and the order of clauses in a procedure, because “x and y” means the same as “y and x.” Yet this order is important, for three principal reasons.

The ¿rst reason is that some procedures, such as write and nl, have side-effects, i.e. their results are not only variable instantiations. The order in which several things are written has an obvious effect on the form of the printout.

Another important reason is ef¿ciency. Here is a famous example (Kowalski I974) of a naive naive sort:

```prolog
sort( List, Sorted ) :- permute( List, Sorted ),
                    ordered( Sorted ).
```

The procedure generates successive permutations of a list until it ¿nds one that is ordered. If permute and ordered can be used both to check their parameters and as generators, then this could also be expressed as

```prolog
sort( List, Sorted ) :- ordered( Sorted ),
                    permute( List, Sorted ).
```

Here, successive ordered lists are generated until a permutation of the ¿rst parameter is found. Both procedures express the same de¿nition of a sorted list, but while the ¿rst is only very costly, the second is absolutely useless.

A third reason is that all computations should be ¿nite. We will illustrate this point with the procedure append, which can be written either as

```prolog
append( H.T, L, H.TL ) :- append( T, L, TL ).
append( ll. L. L ).
```

or, apparently equivalently, as

```prolog
append( ll. L. L ).
append( H.T, L, H.TL ) :- append( T, L, TL ).
```

<!-- page 46 -->
Both versions are equivalent when append is used for appending. But note that its precise reading from section 1.3.4 allows for other uses. For example the second clause, “H.TL is L appended to H.T if TL is L appended to T,” de¿nes H.TL in terms of H.T and L, but also H.T and L in terms of H.TL. Indeed, append is often used for splitting a list. If one executes

```prolog
:- append( Front, End, a.b.c.[] ),
    write( Front ), write( ' & ' ),
    write( End ), nl, fail.
```

then the ¿rst version of append will produce (after successive failures)

a.b.c.[] & []

a.b.[] & c.[]

a.[] & b.c.[]

[] & a.b.c.[] and the second version

[] 8:. a.b.c.[]

a.[] & b.c.[]

a.b.[] & c.[]

a.b.c.[] & [].

This difference is not very important. But when we write

```prolog
append( Ll, a.[], L3)
```

we expect that append will succeed, after instantiating the terms so that L3 is a.[] appended to Ll. The second version doesjust this: Ll 1- [] and L3 <— a.[]; then, if we backtrack, LI <— XI.[] and L3 1- XI.a.[]; then, if we backtrack again, Ll <— Xl.X2.[] and L3 <— Xl.X2.a.[]; and so onthere are in¿nitely many such solutions.

The ¿rst procedure, however, ¿rst looks for the last solution in this in¿nite set, and this causes endless recursion.

Nevertheless, with careful programming, considerations of this sort are needed only to obtain re¿nements of the general meaning of procedures given by their static interpretation. Moreover, the order of calls and clauses is usually a local thing, seldom requiring looking beyond a single procedure.

1.3.6. The Cut

We shall now pass on to so-called extralogical features of Prolog. These are simple and powerful mechanisms which play a large part in making Prolog a practical programming language, but cannot be understood in terms of static interpretation, as outlined in Section 1.3.4.

<!-- page 47 -->
Since we have generators, we must be able to stop them. Suppose that we have two methods for ¿nding the solution of a problem described in temis of two sets. Assume one of these methods is signi¿cantly cheaper than the other, but a necessary—though not suf¿cient!—condition for its applicability is that the problem-de¿ning sets intersect. We might write something like

```prolog
try( Setl, Set2, Solution ) :-
    intersect( Setl, Set2 ),
    methodl( Setl, Set2, Solution ).
try( Setl, Set2, Solution ) :-
    method2( Setl, Set2, Solution ).
```

Now if methodl fails, we want to try method2. But if the sets are large and have many elements in common, we are effectively stopped by a generator. Backtracking from methodl will cause intersect to ¿nd another way of showing that the sets do indeed intersect: this changes nothing, so methodl will be attempted again and again until intersect enumerates all the elements in the intersection of Setl and Set2. In terms of processing time, this might be a disaster. And note that we are lucky: the generator is not in¿nite.

To help in such cases, Prolog provides a commit operation, written as I and called the cut procedure (old Prolog hands tend to call it the slash, after the character /, which was its name in the original Marseilles Prolog). When procedure p executes a cut, everything that was done by p up to that moment—including its choice of current clause—is taken as ¿xed and not to be reconsidered on backtracking. In implementation terms, ! cuts away the top section of the fail point stack, leaving only fail points created before p was called.

Our problem can be solved by modifying intersect:

```prolog
intersect( Ll, L2 ) :- member( E, Ll ),
                   member( E, L2), !.
```

The cut kills the generator of elements from LI.

A more involved example might be useful in clearing up doubts about the effects of a cut. We will try to move a single cut around in our example of section 1.3.2:

```prolog
p :- q( X ), write( trying( X ) ), nl,
    female( X ), write( ok ), nl.
p :- write( ‘Sorry!’ ), nl.
q( X ) :- writer( X ).
q( ? ) :- write( ‘No more writers.‘ ), nl.
writer( hesse ).
writer( mann ).
writer( grass ).
```

<!-- page 48 -->
<!-- page 49 -->
female( austen ). female( sand ). If we insert a cut into the ¿rst clause of writer: writer( hesse ) :- !. the printout will be trying( hesse ) No more writers. trying( ?) Sorry! If we insert it into q instead: q( X ) :- !, writer( X ). we will get trying( hesse ) trying( mann ) trying( grass ) Sorry! But if we choose to insert it at the end of this clause: q( X ) :- writer( X ), I. the program will write trying( hesse ) Sorry! By inserting the cut after the call to q in the ¿rst clause of p, we would obtain only trying( hesse ) As evidenced by these examples, the cut is a powerful tool. A single cut can drastically alter the behaviour of a program. It must be used very carefully: Section 4.3.1 contains some useful hints. An important property of the cut is that it can be used to implement a sort of negation. When we want to list all male writers, we can write :- writer( X ), male( X ), write( X ), nl, fail. If, however, the program contains only descriptions of female persons (as in our example), we must de¿ne male in terms offemale: male( X ) :-female( X ). !, fail. malet _ ). When X is such thatfemale succeeds, the second clause of male is cut off and the whole procedure fails. When female fails, the second clause takes over and the procedure succeeds. The trick is dirty, but very useful. One must be careful, however: if the constant christie is not listed among the females, male(christie) will succeed. (More on this in Section 4.3.2.)

1.3.7. Variable Calls

The negation schema shown in the previous section is of quite general utility. For example, we could write a procedure for checking that two sets (represented as lists) do not intersect:

```prolog
disjoint( SI, S2 ) :- intersect( SI, S2 ), !, fail.
disjoint( _, _ ).
```

Prolog provides a very convenient extension which allows us to use such schemas without going to the trouble of rewriting them again and again. A variable call is a variable occupying the position of a call in a clause or directive. When the tum comes to execute the call occupying this position, the variable's current instantiation is taken as the call, by treating its main functor as a predicate symbol and its arguments as parameters. If we de¿ne

```prolog
do( X ) :- X
```

then the call

```prolog
carcdr( el.[], A, B)
```

is exactly equivalent to

```prolog
do( carcdr( el.[], A, B ))
```

as well as to

```prolog
do( do( carcdr( el.[], A, B ) ) ) .
```

We can use this feature to de¿ne

```prolog
not( X ) :- X, !, fail.
not( _ ).
```

and write

```prolog
male( X ) :- not( female( X ) ).
disjoint( SI, S2 ) :- not( intersect( SI, S2 ) ).
```

<!-- page 50 -->
The dirty trick is now nicely packaged.

In versions of Prolog described here, not is prede¿ned and the predicate symbol is predeclared as a pre¿x symbol. Expanding male in-line, we would write the directive of Section 1.3.6 as

```prolog
:- writer( X ), not female( X ), write( X ), nl, fail.
```

Variable calls can be used to de¿ne many useful procedures. We shall end by showing two companions of “not”: “and” and “or.” The ¿rst is written as a comma and the second as a semicolon; the ¿rst succeeds when both its pararneters—taken as calls—succeed, and the second succeeds when either of its parameters succeeds (but establishes a fail point if it is the ¿rst one). Their de¿nitions are

```prolog
',’( A, B ) :- A, B.
’:'( A._):- A-
':‘( _. B) 1- B-
```

Comma and semicolon are predeclared as in¿x symbols. After de¿ning do, we could write the directive above as

```prolog
:- do( ( writer( X ), not female( X ), write( X ), nl, fail ) ).
```

The extra parentheses are needed to avoid confusion with a call to do/5.

Priorities are chosen so that

```prolog
artwork( X, Y ) :- painting( X, Y ), oil( Y );
                 etching( X, Y ), brass( Y ).
```

is equivalent to

```prolog
artwork( X, Y ) :- ‘;'( ',’( printing( X,Y ),oiI( Y ) ),
                 ','( etching( X,Y ),brass( Y ) ) ).
```

To make the comma and semicolon appear a part of ProIog’s syntax, Prolog-I0 and some of its offsprings made the cut behave somewhat differently for these procedures: they are “transparent” to it. Thus

```prolog
artwork( X, Y ) :- painting( X, Y), oil( Y ), ! ;
                 etching( X, Y ), brass( Y ).
```

avoids checking the second altemative if the ¿rst succeeds.

A similar exception applies to variable calls. If the procedure

a(X):-b,X.

<!-- page 51 -->
a(_):-c. is called with

```prolog
a( ( d, !, fail ))
```

then the cut will commit all choices made by d and b and a—the procedure will fail without executing c.

One should avoid taking advantage of this peculiar property of the cut. It is doubtful whether it is necessary.

