codeunit 50349 "CLR Install"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    var
        Setup: Record "CLR Data Provider Setup";
        ScenarioMgt: Codeunit "CLR Cf Scenario Mgmt";
    begin
        if not Setup.Get('') then begin
            Setup.Init();
            Setup."Primary Key" := '';
            Setup."CF Forecast Months" := 12;
            Setup."Default AR Collection Days" := 30;
            Setup."Default AP Payment Days" := 30;
            Setup.Insert(true);
        end;

        ScenarioMgt.EnsureBaseScenario();
        EnsureForecastRefreshJobQueueEntry();
    end;

    local procedure EnsureForecastRefreshJobQueueEntry()
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"CLR Forecast Job Runner");
        if JobQueueEntry.FindFirst() then
            exit;

        JobQueueEntry.Init();
        JobQueueEntry.Validate("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.Validate("Object ID to Run", Codeunit::"CLR Forecast Job Runner");
        JobQueueEntry.Validate(Description, 'Clarity Forecast Refresh');
        JobQueueEntry.Validate("Recurring Job", true);
        JobQueueEntry.Validate("No. of Minutes between Runs", 1440);
        JobQueueEntry.Validate("Earliest Start Date/Time", CurrentDateTime());
        JobQueueEntry.Insert(true);
    end;
}
