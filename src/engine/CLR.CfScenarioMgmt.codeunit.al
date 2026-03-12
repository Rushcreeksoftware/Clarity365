codeunit 50306 "CLR Cf Scenario Mgmt"
{
    procedure CreateOrUpdateScenario(ScenarioCode: Code[20]; Description: Text[100]; ForecastStart: Date; ForecastEnd: Date; Status: Enum "CLR Scenario Status"; IsBaseScenario: Boolean)
    var
        Scenario: Record "CLR CF Scenario Header";
        IsNewScenario: Boolean;
    begin
        if ScenarioCode = '' then
            Error('Scenario code is required.');
        if (ForecastStart = 0D) or (ForecastEnd = 0D) then
            Error('Scenario forecast start and end dates are required.');
        if ForecastStart > ForecastEnd then
            Error('Scenario forecast start date must be on or before forecast end date.');

        IsNewScenario := not Scenario.Get(ScenarioCode);
        if IsNewScenario then begin
            Scenario.Init();
            Scenario.Code := ScenarioCode;
            Scenario."Created By" := CopyStr(UserId(), 1, MaxStrLen(Scenario."Created By"));
            Scenario."Created Date" := Today();
        end;

        Scenario.Description := Description;
        Scenario."Forecast Start" := ForecastStart;
        Scenario."Forecast End" := ForecastEnd;
        Scenario.Status := Status;
        Scenario."Base Scenario" := IsBaseScenario;

        if IsBaseScenario then
            ClearExistingBaseScenario(ScenarioCode);

        if IsNewScenario then
            Scenario.Insert(true)
        else
            Scenario.Modify(true);
    end;

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

    procedure EnsureScenarioPrerequisites(RequestedScenarioCode: Code[20])
    var
        ForecastEngine: Codeunit "CLR Cf Forecast Engine";
    begin
        if (UpperCase(RequestedScenarioCode) <> 'UPSIDE') and (UpperCase(RequestedScenarioCode) <> 'DOWNSIDE') then
            exit;

        EnsureBaseScenario();
        if not ScenarioHasProjectionData('BASE') then
            ForecastEngine.BuildScenario('BASE');
    end;

    procedure ScenarioHasProjectionData(ScenarioCode: Code[20]): Boolean
    var
        ProjectionLine: Record "CLR CF Projection Line";
    begin
        ProjectionLine.SetRange("Scenario Code", ScenarioCode);
        exit(not ProjectionLine.IsEmpty());
    end;

    local procedure ClearExistingBaseScenario(KeepScenarioCode: Code[20])
    var
        Scenario: Record "CLR CF Scenario Header";
    begin
        Scenario.SetRange("Base Scenario", true);
        if not Scenario.FindSet() then
            exit;

        repeat
            if Scenario.Code = KeepScenarioCode then
                continue;

            Scenario."Base Scenario" := false;
            Scenario.Modify(true);
        until Scenario.Next() = 0;
    end;
}
