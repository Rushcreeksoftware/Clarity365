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
                    ViewMgt: Codeunit "CLR Dashboard View Mgmt";
                    LoadedFilterJson: Text;
                    LoadedMode: Text[20];
                begin
                    CurrentScenarioCode := 'BASE';
                    CurrentMode := 'bi';
                    CurrentFilterJson := '';
                    if ViewMgt.TryBuildFilterPayload('DEFAULT', LoadedFilterJson) then
                        CurrentFilterJson := LoadedFilterJson;

                    if ViewMgt.TryGetViewMode('DEFAULT', LoadedMode) then
                        CurrentMode := LoadedMode;

                    RefreshDashboard();
                    CurrPage.Dashboard.SetMode(CurrentMode);
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

                trigger ModeChanged(Mode: Text)
                begin
                    if Mode = '' then
                        exit;

                    CurrentMode := CopyStr(LowerCase(Mode), 1, MaxStrLen(CurrentMode));
                    CurrPage.Dashboard.SetMode(CurrentMode);
                end;

                trigger ScenarioRequested(ScenarioCode: Text)
                var
                    ForecastEngine: Codeunit "CLR Cf Forecast Engine";
                    ScenarioMgt: Codeunit "CLR Cf Scenario Mgmt";
                    ScenarioHeader: Record "CLR CF Scenario Header";
                begin
                    if ScenarioCode = '' then begin
                        CurrentScenarioCode := 'BASE';
                        RefreshDashboard();
                        exit;
                    end;

                    CurrentScenarioCode := CopyStr(UpperCase(ScenarioCode), 1, 20);
                    ScenarioMgt.EnsureScenarioPrerequisites(CurrentScenarioCode);

                    if ScenarioHeader.Get(CurrentScenarioCode) then
                        ForecastEngine.BuildScenario(ScenarioHeader.Code);

                    RefreshDashboard();
                end;

                trigger SaveViewRequested(ViewJson: Text)
                var
                    ViewMgt: Codeunit "CLR Dashboard View Mgmt";
                    ViewCode: Code[20];
                    ViewDescription: Text[100];
                    ViewMode: Text[20];
                    Payload: JsonObject;
                    Token: JsonToken;
                begin
                    ViewCode := 'DEFAULT';
                    ViewDescription := 'Saved dashboard view';
                    ViewMode := CurrentMode;

                    if Payload.ReadFrom(ViewJson) then begin
                        if Payload.Get('code', Token) then
                            ViewCode := CopyStr(Token.AsValue().AsText(), 1, MaxStrLen(ViewCode));
                        if Payload.Get('description', Token) then
                            ViewDescription := CopyStr(Token.AsValue().AsText(), 1, MaxStrLen(ViewDescription));
                        if Payload.Get('mode', Token) then
                            ViewMode := CopyStr(LowerCase(Token.AsValue().AsText()), 1, MaxStrLen(ViewMode));
                    end;

                    ViewMgt.SaveViewFromPayloadWithMode(ViewCode, ViewDescription, CurrentFilterJson, ViewMode);
                    RefreshDashboard();
                end;

                trigger LoadViewRequested(ViewCode: Text)
                begin
                    ApplySavedView(CopyStr(ViewCode, 1, 20));
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
            action(LoadSavedView)
            {
                ApplicationArea = All;
                Caption = 'Load Saved View';
                Image = GetSourceDoc;

                trigger OnAction()
                begin
                    SelectAndApplySavedView();
                end;
            }

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
        CurrentMode: Text[20];

    local procedure RefreshDashboard()
    var
        BiEngine: Codeunit "CLR BI Engine";
    begin
        CurrPage.Dashboard.SendData(BiEngine.BuildPayloadJsonWithContext(CurrentFilterJson, CurrentScenarioCode));
    end;

    local procedure SelectAndApplySavedView()
    var
        DashboardView: Record "CLR Dashboard View";
        DashboardViewList: Page "CLR Dashboard View List";
    begin
        DashboardViewList.LookupMode(true);
        DashboardViewList.SetTableView(DashboardView);

        if DashboardViewList.RunModal() <> Action::LookupOK then
            exit;

        DashboardViewList.GetRecord(DashboardView);
        ApplySavedView(DashboardView.Code);
    end;

    local procedure ApplySavedView(ViewCode: Code[20])
    var
        ViewMgt: Codeunit "CLR Dashboard View Mgmt";
        LoadedFilterJson: Text;
        LoadedMode: Text[20];
    begin
        if ViewCode = '' then
            exit;

        if not ViewMgt.CanCurrentUserAccessView(ViewCode) then
            Error('You do not have access to saved view %1.', ViewCode);

        if not ViewMgt.TryBuildFilterPayload(ViewCode, LoadedFilterJson) then
            Error('Saved view %1 does not contain any filters.', ViewCode);

        CurrentFilterJson := LoadedFilterJson;

        if ViewMgt.TryGetViewMode(ViewCode, LoadedMode) then begin
            CurrentMode := LoadedMode;
            CurrPage.Dashboard.SetMode(CurrentMode);
        end;

        RefreshDashboard();
    end;

}
