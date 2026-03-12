permissionset 1000221 CLARITYADMIN
{
    Assignable = true;
    Caption = 'Clarity Administrator';

    Permissions =
        tabledata "Clarity Work Item" = RIMD,
        table "Clarity Work Item" = X,
        tabledata "Clarity Setup" = RIMD,
        table "Clarity Setup" = X,
        page "Clarity Role Center" = X,
        page "Clarity Work Items" = X,
        page "Clarity Work Item Card" = X,
        page "Clarity Setup" = X,
        codeunit "Clarity Work Mgt." = X;
}
