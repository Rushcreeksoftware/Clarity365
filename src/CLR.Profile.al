// Clarity365 — CLR.Profile.al
// Purpose: Profile that makes Clarity365 the home Role Center for dedicated users.
//          Users can switch to this via Settings > My Settings > Role.

profile "CLR-ADMIN"
{
    Caption = 'Clarity365';
    ProfileDescription = 'Self-service BI dashboard and cash flow forecasting for Business Central.';
    RoleCenter = "CLR Role Center";
    Enabled = true;
    Promoted = true;
}
