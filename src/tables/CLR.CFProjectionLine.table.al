table 50206 "CLR CF Projection Line"
{
    Caption = 'Clarity CF Projection Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Scenario Code"; Code[20]) { Caption = 'Scenario Code'; DataClassification = CustomerContent; TableRelation = "CLR CF Scenario Header"; }
        field(2; "Projection Date"; Date) { Caption = 'Projection Date'; DataClassification = CustomerContent; }
        field(3; Category; Enum "CLR CF Line Category") { Caption = 'Category'; DataClassification = CustomerContent; }
        field(10; Amount; Decimal) { Caption = 'Amount'; DataClassification = CustomerContent; }
        field(11; "Cumulative Cash"; Decimal) { Caption = 'Cumulative Cash'; DataClassification = CustomerContent; }
        field(12; Source; Text[100]) { Caption = 'Source'; DataClassification = CustomerContent; }
        field(13; "Is Actual"; Boolean) { Caption = 'Is Actual'; DataClassification = CustomerContent; }
    }

    keys
    {
        key(PK; "Scenario Code", "Projection Date", Category) { Clustered = true; }
        key(DateIdx; "Projection Date", "Scenario Code") { }
        key(ScenarioIdx; "Scenario Code", "Is Actual") { }
    }
}
