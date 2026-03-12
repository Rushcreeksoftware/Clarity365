codeunit 50341 "CLR BiEngineTests"
{
    Subtype = Test;

    [Test]
    procedure BuildPayloadJsonReturnsJson()
    var
        Library: Codeunit "CLR LibraryClarity365";
        BiEngine: Codeunit "CLR BI Engine";
        Payload: Text;
    begin
        // GIVEN
        Library.EnsureSetupDefaults();

        // WHEN
        Payload := BiEngine.BuildPayloadJson();

        // THEN
        if Payload = '' then
            Error('Expected non-empty payload JSON.');
    end;

    [Test]
    procedure BuildPayloadJsonWithContextHonorsAsOfDate()
    var
        Library: Codeunit "CLR LibraryClarity365";
        BiEngine: Codeunit "CLR BI Engine";
        Payload: Text;
        RootObj: JsonObject;
        Token: JsonToken;
        ExpectedDateText: Text;
        FilterJson: Text;
    begin
        // GIVEN
        Library.EnsureSetupDefaults();
        ExpectedDateText := Format(CalcDate('<-10D>', Today()), 0, 9);
        FilterJson := StrSubstNo('{"range":"last-30-days","asOfDate":"%1"}', ExpectedDateText);

        // WHEN
        Payload := BiEngine.BuildPayloadJsonWithContext(FilterJson, 'BASE');

        // THEN
        if not RootObj.ReadFrom(Payload) then
            Error('Expected valid JSON payload.');

        if not RootObj.Get('reportingDate', Token) then
            Error('Expected reportingDate in payload.');

        if Token.AsValue().AsText() <> ExpectedDateText then
            Error('Expected reportingDate to match filter asOfDate.');
    end;

    [Test]
    procedure BuildPayloadJsonWithInvalidScenarioFallsBackToBase()
    var
        Library: Codeunit "CLR LibraryClarity365";
        ScenarioMgt: Codeunit "CLR Cf Scenario Mgmt";
        ForecastEngine: Codeunit "CLR Cf Forecast Engine";
        BiEngine: Codeunit "CLR BI Engine";
        Payload: Text;
        RootObj: JsonObject;
        ScenariosToken: JsonToken;
        ScenariosObj: JsonObject;
        BaseToken: JsonToken;
    begin
        // GIVEN
        Library.EnsureSetupDefaults();
        ScenarioMgt.EnsureBaseScenario();
        ForecastEngine.BuildScenario('BASE');

        // WHEN
        Payload := BiEngine.BuildPayloadJsonWithContext('', 'INVALID');

        // THEN
        if not RootObj.ReadFrom(Payload) then
            Error('Expected valid JSON payload.');
        if not RootObj.Get('scenarios', ScenariosToken) then
            Error('Expected scenarios section in payload.');

        ScenariosObj := ScenariosToken.AsObject();
        if not ScenariosObj.Get('base', BaseToken) then
            Error('Expected base scenario flag.');

        if not BaseToken.AsValue().AsBoolean() then
            Error('Expected invalid scenario to fall back to BASE.');
    end;

    [Test]
    procedure BuildPayloadJsonWithInvalidAsOfDateFallsBackToToday()
    var
        Library: Codeunit "CLR LibraryClarity365";
        BiEngine: Codeunit "CLR BI Engine";
        Payload: Text;
        RootObj: JsonObject;
        Token: JsonToken;
        TodayText: Text;
    begin
        // GIVEN
        Library.EnsureSetupDefaults();
        TodayText := Format(Today(), 0, 9);

        // WHEN
        Payload := BiEngine.BuildPayloadJsonWithContext('{"range":"year-to-date","asOfDate":"BAD-DATE"}', 'BASE');

        // THEN
        if not RootObj.ReadFrom(Payload) then
            Error('Expected valid JSON payload.');

        if not RootObj.Get('reportingDate', Token) then
            Error('Expected reportingDate in payload.');

        if Token.AsValue().AsText() <> TodayText then
            Error('Expected invalid asOfDate to fall back to Today.');
    end;

    [Test]
    procedure BuildPayloadJsonWithGlFilterStillReturnsPayload()
    var
        Library: Codeunit "CLR LibraryClarity365";
        BiEngine: Codeunit "CLR BI Engine";
        Payload: Text;
        RootObj: JsonObject;
        KpisToken: JsonToken;
    begin
        // GIVEN
        Library.EnsureSetupDefaults();

        // WHEN
        Payload := BiEngine.BuildPayloadJsonWithContext('{"range":"last-12-months","glFilter":"4*"}', 'BASE');

        // THEN
        if not RootObj.ReadFrom(Payload) then
            Error('Expected valid JSON payload.');

        if not RootObj.Get('kpis', KpisToken) then
            Error('Expected KPI section in payload.');
    end;
}
