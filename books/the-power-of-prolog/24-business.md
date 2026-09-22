# Prolog Business Cases

To establish the use of Prolog in an organization, management must be made aware of the immense benefits it has from a *business perspective*, such as:

- Prolog is **ISO standardized**. This is an extremely important asset from a legal perspective, since it means that Prolog vendors can be *held accountable* when violating the standard.
- Prolog **cuts costs**: Since Prolog programs are so general, you typically need *less code*, which you can type, read and audit in less time.
- Prolog has a proven **track record** in many very serious applications. See for example the SICStus [customer references](https://sicstus.sics.se/customers.html).
- Prolog is ideally suited for **rule based** systems that express your **business rules**.
- etc.

In any organization, there are countless possible applications for Prolog. In the following, we consider some of them.

## Prolog as a database

One of the *most basic* use cases of Prolog is to rely on its ability to act as a **database**. By this, we mean applications that simply *store data* and make it available for *querying*. Prolog is very well suited for such applications, since you can dynamically add and remove data, and rely on automatic *indexing* to obtain good performance in many situations of practical relevance. Also, you can easily edit and process Prolog programs by various means, which makes exporting, importing and processing the accumulated knowledge in general very convenient. In addition, formulating Prolog queries is often more natural and easier than formulating SQL queries. For such reasons, Prolog is often a good alternative for other database systems. There is a syntactic subset of Prolog that is called [**Datalog**](https://en.wikipedia.org/wiki/Datalog), and it is especially suitable for such use cases.

*Video*: [Datalog](https://www.metalevel.at/prolog/videos/datalog)

You can also use the *Constraint Query Language* [CQL](https://eu.swi-prolog.org/pldoc/man?section=cql) to seamlessly access SQL databases from Prolog.

## Analyzing events and anomalies

A **logfile** records events. For example, you can configure a Prolog [HTTPS sever](22-web.md#server) to store information about *requests* it processes. When you locally test such a server by fetching the page [`/prolog`](/prolog), it may write an entry similar to the following in its logfile:

```prolog
/*Sun Apr  9 23:01:19 2017*/
request(45, 1491771679.213,
         [peer(ip(127,0,0,1)),
          method(get),request_uri('/prolog'),path('/prolog'),
          http_version(1-1),host(localhost),port(3037),
          connection('keep-alive'),upgrade_insecure_requests('1'),
          if_modified_since('Wed, 05 Apr 2017 23:24:08 GMT')]).
    
```

This entry describes the *request* of the client. After processing the request, the server may write an additional entry that describes how the request was processed. For example, it may add:

```prolog
completed(45, 0.0009790000000000076, 0, 304, not_modified).
    
```

The key point is that you can configure the server so that the logfile is a series of Prolog *facts*. Hence, the whole logfile can be easily analyzed *using Prolog*! A single invocation of Prolog suffices to *load the entire file*, and at the same time makes it ready for posting arbitrary queries over the accumulated data. For example, in the case above, we can ask: *Are there any client requests that were not served?* In Prolog, this becomes:

```prolog
?- request(R, _, _), \+ completed(R, _, _, _, _).
   false.
    
```

In our case, this means that the server at least *handled* each request in some way, and did not silently ignore one. Of course, not *all* logfiles can be parsed directly with Prolog. However, the more you use Prolog syntax within your organization, the more you will benefit from being able to post queries over such data. In addition, you can typically easily convert any logfile format to valid Prolog facts, and then apply the same reasoning.

## Rule-based reporting

In every organization, there is a constant need for excellent **reports**. Prolog is ideally suited for *generating* such reports from available data. For example, imagine you are responsible for reporting the number of monthly *visitors* of your company's homepage. Further, for historic reasons, your team of technicians sends you the *average number* of visitors *per day*, at the end of each month. That is, the data you have available is stored in the following convenient form, using Prolog facts, indicating a nice growth of daily visitors to your site:

```prolog
year_month_daily_visitors(2017, jan, 30018).
year_month_daily_visitors(2017, feb, 32913).
year_month_daily_visitors(2017, mar, 35871).
    
```

However, your management wants *you* to report the *total* number of visitors for each month, not the daily average. Using Prolog **rules**, it is straight-forward to *convert* your data to the data that your *management* wants to see. For example, using [integer arithmetic](clpfd), we can readily relate the daily average to the monthly total:

```prolog
year_month_total(Year, Month, Total) :-
        Total #= Days*Daily,
        year_month_days(Year, Month, Days),
        year_month_daily_visitors(Year, Month, Daily).
    
```

This only requires the definition of `year_month_days/3`, with clauses that may look as follows:

```prolog
year_month_days(2017, jan, 31).
year_month_days(2017, feb, 28).
year_month_days(2017, mar, 31).
    
```

This suffices to produce the answers we need, for example:

```prolog
?- year_month_total(Year, Month, Total).
   Year = 2017, Month = jan, Total = 930558
;  Year = 2017, Month = feb, Total = 921564
;  Year = 2017, Month = mar, Total = 1112001.
    
```

Using `format/2`, you can turn this into a more readable report:

```prolog
?- format("year month visitors~n", []),
   year_month_total(Year, Month, Total),
   format("~d ~q ~t~U~20|~n", [Year,Month,Total]),
   false.
year month visitors
2017 jan     930_558
2017 feb     921_564
2017 mar   1_112_001
    
```

Notice the use of *forced backtracking* via [`false/0`](03-concepts.md#builtin). A few weeks later, management needs a different report: They now want neither the daily average, nor the total number, but rather the *cumulative sum* of visitors for the current year, *up to* and including the current month. Using Prolog, it is straight-forward to generate this report by simply *formulating the required rules*, while retaining the original data exactly as it was. For example:

```prolog
cumulative(Pred, Until, C) :-
        months(Ms),
        cumulative_(Ms, Pred, Until, 0, C).

cumulative_([], _, _, C, C).
cumulative_([M|Ms], Pred, Until, C0, C) :-
        C1 #= C0 + Current,
        call(Pred, M, Current),
        if_(M=Until, C=C1,
            cumulative_(Ms, Pred, Until, C1, C)).

months([jan,feb,mar,apr,may,jun,jul,aug,sept,oct,nov,dec]).
    
```

This uses the meta-predicates [`call/3`](10-metapredicates.md#call) and [`if_/3`](10-metapredicates.md#if_3) to describe the cumulative sum in a very general and flexible way. For example:

```prolog
?- cumulative(year_month_total(2017), M, C).
   C = 930558, M = jan
;  C = 1852122, M = feb
;  C = 2964123, M = mar
;  false.
    
```

As a special case of this query, we can of course also inquire any particular month:

```prolog
?- cumulative(year_month_total(2017), feb, C).
   C = 1852122
;  false.
    
```

Note the massive advantages of such a way to *reason* about your data. For example, it suffices to send around *Prolog facts*, which you can easily do via plain text. Augmenting these facts is also very easy: It suffices to add one fact per month to keep the above report current.

## Strategic considerations

Suppose you are successfully applying Prolog within your company to solve difficult problems. Would you publicly announce the fact that you are using Prolog, so that your competitors can benefit from the same technology? My personal guess is: *No*, you *wouldn't*. Sometimes, when you introduce Prolog in an organization, people will dismiss the language because they have never heard of anyone who uses it. Yet, [**a third of all airline tickets**](https://web.archive.org/web/20190203010151/https://www.sics.se/projects/sicstus-prolog-leading-prolog-technology) is handled by systems that run SICStus Prolog. NASA uses SICStus Prolog for a voice-controlled system onboard the International Space Station. Windows NT used an embedded Prolog interpreter for [network configuration](http://web.archive.org/web/20040603192757/research.microsoft.com/research/dtg/davidhov/pap.htm). New Zealand's dominant [stock broking system](https://dtai.cs.kuleuven.be/CHR/files/Elston_SecuritEase.pdf) is written in Prolog and CHR. Prolog is used to [reason about business grants](https://arxiv.org/abs/2406.15293v1) in Austria. A commercial Prolog system easily costs *thousands* of dollars. This is not software you "just buy" as an individual. A professional Prolog system is typically bought by companies who simply *need* the power of Prolog to solve their tasks. They are unlikely to advertise their internal technologies. Still, a few of them do. For example, the [Java Virtual Machine Specification](https://docs.oracle.com/javase/specs/jvms/se7/html/jvms-0-preface7.html) contains a lot of Prolog code, and [IBM Watson uses Prolog](https://www.cs.nmsu.edu/ALP/2011/03/natural-language-processing-with-prolog-in-the-ibm-watson-system/) for natural language processing. The Belgian company [VATmiraal](https://vatmiraal.be) are using Scryer Prolog to implement their core product. Sometimes, instead of trying to introduce Prolog in an organization, it is more efficient to start working for one where it is already being used!
