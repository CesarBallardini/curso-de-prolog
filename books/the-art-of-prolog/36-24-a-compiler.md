# 24 A Compiler

<!-- page 500 -->
Our final application is a compiler. The program is presented top-down. The first section outlines the scope of the compiler and gives its defimtion. The next three sections describe the three major components: the parser, the code generator, and the assembler.

24.1 Overview of the Compiler The source language for the compiler is PL, a simplified version of Pascal designed solely for the purposes of this chapter. lt contains an assignment statement, an if-then-else statement, a while statement, and simple 1/O statements. The language is best illustrated with an example. Figure 24.1 contains a program for computing factorials written in PL. A formal definition of the syntax of the language is implicit in the parser in Program 24.1.

The target language is a machine language typical for a one-accumulator computer. Its instructions are given in Figure 24.2. Each instruction has one (explicit) operand, which can be one of four things: an integer constant, the address of a storage location, the address of a program instruction, or a value to be ignored. Most of the instructions also have a second implicit operand, which is either the accumulator or its contents. In addition, there is a pseudoinstruction block that reserves a number of storage locations as specified by its integer operand.

<!-- page 501 -->
The scope of the compiler is clear from its behavior on our example. Figure 24.3 is the translation of the PL program in Figure 24.1 into ma-

```prolog
program factorial;
    begin
        read value;
        count
                1;
        result
              :
                 1;
        while count < value do
           begin
               count
                        count+1;
               result := result*count
           end
        write result
    end
```

Figure 24.1 A PL program for computing factorials

```prolog
    Arithmetic
Literals
           Menory
                    Control
                               I/O, etc.
                               read
                    junpeq
addc
           add
                    jumpne
                               write
subc
           sub
                    jumplt
                               halt
mulc
           mul
                    junpgt
divc
           div
                    junple
loadc
           load
                    jumpge
                    jump
store
```

Figure 24.2

Target language instructions

chine language. The compiler produces the colunms labeled Instruction and Operand.

The task of compiling can be broken down into the five stages given in Figure 24.4. The first stage transforms a source text into a list of tokens. The list of tokens is parsed in the second stage, syntax analysis, to give a source structure. The third and fourth stages transform the source structure into relocatable code and assemble the relocatable code into absolute object code, respectively. The final stage outputs the object program.

<!-- page 502 -->
Our compiler implements the middle three stages. Both the first stage of lexical analysis and the final output stage are relatively uninteresting and are not considered here. The top level of the code handles syntax analysis, code generation, and assembly. Symbol Address Instruction

**Operand**

Symbol i READ

21

VALUE 2 LOADC

**i**

3 STORE

19

COUNT 4 LOADC

20 5 STORE

20

RESULT LABEL1 6 LOAD

19

COUNT 7 SUB

21

VALUE 8 JUMPGE

16

LABEL2 9 LOAD

19

COUNT 10 ADDC

1 11 STORE

19

COUNT 12 LOAD

20

RESULT 13 MUL

19

COUNT 14 STORE

20

RESULT 15 JUMP

6

LABEL1 LABEL2 16 LOAD

20

RESULT 17 WRITE

O 18 HALT

O COUNT 19 BLOCK

3 RESULT 20 VALUE 21 Figure 24.3 Assembiy code version of a factorial program

Object

Object

Structu re

Structure Token Source

(abso-

(relocat-

Object

Program List Source Structure Text

lute)

able) Lexical Syntax

Code

Assembly

Output Analysis Analysis

Generation Figure 24.4 The stages of compilation

**The basic predicate compile (Tokens,ObjectCode) relates a list of to-**

**kens Tokens to the ObjectCode of the program the tokens represent.**

**The compiler compiles correctly any legal PL program but does not han-**

**dle errors; that is outside the scope of this chapter. The list of tokens**

**is assumed to be input from some previous stage of lexical analysis.**

**The parser performing the syntax analysis, implemented by the predi-**

**cate parse, produces from the Tokens an internal parse tree Structure.**

<!-- page 503 -->
compile(Tokens,ObjectCode)

ObjectCode is the result of compilation of

a list of Tokens representing a PL program.

```prolog
compile (Tokens ,ObjectCode)
    parse (Tokens ,Structure),
    encode (Structure ,Dictionary,Code),
    assemble (Code ,Dictionary,ObjectCode).
```

The parser parse( Tokens,Structure) -

Structure represents the successfully parsed list of Tokens.

```prolog
parse (Source ,Structure)
    pl_program(Structure,Source\[ j).
p1_program(S)
             -
                [program], identifier(X), E';'], statement(S).
statement((S;Ss)) -
    [begin] ,
            statement(S), rest_statements(Ss).
statement(assign(X,V))
    identifier(X) , E' :'] ,
                          expression(V).
statement(if(T,Si,S2)) -
    [if] ,
          test(T), [then] ,
                          statement(S1), [else] ,
                                               statement(S2)
statement(while(T,S)) -
    [while] ,
            test(T) ,
                     [do] ,
                           statement(S)
statement(read(X)) -.
    [read] ,
           identifier(X)
statement(write(X)) -.
    [write] ,
            expression(X).
rest_statements((S;Ss)) -
                          [';'] ,
                                statement(S), rest_statements(Ss).
rest_statements(void)
                        [end]
expression(X) -e pl_constant(X).
expression(expr(Op,X,Y))
    pl_constant(X), arithmetic_op(Op), expression(Y).
arithmetic_op('+') -. ['+'j
arithmetic_op('-') -
                     E'-'].
arithmetic_op('*') -.
                     ['*'].
arithmetic_op('/') -
                     E'!'].
pl_constant(name(X)) -. identifier(X).
pl_constant(number(X)) -' pl_integer(X).
identifier(X) -'
                [X], {atom(X)}.
pl_integer(X) -'
                EX],
                     {integer(X)}.
test(compare(Op,X,Y)) -
    expression(X), comparison_op(Op), expression(Y).
```

<!-- page 504 -->
Program 24.1 A compiler from PL to machine language

```prolog
comparison_opY=') -
cornparison_op(')
                     [''].
comparison_opY>') . ['>'1.
comparison_opY<')
                     ['<'J.
comparison_op('') . ['>']
comparison_op('')
                     [''].
The code generator
encode C Stru cture,Dictionary,RelocatableCode) -
```

Relocatable Code is generated from the parsed Structure building a Dictioriry associating variables with addresses.

```prolog
encode((X;Xs),D,(Y;Ys)) -
    encode(X,D,Y), encode(Xs,D,Ys).
encode(void,D,no_op).
encode(assign(Name,E),D,(Code; instr(store,Address))) -
    lookup(Name,D,Address) ,
                          encode_expression(E,D,Code)
encode(if(Test,Then,Else) ,D,
    (TestCode; ThenCode; instr(jump,L2);
    label (Li); ElseCode; label(L2))) -
       encode_test (Test ,L1 ,D ,TestCode)
       encode (Then,D ,ThenCode),
       encode (Else,D,ElseCode)
encode (wliile(Test,Do) ,D,
    (label(L1); TestCode; DoCode; instr(jump,L1); label(L2))) -
       encode_test(Test,L2,D,TestCode), encode(Do,D,DoCode).
encode(read(X) ,D,instr(read,Address))
    lookup(X,D,Address).
encode(write(E),D,(Code; instr(write,O)))
    encode_expression(E,D,Code).
```

encode_expression (Expression,Dictionary, Code) - Code corresponds to an arithmetic Expression.

```prolog
encode_expression(number(C) ,D,ïnstr(loadc,C)).
encode_expression(nanie(X),D,instr(load,Address))
    lookup(X,D,Address)
encode_expression(expr(Op,E1,E2),D,(Load;Instruction))
    single_instruction(Op,E2,D,Instruction),
    encode_expression(E1 ,D,Load).
encode_expression(expr(Dp,Ei,E2) ,D,Code) -
    not sïngle_instruction(Op,E2,D,Instructïon)
    single_operation(Op,E1 ,D,E2Code,Code),
    encode_expression(E2,D,E2Code).
```

Program 24.1

<!-- page 505 -->
(Continued)

```prolog
single_instruction(Op,nuinber(C),D,instr(OpCode,C)) -
    literal_operation(Op,OpCode).
single_instruction(Op,naine(X),D,instr(OpCode,A)) -
    memory_operation(Op,OpCode), lookup(X,D,A).
single_operation(Op,E,D,Code, (Code; Instruction)) -
    coinmutative(Op), single_instruction(Op,E,D,Instruction).
single_operation (Op. E, D ,Code,
        (Code;instr(store,Address);Load;instr(OpCode,Addressfl) -
    not commutative(Op),
    lookupC$temp' ,D,Address),
    encode_expression(E,D,Load),
    op_code (E , Op , OpCode)
op_code(number(C) ,Op,OpCode) - literal_operation(Op,OpCode).
op_code(name(X) ,Op,OpCode) - niemory_operation(Op,OpCode).
literal_operation('+' ,addc).
                              memory_operationY+' ,add).
literal_operation('-' ,subc).
                              memory_operationY-' sub).
literal_operation('*' ,mulc).
                              memory_operationY*' mul).
literal_operationY/' ,divc).
                              memory_operationY/' div).
comlnutative('-*').
                               cominutative('*).
encode_test (compare(Op,E1 E2) Label,D,
        (Code; instr(OpCode ,Label))) -
    coniparison_opcode (Op OpCode)
    encode_expression(exprY' ,Ei,E2) ,D,Code).
comparison_opcode('=' jumpne).
                                comparison_opcode('
                                                    ' ,jumpeq).
comparison_opcodeY>' ,jumple).
                                comparison_opcode('' ,jumplt).
comparison_opcodeY<' ,jumpge).
                                comparison_opcode('' jumpgt).
lookup(Naine,Dictionary,Address) - See Program 15.9.
```

The assembler assemble ( Code,Dictionary, TidyCode) -

TidyCode is the result of assembling Code removing

no_Ups and labels, and filling in the Dictionary.

```prolog
assemble(Code Dictionary,TidyCode) -
    tidy_and_count (Code, 1 N,TidyCode\(instr(halt 0) ;block(L)))
    Ni is N+i,
    allocate (Dictionary,Nl,N2),
    L is N2-N1, L
tidy_and_count((Codei ;Code2) M,N,TCodel\TCode2) -
    tidy_and_count(Codel,M,M1,TCodel\Rest),
    tidy_and_count(Code2,Mi N,Rest\TCode2).
tidy_and_count(instr(X,Y),N,Ni,(instr(X,Y);Code)\Code) -
    Nl is N+l.
tidy_and_count (label (N) N N, Code\Code).
tidy_and_count (no_op ,N, N, Code\Code)
```

Program `24.1`

<!-- page 506 -->
(Continued)

```prolog
allocate(void,N,N).
allocate(dict(Name,N1,Before,After),N0,N)
    allocate (Bef ore ,NO , Nl)
    N2 is Ni1,
    allocate (After,N2,N)
```

Program 24.1

(Continued)

```prolog
test_compiler(X,Y)
    proram(X,P) ,
                 compile(P,Y)
program(testl, [program,testl,' ;
                               ,begïn,write,
    x
       + ' , y ,
            - '
               , z ,
                 ' / ' , 2 , end]
prograxn(test2, [prograni,test2,' ;',
    begin,if,a,'>' ,b,then,max, :' ,a,else,max, :' ,b,end])
prograni(factorial,
    [prograin,factorial,
                       ;'
    ,begin
        ,read,value,'
        ,count , :=' , 1,';'
        ,result,
                :=' ,1, (;)
        ,while,count,'<' ,value,do
            ,begin
               ,count,
                          ,count, '+' 1,
               ,result,
                        :=
                           ,result, 't' ,count
           end, '
        ,write, result
    ,end])
```

Program 24.2

Test data The structure is used by the code generator encode to produce relocatable code Code. A dictionary associating variable locations to memory addresses and keeping track of labels is needed to generate the code. This is the second argument of encode. Finally, the relocatable code is assembled into object code by assemble with the aid of the constructed Dictionary.

<!-- page 507 -->
The testing data and instructions for the program are given as Program 24.2. The program factorial is the PL program of Figure 24.1 translated into a list of tokens. The two small programs consist of a single statement each, and test features of the language not covered by the factorial example. The program testi tests compilation of a nontrivial arithmetic expression, and test2 checks the if-then-else statement. 24.2 The Parser The parser proper is written as a definite clause grammar, as described in Chapter 19. The predicate `parse` as given in Program 24.1 is just an interface to the DCG, whose top-level predicate is `p1_program.` The DCG has a single argument, the structure corresponding to the statements, as described later. A variant of Program 18.9 is assumed to translate the DCG into Prolog clauses. The convention of that program is that the last argument of the predicates defined by the DCG is a difference-list:

```prolog
parse (Source ,Structure) -
    pl_program(Structure,Source\[ 1).
```

The first statement of any PL program must be a program statement. A program statement consists of the word program followed by the name of the program. We call words that must appear for rules of the grammar to apply standard identifiers, the word program being an example. The name of the program is an identifier in the language. What constitutes identifiers, and more generally constants, is discussed in the context of arithmetic expressions. The program name is followed by a semicolon, another standard identifier, and then the program proper begins. The body of a PL program consists of statements or, more precisely, a single statement that may itself consist of several statements. All this is summed up in the top-level grammar rule:

```prolog
p1_program(S) -
     [program], identifier(X), [C;] ,
                                         statement(S).
```

The structure returned as the output of the parsing is the statement constituting the body of the program. For the purpose of code generation, the top-level program statement has no significance and is ignored in the structure built.

<!-- page 508 -->
The first statement we describe is a compound statement. Its syntax is the standard identifier `begin` followed by the first statement, S, say, in the compound statement, and then the remaining statements Ss. The structure returned for a compound statement is (S; Ss), where ; is used as a two-place infix functor. Note that S, Ss, or both may be compound statements or contain them. The semicolon is chosen as functor to echo its use in PL for denoting sequencing of statements:

```prolog
statement ( (S; Ss) )
     [begin] ,
              statement(S), rest_statements(Ss).
```

Statements in PL are delimited by semicolons. The rest of the statements are accordingly defined as a semicolon followed by a nonempty statement, and recursively the remaining statements:

```prolog
rest_statements((S;Ss))
                           -.
     E';'],
             tatement(S), rest_statements(Ss).
```

The end of a sequence of statements is indicated by the standard identifier `end.` The atom `void is` used to mark the end of a statement in the internal structure. The base case of `rest_statements` is therefore

```prolog
rest_statements(void) -.
                           [end]
```

The above definition of statements precludes the possibility of empty statements. Programs and compound statements in PL cannot be empty.

The next statement to discuss is the assignment statement. It has a simple syntactic definition - a left-hand side, followed by the standard identifier is, followed by the right-hand side. The left-hand side is restricted to being a PL identifier, and the right-hand side is any arithmetic expression whose definition is to be given:

```prolog
statement(assign(X,E))
    identifier(X), [':='], expression(E).
```

The structure returned by the successful recognition of an assignment statement has the form `assign(X,E).` The (Prolog) variable `E` represents the structure of the arithmetic expression, and X is the name of the (PL) variable to be assigned the value of the expression. It is implicitly assumed that X will be a PL identifier.

For simplicity of both code and explanation, we restrict ourselves to a subclass of arithmetic expressions. Two rules define the subclass. An expression is either a constant or a constant followed by an arithmetic operator and recursively an arithmetic expression. Examples of expressions in the subclass are x, 3, 2 . t and x + y - z/2, the expression in the first test case in Program 24.2:

```prolog
expression(X) -. pl_constant(X).
expression(expr(Op,X,Y)) -.
    pl_constant(X), arithxnetic_op(Op), expression(Y).
```

<!-- page 509 -->
This subclass of expressions does not respect the standard precedence of arithmetic operators. The expression x . 2 + y is parsed as x (2 + y). On the other hand, the expression x + y - z/2 is interpreted unambiguously as x + (y - (z/2)).

For this example, we restrict ourselves to two types of constants in PL: identifiers and integers. The specification of `p1_constant` duly consists of two rules. Which of the two is found is reflected in the structure returned. For identifiers X, the structure `name (X)` is returned, whereas `number (X)` is returned for the integer X:

```prolog
pl_constant(name(X)) - identifier(X).
pl_constant(number(X)) -. pl_integer(X).
```

For simplicity we assume that PL integers and PL identifiers are Prolog integers and atoms, respectively. This allows the use of Prolog system predicates to identify the PL identifiers and integers. Recall that the curly braces notation of DCGs is used to specify Prolog goals:

```prolog
identifier(X)
                   [X], {atom(X)}.
pl_integer(X) -
                   [X], {integer(X)}.
```

In fact, all grammar rules that use PL identifiers and constants could be modified to call the Prolog predicates directly if greater efficiency is needed.

A list of arithmetic operators is necessary to complete the definition of arithmetic expressions. The form of the statement for addition, represented by +, follows. The grammar rules for subtraction, multiplication, and division are analogous, and appear in the full parser in Program 24.1:

```prolog
arithmetic_op(+')
                        [C]
```

The next statement to be discussed is the conditional statement, or if-then-else. The syntax for conditionals is the standard identifier `if` followed by a test (to be defined). After the test, the standard identifier `then` is necessary, followed by a statement constituting the then part, the standard identifier `else` and a statement constituting the else part, in that order. The structure built by the parser is `if (T,Si , S2),` where T is the test, Si is the then part, and `S2` is the else part:

```prolog
statement(if(T,Si,S2))
     [if], test(T), [then], statement(Si),
     [else], statement(S2).
```

<!-- page 510 -->
Tests are defined to be an expression followed by a comparison operator and another expression. The structure returned has the form compare (Op , X, Y), where Op is the comparison operator, and X and Y are the left-hand and right-hand expressions in the test, respectively: test(compare(Op,X,Y)) -.

```prolog
expression(X), comparison_op(Op), expression(Y).
```

The definition of comparison operators using the predicate comparison_op is analogous to the use of arithmetic_op to define arithmetic operators. Program 24.1 contains definitions for =,

**, >, <,, and**

.

While statements consist of a test and the action to take if the test is true. The structure returned is while(T,S), where T is the test and S `is` the action. The syntax is defined by the following rule: statement(while(T,S)) -.

```prolog
[while], test(T), [do], statement(S).
```

I/O is handled `in PL with a simple read` statement and a simple write statement. The input statement consists of the standard identifier read followed by a PL identifier; it returns the structure read(X), where X is the identifier. Write statements are similar:

```prolog
statement(read(X)) -.
                        [read], identifier(X).
statement(write(X)) -
                         [write], expression(X).
  Collecting the various pieces of the DCG just described gives a parser
```

for the language. Note that ignoring the arguments in the DCG gives a formal BNF grammar for PL.

Let us consider the behavior of the parser on the test data in Program 24.2. The parsed structures produced for the two single statement programs have the form (structure) ;void, where (structure) represents the parsed statement. The write statement is translated to

```prolog
write(expr(+,name(x),expr(-,name(y),expr(/,name(z),
    nuinber(2))))),
and the if-then-else statement is translated to
```

`if (compare` (> ,riame (a) ,name (b)) , `assign(max` name (a) )

```prolog
assign(max,name(b))).
```

<!-- page 511 -->
The factorial program is parsed into a sequence of five statements followed by void. The output after parsing for all three test programs is Program testi:

```prolog
write(expr(+,nanie(x) ,expr(-,name(y),
    expr(/,name(z) ,nuniber(2)flfl;void
```

Program test2:

```prolog
if(compare(>,name(a) ,name(b)),assign(max,naine(a)),
    assign(max,name(bfl) ;void
```

Program test3:

read(value);assign(count,number(lfl;assign(result,number(lfl;

```prolog
while(compare(< ,name(count) ,name(value)),
(assign(count,expr(+,name(count),number(1)));
assign(result,expr(*,name(result),nanie(count)fl;void));
write(name(result)) ;void
```

Figure 24.5

Output from parsing

given in Figure 24.5. This is the input for the second stage of compilation, code generation.

**24.3 The Code Generator**

The basic relation of the code generator is `encode (Structure,Dictio-` `nary ,Code),` which generates `Code` from the `Structure` produced by the parser. This section echoes the previous one. The generated code is described for each of the structures produced by the parser representing the various PL statements.

`Dictionary` relates PL variables to memory locations, and labels to instruction addresses. The dictionary is used by the assembler to resolve locations of labels and identifiers. Throughout this section D refers to this dictionary. An incomplete ordered binary tree is used to implement it, as described in Section 15.3. The predicate `lookup(Name,D,Value)` (Program 15.9) is used for accessing the incomplete binary tree.

<!-- page 512 -->
The structure corresponding to a compound statement is a sequence of its constituent structures. This is translated into a sequence of blocks of code, recursively defined by `encode.` The functor ; is used to denote sequencing. The empty statement denoted by `void` is translated into a null operation, denoted `no_op.` When the relocatable code is traversed during assembly this "pseudoinstruction" is removed.

The structure produced by the parser for the general PL assignment statement has the form `assign(Name,Expression),` where `Expression` is the expression to be evaluated and assigned to the PL variable `Name.` The correspondmg compiled form calculates the expression followed by a `store` instruction whose argument is the address corresponding to `Name.` The representation of individual instructions in the compiled code is the structure `instr(X,Y),` where X is the instruction and Y is the operand. The appropriate translation of the `assign` structure is therefore `(Code; instr(store,Address)),` where `Code` is the compiled form of the expression, which, after execution, leaves the value of the expression in the accumulator. It is generated by the predicate `encode_`

```prolog
expression(Expression, D, ExpressionCode), Encoding the assignment
```

statement is performed by the clause

```prolog
ericode(assign(Name,Expression) ,D,(Code;instr(store,Address)))
    - lookup(Name ,D,Address), encode....expression(Expression,
            D,Code).
```

This clause is a good example of Prolog code that is easily understood declaratively but hides complicated procedural bookkeeping. Logically, relations have been specified between `Name` and `Address,` and between `Expression` and `Code.` From the programmer's point of view it is irrelevant when the final structure is constructed, and in fact the order of the two goals in the body of this clause can be swapped without changing the behavior of the overall program. Furthermore, the `lookup` goal, in relating `Name` with `Address,` could be making a new entry or retrieving a previous one, where the final instantiation of the address happens in the assembly stage. None of this bookkeeping needs explicit mention by the programmer. It goes on correctly in the background.

There are several cases to be considered for compiling the expression. Constants are loaded directly; the appropriate machine instruction is `loadc C,` where C is the constant. Similarly identifiers are compiled into the instruction `load A,` where `A` is the address of the identifier. The two corresponding clauses of `encode_expression` are

```prolog
encode_expression(nuniber(C) ,D,instr(loadc,C)).
encode_expression(name(X) ,D,instr(load,Address)) -
    lookup(X,D,Address).
```

<!-- page 513 -->
The general expression is the structure expr (Op ,El , E2), where Op is the operator, El is a PL constant, and E2 is an expression. The form of the compiled code depends on E2. If it is a PL constant, then the final code consists of two statements: an appropriate load instruction determined recursively by encode_expression and the single instruction corresponding to Op. Again, it does not matter in which order the two instructions are determined. The clause of encode_expression is encode_expression(expr(Op,El,E2),D, (Load;Instruction)) -

```prolog
single_instruction(Op,E2,D, Instruction),
encode_expression(El ,D,Load).
```

The nature of the single instruction depends on the operator and whether the PL constant is a number or an identifier. Numbers refer to literal operations, and identifiers refer to memory operations: single_instruction(Op,nuniber(C) ,D,instr(Opcode,C)) -

```prolog
literal_operation(Op , Opcode).
```

single_instruction(Op,name(X) ,D,instr(Opcode,A)) -

```prolog
meniory_operation(Op,Opcode), lookup(X,D,A).
```

A separate table of facts is needed for each sort of operation. The respective form of the facts is illustrated for +: literal_operation(+ , addc).

```prolog
mernory_operation(+ ,add).
```

A separate calculation is necessary when the second expression is not a constant and caimot be encoded in a single instruction. The form of the compiled code is determined from the compiled code for calculating E2, and the single operation is determined by Op and El: encode_expression(expr(Op,El,E2) ,D,Code) -

not single_instruction(Op,E2,D,Instruction),

```prolog
single_operation(Op El, D, E2Code ,Code),
encode_expression(E2,D,E2Code).
```

<!-- page 514 -->
In general, the result of calculating E2 must be stored iii some temporary location, called $telnp in the following code. The sequence of instructions is then the code for E2, a store instruction, a load instruction for El, and the appropriate memory operation addressing the stored contents. The predicates shown previously are used to construct the final form of the code: single_operation(Op, E, D ,Code,

(Code;

```prolog
instr(store,Address);
Load;
instr (OpCode ,Address))
    not cornmutative(Dp),
    lookup('$temp' ,D,Address),
    encode_expression (E,D,Load),
    op_code (E,Op,OpCode).
```

An optimization is possible if the operation is commutative, e.g., addition or multiplication, which circumvents the need for a temporary variable. In this case, the memory or literal operation can be performed on El, assuming that the result of computing E2 is in the accumulator: single_operation(Op,E,D,Code, (Code;Instruction)) -

```prolog
cominutative(Op), single_instruction(Op,E,D,Instruction).
```

The next statement is the conditional if-then-else parsed into the structure if(Test,Then,Else). To compile the structure, we have to introduce labels to which instructions can jump. For the conditional we need two labels marking the beginning and end of the else part respectively. The labels have the form label (N), where N is the address of the instruction. The value of N is filled in during the assembling stage, when the label statement itself is removed. The schematic of the code is given by the third argument of the following encode clause: encode(if(Test,Then,Else) ,D,

(TestCode;

ThenCode;

```prolog
instr(junip,L2);
label (Li);
ElseCode;
label(L2))
    encode_test (Test ,Li , D, TestCode),
     encode (Then,D ,ThenCode),
     encode (Else, D, ElseCode).
```

<!-- page 515 -->
In order to compare two arithmetic expressions, we subtract the second from the first and make the jump operation appropriate to the particular comparison operator. For example, if the test is whether two expressions are equal, we circumvent the code if the result of subtracting the two is not equal to zero. Thus comparison_opcode(c=

```prolog
,jumpne) is a
```

fact. Note that the label that is the second argument of `encode_test is` the address of the code following the test.

```prolog
encode_test(compare(Op,E1,E2) ,Label,D,
         (Code; instr(OpCode,Label)))
    comparison_opcode(Op,DpCode),
    encode_expression(expr('-' ,E1,E2),D,Code).
```

The next statement to consider is the while statement. The statement is parsed into the structure `while (Test, Statements). A` label is necessary before the test, then the test code is given as for the if-then-else statement, then the body of code corresponding to `Statements` and a jump to reperform the test. `A` label is necessary after the `jump` instruction for when the test fails.

```prolog
encode (while (Test,Do) ,D,
     (label (Li);
    TestCode;
    DoCode;
    instr(jump,L1);
    label(L2))
)
         encode_test (Test ,L2,D,TestCode),
         encode (Do, D, DoCode).
```

The I/O statements are straightforward. The parsed structure for input, `read (X),` is compiled into a single `read` instruction, and the table is used to get the correct address:

```prolog
encode (read(X) ,D,instr(read,Address)) -
    lookup(X,D,Address).
```

The output statement is translated into encoding an expression and then a `write` instruction:

```prolog
encode(write(E) ,D, (Code; instr(write,O))) -
    encode_expression(E,D,Code).
```

<!-- page 516 -->
Program testi

((instr(load,Z);instr(divc,2fl;instr(store,Teuip);

```prolog
instr(load,Y);instr(sub,Ternp));instr(add,X));
instr(write 0)); no_op
```

Program test2:

(((instr(load,A);instr(sub,B));ïnstr(jumple,Llfl;

(instr(load,A);instr(store,Max));instr(juxnp,L2);label(L1);

(instr(load,B);instr(store,Max));label(L2));no_op Program factorial: instr(read,Value); (instr(loadc,1);ïnstr(store,Count));

(instr(loadc,i);instr(store,Result)); (label (Li);

((instr(load,Count);instr(sub,Value));instr(jumpge,L2));

(((instr(load,Count);instr(addc,i));instr(store,Count));

((instr(load,Result);iritr(mul,Countfl;instr(store,Resultfl;

no_op) ;instr(jwnp,Li);label(L2)) ;(instr(load,Result);

instr(write,0));no_op Figure 24.6 The generated code

Figure 24.6 contains the relocatable code after code generation and before assembly for each of the three examples of Program 24.2. Mnemonic variable names have been used for easy reading.

**24.4 The Assembler**

<!-- page 517 -->
The final stage performed by the compiler is assembling the relocatable code into absolute object code. The predicate `assemble(Code,Dictio-` `nary, ObjectCode)` takes the. `Code` and `Dictionary` generated in the previous stage and produces the object code. There are two stages in the assembly. During the first stage, the instructions in the code are counted, at the same time computing the addresses of any labels created during code generation and removing unnecessary null operations. Tuis tidied code is further augmented by a halt instruction, denoted by `instr(halt,O),` and a block of L memory locations for the L PL variables and temporary locations in the code. The space for memory locations is denoted by block (L). In the second stage, addresses are created for the PL and temporary variables used in the program:

```prolog
assemble(Code,Dictionary,TidyCode) -
   tidy_and_count(Code,1,N,TidyCode\(instr(halt,O) ;block(L))),
   Nl is N+1,
   allocate (Dictionary ,Nl, N2),
   L is N2-N1,
                 !.
  The predicate tidy_and_count(Code,M,N,TidyCode) tidies the Code
```

into `TidyCode,` where the correct addresses of labels have been filled in and the null operations have been removed. Procedurally, executing `tidy_and_count` constitutes a second pass over the code. `M` is the address of the begimiing of the code, and `N` is i more than the address of the end of the original code. Thus the number of actual instructions in `Code is N+1-M. TidyCode` is represented as a difference-structure based on;

The recursive clause of `tidy_and_count` demonstrates both standard difference-structure technique and updating of numeric values:

```prolog
tidy_and_count((Codel;Code2) ,M,N,TCodel\TCode2) -
     tidy_and_count (Codel ,M,M1 ,TCodel\Rest),
     tidy_and_count (Code2 ,Ml , N, Rest\TCode2).
```

Three types of primitives occur in the code: instructions, labels, and no_ops. Instructions are handled routinely. The address counter is incremented by 1, and the instruction is inserted into a difference-structure:

```prolog
tidy_and_count(instr(X,Y),N,N1,(instr(X,Y);Code)\Code) -
    Nl is N+1.
```

Both labels and no_ops are removed without updating the current address or adding an instruction to the tidied code:

```prolog
tidy_and_count(label(N) ,N,N,Code\Code).
tidy_and_count(no_op,N,N,Code\Code).
```

Declaratively, the clauses are identical. Procedurally, the unification of the label number with the current address causes a major effect in the program. Every reference to the label address is filled in. This program is another illustration of the power of the logical variable.

<!-- page 518 -->
The predicate `allocate(Dictionary,M,N)` has primarily a procedural interpretation. During the code generation as the dictionary is constructed, storage locations are associated with each of the PL variables Program testi:

```prolog
instr(load,11);instr(divc,2);instr(store,12);instr(load,1O);
instr(sub,12);instr(add,9);instr(write,O);instr(halt,O);block(4)
```

Program test2:

```prolog
instr(load,1O);instr(sub,11);instr(jumple,7);instr(load,1O);
instr(store, 12) ; iristr(jurnp,9) ïnstr(load, 11) instr(store, 12)
instr(halt 0) ;block(3)
```

Program factorial:

```prolog
instr(read,21);instr(loadc,1);instr(store,19);instx(loadc,1);
instr(store,20);instr(load,19);instr(sub,21);instr(jumpge,16);
instr(load,19);instr(addc,1);instr(store,19);instr(load,20);
instr(mul,19);instr(store,20);instr(junip,6);instr(load,20);
instr(write,0) instr(halt »0) ;block(3)
```

Figure 24.7 The compiled object code

in the program, plus any temporary variables needed for computing expressions. The effect of `allocate` is to assign actual memory locations for the variables and to fill in the references to them in the program.

The variables are found by traversing the `Dictionary. M` is the address of the memory location for the first variable, and `N` is i more than the address of the last. The order of variables is alphabetic corresponding to their order in the dictionary. The code also completes the dictionary as a data structure.

```prolog
allocate(void,N,N).
allocate(dict(Name,N1,Before,After) ,NO,N)
    allocate (Bef ore,NO,N1),
    N2 is N1+1,
    allocate(After,N2,N).
```

Because the dictionary is an incomplete data structure, the predicate `allocate` can succeed many times. The variables at the end of the tree match both the fact and the recursive clause. For the compiler, the easiest way to stop multiple solutions is to add a cut to the clause for `assem-` `ble/3,` which conmits to the first (and minimal) assignment of memory locations for variables.

<!-- page 519 -->
The compiled versions of the test programs given in Program 24.2 appear in Figure 24.7. Exercises for Chapter 24

(i) Extend the compiler so that it handles repeat loops. The syntax is repeat (statement) until (test). Extensions to both the parser and the compiler need to be made. Test the program on the following:

```prolog
program repeat;
    begin
         i
           :
              1;
         repeat
         i begin
         ii write(i);
         ii i
                  i+1
         i end
         until i = 11
    end.
```

(ii) Extend the definition of arithmetic expressions to allow arbitrary ones. In the encoder, you will have to cater for the possibility of needing several temporary variables.

**24.5 Background**

The compiler described is based on a delightful paper by Warren (1980).
