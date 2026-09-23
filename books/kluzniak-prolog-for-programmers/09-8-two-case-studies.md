# 8. Two Case Studies

<!-- page 224 -->
## 8.1 Planning

We shall consider planning with respect to a ¿nite. usually small. set of objects to which simple actions from a ¿nite. and also small. set are applicable. Objects constitute a closed “world‘ ‘. The state of the "world" is. by de¿nition. the set of all relationships that hold between its objects; we also call these relationships facts about objects. As a result of an action. some relationships cease or begin to hold; we say that an action deletes or adds facts. A fact established by an action is also called a goal achieved by this action. Every action transforms one state into another. Planning consists in ¿nding a sequence of actions that lead from a given initial state to a given ¿nal state.

As an example, we shall describe one of the so-called cube worlds. There are three cubes. a, b. c, and Àoor. All we can do with them is stack cubes on cubes or on the Àoor. There are two types of facts concerning a cube U and an object W: U is sitting on W. and U is clear (this means that nothing is sitting on U). The set of possible states is determined by naming all meaningless (i.e. impossible or forbidden) combinations of facts:

-—A cube X sitting on a clear cube Y;

-—A cube sitting on two different objects; —Two different cubes sitting on the same cube; —An object sitting on itself.

<!-- page 225 -->
There is one kind of action: move a single clear block, either from another block onto the Àoor, or from an object onto another clear block (the object must differ from both blocks). As a result of moving X from Y onto Z, X is sitting on Z instead of Y, Y is clear (unless it is the Àoor), Z is not clear (unless it is the Àoor).

(o)_

_

(bl

FIG. B.l

(a) An initial state of the cubes world. (b) A ¿nal state of the cubes world.

Even in this microscopic world, planning may require some sophistication. It is reasonable to postulate that a desirable fact, once added, will never be deleted (otherwise we risk an in¿nite loop). However, let the initial state be that of Fig. 8. la, described by a conjunction of ¿ve facts:

a on Àoor, b on Àoor, c on a, clear(b), clear(c).

Let the ¿nal state be that of Fig. 8.lb, described by a conjunction of two goals: c on a, a on b. The ¿rst goal is trivially achieved. To put a on b, though, we must remove c from a, i.e. destroy an already achieved goal. The simple strategy of achieving goals one by one (and freezing all relevant facts) would not work in this case.

ln a more crowded “world”, a state might comprise so many facts that its direct representation (as a list, say) would be impractical. Moreover, even a small change might require copying large data structures. Clausal representation is free from this disadvantage but it is unwieldy when a change must be undone, and of course planning is a trial-anderror process. What we need is a method of incrementally describing incremental changes, and making them easily undoable.

A state and an action determine the next state, if we assume that the action does not affect facts not mentioned explicitly in the description of the action‘s effects as added or deleted. Given an initial state and a plan, i.e. a sequence of actions, we can check whether a fact holds in the resulting ¿nal state. To undo an action, we remove it from the plan (in practice, this may be slightly more complicated).

<!-- page 226 -->
For any particular planning problem, the initial state can be considered ¿xed. The ¿nal state should be given implicitly, as a conjunction of facts to be established by a plan we are going to ¿nd. This approach was taken by D. H. D. Warren in his remarkable planning program, WAR- PLAN.

ln WARPLAN, a world description is separated from the planning procedure (see Listing 8. l, pp. 221-223, lines I-26, for the description of our cube world). Objects are given implicitly, in descriptions of actions and facts. Actions are de¿ned by three procedures. The two-parameter procedure

```prolog
can( Action, Precondition )
```

serves as a catalogue—one clause per action; Precondition is a con_iunction of facts that must hold for Action to be applicable. A conjunction is either a fact, or a pair of conjunctions constructed by the in¿x functor &, e.g.cona&aonb.

Two other procedures,

```prolog
add( Fact, Action )
del( Fact, Action )
```

give facts added and deleted by available actions (and, conversely, actions which can add or delete a fact). Impossible combinations of facts are listed in the procedure

```prolog
imposs( Conjunction )
```

In these four procedures, we can use variables instead of world objects to express general laws, e.g. “a clear cube U is sitting on a cube V":

U on V & notequal( V, Àoor ) 8: clear( U ) For ef¿ciency, facts that hold in the initial state, and are unaffected by any action, are listed in the procedure

```prolog
always( Fact )
```

Other facts that hold in the initial state are supplied by the procedure

```prolog
given( InitialStateName, Fact )
```

The initial state is denoted by its name, e.g. srarr. A state derived from it by actions Al,

An is denoted by the term

lnitia]StateName : Al :

: An, e.g.

start : move( c,a, Àoor) : move( a, Àoor, b ) : move(c, Àoor, a)

<!-- page 227 -->
The planning program (Listing 8.2, pp. 224-226) operates independently of speci¿c world descriptions. It assumes the presence of an appropriate data base whose coherence is the responsibility of the user.

The program begins with a conjunction of facts (i.e. the description of a desired ¿nal state) and the empty plan. In each step, the conjunction shrinks and/or the plan grows; successive intermediate states approximate the ¿nal state. Roughly speaking, the plan is constructed backwards: we look for preconditions of actions that achieve the ¿nal state, then for preconditions of actions that achieve those preconditions, etc. Unless a fact holds in an intermediate state, the program chooses an action that adds this fact, inserts the action into the current partial plan, removes the fact from the current conjunction and adds to it the action’s preconditions.

A partial plan usually contains variables. For example, to achieve a on b, we use the action move(a, V, b), whose precondition includes the fact a on V (for an unknown V). Such variables require some care: the fact U on c may, in general, differ from a on V, even though the two terms are uni¿able. We can either use the built-in procedure = = to compare facts, or temporarily instantiate their variables (by the built-in procedure numbervars) prior to the comparison.

In addition to the current conjunction and plan, the program maintains a conjunction of desirable facts already planned for. No newly inserted action can destroy any of these preserved facts.

The program is amazingly concise. In Warren's original paper it was accompanied by many pages of detailed considerations. Hence, the absence of proper comments in the program text. Below we shall present, in our own words, some indispensable technical explanations.

The main planning routine, plan, is called only if the ¿nal state description is not inconsistent (lines I0-l3), i.e. if it does not imply one of the impossible combinations of facts. plan has three input parametersfacts to be achieved, facts already achieved (initially true; see line l3) and the current plan—and one output parameter, the ¿nal plan. The procedure solve is called for each fact of the initial goal list (see lines 30-32). lt has ¿ve parameters: a fact to be established, preserved facts. the current plan, preserved facts after solve has succeeded and the new plan.

Every clause of solve accounts for a different status of the fact (lines 35-39). It may be always true; it may be true by virtue of general laws extemal to “worlds” (e.g. equality or inequality of objects will be checked by this clause); it may hold in the state described by the current plan (to preserve it, we add it to the facts planned for; see lines 83-84); otherwise (the last clause) we choose an action and call achieve.

<!-- page 228 -->
The procedure achieve (lines 4|-49) tries to apply a given action. i.e. to insert it into the current plan (as the last action, or as the last but one, etc.). The action U is applicable if it deletes none of the preserved facts, and if its precondition is consistent with these facts and if a plan for

8. l. Planning

ZI9

achieving this precondition can be constructed. Notice that possible additions to P (preserved facts) made by the recursive call on plan are invisible to achieve: they are only needed "locally" during the construction of the intermediate plan Tl. The additional call on preserves (line 45) is necessary because of variables in the plan. For example, the action move(b, a, W) need not delete the fact clear(c), so preserves lets it through; however, plan may instantiate W as c, and this ought to cause a failure.

If, for any of these reasons, the action U cannot be added at the end of the plan, achieve will try to undo the last action V and insert U earlier into the plan. This is only possible if V does not delete the fact to be added by U. The procedure retrace (lines 65-73) removes from the set of preserved facts all facts that may be established by V but are different from V’s preconditions. Speci¿cally, it removes the facts added by V (lines 68-69) and the facts that constitute the precondition of V (lines 70-7l)—the latter facts will be re-inserted by append (see lines 66, 86-87)‘.

A few comments on the remaining procedures. A fact holds after executing a given plan (lines 52-55), if it is given or added by one of the actions, and preserved by all subsequent actions (if any). Two conjunctions, C and P, are inconsistent (lines 76-78, 93-97) if C&P contains all facts of an impossible combination S. except those which—like noteqaal—are tested "metaphysically" (see line 95). For disjoint C, S this cannot be the case—hence the call on intersect which is relatively cheap. Two object descriptions X and Y, with variables instantiated by numbervars in mkground (line l0l), may refer to the same object if X = Y or X = ‘V’(_) or Y = ‘V‘(_)—see line 99. The procedure elem (lines 89-9|) extracts single facts from a nested conjunction; it can be used both to test membership, and to generate facts.

Now that you have acquainted yourself with the planning program, try it on a richer world. Here is the world of a robot that walks around several rooms, moves some boxes, etc. (see Listing 8.], lines 33-l0l). Figure 8.2 depicts an initial state of this world. There are six points, ¿ve rooms, four doors, three boxes, a light switch, and the robot. Nine types of facts are considered: at(Object, Point). on(Object, Box), nextto(Objectl, Object2), pushable(Object), inroom(Object, Room), locinroom- (Point, Room), connects(Door, Rooml, Room2), status(Lightswitch, OnO¿'), onÀoor—the latter characterizes the robot. Only the robot performs actions—there are seven of them (see lines 64-77).

<!-- page 229 -->
' The special treatment of V's preconditions is necessary for actions which add facts listed among their own preconditions. lf retrace simply deleted V's effects. such preconditions could be lost from the list of facts which must be presented by U, and those parts of the plan which achieve “locally desirable" goals could inadvertently be destroyed in the insertion process.

roornl2l

roeml3l

re-orntl.)

roomltl

lightswiteh ll l

borlll

O

point (L)

oponntttl

boll2)

q

,rr

.

**I**

**' wÀttlt**

**U**

pomll¿l

opomtllll

O

pe|ntl5l

doorltl

dootl2l

dootl3l

dcorlél

room I5)

FIG. 8.2

"STRIPS" world.

The procedure del merits a comment. It is supposed to delete more than it should—we count on add to straighten the situation out. For example, the action tumon(S) removes whatever status of S may be recorded (line 54); “a moment later" it adds the appropriate fact (line 39). The clauses in lines 49-50 say that a moved object X is no longer “next to" anything. However, this does not apply to the robot manipulating a box (lines 46—48)—del fails, i.e. the fact is not deleted.

For sample results, see Listing 8.3, p. 227.

Although WARPLAN is a feat of ingenuity, there is much more to planning than it does account for. For one thing, the plans it generates need not be optimal, i.e. contain the least possible number of actions. For example, action U in achieve (lines 47-49) is executed when it preserves V's precondition P; if we checked that U establishes P, we might delete actions which had been planned to establish it. A much more profound problem: in general, it is likely that conditional or iterative plans will be required, rather than sequential (the robot explores the world).

<!-- page 230 -->
Even with these (and other) limitations, and despite exponential time complexity, WARPLAN is an excellent tool for experiments with rigorous world descriptions. One example is the world of a robot that assembles cars. Warren has also demonstrated how his program can be used to compile arithmetic expressions into machine code (the code is treated as a plan for placing some values in some registers). LISTING 8.1 WARPLAN—Exa|:|plea of worlds.

**%%%%%% WARPLAN-eubewonds**

**op(50, xlx, on).**

**del( UonW, rmva(U, V, W) ).**

```prolog
elear(V)
       meva(U
              V W) ).
          F
```

**el( UonZ, move(**

**el( elear(W), move(**

**.¢<F2 ii**

**( rmva( U, V, Àoor),**

**UonV 8. notequal(V, Àoor) 8. elear(U) ).**

**(move(U, V, W),**

0.0.DD E §

```prolog
elear(W) 8. UonV 8. notequal(U, W) 8. etear(U))
```

-I-l-L.-L-L-L-L

Qmmhu~_,¢,v.0en—~|o>m:~urolr|'poas(XonY8.elear(Y)). l|rpoas()tonY&XonZ8-netequal(Y, 2)). lrrpoas(XonZ&YonZ&netequal(Z,Àoor)&notaqud(X, Y)) lrrpoea( Xonx ).

**%1'hatl1reeblocltsp|'oblem.**

**Àoor**

**glven( start, aon**

). glvant start, bontloor ). glvent start, eona ). olvent start, eteartb) )glven( stall, elear(e) ). 1 8 19 20 21 22 23 24 25 26 27 28 29 :-

**plans(eona 8. a**

:-

**plans(aonb 8. b**

**onb. start ).**

one. Start ). 2-

d0bÀ'Ol')'), rede¿ne. f

%%%%%WARPt.AN-t:l1oSTFllPSproblem I!

```prolog
htoud1(D, Fl1,Fl2) ).
```

EEEEEEEE

**;§§%?ia§**

**as**

**8'F**

.3. .75N

**c**

**.75c**

**5a 5EE**

**.2). U)**

```prolog
                         :-
                            l,
                              lall.
                         I,
                           tall.
                         I,
                           tall.
22
```

***£££**

**l**

no

l( nextto del( nextto del( Ont X. del(

**53?**

**33**

**'.,=:;.~:**

**3. t==.:.**

**gages?gs**

```prolog
                    ::-
                       -....x?"....""‘cc
                        H"
           Bl)
orilcor, eirrbon
               .
```

**del( lnmom(robot,Z), gothroud1(D,Fl1,H2) ).**

**del( atatus(S,Z), tumon(S) ).**

FF? rmved( robot, goto1( movedt robot, goto2( movedt robot, pushto rnovedt X, pus)-tto( X. ¿$c‘i¿$$¿3883$l€il5‘£8lt3‘-'38 4-B 49 50 51 52 53 54 55 56 57 58 59 60

"<33

1-vm"'.""1"

<!-- page 231 -->
Y. rmved( robot, ellmbon(B) ). LISTING 8.1 (Continued)

```prolog
   ed( robot, ellmbotl(B) ).
   edt robot, gothrou¢l(D,Fl1,Fl2) ).
E3
35.
    goto1( P, H ),
  nroom(P,Ft) 8. hroom(robot,Fl) 8. orllloor ).
can( goto2( X, Fl ),
                     8 lnmorn(X,Fl) 8
            "'55%.-1
                 N-< .?_m
lnroorn(X,Fl) 8 lnreom(robot,H) 8 orlloor ).
can( tumon( lights\vltch(S) ).
on(robot.box(1)) 8 na1rtto(box(1), llghtswlteh(S)) ).
can( pushtot X, Y, Fl
pusl1able(X) 8
            I
nexttot robot, X
can( gothroud1( D, Fl
eennaets(D,H1,Fl2) 8- lnmom(robot,Rt) 8
naxtto(robet, D) 8- orllloor ).
can( cllmbol1(box(B) ), on(robot,box(B)) ).
can( elirnbont box(B)), nexttot robot. box(B)) 8- onlloor ).
                       -0I
                   i
                     ii
alwayst lnreom(D,Fl1) )
                   :-
                      alwayst connoets(D, Fl1,Fl2)
alwayst eonnoctst D, H2, H1
                          eonnaets1( D, H1, H2 )
alwayst eonnacts(D,Fl1,Fl2)
                       :-
                          eonnaetstt D,Fl1,Fl2 )
```

**alwayst pushablet box(N)) ).**

**alwayst loelnroom(polr|t(N),roorn(1)) )**

```prolog
                            :-
                              ranget N, 1,5 )
alwayst loelnroom(polnt(6),room(4)) ).
alwaya( lnroom( lightswlteh(1),roorn(1)) ).
iltritsl Àll5o|1l5Wll¢|1(1)-P°lI'll4)) )-
cenneetstt deor(N),room(N),roorn(5) )
                            :-
                              ranget N, 1,4 )
     FF
Ii
ra
L
  A-3-2 _z......
       C:-_: If...L+1,
                 ranget M, L1,N ).
|n'poss( at(X,Y) 8- at(X,Z) 8. notaquaI(Y,Z) ).
glV9r)( strbst, 8I( box(N),polr|t(N))
                        )
                          2-
                             range( N, 1,3 ).
glvent WW1, 8I( robot, po|r|t(5))
                       ).
glven( strbst, lnroom(box(N),roorn(1)) ) :- rangat N,1,3 )
glven( strbst, ontlcor ).
givert( strlpst, statua( Igt1tawlteh(1),olt) ).
glvant strbst, lnroom(robot,roorn(1)) ).
% A tow tests.
 :-
   plane( at( robot, polnt(5) ), etrbsl ).
 :-
   plane( at( robot, polnt(1) ) 8| at( robot, polnt(2) ), strbst ).
 1-
   PllÀÀt Bit robot.P0|rI1t4))- W951 )-
 :-
   plans( statua( I|gl'ltcwltch(1), on ), strbst ).
 :-
   plans( at(robot. polr|t(6) ), etrbst ).
 :-
   pla.na( nextto( box(1), box(2) ) 8|
```

388128339 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 8-8 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110

```prolog
nextto( box(3), box(2) ), strbst ).
                      Z22
```

<!-- page 232 -->
**LISTING 8.2 WARPLAN—Tl|e general planner**

```prolog
%%%%%%
              WAFIPLAN-ASystemtorGenerathgPlam
%%%%%%
           (pnlbhltadwllttrnklrdpemlbsbnolthehnlnr
%%%%%%
                   DavklH.D.Warren)
%%% Ihegenerdplanner.
9;,
    ..__.._._._.__...
:-
  op(200,Ily,&),
              op(100,yhr,:).
% Generate and output a plan.
Plarwt 0. _)
          =-
lnconslstamt C, true ),
                I,
                  write( 'lrrpossble.' ),
                                nl.
Plarwt 0. T)
          =-
plan( C, true, T, T1 ),
               outputt T1 ),
                         I.
Àan“ _I _)
         :'
write( ‘Cannot do thls.' ),
                 nl.
                                   '.' ).
output()ts:X)
           :-
nurrbarvars(Xs:X,1,_),
                 output1(
output(_)
        :-
          wrIo('Nothlngneed
                        rsit#2
output1()ta:X)
           :-
              I,
                outputttlts),
                          output2(X.':').
output1(X)
         :-
            out|:|ut2(X,':').
output2(ltem.Punet)
                :-
                  wrttetltem),
                           wrIe(Punet),
                                     nl
                        umuumumuw-
% Maln planning routhe.
%
    DeÀnllom ol
%
```

**see epeeltb world deserbt**

**si**

**fl**

**plant X80. P.**

U ."‘-I ."‘T2).

I,

eelvet X, P,

```prolog
plan(X,P,T,T1)
             :-
                          '-4 all
           ."1,5‘‘ill:-I-1..5"is.17 _-|.°
```

1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33

```prolog
       eolvlngagoal.
                 always(X).
          aw?
                  holcls(X,T),
                           and(X,P,P1).
                 ...‘X
                 U,P,T,T1).
               xv???
55525?FxxxxsSw¿mmi
         gaaaa
           552::
             j
              in-P
%Metl\odsolael\lev||-|gaqoal-
%
   byextenslon:
  levo(_, U, P,T,T1:U)
                  :-
       U,P),
             ean(U,O),
                      notheonsbterl(C,P),
       T,T1),
              preserves(U,P).
        rtlon:
        U, P, T:V, T1:V)
                    :-
       )t,V),
             retraee(P,V,P1),
          Pt,T,T1),
                  preserved(X,V).
      Ilataetholdslnaglvonstate.
      _:V)
           :-
             acld(X,V).
               holds(X,T),
                         preservecKX,V).
’§*§
E5525
ggisgg
                                      C)
```

$$$iE8‘£‘3’.'S$$-‘5$c‘i¿8$£$$$‘3‘-3138i’ 58 59

**% Prove that an action preserves a tact.**

**preservest U, X80 )**

```prolog
              :-
                 proservod( X, U ),
                             praservest U,
preserveat _, tme ).
```

<!-- page 233 -->
**LISTING 8.2 (Continued)**

**ii§i**

...

**-xv)**

**=- check(pres(X,V)).**

**rrltground( xav 1.**

**not del( x,v).**

**% Fletraclng a goal already achieved.**

retraeet P, V, P2 )

```prolog
             :-
 can( V, C ),
          retraee( P, V. C, P1 ),
                         append( C. P1, P2 ).
retraee( X&P, V, C, P1 )
                 :-
add( Y, V ),
         X --. Y,
               I,
                 reIrace( P, V, C, P1 ).
retraeet X&P, V, C, P1 )
                 :-
eIem( Y, C ),
          X - Y,
                I,
                  retracet P, V, C, P1 ).
retraeet XGP, V, C, X&P1 )
                   :-
                     retraee( P, V, C, P1 ).
retraee( true. _, _, tme ).
```

¿t. lneonsbteney with a goal already achieved.

**lnconsbletit C, P)**

```prolog
              :-
Wlkawuodt CGP I.
             lmtmÀt 8 I.
check( lnterseett C. S ) ),
                  ln'pIled( S, CGP ),
                              I.
% % % Utilities.
%
    .......-
```

8828 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82

8I8l'l')( Y, P],

**XII Y,**

I.

```prolog
                   l.
                      GPIZIOIIK C, P, P1 ).
iiii
   E3
    "J";3-.5
      sf: 55.1),l'._.3%
eIern( X,Y&_)
           :-
             eIern( X,Y).
elern( X,_8|C)
           :-
             I.
               elem( X,C).
elem( X,X).
ln'olled(S1&S2,C)
              :-
                I,
                   h'plIed(S1,C),
                              In'pIled(S2,C)
lrrplIed(X,C)
           :-
             eIem(X,C).
ln'plled( X,_)
          :-
             X.
interseeI(S1,S2)
             :-
               elernt X,S1),
                          elem( X,S2).
notequal( X, Y)
            :-
              not X-Y,
                     notlt-'V'(_),
                               notY-'V'(_).
rrI<ground(X)
           :- run'bervars(X,O,_).
```

89188128 89 90 91 92 93 94 95 96 97 98 99 100 101

<!-- page 234 -->
Z24 LISTING 8.3 WARPLAN—Sam||Ie reldtn

**3?;**

**3?;**

Toy-Prolog Btenlng: ?-‘)t.IiIeswItl'|outIesteasesbut\vIth

end. atthe end :- eonsuttt planner ). consult cubes ). ?- :-planstcona 8. aonb, start). start : move( move( move( 7. :-planstaonb 8. bone, start). start : rmve( move( move( 7. ;delop( ‘on’ ), reconailt strbs ).

:- planst at( robot, polri(5) ), strbst ). Nothlng need be done. 7. 1- 010rBt01t robot. 0051(1) ) 8- Àit r0001. 0010112) ). 8111001 )lnposslble. 7- :- planst aI( robot, poIrn(4) ), strbst ). stripst : goto1(poIr|I(4),room(1)).

).l'00l'l1l5))

).l'00l'l1l4ll

J5

-u-n :- plans( etaIus( ll9|'|tswltch(1), on ), etrbst ). strbst : goto2(box(1),roorn(1)): pt.|sl1to(box(1),ll9htswltch(1),roorrI(1)): elimbont box( 1 ) ) : tumon( llghtswtteht 1 ) ). 7- :- planet at( robot, poIrd(6) ). strbst ). slripst : 90102( d0'0r( 1 ). §2 00Ihr00oh(d00rt 0010210004 4). a0Ihr00oh(d00rt4 0010110010116). r00mtiii

**mt1))=**

**I)-**

N-L~_l

1""-"1""'-P

-a ?- :- plans( nert1o( box(1), box(2) ) 8| next'to( box(3). box(2) ). elrbst ) stripst : goto2( box( 1 ), roorn( pusl'Io( box( 1 ). box( coto2( box( 3 ), room( pusl1to( box( 3 ), box( ?- stop.

<!-- page 235 -->
Toy-Prolog. end ol eesslon.

**BIBLIOGRAPHIC Nores**

**WARPLAN is described in Warren (I974). Our presentation has been**

**greatly inÀuenced by this excellent paper. The program we publish here is**

**a slightly cleaned-up version of the text given in Coelho et al. (I980),**

**where all the mentioned examples of worlds can also be found. The ro-**

**bot's world was introduced by Fikes and Nilsson (I971) as a test case for**

**their system STRIPS; Warren (I974) used it to compare the performance**

**of the two systems. An extension of WARPLAN, intended for generating**

**conditional plans, was described in Warren (I976).**

## 8.2 Prolog and Relational Data Bases

**ln this section, we shall be primarily concemed with data bases in the**

**limited sense: a data base is a purposefully structured collection of stored**

**data, often pertaining to an organisation (e.g. a bank, factory, university,**

**warehouse). ln a relational data base all data are conceptually grouped**

**into relations, which are usually depicted as rectangular tables as in Fig.**

**8.3. A column in the table is called an attribute and referred to by a name,**

**e.g. dno. All values of an attribute belong to a common domain, e.g. each**

**salary belongs to integers. A relation is a set of tuples (table rows) which**

empno

name

dno

salary

rngrno

13

Miller

1500

'

19

-1

.

21

Jones

1000

13

I

35

Brown

1000

21

I

- 38

White

800

1

35

1.3

Smith

1200

1

13

61

Thomas

85-0

21

89

Morgan

1050

35

_a-0-AhJ_a-Q-lo

i

42

Miller

850

35

--

.

.

_

I

dno

name

rngrno

-It

Pubttclilela t ions

21

2

'

1.3

Security

FIG. 8.3

<!-- page 236 -->
Contents of a relational data base. consist of attribute values, e.g.

< 38, White, I, 800, 35 >. Tuples belong to the set described by a relation schema which speci¿es names, domains and order of attributes, e.g.

EMP < integer empno, string name, integer dno,

integer salary, integer mgrno >

DEPT < integer dno, string name, integer mgrno > Two tuples may share the value of an attribute, and thus implicitly fall into one group; for example, Brown and Thomas are both subordinates of a manager whose number is 21.

A relation can be changed by inserting, deleting or updating some of its tuples. These operations are referred to as data manipulation.

,_

A query to the data base is answered by enumerating tuples of the

l

I resulting relation (or by computing an aggregate function, such as ""aver-

1 age" or "total", over these tuples). Most queries are expressible in tenns of the following primitive operations on relations.

**/'""**

—Selection chooses tuples for which a given condition holds; for example, we can select from EMP those employees of department I who cam over 900 (there are three such tuples). —Projection neglects some attributes and (possibly) reorders the remaining ones; for example, we can project EMP over name, empno, and salary, to get

< Miller, I3, I500 > and seven other triples. —Joln of two relations A, B fomis a new relation. It consists of those concatenations of tuples from A with tuples from B, for which a given condition holds. For example, the join of EMP and DEPT, such that department numbers coincide, consists of the tuple

< 2|, Jones, l, I000, I3, I, PubIicRelations, 2l > and six other 8-tuples. —Unconditional join is a product; for EMP and DEPT the product consists of sixteen 8-tuples. —Finally, set operations, namely union, intersection and difference, can be applied to two relations whose corresponding attributes belong to the same domain, i.e. whose schemata differ only in names.

<!-- page 237 -->
Much of this conceptual framework is naturally translated into Prolog. A relation is modelled as a procedure made of unit clauses which correspond to tuples, for example:

'EMP’( I3, ‘Miller’, 0, I500, I9 ).

'EMP'( 2], ‘Jones’, I, I000, I3 ).

```prolog
etc.
```

(we use quotes to prevent capitalized names from being treated as variables). To change a relation, we use the built-in procedures assert and NZIFGCI.

Primitive operations on relations are expressed in terms of procedure calls. For example, the procedure

```prolog
s( Empno, Name, Dno, Salary, Mgmo) :-
    ’EMP‘( Empno, Name, Dno, Salary, Mgmo ),
    Dno = I, Salary > 900.
```

can be used to generate all tuples for employees of department I who earn over 900 (i.e. to implement selection):

```prolog
:- s( E, N, D, S, M), write( ( E, N, D, S, M ) ), nl, fail.
```

Better still, we can substitute I for Dno and remove the test:

```prolog
s( E, N, I, S, M) :- ‘EMP’( E, N, l, S, M), S > 900.
```

The procedure p can be used to implement projection:

```prolog
p( Name, Empno, Salary ) :-
    ‘EMP’( Empno, Name, _, Salary, _ ).
```

The composition of these two operations can be expressed in Prolog quite succintly:

```prolog
s_then_p( Name, Empno, Salary ) :-
    ’EMP'( Empno, Name, I, Salary. _ ). Salary > 900.
```

Or we can put this directly into a query:

```prolog
:- ’EMP'( E
                    _
  write( ( N
            $0.2 <0:-' jIIs'=
                     -'1-... Qua="'v §
```

Finally, here is the join of EMP and DEPT over coinciding department numbers:

j( Empno, NameE, DnoE, Salary, MgmoE, DnoE, NameD,

```prolog
MgmoD ) :-
    ’EMP'( Empno, NameE, DnoE, Salary, MgmoE ),
    ’DEPT'( DnoE, NameD, MgrnoD ).
```

<!-- page 238 -->
All these operations are neatly explained in tenns of static interpretation of procedures (try for yourselfl). Set operations are even more straightforward. Let a(X| ,

X,,) and b(X| ,

X,,) denote generators of tuples, such as ’DEPT’( D, N, M ) or p( N, E, S ). We have

```prolog
aUNIONb( X1, ..., X“) :-
    a( X), ..., X" )
                  1
                      X|
aINTERSECTIONb( X|,
                           .2
                             3*-~.?<
    a( X1, ..., X“ ) , b( X|,
aDIFFERENCEb( X|, ..., X,,) :-
    a( X|, ..., X,, ) , not b( X1,
                                X,, ).
```

Queries which involve only primitive operations can be answered without actually creating the resulting relation. Its tuples can be generated by a failure-driven loop and displayed immediately. To compute an aggregate function, however, we need the whole attribute (column) at once. We can construct it by means of the procedure bagof (see Section 4.2.4); for example:

```prolog
:- bagof( Salary, ’EMP‘( _, _ , _, Salary, _ ), Salaries ),
  max_of( Salaries, MaxSaI ), write( MaxSaI ), nl.
```

Sometimes we can also use bagof for ef¿ciency. For example, we look for employees of department I who earn no more than a I000 and who are FTU members since at least I980:

```prolog
:- ’EMP’( E, N, I, S, _ ), S =< I000,
  ‘FTU’( E, _, _, Dateloined ), Dateloined =< I980,
  write( ( E, N ) ), nl, fail.
```

With those implementations of Prolog which do not support clause indexing, the entire relation FTU would be scanned many times. Instead, we can precompute the necessary set: :- bagof( Empno, ( ’FTU’( Empno, _, _, Dateloined ),

Dateloined =< I980 ), FTUMembers ),

’EMP‘( E, N, I, S, _ ). S =< I000.

member( E, FTUMembers ), write( ( E, N ) ), nl, fail.

<!-- page 239 -->
There are queries which cannot be expressed as a composition of selections, projections, joins and aggregate functions. A classical example: ¿nd every employee who eams more than at least one of herlhis superiors. The relation “is a superior of" is inherently transitive, but we can only express the relations “is an immediate manager of “is an immediate manager of an immediate manager of" etc. In Prolog, however, the problem is easily solved. For example, we can de¿ne a procedure to generate managers’ salaries:

```prolog
mgr_sal( Mgmo, Salary ) :- ’EMP‘( Mgmo, _ , _, Salary, _ ).
mgr_ sal( Mgmo, Salary ) :-
    ’EMP'( Mgmo, _, _, _ , MgrMgrno ),
    mgr_ sal( MgrMgmo, Salary ).
```

(try to rewrite it so as to avoid the repeated pass through EMP). From the standpoint ofthe caller, this generator is indistinguishable from those made of unit clauses. The query can be written as follows:

```prolog
:- ‘EMP'( Empno, _, _ , Salary, Mgrno ),
  once( ( mgr_sal( Mgmo, MgrSal ), MgrSal < Salary ) ),
  write( Empno ), nl, fail.
```

**A relation which is computed rather than stored (e.g. s, p, s_then_p, j**

above) is called a view in the relational data base terminology. A view results from primitive operations on stored relations—also indirectly, via other views-and it changes as those relations change (and conversely, a change in a view might inÀuence those relations—but this poses quite nontrivial problems). The relation mgr_sal, however, can only be obtained by embedding primitive operations in a host programming language, fumished with recursion or iteration. An important advantage of Prolog is its ability to express tuples, views, and special programs in the same language. In particular, it offers a possibility of enforcing integrity constralnts—application-speci¿c conditions of the coherence of data. Constraints should be tested prior to any change to a relation. For example, we can use this procedure to insert only correct tuples:

```prolog
insert( Tuple ) :-
    correct_insert( Tuple ), !, assertz( Tuple ).
insert( Tuple ) :- signal_violation( Tuple ).
correct_insert( ‘EMP’( E, _, D, _, M ) ) :-
```

!, E=\= M, ‘DEPT’( D, _, _ ). % there is such a dept

```prolog
correct_insert( _ ).
                                 % others are OK
```

<!-- page 240 -->
On the whole, Prolog is a powerful tool for data base applications. Admittedly, there is more to data base systems than our presentation suggests. For one thing, the size of a real data base may far exceed the capacity of any existing Prolog implementation. The model described in Chapter 6 ought to be augmented: clauses would be stored on disk and handled by standard or specialized access methods. Second, every practical data base implementation should address problems such as concurrent execution of users’ commands, recovery after hardware failures, etc., etc. There are no ready solutions in Prolog but presumably they can be programmed into it.

Surprisingly, Prolog is, in a sense, too strong, too unrestricted. For example, to ensure the conformance of a tuple with the relation schema, some form of type checking is required, presumably as explicit tests. Unrestrained use of assert/retract may also ruin the integrity of a data base in other ways. Consequently, Prolog should rather be considered a tool for implementing more restricted user interfaces: queries and commands in a user language are analysed (types checked, integrity ensured, etc.), and only then translated into Prolog.

A particularly attractive option would be to query the data base in a natural language. Several encouraging small experiments have been carried out. At the moment, though, this is much more a research problem in its own right than a generally available programming technique.

Relational data languages, notably Sequel and Query-by-Example, provide syntactic sugar for relation schema de¿nitions, data manipulation and queries (involving Boolean expressions and compositions of primitive relational operations). In contrast with natural language interfaces, a Prolog implementation of a relational data language is a programming task of moderate complexity.

We shall now present Toy-Sequel, a relational data language pattemed after Sequel and implemented in Prolog (see Listing 8.4). With the exception of aggregate functions, expressions in tuple speci¿cations and some exotic features, it supports all that is essential in Sequel. Extensions are relatively easy to introduce (we left them out to make the program shorter). To give the Àavour of the language, here is an annotated conversation with our program, initiated by the call

```prolog
:- toysequel.
```

To begin with, we specify a few relation schemas:

create EMP < string name, integer salary, integer dno >.

create DEPT < integer dno, string manager >.

create BoardMembers < string name, string position,

integer seniority >.

Now we insert some tuples:

into EMP insert < "Brown", I000, I >, < "White". 800, l >.

< "Miller", 850, I >, < "Barry", 900, 2 >.

< "Thomas", 850, I >, < "Morgan". I050, I >.

<!-- page 241 -->
into DEPT insert < I, "Jones" >, < 2, "Smith" >.

We can ask what relations the data base contains; Toy-Sequel displays their names (its responses are italicized):

```prolog
relations.
B0ardMembers
DEPT
EMP
```

What is the schema of EMP?

relation EMP.

string name

integer salary

integer dno

A select expression determines a set of tuples. They may be displayed. For example, who in departments other than 2 earns at least I000?

select from EMP tuples < name, salary >

where dno < > 2 and salary >= I000.

Brown l0OO

Morgan I050 Or they may be inserted elsewhere:

into EMP insert

select from DEPT tuples < manager, I000, dno >. In the absence of “where

the condition is taken as true.

Both managers have the salary I000. We can given Smith a raise:

update EMP so that salary = I200 where name = "Smith".

Fire Barry:

from EMP delete tuples where name = "Barry".

If several relations are involved. e.g. in ajoin, attribute names may be ambiguous. To disambiguate, qualify them with relation names. For example:

select from EMP, DEPT tuples < name, EMP_dno, manager >-

where EMP_dno = DEPT_dno. (Actually, EM P_dno may be replaced with dno: an unquali¿ed attribute name is quali¿ed with the leftmost appropriate relation name.)

<!-- page 242 -->
A relation may be accessed in several places at once. For example, to compare salaries of different employees we need the product of EMP by EM P. We must give one of the occurrences an alias name and so allow unambiguous references to attribute values. The following query joins the relations EMP, DEPT and EMP alias Mgr, to ¿nd employees who eam more than their (immediate) manager:

select from EMP, DEPT, Mgr = EMP tuples < EMP_name >-

where EMP_dno = DEPT_dno

and DEPT_manager = Mgr_name

and Mgr_salary < EMP_salary.

Morgan Again, the quali¿cation with EMP is superÀuous, as well as the quali¿cation of manager.

A similar condition can be used to give a raise of half the difference in salaries to those who eam over I00 less than their manager:

update EMP using DEPT, Mgr = EMP

**so that salary = EMP_ salary+ ( Mgr_saIary - EMP_salary)/2**

where EMP_dno = DEPT_dno

and manager = Mgr_name

and Mgr_salary > EMP_ salary + I00.

Two miscellaneous queries. Find employees whose names do not begin with M:

select from EMP tuples < name >

J_

where name < "M" or name > =

l (¿ve of them). And ¿nd EMP tuples with a nonexistent department number-this is a kind of (manual...) integrity checking:

select from EMP tuples < name. salary, dno > where

not < dno > in select from DEPT tuples < dno >. in denotes set membership. The name dno in the nested select expression pertains to DEPT.

Time to ¿nish. The relation BoardMembers will not be necessary. after all:

cancel BoardMembers. Store the data base in a ¿le:

dump to AAA. (next time we shall begin with

<!-- page 243 -->
load from AAA. and resume at this point). Finally, retum control to Prolog:

```prolog
stop.
```

We shall not go into details of the Toy-Sequel interpreter. The rationale for its design was given above; the program is (almost) self-documenting. The following remarks account for a few central technical decisions.

The main procedure, toysequel (lines 4-7 in the listing), repeatedly reads and executes commands. The procedure getcommand (lines 9-I I) retums a Prolog goal, which is the translation of a command, and a Àag. The Àag remains uninstantiated if the command is correct, otherwise it is instantiated as error. The procedure docommand (lines I3-I4) executes a correct command's translation, and does nothing in the case of errors.

A command is processed in three phases. The text, terminated with a dot, is read in (lines 32-43) and then passed through a scanner, implemented as a metamorphosis grammar (lines 45-84). It classi¿es tokens as names, strings, integers and single non-alphanumeric characters. A list of tokens goes to the command compiler—-a metamorphosis grammar which is the core of the interpreter. The grammar consists of ll parts, one for each Toy-Sequel command (see lines I13-I23).

All commands, except load and stop, manipulate the relation catalogue. The catalogue is implemented as a three-parameter procedure ‘r e I’, with a unit clause for each relation schema. A schema stores the name of a relation, a generator of this relation's tuples and a "frame" of symbol table entries linking attribute names and types to variables in the generator (see lines l3I-I41). For example, the command

create EMP< string name, integer salary, integer dno >. adds the clause

‘r e l‘( ‘EMP’, ' EMP‘( Name, Salary, Dno ),

[ attr( name, string, Name ), attr( salary, integer, Salary ),

```prolog
attr( dno, integer, Dno ) ] ).
```

Blanks are added to relation names in generators to make conÀicts with other procedures less plausible.

The command processors for select, insert, delete and update maintain a symbol table—a stack of frames taken from the catalogue. For example, attribute names in the command

select from EMP, Mgr = EMP, DEPT

tuples < name, Mgr_dno, manager >

where dno = DEPT_dno and manager = Mgr_name

<!-- page 244 -->
and salary > Mgr_saIary. will be looked for in the following symbol table (see lines 208-223, and 96-I02):

[ ‘EMP’ : [ attr( name, string, NameEMP ),

```prolog
          attr( salary, integer, SalaryEMP ),
          attr( dno, integer, DnoEMP ) ],
’Mgr’ : [ attr( name, string, NarneMgr ),
        attr( salary, integer, SalaryMgr ),
        attr( dno, integer, DnoMgr ) ],
‘DEPT’ : [ attr( dno, integer, DnoDEPT ),
          attr( manager, string, ManagerDEPT ) ] ]
```

(Nested select expressions would push their own frames onto this stacksee line 277.)

The product of these three relations will be generated by the following calls retrieved from the catalogue:

‘ EMP‘( NameEMP, SalaryEMP, DnoEMP ),

‘ EMP'( NarneMgr, SalaryMgr, DnoMgr ),

’ DEPT'( DnoDEPT, ManagerDEPT ) The condition will be translated into a Prolog goal (see lines 236-237, 239- 362). The goal will be executed immediately after the generators (lines I66-I68). Attribute names in the condition will be translated into variables from the symbol table. Thus,

salary > Mgr_salary will become

SalaryEMP > SalaryMg:r The "equalities"

DnoEMP = DnoDEPT, ManagerDEPT = NameMg:r will be processed at compile time, by binding variables together (line 318), so that actually only six different variables will occur in the generators.

The tuple pattem (lines 225-234) will also contain variables from the symbol table:

[ NameEMP, DnoMgr, ManagerDEPT ] One such tuple will be displayed in every step of the failure-driven loop (lines I66-I68).

<!-- page 245 -->
A construction that would certainly bene¿t from a more detailed explanation is update. We shall comment on the example shown in the listing (lines 396-411):

update EMP using DEPT, Mgr = EMP

so that salary = salary + ( Mgr_salary — salary ) / 5

where salary < Mgr_salary — I000 and Mgr_name = manager

and DEPT_dno = dno and not< Mgr_name > in

select from BoardMembers tuples < name >. First, two copies of the stack frame are created, and two call pattems (OldTup and NewTup):

' EMP‘( Name, Salary, Dno )

' EMP‘( NewName, NewSalary, NewDno ) Now. makemodlist creates a raw modi¿cation list:

[ modif( attr( name, string, Name ), NewName, ModName ),

```prolog
modif( attr( salary, integer, Salary ). NewSalary, ModSalary ),
modif( attr( dno, integer, Dno ). NewDno, ModDno ) ]
```

A symbol table is constructed, ¿rst a frame for EMP (note that old attribute values will be retrieved and used), next for DEPT and EMP (with the alias name Mgr). During the construction of Modi¿cations (lines 420-421, 410), the raw list is changed by ¿ndmname (lines 454-465, 434): ModSalary is instantiated as true (line 462) to note that the salary will be modi- ¿ed. Finally, closemodlist (lines 447-452, 422) binds together variables that stand for unmodi¿ed attributes, i.e. Name with NewName and Dno with NewDno. Also, equalities in lines 398-399 cause two other pairs of variables to be bound together (see line 318).

A comment on error treatment. Incorrect data do not terminate processing. Instead, the procedure ancestor instantiates the variable ErrÀag (lines 5, 484, 488)—this prevents the command from being executed (lines 13-14), but the analysis continues. The grammar rules synerrc (lines 486- 498) display the troublesome token and the others to its right, and then succeed leaving the token list intact.

In actual use, Toy-Sequel would probably be found too simple. However, many extensions are quite straightforward. As an exercise, try to augment Toy-Sequel with de¿ned views, e.g.

view EMP1 < name. salary > as

select from EMP tuples < name, salary > where dno = 1. Another extension: “wild card" tuple speci¿cations, e.g.

select from EMP tuples *.

<!-- page 246 -->
( i.e. tuples < name, salary, dno > )

select from EMP, DEPT tuples < EMP_*, manager >-

where EMP..dno = DEPT_dno.

(i.e. tuples < name, salary, EMP_dno, manager > ). And aggregate functions, e.g.

select from EMP average of < salary >.

An example of less straightforward modi¿cations is query optimisation. Consider the command:

select from EMP, DEPT tuples < name, salary >

where dno = DEPT_dno and manager = "Jones". The answer will be generated by the calls

‘ EMP'( Name, Salary, Dno ), ' DEPT‘( Dno, "Jones" ) which access every EMP tuple, even though only one department is involved. The same set of tuples would be generated by the calls

' DEPT'( Dno, "Jones" ), ‘ EMP‘( Name, Salary, Dno ) but now other departments‘ tuples would never be retrieved. This optimisation could speed things up considerably for Prolog implementations with clause indexing.

Bratrooaxm-11c NOTES

The bibliography on data bases is enormous. We shall only name a few positions relevant to our presentation which (of necessity) has only touched on basic facts. Two widely accepted introductory textbooks on data bases in general are Ullman (1982) and Date (1982). The relational model of data was introduced by Codd (1970) and further elaborated by many, including Codd himself (1979). The most popular relational data languages are probably Quel, used in the data base system INGRES (Stonebraker et al. I976), Sequel, created for the system R (Astrahan I976; Chamberlin et al. 1976) and Query-by-Example (Zloof I977).

<!-- page 247 -->
In the proceedings of conferences on logic in data bases (Gallaire and Minker I978, Gallaire et al. I981) there are, in particular, papers on the role of logic programming in data base theory and applications. The advantages of Prolog (and logic programming at large) for data bases have been advocated by quite a few authors, e.g. Kowalski (1978), Gallaire (I983) and Lloyd (I982). A practical demonstration of Prolog's power is Chat80 (Warren and Pereira 1982; Warren 1981), a system with a natural language interface. Queries in English are translated into Prolog calls; they are similar to those produced by Toy-Sequel, but Chat80 performs some query optimisation. Several other data base applications with natural language interface are described in Dahl (1977), Coelho (I982), and Filgueiras and Pereira (1983).

Another example of data base application of Prolog is an implementation of Query-by-Example (Neves and Williams 1983; Neves et al. I983). Chomicki and Grudziriski (1983) describe a system, based on extendible hashing, that manipulates tuples stored on disk. The system has been designed to support data-base-oriented implementations of Prolog.

<!-- page 248 -->
The Toy-Sequel interpreter was rewritten as a sized-down version of SPOQUEL, a program which we had written with Wlodek Grudziriski in early I982. It helped us through a dif¿cult winter. LISTING 8.4 Toy—SeqneI lIIer|I'eter

**Toy-Sequel herpreter**

- - - - - -

**c) COPYRIGHT 1933 - Feirs I(lrz1ii1.StanlslawSzpaIrowi:z**

**giliii**

**Instlute ol Irlorrnatlee, Warsaw Unlverely**

```prolog
 el :-
     wrle( '- Toy-Sequel, IIUW Warszawa 1983 -' ), nl,
109001. 11111011’). 1001 0010001001111 C1110. 5111100) l.
           tag( docorrmar:I( Cmd, ErrÀag ) ),
Cmd - eequehtop,
             1.
```

**geteomrnartrl Cmd, ErrÀag)**

```prolog
                   :-
readcmd( CmdStrlno ).
aean( Cmdstrhg, TLBI ), oor1ple( TLlst, Cmd ).
do-eomrnar|:l(Cmd,Errt1ag) :- var( ErrÀag), I, Cmd.
do-eomrnan:l(_,_).
sean( CntlStri1g,TLlst) :-
ph1ase( tokenet TLlst ), CrndStrlng ), traeeaean( TLIst ).
o:>rnp1le(TL1st,Cmd) :-
phrase(eo1'r|rnar|1:l(Crr\d),TLIst),l,traeeco|'rpb(C>rr1d).
corrp1le(_,error) :- synerr(badeommu1d).
traeesean(Cmd):- traeesean, I, wrle('--aear'rned'(Cmd)), nl.
traeesean(_).
              write( '—con1:>led'( CI'rI:l)), ri.
   traoeconpl
traceeorrpIe(_
traces-can.
            traoecorrplle.
% - - - - --readerandamnner - - - - --
%FleaderstopsontheÀrudoto1.rtsldestr1ngs.
readernr:I(S1rhg)
            :- rdehsk( Ch), readcmd( Ch, String).
readernd(
        []) :- I, rch.
readerndt "", [" I Flestl) :-
I, rdcht Ch ), readstrt Ch, Fleet, Flest¿llter ),
rdcht Nexteh ), readcmdt Nerrteh, Rest¿tlter ).
readem:I( Ch, [Ch | Ftestl) :- rdeht Nexteh ), readcmd( Nertch, Rest )
rea&tr( "", [" | Fleet], Rest) :- I.
rea&tr( Ch, [Ch | Fleet], FlestAlter) :-
rdcht Nextoh ), readstrt Nerrteh, Rest, Rest¿tlter ).
```

**% This scanner recognizes names, strings, lriegere, and slngle**

```prolog
%eI-raraetere.Strlr1gsareretumedasI1steoIeI-raraeterrr.
‘It. The tokens are: n(Name), e(Strhg), ltlrieger), Aslngleoharaeter.
tol-tenet [T | Ts])
            ->
               tokent T),
                       I, sp, tokenst Ts ).
Iokemt I] I ->
           11-
Iolten(n(Narne))
             ->
leÀertl-). nam00hntNN). IPMI00tName.l1-IN1~l1)}-
I0l100t0t$Irh0))
             —> 1"'l. 01rh00h0I0t$I1'lI'o)-
I0l100tltl"l000r))
             —>
0101118). 0101110). =00lstDD).
trmm0lt1.10lDD1). 0l0n0dt$.l.lrIle00r)}-
tol-can( Ch)
         ->
            [Ch].
```

;;:3@@~@maw- 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 3-3 34 35 36 37 38 39 40 41 42 43 44 45 48 47 48 49 50 51 52 53 54 55 58 57 58 59

**letter( Ch) -> [Ch], { letter( Ch) }.**

<!-- page 249 -->
Z39 LISTING 8.4 (Continued)

```prolog
namechss([Ch|Chs]) -> letter( Ch ), I, nameeha1s(Chs).
namechars(hCh|Cha]) --> dblt( Ch ),
                          I, nameehatst Chs).
         )->
              .
%'"'1nastrlngstandsIcraslngIe"'
```

% (reademd treats "..."...' as two adjacent strlngs).

```prolog
str1ngeha1s( 1"‘ | Chs] )
                --> [", “'1, I, etr1ngehars( Chs ).
strIngehars( I] ) -> ["'], I.
strlngcharst [Ch | Chs] ) --> [Ch], strIngehars( Chs ).
d1glt(Ch) -> [en], {db1t(Ch) 1.
             -‘I
       II1'r1'.rV
           m-:""*-+.L-.
d1011=110l0D1)
            -->
               01111110). 1.0101101001-
dleltstlll
       -->
           11-
am 1-
01001 '+')
010111‘-I-')
```

38833-283288228 71 72 73 74 75 76 77 78 79 80

slgnedt '+', I, I ).

slgnedt

I, Integer)

```prolog
               :-
                 Integer Is - I.
  -> [' '1,
        1, sp.
                    %opt1onalspaeee
  -> [].
 -8-8
% These are used Ior attrbutee.
qnarne( Qual-Name) -> [n( Oual ), '_', n( Name )],
                                  1.
qnarne( Varlmle-Name ) -> [n( Name )].
                             ‘It. Ie Ills all qualllers
```

323E882 87 88 89 90

**constant( Int, Integer) -> [1(l1'ill.**

1.

**ccnstar|t(Str, strhg**

**1 -> [s(Str)].**

all

syn-bot table operations - - - - - -

```prolog
:- op(100,xlx , ':').
```

‘It. Glven a relatlon name and an atlas (cl select expression, procedure

% relname), use the reletlon's schema to push a new set ct Items onto

% sy11'l:1o1 table stadt and Io retum the generdor. The Icrrnat

‘It. ct a schema ls described wlth create (prceechrre newrel).

```prolog
newrelname( Re1Nm,A11as, Generator, O1dST, [Al1as:Fle1ST I OIdST) ) :-
   'r e I'( Fle1Nm, Generator, He1ST ), I.
newre1name( Fte1Nm, _, Ialt, OldST, OIdST) :- synerr(nore1name(FlelNn-1))
```

‘It. Glven a quali¿ed name, return Its associated varlable and type.

tlndattrt Q-Nm, Var, Type, [Q : FleIST | S1‘) )

```prolog
                             :-
   rnerrb-er( attr( Nm, Type, Var ), Rel-ST ),
                              I.
f1ndattr( QNm, Var, Type, [_|S1')) :- I, Àndattr(QNm, Var, Type, ST).
tlndattrt QNm, __, _, |])
               :- synerrt ncattri:1ute( 0Nm ) ).
```

83882833 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119

```prolog
% - - - - - - command corrpller - - - - - -
%Seethevar1ouscom1nar1dsIorexarrpIesoluse.Cornmar1d
```

% Interpretation routines Bted alonwlde corrrnand gramnar processors.

```prolog
cornrnand( Cmd ) --> create( Cmd ).
ccrnrnand( Cmd) -> cancel( Cmd).
command( C
            -> se1eet( Cmd ).
command(
            -> relat1orn( Cmd ).
corn-narr.I(
               relation( Cmd ).
corn-narr.I(
            -> hsert( Cmd ).
corn-narr.I(
               deIete( Cmd ).
       OOOO
        E5353
```

<!-- page 250 -->
LISTING 8.4 (Continued)

120

command(C

-> updaIe( Cmd). 121

ccmmand(C

```prolog
stop(Cmd).
```

122

ccnI'nan:l(C

-> cirrrp( Cmd). 123

ccrnrnand(C

**-> load(Cmd).**

124

**E333**

125 %---createanewrelatlcn-~ 126

```prolog
% Eg: create EMP < strhg name, lrneger salary, Irieger dno >.
```

127

‘)1. Eg: create DEPT<Integer dnc,str1ng manager>. 128

‘It. Eg: create Boardlvlerrberscstrlng narne, strhg pos, Integer senlority> 120

% Note that lcwertupper case matters. Keywords trust be 130

% In lower ease,othe1wIse use any ccnventlon you lire. 131

create( newreI( RelNarne, [V I Vs], [attr(Nm, Type, V) | As] ) ) --> 132

[n( create ), n( Fte1Name )], 133

['<’], typnam( Type, Nm ), typnarnst Vs, As ), [‘>']. 134 135 typnarrIstlVlV0l-l00rtN"I.Tv00.V)l00l) -> 136

[','], I, typnam(Type, Nm), typnan's(Vs,As). :3; Iv1=>narmtl1.Il) --> 1]-

139

```prolog
typnam(strhg, Nm)
              -> [n( strlng), n( Nm )],
                               I.
```

140

typnarn( Integer, Nm) --> [n( heger ), n( Nm )],

1. 141

```prolog
typnam( nctype, Nm)
               -> synerrct Iypeexpected ).
```

142 143

‘It. A schema stores a pattem lor Involthg the relatIon's tuples (the 144

‘)t.generdor).ar1dallstolsyn'l:oltd:leent11es1i'lrhgattrbute 145

```prolog
%na1'r|esanrltypeswlthvar1d:leshthegeneruor.
```

146

```prolog
newreI( ReINarne, Vars, Rel-ST)
                     :-
```

147

not 'r e I'( FlelName, _, _ ),

1. 143

```prolog
rnlrgen( Fle1Name, Vars. Generator ),
```

149

```prolog
assen( 'r e I'( RelName, Generator, Flel-ST ) ).
```

150

```prolog
newreI( FlelName, _, _)
                :- narnerr( ci.preharne( FIe1Narne ) ).
```

151 152

```prolog
%Addab1ankIcr(rudI111e1'lary) security.
```

153

```prolog
11-Itgen( RelName, Vars, Generator) :-
```

154

```prolog
pname( ReIName , Chars ), pname( FtelÀm, [' ' | Chars] ).
Generator -.. [HelNm|Vars].
```

155 156 157 %---canceIarelat1cn--- 156

‘It. Eg: cancel EMP. 159

caneel( canceI( Relllame) ) --> [n( cancel), n( ReIName )]. 160 161

```prolog
caneeI( Fte1Name )
             :- retract( ‘r e I'( Fte1Name, Generator, _ ) ),
                                         I,
```

162

**retract( Generator), lal.**

163

```prolog
caneel( ReIName)
             :- namerrt urltncwnt FtelName) ).
```

164 165

```prolog
% - - - queries - - -
‘)t.Ll1sttheeetgenerdedbyaseIeeIexpreaslon.
se1ect( (Generators, Flter, wrleIuple( Tup ), tall
                                 ->
   se1ectexp( set( Generators, Filer, Tup, _ ),
                               =11-an
                                .,_'\u-I.
wr110100IetIVIV0I)=-wrltV).w1tt0t' ').wrII0t0p101Vs)-
wr1t1XlY1)
         =- I. wr11e1exttIXIY1)-
wrI(X) :- write()t).
```

166 167 166 169 170 w1‘lletuple(|]) :-

1, nl. 171 172 17:3 174 175 1

```prolog
% Llst al relatlorn. Eg: relations.
```

76

**relatlore( (‘re I'( FtelNm, _, _), wrle( FlelNm), nI,Ia1l)) ->**

177

[n( relatlorn )]. 176

```prolog
% Llst the attrtbutesol a relatlon. Eg: relation EMP.
```

179

```prolog
relation( relation( Name ))
                  ->
                     [n( relation ), n( Name )].
                           Z41
```

<!-- page 251 -->
LISTING 8.4 (Continued)

160 161

```prolog
relation( Ftelll) :- ‘re I'( FtelN,_, Altrs ), I, l1stattrs( Altrs ).
```

162

```prolog
relatlont RelN) :- wrIe( Relll ), wrIe(' B not a relatlonr ), nl.
```

163 184

```prolog
ll6lall1s( I] )
        :-
          1.
```

165

```prolog
l1slatt1s(|attr( Narne,Type,_)|Attrs])
                          :-
```

166

wrl1e( Type ), wrlte(' '), wrle( Name ), nl, 167

1lstat:trs( Attrs ). 166 169

‘ll.---selectexpresslon-H 190

```prolog
% Eg: select Irom EMP, Mgr-EMP, DEPT tuples < name, dno >
```

191

```prolog
%
       where salary > l1lgr_aalary‘65!100
```

192

```prolog
%
        and Mgr_name - manager and DEPT_dno - EMP_dno
```

193

‘)6

and < manager > h (<'SmlIh'>, <'Jones">, <'Brown'>) . 194

```prolog
%(legelname=sanddepartrnerl nrrntlersollltosesrrbordhatesclsmith.
```

195

```prolog
%JonesorBrownwhoeamnnrethan65%oltl1elrmar1.ager'ssaIary).
```

196 197

‘ll. Generators plclr up tuples Irom named relatlom, Flters pass only 196

‘lbtuplesllthgtltewhere-darse,Tq:>leBhstar|tlatedlothepassed 199

% tuples (one by one), Types B the tuple's pattem wlh types Instead 200

```prolog
%ol attrbutes (usedlortypechecltlng).
```

201

% The exarrple oonplles to : 202

```prolog
%
   set((' EMP'(Name. Salary, Dno), ' EMP'(MgrName, MgrSala1y, MgrDno)
```

203

‘ll.

' DEPT‘(Dr1c, l1lgrName)

), 204

‘ll.

(Salary > MgrSalary°65I100, tme, true. 205

```prolog
%
         (rneni:ler(MgrNarne, <'Srnith', '..lones', 'Brown">), true)),
```

206

```prolog
%
      [Name,Dr1o],
                [strlng,lnteger]
                            )
```

207 206

selectexpt set( Generators, Fllter, Tuple, Types ), InitST ) --> 209

[n( select ), n(l1'oI1'|)], relnames( Generators, lnltST, ST), 210

[n( tuples )]. tuplepdtern( Tuple, Types, ST ), 211

whereelarset Fllter, ST ). 212 213

‘ll. One or more relation names, possbly 'allased'. Syntlol table trag- 214

‘It. meris are stadted In reverse order, so attrbute search orderwlll 215

% be that or the Irom-Bl (uslng-H lot update) relatlom. 216

reInarnes( ( Gen, Gens ), OldST, NewST ) --> 217

```prolog
relname( Name, Alas ), |','], I, relnames( Gene, OldST, TempST ),
```

216

{ newrelnarnet Name, Alas, Gen, TernpST, NewST ) }. 219

relnamest Gen, OldST, NewST ) -> relname( Name, Alas ). 220

{ newrelnamet Name, Alias, Gen, OldST, NewST) }. 221 222

relnarnet Name,Allas)--> [n( Alias). '-'. I'll Name)],

1. 223

relnamel Name, Name) --> [n( Name )]. 224 225

‘ll. luplepdtem B also Invoked by lnexp. 226 Ivnlemlteml IA I A01. 1'11 Tel. ST I --> 227

[‘<'], atlrpatt( A, T, ST ), attrpaIts( As, Ts, ST), ['>']. 220 229

**eÀrpattst 141401.111**

--> zao 201

.-1.3rpm -I-I

T

[','],

I, attrpatt(A,

```prolog
                     atlrpatts( As, Ts, ST ).
01110011011]-1]-_) —> 1]-
```

232 233

```prolog
atIrpatt(Attrl:ute,Type,_) --> corBtar1t(Altrbute,Type),
                                       1.
```

234

```prolog
altrpatt(A,T,ST) -> qname(ON), {llnda1tr(ON,A,T,ST)).
```

235 236

**whereelarset Fller, ST) -> [n(where)], I, boolexpt Fllter, ST).**

237

whereelarse(true,_) --> []. 236 239

<!-- page 252 -->
‘ll.---Booleanexpresslons-~ LISTING 8.4 (Continued)

**I11!“ 1'11? -2FV3**

Iv 240

**‘)0 Eg: salary > Mgr_aalary ' 851100**

241

```prolog
%
    or <name> h select from Boarttlllllerrbers tuples <narne>
```

242

% Note that embedded select expressions do not rnodlly the symbol table 243

%whose errtenslone arevlsbleonlyhtheneaed constructs.

boolexpt E, ST) -> bterm( T, ST), rboole:p(T, E, ST). 244 245 246

rboolexpl

-> [n(or)], I, boolexptÀ, ST). 247

rboolexp( 246

```prolog
bterm( T, ST) -> bIactor( F, ST ). Ibterrnl F, T, ST).
rbterm(
               -> [n( and )], I, bterm( Fl, ST).
Ibterrnl
               .
     fl!-
        ."l'l=
                              2.“-tn
                        :-!-|-Cg
```

249 250 251 252 253 254

blaclort not F,

- T).

blaclor( E, S

- blaclor( E, S

--

blar:tor( E, S

-I-I-I

- -:..:.""'rsgssv

="

**xi";-R-"--;In!"333%;**

255 256 257 258 259 260 261 262

```prolog
%---setmeni:lershb---
%Eg: <dno,name>ln<1,'Jones' >,<2,'SrnIl'l'>
‘)1. Eg: < name > In (select Irom Boardlrlenbers tuples <name>)
lnexp( ( Generator, Fller ), ST) ->
```

263

tuplepattem( Patt, Type, ST), [n( In )], 264

setexpl eet( Generator, Fler, Tuple, Types ), ST ), 265

matcl'patterns( Palt, Type, Tuple, Types ). 266 267

```prolog
%matclpatten'BBarule,aothatsynenccanshowconten.
```

266

rnatchpaltemsl Patt, Types, Patt, Types) -> I. 269

rnatchpatlernsl P1, T1, P2, T2 ) --> 270

```prolog
synenc( badlnexppatternl T1, P1, T2, P2 ) ).
```

271 272 %---setexpresslom-~ 273

‘ll. A sequence ol tuples or a select expression, posslbly In parerlheses. 274

')t.ThegeneraIorlorasequeneeoIluplesB acallon merrberwiththe 275

‘ltseoonrlparameterhnarltlatedtoallstolthesettrples. 276

setexpl S61, ST ) -> [‘('], I, eet6lt|:)( Set, ST ), [‘)'].

setexpl Set, ST) -> seleetexpl Set, ST),

I.

setexp( set( menber( Patt, lTup|Tups] ). tme, Patt, Types ), ST) -->

**tvplet Tun. T111700 ). Iunlesl Tum. T7004 1.**

{ rrirpattem( Types, Part) ), I.

setexpl sell lal, lal, l], I] ), _) -> synerrct badsetexpr ).

**w1>Ie=tlTu1>|T01=0l.Tr1m) --> I'.'l. I. 10171011017. 1017171100).**

**14000700117044. 1017171700) 1. 101000110170. Tynes)-**

**100100111-_) -> 11-**

**00rBlnrl0tlAIA0l-l1'lT01)->**

[','],

1, conetari(A,T), oonstarls( As,Ts).

**00retamstIl-l1)->l1-**

01100107001 Type. T1100)

=- I-

checlrtypel T1,T2)

```prolog
:- syr1err(lnror1sBter1t(T1,T2)).
```

277 276 279 260 261 262 263 264 265 266 207

**100101 141401-lTlT01) -->**

266

['<'], constant( A, T), consta11ts(As,Ts), [‘>'],

I. 209

**I01>let11.l]) -> l'<'l. 0700110100111-1010). Ital)-**

290 291 292 293 294 295 296 297 296 299

```prolog
%Pattlneet(_,_, Patl,_)lsal1stolnlreshvarlmles
%(nBthelengthoIlupleshthIsset).
```

<!-- page 253 -->
LISTING 8.4 (Continued)

n'Irpattem( l],|])

```prolog
            :-
             I.
rrIrpattem([_|Types],[V|Vs]) :-
                        rriq:1attem( Types, Vs ).
%---relatlonalexpresslons-~
relexp( E, ST ) ->
```

300 301 302 303 304 305 306

sln'plexp( Lel1E, LeltType, ST), relop( Op ),

I,

6ln'plexp( Fllgl1tE, Ftlgl-1tType, ST ),

{ consrel( LeltE, LeltType, Op, HbhtE, FlbhtType, E ) ).

I'6|Op( 'I<' )

—> ['u', '<'].

I'6bp( '02-’)

—V

**1-:I a£**

I 307 308 309 310

**relop( '--') -> [‘<', ‘>1.**

relopl '<') - 311

**reIop('>-') --> ['>','-'1.**

**relop( '>') -**

V

V

-7* ,_!'.-.-1

```prolog
consrell L, Type, Op, R, Type, E ) :- consrell L, Op, Fl, Type, E ),
                                           I.
corsrell L, LType, Op, Fl, RType, tall):-
   E -.. [Op, L, R], synerrcl typeconlllctl LType, RType, E ) ).
```

312 313 314 315 316 317 318 319 320 321

.113!“

.mr-rillr-:1)‘-'

‘ll. The llrst clause does corrpile-tlme equally.

```prolog
consrel( Arg, '-:-', Arg, _. true ).
consrel( L, '-:-', Ft, strlng, tall ).
corBrel( L, '--', Ft, strlng, not L - Fl ).
consrel( L, Op, R, heger, E)
                    :- E -.. IOP. L, Fl].
cornrel( L, '<', Fl, strlng, lstr(
                       ).
consrel( L, '-<', Ft, strlng, (
cornrel( L, '>', Ft, string, let
consrell L, '>-', R, strlng.(
                 5-=~e
‘ll. Compare strlngs lexlcogrq:>hleally.
W11]-Ll_1)
          1-
            1-
lstr([Ch1|_],[Ch2|_])
                 :- Ch1@<Ch2,
                            I.
lstr( [Ch1 |Chs1],[Ch1 |Chs2])
                      :- lstr( Chs1,Chs2).
```

322 323

**; L - Fl ) ).**

324 325

**; Fl - L) ).**

326 327 326 329 330 331

```prolog
%---sln'pleexpresslons---
s1n‘plexp( E. strlng, ST) -> strln@xp( E, ST),
                                1.
sll1‘plexp( E, Integer, ST ) --> ar1tl'|exp( E, ST).
stringexp(Slr, _) -->[s( Slr)],
                     I.
```

% Type checklng delayed to avold error messages - rnlght be Integer. 332 333 334 335 336 337 338

slrlrlgeIp( Var, ST) --> 339

**qname( ON ), { flndattrl ON, Var, Type, ST), Type - strhg }.**

340 341

```prolog
arithexp( E, ST ) --> 9t6I'I1'l( T, ST ), rarlthexp( T, E, ST ).
rarlthexpt L, E, ST) ->
   ['+'],
       I, atennt T, ST), rarltl1exp( L+T, E, ST).
rarlthexp( L, E, ST)
              —>
   |'-'),
       I, atom( T, ST ), rarltl'lexp( L-T, E, ST).
rarlthexp(E, E,__)
             --> [].
```

342 343 344 345 346 347 346 349

```prolog
atem1( T. ST) --> alaclor( F, ST), ratem1( F, T, ST ).
```

350 351

raterm( L, T, ST) -->

["'], I, aiactort F, ST ), raterm( L°F, T, ST).

raterm( L, T, ST) ->

['1'],

I, alactorl F, ST), ralem'|( UF, T, ST).

ratennl T, T, _ )

-> []. 352 353 354 355 356 357

xp( E, ST ), [')’]. 358 359

**v=V 5;‘**

**"5if**

alactort E, ST)

alactort Int, _ )

**alactor( Var, ST) -it**

<!-- page 254 -->
24-4 LISTING 8.4 (Continued)

**qname( ON ), { l1ndaltr( ON, Var, Type, ST ), Typg - Integer },**

I.

**alac-tor(0,_)**

**-> qname(ON), I,synerrc(noIlr|teger(ON)).**

```prolog
a1actor( 0, _ )
           -> synerrc( nohegertactor ).
% - - - Insert - - -
% Eg: lrio EMP hsert e'Jones',1000,1>, <'Smlth',1200,2>.
‘ll. Eg: Into EMP lnsen select Irom DEPT tuples <1-nanager, 1050, dno>.
hsenl (Generators, Fllter, assertz( NewTuple ), lal ) ) ->
   [n( Into ), n( Relttlame )].
   { ‘r e I'( RelName, _, FtelST) ), I, [n( Insert )],
   setexpl set( Generators, Flter, Ttple, Types ), I] ),
    { checlr.types( Types, RelST ),
   n'ltgen( Fteltllame, Ttple, NewTuple) ).
lnsert( lall) --> [n( Into ), n( Ftelllm )],
         synerrct norelnamel RelNm ) ).
01100107170011]-1])
             1- |-
checlttypes( [T|Ts], [attr( _, T, _ )|As]) :- 1, cheeltlypes( Ts, As ).
checlrtypes( Types, Altrs) :- synerr( badsettype( Types, Attrs ) ).
% - - - delete - - -
```

**% Eg: Irom EMP delete all tuples.**

**% Eg: Irom EMP delete tuples where salary < 1000 and**

‘ll.

**<dno>hselectlromDEPT triples <dno>**

‘)1.

**where manager - 'SmIh' .**

```prolog
%(le llrealsuborchatesol Smlhwhoeamlessthana 1000)
delete( ( RelGen, FtelFler, retract( FtelGen ), lal ) ) -->
   [n( Irom ), n( ReINrn )],
   { newrelnarne( Flelllm, FlelNm, FtelGen, |], ST) },
   [n( delete )], deIIllter( FlelFler, ST ).
delIllter( true, _) --> [n( all), n( 1uples)),
                            I.
deI|'ller( RelFIler, ST) ->
   [n( tuples ), n( where )], boolexpl FtelFilter, ST ).
```

360 361 362 363 364 365 366 367 368 389 370 371 372 373 374 375 376 377 378 379 380 381 382 383 384 385 386 387 388 389 390 391 392 393 394 395

```prolog
% - - - update - - -
‘ll. Eg: update EMP uslng DEPT, Mgr-EMP
```

**so that salary - salary + (Mgr_salary - sala|y)l5**

**where salary < Mgr_sala1y -1000 anrl Mgr_name - manager**

**and DEPT_dno - dno**

and not <Mgr_name> In

**select Irom BoardÀerrbete tuples <name>.**

**le to all errployees who earn over a 1000 less than thelr manager**

**glve a ralse equal to 20% ol the dillerence, provlded the manager**

**does not at on the board)**

**‘l'hls B oormlled to :**

' EMP'( Name, Sal, Dno ).

```prolog
                                 % Olt:ITup
    DEPT'(Dno,Manager), ' EMP'(Manager,ltIgrSal,MgrDno)), ‘ll. UseGens
   Sal < I.lgrSal - 1000. true, true.
$$$$$$£$$s0s0s!
%
%
         not (' Boardlllen'be1s'(Manager,_,_),1rue) ). % Fllter
   NewSalBSal+(MgrSal-Sal)l5,
                           %
%
   retract(‘ EMP'(Name,Sal,Dno)).assett(' EMP'(Name,NewSal,Dno)),lail
update( ( Olt:ITup, UseGerB, Fller, Moc¿lleatlore,
```

§§§§§§§§§§§§§§§§ 412 413 414 415 416 417 418 419

**retract( Olt:lTup ), assen( NewTup ), tall ) ) ->**

[n( update ), n( RelNm )].

**{ 'r e I'( FlelNm, OldT1.1p. OldST ),**

**‘r e I'( Flelllm, NewTup, NewST ),**

I.

**rnalrerncrIst( OldST, NewST, MLBI ) }.**

**uslngelmset UseGerB, UseST ), { ST - [F1eINm : OldST | UseS‘l') }.**

<!-- page 255 -->
I01 00 ). I'll 11101 )]. LISTING 8.4 (Continued)

420

moc¿ller( Modltlmtlon, l1lLBt, ST), 421

rnociflersl Mocilleatlon, l1lodlllcat1ons,MLlst,ST), 422

{closemocl1st( Must ) ), whereclmsel Fller, ST). 4:3

```prolog
update(lall) -> [n( update )], synerrc( noupdaledrelmlon).
```

425

uslngela.rse( Gerts, ST) --> [n(uslng)], reInames( Gerts, []. ST). 426

uslngclt|.rse(true, ST) -> []. 427 426

rnodIlers( M, (I.I,Ms), IvlLBt. ST) --> 429

['.'], l, modlllerl MM,MLBt,S1'), 430

rnocitlersl MM,l1ls, I.ILlst, ST). 431

rnodllletsl l1l,M,_,_) -> []. 432 433

rnodlller( AttrVar ls Expr, Must, ST ) --> 434

[n( Nm )], {llndmnarne( Nm, Altrvar, Type, MLlst) ), 435

['-'), sln'plexp( Expr, EType, ST), 435

1 "TYP01 T700. ETYP0. N111) )- 437 436

% A 'rnorIsl' lists updated relatlon's attrbutes together wlth new 439

‘It. varlables lonnlng new tq:>le's altrbutes and Mod variables which are 440

```prolog
%usedIoIlaganattrI:1ute's|'not:llllcatlonwhenltlsdetectedonthe
```

441

% lelt hanrl slde ol an equalty In ‘so that‘-list. 442

malt_emodist( [Old | Olds], [attr( _, __, Newv) | NewVs]. 443

```prolog
[mocil(Old,NewV,lvlod)|lllods]) :-
```

444

I, maltemodist( Olds, NewVs, Mods ). ¿g

maltemodistt [], []. [] ).

447

‘ll. Blnd old and new variables In "modllst' entrles wlth clear flag. 446

```prolog
closemodlBt([l1llod| Modal) :-
```

449

closemodt Mod ),

I, closemodlst( Mods ). 450

closemoÀtl I] ). 451

closen'od(modil(atlr(_,_,OldV),OldV,lvlod))

```prolog
                                :- var(Mod).
closemod( _ ).
```

452 453 454

% Flag an updated attrbute In '|'nodlBt'. 455

```prolog
flndn'name( Nm, NewV, T, MLBI) :-
```

456

meni:ler( rnod1l(attr( Nm, T, _ ), NewV, Mod ), MLlst ), l, 457

```prolog
mmod( Mod, Nm ).
```

456

llndn'narne( Nm, _, _, _)

```prolog
:- eynerrl rlotlrupdatedrell Nm ) ).
```

459 460 461

% ll no errors, the Ilrst clause ol mmod lals, the second blrnls.

_

```prolog
rnmoo(Mod,Nm) :- notvar(ltlod), l, synerr(updaIeclwlee(Nm)).
mmod(tn.1e,_).
```

462 463 464

```prolog
rrIype(Typ6.Type,_)
               :-
                 I.
```

465

```prolog
rrIype(T1,T2,Nm) :- synerr( typeconlllct(T1,Nm,T2)).
```

466 467

')t.---controlcommands--- 466

stop( sequelstop) --> [n(s1op)]. 469 470

```prolog
sequeBtop.
```

‘)0 do nothlng (cl the maln procechre) 471 472

load( oorBult( FlleName)) ->[n(load).n(lrom),rt(FlleName)]. 473

cIrrrp( t:lrrrp( FlleName)) --> [n( durrp ), n( to ), n( FlleName)].

476

```prolog
cirmp( FlleName) :- tell FlleName).
```

477

**'rel'( Nm, Gen, ST), welause('rel'( Nm, Gen,ST)),**

476

Gen, wclause( Gen ), tall. 479

```prolog
t:irrrp(_) :- wrlte('enrl.'), nl, told.
```

<!-- page 256 -->
**us'm~1c 11.4 (C0110-I111)**

**ct) ;- wrtteqt ct 1, write( ).0|-**

**---errorharItlr\r|1'1i)0101-"°"°°"'°"1'°"'1 ' ' ' ' H**

```prolog
     lrlol :- synrrlesl 1110 l. '1'°°51°'19'1°°mm“d1 -' worn
iii
3
   1101lrIo)
          ->
              10711110011010). WI‘l0('Context:')).
          coraext.
```

**‘It. wll lal everlualyl**

**i .7.**

**..>**

**{nl, a1\cest0r1001°0""'“"d1-'°"°'111'**

:_ N

w|iQ('---»

QITDTI '),

TII.

context

**->**

**lT01101'l- 1“'1°1"°"1T°k°“ 1 1' ends“**

```prolog
wtoken(T)
        =- wt1T.F1001T). wrltet FlealT), write("). |-
v1rt(n(N8rI16).1‘131"01-
wq I( Integer), |rI090r I-
wll 01 $11100 I. $11100 )-
wt( Char, Char).
narnerr(lrIo) ;- nl, wr1tet‘“'E"0'"-'1- "'-
         M,‘ "1, ,_ .1, tegte11toeeornneror_._))-
```

955659556053 492 493 494 495 498 497 498 499 500 501
