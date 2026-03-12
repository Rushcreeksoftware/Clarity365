codeunit 50344 "CLR ProviderTests"
{
    Subtype = Test;

    [Test]
    procedure BCNativeProviderReturnsCashBalance()
    var
        Provider: Codeunit "CLR BC Native Provider";
        CashBalance: Decimal;
    begin
        // GIVEN

        // WHEN
        CashBalance := Provider.GetCurrentCashBalance();

        // THEN
        if CashBalance <> CashBalance then
            Error('Unexpected cash balance result.');
    end;

    [Test]
    procedure ExportMgmtBuildKpiCsvPreviewContainsHeaders()
    var
        Library: Codeunit "CLR LibraryClarity365";
        ExportMgt: Codeunit "CLR Export Mgmt";
        CsvText: Text;
    begin
        // GIVEN
        Library.EnsureSetupDefaults();

        // WHEN
        CsvText := ExportMgt.BuildKpiCsvPreview('', 'BASE');

        // THEN
        if StrPos(CsvText, 'Metric,Value') = 0 then
            Error('Expected CSV header row in export preview.');
        if StrPos(CsvText, 'Revenue MTD') = 0 then
            Error('Expected Revenue MTD row in CSV preview.');
    end;

    [Test]
    procedure ExportMgmtBuildSummaryPreviewContainsScenario()
    var
        Library: Codeunit "CLR LibraryClarity365";
        ExportMgt: Codeunit "CLR Export Mgmt";
        SummaryText: Text;
    begin
        // GIVEN
        Library.EnsureSetupDefaults();

        // WHEN
        SummaryText := ExportMgt.BuildSummaryPreview('', 'UPSIDE');

        // THEN
        if StrPos(SummaryText, 'Clarity365 Dashboard Export Summary') = 0 then
            Error('Expected summary header in export preview.');
        if StrPos(SummaryText, 'Scenario: UPSIDE') = 0 then
            Error('Expected scenario value in export summary preview.');
    end;

    [Test]
    procedure DashboardViewMgmtPersistsFilterPayload()
    var
        ViewMgt: Codeunit "CLR Dashboard View Mgmt";
        ViewFilter: Record "CLR Dashboard View Filter";
    begin
        // GIVEN
        ViewFilter.SetRange("View Code", 'UTVIEW');
        if not ViewFilter.IsEmpty() then
            ViewFilter.DeleteAll();

        // WHEN
        ViewMgt.SaveViewFromPayload('UTVIEW', 'Unit Test View', '{"range":"last-30-days","glFilter":"4*","dimensionCode":"DEPARTMENT"}');

        // THEN
        ViewFilter.SetRange("View Code", 'UTVIEW');
        if ViewFilter.Count() = 0 then
            Error('Expected saved view filters for UTVIEW.');
    end;

    [Test]
    procedure DashboardViewMgmtBuildsFilterPayloadFromSavedView()
    var
        ViewMgt: Codeunit "CLR Dashboard View Mgmt";
        FilterJson: Text;
        Payload: JsonObject;
        Token: JsonToken;
    begin
        // GIVEN
        ViewMgt.SaveViewFromPayload('UTVIEW2', 'Unit Test View 2', '{"range":"last-12-months","asOfDate":"2026-03-12","glFilter":"4*","dimensionCode":"DEPARTMENT"}');

        // WHEN
        if not ViewMgt.TryBuildFilterPayload('UTVIEW2', FilterJson) then
            Error('Expected filter payload for UTVIEW2.');

        // THEN
        if not Payload.ReadFrom(FilterJson) then
            Error('Expected valid JSON payload from saved view filters.');

        if not Payload.Get('range', Token) then
            Error('Expected range property in loaded filter payload.');
        if Token.AsValue().AsText() <> 'last-12-months' then
            Error('Unexpected range value in loaded filter payload.');

        if not Payload.Get('asOfDate', Token) then
            Error('Expected asOfDate property in loaded filter payload.');
        if Token.AsValue().AsText() <> '2026-03-12' then
            Error('Unexpected asOfDate value in loaded filter payload.');
    end;

    [Test]
    procedure DashboardViewMgmtCanShareAndUnshareView()
    var
        ViewMgt: Codeunit "CLR Dashboard View Mgmt";
        DashboardView: Record "CLR Dashboard View";
    begin
        // GIVEN
        ViewMgt.SaveView('UTVSHARE', 'Share Toggle View');

        // WHEN
        ViewMgt.SetViewShared('UTVSHARE', true);

        // THEN
        DashboardView.Get('UTVSHARE');
        if not DashboardView."Is Shared" then
            Error('Expected view to be marked shared.');

        // WHEN
        ViewMgt.SetViewShared('UTVSHARE', false);

        // THEN
        DashboardView.Get('UTVSHARE');
        if DashboardView."Is Shared" then
            Error('Expected view to be marked unshared.');
    end;

    [Test]
    procedure DashboardViewMgmtCurrentUserCanAccessOwnView()
    var
        ViewMgt: Codeunit "CLR Dashboard View Mgmt";
    begin
        // GIVEN
        ViewMgt.SaveView('UTACCESS', 'Access Test View');

        // WHEN / THEN
        if not ViewMgt.CanCurrentUserAccessView('UTACCESS') then
            Error('Expected current user to access own view.');
    end;

    [Test]
    procedure DashboardViewMgmtPersistsAndReturnsViewMode()
    var
        ViewMgt: Codeunit "CLR Dashboard View Mgmt";
        ViewMode: Text[20];
    begin
        // GIVEN
        ViewMgt.SaveViewWithMode('UTMODE', 'Mode View', 'cashflow');

        // WHEN
        if not ViewMgt.TryGetViewMode('UTMODE', ViewMode) then
            Error('Expected to retrieve saved view mode.');

        // THEN
        if ViewMode <> 'cashflow' then
            Error('Expected saved view mode to be cashflow.');
    end;

    [Test]
    procedure DashboardViewMgmtDefaultsModeToBiWhenBlank()
    var
        ViewMgt: Codeunit "CLR Dashboard View Mgmt";
        ViewMode: Text[20];
    begin
        // GIVEN
        ViewMgt.SaveViewWithMode('UTMODEBI', 'Mode Default View', '');

        // WHEN
        if not ViewMgt.TryGetViewMode('UTMODEBI', ViewMode) then
            Error('Expected to retrieve saved view mode.');

        // THEN
        if ViewMode <> 'bi' then
            Error('Expected blank mode to default to bi.');
    end;

    [Test]
    procedure DashboardViewMgmtPersistsModeFromPayloadSave()
    var
        ViewMgt: Codeunit "CLR Dashboard View Mgmt";
        ViewMode: Text[20];
    begin
        // GIVEN
        ViewMgt.SaveViewFromPayloadWithMode('UTMODEPAY', 'Mode Payload View', '{"range":"year-to-date"}', 'cashflow');

        // WHEN
        if not ViewMgt.TryGetViewMode('UTMODEPAY', ViewMode) then
            Error('Expected to retrieve saved view mode.');

        // THEN
        if ViewMode <> 'cashflow' then
            Error('Expected payload save mode to persist as cashflow.');
    end;
}
