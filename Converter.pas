unit Converter;

interface

uses RegularExpression, Automaton;

function regexToNondeterministic(exp: RegularExpression.PNode): Automaton.PAutomaton;

implementation

// rekurzivní tělo metody
procedure regexToNondeterministic_body(
    aut: Automaton.PAutomaton;
    exp: RegularExpression.PNode;

    // mezi těmito dvěma uzly se má vytvořit pod-automat
    initial: Automaton.PState;
    final: Automaton.PState
);
// pomocné proměnné pro ukládání stavů
var s: Automaton.PState;
begin
    if RegularExpression.isNodeOfType(exp, NODE_TYPE__SYMBOL) then begin
        Automaton.createSymbolEdge(
            aut, initial, final,
            RegularExpression.PSymbolNode(exp)^.symbol
        );
    end else if RegularExpression.isNodeOfType(exp, NODE_TYPE__CONCATENATION) then begin
        s := Automaton.createState(aut, false, false);
        regexToNondeterministic_body(
            aut, RegularExpression.PBinaryOperatorNode(exp)^.a, initial, s);
        regexToNondeterministic_body(
            aut, RegularExpression.PBinaryOperatorNode(exp)^.b, s, final);
    end else if RegularExpression.isNodeOfType(exp, NODE_TYPE__ALTERNATION) then begin
        regexToNondeterministic_body(
            aut, RegularExpression.PBinaryOperatorNode(exp)^.a, initial, final);
        regexToNondeterministic_body(
            aut, RegularExpression.PBinaryOperatorNode(exp)^.b, initial, final);
    end else if RegularExpression.isNodeOfType(exp, NODE_TYPE__KLEENE) then begin
        s := Automaton.createState(aut, false, false);
        Automaton.createEpsilonEdge(aut, initial, s);
        regexToNondeterministic_body(
            aut, RegularExpression.PUnaryOperatorNode(exp)^.a, s, s);
        Automaton.createEpsilonEdge(aut, s, final);
    end else begin
        writeln('ERROR! regexToNondeterministic_body() - unsupported node type');
        halt;
    end;
end;

{**
 * Převede regulární výraz na nedeterministický automat
 *}
function regexToNondeterministic(exp: RegularExpression.PNode): Automaton.PAutomaton;
var aut: Automaton.PAutomaton;
var initial, final: Automaton.PState;
begin
    // vytvoříme prázdný automat
    aut := Automaton.createAutomaton();

    // přidáme do něho počáteční a koncový stav
    initial := Automaton.createState(aut, true, false);
    final := Automaton.createState(aut, false, true);

    // a vytvoříme tělo automatu rekurzivně
    regexToNondeterministic_body(aut, exp, initial, final);

    // a vrátíme ho
    regexToNondeterministic := aut;
end;

end.