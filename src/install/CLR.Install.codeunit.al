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
    end;
}
