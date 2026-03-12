codeunit 50342 "CLR CfEngineTests"
{
    Subtype = Test;

    [Test]
    procedure BuildScenarioCreatesProjectionRows()
    var
        Library: Codeunit "CLR LibraryClarity365";
        ScenarioMgt: Codeunit "CLR Cf Scenario Mgmt";
        ForecastEngine: Codeunit "CLR Cf Forecast Engine";
        ProjectionLine: Record "CLR CF Projection Line";
    begin
        // GIVEN
        Library.EnsureSetupDefaults();
        ScenarioMgt.EnsureBaseScenario();

        // WHEN
        ForecastEngine.BuildScenario('BASE');

        // THEN
        ProjectionLine.SetRange("Scenario Code", 'BASE');
        if ProjectionLine.IsEmpty() then
            Error('Expected projection lines for BASE scenario.');
    end;

    [Test]
    procedure EnsureScenarioPrerequisitesBuildsBaseForUpside()
    var
        Library: Codeunit "CLR LibraryClarity365";
        ScenarioMgt: Codeunit "CLR Cf Scenario Mgmt";
        BaseScenario: Record "CLR CF Scenario Header";
        ProjectionLine: Record "CLR CF Projection Line";
    begin
        // GIVEN
        Library.EnsureSetupDefaults();
        ScenarioMgt.EnsureBaseScenario();

        if BaseScenario.Get('BASE') then begin
            BaseScenario."Forecast Start" := Today();
            BaseScenario."Forecast End" := CalcDate('<6M>', Today());
            BaseScenario.Modify(true);
        end;

        ProjectionLine.SetRange("Scenario Code", 'BASE');
        if not ProjectionLine.IsEmpty() then
            ProjectionLine.DeleteAll();

        // WHEN
        ScenarioMgt.EnsureScenarioPrerequisites('UPSIDE');

        // THEN
        if not ScenarioMgt.ScenarioHasProjectionData('BASE') then
            Error('Expected BASE scenario projection data to be prepared before UPSIDE.');
    end;

    [Test]
    procedure BuildScenarioAppliesOneOffAssumptions()
    var
        Library: Codeunit "CLR LibraryClarity365";
        ScenarioMgt: Codeunit "CLR Cf Scenario Mgmt";
        ForecastEngine: Codeunit "CLR Cf Forecast Engine";
        BaseScenario: Record "CLR CF Scenario Header";
        Assumption: Record "CLR CF Scenario Assumption";
        ProjectionLine: Record "CLR CF Projection Line";
    begin
        // GIVEN
        Library.EnsureSetupDefaults();
        ScenarioMgt.EnsureBaseScenario();

        BaseScenario.Get('BASE');
        BaseScenario."Forecast Start" := Today();
        BaseScenario."Forecast End" := CalcDate('<1M>', Today());
        BaseScenario.Modify(true);

        Assumption.SetRange("Scenario Code", 'BASE');
        if not Assumption.IsEmpty() then
            Assumption.DeleteAll();

        Assumption.Init();
        Assumption."Scenario Code" := 'BASE';
        Assumption."Line No." := 10000;
        Assumption.Category := Assumption.Category::OneOffPayment;
        Assumption.Description := 'Unit test one-off payment';
        Assumption.Value := 2500;
        Assumption."Apply From" := Today();
        Assumption.Insert(true);

        // WHEN
        ForecastEngine.BuildScenario('BASE');

        // THEN
        ProjectionLine.SetRange("Scenario Code", 'BASE');
        ProjectionLine.SetRange(Category, ProjectionLine.Category::OneOffPayment);
        if ProjectionLine.IsEmpty() then
            Error('Expected one-off payment line from scenario assumption.');
    end;

    [Test]
    procedure CreateOrUpdateScenarioRejectsInvalidDates()
    var
        Library: Codeunit "CLR LibraryClarity365";
        ScenarioMgt: Codeunit "CLR Cf Scenario Mgmt";
    begin
        // GIVEN
        Library.EnsureSetupDefaults();

        // WHEN / THEN
        asserterror ScenarioMgt.CreateOrUpdateScenario(
            'UTBADDATE',
            'Invalid Dates',
            Today(),
            CalcDate('<-1M>', Today()),
            Enum::"CLR Scenario Status"::Draft,
            false);
    end;

    [Test]
    procedure CreateOrUpdateScenarioKeepsSingleBaseScenario()
    var
        Library: Codeunit "CLR LibraryClarity365";
        ScenarioMgt: Codeunit "CLR Cf Scenario Mgmt";
        BaseScenario: Record "CLR CF Scenario Header";
        NewBaseScenario: Record "CLR CF Scenario Header";
    begin
        // GIVEN
        Library.EnsureSetupDefaults();
        ScenarioMgt.EnsureBaseScenario();

        // WHEN
        ScenarioMgt.CreateOrUpdateScenario(
            'UTBASE2',
            'Replacement Base',
            Today(),
            CalcDate('<6M>', Today()),
            Enum::"CLR Scenario Status"::Active,
            true);

        // THEN
        BaseScenario.Get('BASE');
        if BaseScenario."Base Scenario" then
            Error('Expected original BASE scenario to be unset as base.');

        NewBaseScenario.Get('UTBASE2');
        if not NewBaseScenario."Base Scenario" then
            Error('Expected UTBASE2 to be the new base scenario.');
    end;

    [Test]
    procedure BuildScenarioPreservesExistingActualLines()
    var
        Library: Codeunit "CLR LibraryClarity365";
        ScenarioMgt: Codeunit "CLR Cf Scenario Mgmt";
        ForecastEngine: Codeunit "CLR Cf Forecast Engine";
        BaseScenario: Record "CLR CF Scenario Header";
        ProjectionLine: Record "CLR CF Projection Line";
    begin
        // GIVEN
        Library.EnsureSetupDefaults();
        ScenarioMgt.EnsureBaseScenario();

        BaseScenario.Get('BASE');
        BaseScenario."Forecast Start" := CalcDate('<-1M>', Today());
        BaseScenario."Forecast End" := CalcDate('<1M>', Today());
        BaseScenario.Modify(true);

        ProjectionLine.SetRange("Scenario Code", 'BASE');
        if not ProjectionLine.IsEmpty() then
            ProjectionLine.DeleteAll();

        ProjectionLine.Init();
        ProjectionLine."Scenario Code" := 'BASE';
        ProjectionLine."Projection Date" := CalcDate('<-1D>', Today());
        ProjectionLine.Category := ProjectionLine.Category::OpeningBalance;
        ProjectionLine.Amount := 1234;
        ProjectionLine."Cumulative Cash" := 1234;
        ProjectionLine.Source := 'ACTUAL';
        ProjectionLine."Is Actual" := true;
        ProjectionLine.Insert(true);

        // WHEN
        ForecastEngine.BuildScenario('BASE');

        // THEN
        if not ProjectionLine.Get('BASE', CalcDate('<-1D>', Today()), ProjectionLine.Category::OpeningBalance) then
            Error('Expected existing actual line to be preserved.');
        if not ProjectionLine."Is Actual" then
            Error('Expected preserved line to remain marked as actual.');
    end;
}
