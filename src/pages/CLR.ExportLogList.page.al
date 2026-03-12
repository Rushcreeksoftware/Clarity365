page 50258 "CLR Export Log List"
{
    PageType = List;
    SourceTable = "CLR Export Log";
    ApplicationArea = All;
    UsageCategory = Lists;
    Caption = 'Clarity Export Log';

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Exported At"; Rec."Exported At")
                {
                    ApplicationArea = All;
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = All;
                }
                field("Export Type"; Rec."Export Type")
                {
                    ApplicationArea = All;
                }
                field("Scenario Code"; Rec."Scenario Code")
                {
                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                }
                field("File Name"; Rec."File Name")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
