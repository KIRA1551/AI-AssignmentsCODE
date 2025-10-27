% blocks_planner.pl
% Simple Blocks World planner using DFS
% State representation: list of ground literals, e.g. [on(a,table), on(c,a), clear(c), ...]
% We keep states normalized by sorting terms (so order doesn't matter)

:- module(blocks_planner, [plan/1, show_state/1, initial_state/1, goal_state/1]).

% ---------- Initial and Goal States ----------
initial_state([on(a,table), on(b,table), on(c,a), clear(b), clear(c)]).
goal_state([on(a,b), on(b,table), on(c,table)]).

% ---------- Actions ----------
% move(Block, From, To, Preconditions, Adds, Deletes)
move(Block, From, To,
     [on(Block, From), clear(Block), clear(To)],
     [on(Block, To), clear(From)],
     [on(Block, From), clear(To)]).

% ---------- State utilities ----------
% normalize a state (sort terms so order doesn't matter)
normalize(State, Norm) :- sort(State, Norm).

% check that all Preconditions are present in State
satisfies(State, Preconditions) :-
    forall(member(P, Preconditions), member(P, State)).

% apply action: remove Deletes, add Adds, produce normalized NewState
apply_action(State, move(Block,From,To,Pre,Adds,Deletes), NewState) :-
    satisfies(State, Pre),
    % Remove each Delete literal if present
    foldl(remove_fact, Deletes, State, TempState),
    % Add Adds if not already present
    foldl(add_fact, Adds, TempState, TempState2),
    normalize(TempState2, NewState).

remove_fact(Fact, StateIn, StateOut) :-
    (   select(Fact, StateIn, R) -> StateOut = R ; StateOut = StateIn ).

add_fact(Fact, StateIn, StateOut) :-
    (   member(Fact, StateIn) -> StateOut = StateIn ; StateOut = [Fact|StateIn] ).

% ---------- Depth-First Search Planner ----------
% plan(-Plan)
plan(Plan) :-
    initial_state(Init0),
    goal_state(Goal0),
    normalize(Init0, Init),
    normalize(Goal0, Goal),
    dfs(Init, Goal, [Init], Plan).

% dfs(CurrentState, GoalState, VisitedStates, Plan)
dfs(State, Goal, _, []) :-
    subset(Goal, State), !.           % if Goal literals are in State, we're done

dfs(State, Goal, Visited, [move(Block,From,To)|Plan]) :-
    move(Block, From, To, Pre, Adds, Deletes),
    apply_action(State, move(Block,From,To,Pre,Adds,Deletes), NewState),
    normalize(NewState, NewStateN),
    \+ member(NewStateN, Visited),
    dfs(NewStateN, Goal, [NewStateN|Visited], Plan).

% subset/2: true if every element of Small is a member of Big
subset([], _).
subset([H|T], Big) :- member(H, Big), subset(T, Big).

% helper to print a state in readable format
show_state(State) :-
    sort(State, S),
    writeln('State:'),
    forall(member(F, S), (write('  '), writeln(F))).