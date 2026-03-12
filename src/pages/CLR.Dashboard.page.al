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
                begin
                    CurrentScenarioCode := 'BASE';
                    CurrentFilterJson := '';
                    RefreshDashboard();
                    CurrPage.Dashboard.SetMode('bi');
                end;

                trigger SetupRequested()
                begin
                    Page.Run(Page::"CLR Setup Wizard");
                end;

                trigger FilterChanged(FilterJson: Text)
                begin
                    CurrentFilterJson := FilterJson;
                    RefreshDashboard();
                end;

                trigger ScenarioRequested(ScenarioCode: Text)
                var
                    ForecastEngine: Codeunit "CLR Cf Forecast Engine";
                    ScenarioHeader: Record "CLR CF Scenario Header";
                begin
                    if ScenarioCode = '' then begin
                        CurrentScenarioCode := 'BASE';
                        RefreshDashboard();
                        exit;
                    end;

                    CurrentScenarioCode := CopyStr(UpperCase(ScenarioCode), 1, 20);
                    if ScenarioHeader.Get(CurrentScenarioCode) then
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

                    ViewMgt.SaveViewFromPayload(ViewCode, ViewDescription, CurrentFilterJson);
                    RefreshDashboard();
                end;

                trigger ExportRequested(ExportType: Text)
                var
                    ExportMgt: Codeunit "CLR Export Mgmt";
                begin
                    ExportMgt.ExportDashboard(ExportType, CurrentFilterJson, CurrentScenarioCode);
                end;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(OpenExportLog)
            {
                ApplicationArea = All;
                Caption = 'Export Log';
                Image = Log;
                RunObject = page "CLR Export Log List";
            }
        }
    }

    var
        CurrentFilterJson: Text;
        CurrentScenarioCode: Code[20];

    local procedure RefreshDashboard()
    var
        BiEngine: Codeunit "CLR BI Engine";
    begin
        CurrPage.Dashboard.SendData(BiEngine.BuildPayloadJsonWithContext(CurrentFilterJson, CurrentScenarioCode));
    end;
}
