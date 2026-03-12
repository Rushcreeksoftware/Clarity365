codeunit 50342 "CLR CfEngineTests"
{
    Subtype = Test;

    [Test]
    procedure BuildScenarioCreatesProjectionRows()
    var
        Library: Codeunit "CLR LibraryClarity365";
        ScenarioMgt: Codeunit "CLR Cf Scenario Mgmt";
        ForecastEngine: Codeunit "CLR Cf Forecast Engine";
        ProjectionLine: Record "CLR CF Projection Line";
    begin
        // GIVEN
        Library.EnsureSetupDefaults();
        ScenarioMgt.EnsureBaseScenario();

        // WHEN
        ForecastEngine.BuildScenario('BASE');

        // THEN
        ProjectionLine.SetRange("Scenario Code", 'BASE');
        if ProjectionLine.IsEmpty() then
            Error('Expected projection lines for BASE scenario.');
    end;
}
