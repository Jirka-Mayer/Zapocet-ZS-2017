{
    Pomocné funkce pro testování aplikace
}

unit TestingFramework;

interface

procedure testSuite(suiteName: string);
procedure assertIntEquals(expected, tested: integer);
procedure assertStringEquals(expected, tested: AnsiString);
procedure assertPointerEquals(expected, tested: Pointer);
procedure assertFileEquals(expected, tested: AnsiString);

implementation

uses sysutils;

{**
 * Jméno aktuálního testu
 *}
var currentSuite: string;

{**
 * Vypíše chybovou hlášku na standartní výstup
 *
 * message - zpráva
 * assertion - jaké testování se provádělo
 * expected - očekávaná hodnota
 * given - předaná hodnota
 *}
procedure error(message, assertion, expected, given: string);
begin
    writeln;
    writeln('Error in ' + assertion + ' @ ' + currentSuite + ':');
    writeln(message);
    writeln('===================================');
    writeln('Expected: ' + expected);
    writeln('Given:    ' + given);
    writeln;
end;

{**
 * Nastaví jméno momentální skupiny testů
 *}
procedure testSuite(suiteName: string);
begin
    currentSuite := suiteName;
end;

{**
 * Testuje, zda daný vstup typu 'integer' odpovídá očekávanému
 * 
 * expected - očekávaná hodnota
 * tested - testovaná hodnota
 *}
procedure assertIntEquals(expected, tested: integer);
begin
    if expected = tested then
        exit;

    error(
        'Integers do not match',
        'assertIntEquals',
        IntToStr(expected),
        IntToStr(tested)
    );
end;

{**
 * Testuje, zda daný vstup typu 'string' odpovídá očekávanému
 *}
procedure assertStringEquals(expected, tested: AnsiString);
begin
    if expected = tested then
        exit;

    error(
        'Strings do not match',
        'assertStringEquals',
        '"' + expected + '"',
        '"' + tested + '"'
    );
end;

{**
 * Testuje, zda dva pointery ukazují na stejnou adresu
 *}
procedure assertPointerEquals(expected, tested: Pointer);
begin
    if expected = tested then
        exit;

    error(
        'Pointers do not match',
        'assertPointerEquals',
        '0x' + IntToHex(longword(expected), 8),
        '0x' + IntToHex(longword(tested), 8)
    );
end;

{**
 * Testuje, zda dva textové soubory obsahují stejná data
 *}
procedure assertFileEquals(expected, tested: AnsiString);
var eFile, tFile: text;
var eLine, tLine: AnsiString;
var i: integer;
begin
    assign(eFile, expected);
    assign(tFile, tested);
    reset(eFile);
    reset(tFile);

    i := 1;
    while not eof(eFile) do begin
        readln(eFile, eLine);
        readln(tFile, tLine);
        if eLine <> tLine then begin
            error(
                'Files do not match at line ' + IntToStr(i),
                'assertFileEquals',
                '"' + eLine + '"',
                '"' + tLine + '"'
            );
            break;
        end;
        i += 1;
    end;

    if not seekeof(tFile) then begin
        error(
            'Files do not match',
            'assertFileEquals',
            expected,
            tested
        );
    end;

    close(eFile);
    close(tFile);
end;

end.