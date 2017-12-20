unit RegularExpression_Tests;

interface

procedure runTests;

implementation

uses TestingFramework, RegularExpression;

procedure testSerialization(expression: AnsiString);
var e: PNode;
begin
    e := parse(expression);
    TestingFramework.assertStringEquals(expression, serializePrefix(e));
    destroyExpression(e);
end;

procedure runTests();
var a: PNode;
begin
    TestingFramework.testSuite('RegularExpression');

    // symbol
    a := createSymbolNode('a');
    TestingFramework.assertStringEquals('a', serializePrefix(a));

    // konkatenace
    a := createConcatenationNode(
        createSymbolNode('a'),
        createSymbolNode('b')
    );
    TestingFramework.assertStringEquals('.ab', serializePrefix(a));

    // alternace
    a := createAlternationNode(
        createSymbolNode('a'),
        createSymbolNode('b')
    );
    TestingFramework.assertStringEquals('+ab', serializePrefix(a));

    // kleene
    a := createKleeneNode(
        createSymbolNode('a')
    );
    TestingFramework.assertStringEquals('*a', serializePrefix(a));

    // testování parsováním tam a zpět
    testSerialization('a');
    testSerialization('.ab');
    testSerialization('..abc');
    testSerialization('.a.bc');
    testSerialization('+ab');
    testSerialization('++abc');
    testSerialization('+a+bc');
    testSerialization('*a');

    // složitější test všeho
    testSerialization('+.x*a.bd');
end;

end.