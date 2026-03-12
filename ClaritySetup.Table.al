table 1000200 "Clarity Setup"
{
    Caption = 'Clarity Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(10; Enabled; Boolean)
        {
            Caption = 'Enabled';
        }
        field(20; "Default Owner User ID"; Code[50])
        {
            Caption = 'Default Owner User ID';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(30; "Default Priority"; Option)
        {
            Caption = 'Default Priority';
            OptionMembers = Low,Normal,High;
            OptionCaption = 'Low,Normal,High';
        }
        field(40; "Last Setup Validation"; DateTime)
        {
            Caption = 'Last Setup Validation';
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
}
