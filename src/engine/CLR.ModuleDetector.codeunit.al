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
    var
        Setup: Record "CLR Data Provider Setup";
        JobLedgerEntry: Record "Job Ledger Entry";
        FALedgerEntry: Record "FA Ledger Entry";
        ServiceLedgerEntry: Record "Service Ledger Entry";
        EmployeeLedgerEntry: Record "Employee Ledger Entry";
        ProductionOrder: Record "Production Order";
        ModuleCsv: Text;
    begin
        EnsureSetup(Setup);

        JobLedgerEntry.Reset();
        Setup."Show Jobs Module" := not JobLedgerEntry.IsEmpty();

        FALedgerEntry.Reset();
        Setup."Show FA Module" := not FALedgerEntry.IsEmpty();

        ServiceLedgerEntry.Reset();
        Setup."Show Service Module" := not ServiceLedgerEntry.IsEmpty();

        EmployeeLedgerEntry.Reset();
        Setup."Show HR Module" := not EmployeeLedgerEntry.IsEmpty();

        ProductionOrder.Reset();
        Setup."Show Manufacturing Module" := not ProductionOrder.IsEmpty();

        Setup."Show Purchasing Module" := true;
        Setup.Modify(true);

        ModuleCsv := 'GL,AR,AP,Bank,Purchasing,Inventory';
        if Setup."Show Jobs Module" then
            ModuleCsv := ModuleCsv + ',Jobs';
        if Setup."Show FA Module" then
            ModuleCsv := ModuleCsv + ',FixedAssets';
        if Setup."Show Service Module" then
            ModuleCsv := ModuleCsv + ',Service';
        if Setup."Show HR Module" then
            ModuleCsv := ModuleCsv + ',HR';
        if Setup."Show Manufacturing Module" then
            ModuleCsv := ModuleCsv + ',Manufacturing';

        if IsRecur365Installed() then
            exit(ModuleCsv + ',Recur365');

        exit(ModuleCsv);
    end;

    local procedure EnsureSetup(var Setup: Record "CLR Data Provider Setup")
    begin
        if Setup.Get('') then
            exit;

        Setup.Init();
        Setup."Primary Key" := '';
        Setup.Insert(true);
    end;
}
