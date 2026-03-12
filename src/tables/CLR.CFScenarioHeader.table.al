table 50204 "CLR CF Scenario Header"
{
    Caption = 'Clarity CF Scenario Header';
    DataClassification = CustomerContent;

    fields
    {
        field(1; Code; Code[20]) { Caption = 'Code'; DataClassification = CustomerContent; }
        field(10; Description; Text[100]) { Caption = 'Description'; DataClassification = CustomerContent; }
        field(11; "Base Scenario"; Boolean) { Caption = 'Base Scenario'; DataClassification = CustomerContent; }
        field(12; "Forecast Start"; Date) { Caption = 'Forecast Start'; DataClassification = CustomerContent; }
        field(13; "Forecast End"; Date) { Caption = 'Forecast End'; DataClassification = CustomerContent; }
        field(14; Status; Enum "CLR Scenario Status") { Caption = 'Status'; DataClassification = CustomerContent; }
        field(15; "Created By"; Code[50]) { Caption = 'Created By'; DataClassification = EndUserIdentifiableInformation; }
        field(16; "Created Date"; Date) { Caption = 'Created Date'; DataClassification = CustomerContent; }
        field(17; "Last Built"; DateTime) { Caption = 'Last Built'; DataClassification = CustomerContent; }
    }

    keys
    {
        key(PK; Code) { Clustered = true; }
    }
}
