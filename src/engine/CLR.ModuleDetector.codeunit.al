codeunit 50303 "CLR Module Detector"
{
    SingleInstance = true;

    var
        IsLoaded: Boolean;
        RecurInstalled: Boolean;

    procedure IsRecur365Installed(): Boolean
    begin
        if not IsLoaded then begin
            RecurInstalled := NavApp.IsInstalled('00000000-0000-0000-0000-000000000001');
            IsLoaded := true;
        end;

        exit(RecurInstalled);
    end;

    procedure GetActiveModulesCsv(): Text
    begin
        if IsRecur365Installed() then
            exit('GL,AR,AP,Bank,Purchasing,Inventory,Recur365');

        exit('GL,AR,AP,Bank,Purchasing,Inventory');
    end;
}
