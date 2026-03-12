codeunit 50340 "CLR LibraryClarity365"
{
    Subtype = Test;

    procedure EnsureSetupDefaults()
    var
        Setup: Record "CLR Data Provider Setup";
    begin
        if not Setup.Get('') then begin
            Setup.Init();
            Setup."Primary Key" := '';
            Setup."CF Forecast Months" := 12;
            Setup."Default AR Collection Days" := 30;
            Setup."Default AP Payment Days" := 30;
            Setup."Setup Completed" := true;
            Setup.Insert(true);
        end;
    end;
}
