# Prolog Web Applications

Prolog is extremely well suited for developing **web applications**. Web pages are naturally represented as [Prolog terms](04-data.md) and can be easily created, inspected and processed recursively.

*Video*: [Web Scraping](https://www.metalevel.at/prolog/videos/web_scraping)

We distinguish between **client** and **server** applications. This page explains in more detail how to use Prolog for these tasks. Support for web development differs between Prolog systems. At the most basic level, a few simple predicates that let us access network streams, such as the predicates provided by [`library(sockets)`](https://sicstus.sics.se/sicstus/docs/4.3.2/html/sicstus/lib_002dsockets.html) in SICStus Prolog and Scryer Prolog, suffice to build rudimentary web applications. Of course, the most widely used Prolog systems typically go far beyond this and ship with more thorough and high-level support for such applications. For example, SICStus Prolog and several other systems ship with the [PiLLoW library](http://cliplab.org/Software/pillow/pillow.html) for WWW programming. In SICStus, it is available as [`library(pillow)`](https://sicstus.sics.se/sicstus/docs/latest4/html/sicstus.html/lib_002dpillow.html#lib_002dpillow). [Tau Prolog](http://tau-prolog.org/) is a Prolog interpreter written in JavaScript and can be seamlessly embedded in web applications.

## HTTP Clients

### Fetching pages

A **client** fetches pages from a *server*. Using Scryer Prolog, we can easily fetch a page via HTTP and HTTPS using [**`http_open/3`**](https://www.scryer.pl/http/http_open.html). Example:

```prolog
?- use_module(library(http/http_open)).
   true.

?- http_open("https://www.metalevel.at/prolog", Stream, []).
   Stream = '$stream'(0x7faed0412400)
    
```

This opens `Stream` for reading the page. The third argument of `http_open/3` is a list of *options* that we can use to obtain header fields and control various aspects of the connection. Since the `https` scheme was specified in the example above, a *secure* connection is automatically established and used. You can use [`library(tls)`](https://codeberg.org/mthom/scryer-prolog/raw/master/src/lib/tls.pl) to establish secure connections explicitly.

### Parsing HTML

Once we obtain a stream handle for a web page, we can read the page in several ways. For example, we can read one character at a time or use a [DCG](14-dcg.md) to process the stream in a [pure](11-purity.md) way. Very often, it is most convenient to convert the HTML page to a [Prolog term](04-data.md) that reflects the page structure in a uniform way. The predicate **`load_html/3`** performs this conversion:

```prolog
?- http_open("https://www.metalevel.at/prolog", Stream, []),
   load_html(stream(Stream), DOM, []).
   Stream = ...,
   DOM = [element(html, [], [element(head, [], [element(title, ...)])])].
    
```

See [**`library(sgml)`**](https://www.scryer.pl/sgml.html) for more information, and related predicates for parsing markup languages like XML.

### Processing HTML

Plain Prolog already makes it extremely convenient to process such a nested list of SGML elements, where each element is represented as `element(Name, Attributes, Content)`. We could simply process such structures recursively, using [built-in](03-concepts.md#builtin) Prolog features. Amazingly, we can do even better: In Scryer Prolog, [**`library(xpath)`**](https://www.scryer.pl/xpath.html) allows us to access HTML elements via terms inspired by the [XPath](https://en.wikipedia.org/wiki/XPath) query language in a straight-forward way. For example, let us obtain the text of all *list items* that appear on a page, in continuation of the previous example:

```prolog
?- use_module(library(sgml)),
   use_module(library(xpath)).
   true.
      
?- http_open("https://www.metalevel.at/prolog", Stream, []),
   load_html(stream(Stream), DOM, []),
   xpath(DOM, //li(text), Item).
   Stream = ..., DOM = ..., Item = "Introduction"
;  Stream = ..., DOM = ..., Item = "Facets of Prolog"
;  Stream = ..., DOM = ..., Item = "Logical Foundations"
;  Stream = ..., DOM = ..., Item = "Basic Concepts"
;  Stream = ..., DOM = ..., Item = "Data Structures"
;  ... .
    
```

On backtracking, all solutions are reported.

## HTTP Servers

For **server** applications, we can use for example the [HTTP server](https://www.scryer.pl/http/http_server.html) library of Scryer Prolog. To get started, consider a very rudimentary HTTP server:

```prolog
:- use_module(library(http/http_server)).

run(Port) :-
        http_listen(Port, [get(/, request_response)]).

request_response(_, Response) :-
        http_status_code(Response, 200),
        http_body(Response, text("Hello!")).
    
```

The snippet implements a server that simply responds with *Hello!*. To run the server, copy the snippet to `server.pl`, and start the server for example on port 3040 using:

```prolog
$ scryer-prolog -g "run(3040)" server.pl
    
```

Once the server is running, you can test it by browsing to [`http://127.0.0.1:3040`](http://127.0.0.1:3040). In a more realistic HTTP server, the response will of course depend on the actual *request* of the client. Using different or additional handlers, you can change the behaviour of the server. For HTTP server applications, also consider [SWI-Prolog](http://eu.swi-prolog.org), a Prolog dialect with excellent support for robust and efficient multithreading. See its [**HTTP server libraries**](http://eu.swi-prolog.org/pldoc/man?section=httpserver) for more information. To run Prolog-based HTTPS servers with SWI-Prolog, see [**LetSWICrypt**](/letswicrypt/). [**Proloxy**](/proloxy/) is a Prolog-based **proxy** that uses extensible Prolog clauses for flexible configurations.

## Client/Server Applications

[**Pengines**](http://eu.swi-prolog.org/pldoc/doc_for?object=section%28%27packages/pengines.html%27%29) allow us to implement powerful client/server applications in Prolog. Using Pengines, you can query a remote Prolog server *as if it were local*, using its results in client Prolog programs or web pages with JavaScript. For example, consider again the animal identification task described in [**Expert Systems**](21-expertsystems.md). We can implement it as a client/server application with:

- [animal_server.pl](animal_server.pl)
- [animal_client.pl](animal_client.pl)

Importantly, the application logic resides completely on the server. See [**RITS**](/rits/) for an example of a more complex application. See also Pengine's successor, [**Web Prolog**](https://github.com/Web-Prolog), and the upcoming book [*Web Prolog and the programmable Prolog Web*](https://github.com/Web-Prolog/swi-web-prolog/blob/master/book/web-prolog.pdf) by Torbjörn Lager.
