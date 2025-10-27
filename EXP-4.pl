% Sample graph represented by facts.
edge(a, b).
edge(a, c).
edge(b, d).
edge(b, e).
edge(c, f).
edge(c, g).
edge(d, h).
edge(d, i).

% BFS predicate
bfs(Start, Goal) :-
    bfs_queue([[Start]], Goal).
bfs_queue([[Goal|Path]|_], Goal) :-  % Goal found
    reverse([Goal|Path], Solution),
    write('Solution: '), write(Solution), nl.
bfs_queue([Path|Paths], Goal) :-
    extend(Path, NewPaths),
    append(Paths, NewPaths, UpdatedPaths),
    bfs_queue(UpdatedPaths, Goal).
extend([Node|Path], NewPaths) :-
    findall([NewNode, Node|Path],
            (edge(Node, NewNode), \+ member(NewNode, [Node|Path])),
            NewPaths),
    !. % Cut to prevent backtracking
extend(_, []). % No more extensions

% Sample usage:
% ?- bfs(a, f)


Code for Dfs:-
% Define a graph represented by facts
edge(a, b).
edge(a, c).
edge(b, d).
edge(b, e).
edge(c, f).

% DFS predicate
dfs(Start, End, Path) :-
    dfs_helper(Start, End, [], Path).

% Base case: Reached the destination
dfs_helper(Node, Node, Visited, [Node|Visited]).

% Recursive case: Traverse to adjacent nodes
dfs_helper(Current, End, Visited, Path) :-
    edge(Current, Next),
    \+ member(Next, Visited),  % Avoid revisiting nodes
    dfs_helper(Next, End, [Current|Visited], Path).

% Predicate to start DFS and print the result
dfs_start(Start, End) :-
    dfs(Start, End, Path),
    reverse(Path, PathReversed),
    format("DFS path from ~w to ~w: ~w", [Start, End, PathReversed]).










]