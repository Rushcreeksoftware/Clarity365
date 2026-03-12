codeunit 50309 "CLR Export Mgmt"
{
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
        BiEngine: Codeunit "CLR BI Engine";
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
        InStr: InStream;
        Payload: Text;
        RootObj: JsonObject;
        KpisToken: JsonToken;
        KpisObj: JsonObject;
    begin
        Payload := BiEngine.BuildPayloadJsonWithContext(FilterJson, ScenarioCode);
        if not RootObj.ReadFrom(Payload) then
            Error('Unable to parse dashboard payload for export.');

        if not RootObj.Get('kpis', KpisToken) then
            Error('Payload did not include KPI data.');

        KpisObj := KpisToken.AsObject();

        TempBlob.CreateOutStream(OutStr, TextEncoding::UTF8);
        OutStr.WriteText('Metric,Value');
        OutStr.WriteText('');
        WriteCsvLine(OutStr, 'Revenue MTD', GetJsonValueText(KpisObj, 'revenueMtd'));
        WriteCsvLine(OutStr, 'Revenue YTD', GetJsonValueText(KpisObj, 'revenueYtd'));
        WriteCsvLine(OutStr, 'Open AR', GetJsonValueText(KpisObj, 'openAR'));
        WriteCsvLine(OutStr, 'Open AP', GetJsonValueText(KpisObj, 'openAP'));
        WriteCsvLine(OutStr, 'Cash Balance', GetJsonValueText(KpisObj, 'cashBalance'));
        WriteCsvLine(OutStr, 'Gross Margin %', GetJsonValueText(KpisObj, 'grossMarginPct'));
        WriteCsvLine(OutStr, 'MRR', GetJsonValueText(KpisObj, 'mrr'));
        WriteCsvLine(OutStr, 'MRR Trend', GetJsonValueText(KpisObj, 'mrrTrend'));

        TempBlob.CreateInStream(InStr, TextEncoding::UTF8);
        DownloadFromStream(InStr, 'Clarity365 KPI Export', '', 'CSV File (*.csv)|*.csv',
          StrSubstNo('clarity365-kpis-%1.csv', Format(Today(), 0, 9)));
    end;

    local procedure ExportAsTextSummary(FilterJson: Text; ScenarioCode: Code[20])
    var
        BiEngine: Codeunit "CLR BI Engine";
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
        InStr: InStream;
        Payload: Text;
    begin
        Payload := BiEngine.BuildPayloadJsonWithContext(FilterJson, ScenarioCode);

        TempBlob.CreateOutStream(OutStr, TextEncoding::UTF8);
        OutStr.WriteText('Clarity365 Dashboard Export Summary');
        OutStr.WriteText(StrSubstNo('Generated At: %1', Format(CurrentDateTime(), 0, 9)));
        OutStr.WriteText(StrSubstNo('Scenario: %1', ScenarioCode));
        OutStr.WriteText('');
        OutStr.WriteText('Payload JSON:');
        OutStr.WriteText(Payload);

        TempBlob.CreateInStream(InStr, TextEncoding::UTF8);
        DownloadFromStream(InStr, 'Clarity365 Dashboard Export', '', 'Text File (*.txt)|*.txt',
          StrSubstNo('clarity365-dashboard-export-%1.txt', Format(Today(), 0, 9)));
    end;

    local procedure WriteCsvLine(var OutStr: OutStream; Metric: Text; Value: Text)
    begin
        OutStr.WriteText(StrSubstNo('"%1","%2"', EscapeCsv(Metric), EscapeCsv(Value)));
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
}
