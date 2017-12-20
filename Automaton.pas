unit Automaton;

interface

uses List, sysutils, RegularExpression;

type
    // pointery se nadefinují dopředu
    PState = ^TState;
    PEdge = ^TEdge;
    PSymbolEdge = ^TSymbolEdge;
    PRegexEdge = ^TRegexEdge;
    PAutomaton = ^TAutomaton;

    {**
     * Stav automatu
     *}
    TState = record
        // jedná se o začáteční nebo koncový stav?
        isInitial: boolean;
        isFinal: boolean;

        // seznam hran které odsud vedou
        edges: PList;
    end;

    {**
     * Obecná hrana (přechod stavů)
     *}
    TEdge = record
        edgeType: byte;
        origin, target: PState;
    end;

    {**
     * Hrana s jedním symbolem
     *}
    TSymbolEdge = record
        edgeType: byte;
        origin, target: PState;
        symbol: char;
    end;

    {**
     * Hrana s regulárním výrazem
     *}
    TRegexEdge = record
        edgeType: byte;
        origin, target: PState;
        expression: RegularExpression.PNode;
    end;

    {**
     * Reprezentuje celý automat
     *}
    TAutomaton = record
        // seznam stavů
        states: PList;

        // počáteční stavy
        initialStates: PList;

        // koncové stavy
        finalStates: PList;

        // seznam hran
        edges: PList;
    end;

function createAutomaton(): PAutomaton;
procedure destroy(aut: PAutomaton);
function createState(aut: PAutomaton; isInitial, isFinal: boolean): PState;
function createSymbolEdge(aut: PAutomaton; origin, target: PState; symbol: char): PEdge;
function createEpsilonEdge(aut: PAutomaton; origin, target: PState): PEdge;
procedure destroyEdge(edge: PEdge);
procedure makeStateInitial(aut: PAutomaton; state: PState);
procedure makeStateFinal(aut: PAutomaton; state: PState);

function serializeStates(aut: PAutomaton): AnsiString;
function serializeEdge(aut: PAutomaton; edge: PEdge): AnsiString;

// typy přechodů
const EDGE_TYPE__SYMBOL = 100;
const EDGE_TYPE__REGEX = 200;

implementation

// zase helper - ukazatel na byte
type PByte = ^byte;

{**
 * Kontroluje, zda je hrana daného typu
 *}
function isEdgeOfType(edge: PEdge; edgeType: byte): boolean;
begin
    if edge = nil then begin
        writeln('ERROR! isEdgeOfType, nil given');
        halt;
    end;

    isEdgeOfType := PByte(edge)^ = edgeType;
end;

{**
 * Vytvoří instanci prázdného automatu
 *}
function createAutomaton(): PAutomaton;
begin
    new(createAutomaton);
    createAutomaton^.states := nil;
    createAutomaton^.initialStates := nil;
    createAutomaton^.finalStates := nil;
    createAutomaton^.edges := nil;
end;

{**
 * Uvolní automat z paměti
 *}
procedure destroy(aut: PAutomaton);
var p: PList;
begin
    p := aut^.states;
    while p <> nil do begin
        dispose(PState(p^.item));
        p := p^.next;
    end;
    List.destroy(aut^.states);

    p := aut^.edges;
    while p <> nil do begin
        destroyEdge(PEdge(p^.item));
        p := p^.next;
    end;
    List.destroy(aut^.edges);

    dispose(aut);
end;

{**
 * Vytvoří v automatu nový stav
 *}
function createState(aut: PAutomaton; isInitial, isFinal: boolean): PState;
var state: PState;
begin
    new(createState);
    createState^.isInitial := isInitial;
    createState^.isFinal := isFinal;
    createState^.edges := nil;

    List.append(aut^.states, createState);
    
    if isInitial then
        List.append(aut^.initialStates, createState);

    if isFinal then
        List.append(aut^.finalStates, createState);
end;

{**
 * Udělá ze stavu počáteční stav
 *}
procedure makeStateInitial(aut: PAutomaton; state: PState);
begin
    if state^.isInitial then
        exit;

    state^.isInitial := true;
    List.append(aut^.initialStates, state);
end;

{**
 * Udělá ze stavu koncový stav
 *}
procedure makeStateFinal(aut: PAutomaton; state: PState);
begin
    if state^.isFinal then
        exit;

    state^.isFinal := true;
    List.append(aut^.finalStates, state);
end;

{**
 * Vytvoří v automatu novou symbolovou hranu
 *}
function createSymbolEdge(aut: PAutomaton; origin, target: PState; symbol: char): PEdge;
var edge: PSymbolEdge;
begin
    new(edge);
    edge^.edgeType := EDGE_TYPE__SYMBOL;
    edge^.origin := origin;
    edge^.target := target;
    edge^.symbol := symbol;

    List.append(aut^.edges, edge);
    List.append(origin^.edges, edge);

    createSymbolEdge := PEdge(edge);
end;

{**
 * Vytvoří v automatu epsilonový přechod
 *}
function createEpsilonEdge(aut: PAutomaton; origin, target: PState): PEdge;
begin
    createEpsilonEdge := createSymbolEdge(aut, origin, target, #0);
end;

{**
 * Uvolní hranu z paměti (velikost podle typu)
 *}
procedure destroyEdge(edge: PEdge);
begin
    if isEdgeOfType(edge, EDGE_TYPE__SYMBOL) then begin
        dispose(PSymbolEdge(edge));
    end else if isEdgeOfType(edge, EDGE_TYPE__REGEX) then begin
        RegularExpression.destroyExpression(PRegexEdge(edge)^.expression);
        dispose(PRegexEdge(edge));
    end;
end;

///////////////////
// Serialization //
///////////////////

{**
 * Serializuje seznam stavů automatu
 *}
function serializeStates(aut: PAutomaton): AnsiString;
var p: PList;
begin
    serializeStates := '';
    p := aut^.states;

    while p <> nil do begin
        if PState(p^.item)^.isInitial and (not PState(p^.item)^.isFinal) then begin
            serializeStates += 'I';
        end else if PState(p^.item)^.isFinal and (not PState(p^.item)^.isInitial) then begin
            serializeStates += 'F';
        end else if PState(p^.item)^.isFinal and PState(p^.item)^.isInitial then begin
            serializeStates += 'T';
        end else begin
            serializeStates += 'X';
        end;

        p := p^.next;
    end;
end;

{**
 * Serializuje jednu hranu
 *}
function serializeEdge(aut: PAutomaton; edge: PEdge): AnsiString;
begin
    serializeEdge := IntToStr(List.indexOf(aut^.states, edge^.origin)) + ' ' +
        IntToStr(List.indexOf(aut^.states, edge^.target)) + ' ';

    if isEdgeOfType(edge, EDGE_TYPE__SYMBOL) then begin
        if PSymbolEdge(edge)^.symbol = #0 then begin
            // extra práce s epsilonama
            serializeEdge += 'E';
        end else begin
            serializeEdge += 'S ' + PSymbolEdge(edge)^.symbol;
        end;
    end else if isEdgeOfType(edge, EDGE_TYPE__REGEX) then begin
        serializeEdge += 'R ' + RegularExpression.serializePrefix(
                PRegexEdge(edge)^.expression
            );
    end;
end;

/////////////
// Parsing //
/////////////

// ...

end.