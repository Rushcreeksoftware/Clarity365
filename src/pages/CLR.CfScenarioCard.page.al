page 50252 "CLR CF Scenario Card"
{
    PageType = Card;
    SourceTable = "CLR CF Scenario Header";
    ApplicationArea = All;
    Caption = 'Clarity Cash Flow Scenario';

    layout
    {
        area(Content)
        {
            group(General)
            {
                field(Code; Rec.Code) { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field("Base Scenario"; Rec."Base Scenario") { ApplicationArea = All; }
                field(Status; Rec.Status) { ApplicationArea = All; }
                field("Forecast Start"; Rec."Forecast Start") { ApplicationArea = All; }
                field("Forecast End"; Rec."Forecast End") { ApplicationArea = All; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(BuildScenario)
            {
                ApplicationArea = All;
                Caption = 'Build Scenario';
                Image = Calculate;

                trigger OnAction()
                var
                    Engine: Codeunit "CLR Cf Forecast Engine";
                begin
                    Engine.BuildScenario(Rec.Code);
                    CurrPage.Update(false);
                end;
            }
        }
    }
}
