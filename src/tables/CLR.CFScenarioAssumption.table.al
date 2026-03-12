table 50205 "CLR CF Scenario Assumption"
{
    Caption = 'Clarity CF Scenario Assumption';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Scenario Code"; Code[20]) { Caption = 'Scenario Code'; DataClassification = CustomerContent; TableRelation = "CLR CF Scenario Header"; }
        field(2; "Line No."; Integer) { Caption = 'Line No.'; DataClassification = CustomerContent; }
        field(10; Category; Enum "CLR CF Category") { Caption = 'Category'; DataClassification = CustomerContent; }
        field(11; Description; Text[100]) { Caption = 'Description'; DataClassification = CustomerContent; }
        field(12; Value; Decimal) { Caption = 'Value'; DataClassification = CustomerContent; }
        field(13; "Apply From"; Date) { Caption = 'Apply From'; DataClassification = CustomerContent; }
        field(14; "Apply To"; Date) { Caption = 'Apply To'; DataClassification = CustomerContent; }
        field(15; "Currency Code"; Code[10]) { Caption = 'Currency Code'; DataClassification = CustomerContent; }
    }

    keys
    {
        key(PK; "Scenario Code", "Line No.") { Clustered = true; }
    }
}
