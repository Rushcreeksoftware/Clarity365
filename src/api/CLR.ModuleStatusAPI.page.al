page 50272 "CLR Module Status API"
{
    PageType = API;
    APIPublisher = 'rushcreeksoftware';
    APIGroup = 'clarity365';
    APIVersion = 'v1.0';
    EntityName = 'moduleStatus';
    EntitySetName = 'moduleStatus';
    SourceTable = "CLR Data Provider Setup";
    DelayedInsert = true;
    ODataKeyFields = "Primary Key";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(primaryKey; Rec."Primary Key") { }
                field(activeModules; ActiveModules) { }
                field(hasRecur365; HasRecur365) { }
                field(showJobsModule; Rec."Show Jobs Module") { }
                field(showFaModule; Rec."Show FA Module") { }
                field(showServiceModule; Rec."Show Service Module") { }
                field(showHrModule; Rec."Show HR Module") { }
                field(showManufacturingModule; Rec."Show Manufacturing Module") { }
                field(showPurchasingModule; Rec."Show Purchasing Module") { }
                field(setupCompleted; Rec."Setup Completed") { }
            }
        }
    }

    var
        ActiveModules: Text;
        HasRecur365: Boolean;

    trigger OnAfterGetRecord()
    var
        Detector: Codeunit "CLR Module Detector";
    begin
        ActiveModules := Detector.GetActiveModulesCsv();
        HasRecur365 := Detector.IsRecur365Installed();
    end;
}
