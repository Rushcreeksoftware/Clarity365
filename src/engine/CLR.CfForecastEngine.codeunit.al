codeunit 50305 "CLR Cf Forecast Engine"
{
    procedure BuildScenario(ScenarioCode: Code[20])
    var
        ProjectionLine: Record "CLR CF Projection Line";
        Scenario: Record "CLR CF Scenario Header";
    begin
        if not Scenario.Get(ScenarioCode) then
            exit;

        ProjectionLine.SetRange("Scenario Code", ScenarioCode);
        if not ProjectionLine.IsEmpty() then
            ProjectionLine.DeleteAll();

        ProjectionLine.Init();
        ProjectionLine."Scenario Code" := ScenarioCode;
        ProjectionLine."Projection Date" := Scenario."Forecast Start";
        ProjectionLine.Category := ProjectionLine.Category::OpeningBalance;
        ProjectionLine.Amount := 0;
        ProjectionLine."Cumulative Cash" := 0;
        ProjectionLine."Is Actual" := Scenario."Forecast Start" <= Today();
        ProjectionLine.Insert();

        Scenario."Last Built" := CurrentDateTime();
        Scenario.Modify(true);
    end;
}
