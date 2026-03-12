table 50208 "CLR Error Log"
{
    Caption = 'Clarity Error Log';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer) { Caption = 'Entry No.'; AutoIncrement = true; DataClassification = SystemMetadata; }
        field(10; "Logged At"; DateTime) { Caption = 'Logged At'; DataClassification = CustomerContent; }
        field(11; "Source Object"; Text[100]) { Caption = 'Source Object'; DataClassification = CustomerContent; }
        field(12; Message; Text[250]) { Caption = 'Message'; DataClassification = CustomerContent; }
        field(13; Details; Text[2048]) { Caption = 'Details'; DataClassification = CustomerContent; }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
    }
}
