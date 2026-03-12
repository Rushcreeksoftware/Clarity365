// Clarity365 — CLR.FinanceRCExt.pageext.al
// Purpose: Adds a 'Clarity365' navigation group to the Finance Manager Role Center.

pageextension 50260 "CLR Finance RC Ext" extends "Finance Manager Role Center"
{
    actions
    {
        addlast(Sections)
        {
            group(CLRFinNavGroup)
            {
                Caption = 'Clarity365';

                action(CLRFinDashboardNav)
                {
                    ApplicationArea = All;
                    Caption = 'Clarity Dashboard';
                    RunObject = page "CLR Dashboard";
                    Image = Home;
                }
                action(CLRFinScenariosNav)
                {
                    ApplicationArea = All;
                    Caption = 'Cash Flow Scenarios';
                    RunObject = page "CLR CF Scenario List";
                    Image = Forecast;
                }
            }
        }
    }
}
