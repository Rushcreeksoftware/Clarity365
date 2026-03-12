codeunit 50306 "CLR Cf Scenario Mgmt"
{
    procedure EnsureBaseScenario()
    var
        Scenario: Record "CLR CF Scenario Header";
    begin
        if Scenario.Get('BASE') then
            exit;

        Scenario.Init();
        Scenario.Code := 'BASE';
        Scenario.Description := 'Base Scenario';
        Scenario."Base Scenario" := true;
        Scenario."Forecast Start" := Today();
        Scenario."Forecast End" := CalcDate('<12M>', Today());
        Scenario.Status := Scenario.Status::Active;
        Scenario."Created By" := CopyStr(UserId(), 1, MaxStrLen(Scenario."Created By"));
        Scenario."Created Date" := Today();
        Scenario.Insert(true);
    end;
}
