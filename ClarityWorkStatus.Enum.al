enum 1000211 "Clarity Work Status"
{
    Caption = 'Clarity Work Status';
    Extensible = true;

    value(0; Open)
    {
        Caption = 'Open';
    }
    value(1; "In Progress")
    {
        Caption = 'In Progress';
    }
    value(2; Blocked)
    {
        Caption = 'Blocked';
    }
    value(3; Done)
    {
        Caption = 'Done';
    }
}
