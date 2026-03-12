codeunit 50308 "CLR Setup Wizard Mgmt"
{
    procedure CompleteSetup()
    var
        Setup: Record "CLR Data Provider Setup";
    begin
        if not Setup.Get('') then begin
            Setup.Init();
            Setup."Primary Key" := '';
            Setup.Insert(true);
        end;

        Setup."Setup Completed" := true;
        if Setup."CF Forecast Months" = 0 then
            Setup."CF Forecast Months" := 12;
        if Setup."Default AR Collection Days" = 0 then
            Setup."Default AR Collection Days" := 30;
        if Setup."Default AP Payment Days" = 0 then
            Setup."Default AP Payment Days" := 30;
        Setup.Modify(true);
    end;
}
