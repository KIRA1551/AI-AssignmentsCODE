% ---------- Initial and Goal States ----------
initial_state([on(a,table), on(b,table), on(c,a), clear(b), clear(c)]).
goal_state([on(a,b), on(b,table), on(c,table)]).

% ---------- Actions ----------
% move(Block, From, To, Preconditions, Effects)

move(Block, From, To,
     [on(Block, From), clear(Block), clear(To)],
     [on(Block, To), clear(From), \+ clear(To), \+ on(Block, From)]).

% ---------- State Transition ----------
apply_action(State, move(Block, From, To, _, _), NewState) :-
    select(on(Block, From), State, Temp1),
    select(clear(To), Temp1, Temp2),
    append([on(Block, To), clear(From)], Temp2, NewState).

% ---------- Depth First Search Planner ----------
dfs(State, Goal, _, []) :-
    satisfies(State, Goal), !.

dfs(State, Goal, Visited, [move(Block, From, To) | Plan]) :-
    move(Block, From, To, Preconditions, _),
    satisfies(State, Preconditions),
    apply_action(State, move(Block, From, To, Preconditions, _), NewState),
    \+ member(NewState, Visited),
    dfs(NewState, Goal, [NewState | Visited], Plan).

% ---------- Satisfies Predicate ----------
satisfies(State, []).
satisfies(State, [Cond | Rest]) :-
    member(Cond, State),
    satisfies(State, Rest).

% ---------- Main Planner ----------
plan(Plan) :-
    initial_state(Init),
    goal_state(Goal),
    dfs(Init, Goal, [Init], Plan).
