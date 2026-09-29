# Programming in Tabled Prolog — front matter

**Programming in Tabled Prolog\
(very) DRAFT <a href="#footnode.html_foot97" id="book.html_tex2html1"><sup>1</sup></a>**
========================================================================================

**\

*David S. Warren*\

Department of Computer Science\
SUNY @ Stony Brook\
Stony Brook, NY 11794-4400, U.S.A.\
\**

**July 31, 1999**

------------------------------------------------------------------------

- <a href="#node1.html" id="book.html_tex2html20">Contents</a>
- <a href="#node2.html" id="book.html_tex2html21">Background and Motivation</a>
- <a href="#node3.html" id="book.html_tex2html22">Introduction to Prolog</a>
  - <a href="#node4.html" id="book.html_tex2html23">Prolog as a Procedural Programming Language</a>
    - <a href="#node5.html" id="book.html_tex2html24">Assign-once Variables</a>
    - <a href="#node6.html" id="book.html_tex2html25">Nondeterminism</a>
      - <a href="#node7.html" id="book.html_tex2html26">Prolog execution as the execution of multiple machines</a>
    - <a href="#node8.html" id="book.html_tex2html27">Executing Programs in XSB</a>
    - <a href="#node9.html" id="book.html_tex2html28">The Scheduling of Machine Execution in Prolog</a>
  - <a href="#node10.html" id="book.html_tex2html29">Grammars in Prolog</a>
  - <a href="#node11.html" id="book.html_tex2html30">Prolog as a Database Query Langauge</a>
  - <a href="#node12.html" id="book.html_tex2html31">Deductive Databases</a>
  - <a href="#node13.html" id="book.html_tex2html32">Summary</a>
- <a href="#node14.html" id="book.html_tex2html33">Tabling and Datalog Programming</a>
  - <a href="#node15.html" id="book.html_tex2html34">XSB tabled execution as the execution of concurrent machines</a>
  - <a href="#node16.html" id="book.html_tex2html35">More on Transitive Closure</a>
  - <a href="#node17.html" id="book.html_tex2html36">Other Datalog Examples</a>
  - <a href="#node18.html" id="book.html_tex2html37">Some Simple Graph Problems</a>
  - <a href="#node19.html" id="book.html_tex2html38">Genome Examples</a>
  - <a href="#node20.html" id="book.html_tex2html39">Inferring When to Table</a>
    - <a href="#node21.html" id="book.html_tex2html40">On the Complexity of Tabled Datalog Programs</a>
  - <a href="#node22.html" id="book.html_tex2html41">Datalog Optimization in XSB</a>
- <a href="#node23.html" id="book.html_tex2html42">Grammars</a>
  - <a href="#node24.html" id="book.html_tex2html43">An Expression Grammar</a>
  - <a href="#node25.html" id="book.html_tex2html44">Representing the Input String as Facts</a>
  - <a href="#node26.html" id="book.html_tex2html45">Mixing Tabled and Prolog Evaluation</a>
  - <a href="#node27.html" id="book.html_tex2html46">So What Kind of Parser is it?</a>
  - <a href="#node28.html" id="book.html_tex2html47">Building Parse Trees</a>
  - <a href="#node29.html" id="book.html_tex2html48">Computing First Sets of Grammars</a>
  - <a href="#node30.html" id="book.html_tex2html49">Linear Parsing of LL(k) and LR(k) Grammars</a>
  - <a href="#node31.html" id="book.html_tex2html50">Parsing of Context Sensitive Grammars</a>
- <a href="#node32.html" id="book.html_tex2html51">Automata Theory in XSB</a>
  - <a href="#node33.html" id="book.html_tex2html52">Finite State Machines</a>
    - <a href="#node34.html" id="book.html_tex2html53">Intersection of FSM's</a>
    - <a href="#node35.html" id="book.html_tex2html54">Epsilon-free FSM's</a>
    - <a href="#node36.html" id="book.html_tex2html55">Deterministic FSM's</a>
    - <a href="#node37.html" id="book.html_tex2html56">Complements of FSM's</a>
    - <a href="#node38.html" id="book.html_tex2html57">Minimization of FSM's</a>
    - <a href="#node39.html" id="book.html_tex2html58">Regular Expressions</a>
  - <a href="#node40.html" id="book.html_tex2html59">Push-Down Automata</a>
- <a href="#node41.html" id="book.html_tex2html60">Dynamic Programming in XSB</a>
  - <a href="#node42.html" id="book.html_tex2html61">The Knap-Sack Problem</a>
  - <a href="#node43.html" id="book.html_tex2html62">Sequence Comparisons</a>
  - <a href="#node44.html" id="book.html_tex2html63">??</a>
- <a href="#node45.html" id="book.html_tex2html64">HiLog Programming</a>
  - <a href="#node46.html" id="book.html_tex2html65">Generic Programs</a>
  - <a href="#node47.html" id="book.html_tex2html66">Object Centered Programming in XSB with HiLog</a>
- <a href="#node48.html" id="book.html_tex2html67">Debugging Tabled Programs</a>
- <a href="#node49.html" id="book.html_tex2html68">Aggregation</a>
  - <a href="#node50.html" id="book.html_tex2html69">Min, Max, Sum, Count, Avg</a>
  - <a href="#node51.html" id="book.html_tex2html70">BagReduce and BagPO</a>
  - <a href="#node52.html" id="book.html_tex2html71">Recursive Aggregation</a>
    - <a href="#node53.html" id="book.html_tex2html72">Shortest Path</a>
    - <a href="#node54.html" id="book.html_tex2html73">Reasoning with Uncertainty: Annotated Logic</a>
    - <a href="#node55.html" id="book.html_tex2html74">Longest Path</a>
  - <a href="#node56.html" id="book.html_tex2html75">Scheduling Issues</a>
  - <a href="#node57.html" id="book.html_tex2html76">Stratified Aggregation</a>
- <a href="#node58.html" id="book.html_tex2html77">Negation in XSB</a>
  - <a href="#node59.html" id="book.html_tex2html78">Stratified Negation</a>
  - <a href="#node60.html" id="book.html_tex2html79">Approximate Reasoning</a>
  - <a href="#node61.html" id="book.html_tex2html80">General Negation</a>
- <a href="#node62.html" id="book.html_tex2html81">Meta-Programming</a>
  - <a href="#node63.html" id="book.html_tex2html82">Meta-Interpreters in XSB</a>
    - <a href="#node64.html" id="book.html_tex2html83">A Metainterpreter for Disjunctive Logic Programs</a>
    - <a href="#node65.html" id="book.html_tex2html84">A Metainterpreter for Explicit Negation</a>
  - <a href="#node66.html" id="book.html_tex2html85">Abstract Interpretation</a>
    - <a href="#node67.html" id="book.html_tex2html86">AI of a Simple Nested Procedural Language</a>
- <a href="#node68.html" id="book.html_tex2html87">XSB Modules</a>
- <a href="#node69.html" id="book.html_tex2html88">Handling Large Fact Files</a>
  - <a href="#node70.html" id="book.html_tex2html89">Compiling Fact Files</a>
  - <a href="#node71.html" id="book.html_tex2html90">Dynamically Loaded Fact Files</a>
  - <a href="#node72.html" id="book.html_tex2html91">Indexing Static Program Clauses</a>
  - <a href="#node73.html" id="book.html_tex2html92">Bibliographic Notes</a>
- <a href="#node74.html" id="book.html_tex2html93">Table Builtins</a>
- <a href="#node75.html" id="book.html_tex2html94">XSB System Facilities</a>
- <a href="#node76.html" id="book.html_tex2html95">Bibliography</a>
- <a href="#node77.html" id="book.html_tex2html96">About this document ...</a>

------------------------------------------------------------------------
