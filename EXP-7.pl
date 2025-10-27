% --- Define the initial state ---
initial_state([1, 2, 3, 4]).

% --- Define an evaluation function ---
% Example: sum of all elements
evaluate(State, Value) :-
    sum_list(State, Value).

% --- Generate a neighboring state ---
generate_neighbor(State, Neighbor) :-
    select(X, State, Rest),          % Pick an element X and get remaining list
    member(Y, [1, 2, 3, 4]),         % Choose a possible replacement Y
    X \= Y,                          % Make sure it’s different
    select(Y, Neighbor, Rest).       % Replace X with Y in the new list

% --- Hill climbing main predicate ---
hill_climb(BestState) :-
    initial_state(Init),
    evaluate(Init, Value),
    write('Starting from: '), write(Init), write(' with value '), write(Value), nl,
    hill_climb_step(Init, Value, BestState).

% --- Recursive step ---
hill_climb_step(State, Value, BestState) :-
    findall((N,V), (generate_neighbor(State, N), evaluate(N, V)), Neighbors),
    (   Neighbors = [] ->
        write('No neighbors left. Optimal state: '), write(State), write(' with value '), write(Value), nl,
        BestState = State
    ;
        max_member((BestNeighbor, BestValue), Neighbors),
        (   BestValue > Value ->
            write('Moving to better state: '), write(BestNeighbor), write(' with value '), write(BestValue), nl,
            hill_climb_step(BestNeighbor, BestValue, BestState)
        ;
            write('No better neighbor found. Stopping at: '), write(State), write(' with value '), write(Value), nl,
            BestState = State
        )
    ).

# Right the below code in SWI-Prolog.
?- [ 'C:/Users/ABDUL REHMAN/OneDrive/Documents/Prolog/hill_climb.pl' ].
?- hill_climb(Result).