# 4. Simple Programming Techniques

<!-- page 97 -->
I j

**SIMPLE PROGRAIVIMING**

i’

7171

## 4.1 Introduction

Programming in Prolog differs from programming in classical (Pascalstyle) languages primarily at the level of individual procedures. The larger the program, the more suitable the general recommendations of programming methodology. The advantages of systematic top-down design of programs, modularity‘, clean interfaces, etc., are certainly independent of the programming language used. Design and coding techniques speci¿c to Prolog are due to its logical origin.

In Section 1.3.4 and Chapter 2 we discussed logical—static—interpretation of procedures. This interpretation makes it possible to design programs without paying attention—at least initially—to how the computation will proceed. One only needs to indicate what will be computed. Kowalski (I974, 1979a) coined an “equation”,

Algorithm = Logic + Control which helps clarify the distinctive feature of logic programming. It is maintained that logic programming relieves the programmer of the burden of specifying control information for her program. One would like to say: completely relieves, but unfortunately (at least in Prolog) this is not the case. Many useful built-in procedures, such as the cut, input/output and program modi¿cation procedures (assert, etc.; see Section 5.11), cannot be interpreted statically. As a result, a practical program may not usually be designed without paying regard to control information.

<!-- page 98 -->
' At least on a conceptual level: most existing Prolog implementations do not support it explicitly.

In Section 4.3 we shall brieÀy consider the advantages and disadvantages of some side-effects in Prolog; we shall also present several simple tricks that help increase the ef¿ciency of Prolog programs (especially their space requirements) in many existing implementations. Earlier, in Section 4.2, we shall give a few examples of Prolog implementation of commonly used data structures, in particular binary trees and linear lists. We shall show basic operations on those structures and a few typical applications. Section 4.4 contains small examples of program design.

## 4.2 Examples of Data Structures

We have chosen unbalanced binary search trees (BSTs) and one-way linear lists as an illustration of methods of implementing recursive data structures in Prolog. We assume you are familiar with basic de¿nitions and algorithms; a detailed, though rather elementary presentation can be found, for example, in Wirth (1976) or Sedgewick (I983). Here, we shall refer only to common intuitions, and we shall concentrate on problems speci¿c to Prolog.

V

We shall also brieÀy discuss representation of data structures by clauses—in particular, Prolog counterparts of anays.

4.2.1. Simple Trees and Lists

Terms can usually be regarded as trees: the main functor labels the root, subtrees correspond to arguments. This is slightly imprecise, because multiple occurrences of variables represent more general structures—directed acyclic graphs (DAGs). However, the term f(A, A) which should be depicted as

t

can be thought of as

A

<!-- page 99 -->
A We must only remember that the two subtrees will remain identical, so instantiating variables in one will affect the other. Another dif¿culty is that it is possible to compute tenns which are not even DAGs, and which should therefore be regarded as corresponding to in¿nite trees (see Section l.2.3). All the same, an ordinary tree is a good intuition of the (general) term.

Terms are a convenient and concise representation of trees with irregular structure, where the information in the nodes detennines both the shape of the tree and the repertory of applicable operations. The abstract syntax tree of Fig. 3.3, Section 3.3, is a typical example. However, programs that manipulate such irregular structures are usually problem-dependent, in that every principal functor (i.e. every type of node may require diÀ'erent computations).

There are other situations, typi¿ed by binary search trees, when we need a more uniform representation, because we use trees for contents rather than for structure. Suppose we represent the BST of Fig. 4.1 as the term

```prolog
few(people(many(languages), speak))
```

Even if we disregard the ambiguity (is “languages” the left or right descendant of “many”?), main functors and their arguments must be isolated, that is, we must use the built-in procedure = .. (“univ”; see Section 5.10). To modify the tree, e.g. by adding a node, we must rebuild it completely, also using univ. This is not only inelegant, but ineÀicient as well (but see Section 4.2.6 for a discussion of such techniques).

We shall therefore represent empty binary trees by the atom

**fevv\**

people

**../ \...**

FIG. 4.1

<!-- page 100 -->
A binary search tree.

2

**fl/...\.**

**./.\. .%l.\.**

**À\**

nil

languages nil

FIG. 4.2

A representation of the tree of Fig. 4.1.

and nonempty trees by three-argument terms

```prolog
t( Left_subtree, Node_info, Right_subtree )
```

For example, the BST of Fig. 4.1 will be represented by the term

```prolog
t( nil, few, t( t( t( nil, languages, nil ), many, nil ),
            people, t( nil, speak, nil ) ) )
```

The term can be drawn as a tree (see Fig. 4.2). This method of representing binary trees can be readily adapted to trees of a different ¿xed degree. e.g. non-empty temary trees can be represented by four-argument terms

```prolog
tt( Node_info, Left_subt, Middle_subt, Right_subt )
```

In Fig. 4.2 the contents of each node is only a key, but of course in practical applications nodes contain other information as well. The tree shown in Fig. 4.3 holds names and phone numbers of several personsnames are keys in lexicographic order. We use a nonassociative in¿x functor ‘:‘ to separate keys from other data.

<!-- page 101 -->
An inorder traversal of a BST visits the nodes in increasing order, according to the ordering relation in the set of keys. For example, the

'1:

t

thompson 2432

**\7**

**\**

nrl

rncbr|de:l7Bl

nil

FIG.4.3

Another BST.

following procedure can be used to write out name-phone pairs, sorted alphabetically by names:

uritc_sorted( nil ). ur1te_sorted( tt LeFt_subtreev Node_infov Risht_subtree

)

)

=-

urite_sorted( Left_subtree)v

write( N0de_inF0)v

nlr

```prolog
write_sortud( Risht_subtree).
```

In this procedure, we need not test the actual ordering of nodes; this would not be the case if we wanted, say, to locate a node in a tree. Let the call

```prolog
precedes( Nodel, Node2 )
```

succeed iff Nodel comes before Node2. For our name-number pairs the procedure can be de¿ned simply as

```prolog
precedes( Namel :_, Name2 :_ ) :- Namel Gr»< Name2.
```

<!-- page 102 -->
It is reasonable to expect that nodes are correctly built, e.g. that each key is a name, and other information a number. A good place to check this would be a procedure for inserting a node into a tree:

```prolog
insert( Node, Tree, Newtree ) :-
    con'ect( Node ), !, ins( Node, Tree, Newtree ).
insert( Node, _ , _ ) :- signal_error( Node ).
```

However, such defensive programming is seldom necessary in practice.

The insertion procedure ins is rather straightforward. We must only take care to preserve the ordering relation:

Z on emote tree will

be replaced by o new leaf ins( Nader nilv t( nil:

Noder nil

)

). ins( Node: tt Leftv Root: RiSht)r tt Neuleftr Rootr Risht

)

)

```prolog
                                                        :-
precedest Node:
                Root )1
                          ins( Nodev Leftr Neuleft ).
```

ins( Nnder t(

LOFLr

Root: Ri9ht)r t( Left!

Root: Neurisht

)

)

=-

DPGCGdG5( Root:

Node

)1

```prolog
ins( Noder Rishtr Neurisht ).
```

The procedure fails when it tries to duplicate a key (both calls on precedes fail). If the keys need not be unique, we must relax one of the tests, e.g. by changing

```prolog
precedes(Root, Node)
```

into

not precedes(Node, Root)

A BST can be built by successive insertions. We shall not discuss balanced trees. They present problems of their own, which can be solved by far in the same way as in classical programming languages (see e.g. Sedgewick 1983) but which can cause memory problems with some Prolog implementations. One example is an AVL-tree insertion program (van Emden 1981, Vasey 1982).

We need some thought to delete a node even from an unbalanced tree. If either of the subtrees of the deleted node is empty, the other subtree moves up and replaces the node. For example, deleting adams : _ from the tree in Fig. 4.3 gives the tree in Fig. 4.4. Suppose now that both subtrees are nonempty; we shall preserve the ordering if we replace the deleted node by that with the largest key in the left subtree (or else that with the smallest key in the right subtree).

<!-- page 103 -->
For example, deleting thompson : _ in Fig. 4.3 gives the tree in Fig. 4.5.

FIG. 4.4

The tree of Fig. 4.3 alter deleting adams : _ .

t

**/\ /\**

mt

tndxmeÀÀl

ml

¿t

wmne1M32

mt

The following procedures implement this algorithm. The second

clause is for symmetry (and for ef¿ciency) but it is not really necessary. delt Node1 Lt n111

Node1 Risht )1 Risht ). de1( Noder t( Left1

Noder nil

)1 Left). delt Node1 tt Left1

Node1 Risht )1 tt Newleftv Leftnoxr Rilht

)

)

I-

```prolog
remove_mox( Left1 Leftmox1 Newleft ).
```

de1( Noder tt Left1 Rootr Risht )1 tt New1eft1 Root1 Risht

)

)

8-

orecedest Node1 Root )1

```prolog
de1( Node1 Left1 Newleft ).
```

delt Node1 t( Left1 Rootr Risht )1 tt Left1 Root1 Newriaht

)

)

8-

precede5( Root1 Node )1

```prolog
de1( Nodev Riahtr Newriaht ).
```

Z find and remove the node with the lorsest key remove_mox( tt LeFt1

Hox1 nil

)1

Hoxr Left ). remove_mox( t( Left1 Rootr Risht )1

Hox1 t( Leftr Root1 Newrilht

)

)

I-

remove_mox( Ri9ht1

Hax1 Newrisht )-

Nonnally we would call the procedure del with only the key given.

We might encapsulate such calls:

```prolog
delete( Key, Oldtree, Newtree ) :-
    del( Key : _ , Oldtree, Newtree ).
```

<!-- page 104 -->
-E

**/\ A\**

nil

adams=54BB nil

nil

white:2t.32

nil

FIG. 4.5

The tree of Fig. 4.3 after deleting thompson : _.

The last basic operation on BSTs is the search itself:

search( Node1 tt

"1

Node1

_

)

).

search(

Node1 tt Left1

Root1

_

)

)

=-

erecedest Node1 Root )1

```prolog
                                  search( Node1 Left ).
search( Node1 tt
                 _1
                    Root1 Risht
                                 )
                                   )
                                      =-
        nrocedest Root1
                        Node
                              )1
                                  search(
                                          Node1 Risht-).
```

Again, we can encapsulate typical calls—“¿nd information associated with a given key”:

```prolog
¿nd( Tree, Key, Data ) :- search( Key : Data, Tree ).
```

A slightly different method of representing binary trees consists in using

```prolog
l( Node )
```

for leaves, instead of t(nil, Node, nil). However, with this representation we would have to distinguish empty trees from leaves of non-empty trees. For example, two more clauses would be necessary in the procedure for tree insertion.

<!-- page 105 -->
As a very special case, we can consider trees of degree I, that is, lists. Recall that a widespread convention (introduced in Chapter 1) is to denote empty lists by the atom and non-empty lists by in¿x tenns

Head.Tail The period is used to build trees of degree 2, which are a convenient representation of lists. It plays the same role as t in our BST example. In Prolog-10 a special notation has been invented as yet another application of syntactic sugar. It is very commonly used, even though its advantages over dot notation are debatable. Instead of Head.Tail we shall write’

[ Head I Tail ] the list a.b.c.Tail will be written as

[ a, b, c | Tail ] and the list a.b.c.[] as

[ a, b, c ] To make sure you have mastered this notation, check that [c I [d]] is the same as [c, d].

We shall remind you oftwo list-manipulating procedures from Chapter 1. Membership:

```prolog
member( Item, [ Item I Tail ] ).
member( Item, [ _ | Tail ] ) :- member( Item, Tail ).
```

And list concatenation:

```prolog
append( [], Second, Second ).
append( [ Head I First_tail ], Second, [ Head I Third_tail ] ) :-
    append( First_tail, Second, Third_tail ).
```

Here is another small example of operations on lists. Consider the following simple-minded sorting algorithm: given a list, put all its members in a BST and then apply the procedure write_sorted, de¿ned above.

sort( List

)

2-

buildtraat List1

ni11

Tree

)1

write-sortedt

Tree

Z 2nd and 3rd ariuoentt

the tree built

so far1

the final

Lroo buildtroet

[J1 Fina1tree1 Finaltroo ). buildtraat

Elton

I

ILansJ1

Currenttree1 Finaltree

)

2-

insurtt

Itenr Currenttree1 Nexttree

)1

buildtroet

Iteosr

NextLroo1 Finaltrea ).

i Sometimes an equivalent notation is used: lHead... Tail]. with

<!-- page 106 -->
written without blanks.

In Section 4.2.3 we shall de¿ne a more useful sorting procedure based on BSTs. It will construct the sorted permutation of a given list.

Just as in other programming languages, lists are used in Prolog primarily to represent sequences and sets. They can also be used in a standard way to represent trees of unspeci¿ed degree. For example, the tree of Fig. 4.6 might be represented by the list

**la.lb.[e]].l¢].Id.lfl.ls]]l**

Lists are best utilized when items are processed sequentially from left to right, or when all processing takes place at the beginning of the list. In the latter case the list is used as a stack. The basic stack operations, push and pop, can be easily written in one procedure, e.g.

```prolog
stack_op( Top, Rest_of_stack, [ Top I Rest_of_ stack ] ).
```

with the call

```prolog
stack_op( Newtop, Stack, Newstack )
```

serving as push, and the call

```prolog
stack_op( Top, Newstack, Stack )
```

to execute pop. However, in practice we would rather operate on the stack implicitly, by using appropriate terms in clause heads. One example is the procedure reduce (see Section 7.4.3) with old and new stacks as parameters. The clause

reducet I br( r. '1)‘ 1. t( X 1. br( I, '1)‘ ). idt l ) I 5 1.

**ll(lI'(l.X))|3])-**

describes an action that consists of four pops followed by one push.

Nonsequential access to a list requires, as might be expected, time proportional to the list’s length. To build a list in linear time, we can

**a\**

**1/ C**

<1

FIG. 4.6

<!-- page 107 -->
A non-binary tree. successively push incoming items, but the original sequence will be reversed. Alternatively, we can use append to preserve the original order of items, but this would square the nrnning time. Moreover, each call on append entails not only a traversal of the entire list, but also creation of its copy. Strictly speaking, a series of variables is produced and instantiated to successive tails. When executing the call

```prolog
append([ Itl, I12], [I13 ], X )
```

the following instantiations take place:

X 1- [ ltl

I Third_tail' ]

Third_tail' 1- [ lt2 I Third_tail" ]

Third_tail” 1- [ lt3 ]

As a result, only the top-level structure is copied. The situation is roughly as in Fig. 4.7: the two lists share all items but the last.

We had a similar situation in the tree insertion procedure. Check that Fig. 4.8 properly illustrates the picture after inserting tumer : 6481 into the tree of Fig. 4.3: we copy the top-level structure of the whole branch.

Copying structures upon modi¿cation is necessary because of the semantics of the operations: when we call append(Ll, L2, L3) to concatenate Ll and L2, we may wish to preserve an unmodi¿ed Ll. If we want destructive modi¿cation operations, we must express this desire explicitly.

...

.

...

**. . -sit]**

**®-**

**®-**

**@-**

**.. -__ -.**

**_ _ ..___._;[]**

FIG. 4.7

<!-- page 108 -->
The result of appending two lists.

**i**

**old tree**

'1.

'5

‘I

mcbride:17Bl

nil

**,/\**

**t/<L\.**

**FIG. 4.8**

**The result of insertion into a BST.**

**4.2.2. Open Lists and Trees**

**If we want to build lists ef¿ciently, we must avoid copying longer and**

**longer initial segments of the ¿nal list. Recall how append extends the list**

**piece by piece. After the call**

```prolog
append( [ Itl, It2 ], [ It3 ], X )
```

<!-- page 109 -->
**carom‘-:**

__

**AFTER**

**Q<>--——--**

**-———-~::;'fff11i:1**

**@**

**@-<5 eds -5> r**

FIG. 4.9

Extending a list.

we get

**x <-1 111 | Third_tail' 1**

**Third_tail' <-1 112 | Third_tail" 1**

and ¿nally bind Third_tail". The trick is to keep Third_tail" ready for a subsequent instantiation:

Third_tail" 1- [ It3 I Third_tail'” ] The situation will be roughly as in Fig. 4.9. Figuratively speaking, we shall be able to resume append in the next step of computation. We only need to get hold of the variable Third_tail"', instantiate it:

Third_tail'” 1- [ It4 I Third_tail'”' ] and so on. When we are through, we can instantiate, say,

Third_tail'“ 1- [] and come up with the ¿nal instance of X,

**[It], It2, It3, It4]**

<!-- page 110 -->
We shall illustrate this with a procedure that reads in a sequence of letters (up to the ¿rst non-letter) and puts them in a list:

```prolog
read_letters( [ L I Tail ] ) :-
    lastch( L ), letter( L ), !, rch, read_letters( Tail ).
read_letters( [] ).
```

(See Section 5.7.4 for the description of lastch and rch,)

The last tail variable can be left uninstantiated. Although the resulting structure will not be a proper list, it will be equally good as a representation of sequences. We shall call such structures open lists, and to avoid confusion we shall call proper lists, with [] at the end, closed lists. Empty open lists will be uninstantiated variables.

We must exercise some care if we deal with open lists. Consider the procedure that extends a given list by instantiating its tail variable:

```prolog
extend( List, Ext ) :- var( List ), List = Ext.
extend( [ _ I Tail ], Ext ) :- extend( Tail, Ext ).
```

For example, after the call

```prolog
extend([a,b|V],[c,d|W])
```

the ¿rst parameter becomes la, b, c, d I W].

It is essential that the instantiation of the tail variable be delayed. Consider what would happen if we changed the ¿rst clause to (apparently equivalent)

```prolog
extend( Ext, Ext ).
```

The result of the call

```prolog
extend( [ X, Y, Z I Endl ], [ a, b I End2 1)
```

(i.e. the ¿rst parameter’s instantiation) would be [a, b, Z I Endl] instead of the expected [X, Y, Z, a, b I End2].

Procedure extend can reasonably be used only in strictly detenninistic fashion. Failure after a successful computation causes dummy elements to be inserted after the ¿rst list. For example, the calls

extend( [ a I El ], [ b I E2 I ). fail instantiate El as [b | E2], [- , b I E2], [_ , _ , b I E2], etc. Therefore a more reasonable version would be that with a cut at the end of the ¿rst clause.

The reasoning that has led us to open lists can also be applied to trees. Uninstantiated variables represent empty open trees. Non-empty open trees will be represented as before. For example, the following term represents the tree of Fig. 4.1 (El,

<!-- page 111 -->
E6 are distinct variables):

```prolog
t( El, few, t( t( t( E2, languages, E3 ), many, E4 ),
            people, t( E5, speak, E6 ) ) )
```

Again, we shall refer to trees discussed before as closed trees.

We need not copy anything to insert a node into an open tree. We can go down the appropriate branch, locate a suitable empty tree, i.e. a variable, and instantiate it to a new leaf:

ins( Node:

Empty

)

=-

var(

Emntu )r

Emuts

= t(

E1:

Node:

E2 ).

ins( Node: t( Left: Root:

H

)

)

=~

precedes( Node: Root

)7

```prolog
                                  ins( Node: Left ).
ins( Nodev tt
              xv
                 Root» Rjsht
                              )
                                )
                                   =-
        nrecedest Root»
                        Node )r
                                  ins( Node: Risht ).
```

If we rewrite the ¿rst clause as

```prolog
ins( Node, t( El, Node, E2 ) ).
```

a subtle change in the procedure's behaviour will ensue. The procedure will insert nothing if this Node was already present in the tree. Surprisingly it will also be identical’ to the procedure search from the previous section, and (as might be expected) will serve almost the same purpose. The overall effect of this insertion/search procedure can be described as follows. lt looks for a given Node and succeeds after ¿nding it. However, if there is no matching node in the tree. the procedure inserts Node and then "¿nds" it as well.

There are some strikingly elegant applications of this. A well-known example is maintenance of symbol tables for translators written in Prolog. If the translated language is not. block structured, a symbol table usually cannot contain duplicate entn'es, and it nonnally only grows, so that keeping it in an open tree will require no copying at all.

The example we are going to present is, of necessity, rather involved. Before we proceed, you might ¿nd it helpful to retum to Sections 3.3 and 3.4.1, where we described a simple Algol-like language and sketched a parser and a code generator.

We intend to produce object code for a single-address target machine.

<!-- page 112 -->
-‘The only dilTerence is strictly technical: in some Prolog implementations dummy variables cannot be used to pass information. so we must insert a leaf with fresh named variables. For simplicity, we assume the code will not contain extemal references (we shall also not attempt any optimisations).

The code generator‘s output should be a list of "symbolic" instructions—terms described schematically as

Opcode( Address ) Each Address is an uninstantiated variable. There should be a unique Address for every addressable symbol of the source program (variable, constant, label), and for every label created by the code generator. By way of explanation, we give a possible translation of the assignment

x := x + y * y + 2 —most opcodes have obvious meaning.

[ load( AI ),

```prolog
 store( A2 ),
 load( A3 ),
 mult( A3 ),
 add( A4 ),
 add( A2 ),
 store( Al ),
 $l°P( - ).
 label( Al ), data( _ ),
                        % x
 label( A2 ), data( _ ),
                        % temporary
 label( A3 ), data( _ ),
                        % y
 label( A4 ), data( 2 )
                        % constant 2
1
```

We want the same Prolog variable for all occurrences of a source variable; for example, Al always stands for x.

To assemble this section of code, we should determine the base address and go down the list, counting bytes (or other units of storage). Each executable instruction would be assigned a ¿nal address. The pseudoinstruction label would be treated differently. We would instantiate Address as the current value of the location counter (without advancing the counter); this would instantiate all occurrences of Address (or of van'ables bound to it, if one wants such ¿ne distinctions). Assuming each instruction takes four bytes and the fragment of code starts at location 1000, we would obtain

1000 : load( 1032 ),

1004 : store( 1036),

1008 : load( 1040 ),

1012 : mult( 1040 ),

```prolog
etc.
```

<!-- page 113 -->
4.2. Examples of Data Stmctures

I03

Conveniently enough, all we need to achieve this remarkable behaviour is the procedure ins (it should have rather been christened rable-lookup). Whenever the translator encounters a symbol, say x, in the source program. it allocates a fresh variable V, to represent the symbol in subsequent processing. lt also calls ins to locate or place the pair

**P(X.V)**

in the symbol table. On the ¿rst occurrence of x the pair will actually be inserted. A subsequent "insertion" of p(x, U) only binds V and U together, i.e. ¿nds x’s “symbolic address".

For this scheme to work properly, each non-terminal symbol in the grammar that implements our code generator (see Section 3.4.1) must be fumished with one additional parameter to pass the symbol table‘. The whole grammar should be called with an empty table:

```prolog
generate_code( S, O ) :-
    phrase( code( S, SymTab ), O ).
```

And here is a rule that might be used to generate code for assignments:

code( assign( Name, Expr ), SymTab )—>

```prolog
codeexpr( Expr, SymTab ).
```

% code for this arithmetic expression,

% the value will be left in the accumulator

[ store( Addr ) ],

{ ins( p( Name, Addr ), SymTab ) }.

Symbol tables can also be implemented in open lists. For short tables lack of overhead due to key ordering tests can outweigh the loss due to worse performance. The simplest lookup procedure for open lists can be written as follows:

```prolog
lookup( Entry, [ Entry I Tail ] ).
lookup( Entry, [ _ | Tail ] ) :- lookup( Entry, Tail ).
```

This procedure, and two other versions (a bit more sophisticated) have been used in the Prolog part of ToyProlog implementation (see Section 7.4, Appendices A.2 and A.3), and in the program described in Section 8.2.

Open lists were ¿rst used in the bootstrapped Prolog interpreter from Marseilles (Battani and Méloni 1973, Roussel 1975). The technique shown in the code generator example was presented by Colmerauer (1975, 1978). Open trees were introduced by Warren (l9'7'7b, l980b).

<!-- page 114 -->
‘ For simplicity, we omitted the symbol table while developing the parser. We can save this particular program by doing symbol table management in the back-end, but of course the more proper way is to install symbols in the table in the front-end. 4.2.3. Difference Lists’

If the application does not require shortening a list, open lists can be constructed with no copying whatsoever. Successive instances of the originally empty list—a variable—are longer and longer open lists (assuming, of course, that we are careful to instantiate ¿nal variables appropriately). However, each time we add an item, the list must be traversed to ¿nd the ¿nal variable. To avoid this, we can keep this variable ready for instantiation:

End = [ Newltem I NewEnd ] and make NewEnd available for further processing.

The pair consisting of a list and its ¿nal variable can be considered another representation of the list—a little redundant for the sake of ef¿ciency. It is reasonable to represent the term as a single term. We shall write it as

OpenList -- ItsFinalVariable with -- a nonassociative in¿x functor. For example:

[ a, b I X ] -- X To add an item at the end of a list we use the procedure

additem (Item, List -- [Item I NewEnd], List -- NewEnd). The call

```prolog
additem( 4, [ l, 2, 3 I X ] -- X. NewList )
```

instantiates, as expected,

NewList <— [ l, 2, 3, 4 I NewEnd ] -- NewEnd because

X<—[4INewEnd] Consequently, the old list becomes

[1, 2, 3, 4 I NewEnd ] -- [4 I NewEnd ] To get a new list, we had to destroy the old one.

Fortunately, the destruction is apparent. The pair can still be regarded as a representation of the sequence l, 2, 3. Notice that [4I

<!-- page 115 -->
’ Difference lists (d-lists) were introduced by Clark and Tarnlund (I977). NewEnd] is a tail of [I , 2, 3, 4 I NewEnd]. The sequence consists of those items we must pop off the ¿rst list to get its tail, i.e. of items by which the two lists differ-hence the name of this data structure: difference list (d-list for short).

Actually, a pair consisting of an open list and its tail is only a special case: a difference list is de¿ned as a pair X -- Y such that X = Y or X = [AI ,

An I Y] for some n 2 I. In general, no restrictions need be placed on the fomi of Y, although the most interesting applications of difference lists are those where Y is an open list.

Difference lists can be used to advantage whenever activity is expected at both ends of the sequence, e.g. when it is used as a queue. The procedure additem enqueues an item. To dequeue an item, we can use the obvious

```prolog
remitem( Item, [ Item I List ] -- End, List -- End ).
```

but the behaviour of this procedure is unsatisfactory for empty lists. The call

```prolog
remitem( ltem, E -- E, NewList )
```

instantiates NewList as List -- [Item I List], i.e. as a “negative difference list"°. A procedure which fails, given an empty list, may be written as follows:

```prolog
removeitem( Item, List -- End, NewList -- End ) :-
    not List = End, List = [ Item I NewList ].
```

Another nice feature of difference lists is the way they can be concatenated. Suppose we have two lists:

**[a,bIX]--X**

and

**[c,d,e|Y]--Y,**

and we want to compute a list holding the sequence a, b, c, d, e. If we can assure that

I

**X=[c,d,e|Y],**

we shall have la, b I X] = la, b, c, d, e I Y], and

[ a, b I X ] -- Y will be a solution. This is readily generalized as a procedure:

```prolog
d_conc( Listl -- Tail], Tail] -- Tail2, Listl -- Tail2 ).
```

<!-- page 116 -->
‘ This structure can be very useful in its own rights; see Shapiro (l983b, Section 4.8). Once again, it must be stressed that modi¿cation of such lists is destructive. For example, the second call below fails, because [c, d, e I Y] does not match [p I Z]:

d_conc( [ a, b I X ] --

I Y ] -- Y, ABCDE ),

d_conc( [ a, b I X ] --

-- Z, ABP ).

.?<.?< '°.°

NP- —-0

We now return to the sorting algorithm based on BSTs (see Section 4.2.1). Instead of traversing the tree, built of a given list, and merely writing out the nodes, we would rather traverse it in order to construct the sorted permutation of the list:

```prolog
tree- sort( List, SortedList ) :-
    buildtree( List, nil, Tree ),
    buildlist( Tree, SortedList ).
```

The procedure buildlist "Àattens" the tree (see Fig. 4.10 for an example). The general outline of the algorithm is rather obvious: we Àatten the subtrees (recursively) and concatenate the resulting lists together with the root in between. Difference lists can be used to avoid numerous appends. Let the results of recursive calls be denoted by

LFlat -- LFlatE

and

RFlat -- RFlatE The algorithm is programmed as follows:

Àatten( nil, X -- X ).

```prolog
Àatten( t( L, Root, R ), Flat ) :-
    Àatten( L, LFlat -- LFlatE ),
    Àatten( R, RFlat -- RFlatE ),
    d_conc( LFlat -- LFlatE, [ Root I X ] -- X, A ).
    d_conc( A, RFlat -- RFlatE, Flat ).
        /\%
             FIG. 4.l0
                     (a) A tree. (b) The tree Àattened.
  ./\./\.
```

<!-- page 117 -->
This version is good for didactic purposes. Actually, we know that the following instantiations take place:

I..FlatE <— [ Root I X ],

A <— LFlat -- X,

X <— RFlat,

Flat <— LFlat -- RFlatE We can remove both calls on d_c0nc and end up with an equivalent form of the second clause:

```prolog
Àatten( t( L, Root, R ), LFlat -- RFlatE ) :-
    Àatten( L, LFlat -- [ Root I RFlat ] ),
    Àatten( R, RFlat -- RFlatE ).
```

We might similarly derive a “short cut" clause for leaves. We begin with

```prolog
Àatten( t( nil, Root, nil ), LFlat -- RFlatE ) :-
    Àatten( nil, LFlat -- [ Root I RFlat ] ),
    Àatten( nil, RFlat -- RFlatE ).
```

then make LFlat = [Root I RFlat] and RFlat = RFlatE, and remove the recursive calls. The special case becomes:

Àatten( t( nil, Root, nil ), [ Root I RFlatE ] -- RFlatE ). (as expectedl).

After the call

Àatten( Tree, List -- ListEnd ) we shall have List instantiated as

[Node|,

Node" I ListEnd ], and all we shall need to get SortedList is close List by binding ListEnd to []. This is easily achieved by de¿ning

```prolog
build|ist( Tree, SortedList ) :-
  Àatten( Tree, SortedList -- [] ).
```

(or replacing the buildlist call in rree_sorr. for that matter).

See Section 7.4.1 for a little more sophisticated application of difference lists.

4.2.4. Clausal Representation of Data Structures

<!-- page 118 -->
A Prolog procedure built of unit clauses is a natural representation of sets and sequences. Under the static interpretation of programs, such a procedure models a relation. i.e. a set of tuples for which a certain relationship holds. For example:

```prolog
name_phone( thompson, 2432 ).
name_phone( adams, 5488 ).
name_phone( white, 2432 ).
name_phone( mcbride, I781 ).
```

In practice, unit clause procedures are sequences rather than sets, in that they are accessed sequentially. It is therefore possible to represent a list by a procedure, e.g.

Iist( b ).

Iist( k ).

Iist( q ).

Iist( y ). The call

Iist( X ) tests membership for instantiated X, and serves as a generator for uninstantiated X. The whole list can be processed thus:

```prolog
process_list :- Iist( X ), process_item( X ), fail.
process_list.
```

In general, clauses may be used to represent multidimensional matriceswe shall discuss this brieÀy in the next section.

The restriction to unit clauses is not essential. The clause

```prolog
name_phone( X, 4396 ) :- of¿ce( X, rooml I9 ).
```

will generate tuples one at a time, exactly as the other four clauses do. It is wonh emphasizing that explicit and generated data are functionally indistinguishable. If ¿ve people sit in room I19, we can get up to nine name-phone pairs, without ever becoming aware of the "indirection" in one of the clauses.

Any structure expressible in terms of relations can be naturally cast in clauses. For example, a tree can be described as follows:

```prolog
t( nodel , node2, thompson : 2432, node3 ).
t( node2, nil, adams : 5488, node4 ).
t( node3, nil, white : 2432, nil ).
t( node4, nil, mcbride : I78], nil ).
root( nodel ).
```

<!-- page 119 -->
In particular, we can represent a list in this way:

```prolog
l( iteml, b, item4 ).
l( item2, y, nil ).
l( item3, q, item2 ).
l( item4, k, item3 ).
head( item] ).
```

In general, every graph can be expressed as a unit-clause procedure. By way of explanation, here is a possible representation of the graph of Fig. 4.11 (see also Fig. 3.1):

```prolog
edge( el, e2, o ).
edge( el, e2, letter ).
edge( el, e3, atom ).
edge( e2, e3, x ).
edge( e2, e3, letter ).
edge( e2, e3, atom ).
```

And a representation of the graph of Fig. 4. I5 (Section 4.4.3):

```prolog
arc( a, b).
              arc( a, c ).
                           arc( b, c ).
                                         arc( b, d ).
arc( b, e ).
              arc( c, d).
                           arc( c, e ).
                                         arc( d, e ).
```

Clausal representation of trees, lists and the like is rather less convenient than representations described in previous sections. It cannot be passed as an actual parameter, so that its use can only be recommended when the bulk of data remains unchanged (see Section 8. I for a non-trivial example). Since variables are local in clauses, clever techniques shown in Section 4.2.2 are hardly applicable here. To build and modify data dynamically (e.g. add a node to a tree), we must apply “extralogical” built-in procedures assert, retract, etc., to the detriment of static interpretation of programs.

There are advantages, too. First of all, in Prolog implementations which support clause indexing, direct access to components can be possible. Indexing consists in ¿nding matching clauses by hashing rather than by linear search, so that e.g. a node in a “tree” with n nodes can be located in constant time rather than in log;n steps (on the average).

atom

,1):

e1

e2

e 3

FIG. 4. ||

<!-- page 120 -->
A graph. DEC-I0 Prolog was the ¿rst to offer this possibility. If absent, it can be mimicked by means of the built-in procedure =.. (see the next section).

Clausal representation sometimes helps reduce the problem at hand to its bare essence. A case in point is an amazingly concise solution to a map colouring problem; we quote it after Pereira and Porto (l980b). A planar map is to be coloured with at most four colours so that contiguous regions are coloured differently. First we de¿ne the contiguity relation for colours:

nextt red: blue ).

nextt red: sreen ).

nextt red: sellou ). nextt blue: red ).

nextt blue: sreen ).

```prolog
next( blue: sellou ).
```

nextt sreen:

red ).

nextt sreen: blue ).

next( sreen: sellou

) next( yellow:

red ).

nextt yellow: blue ).

nextt sellou: sreen

)

The original map of Pereira and Porto (l980b) is shown in Fig. 4.12. A region is represented by its colour—this decision makes the solution beautifully terse. To ¿nd a colouring (if any) of the map, we must only call

nextt R1:

R2 ):

nextt R1:

R3 ):

nextt R1:

R5 ):

next( R1:

R6 ): next( R2:

R3 ):

nextt R2:

R4 ):

next( R2:

R5 ):

next( R2:

R6 ): nextt R3:

R4 ):

next( R3:

R6 ):

next( R5:

R6 ):

UPitG(

(R1:

R2:

R3:

R4:

R5:

R6)

)9

```prolog
nl.
```

Structures represented by temts are usually traversed and manipulated by recursive procedures. Clauses are traversed by backtracking, either implicit (e.g. in the call above), or explicit (e.g. in the procedure

3

_.-

-6

2

I

I

i

I

l

FIG. 4.l2

<!-- page 121 -->
A map to be coloured.

4.2. Examples of Data Stnrctures

I I I

process_list). There is a fundamental discrepancy between these two modes, because backtracking destroys variable instantiations which are essential to recursive operations on data structures. Consider the task of computing a list of arcs exiting vertex b of the graph in Fig. 4. I5. Arcs are available one at a time to a routine that “backtracks through" the procedure arc. If we want them to survive backtracking, we must “put aside". i.e. assert, those which contain b:

Dut_oside

=-

arc( X:

Y ):

nut_oside_if_b( X:

Y ):

```prolog
foil.
```

nut_o5ide_if_b( X:

Y

)

8-

has( b:

X:

Y ):

o5sert( uith_b( X:

Y

)

)

hO5(

X:

_:

X

)-

=— nuL_o5ide.

Z Now:

o list con be created as follous=

collect_uith_b( ThisList: FinolList

)

=-

retroct( uith_b( X:

Y

)

):

!:

collect_with_b(

E

(X:

Y)

I

ThisLi5tJ: FinolList ). collect_uith_b( Fino1List: FinolList ).

8collect_with_b( E]: TheList):

write( TheList ):

```prolog
nl.
```

Such operations are usually cast in terms of a general-purpose procedure that ¿nds a set of all items for which a given condition holds. In our example, items would be (X, Y), and the condition

**(arc( X, Y ), has( b, X, Y))**

<!-- page 122 -->
The set is represented by a list, possibly with repetitions, so that it is called bag in the folklore. Here is our version of the procedure: basoftltem: Condition:

_)

=ossert('BAG'('BAG')):

Z a marker Condition:

Z senerates an instance of Item ossert('BAG'(Item)):

**Z saves it**

fail.

Z this clause eventualls fails basof(_:

_:

Baa)

=retract('HAG'(Item)):

!:

Z set the last Item saved collect(Item:

E]: Bus).

collect('BAG': FinalBa9: FinalÀas)

=-

!.

Z this was the marker collect(Item: ThisÀas: Finol¿as)

:— retract('BAG'(NextItem)):

I: collect(NextItem: [Item

I

ThisBa9]: Final¿as).

The marker enables us to use the procedure bagof within Condition. An example of such nested computation is the following pair of calls (Graph is to be a list of “bunches"—lists of arcs entering or leaving a given vertex; the condition in the ¿rst call is an altemative, in the embedded one a conjunction):

=— basoF( X:

( arc(X: _)i arc(_:

X) ): Uertices ): basof( Bunch:

( member(U: Uertices):

basoft

(Y: Z):

( arc(Y: Z):

has(U:

Y:

Z) ):

Bunch

>

>:

<!-- page 123 -->
Graph ). Repetitions in a bag may be undesired. For example, the ¿rst call above should rather ¿nd a set of all vertices—as it stands, Graph will contain numerous duplicates. The procedure setof would call bagof and then ¿lter the resulting bag. In Prolog- I0 and some other implementations both bagofand setofare built-in procedures: setofeven retums its output sorted. An implementation of setof in Prolog was presented by Pereira and Porto (l98l).

4.2.5. Array Analogues in Prolog

There is no addressing mechanism in Prolog, no memory cells directly available to the programmer—for most applications this is simply unnecessary. Consequently, there are no arrays interpreted as contiguous, addressable areas. From a mathematical standpoint, arrays correspond to ¿nite matrices, i.e. to mappings from ¿nite sets of subscripts to sets of values. In theory, there are no restrictions on the fonn of subscripts, although integers are most commonly used.

In Prolog we can represent such mappings as procedures consisting of unit clauses, one clause for each sequence of subscripts and the corresponding value. This is but a special case of relation in the relational model of data (see Section 8.2).

Unit clauses are particularly convenient as a representation of sparse matrices, provided that clause indexing is supported by the Prolog implementation.

Another possibility is to represent a mapping as a list of n-tuples (subscripts, value), and to use list manipulation procedures. As a special case, a sequence subscripted by consecutive integers may be represented as a list of values. This approach may work for short lists, but in general it is prohibitively inef¿cient.

We shall now present an alternative way of storing integer-subscripted sequences, which is rather unlikely to outperform Prolog data bases (with indexing), but may be reasonable for sequences of moderate size. The method makes use of digital search trees (see e.g. Sedgewick I983).

Branching in digital search trees is based on the values of successive digits of the key being looked for. Keys cannot be negative. The order of every node is equal to the base of the digital system, e.g. to I0 if keys are expressed in decimal. In Fig. 4.13 we show two trees, each containing I5 items numbered 0 through I4. A,- denotes the i-th item, the root is empty (i.e. contains a dummy value), and branches are labelled with digits. To ¿nd AI; in the binary tree, we take ll0l, the binary code of I3, and go down selecting branches labelled with I, I, 0 and I. To ¿nd AI; in the temary tree, we use Ill, the ternary code of I3.

<!-- page 124 -->
Digital search trees are best implemented in Prolog by open trees. We shall demonstrate it in the case of temary trees (other cases are basically /C\/\

**/\**

**Q 0**

**I ®**

**ltlx:kZ**

**ID/**

**6)/.L\**

**/À.m\**

**®®**

<!-- page 125 -->
FIG.4.l3 Digital search trees: la) Binary digital search tree lb)Tem rydtgtt lse rch tree.

4.2. Examples of Data Stmctures

I I5

**identical, although impractical if nodes have more than a few branches).**

A non-empty tree will be represented as

```prolog
t3( Value, Left, Middle, Right )
```

and an empty tree as a variable. Explicit labels are unnecessary, as we may simply select Left or Middle, or Right upon encountering 0, I or 2, respectively.

A procedure that ¿nds a value, given a ternary subscript and a tree, is quite straightforward. We assume that subscripts are represented as closed lists of digits:

find_3( E]: t3( Value: _:

_:

_ ): Value ).

find_3( [0

I Sub]: t3( _: Left:

2:

_ ): Value

)

```prolog
                                                  :-
        find_3( Sub: Left: Value )-
find_3( [1
            I
             Sub]: t3( _:
                          _: Middle:
                                      _ ): Value
                                                 )
                                                    :-
        find_3( Sub: Middle: Value ).
find_3( [2
            I Sub]: t3(
                       _:
                          _:
                              _: Risht ): Value
                                                )
                                                   :-
        find_3( Sub: Risht: Value ).
```

**The procedure fails if the ¿rst parameter is not a correct temary subscript,**

**or if the second parameter is not an open temary tree. However, it does**

not fail when a nonexistent item is referred to. We shall discuss this phenomenon presently.

Now for a procedure that replaces an item. Two tree parameters are required, and the new tree is a copy of the old one, except for the replaced item. The amount of copying is similar to that illustrated in Fig. 4.8.

chanse_3( E]: NewVal: t3( _: L:

H:

R ):

t3( NeuVa1: L:

H:

R

) ). chanse_3( [0

I

Sub]: NeuVal: t3( OldVal: L:

H:

R ):

t3( OldVal:

NewL:

H:

R

)

)

=-

chanse_3( Sub:

NewVal: L:

NeuL ). chan9e_3( [1

I Sub]:

N0uVa1: t3( 0ldVal: L:

H:

R ):

t3( 0ldVa1: L:

NewÀ:

R

)

)

=-

chanse_3( Sub: NeuVal:

H:

<!-- page 126 -->
NewÀ ). chanse_3( £2

: Sub]: NeuVal: tat 01dVal: L: a:

R >.

e3< 0ldVal: L: H: NeuR

>

>

```prolog
                                                  :-
chanse_3( Sub: NeuVal:
                       R:
                          NewR )-
```

Both procedures behave in the same way when the subscript is too large: they create a missing part of the tree, and then “¿nd” or “change” the newly inserted item. For example, the call

¿nd_3( [2, l, 0, I ], Tree, A64) applied to the tree of Fig. 4. I3b changes the node with item A7 into the tree of Fig. 4.l4, or, in term notation, into

t3( A7, t3( Dummy2l, Empty_i.

```prolog
                t3( A64, Empty_ii, Empty_iii, Empty_iv ),
                Empty_v ),
Empty_vi, Empty_vii )
```

The same effect will be achieved by the call

```prolog
change_3( [ 2, I, 0, I ], A64, Tree, Tree )
```

The moral is that, ¿rst, no special insertion procedure is needed, and, second, the tree need not be full. It will contain only the inserted nodes together with the branches required to reach these nodes, but intermediate nodes may contain no meaningful information.

To make the story complete, here is a little procedure that converts nonnegative integers into lists of temary digits. Note that there are two procedures here: conv_3/2 and (auxiliary) conv_3/3.

conv_3( O:

[O] ).

conv_3(

N:

TerN

)

=—

inteser(

N ):

O (

N:

conv_3( N:

E]:

TerN

)

conv_3< 0: ¿llÀisits: ¿ll¿isits

)

¿—

'. conv_3( N:

Z: ¿llÀisits

)

=-

Disit is

N mod 3:

Nbs3 is

N / 3:

conv_3( Nbs3: [Disit

I Z]: All¿isits ).

4.2.6. Access to the Structure of Terms

In Section 4.2.1 we dismissed the possibility of representing tree nodes with main functors: the term

```prolog
few( nil, people( many( languages, nil ), speak ) )
```

<!-- page 127 -->
O

**Q**

FIG. 4.l4

Creation of the missing part of a tree.

would stand for the BST of Fig. 4.l. We shall now show an insertion routine for such trees. The built-in procedure = .. (univ) is used to circumvent the problem raised by the potential diversity of the functors.

insert( Node:

Tree:

NewTree

)

=- Tree =..

ERoot: Left: Risht]: insert( Node: Root: Left: Risht: NeuLeft: NeuRi9ht ): NewTree =.. [Root: NewLeft: NeuRisht]. insert( Node: nil: Node ). insert( Node: Leaf: NeuTree

)

=insert( Node: Leaf: nil: nil: Left: Risht ): NeuTree =.. [Leaf: Left: Risht].

insert( Node: Root: L: R:

NeuL:

R

)

=vrecedest Node: Root ):

insert( Node: L:

NeuL ). insert( Node: Root: L:

R: L:

NeuR

)

=nrecedest Root:

Node ):

insert( Node: R:

NeuR )-

<!-- page 128 -->
This application of univ is far from typical. As a more realistic example, consider the problem of translating an arithmetic expression into reverse Polish form, e.g. y*$qrl(sqr(x)+f(l.y)) into I y. X. sqr. I. y. f. '+'. sqrl. ’*’ I Here is a possible solution:

revwoll

Exnr:

RQVEXPP

)

I-

Earr =..

[Fun

I

Arss]:

ravarast hrss: I]:

Revarus

J:

arwendt

RavÀris:

[Fun]:

RevExpr

J.

revarast

E]: Revall:

Revall

).

revarlst

[Ara

I Aris]:

RevTillNou: Revall

)

I-

PEVPO1( Ari:

Revhrs ):

append( RevTillNou:

Revara:

RevÀneÀore

):

revarsst

¿r¿bv

Rev0neHorQ:

Rev¿ll

).

We could use difference lists to decrease the cost of multiple appendings. but the procedures would become even less readable (but try it—this would be an application of the "Àatten" schema, although a little unwieldy because of the unknown number of arguments). However, a readable version would not only be much longer, but also less Àexible:

```prolog
revpol( A + B, RevExpr ) :-
    revpol( A, RevA ), revpol( B, RevB ),
    append( RevA. RevB, Aux ), append( Aux, [ ‘+‘ ], RevExpr ).
revpol( sin( A ), RevExpr ) :-
    revpol( A, RevA ),
    append( RevA, [ sin ], RevExpr ).
revpol( Atom, [ Atom ] ).
```

This is a closed schema: to be able to recognize a new function or operator, we must add a branch to this “case statement".

Perhaps one of the most important applications of univ (and related built-in procedures) is in bootstrapped implementations of Prolog. A basic interpreter (see Chapter 6 and Section 7.3) may support Prolog (with a very rudimentary syntax) furnished with built-in procedures analogous to call and univ. Various user interfaces can then be written in this simpli¿ed Prolog (see Section 7.4). provided we can convert texts to terms.

Assume we input the text

```prolog
foo( ¿e( X ), ok, X )
```

<!-- page 129 -->
and produce its (intermediate) representation:

**[[f.0.0].[[f.i.¢=l.V].[[0.l<]].V]**

with uninstantiated V. (Try to write this reading program: a symbol table such as those described in Section 4.2.2 must be used to handle variable names properly.) Now we can glue the intermediate representation together:

sluet Inter: Inter

)

=—

var( Inter ):

'.

alue(

CFunChars

I

InterÀrss]:

Term

)

=-

not alldisitst FunChars ):

sluearss( Inter¿rss:

Ares ):

pname( Fun: FunChors ):

Term =..

[Fun

I ¿rss].

9lue( [Disits]:

Number

)

```prolog
                   :-
alldisitst Disits ):
onamei( Number: Disits )-
```

sluearsst E]: L] ).

sluear9s( Elnter¿rs

I

lnterÀrss]: [¿rs

I Arss]

)

=-

slue( InterÀrs: ¿rs ):

```prolog
sluearss( Inter¿rss: Arss ).
```

alldisitst

CDi9it

I Uisits]

)

=-

d1sit( DiÀit ):

I:

```prolog
a11di9it5( Uiyits ).
```

al1disits(

[J

J.

The procedure glue should be called with the second parameter uninstantiated.

In implementations that do not support indexing (see Section 4.2.4), unlv helps avoid linear search of matching clauses. Consider. for example, a natural language application program which maintains a dictionary whose entries can look as follows:

```prolog
dict( program, noun( inanim ) or verb( intrans ) ).
dict( modular, adj ).
dict( an, article( indef ) ).
```

<!-- page 130 -->
Next, assume that each word on input is ¿ltered through this dictionary:

```prolog
input_a_word( W, Features ) :-
    read_a_word( W ),
    ( dict( W, Features ), I: signal_unknown( W ) ).
```

Without indexing, dictionary lookup requires time proportional to the number of entries. Access to a procedure, i.e. to its ¿rst clause, usually requires approximately constant time (some form of hashing is used). We can have our dictionary in the form

```prolog
program( noun( inanim ) or verb( intrans ) ).
modular( adj ).
an( article( indef ) ).
```

and de¿ne dict as

```prolog
dict( W, Features ) :-
    Entry =.. [ W, Features ], Entry.
```

or—equivalently—as

```prolog
dict( W, Features ) :-
    functor( Entry, W, I ), Entry, arg( I, Entry, Features ).
```

A particularly simple dictionary is a table of keywords for a scanner of, say, Pascal:

```prolog
const.
            type.
                     array.
                              record.
function.
            var.
                     begin.
                              do.
```

etc. To create the representation of a source program name, we can use this procedure:

```prolog
key_or_id( Name, keyword( Name ) ) :- Name, !.
key_or_id( Name, ident( Name ) ).
```

As a ¿nal example, here is the crucial part of a de¿nition of the procedure phrase which initiates processing based on a metamorphosis grammar:

```prolog
phrase( InitialNonterminal, Terminals ) :-
    InitialNonterminal =.. [ Name | Parameters ],
    InitialCall =.. I Name, Terminals, [] | Parameters ].
    InitialCall.
```

<!-- page 131 -->
Note that input and output parameters are added at the beginning of the parameter list (rather than at the end, as suggested in Section 3.3).

## 4.3 Some Programming Hints

We have collected here some down-to-earth suggestions which may help improve your coding technique in Prolog. Although style is largely a matter of taste, some of the things we have to say have long been present in Prolog folklore, and we feel fairly con¿dent they are worth presenting.

4.3.1. Using the Cut Procedure

Essentially, the cut commits the currently executing procedure to whatever it might have done since its activation. This is precisely what makes the cut a controversial feature: that it can only be interpreted dynamically. On the other hand, the variety of its uses and its power make it an important factor in the emergence of Prolog as a practical programming language.

In Chapters I and 2 we discuss the cut—in a very general mannerboth as an extralogical mechanism and as a tool for improving ef¿ciency. Here, we shall concentrate on its applications.

Despite Prolog’s inherent nondeterminism, the usual computation is mostly deterministic: the majority of procedures are expected to produce a single, well-de¿ned response to any particular set of input data. Most procedures are strictly deterministic: at most one clause of a procedure applies, regardless of the actual data.

With the procedural interpretation of Prolog in mind, clauses are commonly written as

```prolog
head :- tests, actions.
```

A clause is executed for its actions which can be performed if and only if head matches the call and all tests succeed. This conforms to the fundamental notion of guarded commands (Dijkstra I975). Some Prolog dialects, e.g. IC-Prolog (Clark et al. l982b), even provide special syntax for “guards”.

If, during a deterministic computation, tests have succeeded, a cut executed immediately after tests commits our choice of the clause. The cut saves us further—unnecessary—attempts to execute the procedure in the case of a failure later on. As an example of this fairly typical situation, consider the following:

% Retrieve ( fetch ) the grammatical description of a word,

<!-- page 132 -->
% fail if there is no such word in the dictionary. % The word may be given as a string: ¿nd( String, Description ) :isletterstring( String ),

```prolog
% yes, a string
```

pname( Word, String ), fetch( Word, Description ). % or as a word, i.e. nullary functor: ¿nd( Word, Description ) :isword( Word ),

```prolog
% yes, a word
```

fetch( Word, Description ). % Reject bad data: ¿nd( Bad, _ ) :not isletterstring( Bad ), not isword( Bad ),

```prolog
% yes, bad data
```

signal( Bad ), fail. In this procedure, cuts may be safely placed after tests. Notice, however, that a cut inserted earlier changes the procedure‘s behaviour, and a cut afterfetch does not work if a word is absent from the dictionary. (lt would also have ruinous effects if fetch were a nondeterministic generator of synonyms.) When we adhere to the “guarded command“ style of programming. the built-in procedure not is frequently used to invert tests (but see the beginning of the next section for a brief discussion of not‘s peculiaritiesl). However, we would not like to perform expensive tests twice, as in this example: addunique( Item. List ) :presentinalonglist( Item, List ), signal_dupl( Item ). addunique( Item, List ) :not presentinalonglist( Item. List ), additem( Item, List ). We can replace the inverted test with a cut after the original test: addunique( Item, List ) :presentinalonglist( Item, List ), !, signal_dupl( Item ). addunique( Item, List ) :-

```prolog
% not present...( Item, List )
```

additem( Item, List ). This procedure can be interpreted as if present...( Item. List ) then signal_dupl( Item )

<!-- page 133 -->
else additem( Item, List ) This is, perhaps, the most frequent application of the cut. It must be remembered, though, that this use of the cut is extralogical: a clause with a test removed means something else, and it cannot be understood in separation from the rest of the procedure. Still, the procedure as a whole is usually suf¿ciently readable, if we view it as a (possibly nested)

if

then

else if

then etc.

Sometimes cuts inside a procedure are undesirable. One example is a procedure that holds data, e.g.

```prolog
father( jack, tom ).
father( bill, john ).
etc.
```

(with empty tests and actions). With a cut in each clause this would not only look ugly, the procedure would be of no use as a generator! Instead, we should commit the call on father, as in this procedure:

```prolog
is_father( Person ) :- father( Person, _ ), !.
```

The cut serves as a ¿rewall against unwanted backtracking.

Another example. Consider this group of grammar rules:

```prolog
command( Cmd ) —> stop( Cmd ).
command( Cmd ) —> dump( Cmd ).
command( Cmd )—> load( Cmd ).
command( Cmd )—> create( Cmd ).
etc.
```

A “switch” such as command is best committed by the cut after a call. e.g.

phrase( command( Cmd ), Tokens ), I

This technique, however, has a disadvantage. The “committing” cut affects not only the call but also the calling procedure. If the call being committed happens to be the last test in a clause, then the cut plays two roles at once. Otherwise we should make it invisible to the surrounding clause. To achieve this, we can use this general-purpose “call-and-commit” procedure:

```prolog
once( Call ) :- Call, !.
Other arguments against “cutting high” are implementation-depen-
```

<!-- page 134 -->
dent. First of all, in many implementations memory requirements are smaller when there are fewer fail-points, so it may be desirable to perfomi cuts as soon as possible. Some implementations also optimise storage utilisation of tail-recursive procedures (see Section 6.4). A procedure may become tail-recursive dynamically, after having its remaining clauses cut off. For example:

% Recognize a sequence of letters/digits.

Id( [Ch |Chs] )-> [ Ch ],{Ietter( Ch ) }, !, Id( Chs ).

Id( [ Ch I Chs ] )—> [ Ch ], { digit( Ch ) }, !, Id( Chs ).

**Id( ll )—> [I**

(Here, the cuts may protect us against deep recursion, effectively changing it into iteration.)

Sometimes the use of cuts should be recommended for clarity. We shall present two versions of the procedure that translates the term (A, , ..., A,,) into the list [A] , ..., A,,] and the term A (other than a comma-term) into [A]. First the version with “full guards”:

```prolog
c_list( AA, [ AA ] ) :- var( AA ).
c_list( AA, [ A | As ] ) :-
    not var( AA ), AA = ( A, AATail ), c_list( AATail, As ).
c_list( AA, [ AA ] ) :-
    not var( AA ), not AA = (_, _ ).
```

And the version with cuts (here the order of clauses is crucial):

c_list( AA, [ AA ] ) 2- var( AA ), !.

```prolog
c_list( ( A, AATail ), I AI As] ) :-
    !, c_list( AATail, As ).
c_list( AA, [ AA ] ).
```

In nondeterminisitic procedures cuts should be used cautiously, if we do not want to inadvertently lose some solutions. In particular, procedures that compute multiple answers (such as append) should not contain cuts. A cut after a call on a generator makes it yield only its ¿rst satisfactory answer, as in this small example:

```prolog
int( 0 ).
int( NextN ) :- int( N ), NextN is N + I.
:- int( X ), satisfactory( X ), !.
```

Cuts after tests in a procedure written according to the “guarded command” style implement Dijkstra's don't-care nondeterminism of if statements: any—exactly one—of the branches with true guards is chosen (in Prolog, the ¿rst one).

<!-- page 135 -->
Special care must be exercised when adding cuts to procedures intended to be used in more than one way (such as grammar rules intended both for analysis and synthesis). 4.3.2. Failure as a Programming Tool

The procedure not, used to invert tests, owes its power and conciseness to the combined effect of three extralogical mechanisms in Prolog: variable calls, the cut, and forced failure. Recall the de¿nition:

not X

```prolog
       :--
          X, I, fail.
l‘lOI _.
```

Observe that the second clause performs no instantiations, and any instantiations in X must have been undone on failure. If not succeeds, its parameter will remain intact. Therefore, not will not retum anything. For example, the call

not student( X ) with uninstantiated X will not ¿nd a nonstudent (as might have been expected). Instead, it will fail if there is at least one student, e.g.

```prolog
student( jim ).
                 student( jill ).
```

Otherwise it will succeed with X still a variable. If we insist on ¿nding nonstudents, we can look for them among NewYorkers:

```prolog
newyorker( tim ).
                    newyorker( jim ).
newyorker( jill ).
                    newyorker( amy ).
```

Now the command

```prolog
:- newyorker( X ), not student( X ),
    write( X ), nl, fail.
```

will print:

tim

amy

It must be emphasized that not called with a term containing variables does not implement negation properly (see Clark I978). If the call not student(X) succeeds, then we shall actually prove that

m 3x student( x ) which is equivalent to

Vx m student( x ) On the other hand, suppose not means 1 The command

```prolog
:- not student( X ).
```

<!-- page 136 -->
would then be interpreted (see Chapter 2) as

Vx mm student( x )

i.e. as Vx student( x ). Its negation—to be proved by reductio ad absurdum—is

3x m student( x )

This discrepancy was commented upon, for example. by Clark and McCabe (l980a, l980b) and Dahl ( I980). In IC-Prolog (Clark et al. l982b) the problem was solved by treating not calls with variables as erroneous. This is to say. negation in their system is only applicable to ground predicates.

Except for not, forced failure is used primarily for ef¿ciency. Many Prolog implementations have no garbage collection, but upon backtracking almost all of them very ef¿ciently recover some storage holding control information and term instances (see Chapter 6). We can take advantage of this in a few rather unobvious but effective tricks. One of them is “double not“.

On the face of it, the trick is pointless: the call

not not C succeeds if and only if C does. We shall trace the execution of this call to show its hidden effect. Assume ¿rst that C succeeds; here are successive snapshots:

not not C

not C, !, fail

C, !, fail, !, fail

!, fail, !, fail

% the cut will commit the intemal not

fail, I, fail

% RECOVER the storage used by C,

% and backtrack in the external not

SUCCESS Now, let C fail:

not not C

not C, !, fail

C, !, fail, !, fail

% backtrack in the internal not.

<!-- page 137 -->
% succeed via the second clause

!, fail

% the cut commits the external not

fail

FAILURE

Since “double not” does not instantiate anything. it can only be used in two situations. Either we want to perform a complicated “yes/no” test (with all interesting variables already instantiated), or we are only interested in some side-effects of C but we want to recover storage after its execution. For readability, we usually de¿ne two procedures:

```prolog
check( Cond ) :- not not Cond.
side_effects( Goals ) :- not not Goals.
```

One example should suf¿ce:

```prolog
prettyprint( Term ) :- side_effects( doprettyprinting( Term ) ).
```

Suppose now that we need instantiations produced when executing a call, and that space still matters. To preserve the results (i.e. the appropriate tenns) over backtracking, we must “put them aside”. Only stored clauses are immune to failure. The following general-purpose procedure’ executes a call, and at the same time “garbage collects” the storage used by the call:

```prolog
with_gc( Call ) :-
    once( Call ), assert( ‘ASIDE’( Call ) ), fail.
with_gc( Call ) :-
    retract( 'ASIDE'( Call ) ), !.
                               % commit retract
```

This method makes sense when assert requires less storage than Call. or when the implementation has no general garbage collector but reclaims storage left by retracted clauses.

with..gc can be employed in loop optimisation, which is an important application of forced failure. Essentially, recursion is the most natural Prolog counterpart of Pascal-like iteration. Consider a program that takes large chunks of an even larger text. extracts some data from them. and puts these data into an open tree. The storage for a step is worth recovering. Let step assert basta. after having encountered the ¿nal chunk. The loop can be written as follows:

buildtree( _ ) :- retract( basta ), !. % remove the signal

```prolog
buildtree( Tree ) :-
    with_gc( step( Tree ) ). buildtree( Tree ).
```

(Find a similar solution for closed trees.)

<!-- page 138 -->
I This technique was advocated by R. A. Kowalski at the Logic Programming Workshop in Debrecen. Hungary. I980.

Suppose now that steps of a loop have no common terms (which would have to be passed down the loop). This means that a step is executed only for its side-effects. For example, consider the problem of reading in a Prolog program up to the clause end.. Let the procedure clause_in perform one step: read a clause and assert it (unless it is end. or incorrect). The following procedure repeatedly calls on clause_in, and recovers storage after each step:

```prolog
getprog :- clause_in( Clause ), Clause = end, !.
getprog :- getprog.
```

This loop can be made even more concise if we use a “failure screen”. This is a procedure that always succeeds nondetenninistically, i.e. leaves room for yet another success:

```prolog
repeat.
repeat :- repeat.
```

(it is standard in some Prolog implementation). The loop can be expressed as

```prolog
getprog :- repeat, clause_in( C ), C = end, !.
```

After C = end succeeds, the cut will remove the pending choice in repeat, and so terminate the loop.

For this technique to work, the core of the loop must be deterministic, as otherwise a failure of C = end would evoke another attempt to execute an already executed step. Usually it suf¿ces to enclose the call for a step in once(_):

```prolog
getprog :- repeat, once( clause_in( C ) ), C = end, !.
```

A special form of forced failure is caused by tagfail". This built-in procedure is described in Section 5.12, together with other associated procedures. They are all primarily used for error handling, as they allow bypassing of large fragments of a computation. Here we shall present an application of tag and tagfail for exiting loops.

An extremely simpli¿ed interactive executor of Prolog commands can be programmed as follows:

```prolog
ear :- tag( loop ).
ear.
loop :- repeat, read( C ), once( C ), fail.
```

<!-- page 139 -->
' It is only available in Toy (see Section 5.12), but something similar is present or can be programmed in several other implementations of Prolog. The execution of

```prolog
tagfail( loop )
```

terminates the loop: tag(loop) fails, and the second clause of ear promptly succeeds. With a step de¿ned as

```prolog
step :- read( C ), once( C ).
```

and loop rede¿ned as

```prolog
loop :- repeat, tag( step ), fail.
```

we can also exit one step by calling

```prolog
tagfail( step )
```

4.3.3. Clauses as Global Data

The program modi¿cation procedures-assert, retract and the likeare ¿rst of all used to maintain Prolog data bases (see Section 8.2). They can also be used in automodifying procedures, those which assert or retract their own clauses; this is an extremely dubious programming trick, and is not recommended, especially since such programs tend to be rather subtly implementation-dependent.

Modi¿cation procedures are also used to store so-called global data. In Prolog implementations that do not support modularisation, the data kept in program clauses (notably unit clauses) are accessible to all procedures, i.e. global. Such data are signi¿cant in Prolog because they are not affected by backtracking—see with_gc in the previous section. Also, they are sometimes more convenient to handle than information passed around via parameters. One example is a “switch”—a parameterless unit clause whose presence or absence provides a simple yes/no test. For instance, we can supply terse or wordy error messages:

```prolog
message( Code ) :- terse, short_mes( Code ), nl, !.
message( Code ) :- long- mes( Code ), nl, !.
short_mes( sym( S ) ) :- display( ‘?sym ‘ ), display( S ).
long_mes( sym( S ) ) :-
```

display( ‘Unexpected symbol on input: ' ),

display( S ), nl,

display( ’ The remainder of the command will be ignored.’ ). A switch can be easily tumed on:

```prolog
tumon( Switch ) :- Switch, !.
                              % already on
tumon( Switch ) :- asser1( Switch ).
```

<!-- page 140 -->
and off:

```prolog
turnoff( Switch ) :- retract( Switch ), !.
                        % fails if Switch was off
turnoff( _ ).
                        % already off
```

We can also revert the state of a switch (on —> off, off —> on):

```prolog
Àip( Switch ) :- retract( Switch ), !.
Àip( Switch ) :- assert( Switch ).
```

Switches are really cumbersome to program without clausal data. It is not dif¿cult to rewrite message:

```prolog
message( Code, terse ) :- short_mes( Code ), nl, !.
message( Code, wordy ) :- long_mes( Code ), nl, !.
```

but the Terseness parameter ought to be carried everywhere throughout the program: and dynamic reversal of a switch can be somewhat messy.

Our ¿nal example demonstrates how assertions can be used to memorize results of expensive computations for future use. Let the procedure integrate perform symbolic integration of a given formula (and fail if it cannot be done). If we are going to use this procedure frequently, we may wish to avoid recomputing integrals. To this end, we should store every integral, once computed, and always try to ¿nd a ready answer before launching actual integration. Here is a possible solution:

```prolog
integral( Expr, IExpr) :- stored_integral( Expr, IExpr ), !.
integral( Expr, IExpr ) :-
    integrate( Expr, IExpr ),
    assert( stored_integral( Expr, IExpr ) ).
```

In fact. we have thus furnished our program with a primitive learning capacity.

## 4.4 Examples of Program Design

In this section we look at several tiny programming problems and their solutions which result from more or less formal analysis. This is not a real exercise in derivation of programs from formal speci¿cations (see Hogger I979; Gregory I980: Burstall and Darlington I977). This is. at best. an illustration of such derivation. not very rigorous and with formulae kept as simple as possible.

<!-- page 141 -->
These particular problems present no dif¿culty to experienced programmers, who can readily solve them without resorting to sophisticated techniques. Simple as they are, they help demonstrate how logic formulae, which lend justi¿cation to a program designed in a traditional way, can also be viewed as the same program (“modulo” some clean transformations). Implications of this observation for logic programming are farreaching and largely uninvestigated; see Shapiro (l983a) for fascinating examples of Prolog programs which are but a by-product of theoretical considerations.

Some of the procedures discussed below can be bi-directional, but we intentionally neglect such possibilities. As an exercise, try to discover some of their less obvious applications.

Formulae will be written according to the conventions of Prolog-I0: variable names are capitalized, functor names begin with small letters.

4.4.1. List Reversal

Let rev(X) denote the reverse of list X, let X with A denote the result ofattaching A at the end oflist X (e.g.. lp. q] with r = lp. q. r]). Let X = Y mean: X matches Y.

Assuming that X with A has already been de¿ned. a possible de¿nition of rev is: (4-I)

**rev(ll)=ll**

(4.2)

rev( [ A I Tail ] ) = rev( Tail ) with A Now, recall that in Prolog we can comfortably express relations such as “the reversal of X is Y” (which implicitly de¿nes Y as rev(X)) without resorting to the notion of equality. To re-express (4.2) accordingly, we begin with the introduction of a new variable to denote rev(Tail): (4.3)

**T = rev( Tail ) I) rev( I A I Tail ] ) = T with A**

This formula is equivalent to (4.2). Another new variable will denote T with A: (4.4)

T = rev( Tail ) I) I TA = T with A =>

```prolog
rev(lA|Tail])=TA)
```

which is equivalent to (4.5)

(T = rev( Tail ) /\ TA = T with A ) =>

rev(lA|Tail])=TA

<!-- page 142 -->
We shall rewrite this implication. and the formula (4.l). using rever.s'e(X. Y) instead of rev(X) = Y, and attut'h(X, Y. Z) instead 0fZ = X tt't'lh Y: (4.6)

**reverse( Tail, T ) /\ attach( T, A, TA ) =>**

```prolog
reverse( I A I Tail ], TA )
```

(4.7)

```prolog
reverse( l], [] )
```

These two formulae are exactly the logical interpretation of the following procedure:

```prolog
reverse( [ A I Tail ], TA ) :-
    reverse( Tail, T ), attach( T, A, TA ).
reverse( I], [] ).
```

The procedure attach can be derived in a similar way:

a-an-~. :5?‘~00‘:--/'--I

**[]withA=lA]**

**[BITail]withA=[B|(TaiIwithA)]**

From (4.9) we can obtain (4.10)

**TA=TailwithA=>lBITaiI]withA=[BITA]**

and this (together with (4.8)) is rewritten as (4.ll)

```prolog
attach( Tail, A, TA ) :> attach( I B I Tail ], A, [ B I TA ] )
```

(4.I2)

attach ( []. A. I A I )

These derivations are by no means unique. Here is another reasoning that starts with (4.2). We ¿rst introduce TA to denote rev([A I Tarll). and get

(4. I3)

TA = rev( [ A I Tail ] ) :> TA = rev( Tail ) with A which is equivalent to (4.2). Now we introduce T: (4.I4)

**(TA=rev([AITail])/\T=rev(Tail))=>**

TA = T with A This is easily translated into Prolog:

```prolog
attach( T, A, TA ) :-
    reverse( I A I Tail ], TA ), reverse( Tail, T ).
```

In short: we managed to de¿ne attach by reverse, but the de¿nition is only useful if we can de¿ne reverse independently of attach.

Another method of reversing a list stems from its interpretation as a stack (see Section 4.2.1). If we move the items of one stack onto another, they will come up in reversed order. Let Stackl and Stack2 denote the stacks before this reversal. The ¿nal content of the second stack will be

<!-- page 143 -->
rev( Stackl ) ++ Stack2 with X + + Y denoting the result of appending Y to X. The following two equalities de¿ne rev recursively: (4.15)

rev( I] ) ++ Stack2 = Stack2 (4.16)

**rev( I A I Tail ] ) ++ Stack2 = ( rev( Tail ) ++ [A ] ) ++**

Stack2 Now, ++ is associative, and [A] ++ Stack2 = [A I Stack2], so that we can transfonn (4.16) into (4.17)

rev( I A I Tail ] ) ++ Stack2 = rev( Tail ) ++ [ A I Stack2 ] Next, we introduce a new variable Final: (4.I3)

Final = rev( Tail ) + + I A I Stack2] I}

Final = rev( [ A I Tail ] ) ++ Stack2 Let reverse2(X, I’, Z) denote the formula Z = rev(X) + +

I’. From (4.15) and (4.18) we get (4.19)

```prolog
reverse2( [], Stack2, Stack2 )
```

(4.20)

reverse2( Tail, I A I Stack2 ], Final ) =>

```prolog
reverse2( I A I Tail ], Stack2, Final )
```

(or, accordingly, the same in Prolog). For Y = [], reverse2(X, Y, Z) reads Z = rev(X), so to get the reversal of L we must call

```prolog
reverse2( L, [], LReversed )
```

—indeed, Stack2 must be initially empty.

Notice that in going from (4.17) to (4.18) another direction of the implication could have been chosen. This choice would lead to the Prolog clause

```prolog
reverse2a( Tail, [ A I Stack2 ], Final ) :-
    reverse2a( [ A I Tail ], Stack2, Final ).
```

which de¿ned the shorter list in tenns of the longer. Even though it is logically correct, operationally it is unrealistic: neither this nor (4.19) would match the initial call with non-empty L.

We shall conclude this section with an even less formal derivation of difference-list reversal. Let the list to be reversed be L -- Z, where L = [A,,

An I Z]. We can write

**rev(L--Z)=[A,,IX]--Y**

with X -- Y = rev([A,,

A,,-, I W] -- W). Since W is an arbitrary term, we can assume W = [An I Z], so that

<!-- page 144 -->
X--Y=rev(L--[A,,IZ]) We now express the longer list by the shorter (see reverse2a above!):

**rev(L--lA,,|Z])=X--Y:>**

**rev(L--Z)=[A,,|X]--Y**

and rewrite it in Prolog, with reverse_d(X, Y) instead of rev(X) = Y:

```prolog
reverse_d( L -- Z, I An I X ] -- Y) :-
    reverse_d( L -- I An I Z ], X -- Y ).
```

The base clause,

```prolog
reverse_d( Z -- Z, Y -- Y ).
```

must come (i.e. be tried) ¿rst, because otherwise each call with a variable second parameter will fall into in¿nite recursion (you may wish to check this more thoroughly). This is where the peculiarities of Prolog come into play, and obscure the so-far clean derivation. It is even worse: we have missed one weakness of almost all Prolog implementations: the absence of so-called occur check during uni¿cation (see Section I.2.3). Therefore, the base clause matches calls with a non-empty list as the ¿rst parameter, if only the list ends with a variable. For example, the call

```prolog
reverse_d( [ a, b I Z I -- Z, Rev )
```

instantiates Z <— [a, b I Z] and Rev <— Y -- Y. contrary to our expectations. One possible remedy is to instantiate the ¿nal variable as [] before going on, but to this end both clauses of reverse_d must be duplicated. The complete procedure follows.

reverse_d(

E]

~— L]:

Y

——

Y ).

reverse"d(

L -" E]:

[¿n

I

X]

"—

Y

)

=-

reverse_d(

L

—— [¿n]:

X

"—

Y )-

reverse_d(

Z -- Z:

Y ~~

Y ).

reverse_d( L

—~ Z:

[An

I

X]

—-

Y

)

=-

reverse_d(

L

—— [An

I Z]:

X

—~

Y ).

Check that even this improved version loops for “negative” lists such as [b] -- la, b]. As you see. difference lists are useful but can be rather tricky.

4.4.2. Sorting

<!-- page 145 -->
We shall derive three procedures to sort a closed list of integers in ascending order. The ¿rst two implement insertion sort and a very simple transposition sort, a variation of “bubble sort”. Both have running time proportional to the square of list length (but both seem passable because few Prolog applications require fast sorting procedures). The third procedure is the simplest quicksort, which takes less time but uses more space (the same justi¿cation applies).

Let X into I’ denote the list that results from inserting the integer X into the ordered list Y. For example.

5into[4,7, 10] = l4,5,7, I0]. A possible de¿nition of insertion consists of three formulae: (4.2I)

**A into I] = [A]**

(4.22)

**A>B=>Ainto[BITail]=IBI(AintoTail)]**

(4.23)

**A=<B:>Ainto[BITail]=[A,BITail]**

The formula (4.22) can be rewritten as (4.24)

**A>B/\AT=AintoTail:>Ainto[BITail]=[BIAT]**

and then we can use insert(X. Y, Z) instead of X into Y = Z to get the following procedure:

```prolog
insert( A, [], I A ] ).
insert( A, [ B I Tail ], [ B I AT] ) :- A > B, insert( A, Tail, AT).
insert(A,[BITail],IA,BITail]):-A =< B.
```

Now, let sorted(X) denote the sorted permutation of the list X. We can de¿ne sorted in the following way: (4.25)

sorted( I] ) = I] (4.26)

```prolog
sorted( I A I Tail ] ) = A into sorted( Tail )
```

The latter formula can be replaced by (4.27)

**ST = sorted( Tail ) /\ AST = A into ST I)**

sorted( I A I Tail ] ) = AST To express it in Prolog, we shall rewrite sorted(X) = Y as ins_sort(X, Y), and get these two clauses:

```prolog
ins_sort( I], I] ).
ins_sort( I A I Tail ], AST ) :-
    ins_sort( Tail, ST ), insert( A, ST, AST ).
```

The order of calls in the second clause is not accidental: the tests in insert require fully instantiated parameters. so the procedure would not work if insert came ¿rst!

<!-- page 146 -->
Transposition sorting results from the observation that a sequence is unordered iff it contains an unordered pair of contiguous items (e.g. A, B such that A > B, if we consider the ascending order). Each step of a sorting algorithm should increase the “orderedness” of the sequence, e.g. by swapping A and B.

The following formula characterizes this sorting method:

(4.28)

**L=X++[A,BIY]/\A>B/\LT=X++[B,AIY]**

=> sorted( L) = sorted( LT)

where X + + Y denotes Y appended to X. We should describe explicitly the “less ordered” sequence by the “more ordered”, e.g. thus:

(4.29)

**L=X++[A,BIY]/\A>B/\LT=X++IB,AIY]**

**/\SL= sorted(LT):>SL= sorted(L)**

Using trans_sort(X, Y) for sorted(X) = Y, and append(X, Y, Z) for X + + Y = Z, we can rewrite (4.29) into Prolog:

```prolog
trans_sort( L, SL ) :-
                     <-M
    =1PP¢nd(X.lA
                      Yl.L).A>B.
    append( X, I
                       ], LT), trans_sort( LT, SL ).
               re 2.1::
```

Suppose now that for no X, A, B, Y we have L = X ++ IA, B I Y] /\ A > B, i.e. that L is either ordered or too short (and also orderedl). More formally:

(4.30)

**“(L=X++IA,BIY]/\A>B)I>L=sorted(L)**

When we rewrite this in Prolog, we shall drop the premise and place the resulting clause after the recursive one. The ¿rst two calls in that clause can be regarded as tests: does L contain a two-item subsequence, and is this subsequence unordered? The clause fails if this is not the case, and the premise of (4.30) becomes trivially true. We are left with the clause

```prolog
trans_sort( L, L ).
```

which is exactly the required base clause: we proceed from “less ordered” sequences, so that eventually we must get an ordered permutation.

<!-- page 147 -->
The arrangement of calls in the ¿rst clause is crucial. To begin with, we repeatedly isolate any two contiguous items (this fails if the list is too short), and we look at their ordering. The ¿rst improperly ordered pair terminates this process, and we recursively sort the “improved” sequence. The procedure is attributed to van Emden (Coelho et al. I980).

The last sorting algorithm we are going to program in Prolog is the well-known quicksort (Hoare 1962). For a given sequence L and its element A, let small(L, A) denote the subsequence consisting of all items smaller than A, and large(L, A) those larger than A. Items equal to A will fall, say, into small(L, A). The following formulae describe two possible situations: (4.31)

sorted( I A I L ] ) = sorted( small( L, A )) ++ A ++

```prolog
sorted( large( L, A ) )
```

(4.32)

sorted( I] ) = I]

The usual transfonnations of (4.31) give, for example,

(4.33)

**small( L, A ) = LAs /\ large( L, A ) = LAI /\**

sorted( LAs ) = SLAs /\ sorted( LAI ) = SLAI =>

**sorted([AIL])=SLAs ++ [A]++ SLAI**

When implementing quicksort, a standard practice is to compute small(L, A) and large(L, A) simultaneously, i.e. to introduce

```prolog
partition( L, A, LAs, LAI )
```

instead of the ¿rst two equalities in (4.33). Here is the Prolog code for partition (it can be derived in a straightforward way):

```prolog
partition( I X I Tail ], A, I X I Small ], Large ) :-
    X =< A, partition( Tail, A, Small, Large ).
partition( I X I Tail ], A, Small, I X I Large ] ) :-
    X > A, partition( Tail, A, Small, Large ).
PÀÀiliont ll. -. ll. ll ).
```

The formula (4.33) should be transformed in the usual way:

(4.34)

partition( L, A, LAs, LAI ) /\

sorted( LAs ) = SLAs /\ sorted( LAI ) = SLAI /\

**SLAs ++ I A I SLAI ] = Sorted I)**

sorted( I A I L ] ) = Sorted This is directly expressible in Prolog, with quick_sort(X, Y) denoting the equality sorted(X) = Y:

```prolog
quick_sort( I A I L ], Sorted ) :-
    partition( L, A, LAs, LAI ),
    quick_sort( LAs, SLAs ), quick_sort( LAI, SLAI ),
    append( SLAs, I A I SLAI ], Sorted ).
quick_sort( I], I] ).
```

<!-- page 148 -->
ln the worst case. the cost of appending sorted fragments is proportional to n2 for a list of length n. We can avoid appending altogether exactly as we did in reverse2 in the previous section. We take the empty stack, son large(L. A) and push sorted(large(L. A)) onto the stack. Next. we stack A. and ¿nally sorted(sma|l(L. A)).

The formulae corresponding to (4.3l). (4.32)—and similar to (4.15). (4. l6)—are as follows:

(4.35)

sorted( [ A I L ] ) ++ Stack2 =

sorted( sma|l( L. A )) ++ l A ] ++

sorted( large( L. A ) ) ++ Stack2 (4.36)

sorted( [] ) ++ Stack2 = Stack2 We can now repeat the same reasoning and replace (4.35) with (4.37)

partition( L. A. LAs. LAI ) /\

**sorted( LAs) + + [A] + + sorted( LAl ) + + Stack2=Sorted**

=> sorted( I A I L ] ) + + Stack2 = Sorted The lefthand side equality in (4.37) must be rewritten as

(4.38)

sorted( LAI ) ++ Stack2 = LargeStacked /\

sorted( LAs ) ++ [ A ] ++ LargeStacked = Sorted We introduce q_sort(X. Y. Z) for the equality sorted(X) ++ Y = Z. and get the following procedure:

```prolog
q_sort( [ A I L ]. Stack2. Sorted ) :-
    partition( L. A. LAs. LAI ).
    q_sort( LAI, Stack2. LargeStacked ),
    q_sort( LAs. l A I LargeStacked ]. Sorted ).
q_sort( []. Stack2, Stack2 ).
```

And wrap it in

```prolog
quick_sort_2( List. Sorted ) :- q_sort( List. ll. Sorted ).
```

This version of quicksort is also attributed to van Emden (Coelho er al. I980).

<!-- page 149 -->
Notice that the recursive calls on q_s0r! can be interchanged. A partly uninstantiated stack will be appended to sorted(small(L. A)): the other call will then fully instantiate the stack. Actually. the pairs Sorted. [A I LargeStacked] and LargeStacked. Stack2 can be interpreted as difference lists. Try to derive more formally a version of quicksort with difference lists.

FIG. 4.l$

A graph.

**K**

4.4.3. Euler Paths”

We shall try to solve in Prolog the problem of ¿nding Euler paths in an undirected graph. For the sake of completeness. here are the basic de¿nitions. An undirected graph is the pair (V, 6’), with V a ¿nite set of vertice-s and ‘S a set of edges. A vertex is labelled with a unique name. An edge is an unordered pair of different vertices, usually interpreted as a connection between them. A graph is often modelled by a drawing with a point for each vertex and a line (connecting the two vertices) for each edge. Figure 4. l5 shows a graph which consists of ¿ve venices and eight edges. A path from vertex X to vertex Y is a sequence of edges such that contiguous edges share a vertex. X belongs to the ¿rst edge. Y to the last. For example,

**(&.b).(b.¢).(¢.d).(d.¢)**

is a path from a to e in the graph of Fig. 4.l5. The same path can be unambiguously represented as a sequence of vertices:

abcde

An Euler path is a path passing through all vertices. in which every edge occurs exactly once. An Euler graph is a graph that contains an Euler path. For our graph.

**dbacbecde**

<!-- page 150 -->
“The problem (described as “drawing a picture") was solved in Prolog by Szercdi (I977). is an example of Euler path. If we remove the edge be. the resulting graph will not be an Euler graph (you may wish to check this).

We shall develop a very simple program. depending only on the most intuitive properties, which looks somewhat blindly for Euler paths. A more ef¿cient algorithm arises from a theorem that characterizes Euler graphs. We shall quote the theorem at the end of this section.

At ¿rst, we must choose a method of representing graphs. We can assume that the graph contains no isolated venices (vertices which do not belong to any edge); otherwise. it is certainly not an Euler graph. A graph without isolated venices can be represented by its set of edges alone. An edge is an unordered pair. i.e. a set of two vertices. Since we have no sets in Prolog (as in most programming languages). we shall represent edges with ordered pairs:

Vl<—>V2 (<—> is a non-associative in¿x functor). and we shall try to make the program account for the cummutativity of pairs.

Euler graphs have the following two properties: l. A graph with one edge is an Euler graph.

2. Suppose we take out an edge, and what remains is a Euler graph with

an Euler path starting with one of this edge‘s vertices: then the whole

graph is an Euler graph (and we happened to have removed a tenninal

edge of an Euler path).

Let paths be represented with lists of vertex names. and let parh(E.P) mean “E is the set of edges of an Euler graph. and P is an Euler path in this graph". The ¿rst property above can be rewritten as two fonnulae: (4.39)

```prolog
path({Vl <—>V2 },[Vl,V2])
```

(4.40)

```prolog
path({V2<—>Vl }, I Vl, V2])
```

In other words, both arrangements of vertices are equally satisfactory.

Here is how the second property can be formalized (\ denotes set subtraction): (4.41)

path( E \ { Vl <—> V2 }. [ V2 I RestofPath ] ) I}

```prolog
path( E, [ VI. V2 I RestofPath ] )
```

(4.42)

path( E \{ V2 <—> Vl }. [ V2 I RestofPath I ) I)’

```prolog
path( E. [ Vl. V2 I RestofPath ] )
```

<!-- page 151 -->
Before we rewrite (4.39-4.42) into Prolog, we must ¿nally decide how to represent sets. We can use any structure capable of holding uniform data; to keep things simple we shall use lists. (Another possibility would be to represent each edge as a separate clause, but then we would have no easy way of passing a set of edges as a parameter to a path-¿nding procedure.)

The fonnulae (4.41) and (4.42) must be transformed to get rid of the complicated expression inside path: for example. (4.41) becomes

(4.43)

El = E \{ Vl <-> V2 } /\ path( El, I V2 I RestofPath I ) =}

```prolog
path( E, [ VI, V2 I RestofPath ] )
```

**With the set {VI <-> V2} represented as the list [VI <-> V2]. and**

with takeout(X. Y. Z) denoting the equality X \ {Y} = Z. we can write down the procedure path:

```prolog
path( [ Vl <-> V2 ]. [ VI. V2 ] ).
path( I V2 <-> Vl ]. [ VI. V2 ] ).
path( E, [ VI, V2 I RestofPath ] ) :-
    takeout( E. VI <-> V2, El ). path( El. I V2 I RestofPath ] ).
path( E. [ VI. V2 I RestofPath ] ) :-
    takeout( E. V2 <-> Vl, El ). path( El. [ V2 I RestofPath ] ).
```

Notice that details of set representation are transparent to the recursive clauses.

A list version of takeout can be de¿ned in a straightforward manner. so we shall skip a detailed derivation:

```prolog
takeout( I VI <-> V2I El ], VI <-> V2. El ).
takeout( [ Edge I Edges ], TheEdge, [ Edge I Remainder ] ) :-
    takeout( Edges, TheEdge, Remainder ).
```

This program is crying out for optimisation: in the worst cases we can traverse the list E twice before locating the edge to be taken out. One solution. actually presented in Szeredi (I977). is to make takeout. rather than path. sensitive to the order of vertices. This can be easily achieved by adding another base clause to takeout:

```prolog
takeout( [ V2 <-> Vl I El ]. Vl <-> V2. El ).
```

and deleting any one of the two recursive clauses of path.

The procedure path can be used non-deterministically. to produce all Euler paths in a given graph, or with a cut, to check whether the graph is an Euler graph (and ¿nd an instance of Euler path). It can also be used the other way round: given a path it computes a list that represents the Euler graph with this path (or all such lists, but this would be overzealous).

<!-- page 152 -->
We shall need a few more de¿nitions to formulate Euler‘s fundamental theorem on Euler graphs. A graph is connected if for each two vertices Vl , V2 there is a path from Vl to V2. For example. the graph of Fig. 4.15 is connected. The degree of a vertex is the number of edges which contain the vertex. For example. h in our graph is a vertex of degree 4. and e of degree 3.

The theorem states that a graph is an Euler graph if and only if it is connected and contains either no vertices of an odd degree. or exactly two such vertices. In the latter case. the two odd-degree vertices are terminal vertices of each Euler path. In the former case. each Euler path is a cycle. i.e. a path that returns to the starting point. In our example. d and e are the only vertices of odd degree.

If the graph is known to be an Euler graph. an Euler path can be found in time proportional to the number of edges. Once removed. the edge can be attached to the path for good. You may ¿nd it amusing to modify the above program in this direction.

