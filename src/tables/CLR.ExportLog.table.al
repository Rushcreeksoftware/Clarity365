table 50209 "CLR Export Log"
{
    Caption = 'Clarity Export Log';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
            DataClassification = SystemMetadata;
        }
        field(10; "Exported At"; DateTime)
        {
            Caption = 'Exported At';
            DataClassification = CustomerContent;
        }
        field(11; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(12; "Export Type"; Code[20])
        {
            Caption = 'Export Type';
            DataClassification = CustomerContent;
        }
        field(13; "Scenario Code"; Code[20])
        {
            Caption = 'Scenario Code';
            DataClassification = CustomerContent;
        }
        field(14; "Filter JSON"; Text[2048])
        {
            Caption = 'Filter JSON';
            DataClassification = CustomerContent;
        }
        field(15; "File Name"; Text[100])
        {
            Caption = 'File Name';
            DataClassification = CustomerContent;
        }
        field(16; Status; Code[20])
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
        }
        field(17; "Summary Text"; Text[2048])
        {
            Caption = 'Summary Text';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(ExportedAt; "Exported At")
        {
        }
    }
}
