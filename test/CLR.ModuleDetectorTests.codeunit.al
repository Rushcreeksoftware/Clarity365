codeunit 50343 "CLR ModuleDetectorTests"
{
    Subtype = Test;

    [Test]
    procedure ActiveModulesContainsCoreModules()
    var
        Detector: Codeunit "CLR Module Detector";
        Setup: Record "CLR Data Provider Setup";
        ModulesCsv: Text;
    begin
        // GIVEN

        // WHEN
        ModulesCsv := Detector.GetActiveModulesCsv();

        // THEN
        if StrPos(ModulesCsv, 'GL') = 0 then
            Error('Expected GL in module list.');

        if not Setup.Get('') then
            Error('Expected setup record to be created by module detector.');

        if Setup."Show HR Module" and (StrPos(ModulesCsv, 'HR') = 0) then
            Error('Expected HR to appear in module CSV when HR module flag is enabled.');
    end;
}
