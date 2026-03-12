page 1000214 "Clarity Work Item Card"
{
    Caption = 'Clarity Work Item';
    PageType = Card;
    SourceTable = "Clarity Work Item";
    ApplicationArea = All;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies the work item number.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the work item description.';
                }
                field(Status; Rec.Status)
                {
                    ToolTip = 'Specifies the current work item status.';
                }
                field(Priority; Rec.Priority)
                {
                    ToolTip = 'Specifies the work item priority.';
                }
                field("Owner User ID"; Rec."Owner User ID")
                {
                    ToolTip = 'Specifies the owner user ID.';
                }
                field("Due Date"; Rec."Due Date")
                {
                    ToolTip = 'Specifies the due date.';
                }
            }
        }
    }
}
