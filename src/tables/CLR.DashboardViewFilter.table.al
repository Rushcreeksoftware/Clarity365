table 50203 "CLR Dashboard View Filter"
{
    Caption = 'Clarity Dashboard View Filter';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "View Code"; Code[20]) { Caption = 'View Code'; DataClassification = CustomerContent; TableRelation = "CLR Dashboard View"; }
        field(2; "Line No."; Integer) { Caption = 'Line No.'; DataClassification = CustomerContent; }
        field(10; "Field Name"; Text[100]) { Caption = 'Field Name'; DataClassification = CustomerContent; }
        field(11; "Filter Value"; Text[250]) { Caption = 'Filter Value'; DataClassification = CustomerContent; }
    }

    keys
    {
        key(PK; "View Code", "Line No.") { Clustered = true; }
    }
}
