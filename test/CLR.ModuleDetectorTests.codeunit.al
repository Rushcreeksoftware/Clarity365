codeunit 50343 "CLR ModuleDetectorTests"
{
    Subtype = Test;

    [Test]
    procedure ActiveModulesContainsCoreModules()
    var
        Detector: Codeunit "CLR Module Detector";
        ModulesCsv: Text;
    begin
        // GIVEN

        // WHEN
        ModulesCsv := Detector.GetActiveModulesCsv();

        // THEN
        if StrPos(ModulesCsv, 'GL') = 0 then
            Error('Expected GL in module list.');
    end;
}
