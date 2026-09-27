
remove(A) :-
	retract(right_to(A, B)),
	retract(right_to(C, A)).

left_to(A, B) :-
	right_to(B, A).
