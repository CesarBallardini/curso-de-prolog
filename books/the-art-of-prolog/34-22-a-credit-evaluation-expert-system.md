# 22 A Credit Evaluation Expert System

<!-- page 470 -->
When the first edition of this book was published, there was a surge of activity in the application of artificial intelligence to industry. Of particular interest were expert systemsprograms designed to perform tasks previously allocated to highly paid human experts. One important feature of expert systems is the explicit representation of knowledge.

This entire book is relevant for programming expert systems. The example programs typify code that might be written. For instance, the equation-solving program of Chapter 23 can be, and has been, viewed as an expert system. The knowledge of expert systems is often expressed as rules. Prolog whose basic statements are rules is thus a natural language for implementing expert systems.

<!-- page 471 -->
22.1 Developing the System This chapter presents an account of developing a prototype expert system. The example comes from the world of banking: evaluating requests for credit from small business ventures. We give a fictionalized account of the development of a simple expert system for evaluating client requests for credit from a bank. The account is from the point of view of Prolog programmers, or knowledge engineers, commissioned by the bank to write the system. It begins after the most difficult stage of building an expert system, extracting the expert knowledge, has been under way for some time. In accordance with received wisdom, the programmers have been consulting with a single bank expert, Chas E. Manhattan. Chas has told us that three factors are of the utmost importance in considering a request for credit from a client (a small business venture).

The most important factor is the collateral that can be offered by the client in case the venture folds. The various types of collateral are divided into categories. Currency deposits, whether local or foreign, are first-class collateral. Stocks are examples of second-class collateral, and the collateral provided by mortgages and the like is illiquid.

Also very important is the client's financial record. Experience in the bank has shown that the two most important factors are the client's net worth per assets and the current gross profits on sales. The client's short-term debt per annual sales should be considered in evaluating the record, and slightly less significant is last year's sales growth. For knowledge engineers with some understanding of banking, no further explanation of such concepts is necessary. In general, a knowledge engineer must understand the domain sufficiently to be able to communicate with the domain expert.

The remaining factor to be considered is the expected yield to the bank. This is a problem that the bank has been working on for a while. Programs exist to give the yield of a particular client profile. The knowledge engineer can thus assume that the information will be available in the desired form.

Chas uses qualitative terms in speaking about these three factors: "The client had an excellent financial rating, or a good form of collateral. His venture would provide a reasonable yield," and so on. Even concepts that could be determined quantitatively are discussed in qualitative terms. The financial world is too complicated to be expressed only with the numbers and ratios constantly being calculated. In order to make judgments, experts in the financial domain tend to think in qualitative terms with which they are more comfortable. To echo expert reasoning and to be able to interact with Chas further, qualitative reasoning must be modeled.

<!-- page 472 -->
On talking to Chas, it became clear that a significant amount of the expert knowledge he described could be naturally expressed as a mixture of procedures and rules. On being pressed a little in the second and third interviews, Chas gave rules for determining ratings for collateral and financial records. These involved considerable calculations, and in fact, Chas admitted that to save himself work in the long term, he did a quick initial screening to see if the client was at all suitable.

This information is sufficient to build a prototype. We show how these comments and observations are translated into a system. The top-level basic relation is credit(Client,Answer), where Answer is the reply given to the request by Client for credit. The code has three modulescollateral, financial_rating, and bank_yieldcorrespondirig to the three factors the expert said were important. The initial screening to determine that the client is worth considering in the first place is performed by the predicate ok_prof ile(Client). The answer Answer is then determined with the predicate evaluate (Prof ile,Answer), which evaluates the Profile built by the three modules.

Being proud knowledge engineers, we stress the features of the toplevel formulation in credit/2. The modularity is apparent. Each of the modules can be developed independently without affecting the rest of the system. Further, there is no commitment to any particular data structure, i.e., data abstraction is used. For this example, a structure pro f ile(C,F,Y) represents the profile of collateral rating C, the financial rating F, and the yield Y of a client. However, nothing central depends on this decision, and it would be easy to change it. Let us consider some of the modular pieces.

Let us look at the essential features of the collateral evaluation module. The relation collateral_ratirig/2 determines a rating for a particular client's collateral. The first step is to determine an appropriate profile. This is done with the predicate collateral_profile, which classifies the client's collateral as first_class, second_class, or illiquid and gives the percentage each covers of the amount of credit the client requested. The relation uses facts in the database concerning both the bank and the client. In practice, there may be separate databases for the bank and the client. Sample facts shown in Program 22.1 indicate, for example, that local currency deposits are first-class collateral.

The profile is evaluated to give a rating by collateral_evaluation. lt uses rules of thumb to give a qualitative rating of the collateral: excellent, good, etc. The first collateral_evaluation rule, for example, reads: "The rating is excellent if the coverage of the requested credit amount by first-class collateral is greater than or equal to loo percent."

<!-- page 473 -->
Two features of the code bear comment. First, the terminology used in the program is the terminology of Chas. This makes the program (almost) self-documenting to the experts and means they can modify it with Credit Evaluation credit (Client,Answer)

Answer

`is` the reply to a request by

```prolog
                                    Client for credit.
credit (Client ,Answer) -
    ok_profile (Client),
    collateral_rating (Client ,Collateralhating),
    financial_rating(Client ,FinancialRating),
    bank_yield (Client ,Yield),
    evaluate(profile(CollateralRating,FinancialRating,Yield) Answer).
```

The collateral rating module collateraL rating ( Client,Rating) -

Rating is a qualitative description assessing the collateral

offered by Client to cover the request for credit.

```prolog
collateral_rating (Client Rating)
    collateral_profile (Client, FirstClass , SecondClass , Illiquid),
    collateral_evaluation (FirstClass ,SecondClass , Illiquid,Rating).
collateral_prof ile(Client ,FirstClass,SecondClass,Illiquid) -
    requested_credit (Client ,Credit),
    collateral_percent (f irst_class,Client ,Credit ,FirstClass),
    collateral_percent(second_class,Clïent ,Credit,SecondClass),
    collateral_percent(illiquid,Client,Credit ,Illiquid).
collateral_percent (Type ,Client Total ,Value) -
    findall(X, (collateral(Collateral Type),
       amount (Collateral,Client,X)) ,Xs)
    sumlist(Xs,Suni),
    Value is Sum*100/Total.
```

Evaluation rules

```prolog
collateral_evaluation(FirstClass , SecondClass ,Illiquid ,excellent) -
    FirstClass
                 loo.
collateral_evaluation(FirstClass,SecondClass ,Illiquid,excellent) -
    FirstClass
              >
                70, FirstClass
                              +
                                SecondClass
                                              100.
collateral_evaluation(FirstClass ,SecondClass,Illiquid,good) -
    FirstClass + SecondClass
                           >
                             60,
    FirstClass + SecondClass
                           <
                             70,
    FirstClass + SecondClass + Illiquid
                                        100.
```

Bank data

classification of collateral

```prolog
collateral (local_currency_deposits ,first_class)
collateral (foreign_currency_deposits ,first_class)
collateral (negotiate_instruments ,second_class).
collateral (mortgage, illiquid).
```

<!-- page 474 -->
Program 22.1 A credit evaluation system Financial rating financial_rating C Client,Rating)

Rating is a qualitative description assessing the financial

record offered by Client to support the request for credit.

```prolog
financial_rating(Client Rat ing)
    financial_f actors (Factors)
    score (Factors ,Client, 0, Score),
    calibrate (Score , Rating)
```

Financial evaluation rules calibrate(Score,bad)

Score

-500.

```prolog
calibrate(Score,mediuin) - -500
                              < Score, Score
                                            < 150.
calibrate(Score,good)
                       150
                             Score, Score
                                          <
                                            1000.
calibrate(Score,excellent) - Score
                                    1000.
```

Bank data - weighting factors financial_factors(E(net_worth_per_assets,5),

(last_year_sales_growth, 1),

(gross_prof its_on_sales,5),

(short_term_debt_per_annual_sales, 2) 1).

```prolog
score([(Factor,Weight)IFactorsl ,Client,Acc,Score) -
    value (Factor,Client ,Value)
    Acci is Acc
               + Weight*Value,
    score (Factors,Client,Accl ,Score)
score([ I ,Client,Score,Score)
```

Final evaluation evaluate (Pro file,Outcome)

Outcome is the reply to the client's Profile.

```prolog
evaluate(Profile Answer)
    rule(Conditions,Answer), verify(Conditions,Profile).
verify([condition(Type,Test,Rating)IConditions] ,Profile) -
    scale(Type,Scale),
    select_value (Type Profile ,Fact)
    compare(Test ,Scale Fact Rating),
    verify(Conditions Profile).
verify([ I Profile)
compare('=',Scale,Rating,Rating).
compare('>' Scale,Ratingl,Rating2) -
    precedes(Scale,Ratingl ,Rating2).
compare('' Scale,Ratingl,Rating2) -
    precedes(Scale,Ratingl,Rating2)
                                    Ratingi
                                             Rating2.
```

Program 22.1

<!-- page 475 -->
(Continued)

```prolog
compare('<' ,Scale,Ratingi,Rating2) -
    precedes(Scale,Rating2,Ratingl).
compare('' ,Scale,Ratingl,Rating2) -
    precedes(Scale,Rating2,Ratingl)
                                  ;
                                    Ratingi
                                           = Rating2.
precedes([R1IRs] ,R1,R2).
precedes([RIRs],Ri,R2) - R
                             R2, precedes(Rs,Rl,R2).
select_value(collateral,profile(C,F,Y) ,C)
select_value(finances,profile(C,F,Y) ,F).
select_value(yield,profile(C,F,Y) ,Y).
```

Utilities sumlist(Xs,Sum) - See Program 8.6b. Bank data and rules

```prolog
rule([condition(collateral,'' ,excellent),
    condition(finances,'' ,good),
    condition(yield,'' ,reasonable)] ,give_credit).
rule([condition(collateral,
                             ,good) ,condition(finances, C
                                                        ,good),
    condition(yield,'' ,reasonable)] ,consult_superior).
rule ( [conditíon(collateral,'' ,moderate),
    condition(finances,'' ,mediuin)]
    refuse_credit)
scale(collateral, [excellent,good,moderate]).
scale(finances, [excellent ,good,medium,bad]).
scale (yield, [excellent ,reasonable, poor]).
```

Program 22.1

(Continued)

little help from the knowledge engineer. Allowing people to think in domain concepts also facilitates debugging and assists in using a domainindependent explanation facility as discussed in Section 17.4. Second, the apparent naivete of the evaluation rules is deceptive. A lot of knowledge and experience are hidden behind these simple numbers. Choosing poor values for these numbers may mean suffering severe losses.

The financial evaluation module evaluates the financial stability of the client. It uses items taken mainly from the balance and profit/loss sheets. The financial rating is also qualitative. A weighted sum of financial factors is calculated by score and used by calibrate to determine the qualitative class.

<!-- page 476 -->
It should be noted that the modules giving the collateral rating and the financial rating both reflect the point of view and style of a particular expert, Chas Manhattan, rather than a universal truth. Within the bank there is no consensus about the subject. Some people tend to be conservative and some are prepared to take considered risks.

Programming the code for determining the collateral and financial ratings proceeded easily. The knowledge provided by the expert was more or less directly translated into the program. The module for the overall evaluation of the client, however, was more challenging.

The major difficulty was formulating the relevant expert knowledge. Our expert was less forthcoming with general rules for overall evaluation than for rating the financial record, for example. He happily discussed the profiles of particular clients, and the outcome of their credit requests and loans, but was reluctant to generalize. He preferred to react to suggestions rather than volunteer rules.

This forced a close reevaluation of the exact problem we were solving. There were three possible answers the system could give: approve the request for credit, refuse the request, or ask for advice. There were three factors to be considered. Each factor had a qualitative value that was one of a small set of possibilities. For example, the financial rating could be bad, medium, good, or excellent. Further, the possible values were ranked on an ordinal scale.

Our system clearly faced an instance of a general problem: Find an outcome from some ordinal scale based on the qualitative results of several ordinal scales. Rules to solve the problem were thus to give a conclusion based on the outcome of the factors. We pressed Chas with this formulation, and he rewarded us with several rules. Here is a typical one: "If the client's collateral rating is excellent (or better), her financial rating good (or better), and her yield at least reasonable, then grant the credit request."

An inirnediate translation of the rule is

```prolog
evaluate (profile (excellent,good,reasonable) ,give_credit).
```

<!-- page 477 -->
But this misses many cases covered by the rule, for example, when the client's profile is `(excellent,good,excellent). All` the cases for a given rule can be listed. lt seemed more sensible, however, to build a more general tool to evaluate rules expressed in terms of qualitative values from ordinal scales.

There is potentially a problem with using ordinal scales because of the large number of individual cases that may need to be specified. If each of the N modules have M possible outcomes, there are NM cases to be considered. In general, it is infeasible to have a separate rule for each possibility. Not only is space a problem for so many rules but the search involved in finding the correct rule may be prohibitive. So instead we defined a small ad hoc set of rules. We hoped the rules defined, which covered many possibilities at once, would be sufficient to cover the clients the bank usually dealt with. We chose the structure rule(Conditions,Conclusion) for our rules, where Conditions is a list of conditions under which the rule applies and Conclusion is the rule's conclusion. A condition has the form condition(Factor,Relation,Rating), insisting that the rating from the factor named by Factor bears the relation named by Relation to the rating given by Rating.

The relation is represented by the standard relational operators: <, =, >, etc. The previously mentioned rule is represented as

```prolog
rule([condition(collateral,'' ,excellent),
     condition(finances,'' ,good),
     condition(yield,'' ,reasonable)] ,give_credit).
```

Another rule given by Chas reads: "If both the collateral rating and financial rating are good, and the yield is at least reasonable, then consult your superior." This is translated to

```prolog
rule( [condition(collateral, ' ,good),
     condition(finances, '=' ,good),
     condition(yield,'' ,reasonable)] ,consult_superior).
```

Factors can be mentioned twice to indicate they lie in a certain range or might not be mentioned at all. For example, the rule

```prolog
rule( [condition(collateral,'' ,moderate),
     condition(finances, '' ,medium)]
    refuse_credit).
```

<!-- page 478 -->
states that a client should be refused credit if the collateral rating is no better than moderate and the financial rating is at best medium. The yield is not relevant and so is not mentioned. Client Data bank_yield(clientl ,excellent) requested_credit (clienti 50000). amount (local_currency_deposits client i 30000). axnount(foreign_currencydeposits ,clienti ,20000). amount (bank_guarantees, clienti 3000). axnount(negotiate_instruxnents,clientl,5000). amount(stocks,clientl,9000) amount (mortgage ,clienti , i2000). amount (do cuments client i, 14000). value (net_worth_per_assets,clienti ,40). value(last_year_sales_growth,clientl 20). value (gross_prof its_on_sales,clienti 45). value(short_term_debt_per_annual_sales,clienti ,9). ok_profile(clienti). Program 22.2

Test data for the credit evaluation system

The interpreter for the rules is written nondeterministically. The procedure is: "Find a rule and verify that its conditions apply," as defined

```prolog
by evaluate. The predicate verify(Conditions,Profile) checks that
```

the relation between the corresponding symbols in the rule and the ones that are associated with the `Profile` of the client is as specified by `Con-` `ditions. For` each `Type` that can appear, a scale is necessary to give the order of values the scale can take. Examples of scale facts in the bank database are `scale(collateral, [excellent,good,Inoderate])`

```prolog
and scale(finances, [excellent,good,mediuni,bad]). The predicate
```

`select_value` returns the appropriate symbol of the factor under the ordinality test that is performed by `compare.` lt is an access predicate, and consequently the only predicate dependent on the choice of data structure for the profile.

At this stage, the prototype program is tested. Some data from real clients are necessary, and the answer the system gives on these individuals is tested against what the corresponding bank official would say. The data for `clienti` is given in Program 22.2. The reply to the query

```prolog
credit(clientl,X) isX = give_credit.
```

<!-- page 479 -->
Our prototype expert system is a composite of styles and methods not just a backward chaining system. Heuristic rules of thumb are used to deterrnme the collateral rating; an algorithm, albeit a simple one, is used to deterrmne the financial rating; and there is a rule language, with an interpreter, for expressing outcomes in terms of values from discrete ordinal scales. The rule interpreter proceeds forward from conditions to conclusion rather than backward as in Prolog. Expert systems must become such composites in order to exploit the different forms of knowledge already extant.

The development of the prototype was not the only activity of the knowledge engineers. Various other features of the expert system were developed in parallel. An explanation facility was built as an extension of Program 17.22. A simulator for rules based on ordinal scales was built to settle the argument among the knowledge engineers as to whether a reasonable collection of rules would be sufficient to cover the range of outcomes in the general case.

Finally, a consistency checker for the rules was built. The following meta-rule is an obvious consistency principle: "If all of client A's factors are better than or equal to client B's, then the outcome of client A must be better than or equal to that of client B."

22.2 Background More details on the credit evaluation system can be found in Ben-David and Sterling (1986).
