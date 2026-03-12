page 50255 "CLR Dashboard View List"
{
    PageType = List;
    SourceTable = "CLR Dashboard View";
    ApplicationArea = All;
    UsageCategory = Lists;
    Caption = 'Clarity Dashboard Views';

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Code; Rec.Code) { ApplicationArea = All; }
                field("User ID"; Rec."User ID") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field(Mode; Rec.Mode) { ApplicationArea = All; }
                field("Is Shared"; Rec."Is Shared") { ApplicationArea = All; }
                field("Created DateTime"; Rec."Created DateTime") { ApplicationArea = All; }
            }
        }
    }
}
