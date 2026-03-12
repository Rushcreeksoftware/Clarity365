permissionset 1000220 CLARITY
{
    Assignable = true;
    Caption = 'Clarity User';

    Permissions =
        tabledata "Clarity Work Item" = RIMD,
        table "Clarity Work Item" = X,
        tabledata "Clarity Setup" = R,
        table "Clarity Setup" = X,
        page "Clarity Role Center" = X,
        page "Clarity Work Items" = X,
        page "Clarity Work Item Card" = X,
        page "Clarity Setup" = X,
        codeunit "Clarity Work Mgt." = X;
}
