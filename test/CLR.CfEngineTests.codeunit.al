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

    [Test]
    procedure EnsureScenarioPrerequisitesBuildsBaseForUpside()
    var
        Library: Codeunit "CLR LibraryClarity365";
        ScenarioMgt: Codeunit "CLR Cf Scenario Mgmt";
        BaseScenario: Record "CLR CF Scenario Header";
        ProjectionLine: Record "CLR CF Projection Line";
    begin
        // GIVEN
        Library.EnsureSetupDefaults();
        ScenarioMgt.EnsureBaseScenario();

        if BaseScenario.Get('BASE') then begin
            BaseScenario."Forecast Start" := Today();
            BaseScenario."Forecast End" := CalcDate('<6M>', Today());
            BaseScenario.Modify(true);
        end;

        ProjectionLine.SetRange("Scenario Code", 'BASE');
        if not ProjectionLine.IsEmpty() then
            ProjectionLine.DeleteAll();

        // WHEN
        ScenarioMgt.EnsureScenarioPrerequisites('UPSIDE');

        // THEN
        if not ScenarioMgt.ScenarioHasProjectionData('BASE') then
            Error('Expected BASE scenario projection data to be prepared before UPSIDE.');
    end;
}
