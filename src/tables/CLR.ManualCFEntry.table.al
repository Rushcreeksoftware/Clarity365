table 50207 "CLR Manual CF Entry"
{
    Caption = 'Clarity Manual CF Entry';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer) { Caption = 'Entry No.'; AutoIncrement = true; DataClassification = SystemMetadata; }
        field(10; "Scenario Code"; Code[20]) { Caption = 'Scenario Code'; DataClassification = CustomerContent; TableRelation = "CLR CF Scenario Header"; }
        field(11; "Posting Date"; Date) { Caption = 'Posting Date'; DataClassification = CustomerContent; }
        field(12; Description; Text[100]) { Caption = 'Description'; DataClassification = CustomerContent; }
        field(13; Amount; Decimal) { Caption = 'Amount'; DataClassification = CustomerContent; }
        field(14; "Is Receipt"; Boolean) { Caption = 'Is Receipt'; DataClassification = CustomerContent; }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
    }
}
