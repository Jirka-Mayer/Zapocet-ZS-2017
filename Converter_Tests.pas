unit Converter_Tests;

interface

procedure runTests();

implementation

uses TestingFramework, Converter, RegularExpression, Automaton, List;

procedure runTests();
var exp: RegularExpression.PNode;
var aut: Automaton.PAutomaton;
begin
    TestingFramework.testSuite('Converter');

    // převod symbolu
    exp := RegularExpression.parse('a');
    aut := Converter.regexToNondeterministic(exp);
    TestingFramework.assertStringEquals('IF', Automaton.serializeStates(aut));
    TestingFramework.assertStringEquals(
        '1 2 S a', Automaton.serializeEdge(aut, List.getAt(aut^.edges, 1)));
    RegularExpression.destroyExpression(exp);
    Automaton.destroy(aut);

    // převod konkatenace
    exp := RegularExpression.parse('.ab');
    aut := Converter.regexToNondeterministic(exp);
    TestingFramework.assertStringEquals('IFX', Automaton.serializeStates(aut));
    TestingFramework.assertStringEquals(
        '1 3 S a', Automaton.serializeEdge(aut, List.getAt(aut^.edges, 1)));
    TestingFramework.assertStringEquals(
        '3 2 S b', Automaton.serializeEdge(aut, List.getAt(aut^.edges, 2)));
    RegularExpression.destroyExpression(exp);
    Automaton.destroy(aut);

    // převod alternace
    exp := RegularExpression.parse('+ab');
    aut := Converter.regexToNondeterministic(exp);
    TestingFramework.assertStringEquals('IF', Automaton.serializeStates(aut));
    TestingFramework.assertStringEquals(
        '1 2 S a', Automaton.serializeEdge(aut, List.getAt(aut^.edges, 1)));
    TestingFramework.assertStringEquals(
        '1 2 S b', Automaton.serializeEdge(aut, List.getAt(aut^.edges, 2)));
    RegularExpression.destroyExpression(exp);
    Automaton.destroy(aut);

    // převod kleene
    exp := RegularExpression.parse('*a');
    aut := Converter.regexToNondeterministic(exp);
    TestingFramework.assertStringEquals('IFX', Automaton.serializeStates(aut));
    TestingFramework.assertStringEquals(
        '1 3 E', Automaton.serializeEdge(aut, List.getAt(aut^.edges, 1)));
    TestingFramework.assertStringEquals(
        '3 3 S a', Automaton.serializeEdge(aut, List.getAt(aut^.edges, 2)));
    TestingFramework.assertStringEquals(
        '3 2 E', Automaton.serializeEdge(aut, List.getAt(aut^.edges, 3)));
    RegularExpression.destroyExpression(exp);
    Automaton.destroy(aut);

    // složitější převod            (xa*)|bd
    exp := RegularExpression.parse('+.x*a.bd');
    aut := Converter.regexToNondeterministic(exp);
    TestingFramework.assertStringEquals('IFXXX', Automaton.serializeStates(aut));
    TestingFramework.assertStringEquals(
        '1 3 S x', Automaton.serializeEdge(aut, List.getAt(aut^.edges, 1)));
    TestingFramework.assertStringEquals(
        '3 4 E', Automaton.serializeEdge(aut, List.getAt(aut^.edges, 2)));
    TestingFramework.assertStringEquals(
        '4 4 S a', Automaton.serializeEdge(aut, List.getAt(aut^.edges, 3)));
    TestingFramework.assertStringEquals(
        '4 2 E', Automaton.serializeEdge(aut, List.getAt(aut^.edges, 4)));
    TestingFramework.assertStringEquals(
        '1 5 S b', Automaton.serializeEdge(aut, List.getAt(aut^.edges, 5)));
    TestingFramework.assertStringEquals(
        '5 2 S d', Automaton.serializeEdge(aut, List.getAt(aut^.edges, 6)));
    RegularExpression.destroyExpression(exp);
    Automaton.destroy(aut);
end;

end.