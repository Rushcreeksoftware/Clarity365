codeunit 50341 "CLR BiEngineTests"
{
    Subtype = Test;

    [Test]
    procedure BuildPayloadJsonReturnsJson()
    var
        Library: Codeunit "CLR LibraryClarity365";
        BiEngine: Codeunit "CLR BI Engine";
        Payload: Text;
    begin
        // GIVEN
        Library.EnsureSetupDefaults();

        // WHEN
        Payload := BiEngine.BuildPayloadJson();

        // THEN
        if Payload = '' then
            Error('Expected non-empty payload JSON.');
    end;
}
