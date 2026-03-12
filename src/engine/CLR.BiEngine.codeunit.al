codeunit 50304 "CLR BI Engine"
{
    procedure BuildPayloadJson(): Text
    var
        ProviderFactory: Codeunit "CLR Provider Factory";
        Setup: Record "CLR Data Provider Setup";
        Provider: Interface "CLR IDataProvider";
        MetricBuffer: Record "CLR BI Metric Buffer" temporary;
        FromDate: Date;
        AsOfDate: Date;
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
        Dimensions: JsonArray;
        Jobs: JsonArray;
        Fa: JsonArray;
        Payroll: JsonArray;
        Service: JsonArray;
        Mfg: JsonArray;
        Inventory: JsonArray;
        Purchasing: JsonArray;
        MrrSeries: JsonArray;
        CashFlow: JsonArray;
        RevenueObj: JsonObject;
        Scenarios: JsonObject;
    begin
        Provider := ProviderFactory.GetProvider();

        if not Setup.Get('') then begin
            Setup.Init();
            Setup."Primary Key" := '';
        end;

        FromDate := CalcDate('<CY>', Today());
        AsOfDate := Today();
        MetricBuffer.DeleteAll();
        Provider.GetGLMetrics(FromDate, AsOfDate, Setup."Revenue GL Account Filter", MetricBuffer);
        RevenueAmount := GetMetricAmount(MetricBuffer, 'REVENUE');
        CogsAmount := GetMetricAmount(MetricBuffer, 'COGS');
        GrossMarginAmount := GetMetricAmount(MetricBuffer, 'GROSS_MARGIN');

        MetricBuffer.DeleteAll();
        Provider.GetARSummary(AsOfDate, MetricBuffer);
        OpenArAmount := GetMetricAmount(MetricBuffer, 'AR_TOTAL');

        BuildAgingRows(MetricBuffer, ArAging, true);

        MetricBuffer.DeleteAll();
        Provider.GetAPSummary(AsOfDate, MetricBuffer);
        OpenApAmount := GetMetricAmount(MetricBuffer, 'AP_TOTAL');

        BuildAgingRows(MetricBuffer, ApAging, false);

        CashBalance := Provider.GetCurrentCashBalance();

        MetricBuffer.DeleteAll();
        Provider.GetMRRMetrics(FromDate, AsOfDate, MetricBuffer);
        MrrAmount := GetMetricAmount(MetricBuffer, 'MRR');

        MetricBuffer.DeleteAll();
        if Setup."Primary Dimension Code" <> '' then begin
            Provider.GetDimensionBreakdown(Setup."Primary Dimension Code", FromDate, AsOfDate, Setup."Revenue GL Account Filter", MetricBuffer);
            BuildDimensionRows(MetricBuffer, Dimensions);
        end;

        MetricBuffer.DeleteAll();
        Provider.GetJobMetrics(FromDate, AsOfDate, MetricBuffer);
        BuildJobArray(MetricBuffer, Jobs);

        MetricBuffer.DeleteAll();
        Provider.GetFixedAssetMetrics(AsOfDate, MetricBuffer);
        BuildFaArray(MetricBuffer, Fa);

        MetricBuffer.DeleteAll();
        Provider.GetPayrollMetrics(FromDate, AsOfDate, MetricBuffer);
        BuildAmountSeries(MetricBuffer, Payroll, 'PAYROLL_TOTAL', 'amount');

        MetricBuffer.DeleteAll();
        Provider.GetServiceMetrics(FromDate, AsOfDate, MetricBuffer);
        BuildServiceArray(MetricBuffer, Service, AsOfDate);

        MetricBuffer.DeleteAll();
        Provider.GetManufacturingMetrics(FromDate, AsOfDate, MetricBuffer);
        BuildMfgArrayFromMetric(MetricBuffer, Mfg, 'MFG_ENTRY_COUNT');

        MetricBuffer.DeleteAll();
        Provider.GetInventoryValuation(AsOfDate, MetricBuffer);
        BuildInventoryArray(MetricBuffer, Inventory);

        MetricBuffer.DeleteAll();
        Provider.GetPurchaseMetrics(FromDate, AsOfDate, MetricBuffer);
        BuildPurchasingArray(MetricBuffer, Purchasing);

        BuildMrrArray(MrrSeries, MrrAmount, AsOfDate);

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

        RevenueObj.Add('date', Format(CalcDate('<CM>', AsOfDate), 0, 9));
        RevenueObj.Add('revenue', RevenueAmount);
        RevenueObj.Add('cogs', CogsAmount);
        RevenueObj.Add('grossMargin', GrossMarginAmount);
        Revenue.Add(RevenueObj);

        Payload.Add('kpis', Kpis);
        Payload.Add('revenue', Revenue);
        Payload.Add('arAging', ArAging);
        Payload.Add('apAging', ApAging);
        Payload.Add('dimensions', Dimensions);
        Payload.Add('jobs', Jobs);
        Payload.Add('fa', Fa);
        Payload.Add('payroll', Payroll);
        Payload.Add('service', Service);
        Payload.Add('mfg', Mfg);
        Payload.Add('inventory', Inventory);
        Payload.Add('purchasing', Purchasing);
        Payload.Add('mrr', MrrSeries);
        Payload.Add('cashFlow', CashFlow);
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

    local procedure BuildDimensionRows(var MetricBuffer: Record "CLR BI Metric Buffer" temporary; var DimensionArray: JsonArray)
    var
        DimensionObj: JsonObject;
    begin
        MetricBuffer.Reset();
        MetricBuffer.SetRange("Metric Code", 'DIMENSION_REVENUE');
        if MetricBuffer.FindSet() then
            repeat
                DimensionObj.Add('label', MetricBuffer."Group Code");
                DimensionObj.Add('revenue', MetricBuffer.Amount);
                DimensionObj.Add('cost', 0);
                DimensionArray.Add(DimensionObj);
                Clear(DimensionObj);
            until MetricBuffer.Next() = 0;
    end;

    local procedure BuildAmountSeries(var MetricBuffer: Record "CLR BI Metric Buffer" temporary; var SeriesArray: JsonArray; MetricCode: Code[50]; AmountFieldName: Text)
    var
        SeriesObj: JsonObject;
        AmountValue: Decimal;
    begin
        AmountValue := GetMetricAmount(MetricBuffer, MetricCode);
        if AmountValue = 0 then
            exit;

        SeriesObj.Add('date', Format(CalcDate('<CM>', Today()), 0, 9));
        SeriesObj.Add(AmountFieldName, AmountValue);
        SeriesArray.Add(SeriesObj);
    end;

    local procedure BuildJobArray(var MetricBuffer: Record "CLR BI Metric Buffer" temporary; var JobsArray: JsonArray)
    var
        JobObj: JsonObject;
        MetricValue: Decimal;
    begin
        MetricValue := GetMetricAmount(MetricBuffer, 'JOB_ENTRY_COUNT');
        if MetricValue = 0 then
            exit;

        JobObj.Add('jobNo', 'JOBS');
        JobObj.Add('jobName', 'Job Entries');
        JobObj.Add('revenue', MetricValue);
        JobObj.Add('cost', 0);
        JobObj.Add('margin', MetricValue);
        JobsArray.Add(JobObj);
    end;

    local procedure BuildFaArray(var MetricBuffer: Record "CLR BI Metric Buffer" temporary; var FaArray: JsonArray)
    var
        FaObj: JsonObject;
        MetricValue: Decimal;
    begin
        MetricValue := GetMetricAmount(MetricBuffer, 'FA_ENTRY_COUNT');
        if MetricValue = 0 then
            exit;

        FaObj.Add('class', 'Fixed Assets');
        FaObj.Add('cost', MetricValue);
        FaObj.Add('depreciation', 0);
        FaObj.Add('nbv', MetricValue);
        FaArray.Add(FaObj);
    end;

    local procedure BuildServiceArray(var MetricBuffer: Record "CLR BI Metric Buffer" temporary; var ServiceArray: JsonArray; AsOfDate: Date)
    var
        ServiceObj: JsonObject;
        MetricValue: Decimal;
    begin
        MetricValue := GetMetricAmount(MetricBuffer, 'SERVICE_ENTRY_COUNT');
        if MetricValue = 0 then
            exit;

        ServiceObj.Add('date', Format(CalcDate('<CM>', AsOfDate), 0, 9));
        ServiceObj.Add('revenue', MetricValue);
        ServiceObj.Add('cost', 0);
        ServiceObj.Add('margin', MetricValue);
        ServiceArray.Add(ServiceObj);
    end;

    local procedure BuildMfgArrayFromMetric(var MetricBuffer: Record "CLR BI Metric Buffer" temporary; var MfgArray: JsonArray; MetricCode: Code[50])
    var
        MfgObj: JsonObject;
        MetricValue: Decimal;
    begin
        MetricValue := GetMetricAmount(MetricBuffer, MetricCode);
        if MetricValue = 0 then
            exit;

        MfgObj.Add('date', Format(CalcDate('<CM>', Today()), 0, 9));
        MfgObj.Add('materialCost', 0);
        MfgObj.Add('capacityCost', 0);
        MfgObj.Add('outputValue', MetricValue);
        MfgObj.Add('variance', 0);
        MfgArray.Add(MfgObj);
    end;

    local procedure BuildInventoryArray(var MetricBuffer: Record "CLR BI Metric Buffer" temporary; var InventoryArray: JsonArray)
    var
        InventoryObj: JsonObject;
        InventoryValue: Decimal;
    begin
        InventoryValue := GetMetricAmount(MetricBuffer, 'INVENTORY_VALUATION');
        if InventoryValue = 0 then
            exit;

        InventoryObj.Add('category', 'Total Inventory');
        InventoryObj.Add('value', InventoryValue);
        InventoryArray.Add(InventoryObj);
    end;

    local procedure BuildPurchasingArray(var MetricBuffer: Record "CLR BI Metric Buffer" temporary; var PurchasingArray: JsonArray)
    var
        PurchasingObj: JsonObject;
        EntryCount: Decimal;
    begin
        EntryCount := GetMetricAmount(MetricBuffer, 'PURCHASE_ENTRY_COUNT');
        if EntryCount = 0 then
            exit;

        PurchasingObj.Add('date', Format(CalcDate('<CM>', Today()), 0, 9));
        PurchasingObj.Add('spend', EntryCount);
        PurchasingObj.Add('vendorCount', EntryCount);
        PurchasingArray.Add(PurchasingObj);
    end;

    local procedure BuildMrrArray(var MrrArray: JsonArray; MrrAmount: Decimal; AsOfDate: Date)
    var
        MrrObj: JsonObject;
    begin
        if MrrAmount = 0 then
            exit;

        MrrObj.Add('date', Format(CalcDate('<CM>', AsOfDate), 0, 9));
        MrrObj.Add('amount', MrrAmount);
        MrrArray.Add(MrrObj);
    end;
}
