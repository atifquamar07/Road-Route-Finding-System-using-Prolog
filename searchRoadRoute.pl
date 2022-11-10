%------------------------------------------------------------------------------------------------------
% Including the heuristics and distance prolog files forming our knowledge base.
%------------------------------------------------------------------------------------------------------
:- [distance].
:- [heuristics].
:- style_check(-singleton).

%------------------------------------------------------------------------------------------------------
% Main Function, Program begins here.
%------------------------------------------------------------------------------------------------------

main:-
    writeln('-------------------------------------------------------------------------------------'),
    writeln('                WELCOME TO ROAD ROUTE FINDING SYSTEM'),
    writeln('-------------------------------------------------------------------------------------'), nl,
    writeln('This road route finding system will find path from source to destination '),
    writeln('using depth-first search and best-first search'), nl, 
    writeln('End each of your answers with a dot (.)'), nl, 
    
    writeln('Let us begin'), nl,
    writeln('How do you want to find the path to your destination?'), 
    writeln('Choose option 1 or 2.'), 
    writeln('1. Depth-First Search'),
    writeln('2. Best-First Search'), 
    read(Choice),
    check_option(Choice).


%------------------------------------------------------------------------------------------------------
% Functions used for printing lists.
%------------------------------------------------------------------------------------------------------

print_sol([Head|List]):- write(Head),write('->'),print_sol(List).
print_sol([]).

print_sol_bfs([[Head,Tail]|List]):- write(Head),write('->'),print_sol_bfs(List).
print_sol_bfs([]).

%------------------------------------------------------------------------------------------------------
% Option checking whether the input is for DFS or BFS.
% Option 1 is DFS
%------------------------------------------------------------------------------------------------------

check_option(Choice):-
    Choice is 1,
    write('Enter your source location '), 
    read(Source),
    write('Enter your destination location '), 
    read(Destination),

    retractall(place_to_reach(_)),
    assert(place_to_reach(Destination)),

    % calling depth-first function
    depthFirstSearch([], Source, Final_Ans, 0, FinalCost),
    reverse(Final_Ans, Reversed_Ans),
    nl, writeln("The path according to DFS is:-"),
    print_sol(Reversed_Ans), nl,
    nl, writeln("Distance travelled following the mentioned path is:-"),
    writeln(FinalCost).

%------------------------------------------------------------------------------------------------------
% Option 2 is BFS
%------------------------------------------------------------------------------------------------------

check_option(Choice):-
    Choice is 2,

    % Taking input
    write('Enter your source location '), 
    read(Source),
    write('Enter your destination location '), 
    read(Destination),

    % asseting the destination to be reached as a fact.
    retractall(place_to_reach(_)),
    assert(place_to_reach(Destination)),

    % calling best-first function
    bestFirstSearch(Source, Destination, Path, TotalDistanceTravelled),

    % reversing the path generated, as path generated is in reverse order.
    reverse(Path, Reversed_Ans),

    % printing the obtained path
    nl, writeln("The path according to BFS is:-"),
    print_sol_bfs(Reversed_Ans), nl,

    % printing the distance travelled using that path.
    nl, writeln("Distance travelled following the mentioned path is:-"),
    writeln(TotalDistanceTravelled).

%------------------------------------------------------------------------------------------------------
% Depth First Search Functions.
%------------------------------------------------------------------------------------------------------

depthFirstSearch(Path, Source, [Source|Path], CurrCost, FinalCost):-
    place_to_reach(Source),
    FinalCost is CurrCost.

depthFirstSearch(Path, Source, Final_Ans, CurrCost, FinalCost):-
    distance(Source, X, Y),
    \+member(X, Path),
    number(Y),
    NewCost is CurrCost + Y,
    depthFirstSearch([Source|Path], X, Final_Ans, NewCost, FinalCost).
    
%------------------------------------------------------------------------------------------------------
% Start of Best First Search
%------------------------------------------------------------------------------------------------------

bestFirstSearch(Start, Destination, PathFormed, TotalDistanceTravelled):-
    heuristics(Start, Destination, HeuristicsCalculated), !,
    initiateBFS([[Start, HeuristicsCalculated]], [], Destination, PathFormed),
    sizeList(PathFormed, 0, TotalDistanceTravelled).

%------------------------------------------------------------------------------------------------------
% Fucntion to calculate size of the list.
%------------------------------------------------------------------------------------------------------

sizeList([[Head1, _]|[[Head2, _]|Tail2]], Tail3, TotalDistance) :-
    tempPaths(Head1, Head2, PathDistance),
    TempDistance is Tail3 + PathDistance,
    sizeList([[Head2, _]|Tail2], TempDistance, TotalDistance).

sizeList([], Tail, Tail).

sizeList([[_TempHead, _]], Tail, Tail).

%------------------------------------------------------------------------------------------------------
% Initiation of Best-First Search is here.
%------------------------------------------------------------------------------------------------------

initiateBFS(_Open, [[Start, Head]| Tail], Destination, [[Start, Head]| Tail]):-
    Start = Destination, !.


initiateBFS(Unvisited, Closed, Destination, PathTravelled):-
    rearrange(Unvisited, [], [Front|Back]), customAppend(Front, Closed, TempVisited),
    neighbours(TempVisited, Unvisited, Destination, Front, Neighbours), combining(Neighbours, Back, TempUnvisited),
    initiateBFS(TempUnvisited, TempVisited, Destination, PathTravelled).

%------------------------------------------------------------------------------------------------------
% Merging the lists (in-between process)
%------------------------------------------------------------------------------------------------------

combining(A, [F|B], [F|O]):-
    \+(member(F,A)), 
    union(A, B, O).

combining(A, [F|B], O):-
    member(F,A), 
    union(A, B, O).

combining([],[],[]).

combining(A,[],A).

%------------------------------------------------------------------------------------------------------
% Checking the neighbours of the current node.
%------------------------------------------------------------------------------------------------------

neighbours(Visited, Unvisited, Destination, [Head, _], Neighbour):-
    bagof([Child, TempHead], ultimateHeuristics(Visited, Unvisited, Child, Destination, Head, TempHead), Neighbour).

%------------------------------------------------------------------------------------------------------
% Finding heuristics value.
%------------------------------------------------------------------------------------------------------
ultimateHeuristics(Visited, Unvisited, CloseNeighbour, Destination, Front, A):-
    tempPaths(Front, CloseNeighbour, _),
    not(member(CloseNeighbour, Visited)), not(member(CloseNeighbour, Unvisited)),
    heuristics(CloseNeighbour, Destination, A).

rearrange([], Same, Same).

rearrange([[InterHead, InterTail]|Tail], Temp, Arranged):-
    helperFunction(InterTail, Tail, ListOne, ListTwo),
    rearrange(ListOne, Temp, InterSorted),
    rearrange(ListTwo, [[InterHead, InterTail] | InterSorted], Arranged).

%------------------------------------------------------------------------------------------------------
% Addition of element in a list.
%------------------------------------------------------------------------------------------------------
customAppend(Head, [], [Head]).

customAppend(Head, [TempHead | Tail], [Head, TempHead | Tail]).


tempPaths(PlaceA, PlaceB, KM):-
    distance(PlaceA, PlaceB, KM).

tempPaths(PlaceA, PlaceB, KM):-
    distance(PlaceB, PlaceA, KM),
    \+distance(PlaceA, PlaceB, KM).

%------------------------------------------------------------------------------------------------------
% Helper Functions.
%------------------------------------------------------------------------------------------------------
helperFunction(_Head,[],[],[]).

helperFunction(Head,[[TempHead, TempTail]|Tail],[[TempHead, TempTail]|End], Find):-
    TempTail >= Head,
    helperFunction(Head, Tail, End, Find).

helperFunction(Head,[[TempHead, TempTail]|Tail], End,[[TempHead, TempTail]|Find]):-
    TempTail < Head,
    helperFunction(Head, Tail, End, Find).
