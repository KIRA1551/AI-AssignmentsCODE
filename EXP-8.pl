1.  Backward Chaining:

% FACTS
parent(john, mary).
parent(john, lisa).
parent(mary, ann).
parent(lisa, pat).

% RULES
% Rule 1: Base case - direct parent is an ancestor
ancestor(X, Y) :-
  parent(X, Y).

% Rule 2: Recursive case - X is an ancestor of Y if X is a parent of Z,
% and Z is an ancestor of Y.
ancestor(X, Y) :-
  parent(X, Z),
  ancestor(Z, Y).

% Example Queries for Backward Chaining:
% ?- ancestor(john, pat).
% ?- ancestor(X, ann).

2. Forward Chaining:

% FACTS
bird(sparrow).
bird(eagle).
mammal(cat).
mammal(dog).

% RULES
% Rule 3: Anything that is a bird can fly
can_fly(X) :-
  bird(X).

% Rule 4: Anything that is a mammal has fur
has_fur(X) :-
  mammal(X).

% Example Query for Forward Chaining (to find all things that can fly):
% ?- can_fly(X).


 ?- consult('path/to/family.pl').
 ?- ancestor(john, pat).
