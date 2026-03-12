page 1000202 "Clarity Role Center"
{
    Caption = 'Clarity Role Center';
    PageType = RoleCenter;
    ApplicationArea = All;

    layout
    {
        area(RoleCenter)
        {
            group(Clarity)
            {
                field(WelcomeText; WelcomeText)
                {
                    ApplicationArea = All;
                    Caption = 'Clarity365';
                    Editable = false;
                    ToolTip = 'Shows role center status.';
                }
            }
        }
    }

    actions
    {
        area(Sections)
        {
            action(OpenSetup)
            {
                ApplicationArea = All;
                Caption = 'Setup';
                Image = Setup;
                RunObject = page "Clarity Setup";
            }

            action(OpenWorkItems)
            {
                ApplicationArea = All;
                Caption = 'Work Items';
                Image = TaskList;
                RunObject = page "Clarity Work Items";
            }
        }

        area(Processing)
        {
            action(SeedSampleData)
            {
                ApplicationArea = All;
                Caption = 'Seed Sample Data';
                Image = New;

                trigger OnAction()
                var
                    WorkMgt: Codeunit "Clarity Work Mgt.";
                begin
                    WorkMgt.SeedSampleData();
                end;
            }
        }
    }

    var
        WelcomeText: Text[100];

    trigger OnOpenPage()
    begin
        WelcomeText := 'Welcome to Clarity365.';
    end;
}
