codeunit 50310 "CLR Forecast Job Runner"
{
    trigger OnRun()
    var
        ScenarioMgt: Codeunit "CLR Cf Scenario Mgmt";
        ForecastEngine: Codeunit "CLR Cf Forecast Engine";
    begin
        ScenarioMgt.EnsureBaseScenario();
        ForecastEngine.BuildScenario('BASE');
    end;
}
