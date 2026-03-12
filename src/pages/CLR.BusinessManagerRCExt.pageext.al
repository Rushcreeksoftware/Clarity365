// Clarity365 — CLR.BusinessManagerRCExt.pageext.al
// Purpose: Adds a 'Clarity365' navigation group to the Business Manager Role Center
//          so users on the default BC profile can reach the dashboard from the toolbar.

pageextension 50259 "CLR Business Manager RC Ext" extends "Business Manager Role Center"
{
    actions
    {
        addlast(Sections)
        {
            group(CLRBMNavGroup)
            {
                Caption = 'Clarity365';

                action(CLRBMDashboardNav)
                {
                    ApplicationArea = All;
                    Caption = 'Clarity Dashboard';
                    RunObject = page "CLR Dashboard";
                    Image = Home;
                }
                action(CLRBMScenariosNav)
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
