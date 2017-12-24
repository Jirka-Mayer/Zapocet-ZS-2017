unit Converter_Tests;

interface

procedure runTests();

implementation

uses TestingFramework, Converter, RegularExpression, Automaton, List;

// regulérní výraz na nedeteerministický automat
procedure RxToNda();
var exp: RegularExpression.PNode;
var aut: Automaton.PAutomaton;
begin
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

procedure NdaToRgx();
var exp: RegularExpression.PNode;
var aut: Automaton.PAutomaton;
begin
    // Vyzkoušíme správný převod symbolových hran na regex hrany.
    // Máme automat, co odpovídá výrazu a|b :
    aut := Automaton.createAutomaton();
    Automaton.parseStates(aut, 'IF');
    Automaton.parseEdge(aut, '1 2 S a');
    Automaton.parseEdge(aut, '1 2 S !');
    Automaton.edgesToRegex(aut);
    TestingFramework.assertStringEquals('1 2 R +a!',
        Automaton.serializeEdge(aut, List.getAt(aut^.edges, 1)));
    Automaton.destroy(aut);

    // zkusíme převést automat "ab"
    aut := Automaton.createAutomaton();
    Automaton.parseStates(aut, 'IXF');
    Automaton.parseEdge(aut, '1 2 S a');
    Automaton.parseEdge(aut, '2 3 S b');
    exp := Converter.nondeterministicToRegex(aut);
    TestingFramework.assertStringEquals('...!ab!', RegularExpression.serializePrefix(exp));
    RegularExpression.removeUselessEpsilons(exp);
    TestingFramework.assertStringEquals('.ab', RegularExpression.serializePrefix(exp));
    Automaton.destroy(aut);
    RegularExpression.destroyExpression(exp);

    // zkusíme převést automat "ab|c"
    aut := Automaton.createAutomaton();
    Automaton.parseStates(aut, 'IXF');
    Automaton.parseEdge(aut, '1 2 S a');
    Automaton.parseEdge(aut, '2 3 S b');
    Automaton.parseEdge(aut, '1 3 S c');
    exp := Converter.nondeterministicToRegex(aut);
    TestingFramework.assertStringEquals('.+.!c..!ab!', RegularExpression.serializePrefix(exp));
    RegularExpression.removeUselessEpsilons(exp);
    TestingFramework.assertStringEquals('+c.ab', RegularExpression.serializePrefix(exp));
    Automaton.destroy(aut);
    RegularExpression.destroyExpression(exp);

    // zkusíme převést automat "a*"
    aut := Automaton.createAutomaton();
    Automaton.parseStates(aut, 'T');
    Automaton.parseEdge(aut, '1 1 S a');
    exp := Converter.nondeterministicToRegex(aut);
    TestingFramework.assertStringEquals('.!.*a!', RegularExpression.serializePrefix(exp));
    RegularExpression.removeUselessEpsilons(exp);
    TestingFramework.assertStringEquals('*a', RegularExpression.serializePrefix(exp));
    Automaton.destroy(aut);
    RegularExpression.destroyExpression(exp);

    // zkusíme převést složitý automat se smyčkami
    aut := Automaton.createAutomaton();
    Automaton.parseStates(aut, 'IXXF');
    Automaton.parseEdge(aut, '1 2 S a');
    Automaton.parseEdge(aut, '1 3 S b');
    Automaton.parseEdge(aut, '2 1 S c');
    Automaton.parseEdge(aut, '2 3 S x');
    Automaton.parseEdge(aut, '3 2 S y');
    Automaton.parseEdge(aut, '3 4 S h');
    Automaton.parseEdge(aut, '2 4 S d');
    exp := Converter.nondeterministicToRegex(aut);
    RegularExpression.removeUselessEpsilons(exp);
    TestingFramework.assertStringEquals(
        '+.a.*.cad.+b.a.*.ca+x.cb.*.y.*.ca+x.cb+h.y.*.cad',
        RegularExpression.serializePrefix(exp)
    );
    Automaton.destroy(aut);
    RegularExpression.destroyExpression(exp);
end;

procedure runTests();
begin
    TestingFramework.testSuite('Converter - RxToNda');
    RxToNda();

    TestingFramework.testSuite('Converter - NdaToRgx');
    NdaToRgx();
end;

end.