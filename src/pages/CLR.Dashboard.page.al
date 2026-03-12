page 50250 "CLR Dashboard"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    Caption = 'Clarity Dashboard';

    layout
    {
        area(Content)
        {
            usercontrol(Dashboard; "CLR Dashboard")
            {
                ApplicationArea = All;

                trigger ControlAddInReady()
                var
                    BiEngine: Codeunit "CLR BI Engine";
                begin
                    CurrPage.Dashboard.SendData(BiEngine.BuildPayloadJson());
                    CurrPage.Dashboard.SetMode('bi');
                end;

                trigger SetupRequested()
                begin
                    Page.Run(Page::"CLR Setup Wizard");
                end;

                trigger FilterChanged(FilterJson: Text)
                begin
                    if FilterJson <> '' then;
                    RefreshDashboard();
                end;

                trigger ScenarioRequested(ScenarioCode: Text)
                var
                    ForecastEngine: Codeunit "CLR Cf Forecast Engine";
                    ScenarioHeader: Record "CLR CF Scenario Header";
                begin
                    if ScenarioCode = '' then begin
                        RefreshDashboard();
                        exit;
                    end;

                    if ScenarioHeader.Get(CopyStr(UpperCase(ScenarioCode), 1, MaxStrLen(ScenarioHeader.Code))) then
                        ForecastEngine.BuildScenario(ScenarioHeader.Code);

                    RefreshDashboard();
                end;

                trigger SaveViewRequested(ViewJson: Text)
                var
                    ViewMgt: Codeunit "CLR Dashboard View Mgmt";
                    ViewCode: Code[20];
                    ViewDescription: Text[100];
                    Payload: JsonObject;
                    Token: JsonToken;
                begin
                    ViewCode := 'DEFAULT';
                    ViewDescription := 'Saved dashboard view';

                    if Payload.ReadFrom(ViewJson) then begin
                        if Payload.Get('code', Token) then
                            ViewCode := CopyStr(Token.AsValue().AsText(), 1, MaxStrLen(ViewCode));
                        if Payload.Get('description', Token) then
                            ViewDescription := CopyStr(Token.AsValue().AsText(), 1, MaxStrLen(ViewDescription));
                    end;

                    ViewMgt.SaveView(ViewCode, ViewDescription);
                    RefreshDashboard();
                end;

                trigger ExportRequested(ExportType: Text)
                begin
                    Message('Clarity export requested: %1', ExportType);
                end;
            }
        }
    }

    local procedure RefreshDashboard()
    var
        BiEngine: Codeunit "CLR BI Engine";
    begin
        CurrPage.Dashboard.SendData(BiEngine.BuildPayloadJson());
    end;
}
