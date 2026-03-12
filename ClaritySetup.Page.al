page 1000201 "Clarity Setup"
{
    Caption = 'Clarity Setup';
    PageType = Card;
    SourceTable = "Clarity Setup";
    ApplicationArea = All;
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field(Enabled; Rec.Enabled)
                {
                    ToolTip = 'Specifies whether Clarity365 functionality is enabled.';
                }
                field("Default Owner User ID"; Rec."Default Owner User ID")
                {
                    ToolTip = 'Specifies the default owner for newly created work items.';
                }
                field("Default Priority"; Rec."Default Priority")
                {
                    ToolTip = 'Specifies the default priority for new work items.';
                }
                field("Last Setup Validation"; Rec."Last Setup Validation")
                {
                    ToolTip = 'Shows when setup was validated last.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ValidateSetup)
            {
                ApplicationArea = All;
                Caption = 'Validate Setup';
                Image = TestFile;
                ToolTip = 'Validate setup values and stamp validation date/time.';

                trigger OnAction()
                begin
                    if not Rec.Enabled then
                        Error('Enable Clarity365 before continuing.');

                    Rec."Last Setup Validation" := CurrentDateTime();
                    Rec.Modify(true);
                    Message('Setup validated successfully.');
                end;
            }

            action(OpenWorkItems)
            {
                ApplicationArea = All;
                Caption = 'Work Items';
                Image = TaskList;
                RunObject = page "Clarity Work Items";
                ToolTip = 'Open the work item list.';
            }

            action(SeedSampleWorkItems)
            {
                ApplicationArea = All;
                Caption = 'Seed Sample Work Items';
                Image = New;
                ToolTip = 'Create starter work items for testing and demos.';

                trigger OnAction()
                var
                    WorkMgt: Codeunit "Clarity Work Mgt.";
                begin
                    WorkMgt.SeedSampleData();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        if not Rec.Get('SETUP') then begin
            Rec.Init();
            Rec."Primary Key" := 'SETUP';
            Rec.Enabled := true;
            Rec."Default Priority" := Rec."Default Priority"::Normal;
            Rec.Insert(true);
        end;
    end;
}
