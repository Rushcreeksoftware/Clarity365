codeunit 50309 "CLR Export Mgmt"
{
    procedure BuildKpiCsvPreview(FilterJson: Text; ScenarioCode: Code[20]): Text
    var
        BiEngine: Codeunit "CLR BI Engine";
        Payload: Text;
        RootObj: JsonObject;
        KpisToken: JsonToken;
        KpisObj: JsonObject;
        CsvText: Text;
        NewLine: Text;
    begin
        Payload := BiEngine.BuildPayloadJsonWithContext(FilterJson, ScenarioCode);
        if not RootObj.ReadFrom(Payload) then
            Error('Unable to parse dashboard payload for export.');

        if not RootObj.Get('kpis', KpisToken) then
            Error('Payload did not include KPI data.');

        KpisObj := KpisToken.AsObject();
        NewLine := GetNewLine();

        CsvText := 'Metric,Value' + NewLine;
        CsvText += ComposeCsvLine('Revenue MTD', GetJsonValueText(KpisObj, 'revenueMtd')) + NewLine;
        CsvText += ComposeCsvLine('Revenue YTD', GetJsonValueText(KpisObj, 'revenueYtd')) + NewLine;
        CsvText += ComposeCsvLine('Open AR', GetJsonValueText(KpisObj, 'openAR')) + NewLine;
        CsvText += ComposeCsvLine('Open AP', GetJsonValueText(KpisObj, 'openAP')) + NewLine;
        CsvText += ComposeCsvLine('Cash Balance', GetJsonValueText(KpisObj, 'cashBalance')) + NewLine;
        CsvText += ComposeCsvLine('Gross Margin %', GetJsonValueText(KpisObj, 'grossMarginPct')) + NewLine;
        CsvText += ComposeCsvLine('MRR', GetJsonValueText(KpisObj, 'mrr')) + NewLine;
        CsvText += ComposeCsvLine('MRR Trend', GetJsonValueText(KpisObj, 'mrrTrend'));

        exit(CsvText);
    end;

    procedure BuildSummaryPreview(FilterJson: Text; ScenarioCode: Code[20]): Text
    var
        BiEngine: Codeunit "CLR BI Engine";
        SummaryText: Text;
        NewLine: Text;
    begin
        NewLine := GetNewLine();
        SummaryText := 'Clarity365 Dashboard Export Summary' + NewLine;
        SummaryText += StrSubstNo('Generated At: %1', Format(CurrentDateTime(), 0, 9)) + NewLine;
        SummaryText += StrSubstNo('Scenario: %1', ScenarioCode) + NewLine;
        SummaryText += NewLine;
        SummaryText += 'Payload JSON:' + NewLine;
        SummaryText += BiEngine.BuildPayloadJsonWithContext(FilterJson, ScenarioCode);
        exit(SummaryText);
    end;

    procedure ExportDashboard(ExportType: Text; FilterJson: Text; ScenarioCode: Code[20])
    var
        ExportKind: Text;
        ExportLog: Record "CLR Export Log";
        OutputFileName: Text[100];
    begin
        ExportKind := LowerCase(Trim(ExportType));

        InitExportLog(ExportLog, ExportKind, FilterJson, ScenarioCode);
        case ExportKind of
            'excel':
                begin
                    ExportAsCsv(FilterJson, ScenarioCode, OutputFileName);
                    MarkExportCompleted(ExportLog, OutputFileName, BuildKpiCsvPreview(FilterJson, ScenarioCode));
                end;
            'pdf':
                begin
                    ExportAsPdfSummaryReport(ExportLog, OutputFileName);
                    MarkExportCompleted(ExportLog, OutputFileName, BuildSummaryPreview(FilterJson, ScenarioCode));
                end;
            else
                Error('Unsupported export type: %1', ExportType);
        end;
    end;

    local procedure ExportAsCsv(FilterJson: Text; ScenarioCode: Code[20]; var OutputFileName: Text[100])
    var
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
        InStr: InStream;
        CsvText: Text;
    begin
        CsvText := BuildKpiCsvPreview(FilterJson, ScenarioCode);

        TempBlob.CreateOutStream(OutStr, TextEncoding::UTF8);
        OutStr.WriteText(CsvText);

        TempBlob.CreateInStream(InStr, TextEncoding::UTF8);
                OutputFileName := CopyStr(StrSubstNo('clarity365-kpis-%1.csv', Format(Today(), 0, 9)), 1, MaxStrLen(OutputFileName));
        DownloadFromStream(InStr, 'Clarity365 KPI Export', '', 'CSV File (*.csv)|*.csv',
                    OutputFileName);
    end;

    local procedure ExportAsPdfSummaryReport(var ExportLog: Record "CLR Export Log"; var OutputFileName: Text[100])
    var
        FilteredExportLog: Record "CLR Export Log";
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
        InStr: InStream;
        ExportRecordRef: RecordRef;
    begin
        FilteredExportLog.SetRange("Entry No.", ExportLog."Entry No.");
        ExportRecordRef.GetTable(FilteredExportLog);

        TempBlob.CreateOutStream(OutStr);
        Report.SaveAs(Report::"CLR Dashboard Summary", '', ReportFormat::Pdf, OutStr, ExportRecordRef);

        TempBlob.CreateInStream(InStr);
        OutputFileName := CopyStr(StrSubstNo('clarity365-dashboard-export-%1.pdf', Format(Today(), 0, 9)), 1, MaxStrLen(OutputFileName));
        DownloadFromStream(InStr, 'Clarity365 Dashboard PDF Export', '', 'PDF File (*.pdf)|*.pdf', OutputFileName);
    end;

    local procedure ComposeCsvLine(Metric: Text; Value: Text): Text
    begin
        exit(StrSubstNo('"%1","%2"', EscapeCsv(Metric), EscapeCsv(Value)));
    end;

    local procedure EscapeCsv(InputText: Text): Text
    begin
        exit(ConvertStr(InputText, '"', ''''));
    end;

    local procedure GetJsonValueText(var Obj: JsonObject; PropertyName: Text): Text
    var
        Token: JsonToken;
    begin
        if not Obj.Get(PropertyName, Token) then
            exit('');

        exit(Token.AsValue().AsText());
    end;

    local procedure GetNewLine(): Text
    var
        NewLineChar: Char;
    begin
        NewLineChar := 10;
        exit(Format(NewLineChar));
    end;

    local procedure InitExportLog(var ExportLog: Record "CLR Export Log"; ExportType: Text; FilterJson: Text; ScenarioCode: Code[20])
    begin
        ExportLog.Init();
        ExportLog."Exported At" := CurrentDateTime();
        ExportLog."User ID" := CopyStr(UserId(), 1, MaxStrLen(ExportLog."User ID"));
        ExportLog."Export Type" := CopyStr(UpperCase(ExportType), 1, MaxStrLen(ExportLog."Export Type"));
        ExportLog."Scenario Code" := CopyStr(UpperCase(ScenarioCode), 1, MaxStrLen(ExportLog."Scenario Code"));
        ExportLog."Filter JSON" := CopyStr(FilterJson, 1, MaxStrLen(ExportLog."Filter JSON"));
        ExportLog.Status := 'STARTED';
        ExportLog.Insert(true);
    end;

    local procedure MarkExportCompleted(var ExportLog: Record "CLR Export Log"; FileName: Text[100]; SummaryText: Text)
    begin
        ExportLog."File Name" := FileName;
        ExportLog.Status := 'COMPLETED';
        ExportLog."Summary Text" := CopyStr(SummaryText, 1, MaxStrLen(ExportLog."Summary Text"));
        ExportLog.Modify(true);
    end;
}
