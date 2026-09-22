# Prototyping

<!-- page 141 -->
Regardless of whether one is going to use Prolog to build a finished application, Prolog is still a powerful tool for prototyping the application. The problem might fit nicely into *Clam* or *Foops*, in which case those systems should be used for the prototype. Otherwise, pure Prolog can be used to model the application.

In an expert system prototype it is important to model all of the different types of knowledge that will be used in the application. Initial knowledge engineering should be focused on what types of information the expert uses and how it is used. The full range of expertise should be modelled, but not to the depth required for a real system.

The Prolog rules used in a prototype can be quickly molded to get the desired effects in the application. The clean break between the inference engine and the knowledge base can be somewhat ignored to allow more rapid development of the prototype. Explanations, traces and many of the other features of an expert system are left out of the prototype. The I/O is implemented simply to just give a feeling for the user interaction with the system. The full system can be more elegantly designed once the prototype has been reviewed by the potential users. 11.1 The Problem

This section describes the building of a prototype system, which acts as an advisor for a mainframe software salesperson. A good sales person must not only be congenial and buy lunches, but must also have good product knowledge and know how to map that knowledge onto a potential customer's needs. The type of knowledge needed by the sales person is different from that typically held by a technical person.

The technical person thinks of a product in terms of its features, and implementation details. The sales person must think of the prospect's real and perceived needs and be able to map those to benefits provided by the features in the product. That is, the sales person must understand the prospect's objectives and be able to present the benefits and features of the product that help meet those objectives.

The salesperson must also have similar product knowledge about the competitor's products and know which benefits to stress that will show up the weaknesses in the competitor's product for the particular prospect.

In addition to this product knowledge, the sales person also has rules for deciding whether or not the prospect is likely to buy, and recognizing various typical sales situations.

With a large workload, it is often difficult for a sales person to keep up on product knowledge. An expert system, which helps the sales person position the products for the prospect, would be a big asset for a high tech sales person. The *Sales Advisor* system is a prototype of such a system, designed to help in the early stages of the sales cycle. 11.2 The Sales Advisor Knowledge Base

The ways in which sales people mentally organize product knowledge are fairly consistent. The knowledge base for the sales advisor should be organized in a format which is as close to the sales person's organization of the knowledge as possible. This way the semantic gap will be reduced and the knowledge base will be more easily maintained by a domain expert.

<!-- page 142 -->
*Building Expert Systems in Prolog* The main types of knowledge used by the salesperson fall into the following categories:

Qualification — the way in which the salesperson determines if the prospect is a

good potential customer and worth pursuing;

Objective Benefit Feature (OBF) analysis — the way a salesperson matches the

customer's objectives with the benefits and features of the product;

Competitive analysis — the way a salesperson decides which benefits and features to

stress based on the competitor's weaknesses;

Situation analysis — the way a salesperson determines if the products will run in the

prospect's shop.

Miscellaneous advice — various rules covering different situations, which do not fall

neatly in the above categories.

Having this overall organization, we can now begin to prototype the system. The first step is to design the knowledge base. Simple Prolog rules can be used wherever possible. The knowledge for each area will be considered separately. The example uses the products sold for mainframe computers by Cullinet Software.

### Qualifying

First we implement the knowledge for qualifying the prospect. This type of knowledge falls easily into a rule format. The final version will probably need some uncertainty handling as in *Clam*, but it is also important for this system to provide more text output than *Clam* provides. The quickest way to build the prototype is to use pure Prolog syntax rules with I/O statements included directly in the body of the rule. *Clam* can be used later with modifications for better text display.

Two examples of qualifying rules are: the prospect must have an IBM mainframe, and the prospect's revenues must be at least $30 million. They are written as unqualified since if the prospect fails a test then it is unqualified.

```prolog
unqualified:-
not computer('IBM'),
advise('Prospect must have an IBM computer'),
nl.
unqualified:-
revenues(X),
X < 30,
advise('Prospect is unlikely to buy IDMS with revenues under $30
million'),
nl.
```

### Objectives - Benefits - Features

Sales people typically store product knowledge in a tabular form called an objectivebenefit-feature chart, or OBF chart. It categorizes product knowledge so that for each objective of the customer, the benefits of the product for meeting that objective and the features of the product are detailed.

For the prototype we can simplify the prospect objectives by considering three main ones: development of applications, building an information center and building efficient production systems. Each prospect might have a different one of these objectives. The benefits of each product in the product line varies for each of these objectives. This information is stored in Prolog structures of three arguments called obf. The first argument is the feature (or product), the second is the customer objective and the third is the benefit that is stressed to the prospect.

132

<!-- page 143 -->
*Chapter 11 - Prototyping*

```prolog
obf('IDMS/R', development,
'IDMS/R separates programs from data, simplifying
development.').
obf('IDMS/R', information,
'IDMS/R maintains corporate information for shared access.').
obf('IDMS/R', production,
'IDMS/R allows finely tuned data access for optimal
performance.').
obf('ADS', development,
'ADS automates many programming tasks thus increasing
productivity.').
obf('ADS', production,
'ADS generates high performance compiled code.').
obf('OLQ', development,
'OLQ allows easy validation of the database during
development.').
obf('OLQ', information,
'OLQ lets end users access corporate data easily.').
obf('OLE', information,
'OLE lets users get information with English language
queries.').
```

By using a chart such as this, the salesperson can stress only those features and benefits that meet the prospect's objectives. For example, OLE (OnLine English — a natural language query) would only be mentioned for an information center. OLQ (OnLine Query — a structured query language) would be presented as a data validation tool to a development shop, and as an end user query tool to an information center.

This knowledge could have been stored as rules of the form:

```prolog
obf('OLE', 'OLE lets users get information in English') :-
objective(information).
```

This type of rule is further away from the way in which the experts understand the knowledge. The structures are more natural to deal with and the inference engine can be easily modified to deal with what is really just a different format of a rule.

### Situation Analysis

The next key area is making sure that the products are compatible with the customer's configuration. We wouldn't want to sell something that doesn't work. For example, OLE would not run at the time on a small machine or under a DOS operating system.

```prolog
unsuitable('OLE'):-
operating_system(dos).
unsuitable('OLE'):-
machine_size(small).
```

### Competitive Analysis

A good sales person will not directly attack the competition, but will use the competition's weakness to advantage. This is done by stressing those aspects of a product which highlight the competitor's weakness. That is, how can our product be differentiated from the competitor's. For example, two of Cullinet's main competitors were IBM and ADR.

<!-- page 144 -->
*Building Expert Systems in Prolog* Both IBM and Cullinet provided systems that performed well, but Cullinet's was easy to use, so ease of use was stressed when the competitor was IBM. ADR's system was also easy to use, but did not perform as well as Cullinet's, so against ADR performance was stressed.

```prolog
prod_dif('IDMS/R', 'ADR',
'IDMS/R allows specification of linked lists for high
performance.').
prod_dif('IDMS/R', 'IBM',
'IDMS/R allows specification of indexed lists for easy
access.').
prod_dif('ADS', 'ADR',
'ADS generates high performance code.').
prod_dif('ADS', 'IBM',
'ADS is very easy to use.').
```

### Miscellaneous Advice

Besides this tabular data, there are also collections of miscellaneous rules for different situations. For example, there were two TP monitors, UCF, and DC. One allowed the user to use CICS for terminal networks, and the other provided direct control of terminals. The recommendation would depend on the situation. Another example is dealing with federal government prospects, which required help with the Washington office as well. Another rule recommends a technical sales approach, rather than the business oriented sell, for small shops that are not responding well.

```prolog
advice:-
not objective(production),
tp_monitor('CICS'),
online_applications(many),
nl,
advise('Since there are many existing online applications and'),
nl,
advise('performance isn''t an issue suggest UCF instead of DC'),
nl.
advice:-
industry(government),
government(federal),
nl,
advise('If it's the federal government, make sure you work'),
nl,
advise(' with our federal government office on the account'),
nl.
advice:-
competition('ADR'),
revenues(X),
X < 100,
friendly_account(no),
nl,
advise(' Market database technical issues'),
nl,
advise(' Show simple solutions in shirt sleeve sessions' ),
nl.
```

### User Queries

Finally, the knowledge base contains a list of those items which will be obtained from the user.

134

<!-- page 145 -->
*Chapter 11 - Prototyping*

```prolog
competition(X):-
menuask('Who is the competition?',
X, ['ADR', 'IBM', 'other']).
computer(X):-
menuask('What type of computer are they using?',
X, ['IBM', 'other']).
friendly_account(X):-
menuask('Has the account been friendly?',
X, [yes, no]).
government(X):-
menuask('What type of government account is it?',
X, [federal, state, local]).
industry(X):-
menuask('What industry segment?',
X, ['manufacturing', 'government', 'other']).
machine_size(X):-
menuask('What size machine are they using?',
X, [small, medium, large]).
objective(X):-
menuask('What is the main objective for looking at DBMS?',
X, ['development', 'information', 'production']).
online_applications(X):-
menuask('Are there many existing online applications?',
X, [many, few]).
operating_system(X):-
menuask('What operation system are they using?',
X, ['OS', 'DOS']).
revenues(X):-
ask('What are their revenues (in millions)?',X).
tp_monitor(X):-
menuask('What is their current TP monitor?',
X, ['CICS', 'other']).
```

**11.3 The Inference Engine**

Now that a knowledge base has been designed, which has a reasonably small semantic gap with the expert's knowledge, the inference engine can be written. For the prototype, some of the knowledge is more easily stored in the inference engine. The high level order of goals to seek is stored in the main predicate, recommend.

```prolog
recommend:-
qualify,
objective_products,
product_differentiation,
other_advice,
!.
recommend.
```

First, the prospect is qualified. The qualify predicate checks to make sure there are no unqualified rules which fire.

```prolog
qualify:-
unqualified,
!,
```

<!-- page 146 -->
*Building Expert Systems in Prolog*

```prolog
fail.
qualify.
```

The objective_products predicate uses the user's objectives and the OBF chart to recommend which products to sell and which benefits to present. It makes use of the unsuitable rules to ensure no products are recommended, which will not work in the customer's shop.

```prolog
objective_products:-
objective(X),
advise('The following products meet objective'),
advise(X), nl, nl,
obf(Product, X, Benefit),
not unsuitable(Product),
advise(Product:Benefit),nl,
fail.
objective_products.
```

Next, the product differentiation table is used in a similar fashion.

```prolog
product_differentiation:-
competition(X),
prod_dif(_,X,_),
advise('Since the competition is '),
advise(X),
advise(', stress:'), nl, nl,
product_diff(X),
!.
product_differentiation.
product_diff(X):-
prod_dif(Prod, X, Advice),
tab(5), advise(Advice), nl,
fail.
product_diff(_).
```

Finally, the other advice rules are all tried.

```prolog
other_advice:-
advice,
fail.
other_advice.
```

**11.4 User Interface**

For a prototype, the user interface is still a key point. The system will be looking for supporters inside an organization, and it must be easy for people to understand the system. The windowing environment makes it relatively easy to put together a reasonable interface.

For this example, one display window is used for advice near the top of the screen, and a smaller window near the bottom is used for questions to the user. Pop-up menus and prompter windows are used to gather information from the user. Figure 11.1 shows the

## User Interface

136

<!-- page 147 -->
*Chapter 11 - Prototyping*

IDMS/R maintains corporate information for

shared access

OLQ lets end users access corporate data easily

What industry segment?

manufacturing

government

other

*Figure 11.1 User interface of sales advisor prototype*

The two display windows are defined at the beginning of the session.

```prolog
window_init:-
window(advice, create, [type(display), coord(1,1,10,78),
border(blue:white),
contents(blue:white)]),
window(quest, create, [type(display), coord(13,10,13,70),
border(blue:white),
contents(blue:white)]).
```

The prompt and pop-up menu windows are defined dynamically as they are needed. The ask and menuask predicates work as in other examples. Here are the clauses that interface with the user.

```prolog
ask(A,V):-
window(quest,write,A),
window([type(prompt),coord(16,10,16,70),border(white:blue),
contents(white:blue)],
read, ['', Y]),
asserta(known(A,Y)),
Y = V.
menuask(Attribute,AskValue,Menu):-
length(Menu,L),
R1 = 16,
R2 is R1 + L - 1,
window(quest,write,Attribute),
window([type(menu),coord(R1,10,R2,40),border(white:blue),
contents(white:blue),menu(Menu)],
read, AnswerValue),
asserta(known(Attribute,AnswerValue)),
AskValue = AnswerValue.
```

The advise predicate uses the predefined display window, advice.

```prolog
advise([H|T]):-
window(advice,writeline,[H|T]),
!.
advise(X):-
window(advice,write,X).
```

<!-- page 148 -->
*Building Expert Systems in Prolog* 11.5 Summary

One can model a fairly complex domain relatively quickly in Prolog, using the tools available. A small semantic gap on the knowledge base and good user interface are two very important points in the prototype.

## Exercises

11.1 Prototype an expert system that plays poker or some similar game. It will need to be

specialized to understand the particular knowledge of the game. Experiment with

the prototype to find the best type of user interface and dialog with the system.

138

*Chapter 11 - Prototyping*

