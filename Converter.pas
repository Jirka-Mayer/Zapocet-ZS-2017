unit Converter;

interface

uses RegularExpression, Automaton, List;

function regexToNondeterministic(exp: RegularExpression.PNode): Automaton.PAutomaton;
function nondeterministicToRegex(aut: Automaton.PAutomaton): RegularExpression.PNode;

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

{**
 * Převede nedeterministický automat na regulární výraz
 * (destruktivně, automat se při tom zničí)
 *}
function nondeterministicToRegex(aut: Automaton.PAutomaton): RegularExpression.PNode;
var initial, final: Automaton.PState;
var s, input, output: List.PList;
var inputs, outputs: List.PList;
var loop: Automaton.PRegexEdge;
begin
    // přidáme (hlavní) počáteční a koncový vrchol
    // (ale nebudou mít flag, aby nebyly v seznamech)
    initial := Automaton.createState(aut, false, false);
    final := Automaton.createState(aut, false, false);

    // spojím je epsilon přechodem s ostatními
    s := aut^.initialStates;
    while s <> nil do begin
        Automaton.createEpsilonEdge(aut, initial, Automaton.PState(s^.item));
        s := s^.next;
    end;

    s := aut^.finalStates;
    while s <> nil do begin
        Automaton.createEpsilonEdge(aut, Automaton.PState(s^.item), final);
        s := s^.next;
    end;

    // hrany převedeme na regex typ
    Automaton.edgesToRegex(aut);

    // jdeme přes všechny stavy mezi počátečním a koncovým
    s := aut^.states;
    while s <> nil do begin
        // přes všechny stavy krom začátečního a koncového
        if (s^.item = initial) or (s^.item = final) then begin
            s := s^.next;
            continue;
        end;

        // DEBUG
        //Automaton.printAutomaton(aut);

        // najdeme smyčku a vyzobneme ji
        // (musí být první - smyčka je jak vstup, tak výstup)
        loop := Automaton.PRegexEdge(
            Automaton.pickLoop(aut, Automaton.PState(s^.item)));

        // vyzobeme všechny vstupní hrany
        inputs := Automaton.pickInputEdges(aut, Automaton.PState(s^.item));

        // vyzobeme všechny výstupní hrany
        outputs := Automaton.pickOutputEdges(aut, Automaton.PState(s^.item));

        // pro každou kombinaci vstup/výstup vložíme novou hranu
        input := inputs;
        while input <> nil do begin
            output := outputs;
            while output <> nil do begin

                // vytvoříme hranu bez smyčky
                if loop = nil then begin
                    Automaton.createRegexEdge(aut,
                        PEdge(input^.item)^.origin,
                        PEdge(output^.item)^.target,
                        RegularExpression.createConcatenationNode(
                            RegularExpression.clone(PRegexEdge(input^.item)^.expression),
                            RegularExpression.clone(PRegexEdge(output^.item)^.expression)
                        )
                    );
                // vytvoříme hranu se smyčkou
                end else begin
                    Automaton.createRegexEdge(aut,
                        PEdge(input^.item)^.origin,
                        PEdge(output^.item)^.target,
                        RegularExpression.createConcatenationNode(
                            RegularExpression.clone(PRegexEdge(input^.item)^.expression),
                            RegularExpression.createConcatenationNode(
                                RegularExpression.createKleeneNode(
                                    RegularExpression.clone(loop^.expression)
                                ),
                                RegularExpression.clone(PRegexEdge(output^.item)^.expression)
                            )
                        )
                    );
                end;

                output := output^.next;
            end;
            input := input^.next;
        end;

        // zahodíme původní hrany (z paměti)
        input := inputs;
        while input <> nil do begin
            Automaton.destroyEdge(PEdge(input^.item));
            input := input^.next;
        end;
        List.destroy(input);

        output := outputs;
        while output <> nil do begin
            Automaton.destroyEdge(PEdge(output^.item));
            output := output^.next;
        end;
        List.destroy(output);

        // odstraníme stav
        // (vlastně nemusíme, ono by se akorát posunuly indexy a bylo by
        // těžší program ladit, navíc se automat stejně nakonec zahodí)

        // další stav
        s := s^.next;
    end;

    // vrátíme zbylý regulární výraz mezi počátečním a koncovým stavem
    nondeterministicToRegex := RegularExpression.clone(
        Automaton.PRegexEdge(initial^.edges^.item)^.expression);
end;

end.