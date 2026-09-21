# 21 Game-Playing Programs

<!-- page 452 -->
Learning how to play a game is fun. As well as understanding the rules of the game, we must constantly learn new strategies and tactics until the gaine is mastered. Writing a program to play games is also fun, and a good vehicle for showing bow to use Prolog for writing nontrivial programs.

21.1 Mastermind Our first program guesses the secret code in the game of mastermind lt is a good example of what can be programmed in Prolog easily with just a little thought.

The version of mastermind we describe is what we played as kids. It is a variant on the commercial version and needs less hardware (only pencil and paper). Player A chooses a sequence of distinct decimal digits as a secret codeusually four digits for beginners and five for advanced players. Player B makes guesses and queries player A for the number of bulls (number of digits that appear in identical positions in the guess and in the code) and cows (number of digits that appear in both the guess and the code, but in different positions).

<!-- page 453 -->
There is a very simple algorithm for playing the game: Impose some order on the set of legal guesses; then iterate, making the next guess that is consistent with all the information you have so far until you find the secret code.

Rather than defining the notion of consistency formally, we appeal to the reader's intuition: A guess is consistent with a set of answers to queries if the answers to the queries would have remained the same if the guess were the secret code.

The algorithm performs quite well compared with experienced players: an average of four to six guesses for a code with four digits with an observed maximum of eight guesses. However, it is not an easy strategy for humans to apply, because of the amount of bookkeeping needed. On the other hand, the control structure of Prolognondeterministic choice, simulated by backtrackingis ideal for implementing the algorithm.

We describe the program top-down. The entire program is given as Program 21.1. The top-level procedure for playing the game is

```prolog
mastermind(Code) -
     cleanup, guess(Code), check(Code), announce.
```

The heart of the top level is a generate-and-test loop. The guessing procedure `guess (Code),` which acts as a generator, uses the procedure `se-` `lects(Xs,Ys)` (Program 7.7) to select nondeterrninistically a list `Xs` of elements from a list Ys. According to the rules of the game, Xs is constrained to contain four distinct elements, while Ys is the list of the ten decimal digits:

```prolog
guess(Code) -
    Code = [X1,X2,X3,X4],
    selects(Code,[1,2,3,4,5,6,7,8,9,O]).
```

The procedure `check(Guess)` tests the proposed code `Guess.` It first verifies that `Guess is` consistent with all (i.e., not inconsistent with any) of the answers to queries already made; then it asks the user for the number of bulls and cows in `Guess.` The `ask(Guess)` procedure also controls the generate-and-test loop, succeeding only when the number of bulls is four, indicating the correct code is found:

```prolog
check(Guess) -
    not inconsistent(Guess), ask(Guess).
```

<!-- page 454 -->
`Ask` stores previous answers to queries in the relation `query(X,B,C),` where X is the guess, `B` is the number of bulls in it, and C the number of cows. A guess is inconsistent with a previous query if the number of bulls and cows do not match:

```prolog
mastermind(Code) -
    cleanup, guess(Code), check(Code), announce.
guess(Code) -
    Code
         =
           [X1,X2,X3,X4J, selects(Code,[1,2,3,4,5,6,7,8,9,O]).
```

Verify the proposed guess

```prolog
check (Guess)
    not inconsistent(Guess) ,
                           ask(Guess)
inconsistent (Guess)
    query(OldGuess,Bulls,Cows),
    not bulls_and_cows_rnatch(DldGuess,Guess,Bulls,Cows).
bulls_and_cows_match(OldGuess,Guess,Bulls,Cows) -
    exact_matches(OldGuess,Guess,N1),
    Bulls =:
             Nl,
                          'f, Correct number of bulls
    common_members (OldGuess Guess ,N2),
    Cows =:= N2-Bulls.
                          '/ Correct number of cows
exact_matches(Xs,Ys,N) -
    size_of (A,saine_place(A,Xs,Ys) ,N)
common_members(Xs ,Ys ,N)
    size_of (A, (member(A,Xs) ,member(A,Ys)) ,N).
sanie_place(X,[XIXs] , [XIYs]).
sane_place(A, [XIXs] , [YIYs]) - same_place(A,Xs,Ys)
```

Asking a guess

```prolog
ask (Guess)
    repeat,
    writeln(['How many bulls and
                               cows in ',Guess,'?']),
    read((Bulls,Cows))
    sensible (Bulls,Cows)
    assert (query(Guess,Bulls,Cows)),
    Bulls
             4.
sensible(Bulls,Cows) -
    integer(Bulls), integer(Cows), Bulls+Cows
                                              4.
Bookkeeping
cleanup - abolish(query,3).
announce -
    size_of (X,query(X,A,B) ,N)
    writeln(['Found the answer after ',N,' queries']).
size_of(X,G,N) - findall(X,G,Xs), length(Xs,N).
length(Xs,N) - See Program 8.11.
selects(X,Xs) - See Program 7.7.
abolish(F,N) - See Exercise 12.5(i).
```

Program 21.1

<!-- page 455 -->
Playing mastermind inconsistent(Guess) -

```prolog
query(Úld,Bulls,Cows),
not bulls_and_cows_match(Old,Guess,Bulls,Cows).
```

The bulls match between a previous guess OldGuess and a conjectured guess Guess if the number of digits in the same position in the two guesses equals the number of Bulls in DidGuess. It is computed by the predicate exact_matches(DldGuess,Guess,Bulls). The cows match if the number of common digits without respect to order corresponds to the sum of Bulls and Cows; it is computed by the procedure bulls_ and_cows_match. It is easy to count the number of matchtug digits and common digits in two queries, using an all-solutions predicate size_ of/3.

The ask(Guess) procedure is a memo-function that records the answer to the query. It performs some limited consistency checks on the input with the procedure sensible/2 and succeeds only if four bulls are indicated. The expected syntax for the user's reply is a tuple (Bulls,Cows).

The remaining (top-level) predicates are for bookkeeping. The first, cleanup, removes unwanted information from previous games. The predicate announce tells how many guesses were needed, which is determined using size_of /3.

A more efficient implementation of the exact_matches and common_ members procedures can be obtained by writing iterative versions: exact_matches(Xs,Ys,N) - exact_matches(Xs,Ys,O,N). exact_matches([XIXs] , [XIYsI ,K,N) -

Kl is K+l, exact_matches(Xs,Ys,Kl,N). exact_matches([XIXs] , [YIYsI ,K,N) -

X

Y, exact_matches(Xs,Ys,K,N). exact_matches([ ],[ ],N,N). common_members(Xs,Ys,N) - common_members(Xs,Ys,O,N). comnaon_members([XIXs] ,Ys,K,N) -

```prolog
member(X,Ys), Kl is K+l, comnion_members(Xs,Ys,Kl,N).
```

comrnon_members([XIXs] ,Ys,K,N) -

common_members (Xs , Ys , K, N). comxnon_members([ I ,Ys,N,N).

<!-- page 456 -->
Using the more efficient versions of exact_matches and common_ members saves about 10%-30% of the execution time. 21.2 Ni We turn our attention now from mastermind to Nim, also a game for two players. There are several piles of matches, and the players take turns removing some of the matches (up to all) in a pile. The winner is the player who takes the last match. Figure 21.1 gives a common starting position, with piles of 1, 3, 5 and 7 matches.

To implement the Nim-playing program, we use the game-playing framework of Program 20.8.

The first decision is the representation of the game position and the moves. A natural choice for positions is a list of integers where elements of the list correspond to piles of matches. A move is a tupie (N,M) for taking M matches from pile N. Writing the procedure `move(Move,Position,Positionl),` where `Position` is updated to Posi- `tioni` by `Move,` is straightforward. The recursive rule counts down match piles until the desired pile is reached. The remaining piles of matches representing the new game position are computed routinely:

```prolog
move((K,M) , [NINs] , [N1Ns1]) -
    K > 1, Kl is K-1, move((K1,M),Ns,Nsl).
```

There are two possibilities for updating the specified pile of matches, the base case of the procedure. If all the matches are taken, the pile is removed from the list. Otherwise the new number of matches in the pile is computed and checked to be legal:

```prolog
move((1,N), [NINs] ,Ns).
move((l,M), [NINs] , [Nl INs]) - N > M, Nl is N-M.
```

The mechanics of turns for two-person games is specified by two facts.

s

s

I

I

<!-- page 457 -->
Figure 21.1 A starting position for Nim

The initial piles of matches and who moves first must be decided by the two players. Assuming the computer moves second, the game of Figure 21.1 is specified as

```prolog
initialize(niin, [1,3,5,7] ,opponent).
```

The game is over when the last match is taken. This corresponds to the game position being the empty list. The person having to move next is the loser, and the output messages of `announce` are formulated accordingly. The details are in Program 21.2.

It remains to specify how to choose the moves. The opponent's moves are accepted from the keyboard; how much flexibility is allowed in input is the responsibility of the programmer

```prolog
choose_move (Pos ition,opponent, Move)
    writeln(['Please make move']),
    read (Move),
    legal (Move,Position).
```

Choosing a move for the computer requires a strategy. A simple strategy to implement is taking all of the first pile of matches. It is recommended only for use against extremely poor players:

```prolog
choose_move([NINs] ,computer, (1,N)).
```

A wirming strategy is known for Nim. It involves dividing game states, or positions, into two classes, safe and unsafe. To determine if a position is safe or unsafe, the binary representation of the number of matches in each pile is computed. The fErn-sum of these binary numbers is then calculated as follows. Each column is summed independently modulo 2. If the total in each colunm is zero, the position is safe. Otherwise the position is unsafe.

<!-- page 458 -->
Figure 21.2 illustrates the process for the four piles of matches in Figure 21.1. The binary representations of 1, 3, 5, and 7 are 1, 11, 101, and 111 respectively. Calculating the mm-sum: there are four l's in the units column, two l's in the 2's colunm and two l's in the 4's colunm; an even number of l's in each. The mm-sum is zero, making the position [1,3,5,7] safe. On the other hand the position [2,61 is unsafe. The binary representations are 10 and 110 Summing them gives one i in the 4's column and two l's in the 2's colunm. The single i in the 4's column makes the position unsafe. play(Game) '- See Program 20.8. Filling in the game-playing framework initialize(nim, [1,3,5,7'] opponent). display_gaine(Position,X)

write(Position), nl. ganie_over([ I ,Player,Player). anuounce(computer) - write('You won! Congratulations.'), nl. annol.mco(opponent) - write('I won.'), nl. Choosing moves choose_move (Position,opponent Move)

```prolog
writeln(['Please make move']), read(Move), legal(Move,Position).
```

legal((K,N) Position) - nth_member(K,Position,M), N

M. nth_member(1, [XIXs] ,X). nth_rnember(N,[XIXs],Y)

N > 1, Nl is N-1, nth_member(N1,Xs,Y). choose_move (Position, computer,Move)

evaluate (Position,Saf ety,Suxri)

```prolog
decide_move(Safety,Position,Sum,Move).
```

evaluate(Positïon,Safety,Suin) -

```prolog
nim_sum(Position, [ I ,Suxn) , sa±ety(Sum,Salety)
```

safety(Sum,safe) - zero(Sum), !. safety(Suxn,unsafe) - not zero(Suin), decide_move(safe Position,Sum, (1,1))

'h The computer's ''arbitrary nove'' decide_move(unsaíe,Position,Sum,Move) -

```prolog
saíe_move(Position,Sum,Move).
```

move(Move,Position,Positionl)

Position i is the resi.ilt of executing the move

Move from the current Position. move((K,M),[NIN5],[NINs1]) -

K > 1, Kl is K-1, move((K1,M),Ns,Nsl). move1,N) [N INs] Ns). move((1,M),[NINs],[N1INs]) -

N > M, Nl is N-M. next_player(computer,opponent).

```prolog
next_player(opponent computer).
```

<!-- page 459 -->
Program 21.2 A program for playing a winning game of Nim nim_sum(Position,SoFar,Sum) - Sum is the nim-sum of the current Position, and SoFar is an accumulated value.

```prolog
nim_sum([NINs] ,Bs,Sum) -
    binary(N,Ds), nim_add(Ds,Bs,Bsl), nim_sum(Ns,Bsl,Sum).
nim_sum([ ] ,Sum,Sum).
nim_add(Bs,
           E I ,Bs).
nim_add([ ],Bs,Bs).
nim_add([BIBs] , [CICs] , [DIDs]) -
    D is (Bi-C) mod 2, nim_add(Bs,Cs,Ds).
binary(l, [1]).
binary(N,[DIDs]) -
    N > i, D is N mod 2, Nl is N/2, binary(Ni,Ds).
decimal(Ds,N) - decimal(Ds,O,l,N).
decimal([ ],N,T,N).
decimal([DIDs],A,T,N) -
    Al is A+D*T, Ti is T*2, decimal(Ds,A1,Ti,N).
zero([ J).
zero([OIZs]) - zero(Zs).
```

safe_move (Position,NimSum,Move) - Move is a move from the current Position with the value NimSum that leaves a safe position.

```prolog
safe_move(Piles,NimSum,Move) -
    safe_move(Piles,NimSum, i ,Move).
safe_move([PileIPiles] ,NimSum,K,(K,M)) -
    binary(Pile,Bs), can_zero(Bs,NimSum,Ds,O), decimal(Ds,M).
safe_move([PileIPiles] ,NimSum,K,Move)
    Kl is K+l, safe_move(Piles,NimSum,Kl,Move).
can_zero([ ],NimSum,[ ],O) -
    zero(NimSum).
can_zero([BIB5L[OlNimSuna],[CIDs],C) -
    can_zero (Es, NimSum , Ds , C).
can_zero([BIBs] , [ilNimSum] , [DIDs] ,C) -
    D is i-B*C, Cl is l-B, can_zero(Bs,NimSuxn,Ds,Ci).
```

Program 21.2

<!-- page 460 -->
(Continued) 000 Figure 21.2 Computmg mm-sums

The winning strategy is to always leave the position safe. Any unsafe position can be converted to a safe position (though not all moves do), while any move from a safe position creates an unsafe one. The best strategy is to make an arbitrary move when confronted with a safe position, hoping the opponent will blunder, and to convert unsafe positions to safe ones.

The current position is evaluated by the predicate `evaluate/3,` which determines the safety of the current position. An algorithm is needed to compute the nim-sum of a position. The nim-sum is checked by the predicate `safety(Sum,Safety),` which labels the position safe or unsafe depending on the value of `Sum.`

```prolog
choose_move (Position,computer, Move) -
    evaluate (Poition,Safety, Sum),
    decide_move (Saf ety, Position , Sum , Move)
```

The move made by the computer computed by `decide_move/4` depends on the safety of the position. If the position is safe, the computer makes the "arbitrary" move of one match from the first pile. If the position is unsafe, an algorithm is needed to compute a move that converts an unsafe position into a safe one. This is done by `safe_move/3.`

In a prior version of the program `evaluate` did not return `Sum.` In the writing of `safe_move` it transpired that the mm-sum was helpful, and it was sensible to pass the already computed value rather than recomputing it.

The nim-sum is computed by `nim_sum(Ns,SoFar,Suzn).` The relation computed is that `Sum` is the mm-sum of the numbers `Ns` added to what has been accumulated in `SoFar.` To perform the additions, the numbers must first be converted to binary, done by `biriary/2:`

```prolog
nìm_sum([N INs] ,Bs,Sum) -
    binary(N,Ds), nim_add(Ds,Bs,Bsl), nim_sum(Ns,Bsl,Sum).
```

<!-- page 461 -->
The binary form of a number is represented here as a list of digits. To overcome the difficulty of adding lists of unequal length, the least significant digits are earliest in the list. Thus 2 (in binary 10) is represented as [0,1], while 6 is represented as [0,1,1]. The two numbers can then be added from least significant digit to most significant digit, as is usual for addition. This is done by `nim_add/3` and is slightly simpler than regular addition, since no carry needs to be propagated. The code for both `binary` and `nim_add` appears in Program 21.2.

The nim-sum `Suni` is used by the predicate `safe_move (Ns ,Sum ,Move)` to find a winning move `Move` from the position described by `Ns.` The piles of matches are checked in turn by `safe_move/4` to see if there is a number of matches that can be taken from the pile to leave a safe position. The interesting clause is

```prolog
safe_move([PileIPiles] ,NimSuni,K,(K,M)) -
    binary(Pile,Bs), can_zero(Bs,NimSum,Ds,O), decimal(Ds,M).
```

The heart of the program is `can_zero(Bs,NimSum,Ds,Carry).` This relation is true if replacing the binary number `Bs` by the binary number `Ds` would make `NimSum` zero. The number `Ds` is computed digit by digit. Each digit is determined by the corresponding digit of `Bs, NimSum,` and a carry digit `Carry` initially set to 0. The number is converted to its decimal equivalent by `decimal/2` in order to get the correct move.

Program 21.2 is a complete program for playing Nim interactively incorporating the winning strategy. As well as being a program for playing the game, it is also an axiomatization of what constitutes a winning strategy.

21.3 Kalah We now present a program for playing the game of Kalah that uses alphabeta pruning. Kalah fits well into the paradigm of game trees for two reasons. First, the game has a simple, reasonably reliable evaluation function, and second, its game tree is tractable, which is not true for games such as chess and go. It has been claimed that some Kalah programs are unbeatable by human players. Certainly, the one presented here beats us.

<!-- page 462 -->
Kalah is played on a board with two rows of six holes facing each other. Each player owns a row of six holes, plus a kalah to the right of the holes. Ô

**Ô**

421 Game-Playing Programs::

**Ô**

**Ô**

Figure 21.3

Board positions for Kalah

In the initial state there are six stones in each hole and the two kalahs are empty. This is pictured in the top half of Figure 21.3.

A player begins his move by picking up all the stones in one of his holes. Proceeding counterclockwise around the board, he puts one of the picked-up stones in each hole and in his own kalah, skipping the opponent's kalah, until no stones remain to be distributed. There are three possible outcomes. If the last stone lands on the kalah, the player has another move. If the last stone lands on an empty hole owned by the player, and the opponent's hole directly across the board contains at least one stone, the player takes all the stones in the hole plus his last landed stone and puts them all in his kalah. Otherwise the player's turn ends, and his opponent moves.

The bottom kalah board in Figure 21.3 represents the following move from the top board by the owner of the top holes. He took the six stones in the rightmost hole and distributed them, the last one ending in the kalah, allowing another move. The stones in the fourth hole from the right were then distributed.

<!-- page 463 -->
If all the holes of a player become empty (even if it is not his turn to play), the stones remaining in the holes of the opponent are put in the opponent's kalah and the game ends. The winner of the game is the first player to get more than half the stones in his kalah.

The difficulty for programming the game in Prolog is finding an efficient data structure to represent the board, to facilitate the calculation of moves. We use a four-argument structure `board (Holes , Kalah, Opp-` `Holes, OppKalah),` where `Holes` is a list of the numbers of stones in your six holes, `Kalah` is the number of stones in your kalah, and `OppHoles` and `OppKalah` are, respectively, the lists of the numbers of stones in the opponent's holes and the number of stones in his kalah. Lists were chosen rather than six-place structures to facilitate the writing of recursive programs for distributing the stones in the holes.

A move consists of choosing a hole and distributing the stones therein. A move is specified as a list of integers with values between 1 and 6 inclusive, where the numbers refer to the holes. Hole i is farthest from the player's kalah, while hole 6 is closest. A list is necessary rather than a single integer because a move may continue. The move depicted in Figure 21.3 is [1,4].

The code gives all moves on backtracking. The predicate `stones_in_` `hole(M,Board,N)` returns the number of stones `N` in hole `M` of the `Board` if `N` is greater than O, failing if there are no stones in the hole. The predicate `ext end_move (M ,Board, N, Ms)` returns the continuation of the move `Ms.` The second clause for `move` handles the special case when all the player's holes become empty during a move.

Testing whether the move continues is nontrivial, since it may involve all the procedures for making a move. If the last stone is not placed in the kalah, which can be determined by simple arithmetic, the move will end, and there is no need to distribute all the stones. Otherwise the stones are distributed, and the move continues recursively.

The basic predicate for making a move is `distribute_stones (Stones,` `N ,Board, Board 1),` which computes the relation that `Board i` is obtained from `Board` by distributing the number of stones in `Stones` starting from hole number

`N.` There are two stages to the distribution, putting the stones in the player's holes, `distribute_my_holes,` and putting the stones in the opponent's holes, `distribute_your_holes.`

The simpler case is distributing the stones in the opponent's holes. The holes are updated by `distribute,` and the distribution of stones continues recursively if there is an excess of stones. A check is made to see if the player's board has become empty during the course of the move, and if so, the opponent's stones are added to his kalah.

<!-- page 464 -->
Distributing the player's stones must take into account two possibilities, distributing from any particular hole, and continuing the distribution for a large number of stones. The `pick_up_and_distribute` predicate is the generalization of `distribute` to handle these cases. The predicate `check_capture` checks if a capture has occurred and updates the holes accordingly; `update_kalah` updates the number of stones in the player's kalah. Some other necessary utilities such as `ri_substitute` are also included in the program.

The evaluation function is the difference between the number of stones in the two kalahs:

```prolog
value(board(H,K,Y,L),Value) - Value is K-L.
```

The central predicates have been described. A running program is now obtained by filling in the details for I/O, for initializing and terminating the game, etc. Simple suggestions can be found in the complete program for the game, given as Program 21.3.

[n order to optimize the performance of the program, cuts can be added. Another tip is to rewrite the main loop of the program as a failuredriven ioop rather than a tail recursive program. This is sometimes necessary in implementations that do not incorporate tail recursion optimization and a good garbage collector.

**21.4 Background**

The mastermind program, slightly modified, originally appeared in SIGART (Shapiro, 1983d) in response to a program for playing mastermind in Pascal. The SIGART article provoked several reactions, both of theoretical improvements to algorithms for playing mastermind and practical improvements to the program. Most interesting was an analysis and discussion by Powers (1984) of how a Prolog program could b rewritten to good benefit using the mastermind code as a case study. Eventually, speedup by a factor of 50 was achieved.

A proof of the correctness of the algorithm for playing Nim can be found in any textbook discussing games on graphs, for example, Berge (1962).

<!-- page 465 -->
Kalah was an early AI target for game-playing programs (Slagle and Dixon, 1969). Play framework

```prolog
play(Game)
             See Program 20.8.
```

Choosing a move by minimax with alpha-beta cutoff

```prolog
choose_move (Position,computer, Move)
    lookahead(Depth),
    alpha_beta(Depth,Position,-40,40,Move,Value),
    nl, write(Move), nl.
choose_move (Position,opponent, Move)
    nl, writeln(['please nake move']), read(Move), legal(Move).
alpha_beta(Depth,Position,Alpha,Beta,Move,Value)
```

See Program 20.11.

```prolog
move(Board, [MIMs])
    member(M, [1,2,3,4,5,6]),
    stones_in_hole (M,Board,N),
    extend_move (N ,M, Board, Ms)
nove(board([O,O,O,O,O,O],K,Ys,L),[]).
stones_in_hole(M,board(Hs,K,Ys,L),Stones)
    nth_nember(M,Hs,Stones), Stones > O.
extend_move(Stones,M,Board,[ J)
    Stones =\
              (7-M) nod 13,
extend_move(Stones ,M,Board,Ms)
    Stones
              (7-M) mod 13,
                            !,
    distribute_stones(Stones ,M,Board,Boardl),
    move(Boardl,Ms).
```

Executing a move

```prolog
move([N Nsj ,Board,FinalBoard)
    stones_in_hole (N, Bod,Stones),
    distribute_stones (Stones, N ,Board, Boardi),
    move (Ns, Boardi , FinalBoard).
move([ ],Boardl,Board2)
    swap(Eoardl ,Board2).
```

<!-- page 466 -->
distribute_stones (Stones,Hole,Board,Boardl) Boardi is the result of distributing the number of stones Stones from Hole from the current Board. It consists of two stages: distributmg the stones in the player's holes, distribute_my_holes, and distributing the stones in the opponent's holes, distribute_your_holes. Program 21.3 A complete program for playing Kalah distribute_stones(Stones,Hole,Board,FinalBoard) distribute_my_holes(Stones,Hole,Board,Boardl,Stonesl), distribute_your_holes (Stonesi ,Boardl ,FinalBoard). distribute_my_holes(Stones,N,board(Hs,K,Ys,L),

board(Hsl,Kl,Ys,L),Stonesl) - Stones > 7-N, pick_up_axid_distribute(N,Stones,Hs,Hsl), Kl is K+1, Stonesi is Stones-fN-7. dïstribute_my_holes(Stones,N,board(Hs,K,Ys,L),Board,O) - Stones

7-N, pïckup_ancLdistribute(N,Stones,Hs,Hsl), check_capture(N,Stones,Hsl,Hs2,Ys,Ysi,Pieces), update_kalah(Pieces,N,Stones,K,Kl) checkïffinished(board(Hs2,Kl,Ysl,L),Board). checkcapture(N,Stones,Hs,Hsl,Ys,Ysl,Pieces) Finishingllole is N+Stones, nth_rnernber(FinishingHole,Hs, 1), OppositeHole is 7-FinishingHole, ath_member (OppositeHole , Ys , Y), Y> O, I, n_substitute(OppositeHole,Ys ,O,Ysl) n_substitute (FinishingHole,Hs ,O,Hsl), Pieces is Y+l. check_capture(N,Stones,Hs,Hs,Ys,Ys,O) check.if_finished(board(Hs,K,Ys,L),board(Hs,K,Hs,Ll)) zero(Hs) ,

! , suinlist(Ys,YsSum) , Li is L-i-YsSum. check_iLfinished(board(Hs,K,Ys,L),board(Ys,Kl,Ys,L)) zero(Ys),

!, sunilist(Hs,HsSun), Kl is K+HsSum. check_if_f inished(Soard,Board) update_kalah(O,Stones,N,K,K) '- Stones < 7-N,

!. update_kalah(O,Stones,N,K,Kl) - Stones

7-N, !, Kl is K+l. update_kalah(Pieces,Stones,N,K,Kl) - Pieces > O,

, Kl is K+Pieces. distributeyour_holes(O,Board,Board) - ! distributeyour_holes(Stones,board(Hs,K,Ys,L),bosrd(Hs,K,Ysl,L)) i

Stones, Stones < 6, non_zero(Hs),

! distribute (Stones,Ys,Ysl) Program 21.3

<!-- page 467 -->
(Continued)

```prolog
distribute_your_holes (Stones ,board(Hs,K,Ys,L) ,Board) -
    Stones > 6,
                !,
    distribute(6,Ys,Ysl),
    Stonesi is Stones-6,
    distribute_stones(Stonesl ,O,board(Hs ,K,Ysi ,L) ,Board).
distribute_your_holes(Stones,board(Hs,K,Ys,L),board(Hs,K,Hs,Ll)) -
    zero(Hs),
              !, sumlist(Ys,YsSuni), Li is Stones+YsSum+L.
```

Lower-level stone distribution

```prolog
pick_up_and_distribute(O,N,Hs,Hsi) -
    !, distribute(N,Hs,Hsl).
pick_up_and_distribute(l,N, [HIHs] ,[OIHsi]) -
       distribute(N,Hs,Hsi).
pick_up_and_distribute(K,N,[HIHs] ,[HIHs1]) -
    K > i,
           !, Kl is K-1, pick_up_and_distribute(Kl,N,Hs,Hsi).
distribute(O,Hs,Hs) -
distribute(N, [HIHs] , [HhIHsl]) -
    N > O,
           !, Nl is N-i, Hl is H+l, distribute(Nl,Hs,Hsl).
distribute(N,[ ],[ ]) - L
```

Evaluation function

```prolog
value(board(H,K,Y,L),Value) - Value is K-L.
```

Testing for the end of the game

```prolog
game_over(board(O,N,O,N) ,Player,draw) -
    pieces(K), N
                    6*K,
game_over(board(H,K,Y,L) ,Player,Player) -
    pieces(N), K > 6*N,
                       !.
gameover(board(H,K,Y,L) ,Player,Opponent) -
    pieces(N), L > 6*N, next_player(Player,Opponent).
announce(opponent) - writeln( ['You won! Congratulations.']).
announce(computer) - writeln(['I won.']).
announce(draw) - writeln(['The game is a draw']).
```

Miscellaneous game utilities

```prolog
nthjnember(N, [HIHs] ,K) -
    N > 1,
           !, Ni is N-1, nthmember(Nl,Hs,K).
nthmember(l, [HIHs] ,H).
n_substitute(l, [XIXs] ,Y, [YIXs]) -
                                 !
n_substitute(N, [XXs] ,Y, [XIXs1]) -
    N > 1,
           !, Ni is N-1, n_substitute(Nl,Xs,Y,Xsi).
```

Program 21.3

<!-- page 468 -->
(Continued)

```prolog
next_player(computer opponent).
next_player (opponent ,computer).
legal([NINsJ) - O
                  <
                    N, N < 7, legal(Ns).
legal([ ]).
swap(board(Hs,K,Ys,L) ,board(Ys,L,Hs ,K)).
display_game (Position, computer)
    show (Posit ion)
display_game (Position, opponent)
    swap(Position,Positionl) ,
                            show(Positionl)
show(board(H,K,Y,L)) -
    reverse(H,HFt), write_stones(HR),
    write_kalahs(K,L) , write_stones(Y)
write_stones (H)
    nl, tab(5), display_holes(H).
display_holes( [H IHs]) -
    write_pile (H) ,
                  display_holes(Hs)
display_holes([ J) -
                     nl.
write_pile(N)
                N <
                    10, write(N), tab(4)
write_pile(N) - N
                    10, write(N), tab(3)
write_kalahs(K,L)
    write(K), tab(34), write(L), nl.
zero([O,O,0,0,O,O]).
non_zero(Hs) - Hs
                     [0,0,0,0,0,0]
```

Initializing

```prolog
lookahead(2).
initialize(kalali,board([N,N,N,N,N,N],O,[N,N,N,N,N,N],O),opponent) -
    pieces (N)
pieces (6).
```

Program 21.3

(Continued)
