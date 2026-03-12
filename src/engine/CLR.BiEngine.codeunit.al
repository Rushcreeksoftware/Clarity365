codeunit 50304 "CLR BI Engine"
{
    procedure BuildPayloadJson(): Text
    var
        ProviderFactory: Codeunit "CLR Provider Factory";
        Setup: Record "CLR Data Provider Setup";
        Provider: Interface "CLR IDataProvider";
        MetricBuffer: Record "CLR BI Metric Buffer" temporary;
        TempMetricBuffer: Record "CLR BI Metric Buffer" temporary;
        FromDate: Date;
        AsOfDate: Date;
        MonthStart: Date;
        MonthEnd: Date;
        PreviousMrrAmount: Decimal;
        MrrTrendPct: Decimal;
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
        Scenarios: JsonObject;
        HasBaseScenario: Boolean;
        HasUpsideScenario: Boolean;
        HasDownsideScenario: Boolean;
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
        BuildPayrollTrend(Provider, Setup, Payroll);

        MetricBuffer.DeleteAll();
        Provider.GetServiceMetrics(FromDate, AsOfDate, MetricBuffer);
        BuildServiceTrend(Provider, Service, AsOfDate);

        MetricBuffer.DeleteAll();
        Provider.GetManufacturingMetrics(FromDate, AsOfDate, MetricBuffer);
        BuildManufacturingTrend(Provider, Mfg, AsOfDate);

        MetricBuffer.DeleteAll();
        Provider.GetInventoryValuation(AsOfDate, MetricBuffer);
        BuildInventoryArray(MetricBuffer, Inventory);

        MetricBuffer.DeleteAll();
        Provider.GetPurchaseMetrics(FromDate, AsOfDate, MetricBuffer);
        BuildPurchasingTrend(Provider, Purchasing, AsOfDate);

        BuildMrrTrend(Provider, MrrSeries, AsOfDate);

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
        MonthStart := CalcDate('<CM-1M>', AsOfDate);
        MonthEnd := CalcDate('<CM-1D>', AsOfDate);
        TempMetricBuffer.DeleteAll();
        Provider.GetMRRMetrics(MonthStart, MonthEnd, TempMetricBuffer);
        PreviousMrrAmount := GetMetricAmount(TempMetricBuffer, 'MRR');
        MrrTrendPct := CalculateTrendPct(PreviousMrrAmount, MrrAmount);
        Kpis.Add('mrrTrend', MrrTrendPct);

        BuildRevenueTrend(Provider, Setup, Revenue);
        BuildCashFlowArray(CashFlow, AsOfDate);

        HasBaseScenario := ScenarioHasData('BASE');
        HasUpsideScenario := ScenarioHasData('UPSIDE');
        HasDownsideScenario := ScenarioHasData('DOWNSIDE');

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
        Scenarios.Add('base', HasBaseScenario);
        Scenarios.Add('upside', HasUpsideScenario);
        Scenarios.Add('downside', HasDownsideScenario);
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

    local procedure BuildJobArray(var MetricBuffer: Record "CLR BI Metric Buffer" temporary; var JobsArray: JsonArray)
    var
        JobObj: JsonObject;
        EntryCount: Decimal;
        RevenueValue: Decimal;
        CostValue: Decimal;
    begin
        EntryCount := GetMetricAmount(MetricBuffer, 'JOB_ENTRY_COUNT');
        RevenueValue := GetMetricAmount(MetricBuffer, 'JOB_REVENUE');
        CostValue := GetMetricAmount(MetricBuffer, 'JOB_COST');

        if (EntryCount = 0) and (RevenueValue = 0) and (CostValue = 0) then
            exit;

        if RevenueValue = 0 then
            RevenueValue := EntryCount;

        JobObj.Add('jobNo', 'JOBS');
        JobObj.Add('jobName', 'Jobs Summary');
        JobObj.Add('revenue', RevenueValue);
        JobObj.Add('cost', CostValue);
        JobObj.Add('margin', RevenueValue - CostValue);
        JobsArray.Add(JobObj);
    end;

    local procedure BuildFaArray(var MetricBuffer: Record "CLR BI Metric Buffer" temporary; var FaArray: JsonArray)
    var
        FaObj: JsonObject;
        EntryCount: Decimal;
        NbvValue: Decimal;
    begin
        EntryCount := GetMetricAmount(MetricBuffer, 'FA_ENTRY_COUNT');
        NbvValue := GetMetricAmount(MetricBuffer, 'FA_NBV');
        if (EntryCount = 0) and (NbvValue = 0) then
            exit;

        if NbvValue = 0 then
            NbvValue := EntryCount;

        FaObj.Add('class', 'Fixed Assets');
        FaObj.Add('cost', NbvValue);
        FaObj.Add('depreciation', 0);
        FaObj.Add('nbv', NbvValue);
        FaArray.Add(FaObj);
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

    local procedure BuildRevenueTrend(Provider: Interface "CLR IDataProvider"; Setup: Record "CLR Data Provider Setup"; var RevenueArray: JsonArray)
    var
        MonthOffset: Integer;
        PeriodStart: Date;
        PeriodEnd: Date;
        MetricBuffer: Record "CLR BI Metric Buffer" temporary;
        RevenueObj: JsonObject;
        RevenueValue: Decimal;
        CogsValue: Decimal;
        GrossMarginValue: Decimal;
    begin
        for MonthOffset := 5 downto 0 do begin
            PeriodStart := CalcDate(StrSubstNo('<CM-%1M>', MonthOffset), Today());
            PeriodEnd := CalcDate('<CM+1M-1D>', PeriodStart);

            MetricBuffer.DeleteAll();
            Provider.GetGLMetrics(PeriodStart, PeriodEnd, Setup."Revenue GL Account Filter", MetricBuffer);
            RevenueValue := GetMetricAmount(MetricBuffer, 'REVENUE');
            CogsValue := GetMetricAmount(MetricBuffer, 'COGS');
            GrossMarginValue := GetMetricAmount(MetricBuffer, 'GROSS_MARGIN');

            RevenueObj.Add('date', Format(PeriodStart, 0, 9));
            RevenueObj.Add('revenue', RevenueValue);
            RevenueObj.Add('cogs', CogsValue);
            RevenueObj.Add('grossMargin', GrossMarginValue);
            RevenueArray.Add(RevenueObj);
            Clear(RevenueObj);
        end;
    end;

    local procedure BuildPayrollTrend(Provider: Interface "CLR IDataProvider"; Setup: Record "CLR Data Provider Setup"; var PayrollArray: JsonArray)
    var
        MonthOffset: Integer;
        PeriodStart: Date;
        PeriodEnd: Date;
        MetricBuffer: Record "CLR BI Metric Buffer" temporary;
        PayrollObj: JsonObject;
        PayrollAmount: Decimal;
    begin
        for MonthOffset := 5 downto 0 do begin
            PeriodStart := CalcDate(StrSubstNo('<CM-%1M>', MonthOffset), Today());
            PeriodEnd := CalcDate('<CM+1M-1D>', PeriodStart);

            MetricBuffer.DeleteAll();
            Provider.GetPayrollMetrics(PeriodStart, PeriodEnd, MetricBuffer);
            PayrollAmount := GetMetricAmount(MetricBuffer, 'PAYROLL_TOTAL');

            PayrollObj.Add('date', Format(PeriodStart, 0, 9));
            PayrollObj.Add('amount', PayrollAmount);
            PayrollArray.Add(PayrollObj);
            Clear(PayrollObj);
        end;
    end;

    local procedure BuildServiceTrend(Provider: Interface "CLR IDataProvider"; var ServiceArray: JsonArray; AsOfDate: Date)
    var
        MonthOffset: Integer;
        PeriodStart: Date;
        PeriodEnd: Date;
        MetricBuffer: Record "CLR BI Metric Buffer" temporary;
        ServiceObj: JsonObject;
        RevenueValue: Decimal;
        CostValue: Decimal;
        EntryCount: Decimal;
    begin
        for MonthOffset := 5 downto 0 do begin
            PeriodStart := CalcDate(StrSubstNo('<CM-%1M>', MonthOffset), AsOfDate);
            PeriodEnd := CalcDate('<CM+1M-1D>', PeriodStart);

            MetricBuffer.DeleteAll();
            Provider.GetServiceMetrics(PeriodStart, PeriodEnd, MetricBuffer);
            RevenueValue := GetMetricAmount(MetricBuffer, 'SERVICE_REVENUE');
            CostValue := GetMetricAmount(MetricBuffer, 'SERVICE_COST');
            EntryCount := GetMetricAmount(MetricBuffer, 'SERVICE_ENTRY_COUNT');
            if (RevenueValue = 0) and (CostValue = 0) and (EntryCount = 0) then
                continue;

            if RevenueValue = 0 then
                RevenueValue := EntryCount;

            ServiceObj.Add('date', Format(PeriodStart, 0, 9));
            ServiceObj.Add('revenue', RevenueValue);
            ServiceObj.Add('cost', CostValue);
            ServiceObj.Add('margin', RevenueValue - CostValue);
            ServiceArray.Add(ServiceObj);
            Clear(ServiceObj);
        end;
    end;

    local procedure BuildManufacturingTrend(Provider: Interface "CLR IDataProvider"; var MfgArray: JsonArray; AsOfDate: Date)
    var
        MonthOffset: Integer;
        PeriodStart: Date;
        PeriodEnd: Date;
        MetricBuffer: Record "CLR BI Metric Buffer" temporary;
        MfgObj: JsonObject;
        OutputValue: Decimal;
        MaterialCost: Decimal;
        EntryCount: Decimal;
    begin
        for MonthOffset := 5 downto 0 do begin
            PeriodStart := CalcDate(StrSubstNo('<CM-%1M>', MonthOffset), AsOfDate);
            PeriodEnd := CalcDate('<CM+1M-1D>', PeriodStart);

            MetricBuffer.DeleteAll();
            Provider.GetManufacturingMetrics(PeriodStart, PeriodEnd, MetricBuffer);
            OutputValue := GetMetricAmount(MetricBuffer, 'MFG_OUTPUT_VALUE');
            MaterialCost := GetMetricAmount(MetricBuffer, 'MFG_MATERIAL_COST');
            EntryCount := GetMetricAmount(MetricBuffer, 'MFG_ENTRY_COUNT');
            if (OutputValue = 0) and (MaterialCost = 0) and (EntryCount = 0) then
                continue;

            if OutputValue = 0 then
                OutputValue := EntryCount;

            MfgObj.Add('date', Format(PeriodStart, 0, 9));
            MfgObj.Add('materialCost', MaterialCost);
            MfgObj.Add('capacityCost', 0);
            MfgObj.Add('outputValue', OutputValue);
            MfgObj.Add('variance', OutputValue - MaterialCost);
            MfgArray.Add(MfgObj);
            Clear(MfgObj);
        end;
    end;

    local procedure BuildPurchasingTrend(Provider: Interface "CLR IDataProvider"; var PurchasingArray: JsonArray; AsOfDate: Date)
    var
        MonthOffset: Integer;
        PeriodStart: Date;
        PeriodEnd: Date;
        MetricBuffer: Record "CLR BI Metric Buffer" temporary;
        PurchasingObj: JsonObject;
        SpendAmount: Decimal;
        EntryCount: Decimal;
    begin
        for MonthOffset := 5 downto 0 do begin
            PeriodStart := CalcDate(StrSubstNo('<CM-%1M>', MonthOffset), AsOfDate);
            PeriodEnd := CalcDate('<CM+1M-1D>', PeriodStart);

            MetricBuffer.DeleteAll();
            Provider.GetPurchaseMetrics(PeriodStart, PeriodEnd, MetricBuffer);
            SpendAmount := GetMetricAmount(MetricBuffer, 'PURCHASE_SPEND');
            EntryCount := GetMetricAmount(MetricBuffer, 'PURCHASE_ENTRY_COUNT');
            if (SpendAmount = 0) and (EntryCount = 0) then
                continue;

            PurchasingObj.Add('date', Format(PeriodStart, 0, 9));
            PurchasingObj.Add('spend', SpendAmount);
            PurchasingObj.Add('vendorCount', EntryCount);
            PurchasingArray.Add(PurchasingObj);
            Clear(PurchasingObj);
        end;
    end;

    local procedure BuildMrrTrend(Provider: Interface "CLR IDataProvider"; var MrrArray: JsonArray; AsOfDate: Date)
    var
        MonthOffset: Integer;
        PeriodStart: Date;
        PeriodEnd: Date;
        MetricBuffer: Record "CLR BI Metric Buffer" temporary;
        MrrObj: JsonObject;
        MrrValue: Decimal;
    begin
        for MonthOffset := 5 downto 0 do begin
            PeriodStart := CalcDate(StrSubstNo('<CM-%1M>', MonthOffset), AsOfDate);
            PeriodEnd := CalcDate('<CM+1M-1D>', PeriodStart);

            MetricBuffer.DeleteAll();
            Provider.GetMRRMetrics(PeriodStart, PeriodEnd, MetricBuffer);
            MrrValue := GetMetricAmount(MetricBuffer, 'MRR');

            MrrObj.Add('date', Format(PeriodStart, 0, 9));
            MrrObj.Add('amount', MrrValue);
            MrrArray.Add(MrrObj);
            Clear(MrrObj);
        end;
    end;

    local procedure BuildCashFlowArray(var CashFlowArray: JsonArray; AsOfDate: Date)
    var
        MonthOffset: Integer;
        MonthStart: Date;
        MonthEnd: Date;
        CashFlowObj: JsonObject;
        Inflows: Decimal;
        Outflows: Decimal;
        BaseCumulative: Decimal;
        UpsideCumulative: Decimal;
        DownsideCumulative: Decimal;
    begin
        for MonthOffset := 0 to 5 do begin
            MonthStart := CalcDate(StrSubstNo('<CM+%1M>', MonthOffset), AsOfDate);
            MonthEnd := CalcDate('<CM+1M-1D>', MonthStart);

            SumScenarioFlows('BASE', MonthStart, MonthEnd, Inflows, Outflows);
            BaseCumulative := GetScenarioCumulativeAtDate('BASE', MonthEnd);
            UpsideCumulative := GetScenarioCumulativeAtDate('UPSIDE', MonthEnd);
            DownsideCumulative := GetScenarioCumulativeAtDate('DOWNSIDE', MonthEnd);

            CashFlowObj.Add('date', Format(MonthStart, 0, 9));
            CashFlowObj.Add('inflows', Inflows);
            CashFlowObj.Add('outflows', Outflows);
            CashFlowObj.Add('base', BaseCumulative);
            CashFlowObj.Add('upside', UpsideCumulative);
            CashFlowObj.Add('downside', DownsideCumulative);
            CashFlowArray.Add(CashFlowObj);
            Clear(CashFlowObj);
        end;
    end;

    local procedure CalculateTrendPct(PreviousValue: Decimal; CurrentValue: Decimal): Decimal
    begin
        if PreviousValue = 0 then
            exit(0);

        exit(Round(((CurrentValue - PreviousValue) / PreviousValue) * 100, 0.01));
    end;

    local procedure SumScenarioFlows(ScenarioCode: Code[20]; FromDate: Date; ToDate: Date; var Inflows: Decimal; var Outflows: Decimal)
    var
        ProjectionLine: Record "CLR CF Projection Line";
    begin
        Inflows := 0;
        Outflows := 0;

        ProjectionLine.SetRange("Scenario Code", ScenarioCode);
        ProjectionLine.SetRange("Projection Date", FromDate, ToDate);
        if ProjectionLine.FindSet() then
            repeat
                if IsOutflowCategory(ProjectionLine.Category) then
                    Outflows += ProjectionLine.Amount
                else
                    Inflows += ProjectionLine.Amount;
            until ProjectionLine.Next() = 0;
    end;

    local procedure GetScenarioCumulativeAtDate(ScenarioCode: Code[20]; AtDate: Date): Decimal
    var
        ProjectionLine: Record "CLR CF Projection Line";
    begin
        ProjectionLine.SetRange("Scenario Code", ScenarioCode);
        ProjectionLine.SetRange("Projection Date", 0D, AtDate);
        if ProjectionLine.FindLast() then
            exit(ProjectionLine."Cumulative Cash");

        exit(0);
    end;

    local procedure IsOutflowCategory(LineCategory: Enum "CLR CF Line Category"): Boolean
    begin
        case LineCategory of
            LineCategory::APPayment,
            LineCategory::Payroll,
            LineCategory::CapEx,
            LineCategory::OneOffPayment,
            LineCategory::TaxPayment:
                exit(true);
        end;

        exit(false);
    end;

    local procedure ScenarioHasData(ScenarioCode: Code[20]): Boolean
    var
        ProjectionLine: Record "CLR CF Projection Line";
    begin
        ProjectionLine.SetRange("Scenario Code", ScenarioCode);
        exit(not ProjectionLine.IsEmpty());
    end;
}
