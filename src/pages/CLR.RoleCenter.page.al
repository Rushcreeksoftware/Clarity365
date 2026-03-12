// Clarity365 — CLR.RoleCenter.page.al
// Purpose: Role Center for dedicated Clarity365 users, providing quick access to
//          the dashboard, cash flow scenarios, saved views, and admin pages.
// Called by: CLR Profile; also used when user switches Role to 'Clarity365'

page 50258 "CLR Role Center"
{
    PageType = RoleCenter;
    ApplicationArea = All;
    Caption = 'Clarity365';

    layout
    {
        area(RoleCenter)
        {
        }
    }

    actions
    {
        area(Sections)
        {
            group(CLRDashboardGroup)
            {
                Caption = 'Dashboard';

                action(CLRDashboardAction)
                {
                    ApplicationArea = All;
                    Caption = 'Clarity Dashboard';
                    RunObject = page "CLR Dashboard";
                    Image = Home;
                }
                action(CLRCashFlowScenariosAction)
                {
                    ApplicationArea = All;
                    Caption = 'Cash Flow Scenarios';
                    RunObject = page "CLR CF Scenario List";
                    Image = Forecast;
                }
                action(CLRManualCFAction)
                {
                    ApplicationArea = All;
                    Caption = 'Manual Cash Flow Entries';
                    RunObject = page "CLR Manual CF Entry List";
                    Image = Register;
                }
                action(CLRSavedViewsAction)
                {
                    ApplicationArea = All;
                    Caption = 'Saved Views';
                    RunObject = page "CLR Dashboard View List";
                    Image = View;
                }
            }
            group(CLRAdminGroup)
            {
                Caption = 'Administration';

                action(CLRSetupAction)
                {
                    ApplicationArea = All;
                    Caption = 'Clarity Setup';
                    RunObject = page "CLR Setup";
                    Image = Setup;
                }
                action(CLRExportLogAction)
                {
                    ApplicationArea = All;
                    Caption = 'Export Log';
                    RunObject = page "CLR Export Log List";
                    Image = Log;
                }
            }
        }
    }
}
