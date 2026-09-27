:- encoding(utf8).

% Generate the PlDoc HTML pages of some example files, for the site.
%
%     swipl tools/pldoc-html.pl <output dir> <example file>...
%
% Run from the directory that holds the example files: PlDoc names each page
% after the file's path relative to the working directory. PlDoc must be loaded
% before the files, because it collects the %! comments while they load; and
% doc_save/2 documents only files that are loaded, so the ones not named here
% (soluciones.pl, for instance) stay out.
%
% doc_save/2 writes some links for PlDoc's own web server (doc_server/1), of
% the form /pldoc/doc_for?object=Name/Arity, which a static site does not
% serve. After saving, each one is rewritten: to the page and anchor of the
% predicate when one of the documented files defines it, and to the online
% SWI-Prolog manual otherwise.

:- use_module(library(pldoc)).
:- use_module(library(doc_files)).
:- use_module(library(readutil)).

:- initialization(main, main).

main :-
    current_prolog_flag(argv, [Output|Files]),
    Files \== [],
    maplist(load_example, Files),
    doc_save('.', [doc_root(Output), title('Ejemplos del capítulo')]),
    directory_files(Output, Entries),
    forall(( member(Entry, Entries),
             file_name_extension(_, html, Entry) ),
           ( directory_file_path(Output, Entry, Page),
             static_links(Page, Files) )).

load_example(File) :-
    load_files(File, [silent(true)]).

%!  static_links(+Page, +Files) is det.
%
%   Rewrite in Page every link to PlDoc's server as a link that works without
%   it.
static_links(Page, Files) :-
    read_file_to_string(Page, Html, [encoding(utf8)]),
    rewrite(Html, Files, Static),
    (   Static == Html
    ->  true
    ;   setup_call_cleanup(
            open(Page, write, Out, [encoding(utf8)]),
            write(Out, Static),
            close(Out))
    ).

%!  rewrite(+Html, +Files, -Static) is det.
%
%   Static is Html with each href="/pldoc/doc_for?object=Name/Arity" replaced.
rewrite(Html, Files, Static) :-
    Prefix = "href=\"/pldoc/doc_for?object=",
    (   sub_string(Html, Before, Length, _, Prefix)
    ->  sub_string(Html, 0, Before, _, Head),
        Start is Before + Length,
        sub_string(Html, Start, _, 0, Rest),
        sub_string(Rest, End, 1, _, "\""),
        !,
        sub_string(Rest, 0, End, _, Object),
        sub_string(Rest, End, _, 0, Tail),
        target(Object, Files, Target),
        rewrite(Tail, Files, StaticTail),
        string_concat(Head, "href=\"", Head1),
        string_concat(Head1, Target, Head2),
        string_concat(Head2, StaticTail, Static)
    ;   Static = Html
    ).

%!  target(+Object, +Files, -Url) is det.
%
%   Url is where the documentation of Object (Name/Arity) is on the site: its
%   anchor in the page of the example that defines it, or the manual.
target(Object, Files, Url) :-
    term_string(Name/Arity, Object),
    functor(Head, Name, Arity),
    member(File, Files),
    absolute_file_name(File, Path, [file_type(prolog), access(read)]),
    predicate_property(user:Head, file(Path)),
    !,
    file_name_extension(Base, _, File),
    format(string(Url), "~w.html#~w", [Base, Object]).
target(Object, _, Url) :-
    format(string(Url), "https://www.swi-prolog.org/pldoc/man?predicate=~w",
           [Object]).
