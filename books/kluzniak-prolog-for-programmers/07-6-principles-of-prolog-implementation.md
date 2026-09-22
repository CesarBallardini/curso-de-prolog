# 6. Principles of Prolog Implementation

<!-- page 177 -->
**IIVIPLEIVIENTATION**

## 6.1 Introduction

This chapter is but a bird's-eye view on implementation techniques speci¿c to Prolog. We assume you know how conventional block structure languages are implemented: a competent programmer could hardly escape learning these things. The discussion is kept at a level free of representation details. Chapter 7 provides a rather detailed and complete case study of one of the many ways in which the basic principles can be applied in practice.

Two topics are missing: compilation and garbage collection. To compile Prolog programs is to apply the general principles in such a way that a program is executed particularly ef¿ciently. This is done partly by taking advantage of the underlying machine (e.g. by using machine code instead of a more compact representation of programs. trading speed for memory) and partly by performing special case analysis to detect operations which can be simpli¿ed (e.g. uni¿cation with a variable which is known to be uninstantiated). We decided that compilation is beyond the scope of this book (which already discusses implementation issues more thoroughly than the usual introduction to a programming language). The problem and techniques of garbage collection are well known, and are best studied independently of a particular programming language (though you will ¿nd that in Prolog one has to do with one of the harder variants of the problem).

<!-- page 178 -->
I67

## 6.2 Representation of Terms

If we disregard the possibility of forming cyclic structures (see Section l.2.3), we can see that all terms are directed acyclic graphs (DAGs). They are not necessarily trees. because different branches can converge to a common component: in linear notation we express this phenomenon by repetition, as in t(p(X), q(p(X), Y)).

In a Prolog program. several identical occurrences of a term within a single clause denote the same object. Properly speaking, this is not an object but a descriptor, or template. At execution time, it corresponds to different objects in different instances of the clause. In this and the next chapter we shall reserve the unadorned word “term” for tenn instances. Terms written in a program will be referred to as tenn descriptions. A description can have several occurrences; similarly. an instance can have several parents in a DAG.

There are many possible representations of a DAG. For our present purposes they are all equivalent, provided that it is possible to distinguish nodes corresponding to Prolog variables. On a more abstract level. however, two very different methods are used to implement term instances. Accordingly. all existing implementations of Prolog can be classi¿ed as either Structure Sharing or Non-Structure Sharing (NSS).

In principle. to form a new term instance in a Non-Structure Sharing system. one must create a new DAG. We are talking about creating new instances that correspond to term descriptions (present in the program text, or in clauses asserted after having been constructed by a program); creation of new terms as a result of uni¿cation is different. Variables are bound by being associated with pointers directed at their instantations. These pointers are invisible. i.e. automatically dereferenced, whenever the DAG is traversed. Figure 6.l illustrates—in a representation-independent manner-two terms, before and after uni¿cation.

A Structure Sharing system takes advantage of the fact that different instances of the same term differ only in their variable bindings. Whereas two instances of

```prolog
t(p(X).q(p(X).Y))
```

canbe

```prolog
l(P(c).q(P(¢).d))
                        and
    t(P(r(a)).¢l(P(r(a)).I'(a)))
```

<!-- page 179 -->
respectively, their general structure remains the same. The main functor must be a t of two arguments; t‘s ¿rst argument must also be the ¿rst

(o)

terrnl=

‘U

term2=

T

**I**

**. 7).**

**./\@ .**

(bl

**IE: If**

10??

I

°

P

B

**'/\**

**I**

I

FIG. 6.l

The Non-Structure Sharing representation of terms: (a) t(A. q(A. Y)) and t(p(X). B) before uni¿cation. (b) t(A. q(A. Y)) and t(p(X). B) instantiated to t(p(X). q(p(X), Y)) after uni¿cation.

argument of the two-argument q which is t’s second argument; and so on. Consequently, all instances of the term may share this structural information, if only care is taken to let them have different variables. This is easily achieved by associating each instance with a different variable frame: a chunk of storage holding variable instances. The intemal representation of a term description—we shall call it prototype—-is a DAG in which each variable node is represented by infomration about the offset of the variable’s location in a variable frame. All tenns-including variable bindings—are now represented not by single pointers, but by two-pointer tenn handles‘

< prototype, variable frame >

<!-- page 180 -->
' Another ten'nin0IOBy. introduced by Warren (I977a). is to call prototypes skeletons. and handles molecules. We do not like the mixed metaphor.

(0) l1r'.!Ji=< '

>

**0**

**t**

**_.**

,

**°'\**

**I**

Y:

**><=**

p

- GIEII) '\ prototype

variable trarnes

(bl terrnt:< v >

C

**0**

**....**

**... I**

Q'l'I'I'l I

<2’

>

**0**

**I**

**\**

d t _., \/ p Y‘. ' I I’ X:

0

3

<!-- page 181 -->
FIG. 6.2 The Structure Sharing representation of terms: (a) Two instances of t(p(X). q(p(X), Y)). both sharing the same prototype. (b) tennl instantiated to t(p(c). q(p(c). d)) and term2 instantiated to t(p(r(a)). q(p(r(a)). l'(¿)))-

Figure 6.2 illustrates the principle of Structure Sharing. Figure 6.3 corresponds to Fig. 6.l. If we ¿nd general DAGs less convenient than trees, Structure Sharing makes it easy to employ trees by providing implicit links to variables from all occurrence sites. This is shown in Fig. 6.4.

Inside a clause. different occun'ences of the same variable description can appear within different term descriptions. There is the problem of

(O)

mml-<

r

>\

,

‘.>

**t**

**\**

**I**

**I**

**°**

**°**

Q

P

**WI**

GED as-\

**-.**

**.\9/**

**=<=**

**(b)?.>**

**7:.-**

**.**

**\**

**.**

**\**

I

**Q**

**?**

**/\**

**21**

FIG. 6.3

<!-- page 182 -->
The Structure Sharing representation of tenns: (a) t(A.q(A. Y)) and t(p(X). B) before uni¿cation. (b) t(A. q(A. Y)) and t(p(X). B) instantiated to t(p(X). q(p(X), Y)) after uni¿cation.

<

1

>

**/\q ?**

**/**

FIG. 6.4

Structure Sharing: the DAG t(p(X). q(p(X), Y)) represented by a tree.

ensuring that the same variable becomes a part of all the corresponding terms associated with a clause instance. With Structure Sharing, this is done by allocating a single frame for all the variables appearing in a clause, at the moment of its activation. All occurrences of a variable within this clause's prototypes are encoded as the same ojfset in the common variable frame (this is just an application of the technique demonstrated in Fig. 6.4).

In practice, most NSS implementations use a very similar approach to solve the problem (despite its name. it is a hybrid method). Term instances are also encoded as prototypes, with variables represented by offsets into a clause's variable frame. One difference is that variable frame locations hold only single pointers rather than term handles. The other—more important—difference is that terms formed in this way are only “virtual” instances. This is to say that they may be used only as data selectors, directing uni¿cation to instantiate variables in the variable frame. Whenever one of these terms is to become a variable‘s instantiation. a “real” instance (a new DAG) must be built. If this new instance contains a variable. its variable node becomes a copy of the appropriate location in the variable frame, while the location is made to hold a pointer to the node. This ensures that all future references to the variable will end up in the node.

<!-- page 183 -->
The process is shown in Fig. 6.5. Note that here, too. prototypes can

**I”**

**...**

**....**

**EB**

P

**t\/ -/**

**3...**

**@._. @._.:..**

**\n or@/B E._.. ,;..**

**BE**

**9**

**E \**

**@\/**

**8**

**/I\**

**../**

FIG. 6.5

“Virtual” and “real” instances in Non-Structure Sharing: (a) proc(t(p(A). p(A). q(p(A).B))) is called with pr0c(t(p(X). Y. q(Z. I'tY))))—both terms are “virtual” before uni¿cation. (b) The ¿rst occurrence of p(A) acts as a selector—A is bound to X. (c) The second occunence of p(A) acts as a constructor—Y is bound to its copy (a

instance).

<!-- page 184 -->
(d) q(p(A). B) and q(Z, r(Y)) both act as selectors. but p(A) and r(Y) are constn|ctors—both tenns are now t(p(X). p(X). q(p(X), r(p(X)))). represented by a mixture of “real” and “virtual“ instances. (continued) I

I

- *-

- anrr

I‘

**5- 1 m**

**I**

**/I**

II

**El**

**@\. _/**

**s:at**

I

**I**

.

**.P**

I @..____..

**\**

**.@/ @.___..**

GED

**8**

P

FIG. 6.5 (Continued)

be trees, and more general DAGs are implemented by variable bindings. In general. the process of term creation can give rise to several copies of a single term instance (p(A) in the example), but these are indistinguishable.

The process of copying an uninstantiated variable might seem a little roundabout: why don’t all copies simply contain pointers to the variable frame location? Indeed, why are there any copies at all: is not Structure Sharing always better?

<!-- page 185 -->
Recall from chapter I (see Fig. I.6) that a term's lifetime may have to exceed that of the encompassing clause instance. Yet it is obvious that we would like to regard a variable frame—which is created when a clause is activated—as a part of the clause’s activation record. If we are careful to represent variable-to-variable bindings so that younger variables point at older ones rather than the other way round, and if term copies contain no pointers into variable frames. then there is no risk of leaving dangling

6.2. Representation of Tenns

I75

td)

A=0

x=0

**8/**

**'3**

**\ I**

I 8...‘ ,._;.

**B“\**

p

II

FIG. 6.5 (Continued)

pointers as activation records are deallocated upon procedure completion (according to the normal stack regime)’.

The situation is quite similar to that encountered in Pascal, say: an object which is to live longer than the procedure which has created it is allocated in the heap, i.e. a memory area distinct from the activation stack. The NSS heap is called a copy staclr. It is a true stack, because term copies can obviously be discarded when the program backtracks past their point of creation. They can become inaccessible much earlier, too, and a garbage collector could be very useful, but it is not essential to Prolog as it is to Lisp. One must remember, however. that without garbage collection the copy stack's size is roughly proportional to the amount of time spent in forward execution (without backtracking). and

<!-- page 186 -->
1 But this is not always possible (see the next section). that one may need to alleviate that by introducing arti¿cial failures in a few well-chosen places (see Section 4.3.2).

In the simplest form of Structure Sharing. a variable frame is an integral part of the representation of a number of term instances. and cannot—in principle—be deallocated so long as any of these terms is accessible. It must be allocated on a variable stack. which closely resembles the copy stack of NSS (except that a garbage collector. if required. is harder to implement). The activation stack is smaller, as it only holds control information.

The most important advantage of NSS is that retention past the moment of procedure termination concems only those terms which become variable instantiations. With simple Structure Sharing. on the other hand, all terms are retained. As it tums out. terms are often used as selectors rather than constructors. and clauses frequently propel a computation along without creating many long-lived objects. The copy stack is therefore usually smaller than the variable stack. and the effects of memory requirements being a function of time are much less pronounced with NSS.

Starting with DECProlog-I0, many Structure Sharing implementations take advantage of the difference between terms which must live longer than their clauses and those which need not. As a clause is read in, it is analysed to detect variables which cannot. under any circumstances. be used to form instantiations of variables outside the clause. These are classi¿ed as local variables, whereas the others are called global. The variable names are all local to the clause, of course—the terminology is to convey that global variables are long-lived, while local variables may be allocated (and deallocated) with the clause's activation frame. The activation stack is accordingly referred to as the local staclr, and the global stack holds global variables.

A simple. though not necessarily the most subtle, classi¿cation criterion is whether a variable appears inside a term (i.e. is not only a procedure‘s parameter). For example. in

```prolog
a(X.f(Y)):-b(X.g(Z)).
```

we ¿nd that X is local. The rule about directing variable-to-variable references towards the bottom of the stack suf¿ces to ensure that its deallocation will not leave dangling pointers. The variable Y is obviously global, as the clause can “export” it after having been activated by

```prolog
a( Something. Variable ).
```

<!-- page 187 -->
The status of Z is uncertain. It can be bound to a variable in b. but we are really interested only in those outside variables which outlive a. If the body of a were

```prolog
b(s(Z))
```

then Z could conceivably be classi¿ed as local (according to our experience, though, allowing such cases could complicate the implementation). But as the clause stands. we need to analyse b (assuming it will not subsequently be modi¿ed!) to check whether g(Z) can be made an instantiation of a variable to which X is bound. For example. with b de¿ned as

```prolog
b( V, V )
```

the call

```prolog
a(P.Q)
```

would instantiate P <— g(Z) and Q <— f(Y)—both Y and Z would be “exported.” Variables that do not appear in terms can only be used to carry information around the clause; it is safest to assume that all others will be used to form structures.

This assumption does not yet allow Structure Sharing to be really competitive with NSS. To achieve this, we must declare our intentions by providing so-called mode declarations. In Prolog-I0 one writes

```prolog
:- mode member(?, +).
```

to inform Prolog that the second parameter of member will never be a variable, though its ¿rst parameter might be one. This means that the procedure

><l'I'l

l"l"

member( E, [

member( E, [

```prolog
member( E, L ).
```

will not be invoked as a generator of lists, so the compound tenns will only be used as selectors and all the variables—even those global by the general criterion—can be classi¿ed as local’.

Providing mode declarations may seem a nuisance, but they are good documentation (and are not compulsory). The declarations are static and must necessarily be less informative than the dynamic special-case analysis of NSS. In common cases. however, the difference is not detectable and this form of Structure Sharing is. in fact, as good as NSS with regard to memory utilisation. This does not mean that the two behave identically. Programs can be written which make any one method almost arbitrarily worse than the other (how would you go about devising such a program?).

<!-- page 188 -->
’ A compiler can also use this information to generate faster code.

Structure Sharing tends to be faster. but it is more complicated. There is the problem of analysing clauses. utilising mode declarations and manipulating term handles instead of single pointers. Moreover. system routines such as clause are harder to write because a clause can contain references to local variables and its instance is not therefore a correct term. If you want to write a simple memory-ef¿cient interpreter. use Non-Structure Sharing.

## 6.3 Control

One of the keys to the success of a Prolog implementation is the ef¿ciency of backtracking. Whenever a fail point is established (see Section I.3.2), the computation’s state must be saved. so that it can be restored upon failure. Both the saving and the restoration of a state are frequent events, which must take place as rapidly as possible.

The state of a computation can be reduced to the contents of the control stack and the heap‘. Obviously, Prolog's special requirements rule out checkpointing (i.e. dumping memory contents) as a means of saving the state. Logging (i.e. recording changes made to the state) is a more hopeful technique, as differences between successive states of interest are usually minute in comparison to the amount of information contained in a state. The technique is particularly suitable—and universally used—for dealing with the evolution of variable instantiations. Only uninstantiated variables can be modi¿ed, so the old value need not be remembered and it is enough to record a modi¿ed variable's address.

While logging is also a viable method of handling activation record traf¿c on the control stack, it would not be able to take advantage of the disciplined manner in which procedure instances are created and destroyed. A better method. well known since the appearance of (Bobrow and Wegbreit I973). can roughly be described as using the log itself to de¿ne a new state.

As a fail point is established, a fail point record is pushed onto a special stack. (We are interested in a conceptual description. In practice. this stack is often implemented by a chain of pointers threaded through activation records.) The fail point record stores information about current sizes of memory areas and a pointer to the list of untried clauses likely to match the current call. In other words, it contains information essential to Prolog‘s ability to recommence computations from this fail point. To

<!-- page 189 -->
‘ The generic tenns are meant to emphasize that this discussion is valid for Structure Sharing and NSS alike. make this information suf¿cient, stack and heap areas below the levels indicated by a fail point record are treated as frozen, i.e. under special protection.

Binding a frozen variable is allowed, but must be logged by pushing its address onto a fourth stack, called the trail (its size is also remembered in a fail point record). The control stack, however, is frozen quite literally. Whenever a terminating procedure would cause control to be retumed to an activation record (AR) within the frozen area, a copy of the AR is created just above the protected part of the stack. The copy de¿nes the current procedure‘s environment: an ancestor link provides access to the frozen AR of the procedure’s caller. To avoid copying that part of an AR which contains variables’, the variables ofa clause are associatedwith the A R of its caller rather than with its own AR. An AR's copy will be used to perform a new call: the original describes the previous call, so its variables are irrelevant. All this is illustrated in Fig. 6.6.

With these precautions, backtracking consists in undoing bindings made after creating the most recent fail point record FR (a simple matter of resetting locations referenced in the top-most fragment of the trail), popping all stacks to the levels indicated by FR, grabbing the untried clause list and popping FR itself. This is rapid enough; the unescapable penalty is that of maintaining (several copies of) frozen substacks which would normally disappear with the shortening of call chains. One of the reasons why judicious use of the cut is so important (see Section 4.3.1) is that it allows Prolog to reclaim stack storage. To invoke the cut is to pop a number of fail point records, thereby unfreezing areas of memory.

## 6.4 Tail Recursion Optimisation

Many programming tasks are inherently iterative. For example, to test whether an item is present in a list, we must look at successive elements until either the list is exhausted or the item is found. But in Prolog we can only de¿ne member as a recursive procedure. Recursion is more expensive than iteration in that it requires not only time but also stack storage which grows linearly with the number of tums. Storage is often a scarce resource, and it would be very unsatisfactory if each decision to traverse a list had to be accompanied by speculations about the potential length of the list. In Prolog, using recursion instead of iteration is all the more serious because the stack may subsequently have to be frozen.

<!-- page 190 -->
’ Local variables of Structure Sharing, "virtual" variable instances of NSS.

lo)

**li)**

alXlI—

```prolog
                      blXl.
       liil
             blZl:—
                      clZ),
                            d(Z).
       liiil
             blll.
       liv)
             ctel.
       lvl
             dlVl.
       2-
             alW), writetwl, fail.
                                        3
 lb’
                       —
                           serum
                               .-—————Q
                                        1‘
                                 I
                             wr|—telW) mt
                         U ix
                           W
                           ['11
                                            *1
                                        _I
                                        N
                                          --I,’
                                           ll
                                          ‘in
                                           \-
                                         \
1
     tnlow
                                        $5 '
trail level
next clause Ill
                          d‘-'""""Y
                            '_
                                        0
```

TRAIL

FAIL FOTNT STACK

comnot STACK

COPY STACK

O O i

**7'""" "**

**Es**

\\

'

a

.' - - - - - - -

"1:-~

**um**

**\**

2

‘T

.- - - - - - --

In.‘

- \

a gw|,wm¢|'\Ti,Tait

\

\\_.—.I\ ‘H11

**£~\ \**

\

5"-I-Q- \ \\Q

Q

**'-@=<» =--**

**--**

**- --**

trail level E

**a....:..m**

**O**

TRAIL

FAIL POINT STACK

CONTROL STACK

COPY STAG’!

FIG. 6.6

<!-- page 191 -->
Control stack management: (a) The example program. (b) Clause (iv) is invoked. (Solid lines in control stack are the ancestor links, dotted lines are variable bindings. Active calls are underscored, remaining calls in each clause are also shown. The model is NSS.) (c) One step later, d is ready to return. (d) After returning from d and b. (Frame 3 is a copy of I, executing the next call. The variable Z was destroyed when the stack was popped—it was just above the freezing level.) (e) After failure, before invocation of clause (iii). (f) Clause (iii) and (i) terminated. directive in control.

**id)**

v:rite—[W|,Iait

I

3

2

X:

F1111

\

\

**ii W|,vvriteIW) hit**

\\

- .

.

.

1

I

I’

II’ e

t'reen'I'|5-hdon

**_**

**Q;**

**._____ T.-.--"I**

trait level

_

**next diuserliill**

**O-**

0

TRAIL

FAIL POINT STEK

CONTROL STACK

COPY STACI4

(ET

**blxlf**

—

‘I

—_

2

X;

**0- - - - - -- -_**

**aIW],writeIW),tait**

'

\‘

I

.

--

**‘I’**

W: tree

dummy

0

TRAIL

FAIL POINT STACK

CONTROL STACK

COPY STACK

**If)**

**v.m¢|w1,Fa1t**

|

'

I

T

Y

1"

f

W1

**0-*1- - - - -**

**- " '**

dummy

0

TRAIL

FAIL POINT STACK

CUITROL STACK

COPY STACK

**FIG. 6.6 (Continued)**

**Tail recursion optimisation (TRO) is the technique of replacing some**

**forms of recursion with iteration. Despite its name, it is also useful in**

**situations where there is no direct recursion, or even no recursion at all-**

**just a long chain of procedure calls.**

**The general idea is illustrated in Fig. 6.7. Assume that q is the last call**

**in p and that p is deterministic, i.e. there are no fail points between the**

<!-- page 192 -->
```prolog
   :- ..., p...
p:*"
     allulq.
q :-
     FIG. 6.7
             Tail recursion optimisation.
```

invocations of p and q (they were not established or were removed by a cut). This means that both activation records are not frozen, and are not separated by locations containing useful information. Now, if the activated clause of q is known to be the last clause matching its call, then some of the information in the two activation records clearly becomes redundant. The younger frame's control information is no longer needed, because the only thing p can do after q’s termination is retum immediately to its caller: if q retumed to the caller of p, the effect would be the same. Similarly, the older frame’s variables (local or “virtual") will not be needed by p. TRO is the technical term for replacing the two—either during or after q’s invocation—by one activation record, with q‘s variables and with control information needed to exit from p. Ifq is the same as p (or contains a tail recursive call on p, or the like), many calls may be executed without increasing the size of the control stack. (The heap may grow, though, if the computation constructs some long-lived objects.)

<!-- page 193 -->
Several methods of implementing TRO are described in the literature, and we shall not discuss them here. An important feature of some of them is that they allow delayed TRO, i.e. merging ofour two activation records after q performs a cut, even though its initial invocation is not deterministic. In Section 7.3.4 you will ¿nd one such method, which we favour for its simplicity.

## 6.5 Bibliographic Notes

The idea of structure sharing comes from Boyer and Moore (I972). It was used in the original Marseilles interpreter (Battani and Méloni I973, Roussel I975), which, actually, was preceded by an earlier, experimental version (Colmerauer et al. I972). That interpreter did not have anything like fail point records. Though variables were allocated on a separate stack, control frames were also—as a rule—popped only on backtracking. Classi¿cation of variables into local and global was introduced with the DECProlog compiler. Warren (I977a) is the original reference, see also Warren et al. (I977) and Warren (I980b). A preliminary report on the ¿rst NSS implementation is Bruynooghe (I976).

The idea of tail recursion optimisation is well known. Bruynooghe was the ¿rst to use TRO in Prolog, while Warren used a different method as an afterthought; see Warren (I980a).

A good detailed explanation of the implementation principles is Bruynooghe (l982b). It stresses both the similarity of structure sharing to conventional handling of procedure instances and the similarity of Prolog’s control structures to a proof tree. Van Emden (I982) contains a disciplined derivation of the control algorithm, starting from search-tree traversal.

Most implementations merge fail point records and control frames into a single type of record. To our knowledge, they were ¿rst separated in Donz (I979), an early approach to global optimisation, where they were talked of as the and-nodes and or-nodes of a search tree. We like the separation because it brings to light the fact that backtracking is implemented almost exactly as proposed—in a more general setting—in Bobrow and Wegbreit (I973), the classic paper on implementation of unconventional control structures.

A comparison of NSS and structure sharing can be found in Mellish (I982), with some comments in Bruynooghe (l982b).

Mellish (I981) is an early approach to automatic production of mode declarations by means of global Àow analysis. Other papers concemed with global analysis, though not for the sake of ef¿ciency, are Bruynooghe (I982a) and Mycroft and O'Keefe (I983).

At the time of this writing we know of two new compilers being developed. The references are Bowen et al. (I983) and Ballieu (I983).

See also Section 2.5 for references on Prolog implementations with coroutining and parallelism.

As a point of interest, we shall mention two papers describing implementations of Prolog done by embedding it in another programming language: Lisp (Komorowski I982) or POP-ll (Mellish and Hardy I983).

