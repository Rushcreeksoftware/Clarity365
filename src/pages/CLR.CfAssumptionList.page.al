page 50253 "CLR CF Assumption List"
{
    PageType = List;
    SourceTable = "CLR CF Scenario Assumption";
    ApplicationArea = All;
    UsageCategory = Lists;
    Caption = 'Clarity CF Assumptions';

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Scenario Code"; Rec."Scenario Code") { ApplicationArea = All; }
                field("Line No."; Rec."Line No.") { ApplicationArea = All; }
                field(Category; Rec.Category) { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field(Value; Rec.Value) { ApplicationArea = All; }
                field("Apply From"; Rec."Apply From") { ApplicationArea = All; }
                field("Apply To"; Rec."Apply To") { ApplicationArea = All; }
            }
        }
    }
}
