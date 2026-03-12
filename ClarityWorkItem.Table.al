table 1000210 "Clarity Work Item"
{
    Caption = 'Clarity Work Item';
    DataClassification = CustomerContent;
    DrillDownPageId = "Clarity Work Items";
    LookupPageId = "Clarity Work Items";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
        }
        field(10; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(20; Status; Enum "Clarity Work Status")
        {
            Caption = 'Status';
        }
        field(30; Priority; Option)
        {
            Caption = 'Priority';
            OptionMembers = Low,Normal,High;
            OptionCaption = 'Low,Normal,High';
        }
        field(40; "Owner User ID"; Code[50])
        {
            Caption = 'Owner User ID';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(50; "Due Date"; Date)
        {
            Caption = 'Due Date';
        }
        field(60; "Created At"; DateTime)
        {
            Caption = 'Created At';
            Editable = false;
        }
    }

    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
        key(StatusDueDate; Status, "Due Date")
        {
        }
    }

    trigger OnInsert()
    begin
        if "Created At" = 0DT then
            "Created At" := CurrentDateTime();
        if Status = Status::" " then
            Status := Status::Open;
    end;
}
