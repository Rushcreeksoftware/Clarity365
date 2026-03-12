table 50202 "CLR Dashboard View"
{
    Caption = 'Clarity Dashboard View';
    DataClassification = CustomerContent;

    fields
    {
        field(1; Code; Code[20]) { Caption = 'Code'; DataClassification = CustomerContent; }
        field(10; "User ID"; Code[50]) { Caption = 'User ID'; DataClassification = EndUserIdentifiableInformation; }
        field(11; Description; Text[100]) { Caption = 'Description'; DataClassification = CustomerContent; }
        field(12; Mode; Text[20]) { Caption = 'Mode'; DataClassification = CustomerContent; }
        field(13; "From Date Formula"; DateFormula) { Caption = 'From Date Formula'; DataClassification = CustomerContent; }
        field(14; "To Date Formula"; DateFormula) { Caption = 'To Date Formula'; DataClassification = CustomerContent; }
        field(15; "Dimension Code"; Code[20]) { Caption = 'Dimension Code'; DataClassification = CustomerContent; TableRelation = Dimension; }
        field(16; "Chart Types JSON"; Blob) { Caption = 'Chart Types JSON'; DataClassification = CustomerContent; }
        field(17; "Is Shared"; Boolean) { Caption = 'Is Shared'; DataClassification = CustomerContent; }
        field(18; "Created DateTime"; DateTime) { Caption = 'Created DateTime'; DataClassification = CustomerContent; }
    }

    keys
    {
        key(PK; Code) { Clustered = true; }
    }
}
