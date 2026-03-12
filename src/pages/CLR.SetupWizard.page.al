page 50257 "CLR Setup Wizard"
{
    PageType = Card;
    SourceTable = "CLR Data Provider Setup";
    ApplicationArea = All;
    UsageCategory = Administration;
    Caption = 'Clarity Setup Wizard';

    layout
    {
        area(Content)
        {
            group(Wizard)
            {
                field("Revenue GL Account Filter"; Rec."Revenue GL Account Filter") { ApplicationArea = All; }
                field("COGS GL Account Filter"; Rec."COGS GL Account Filter") { ApplicationArea = All; }
                field("OpEx GL Account Filter"; Rec."OpEx GL Account Filter") { ApplicationArea = All; }
                field("Primary Dimension Code"; Rec."Primary Dimension Code") { ApplicationArea = All; }
                field("Secondary Dimension Code"; Rec."Secondary Dimension Code") { ApplicationArea = All; }
                field("CF Forecast Months"; Rec."CF Forecast Months") { ApplicationArea = All; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CompleteWizard)
            {
                ApplicationArea = All;
                Caption = 'Complete Setup';
                Image = Approve;

                trigger OnAction()
                var
                    WizardMgt: Codeunit "CLR Setup Wizard Mgmt";
                begin
                    WizardMgt.CompleteSetup();
                    CurrPage.Update(false);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        if not Rec.Get('') then begin
            Rec.Init();
            Rec."Primary Key" := '';
            Rec.Insert(true);
        end;
    end;
}
