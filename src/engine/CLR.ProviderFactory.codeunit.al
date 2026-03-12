codeunit 50302 "CLR Provider Factory"
{
    procedure GetProvider(): Interface "CLR IDataProvider"
    var
        Detector: Codeunit "CLR Module Detector";
        NativeProvider: Codeunit "CLR BC Native Provider";
        RecurProvider: Codeunit "CLR Recur365 Provider";
    begin
        if Detector.IsRecur365Installed() then
            exit(RecurProvider);

        exit(NativeProvider);
    end;
}
