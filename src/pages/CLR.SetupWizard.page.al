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
                field("Payroll GL Account Filter"; Rec."Payroll GL Account Filter") { ApplicationArea = All; }
                field("CapEx GL Account Filter"; Rec."CapEx GL Account Filter") { ApplicationArea = All; }
                field("Primary Dimension Code"; Rec."Primary Dimension Code") { ApplicationArea = All; }
                field("Secondary Dimension Code"; Rec."Secondary Dimension Code") { ApplicationArea = All; }
                field("CF Forecast Months"; Rec."CF Forecast Months") { ApplicationArea = All; }
                field("Default AR Collection Days"; Rec."Default AR Collection Days") { ApplicationArea = All; }
                field("Default AP Payment Days"; Rec."Default AP Payment Days") { ApplicationArea = All; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ApplySuggestions)
            {
                ApplicationArea = All;
                Caption = 'Apply Auto-Suggestions';
                Image = SuggestCustomerPrice;

                trigger OnAction()
                var
                    WizardMgt: Codeunit "CLR Setup Wizard Mgmt";
                begin
                    WizardMgt.ApplyAutoSuggestions(Rec);
                    Rec.Modify(true);
                    CurrPage.Update(false);
                end;
            }

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
