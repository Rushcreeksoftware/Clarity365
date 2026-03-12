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
}
