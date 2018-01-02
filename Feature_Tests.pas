{
    Testuje celkovou funkčnost programu
}
unit Feature_Tests;

interface

procedure runTests();

implementation

uses TestingFramework, Converter;

{**
 * Udělá jeden test
 *}
procedure singleTest(path, targetType: AnsiString);
begin
    // udělat převod
    Converter.convert(
        'tests/' + path + '.txt',
        'tests/temp.txt',
        targetType
    );

    // porovnat s očekávaným výsledkem
    TestingFramework.assertFileEquals(
        'tests/' + path + '_result.txt',
        'tests/temp.txt'
    );
end;

procedure runTests();
begin
    TestingFramework.testSuite('Feature - RE-NDA');
    singleTest('RE-NDA/complex-1', 'NDA');
    singleTest('RE-NDA/empty-set-1', 'NDA');
    singleTest('RE-NDA/empty-string-1', 'NDA');

    TestingFramework.testSuite('Feature - NDA-RE');
    singleTest('NDA-RE/complex-1', 'RE');
    singleTest('NDA-RE/empty-set-1', 'RE');
    singleTest('NDA-RE/empty-string-1', 'RE');
    singleTest('NDA-RE/empty-string-2', 'RE');

    TestingFramework.testSuite('Feature - NDA-DA');
    singleTest('NDA-DA/complex-1', 'DA');

    TestingFramework.testSuite('Feature - DA-NDA');
    singleTest('DA-NDA/complex-1', 'NDA');
    singleTest('DA-NDA/empty-set-1', 'NDA');

    TestingFramework.testSuite('Feature - RE-DA');
    singleTest('RE-DA/complex-1', 'DA');
    singleTest('RE-DA/empty-set-1', 'DA');
    singleTest('RE-DA/empty-string-1', 'DA');

    TestingFramework.testSuite('Feature - DA-RE');
    singleTest('DA-RE/complex-1', 'RE');
    singleTest('DA-RE/empty-set-1', 'RE');
    singleTest('DA-RE/empty-string-1', 'RE');

    TestingFramework.testSuite('Feature - same type conversions');
    singleTest('same-type-conversions/RE', 'RE');
    singleTest('same-type-conversions/NDA', 'NDA');
    singleTest('same-type-conversions/DA', 'DA');
end;

end.