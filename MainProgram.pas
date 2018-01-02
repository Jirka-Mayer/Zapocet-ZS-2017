program MainProgram;

uses Converter;

procedure printUsage();
begin
    writeln('Usage: [input filename] [output filename] [output type]');
    writeln('Output types: RE, NDA, DA');
    halt;
end;

begin
    if ParamCount() <> 3 then
        printUsage();

    if (ParamStr(3) <> 'RE') and (ParamStr(3) <> 'DA') and (ParamStr(3) <> 'NDA') then
        printUsage();

    Converter.convert(ParamStr(1), ParamStr(2), ParamStr(3));

    writeln('Done.');
end.