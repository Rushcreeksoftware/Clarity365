page 50270 "CLR BI Metrics API"
{
    PageType = API;
    APIPublisher = 'rushcreeksoftware';
    APIGroup = 'clarity365';
    APIVersion = 'v1.0';
    EntityName = 'biMetric';
    EntitySetName = 'biMetrics';
    SourceTable = "CLR BI Metric Buffer";
    DelayedInsert = true;
    ODataKeyFields = "Entry No.";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(entryNo; Rec."Entry No.") { }
                field(metricCode; Rec."Metric Code") { }
                field(periodFrom; Rec."Period From") { }
                field(periodTo; Rec."Period To") { }
                field(amount; Rec.Amount) { }
                field(amount2; Rec."Amount 2") { }
                field(description; Rec.Description) { }
                field(groupCode; Rec."Group Code") { }
                field(metricType; Rec."Metric Type") { }
                field(currencyCode; Rec."Currency Code") { }
            }
        }
    }
}
