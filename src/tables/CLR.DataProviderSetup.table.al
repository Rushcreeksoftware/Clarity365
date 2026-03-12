table 50200 "CLR Data Provider Setup"
{
    Caption = 'Clarity Data Provider Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10]) { Caption = 'Primary Key'; DataClassification = SystemMetadata; }
        field(10; "Revenue GL Account Filter"; Text[250]) { Caption = 'Revenue GL Account Filter'; DataClassification = CustomerContent; }
        field(11; "COGS GL Account Filter"; Text[250]) { Caption = 'COGS GL Account Filter'; DataClassification = CustomerContent; }
        field(12; "OpEx GL Account Filter"; Text[250]) { Caption = 'OpEx GL Account Filter'; DataClassification = CustomerContent; }
        field(13; "Payroll GL Account Filter"; Text[250]) { Caption = 'Payroll GL Account Filter'; DataClassification = CustomerContent; }
        field(14; "CapEx GL Account Filter"; Text[250]) { Caption = 'CapEx GL Account Filter'; DataClassification = CustomerContent; }
        field(20; "Primary Dimension Code"; Code[20]) { Caption = 'Primary Dimension Code'; DataClassification = CustomerContent; TableRelation = Dimension; }
        field(21; "Secondary Dimension Code"; Code[20]) { Caption = 'Secondary Dimension Code'; DataClassification = CustomerContent; TableRelation = Dimension; }
        field(30; "CF Forecast Months"; Integer) { Caption = 'CF Forecast Months'; DataClassification = CustomerContent; }
        field(31; "Default AR Collection Days"; Integer) { Caption = 'Default AR Collection Days'; DataClassification = CustomerContent; }
        field(32; "Default AP Payment Days"; Integer) { Caption = 'Default AP Payment Days'; DataClassification = CustomerContent; }
        field(40; "Show Jobs Module"; Boolean) { Caption = 'Show Jobs Module'; DataClassification = CustomerContent; }
        field(41; "Show FA Module"; Boolean) { Caption = 'Show FA Module'; DataClassification = CustomerContent; }
        field(42; "Show Service Module"; Boolean) { Caption = 'Show Service Module'; DataClassification = CustomerContent; }
        field(43; "Show HR Module"; Boolean) { Caption = 'Show HR Module'; DataClassification = CustomerContent; }
        field(44; "Show Manufacturing Module"; Boolean) { Caption = 'Show Manufacturing Module'; DataClassification = CustomerContent; }
        field(45; "Show Purchasing Module"; Boolean) { Caption = 'Show Purchasing Module'; DataClassification = CustomerContent; }
        field(50; "Setup Completed"; Boolean) { Caption = 'Setup Completed'; DataClassification = CustomerContent; }
    }

    keys
    {
        key(PK; "Primary Key") { Clustered = true; }
    }
}
