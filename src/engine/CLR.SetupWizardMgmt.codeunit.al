codeunit 50308 "CLR Setup Wizard Mgmt"
{
    procedure DetectActiveModules(var Setup: Record "CLR Data Provider Setup")
    var
        Detector: Codeunit "CLR Module Detector";
    begin
        Detector.GetActiveModulesCsv();
        if Setup.Get('') then;
    end;

    procedure ApplyAutoSuggestions(var Setup: Record "CLR Data Provider Setup")
    var
        GLAccount: Record "G/L Account";
        Dimension: Record Dimension;
    begin
        if Setup."Revenue GL Account Filter" = '' then
            Setup."Revenue GL Account Filter" := '4*';

        if Setup."COGS GL Account Filter" = '' then
            Setup."COGS GL Account Filter" := '5*';

        if Setup."OpEx GL Account Filter" = '' then
            Setup."OpEx GL Account Filter" := '6*|7*';

        if Setup."Payroll GL Account Filter" = '' then begin
            GLAccount.Reset();
            GLAccount.SetFilter(Name, '@*PAYROLL*|@*SALARY*');
            if GLAccount.FindFirst() then
                Setup."Payroll GL Account Filter" := CopyStr(GLAccount."No.", 1, MaxStrLen(Setup."Payroll GL Account Filter"));
        end;

        if Setup."CapEx GL Account Filter" = '' then
            Setup."CapEx GL Account Filter" := '8*';

        if Setup."Primary Dimension Code" = '' then begin
            Dimension.Reset();
            if Dimension.FindFirst() then
                Setup."Primary Dimension Code" := Dimension.Code;
        end;

        if Setup."Secondary Dimension Code" = '' then begin
            Dimension.Reset();
            if Dimension.FindFirst() then begin
                if (Dimension.Next() <> 0) and (Dimension.Code <> Setup."Primary Dimension Code") then
                    Setup."Secondary Dimension Code" := Dimension.Code;
            end;
        end;

        if Setup."CF Forecast Months" = 0 then
            Setup."CF Forecast Months" := 12;

        if Setup."Default AR Collection Days" = 0 then
            Setup."Default AR Collection Days" := 30;

        if Setup."Default AP Payment Days" = 0 then
            Setup."Default AP Payment Days" := 30;
    end;

    procedure CompleteSetup()
    var
        Setup: Record "CLR Data Provider Setup";
    begin
        if not Setup.Get('') then begin
            Setup.Init();
            Setup."Primary Key" := '';
            Setup.Insert(true);
        end;

        ApplyAutoSuggestions(Setup);
        Setup."Setup Completed" := true;
        Setup.Modify(true);
    end;
}
