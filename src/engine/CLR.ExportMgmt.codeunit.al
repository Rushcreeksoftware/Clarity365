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
    begin
        ExportKind := LowerCase(Trim(ExportType));
        case ExportKind of
            'excel':
                ExportAsCsv(FilterJson, ScenarioCode);
            'pdf':
                ExportAsTextSummary(FilterJson, ScenarioCode);
            else
                Error('Unsupported export type: %1', ExportType);
        end;
    end;

    local procedure ExportAsCsv(FilterJson: Text; ScenarioCode: Code[20])
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
        DownloadFromStream(InStr, 'Clarity365 KPI Export', '', 'CSV File (*.csv)|*.csv',
          StrSubstNo('clarity365-kpis-%1.csv', Format(Today(), 0, 9)));
    end;

    local procedure ExportAsTextSummary(FilterJson: Text; ScenarioCode: Code[20])
    var
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
        InStr: InStream;
        SummaryText: Text;
    begin
        SummaryText := BuildSummaryPreview(FilterJson, ScenarioCode);

        TempBlob.CreateOutStream(OutStr, TextEncoding::UTF8);
        OutStr.WriteText(SummaryText);

        TempBlob.CreateInStream(InStr, TextEncoding::UTF8);
        DownloadFromStream(InStr, 'Clarity365 Dashboard Export', '', 'Text File (*.txt)|*.txt',
          StrSubstNo('clarity365-dashboard-export-%1.txt', Format(Today(), 0, 9)));
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
}
