table 50201 "CLR BI Metric Buffer"
{
    Caption = 'Clarity BI Metric Buffer';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer) { Caption = 'Entry No.'; AutoIncrement = true; DataClassification = SystemMetadata; }
        field(10; "Metric Code"; Code[50]) { Caption = 'Metric Code'; DataClassification = CustomerContent; }
        field(11; "Period From"; Date) { Caption = 'Period From'; DataClassification = CustomerContent; }
        field(12; "Period To"; Date) { Caption = 'Period To'; DataClassification = CustomerContent; }
        field(13; Amount; Decimal) { Caption = 'Amount'; DataClassification = CustomerContent; }
        field(14; "Amount 2"; Decimal) { Caption = 'Amount 2'; DataClassification = CustomerContent; }
        field(15; Description; Text[100]) { Caption = 'Description'; DataClassification = CustomerContent; }
        field(16; "Group Code"; Code[20]) { Caption = 'Group Code'; DataClassification = CustomerContent; }
        field(17; "Metric Type"; Enum "CLR Metric Type") { Caption = 'Metric Type'; DataClassification = CustomerContent; }
        field(18; "Currency Code"; Code[10]) { Caption = 'Currency Code'; DataClassification = CustomerContent; }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
        key(MetricCode; "Metric Code", "Period From") { }
        key(GroupCode; "Group Code", "Metric Code") { }
    }
}
