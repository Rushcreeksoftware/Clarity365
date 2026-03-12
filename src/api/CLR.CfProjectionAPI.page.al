page 50271 "CLR CF Projection API"
{
    PageType = API;
    APIPublisher = 'rushcreeksoftware';
    APIGroup = 'clarity365';
    APIVersion = 'v1.0';
    EntityName = 'cfProjection';
    EntitySetName = 'cfProjections';
    SourceTable = "CLR CF Projection Line";
    DelayedInsert = true;
    ODataKeyFields = "Scenario Code", "Projection Date", Category;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(scenarioCode; Rec."Scenario Code") { }
                field(projectionDate; Rec."Projection Date") { }
                field(category; Rec.Category) { }
                field(amount; Rec.Amount) { }
                field(cumulativeCash; Rec."Cumulative Cash") { }
                field(source; Rec.Source) { }
                field(isActual; Rec."Is Actual") { }
            }
        }
    }
}
