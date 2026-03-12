report 50380 "CLR Dashboard Summary"
{
    ProcessingOnly = true;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    Caption = 'Clarity Dashboard Summary';

    dataset
    {
        dataitem(ExportLog; "CLR Export Log")
        {
            column(EntryNo; "Entry No.") { }
            column(ExportedAt; "Exported At") { }
            column(UserId; "User ID") { }
            column(ExportType; "Export Type") { }
            column(ScenarioCode; "Scenario Code") { }
            column(FileName; "File Name") { }
            column(Status; Status) { }
            column(SummaryText; "Summary Text") { }
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
            }
        }
    }
}
