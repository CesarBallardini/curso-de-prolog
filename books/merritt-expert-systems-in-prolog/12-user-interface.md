# User Interface

<!-- page 121 -->
The user interface issues for expert system shells can be divided between two classes of users and two different levels. The two users are the developer and the end-user of the application. The levels are the external interface and the internal function.

For the developer, the internal function must be adequate before the external interface becomes a factor. To build a configuration application, an easy-to-use backward chaining system is not as good as a hard-to-use forward chaining system. To build a large configuration system, an easy-to-use, low performance forward chaining system is not as good as a hard-to-use, high performance forward chaining system.

The same is true for the end-user. While there is increasing awareness of the need for good external interfaces, it should not be forgotten that the internal function is still the heart of an application. If a doctor wants a diagnostic system to act as an intelligent assistant and instead it acts as an all knowing guru, then it doesn't matter how well the external interface is designed. The system will be a failure. If a system can save a company millions of dollars by more accurately configuring computers, then the system will be used no matter how poor the external interface is.

Given that a system meets the needs of both the developer and the end-user, then the external interface becomes an essential ingredient in the satisfaction with the system. The systems developed so far have used a command driven, dialog type user interface. Increasingly windows, menus, and forms are being used to make interfaces easier to understand and work with. This chapter describes how to build the tools necessary for developing good user interfaces. 9.1 Object Oriented Window Interface

One of the major difficulties with computer languages in general, and Prolog in particular, is the lack of standards for user interface features. There are emerging standards, but there is still a long way to go. The windowing system described here includes a high-level, object oriented interface for performing common window, menu and form operations, which can be used with any Prolog or computer. The low level implementation will vary from Prolog to Prolog, and computer to computer.

The interface is object-oriented in that each window, menu and form in the system is considered to be a "window-object" that responds to messages requesting various behaviors. For example, a display window would respond to "write" messages, and both a menu and prompt window would respond to a "read" message.

The developer using the system defines window-objects to be used in an application and then uses a single predicate, window, to send messages to them. The system can be easily extended to include new messages and window-objects. For example, graphics can be included for systems that support it. 9.2 Developer's Interface to Windows

The windows module provides for overlapping windows of four basic flavors.

display — an output only window. The user may scroll the window up and down

using the cursor keys.

menu — a pop-up vertical menu.

form — a fill-in-the-blanks form.

<!-- page 122 -->
*Building Expert Systems in Prolog*

prompt — a one line input window.

The programmer creates the various windows by specifying their attributes with a create message. Other window messages are used to open, close, read or write the window.

All of the window operations are performed with the predicate window. It can either be specified with two or three arguments, depending on whether the message requires an argument list. The arguments are:

- the window-object name or description,

- the operation to be performed (message),

- the arguments for the operation (optional).

For example, the following Prolog goals cause a value to be selected from a main menu, a value to be written to a display window, and a useless window to be closed:

```prolog
window(main_menu, read, X).
window(listing, write, 'Hello').
window(useless, close).
```

A window description is a list of terms. The functors describe the attribute, and the arguments are the value(s). Some of the attributes used to define a window are:

type(T) — type of window (display, prompt, menu, or form),

coord(R1, C1, R2, C2) — the upper left and lower right coordinates of useable

window space,

border(Color) — the border color,

contents(Color) — the color of the contents of the window.

The following two attributes are used to initialize menus and forms:

menu(List) — List is a list of menu items.

form(Field_List) — Field_List defines the fields in the form. The field may be either

a literal or a variable. The two formats are:

```prolog
lit(Row:Col, Literal),
var(FieldName, Row:Col, Length, InitialValue).
```

Some examples of window descriptions are:

```prolog
[type(display), coord(2, 3, 10, 42), border(white:blue),
contents(white:blue)]
[type(menu), coord(10, 50, 12, 70), border(bright:green),
menu(['first choice',
'second choice',
'third choice',
'fourth choice'])]
[type(form), coord(15, 34, 22, 76), border(blue),
form([lit(2:2, 'Field One'),
var(one, 2:12, 5, ''),
lit(4:2, 'Field Two'),
var(two, 4:12, 5, 'init')])]
```

The first argument of each window command refers to a window-object. It may either be the name of a created window or a window description. If a description is used, the window is created and used only for the duration of the command. This is useful for pop up menus, prompts and forms. Created windows are more permanent.

112

<!-- page 123 -->
*Chapter 9 - User Interface* Some of the messages which can be sent to windows are:

window(W, create, Description) — stores the Description with the name W;

window(W, open) — opens a window by displaying it as the current top window

(usually not necessary since most messages open a window first);

window(W, close) — closes the window by removing the viewport from the screen

while preserving the contents (for later re-opening);

window(W, erase) — closes the window, and erases the contents as well;

window(W, display, X) — writes the term X to the window.

To use the windows to improve the user interface of a simple expert system shell, the main menu can be made a pop-up menu. The text for questions to the user can appear in one window, and the user can respond using pop-up menus or prompt windows. The advice from the system can appear in another window.

Load

Consult

Explain

Trace

Quit

*Figure 9.1 Main menu*

First, the permanent windows are created during the initialization phase. The descriptions are stored in Prolog's database with the window name for use when the window is referenced. The windows for a simple interface include the main menu, the window for advice, and the window for questions to the user:

```prolog
window_init:-
window(wmain, create,
[type(menu), coord(14, 25, 21, 40),
border(blue), contents(yellow),
menu(['Load',
'Consult',
'Explain',
'Trace',
'Quit'])]),
window(advice, create,
[type(display), coord(1, 1, 10, 78),
border(blue:white), contents(blue:white)]),
window(quest, create,
[type(display), coord(13, 10, 13, 70),
border(blue:white), contents(blue:white)]).
```

The main loop then uses the main menu:

```prolog
go :-
repeat,
```

<!-- page 124 -->
*Building Expert Systems in Prolog*

```prolog
window(wmain, read, X),
do(X),
fail.
```

The user sees a menu as in figure 9.1. The cursor keys move the highlighting bar, and the enter key selects a menu item. The ask and menuask predicates in the system use the windows to get information from the user. First ask writes the text of the question to the quest window, and then generates a pop-up prompt:

```prolog
ask(A, V) :-
window(quest, write, A),
window([type(prompt), coord(16, 10, 16, 70),
border(white:blue),
contents(white:blue)],
read, ['', Y]),
asserta(known(A, Y)),
...
```

The menuask predicate also writes the text of the question to the quest window, but then dynamically builds a pop-up menu, computing the size of the menu from the length of the menu list:

```prolog
menuask(Attribute, AskValue, Menu):-
length(Menu, L),
R1 = 16,
R2 is R1 + L - 1,
window(quest, write, Attribute),
window([type(menu), coord(R1, 10, R2, 40),
border(white:blue),
contents(white:blue), menu(Menu)],
read, Value),
asserta(known(Attribute, Value)),
...
```

Figure 9.2 shows how a simple window interface would look with the Birds expert system.

consult quit

goal − bird identification

hypothesis − laysay_albatross

what is color?

white

dark

green

*Figure 9.2 Window interface for dialog with Birds system* 9.3 High-Level Window Implementation

The window module is constructed in layers. The top layer can be used with any Prolog. The lower layers have the actual implementations of the windows and vary from system to

114

<!-- page 125 -->
*Chapter 9 - User Interface* system. The detailed examples will come from a Macintosh based Prolog (AAIS) using a rich user interface toolbox, and a PC based Prolog (Arity) using simple screen primitives.

### Message Passing

At the top level, the interface is object oriented. This means messages are sent to the individual windows. One feature of object oriented systems is that messages are dispatched at run time based on the class of object. For example, the read message applies to both the prompt windows and the menu windows, but the implementation is different in each case. The implementations are called methods. The window predicate must determine what type of window is receiving the message, and what the correct method to call is:

```prolog
window(W, Op, Args):-
get_type(W, T),
find_proc(T, Op, Proc),
P =.. [Proc, W, Args],
call(P),
!.
```

The get_type predicate finds the type of the window, find_proc gets the correct method to call, and univ (=..) is used to call it.

When window is called with a window description as the first argument, it creates a temporary window, sends the message to it, and then deletes it. A two argument version of window is used to capture calls with no arguments.

```prolog
window([H|T], Op, Args):-
window(temp_w, create, [H|T]),
window(temp_w, Op, Args),
window(temp_w, delete),
!.
window(W, Op) :-
window(W, Op, []).
```

The get_type predicate uses select_parm to find the value for the type attribute of the window. It uses the stored window definition.

```prolog
get_type(W, X):-
select_parm(W, [type(X)]),
!.
```

Window definitions are stored in structures of the form:

```prolog
wd(W, AttributeList).
```

### Inheritance

Another feature of object oriented systems is inheritance of methods. The objects are arranged in a class hierarchy, and lower level objects only have methods defined for them that are different from the higher level methods. In the window program, type(window) is the highest class, and the other types are subclasses of it. A predicate such as close is only defined for the window superclass and not redefined for the subclasses.

This makes it easy to add new window types to the system. The new types can inherit many of the methods of the existing types.

The classes are represented in Prolog using a subclass predicate:

<!-- page 126 -->
*Building Expert Systems in Prolog*

```prolog
subclass(window, display).
subclass(window, menu).
subclass(window, form).
subclass(window, prompt).
```

The methods are associated with classes by a method predicate. Some of the defined methods are:

```prolog
method(window, open, open_w).
method(window, close, close_w).
method(window, create, create_w).
method(window, display, display_w).
method(window, delete, delete_w).
method(display, write, write_d).
method(display, writeline, writeline_d).
method(menu, read, read_m).
method(form, read, read_f).
method(prompt, read, read_p).
```

The find_proc predicate is the one that looks for the correct method to call for a given message and a given window type.

```prolog
find_proc(T, Op, Proc):-
find_p(T, Op, Proc),
!.
find_proc(T, Op, Proc):-
error([Op, 'is illegal operation for a window of type', T]).
find_p(T, Op, Proc):- method(T, Op, Proc),
!.
find_p(T, Op, Proc):-
subclass(Super, T),
!,
find_p(Super, Op, Proc).
```

This completes the definition of the high level interface, with the exception of the one utility predicate, select_parm. It is used by get_type to find the value of the type attribute, but is also heavily used by the rest of the system to find attributes of windows, such as coordinates. It has the logic built into it to allow for calculated attributes, such as height, and attribute defaults. It is called with a request list of the desired attributes. For example, to get a window's coordinates, height, and color:

```prolog
select_parm(W, [coord(R1, C1, R2, C2), height(H),
color(C)]).
```

The select_parm predicate gets the windows attribute list, and calls the fulfill predicate to unify the variables in the request list with the values of the same attributes in the window definition.

```prolog
select_parm(W, RequestList):-
wd(W, AttrList),
fulfill(RequestList, AttrList),
!.
```

The fulfill predicate recurses through the request list, calling w_attr each time to get the value for a particular attribute.

```prolog
fulfill([], _):- !.
fulfill([Req|T], AttrList):-
w_attr(Req, AttrList),
!,
fulfill(T, AttrList).
```

116

<!-- page 127 -->
*Chapter 9 - User Interface* The w_attr predicate deals with three cases. The first is the simple case that the requested attribute is on the list of defined attributes. The second is for attributes that are calculated from defined attributes. The third sets defaults when the first two fail. Here are some of the w_attr clauses:

```prolog
w_attr(A, AttrList):-
member(A, AttrList),
!.
% calculated attributes
w_attr(height(H), AttrList):-
w_attr(coord(R1, _, R2, _), AttrList),
H is R2 - R1 + 1,
!.
w_attr(width(W), AttrList):-
w_attr(coord(_, C1, _, C2), AttrList),
W is C2 - C1 + 1,
!.
% default attributes
w_attr(title(''), _).
w_attr(border(white), _).
w_attr(contents(white), _).
w_attr(type(display), _).
```

**9.4 Low-Level Window Implementation**

In addition to being a powerful language for artificial intelligence applications, Prolog is good at implementing more standard types of programs as well. Since most programs can be specified logically, Prolog is a very efficient tool. While we will not look at all the details in this chapter, a few samples from the low-level implementation should demonstrate this point. An entire overlapping window system with reasonable response time was implemented 100% in Prolog using just low-level screen manipulation predicates.

The first example shows predicates that give the user control over a menu. They follow very closely the logical specification of a menu driver. A main loop, menu_select, captures keystrokes, and then there are a number of rules, m_cur, governing what to do when various keys are hit. Here is the main loop for the Arity Prolog PC implementation:

```prolog
menu_select(W, X):-
select_parm(W, [coord(R1, C1, R2, _), width(L), attr(A)]),
tmove(R1, C1),  % move the cursor to first item
revideo(L, A),  % reverse video first item
repeat,
keyb(_, S),  % read the keyboard
m_cur(S, Z, w(W, R1, R2, C1, L, A)),  % usually fails
!,
Z = X.
```

Here are four of the menu rules covering the cases where: the down arrow (scan code of 80) is hit (highlight the next selection); the down arrow is hit at the bottom of the menu (scroll the menu); the home key (scan code of 71) is hit (go to the top); and the enter key (scan code of 28) is hit (finally succeed and select the item).

```prolog
m_cur(80, _, w(W, R1, R2, C1, L, A)):-  % down arrow
tget(R, _),
R < R2,
normvideo(L, A),
RR is R + 1,
tmove(RR, C1),
revideo(L, A),
!,
fail.
```

<!-- page 128 -->
*Building Expert Systems in Prolog*

```prolog
m_cur(80, _, w(W, R1, R2, C1, L, A)):-  % bottom down arrow
tget(R, _),
R >= R2,
normvideo(L, A),
scroll_window(W, 1),
tmove(R2, C1),
revideo(L, A),
!,
fail.
m_cur(71, _, w(W, R1, R2, C1, L, A)):-  % home key
normvideo(L, A),
scroll_window(W, top),
tmove(R1, C1),
revideo(L, A),
!,
fail.
m_cur(28, X, w(W, R1, R2, C1, L, A)):-  % enter key
tget(R, _),
select_stat(W, curline, Line),  % current line
Nth is Line + R - R1,
getnth(W, Nth, X),
normvideo(L, A),
!.
```

Here is some of the code that deals with overlapping windows. When a window is opened, the viewport, which is the section of the screen it appears in, is initialized. The system maintains a list of active windows, where the list is ordered from the top window to the bottom. In the case covered here, the window to be opened is already on the active list, but not on the top.

```prolog
make_viewport(W):-
retract(active([H|T])),
save_image(H),
split(W, [H|T], L1, L2),
w_chkover(W, L1, _),
append([W|L1], L2, NL),
assert(active(NL)).
```

The save_image predicate stores the image of the top window for redisplay if necessary. The split predicate is a list utility, which splits the active list at the desired window name. Next, w_chkover decides if the window needs to be redrawn due to overlapping windows on top of it, and then a new active list is constructed with the requested window on top.

The w_chkover predicate recurses through the list of windows on top of the requested window, checking each one for the overlap condition. If any window is overlapping, then the requested window is redrawn. Otherwise nothing needs to be done.

```prolog
w_chkover(W, [], no).
w_chkover(W, [H|T], Stat):-
w_nooverlap(W, H),
w_chkover(W, T, Stat).
w_chkover(W, _, yes):-
restore_image(W),
!.
```

An overlap is detected by simply comparing the coordinates of the two windows.

```prolog
w_nooverlap(Wa, Wb):-
select_parm(Wa, [coord(R1a, C1a, R2a, C2a)]),
select_parm(Wb, [coord(R1b, C1b, R2b, C2b)]),
(R1a > R2b + 2;
R2a < R1b - 2;
C1a > C2b + 2;
C2a < C1b - 2),
```

118

<!-- page 129 -->
*Chapter 9 - User Interface*

```prolog
!.
```

As opposed to the PC implementation, which requires coding to the detail level, the Macintosh implementation uses a rich toolbox of primitive building blocks. However, the complexity of the toolbox sometimes makes it more difficult to perform simple operations. For example, to make a new window in the PC version, all that is necessary is to save the window definition:

```prolog
make_window(W, Def):-
asserta( wd(W, Def)).
```

In the Macintosh version, a number of parameters and attributes must be set up to interface with the Macintosh environment. The code to create a new window draws heavily on a number of built-in AAIS Prolog predicates that access the Macintosh toolbox.

```prolog
make_window(W, L) :-
define(wd, 2),
include([window, quickdraw, types, memory]),
fulfill([coord(R1, C1, R2, C2), title(T), visible(V),
procid(Pid), behind(B), goaway(G),
refcon(RC)], L),
new_record(rect, R),
new_record(windowptr, WP),
setrect(R, C1, R1, C2, R2),
pname(T, Tp),
newwindow(WP, R, Tp, V, Pid, B, G, RC, WPtr),
asserta( wd(W, [wptr(WPtr)|L]) ).
```

Notice that the special Macintosh window parameters are easily represented using the window attribute lists of the generic windows. The example above has attributes for goaway, a box the user can click to make a window go away, and refcon for attaching more sophisticated functions to windows. The select_parm predicate has intelligent defaults set for each of these parameters so the user does not have to worry about specifying them.

```prolog
w_attr(goaway(false), _).
w_attr(refcon(0), _).
```

The generic window interface we developed recognizes a few fundamental types of window. The Macintosh also has numerous window types. The w_attr predicate is used to calculate values for the Macintosh parameters based on the generic parameters. The user only sees the generic parameters. Internally, the Macintosh parameters are used. Here is how the internal routines get a value for the Macintosh based parameter wproc, which controls the type of box the window is drawn in:

```prolog
w_attr(wproc(documentproc), L) :-
akindof(text, L),
!.
w_attr(wproc(dboxproc), L) :-
akindof(dialog, L),
!.
w_attr(wproc(plaindbox), L) :-
akindof(graph, L),
!.
```

The akindof predicate checks type against the inheritance specified by the subclass predicate defined earlier.

```prolog
akindof(ST, L) :-
w_attr(type(T), L),
subsub(ST, T),
```

<!-- page 130 -->
*Building Expert Systems in Prolog*

```prolog
!.
subsub(X, X).
subsub(Y, X) :-
subclass(C, X),
subsub(Y, C).
```

As more toolboxes for user interface functions become available, such as Presentation Manager, the low level portions of this window package can be modified to take advantage of them. At the same time the simple object oriented high level interface described earlier can be maintained for easy application development and portability.

## Exercises

9.1 Implement object oriented windows on the Prolog system you use. 9.2 Add windowing interfaces to all of the expert system shells developed so far. 9.3 Add controls as a window type. These are display windows that use a graphical image to represent a number. The easiest graphical control to implement is a thermometer in a text based system (such as the IBM PC in text mode). The controls can also contain digital readouts, which is of course even easier to implement. 9.4 Active images are controls which automatically display the contents of some variable in a system. For example, in the furniture placement system it would be interesting to have four controls that indicate the available space on each of the four walls. They can be elegantly implemented using the attached procedure in the add slot of the frames. Whenever a new value is added, the procedure sends it to the control window. (Note that add is called during update of the slot in this implementation.) 9.5 In the windowing interface for the various shells, have trace information appear in a separate window. 9.6 Add graphics windows to the system if your version of Prolog can support it. 9.7 In the main control loop, recognize certain user actions as a desire to manipulate the windows. For example, function keys might allow the user to pop various windows to the top. This would enable the system to keep trace information in one window, which is overlapped by the main window. The user could access the other windows by taking the appropriate actions.

120

*Chapter 9 - User Interface*
