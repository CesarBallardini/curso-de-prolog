# 20 Search Techniques

<!-- page 430 -->
In this chapter, we show programs encapsulating classic AI search techniques. The first section discusses state-transition frameworks for solving problems formulated in terms of a state-space graph. The second discusses the minimax algorithm with alpha-beta pruning for searching game trees.

20.1 Searching State-Space Graphs State-space graphs are used to represent problems. Nodes of the graph are states of the problem. An edge exists between nodes if there is a transition rule, also called a move, transforming one state into the next. Solving the problem means finding a path from a given initial state to a desired solution state by applying a sequence of transition rules.

Program 20.1 is a framework for solving problems by searching their state-space graphs, using depth-first search as described in Section 14.2.

No cornniitment has been made to the representation of states. The moves are specified by a binary predicate `move(State,Move),` where `Move` is a move applicable to `State.` The predicate `update(State,Move,` `Statel)` finds the state `Statel` reached by applying the move `Move` to state `State.` It is often easier to combine the `move` and `update` procedures. We keep them separate here to make knowledge more explicit and to retain flexibility and modularity, possibly at the expense of performance.

<!-- page 431 -->
The validity of possible moves is checked by the predicate `legal` `(State),` which checks if the problem state `State` satisfies the constraints of the problem. The program keeps a history of the states visited solve_dfs (State,History,Moves) -

Moves is a sequence of moves to reach a

desired final state from the current State,

where History contains the states visited previously.

```prolog
solve_dfs(State,History,[ J) -
    final_state (State).
solve_dfs(State,History, [Move Moves])
    move (State,Move),
    update (State,Move,Statei),
    legal(Statel),
    not member(Statel ,History),
    solve_dfs(Statei, [Statelillistory] ,Moves).
```

Testing the framework

```prolog
test_dfs(Problem,Moves) -
    initial_state(Problem,State), solve_dfs(State,[State] Moves).
```

Program 20.1 A depth-first state-transition framework for problem solving

to prevent looping. Checking that looping does not occur is done by seeing if the new state appears in the history of states. The sequence of moves leading from the initial state to the final state is built incrementally in the third argument of `salve_df s/3.`

To solve a problem using the framework, the programmer must decide how states are to be represented, and axiomatize the `move, update,` and `legal` procedures. A suitable representation has profound effect on the success of this framework.

Let us use the framework to solve the wolf, goat, and cabbage problem. We state the problem informally. A farmer has a wolf, goat, and cabbage on the left side of a river. The farmer has a boat that can carry at most one of the three, and he must transport this trio to the right bank. The problem is that he dare not leave the wolf with the goat (wolves love to eat goats) or the goat with the cabbage (goats love to eat cabbages). He takes all his jobs very seriously and does not want to disturb the ecological balance by losing a passenger.

States are represented by a triple, `wgc(B,L,R),` where `B` is the position of the boat (left or right),

`L` is the list of occupants of the left bank, and `R` the list of occupants of the right bank. The initial and final states are

```prolog
                          wgc(lef t, [wolf,goat,cabbage]
                                                         , E ]) and
wgc (right, [
```

<!-- page 432 -->
I , `[wolf ,goat , cabbage]),` respectively. In fact, it is not strictly necessary to note the occupants of both the left and right banks. The occupants of the left bank can be deduced from the occupants of the right bank, and vice versa. But having both makes specifying moves clearer.

lt is convenient for checking for loops to keep the lists of occupants sorted. Thus wolf will always be listed before `goat,` both of whom will be before `cabbage` if they are on the same bank.

Moves transport an occupant to the opposite bank and can thus be specified by the particular occupant who is the `Cargo.` The case when nothing is taken is specified by the cargo `alone.` The nondeterministic behavior of `member` allows a concise description of all the possible moves in three clauses as shown in Program 20.2: moving something from the left bank, moving something from the right bank, or the farmer's rowing in either direction by himself.

For each of these moves, the updating procedure must be specified, namely, changing the position of the boat (by `update_boat/2)` and updating the banks (by `update_banks).` Using the predicate `select` allows a compact description of the updating process. The `insert` procedure is necessary to keep the occupant list sorted, facilitating the check if a state has been visited before. It contains all the possible cases of adding an occupant to a bank.

Finally, the test for legality must be specified. The constraints are simple. The wolf and goat cannot be on the same bank without the farmer, nor can the goat and cabbage.

Program 20.2, together with Program 20.1, solves the wolf, goat, and cabbage problem. The clarity of the program speaks for itself.

We use the state-transition framework for solving another classic search problem from recreational mathematicsthe water jugs problem. There are two jugs of capacity 8 and 5 liters with no markings, and the problem is to measure out exactly 4 liters from a vat containing 20 liters (or some other large number). The possible operations are filling up a jug from the vat, emptying a jug into the vat, and transferring the contents of one jug to another until either the pouring jug is emptied completely, or the other jug is filled to capacity. The problem is depicted in Figure 20.1.

<!-- page 433 -->
The problem can be generalized to N jugs of capacity C1.....CN. The problem is to measure a volume V, different from all the C but less than the largest. There is a solution if V is a multiple of the greatest common divisor of the C. Our particular example is solvable because 4 is a multiple of the greatest common divisor of 8 and 5. States for the wolf, goat and cabbage problem are a structure wgc(Boat,Left,Right), where Boat is the bank on which the boat currently is, Left is the list of occupants on the left bank of the river, and Right is the list of occupants on the right bank.

```prolog
initial_state(wgc,wgc(left, [wolf ,goat,cabbagej
                                             1 1)).
final_state (wgc(right, E i , [wolf ,goat ,cabbage])).
move(wgc(lef t ,L,R) ,Cargo) - member(Cargo,L).
move(wgc(right ,L,R) ,Cargo) - member(Cargo,R).
move(wgc(B,L,R) ,alone).
update(wgc(B,L,R),Cargo,wgc(B1,L1,R1)) -
    update_boat(B,B1), update_banks(Cargo,B,L,R,L1,R1).
update_boat (left ,right).
update_boat (right ,left).
update_banks(alone,B,L,R,L,R).
update_banks(Cargo,lef t ,L,R,Ll,R1)
    select(Cargo,L,L1), insert(Cargo,R,R1).
update_banks(Cargo,right,L,R,L1,R1) -
    select(Cargo,R,R1), insert(Cargo,L,L1).
insert(X,[YIYs],[X,YIYs]) -
    precedes (X , Y)
insert(X,[YIYs],[YIZs]) -
    precedes(Y,X) ,
                  insert(X,Ys,Zs)
insert(X,[ ],[X]).
precedes(wolf ,X).
precedes (X , cabbage)
legal(wgc(left,L,R)) - not illegal(R).
legal(wgc(right,L,R)) - not illegal(L).
illegal(Bank) - member(wolf Bank), menber(goat ,Bank).
illegal(Bank) - member(goat ,Bank), member(cabbage,Bank).
select(X,Xs,Ys)
                  See Program 3.19.
```

Program 20.2

<!-- page 434 -->
Solving the wolf, goat, and cabbage problem

4 litres

**Jb**

8 litres

5 litres

**-u**

Figure 20.1

The water jugs problem

The particular problem we solve is for two jugs of arbitrary capacity, but the approach is immediately generalizable to any number of jugs. The program assumes two facts in the database, `capacity(I CI),` for I equals i and 2. The natural representation of the state is a structure `jugs(V1 ,V2),` where Vi and `V2` represent the volumes of liquid currently in the two jugs. The initial state is `jugs (0,0)` and the desired final state either `jugs(0,X)` or `jugs(X,0),` where X is the desired volume. In fact, the only final state that needs to be specified is that the desired volume be in the larger jug. The volume can be transferred from the smaller volume, if it fits, by emptying the larger jug and pouring the contents of the smaller jug into the larger one.

Data for solving the jugs problem in conjunction with Program 20.1 are given in Program 20.3. There are six moves filling each jug, emptying each jug, and transferring the contents of one jug to another. A sampie fact for filling the first jug is `¡nove (jugs (Vi, V2) ,fili(i)).` The jugs' state is given explicitly to allow the data to coexist with other problem solving data such as in Program 20.2. The emptying moves are optimized to prevent emptying an already empty jug. The updating procedure associated with the first four moves is simple, while the transferring operation has two cases. If the total volume in the jugs is less than the capacity of the jug being filled, the pouring jug will be emptied and the other jug will have the entire volume. Otherwise the other jug will be filled to capacity and the difference between the total liquid volume and the capacity of the filled jug will be left in the pouring jug. This is achieved by the predicate `adjust/4.` Note that the test for legality is trivial because all reachable states are legal.

<!-- page 435 -->
Most interesting problems have too large a search space to be searched exhaustively by a program like 20.1. One possibility for improvement is

```prolog
iriitial_state(jugs,jugs(O,O)).
final_state(jugs(4,V)).
final_state(jugs(V,4).
move(jugs(V1,V2) ,fill(1)).
niove(jugs(Vt,V2) ,fill(2)).
move(jugs(V1,V2),empty(1)) - Vi
```

>

```prolog
                                 O.
move(jugs(V1,V2),empty(2)) - V2
```

>

```prolog
                                 O.
move(jugs(Vi,V2),transfer(2,1)).
move(jugs(V1,V2) ,transfer(1,2)).
update(jugs(Vi,V2),fill(1),jugs(C1,V2)) - capacity(i,C1).
update(jugs(V1,V2),fill(2),jugs(V1,C2))
                                        capacity(2,C2).
update(jugs(V1,V2) ,empty(1) ,jugs(O,V2)).
update(jugs(V1,V2),empty(2),jugs(Vi3O)).
update(jugs(Vi,V2),transfer(2,i),jugs(W1,W2)) -
    capacity(i,Ci),
    Liquid is Vi +
                  V2,
    Excess is Liquid - Cl,
    adjust (Liquid,Excess,Wl ,W2).
update(jugs(Vl,V2),transfer(i,2),jugs(Wl,W2)) -
    capacity(2,C2),
    Liquid is Vi +
                  V2,
    Excess is Liquid - C2,
    adjust (Liquid,Excess,W2,Wi).
adjust(Liquid,Excess,Liquid,O) - Excess
                                         O.
adjust(Liquid,Excess,V,Excess) -
    Excess
          > O, V is Liquid - Excess.
iegai(jugs(Vi,V2)).
capacity(i,8).
capacity(2,5).
```

**Program 20.3**

**Solving the water jugs problem**

<!-- page 436 -->
to put more knowledge into the moves allowed. Solutions to the jug problem can be found by filling one of the jugs whenever possible, emptying the other whenever possible, and otherwise transferring the contents of the jug being filled to the jug being emptied. Thus instead of six moves only three need be specified, and the search will be more direct, because only one move will be applicable to any given state. This may not give an optimal solution if the wrong jug to be constantly filled is chosen.

Developing this point further, the three moves can be coalesced into a higher-level move, `fill_and_transfer.` This tactic fills one jug and transfers all its contents to the other jug, emptying the other jug as necessary. The code for transferring from the bigger to the smaller jug is

```prolog
move(jugs(V1,V2) ,fill_and_transfer(1)).
update(jugs(V1,V2),fill_and_transfer(1),jugs(0,V))
     capacity(1,C1),
     capacity(2,C2),
     Cl > C2,
     V is (Cl+V2) mod C2.
```

Using this program, we need only three fill and transfer operations to solve the problem in Figure 20.1.

Adding such domain knowledge means changing the problem description entirely and constitutes programming, although at a different level.

Another possibility for improvement of the search performance, investigated by early research in Al, is heuristic guidance. A general framework, based on a more explicit choice of the next state to search in the state-space graph, is used. The choice depends on numeric scores assigned to positions. The score, computed by an evaluation function, is a measure of the goodness of the position. Depth-first search can be considered a special case of searching using an evaluation function whose value is the distance of the current state to the initial state, while breadth-first search uses an evaluation function which is the inverse of that distance.

<!-- page 437 -->
We show two search techniques that use an evaluation function explicitly: hill climbing and best-first search. In the following, the predicate `value (State,Value)` is an evaluation function. The techniques are described abstractly.

Hill climbing is a generalization of depth-first search where the successor position with the highest score is chosen rather than the leftmost one chosen by Prolog. The problem-solving framework of Program 20.1 is easily adapted. The hill climbing `move` generates all the states that can be reached from the current state in a single move, and then orders them in decreasing order with respect to the values computed by the evalu-

```prolog
ation function. The predicate evaluate_and_order(Moves ,State, MVs)
```

determines the relation that `MVs` is an ordered list of move-value tuples corresponding to the list of moves `Moves` from a state `State.` The overall program is given as Program 20.4.

To demonstrate the behavior of the program we use the example tree of Program 14.8 augmented with a value for each move. This is given as Program 20.5. Program 20.4, combined with Program 20.Sand appropriate definitions of `update` and `legal` searches the tree in the order `a, d,` j. The program is easily tested on the wolf, goat, and cabbage problem using as the evaluation function the number of occupants on the right bank.

Program 20.4 contains a repeated computation. The state reached by `Move is` calculated in order to reach a value for the move and then recalculated by `update.` This recalculation can be avoided by adding an extra argument to `move` and keeping the state along with the move and the value as the moves are ordered. Another possibility if there will be many calculations of the same move is using a memo-function. What is the most efficient method depends on the particular problem. For problems where the `update` procedure is simple, the program as presented will be best.

Hill climbing is a good technique when there is only one hill and the evaluation function is a good indication of progress. Essentially, it takes a local look at the state-space graph, making the decision on where next to search on the basis of the current state alone.

An alternative search method, called best-first search, takes a global look at the complete state-space. The best state from all those currently unsearched is chosen.

<!-- page 438 -->
Program 20.6 for best-first search is a generalization of breadth-first search given in Section 16.2. A frontier is kept as for breadth-first search, which is updated as the search progresses. At each stage, the next best available move is made. We make the code as similar as possible to Program 20.4 for hill climbing to allow comparison. solve_hill_climb (Sta te,History,Moves) - Moves is the sequence of moves to reach a desired final state from the current State, where History is a list of the states visited previously.

```prolog
solve_hill_climb(State,History, [ ])
    final_state (State).
solve_hill_climb(Sate,History,[MovePMoves]) -
    hill_climb (State , Move)
    update (State,Move,Statel),
    legal(Statel)
    not member(Statel,History),
    solve_hill_climb(Statel, [Statel IHistory] Moves)
hill_climb(State,Move) -
    findall(M,move(State,M) ,Moves)
    evaluate_and_order(Moves,State, E
                                   ] ,MVs),
    member((Move,Value) ,MVs).
```

evaluate_and_order (Moves,State,SoFar, Orde redMvs) All the Moves from the current State are evaluated and ordered as Orde redMvs. SoFar

`is` an accumulator for partial computations.

```prolog
evaluate_and_order([Move Moves] ,State ,MVs ,DrderedMVs)
    update(State ,Move,Statel),
    value (Statel, Value)
    insert((Move,Value) ,MVs,MVs1),
    evaluate_and_order (Moves ,State,MVs1 ,OrderedMVs).
evaluate_and_order([ I ,State,MVs,MVs).
insert(MV,[ ],[MV]).
insert((M,V),[(M1,V1)IMVs],[(M,V),(M1,V1)IMVs]) -
    V
        Vi.
insert((M,V),[(Ml,Vi)JMVs]j(M1,V1)IMVs1]) -
    V < Vi, ïnsert((M,V),MVs,MVsi).
```

Testing the framework

```prolog
test_hill_climb(Problem,Moves) -
    initial_state (Problem,State),
    solve_hill_climb(State, [State] ,Moves)
```

Program 20.4

<!-- page 439 -->
Hill climbing framework for problem solving

```prolog
initial_state(tree,a).
                         value(a,O).
                                       final_state(j).
move(a,b).
             value(b,1).
                           move(c,g).
                                         value(g,6).
move(a,c).
             value(c,5).
                           move(d,j).
                                         value(j,9).
move(a,d).
             value(d,7).
                           move(e,k).
                                         value(k,1).
move(a,e).
             value(e,2).
                           move(f,h).
                                         value(h,3).
move(c,f).
             value(f,4).
                           move(f,i).
                                         value(i,2).
```

Program 20.5

Test data

At each stage of the search, there is a set of moves to consider rather than a single one. The plural predicate names, for example, `updates` and `legals,` indicate this. Thus `legals(States,Statesl)` filters a set of successor states, checking which ones are allowed by the constraints of the problem. One disadvantage of breadth-first search (and hence bestfirst search) is that the path to take is not as conveniently calculated. Each state must store explicitly with it the path used to reach it. This is reflected in the code.

Program 20.6 tested on the data of Program 20.5 searches the tree in the same order as for hill climbing.

Program 20.6 makes each step of the process explicit. In practice, it may be more efficient to combine some of the steps. When filtering the generated states, for example, we can test that a state is new and also legal at the same time. This saves generating intermediate data structures. Program 20.7 illustrates the idea by combining all the checks into one

```prolog
procedure, update_frontier.
```

Exercises for Section 20.1

Redo the water jugs program based on the two fill-and-transfer

```prolog
operations.
```

Write a program to solve the missionaries and cannibals problem:

Three missionaries and three cannibals are standing on the left bank of

a river. There is a small boat to ferry them across with enough room

for only one or two people. They wish to cross the river. If ever there

are more missionaries than cannibals on a particular bank of the river,

the missionaries will convert the cannibals. Find a series of ferryings

to transport safely all the missionaries and cannibals across the river

<!-- page 440 -->
without exposing any of the cannibals to conversion. solve_best (Frontier,History,Moves) Moves is a sequence of moves to reach a desired final state from the initial state, where Frontier contains the current states under consideration, and History contains the states visited previously. solve_best([state(State,Path,Value)IFrontior] ,History,Moves)'final_state(State), reverse(Path,Moves). solve_best([state(State,Path,Value)IFrontier] ,History,FinalPath)findall(M,rnove(State,M) Moves), updates (Moves , Path, State , States) legals(States,Statesl) news(Statesl,History,States2), evaluates(States2,Values), inserts(Values,Frontier,Frontierl), solve_best (Frontierl, [State IHistory] ,FinalPath) upda tes (Moves,Path,State,Sta tes) States is the list of possible states accessible from the current State, according to the list of possible Moves, where Path is a path from the initial node to State. updates([MIMs],Path,S,[(S1,[MIPath]flSs]) update(S,M,S1), updates(Ms,Path,S,Ss). updates([ ],Patb,State,[ 1). le gals (States,Statesl) - Statesi is the subset of the list of States that are legal. legals( E (S , P) IStates] , [ (S , P) IStatesi] ) legal(S), legals(States,Statesl). legals( E (S, P) States] , St at esi) not legal(s), legals(States,Statesl) legals(E ],[ 1). news (States,History,Statesl) - Statesi is the list of states in States but not in History. news([(S,P)IStates] ,History,Statesl) member(S,History), news(States,Hïstory,Statesl). news([(S,P)IStates],History,[(S,P)IStatesl]) not member(S,History), news(States,History,Statesl). news([ ],History,[ 1). evaluates(States,Values) - Values is the list of tuples of States augmented by their value. evaluates([(S,PflStates],[state(S,P,VflValues]) value(S,V), evaluates(States,Values). evaluates([ ],[ 1). Program 20.6

<!-- page 441 -->
Best-first framework for problem solving inserts (States,Frontier,Frontierl) - Fron tien

is the result of inserting States into the current Frontier.

```prolog
inserts([ValuelValues] ,Frontier,Frontierl) -
    insert (Value ,Frontier, FrontierO),
    inserts (Values, FrontierO , Frontierl).
inserts([ I ,Frontier,Frontier).
insert (State, C j , [State]).
insert(State,[StatellStates] , [State,StatellStates] -
    lesseq_value(State , Statel).
insert (State, [Statel IStates] , [State IStates]) -
    equals(State,Statel).
insert(State, [StateliStates] , [StateliStatesi]) -
    greater_value(State,Statel), insert(State,States,Statesl)
equals(state(S,P,V) ,state(S,P1,V)).
lesseq_value(state(Si,Pi,V1),state(52,P2,V2)) - Si
                                                   S2, Vi
                                                            V2.
greater_value(state(S1,P1,V1),state(S2,P2,V2)) - Vi
                                                  >
                                                    V2.
```

Program 20.6

(Continued)

solve_best (Frontier,History,Moves) Moves is a sequence of moves to reach a desired final state from the initial state. Frontier contains the current states

```prolog
    under consideration. History
                              contains the states visited previously.
solve_best([state(State,Path,Value) Frontier] ,History,Moves) -
    final_state(State), reverse(Path, [ j ,Moves).
solve_best([state(State,Path,Value) Frontier] ,History,FinalPath)
    findall(M,move(State,M) ,Moves),
    update_frontier(Moves,State,Path,History,Frontier,Frontierl),
    solve_best (Frontierl, [State I History] , FinalPath).
update_frontier([MIMs],State,Path,Hïstory,F,F1) -
    update (State , M, Statel)
    legal(Statel),
    value (Statel,Value),
    not member(Statel,History),
    insert((Statel, [MiPath] ,Value) ,F,FO),
    update_Írontier(Ms,State,Path,History,FO,F1).
update_frontier([ ],S,P,H,F,F).
insert(State,Frontier,Frontierl) - See Program 20.6.
```

Program 20.7

<!-- page 442 -->
Concise best-first framework for problem solving Write a program to solve the five jealous husbands problem (Dudeney, 1917): During a certain flood five married couples found themselves surrounded by water and had to escape from their unpleasant position in a boat that would only hold three persons at a time. Every husband was so jealous that he would not allow his wife to be in the boat or on either bank with another man (or with other men) unless he himself was present. Find a way of getting these five men and their wives across to safety. Compose a general problem-solving framework built around breadth-first search analogous to Program 20.1, based on programs in Section 16.2.

(y) Express the 8-queens puzzle within the framework. Find an evaluation function.

20.2 Searching Game Trees What happens when we play a game? Starting the game means setting up the chess pieces, dealing out the cards, or setting out the matches, for example. Once it is decided who plays first, the players take turns making a move. After each move the game position is updated accordingly. We develop the vague specification in the previous paragraph into a simple framework for playing games. The top-level statement is

```prolog
play(Game)
     initialize (Gaine, Position ,Player),
    display_game (Position,Player),
    play (Position, Player , Result)
```

<!-- page 443 -->
The predicate `initialize (Gaine ,Posit on,Player)` determines the initial game position Position for `Game,` and `Player,` the player to start. A game is a sequence of turns, where each turn consists of a player choosing a move, the move being executed, and the next player being determined. The neatest way of expressing this is as a tail recursive procedure, `play,` with three arguments: a game position, a player to move, and the final result. It is convenient to separate the choice of the move by `choose_move/3` from its execution by `move/3.` The remaining play(Game) -

Play game with name Game.

```prolog
play(Game) -
    initialize(Game,Position,Player),
    display_game (Position , Player)
    play(Position,Player,Result).
play(Position,Player,Result) -
    game_over (Position,Player,Result),
                                     !
                                      ,
                                        announce(Result).
play(Position,Player,Result) -
    choose_move (Position, Player , Move)
    move(Move,Position,Positionl),
    display_game (Positioni ,Player),
    next_player(Player,Playerl),
       play(Positionl,Playeri,Result).
```

Program 20.8 Framework for playing games

predicates m the clause for `play/3` display the state of the game and determine the next player:

```prolog
play(Position,Player,Result) -
    choose_move(Position,Player,Move),
    move(Move,Position,Positionl),
    display_game (Positioni ,Player),
    next_player(Player ,Player 1),
     !,
         play(Positionl,Playerl,Result)
```

Program 20.8 provides a logical framework for game-playing programs. Using it for writing a program for a particular game focuses attention on the important issues for game playing: what data structures should be used to represent the game position, and how strategies for the game should be expressed. We demonstrate the process in Chapter 21 by writing programs to play Nim and Kalah.

The problem-solving frameworks of Section 20.1 are readily adapted to playing games. Given a particular game state, the problem is to find a path of moves to a winning position.

<!-- page 444 -->
A game tree is similar to a state-space graph. It is the tree obtained by identifying states with nodes and edges with players' moves. We do not, however, identify nodes on the tree, obtained by different sequences of moves, even if they repeat the same state. In a game tree, each layer is called a ply. evahiate_and_choose (Moves,Position,Record,BestMove) -

Chooses the BestMove from the set of Moves from the

current Position. Record records the current best move.

```prolog
evaluate_and_choose( [MovelMoves] ,Positïon,Record,BestMove)
    inove(Move,Position,Positionl)
    value(Positionl ,Value),
    update (Move , Value , Record , Recordi)
    evaluate_and_choose(Moves,Position,Recordl ,BestMove).
evaluate_and_choose([ j ,Position, (Move,Value) ,Move).
update(Move,Valu,(Move1,Value1),(Move1,Value1))
    Value
            Valuel.
update(Move ,Value, (Movel ,Valuel) ,(Move ,Value)) -
    Value > Valuel.
```

Program 20.9

Choosing the best move

Most game trees are far too large to be searched exhaustively. This section discusses the techniques that have been developed to cope with the large search space for two-person games. In particular, we concentrate on the minimax algorithm augmented by alpha-beta pruning. This strategy is used as the basis of a program we present for playing Kalah in Chapter 21.

We describe the basic approach of searching game trees using evaluation functions. Again, in this section `value(Position,Value)` denotes an evaluation function computing the `Value` of `Position,` the current state of the game. Here is a simple algorithm for choosing the next move: Find all possible game states that can be reached in one move. Compute the values of the states using the evaluation function. Choose the move that leads to the position with the highest score. This algorithm is encoded as Program 20.9. It assumes a predicate `move (Move,Position,Positionl)` that applies a `Move` to the current `Po-` `sition` to reach `Positioni.` The interface to the game framework of Program 20.8 is provided by the clause

```prolog
choose_move (Position, computer,Move) -
    firidall(M,move(Position,M) ,Moves),
    evaluate_and_choose (Moves,Position, (nil,-1000) ,Move).
```

<!-- page 445 -->
The predicate `move(Position,Move)` is true if `Move` is a possible move from the current position.

The basic relation is `evaluate_and_choose (Noves ,Position,Record,` `BestMove)` which chooses the best move `BestMove` in the possible `Moves` from a given `Position.` For each of the possible moves, the corresponding position is determined, its value is calculated, and the move with the highest value is chosen. `Record` is a record of the current best move so far. In Program 20.9, it is represented as a tuple `(Move,Value).` The structure of `Record` has been partially abstracted in the procedure `up` `date/4.` How much data abstraction to use is a matter of style and a trade-off among readability, conciseness, and performance.

Looking ahead one move, the approach of Program 20.9, would be sufficient if the evaluation function were perfect, that is, if the score reflected which positions led to a win and which to a loss. Games become interesting when a perfect evaluation function is not known. Choosing a move on the basis of looking ahead one move is generally not a good strategy. It is better to look several moves ahead and to infer from what is found the best move to make.

The minimax algorithm is the standard method for determining the value of a position based on searching the game tree several ply ahead.

The algorithm assumes that, when confronted with several choices, the opponent would make the best choice for her, i.e., the worst choice for me. My goal then is to make the move that maximizes for me the value of the position after the opponent has made her best move, i.e., that minimizes the value for her. Hence the name minimax This reasoning proceeds several ply ahead, depending on the resources that can be allocated to the search. At the last ply the evaluation function is used.

Assuming a reasonable evaluation function, the algorithm will produce better results the more ply are searched. It will produce the best move if the entire tree is searched.

The minimax algorithm is justified by a zero-sum assumption, which says, informally, that what is good for me must be bad for my opponent, and vice versa.

<!-- page 446 -->
Figure 20.2 depicts a simple game tree of depth 2 ply. The player has two moves in the current position, and the opponent has two replies. The values of the leaf nodes are the values for the player. The opponent wants to minimize the score, so will choose the minimum values, making the positions be worth +1 and 1 at one level higher in the tree. The player wants to maximize the value and will choose the node with value +1. Figure 20.2 A simple game tree

Program 20.10 encodes the rninimax algorithm. The basic relation is `minimax(D,Position,MaxMin,Move,Value),` which is true if `Move is` the move with the highest `Value` from `Position` obtained by searching `D ply` in the game tree. `MaxMin` is a flag that indicates if we are maximizing or minimizing. lt is i for maximizing and - i for minimizing, the particular values being chosen for ease of manipulation by simple arithmetic operations. A generalization of Program 20.9 is used to choose from the set of moves. Two extra arguments must be added to `evaluate_and_choose:` the number of ply `D` and the flag `MaxMin.` The last argument is generalized to reflirn a record including both a move and a value rather than just a move. The `minimax` procedure does the bookkeeping, changing the number of moves being looked ahead and also the minimax flag. The initial record is `(nil,-1000),` where `nil` represents an arbitrary move and

i000 is a score intended to be less than any possible score of the evaluation function.

The observation about efficiency that was made about combining the move generation and update procedures in the context of searching state-space graphs has an analogue when searching game trees. Whether it is better to compute the set of positions rather than the set of moves (with the corresponding change in algorithm) will depend on the particular application.

<!-- page 447 -->
The minimax algorithm can be improved by keeping track of the results of the search so far, using a technique known as alpha-beta pruning. The idea is to keep for each node the estimated minimum value found so far, the alpha value, along with the estimated maximum value, beta. If, on evaluating a node, beta is exceeded, no more search on that branch is necessary. In good cases, more than half the positions in the game tree need not be evaluated. evaluate_and_choose (Moves,Position,Depth,Flag,Record,BestMove) -

Choose the BestMove from the set of Moves from the current

Position using the minimax algorithm searching Depth piy ahead.

Flag indicates if we are currently minimizing or maximizing.

Record records the current best move.

```prolog
evaluate_and_choose( [MovelMoves] ,Position,D,MaxMin,Record,Best)
    move (Move,Position,Positionl),
    minimax(D,Positionl ,MaxMin,MoveX,Value),
    update (Nove ,Value, Record, Recordi),
    evaluate_and_choose(Moves,Position,D,MaxMin,Recordl Best).
evaluate_and_choose([ I ,Position,D,MaxMin,Record,Record).
minimax(O,Position,MaxMin,Move,Value) -
    value (Position,V),
    Value is V*MaxMin.
minimax (D Position, MaxMin Move, Value)
    D > O,
    findall(M,move(Position,M) ,Moves),
    Dl is D
             1,
    MinMax is -MaxMin,
    evaluate_and_choose(Moves,Position,Dl,MinMax, (nil,-1000),
        (Nove,Value)).
update (Move,Value ,Record,Recordl) - See Program 20.9.
```

Program 20.10 Choosing the best move with the minimax algorithm

Program 20.11 is a modified version of Program 20.10 that incorporates alpha-beta pruning. The new relation scheme is `alpha_beta` `(Depth,Position,Alpha,Beta,Move ,Value),` which extends mirumax by replacing the minimax flag with alpha and beta. The same relation holds with respect to `evaluate_and_choose.`

Unlike the one in Program 20.10, the version of `evaluate_arid_choose` in Program 20.11 does not need to search all possibilities. This is achieved by introducing a predicate `cutoff,` which either stops searching the current branch or continues the search, updating the value of alpha and the current best move as appropriate.

For example, the last node in the game tree in Figure 20.2 does not need to be searched. Once a move with value 1 is found, which is less than the value of + 1 the player is guaranteed, no other nodes can contribute to the final score.

<!-- page 448 -->
The program can be generalized by replacing the base case of `alpha_` `beta` by a test of whether the position is terminal. This is necessary in chess programs, for example, for handling incomplete piece exchanges. evaluate_and_choose (Moves,Position,Depth,Alpha,Beta,Record,BestMove) Chooses the BestMove from the set of Moves from the current Position using the minimax algorithm with alpha-beta cutoff searching Depth piy ahead. Alpha and Beta are the parameters of the algorithm. Record records the current best move.

```prolog
evaluate_and_choose([MovelMovesl ,Position,D,Alpha,Beta,Movel,
        BestMove)
    move(Move,Position,Positionl)
    alpha_beta(D ,Positionl ,Alpha,Beta,MoveX,Value),
    Valuel is -Value,
    cutoff (Move,Valuel,D,Alpha,Beta,Moves,Positïon,Novel,BestMove)
evaluate_and_choose([ j ,Position,D,Alpha,Beta,Move,(Move,Alpha)).
alpha_beta(O ,Positïon,Alpha,Beta,Move ,Value) -
    value (Position, Value)
alphabeta(D,Position,Alpha,Beta,Move ,Value)
    findall(M,move(Position,M) ,Moves),
    Alphal is -Beta,
    Betal is -Alpha,
    Dl is D-1,
    evaluateand_choose(Moves,Position,D1,Alphal,Betal,nil,
        i (Move,Value)).
cutoff (Move,Value,D,Alpha,Beta,Moves,Position,Movel, (Move,Value))
    Value
            Beta.
cutoff (Move,Value,D,Alpha,Beta,Moves,Position,Movel,BestMove)
    Alpha <
           Value, Value
                        < Beta,
    evaluateandchoose(Moves,Position,D,Value,Beta,Move,BestMove)
cutoff (Move,Value,D,Alpha,Beta,Moves,Position,Movel,BestMove)
    Value
            Alpha,
    evaluateandchoose(Moves,Positiou,D,Alpha,Beta,Movel,BestMove).
```

Program 20.11

Choosing a move using minimax with alpha-beta pruning

<!-- page 449 -->
20.3 Background Search techniques for both planning and game playing are discussed in Al textbooks. For further details of search strategies or the minimax algorithm and its extension to alpha-beta pruning, see, for example, Nilsson (1971) or Winston (1977). Walter Wilson originally showed us the alpha-beta algorithm in Prolog. V.

**4M**

**1 '**

lr

**r'--4-**

**..-i.**

**.-; 4r Ti+**

T T 4

**4.**

**1' -**

L.J.U....._A_-_1-___¡

- - r

**___**

- r --' r'" .,.

**. 4_r. .Jw**

**s**

**-.. -'1 ''r**

**-f**

,st.f,a4

**4.w4.M**

-qe.

**....» ..-''.1**

**. i**

.a

..

L

'

'rà'. ....

1A4 Leonardo Da Vinci, The Proportions of the Human Figure, after Vitruvius. Pen and ink. About 1492. Venice Academy.
