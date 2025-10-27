% Define the initial state and its evaluation
initial_state(State) :-
    % Define your initial state here
    State = [1, 2, 3, 4].

% Define a predicate to evaluate the current state
evaluate(State, Value) :-
    % Define your evaluation function here
    sum_list(State, Value).

% Define a predicate to generate neighboring states
generate_neighbor(State, Neighbor) :-
    select(X, State, Rest), % Select an element X from the State
    member(Y, [1, 2, 3, 4]), % Generate a new element Y
    X \= Y, % Ensure the new element is different from X
    permutation([Y|Rest], Neighbor). % Generate Neighbor with Y in place of X

% Hill climbing algorithm
hill_climb(State, BestState) :-
    initial_state(CurrentState),
    hill_climb(CurrentState, 0, BestState).

% Recursive hill climbing algorithm with a stopping criterion
hill_climb(State, _, State) :-
    evaluate(State, Value),
    \+ generate_neighbor(State, _), % No better neighbors found
    write('Optimal solution found: '), write(State), write(' with value '), write(Value), nl.

hill_climb(State, PrevValue, BestState) :-
    evaluate(State, Value),
    write('Current state: '), write(State), write(' with value '), write(Value), nl,
    generate_neighbor(State, Neighbor),
    evaluate(Neighbor, NeighborValue),
    (NeighborValue > Value ->
        write('Found better neighbor: '), write(Neighbor), write(' with value '), write(NeighborValue), nl,
        hill_climb(Neighbor, Value, BestState)
    ;
        write('No better neighbors, stopping.'), nl,
        BestState = State
    ).