codeunit 50304 "CLR BI Engine"
{
    procedure BuildPayloadJson(): Text
    var
        ProviderFactory: Codeunit "CLR Provider Factory";
        Setup: Record "CLR Data Provider Setup";
        Provider: Interface "CLR IDataProvider";
        MetricBuffer: Record "CLR BI Metric Buffer" temporary;
        FromDate: Date;
        JsonText: Text;
        RevenueAmount: Decimal;
        CogsAmount: Decimal;
        GrossMarginAmount: Decimal;
        OpenArAmount: Decimal;
        OpenApAmount: Decimal;
        CashBalance: Decimal;
        GrossMarginPct: Decimal;
        MrrAmount: Decimal;
        Detector: Codeunit "CLR Module Detector";
        Payload: JsonObject;
        Kpis: JsonObject;
        Revenue: JsonArray;
        ArAging: JsonArray;
        ApAging: JsonArray;
        EmptyArr: JsonArray;
        RevenueObj: JsonObject;
        Scenarios: JsonObject;
    begin
        Provider := ProviderFactory.GetProvider();

        if not Setup.Get('') then begin
            Setup.Init();
            Setup."Primary Key" := '';
        end;

        FromDate := CalcDate('<CY>', Today());
        MetricBuffer.DeleteAll();
        Provider.GetGLMetrics(FromDate, Today(), Setup."Revenue GL Account Filter", MetricBuffer);
        RevenueAmount := GetMetricAmount(MetricBuffer, 'REVENUE');
        CogsAmount := GetMetricAmount(MetricBuffer, 'COGS');
        GrossMarginAmount := GetMetricAmount(MetricBuffer, 'GROSS_MARGIN');

        MetricBuffer.DeleteAll();
        Provider.GetARSummary(Today(), MetricBuffer);
        OpenArAmount := GetMetricAmount(MetricBuffer, 'AR_TOTAL');

        BuildAgingRows(MetricBuffer, ArAging, true);

        MetricBuffer.DeleteAll();
        Provider.GetAPSummary(Today(), MetricBuffer);
        OpenApAmount := GetMetricAmount(MetricBuffer, 'AP_TOTAL');

        BuildAgingRows(MetricBuffer, ApAging, false);

        CashBalance := Provider.GetCurrentCashBalance();

        MetricBuffer.DeleteAll();
        Provider.GetMRRMetrics(FromDate, Today(), MetricBuffer);
        MrrAmount := GetMetricAmount(MetricBuffer, 'MRR');

        if RevenueAmount <> 0 then
            GrossMarginPct := Round((GrossMarginAmount / RevenueAmount) * 100, 0.01)
        else
            GrossMarginPct := 0;

        Payload.Add('activeModules', Detector.GetActiveModulesCsv());
        Payload.Add('hasRecur365', Detector.IsRecur365Installed());
        Payload.Add('currencyCode', GetCurrencyCode());
        Payload.Add('reportingDate', Format(Today(), 0, 9));

        Kpis.Add('revenueMtd', RevenueAmount);
        Kpis.Add('revenueYtd', RevenueAmount);
        Kpis.Add('openAR', OpenArAmount);
        Kpis.Add('openAP', OpenApAmount);
        Kpis.Add('cashBalance', CashBalance);
        Kpis.Add('grossMarginPct', GrossMarginPct);
        Kpis.Add('mrr', MrrAmount);
        Kpis.Add('mrrTrend', 0);

        RevenueObj.Add('date', Format(CalcDate('<CM>', Today()), 0, 9));
        RevenueObj.Add('revenue', RevenueAmount);
        RevenueObj.Add('cogs', CogsAmount);
        RevenueObj.Add('grossMargin', GrossMarginAmount);
        Revenue.Add(RevenueObj);

        Payload.Add('kpis', Kpis);
        Payload.Add('revenue', Revenue);
        Payload.Add('arAging', ArAging);
        Payload.Add('apAging', ApAging);
        Payload.Add('dimensions', EmptyArr);
        Payload.Add('jobs', EmptyArr);
        Payload.Add('fa', EmptyArr);
        Payload.Add('payroll', EmptyArr);
        Payload.Add('service', EmptyArr);
        Payload.Add('mfg', EmptyArr);
        Payload.Add('inventory', EmptyArr);
        Payload.Add('purchasing', EmptyArr);
        Payload.Add('mrr', EmptyArr);
        Payload.Add('cashFlow', EmptyArr);
        Scenarios.Add('base', true);
        Scenarios.Add('upside', false);
        Scenarios.Add('downside', false);
        Payload.Add('scenarios', Scenarios);

        Payload.WriteTo(JsonText);
        exit(JsonText);
    end;

    local procedure GetMetricAmount(var MetricBuffer: Record "CLR BI Metric Buffer" temporary; MetricCode: Code[50]): Decimal
    begin
        MetricBuffer.Reset();
        MetricBuffer.SetRange("Metric Code", MetricCode);
        if MetricBuffer.FindLast() then
            exit(MetricBuffer.Amount);

        exit(0);
    end;

    local procedure BuildAgingRows(var MetricBuffer: Record "CLR BI Metric Buffer" temporary; var AgingArray: JsonArray; IsAr: Boolean)
    begin
        if IsAr then begin
            AddAgingRow(AgingArray, 'Current', GetMetricAmount(MetricBuffer, 'AR_CURRENT'));
            AddAgingRow(AgingArray, '1-30 days', GetMetricAmount(MetricBuffer, 'AR_1_30'));
            AddAgingRow(AgingArray, '31-60 days', GetMetricAmount(MetricBuffer, 'AR_31_60'));
            AddAgingRow(AgingArray, '61-90 days', GetMetricAmount(MetricBuffer, 'AR_61_90'));
            AddAgingRow(AgingArray, '90+ days', GetMetricAmount(MetricBuffer, 'AR_90_PLUS'));
            exit;
        end;

        AddAgingRow(AgingArray, 'Current', GetMetricAmount(MetricBuffer, 'AP_CURRENT'));
        AddAgingRow(AgingArray, '1-30 days', GetMetricAmount(MetricBuffer, 'AP_1_30'));
        AddAgingRow(AgingArray, '31-60 days', GetMetricAmount(MetricBuffer, 'AP_31_60'));
        AddAgingRow(AgingArray, '61-90 days', GetMetricAmount(MetricBuffer, 'AP_61_90'));
        AddAgingRow(AgingArray, '90+ days', GetMetricAmount(MetricBuffer, 'AP_90_PLUS'));
    end;

    local procedure AddAgingRow(var AgingArray: JsonArray; BucketLabel: Text; Amount: Decimal)
    var
        AgingItem: JsonObject;
    begin
        AgingItem.Add('bucket', BucketLabel);
        AgingItem.Add('amount', Amount);
        AgingArray.Add(AgingItem);
    end;

    local procedure GetCurrencyCode(): Code[10]
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        if GeneralLedgerSetup.Get() then
            exit(GeneralLedgerSetup."LCY Code");

        exit('');
    end;
}
