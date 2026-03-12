page 50254 "CLR Manual CF Entry List"
{
    PageType = List;
    SourceTable = "CLR Manual CF Entry";
    ApplicationArea = All;
    UsageCategory = Lists;
    Caption = 'Clarity Manual CF Entries';

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.") { ApplicationArea = All; }
                field("Scenario Code"; Rec."Scenario Code") { ApplicationArea = All; }
                field("Posting Date"; Rec."Posting Date") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field(Amount; Rec.Amount) { ApplicationArea = All; }
                field("Is Receipt"; Rec."Is Receipt") { ApplicationArea = All; }
            }
        }
    }
}
