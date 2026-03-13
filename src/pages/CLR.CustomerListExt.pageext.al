// Clarity365 — CLR.CustomerListExt.pageext.al
// Purpose: Adds a guaranteed entry point to the Clarity dashboard from Customer List.

pageextension 50262 "CLR Customer List Ext" extends "Customer List"
{
    actions
    {
        addlast(Processing)
        {
            action(CLROpenDashboard)
            {
                ApplicationArea = All;
                Caption = 'Open Clarity Dashboard';
                Image = Home;
                RunObject = page "CLR Dashboard";
                ToolTip = 'Open the Clarity365 dashboard.';
            }
        }
    }
}
