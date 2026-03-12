page 1000212 "Clarity Work Items"
{
    Caption = 'Clarity Work Items';
    PageType = List;
    SourceTable = "Clarity Work Item";
    ApplicationArea = All;
    UsageCategory = Lists;
    CardPageId = "Clarity Work Item Card";

    layout
    {
        area(Content)
        {
            repeater(Items)
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

    actions
    {
        area(Processing)
        {
            action(NewSample)
            {
                ApplicationArea = All;
                Caption = 'Seed Sample Data';
                Image = New;
                ToolTip = 'Create sample work items.';

                trigger OnAction()
                var
                    WorkMgt: Codeunit "Clarity Work Mgt.";
                begin
                    WorkMgt.SeedSampleData();
                    CurrPage.Update(false);
                end;
            }
        }
    }
}
