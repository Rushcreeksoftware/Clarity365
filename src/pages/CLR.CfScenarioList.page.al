page 50251 "CLR CF Scenario List"
{
    PageType = List;
    SourceTable = "CLR CF Scenario Header";
    ApplicationArea = All;
    UsageCategory = Lists;
    CardPageId = "CLR CF Scenario Card";
    Caption = 'Clarity Cash Flow Scenarios';

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Code; Rec.Code) { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field("Base Scenario"; Rec."Base Scenario") { ApplicationArea = All; }
                field(Status; Rec.Status) { ApplicationArea = All; }
                field("Forecast Start"; Rec."Forecast Start") { ApplicationArea = All; }
                field("Forecast End"; Rec."Forecast End") { ApplicationArea = All; }
                field("Last Built"; Rec."Last Built") { ApplicationArea = All; }
            }
        }
    }
}
