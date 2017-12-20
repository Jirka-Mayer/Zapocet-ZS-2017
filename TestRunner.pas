program TestRunner;

uses
    TestingFramework,
    TestingFramework_Tests,
    List_Tests,
    RegularExpression_Tests,
    Automaton_Tests,
    Converter_Tests;

begin
    TestingFramework_Tests.runTests();
    List_Tests.runTests();
    RegularExpression_Tests.runTests();
    Automaton_Tests.runTests();
    Converter_Tests.runTests();

    writeln('All tests were run.');
end.