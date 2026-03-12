codeunit 50300 "CLR BC Native Provider" implements "CLR IDataProvider"
{
    procedure GetGLMetrics(FromDate: Date; ToDate: Date; GLAccountFilter: Text; var Buffer: Record "CLR BI Metric Buffer" temporary)
    var
        Setup: Record "CLR Data Provider Setup";
        RevenueRaw: Decimal;
        CogsRaw: Decimal;
        PayrollRaw: Decimal;
        FilteredRaw: Decimal;
        RevenueAmount: Decimal;
        CogsAmount: Decimal;
        PayrollAmount: Decimal;
        GrossMarginAmount: Decimal;
    begin
        if EnsureSetup(Setup) then begin
            RevenueRaw := SumGLEntryAmount(FromDate, ToDate, Setup."Revenue GL Account Filter");
            CogsRaw := SumGLEntryAmount(FromDate, ToDate, Setup."COGS GL Account Filter");
            PayrollRaw := SumGLEntryAmount(FromDate, ToDate, Setup."Payroll GL Account Filter");
        end;

        if GLAccountFilter <> '' then begin
            FilteredRaw := SumGLEntryAmount(FromDate, ToDate, GLAccountFilter);
            InsertMetric(Buffer, 'FILTER_TOTAL', FromDate, ToDate, FilteredRaw, 'Filtered G/L amount', '', Enum::"CLR Metric Type"::Amount);
        end;

        RevenueAmount := NormalizeRevenue(RevenueRaw);
        CogsAmount := Abs(CogsRaw);
        PayrollAmount := Abs(PayrollRaw);
        GrossMarginAmount := RevenueAmount - CogsAmount;

        InsertMetric(Buffer, 'REVENUE', FromDate, ToDate, RevenueAmount, 'Revenue', '', Enum::"CLR Metric Type"::Amount);
        InsertMetric(Buffer, 'COGS', FromDate, ToDate, CogsAmount, 'COGS', '', Enum::"CLR Metric Type"::Amount);
        InsertMetric(Buffer, 'GROSS_MARGIN', FromDate, ToDate, GrossMarginAmount, 'Gross Margin', '', Enum::"CLR Metric Type"::Amount);
        InsertMetric(Buffer, 'PAYROLL', FromDate, ToDate, PayrollAmount, 'Payroll', '', Enum::"CLR Metric Type"::Amount);
    end;

    procedure GetARSummary(AsOfDate: Date; var Buffer: Record "CLR BI Metric Buffer" temporary)
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        RemainingLcy: Decimal;
        CurrentAmt: Decimal;
        Bucket1To30: Decimal;
        Bucket31To60: Decimal;
        Bucket61To90: Decimal;
        Bucket90Plus: Decimal;
        TotalAmt: Decimal;
        DaysOverdue: Integer;
    begin
        CustLedgerEntry.Reset();
        CustLedgerEntry.SetRange(Open, true);
        CustLedgerEntry.SetRange("Posting Date", 0D, AsOfDate);

        if CustLedgerEntry.FindSet() then
            repeat
                CustLedgerEntry.CalcFields("Remaining Amt. (LCY)");
                RemainingLcy := CustLedgerEntry."Remaining Amt. (LCY)";
                if RemainingLcy = 0 then
                    RemainingLcy := CustLedgerEntry."Remaining Amount";
                RemainingLcy := Abs(RemainingLcy);

                if RemainingLcy = 0 then
                    continue;

                TotalAmt += RemainingLcy;

                if (CustLedgerEntry."Due Date" = 0D) or (CustLedgerEntry."Due Date" >= AsOfDate) then begin
                    CurrentAmt += RemainingLcy;
                    continue;
                end;

                DaysOverdue := AsOfDate - CustLedgerEntry."Due Date";
                if DaysOverdue <= 30 then
                    Bucket1To30 += RemainingLcy
                else
                    if DaysOverdue <= 60 then
                        Bucket31To60 += RemainingLcy
                    else
                        if DaysOverdue <= 90 then
                            Bucket61To90 += RemainingLcy
                        else
                            Bucket90Plus += RemainingLcy;
            until CustLedgerEntry.Next() = 0;

        InsertMetric(Buffer, 'AR_TOTAL', AsOfDate, AsOfDate, TotalAmt, 'Open AR', '', Enum::"CLR Metric Type"::Amount);
        InsertMetric(Buffer, 'AR_CURRENT', AsOfDate, AsOfDate, CurrentAmt, 'AR Current', 'Current', Enum::"CLR Metric Type"::Amount);
        InsertMetric(Buffer, 'AR_1_30', AsOfDate, AsOfDate, Bucket1To30, 'AR 1-30', '1-30 days', Enum::"CLR Metric Type"::Amount);
        InsertMetric(Buffer, 'AR_31_60', AsOfDate, AsOfDate, Bucket31To60, 'AR 31-60', '31-60 days', Enum::"CLR Metric Type"::Amount);
        InsertMetric(Buffer, 'AR_61_90', AsOfDate, AsOfDate, Bucket61To90, 'AR 61-90', '61-90 days', Enum::"CLR Metric Type"::Amount);
        InsertMetric(Buffer, 'AR_90_PLUS', AsOfDate, AsOfDate, Bucket90Plus, 'AR 90+', '90+ days', Enum::"CLR Metric Type"::Amount);
    end;

    procedure GetAPSummary(AsOfDate: Date; var Buffer: Record "CLR BI Metric Buffer" temporary)
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        RemainingLcy: Decimal;
        CurrentAmt: Decimal;
        Bucket1To30: Decimal;
        Bucket31To60: Decimal;
        Bucket61To90: Decimal;
        Bucket90Plus: Decimal;
        TotalAmt: Decimal;
        DaysOverdue: Integer;
    begin
        VendorLedgerEntry.Reset();
        VendorLedgerEntry.SetRange(Open, true);
        VendorLedgerEntry.SetRange("Posting Date", 0D, AsOfDate);

        if VendorLedgerEntry.FindSet() then
            repeat
                VendorLedgerEntry.CalcFields("Remaining Amt. (LCY)");
                RemainingLcy := VendorLedgerEntry."Remaining Amt. (LCY)";
                if RemainingLcy = 0 then
                    RemainingLcy := VendorLedgerEntry."Remaining Amount";
                RemainingLcy := Abs(RemainingLcy);

                if RemainingLcy = 0 then
                    continue;

                TotalAmt += RemainingLcy;

                if (VendorLedgerEntry."Due Date" = 0D) or (VendorLedgerEntry."Due Date" >= AsOfDate) then begin
                    CurrentAmt += RemainingLcy;
                    continue;
                end;

                DaysOverdue := AsOfDate - VendorLedgerEntry."Due Date";
                if DaysOverdue <= 30 then
                    Bucket1To30 += RemainingLcy
                else
                    if DaysOverdue <= 60 then
                        Bucket31To60 += RemainingLcy
                    else
                        if DaysOverdue <= 90 then
                            Bucket61To90 += RemainingLcy
                        else
                            Bucket90Plus += RemainingLcy;
            until VendorLedgerEntry.Next() = 0;

        InsertMetric(Buffer, 'AP_TOTAL', AsOfDate, AsOfDate, TotalAmt, 'Open AP', '', Enum::"CLR Metric Type"::Amount);
        InsertMetric(Buffer, 'AP_CURRENT', AsOfDate, AsOfDate, CurrentAmt, 'AP Current', 'Current', Enum::"CLR Metric Type"::Amount);
        InsertMetric(Buffer, 'AP_1_30', AsOfDate, AsOfDate, Bucket1To30, 'AP 1-30', '1-30 days', Enum::"CLR Metric Type"::Amount);
        InsertMetric(Buffer, 'AP_31_60', AsOfDate, AsOfDate, Bucket31To60, 'AP 31-60', '31-60 days', Enum::"CLR Metric Type"::Amount);
        InsertMetric(Buffer, 'AP_61_90', AsOfDate, AsOfDate, Bucket61To90, 'AP 61-90', '61-90 days', Enum::"CLR Metric Type"::Amount);
        InsertMetric(Buffer, 'AP_90_PLUS', AsOfDate, AsOfDate, Bucket90Plus, 'AP 90+', '90+ days', Enum::"CLR Metric Type"::Amount);
    end;

    procedure GetCurrentCashBalance(): Decimal
    var
        BankLedgerEntry: Record "Bank Account Ledger Entry";
    begin
        BankLedgerEntry.Reset();
        BankLedgerEntry.SetRange("Posting Date", 0D, Today());
        BankLedgerEntry.CalcSums(Amount);
        exit(BankLedgerEntry.Amount);
    end;

    procedure GetDimensionBreakdown(DimensionCode: Code[20]; FromDate: Date; ToDate: Date; GLAccountFilter: Text; var Buffer: Record "CLR BI Metric Buffer" temporary)
    var
        GLEntry: Record "G/L Entry";
        DimSetEntry: Record "Dimension Set Entry";
        DimValueCode: Code[20];
    begin
        GLEntry.Reset();
        GLEntry.SetRange("Posting Date", FromDate, ToDate);
        if GLAccountFilter <> '' then
            GLEntry.SetFilter("G/L Account No.", GLAccountFilter);

        if GLEntry.FindSet() then
            repeat
                DimSetEntry.Reset();
                DimSetEntry.SetRange("Dimension Set ID", GLEntry."Dimension Set ID");
                DimSetEntry.SetRange("Dimension Code", DimensionCode);
                if DimSetEntry.FindFirst() then begin
                    DimValueCode := CopyStr(DimSetEntry."Dimension Value Code", 1, 20);
                    UpsertMetric(Buffer, 'DIMENSION_REVENUE', FromDate, ToDate, GLEntry.Amount, 'Dimension Revenue', DimValueCode, Enum::"CLR Metric Type"::Amount);
                end;
            until GLEntry.Next() = 0;
    end;

    procedure GetInventoryValuation(AsOfDate: Date; var Buffer: Record "CLR BI Metric Buffer" temporary)
    var
        ValueEntry: Record "Value Entry";
        InventoryValue: Decimal;
    begin
        ValueEntry.Reset();
        ValueEntry.SetRange("Posting Date", 0D, AsOfDate);
        ValueEntry.CalcSums("Cost Amount (Actual)");
        InventoryValue := Abs(ValueEntry."Cost Amount (Actual)");
        InsertMetric(Buffer, 'INVENTORY_VALUATION', AsOfDate, AsOfDate, InventoryValue, 'Inventory Valuation', '', Enum::"CLR Metric Type"::Amount);
    end;

    procedure GetJobMetrics(FromDate: Date; ToDate: Date; var Buffer: Record "CLR BI Metric Buffer" temporary)
    var
        JobLedgerEntry: Record "Job Ledger Entry";
        JobEntryCount: Integer;
        JobRevenue: Decimal;
        JobCost: Decimal;
    begin
        JobLedgerEntry.Reset();
        JobLedgerEntry.SetRange("Posting Date", FromDate, ToDate);
        JobEntryCount := JobLedgerEntry.Count();
        JobLedgerEntry.CalcSums("Line Amount (LCY)", "Total Cost (LCY)");
        JobRevenue := Abs(JobLedgerEntry."Line Amount (LCY)");
        JobCost := Abs(JobLedgerEntry."Total Cost (LCY)");

        InsertMetric(Buffer, 'JOB_REVENUE', FromDate, ToDate, JobRevenue, 'Job revenue', '', Enum::"CLR Metric Type"::Amount);
        InsertMetric(Buffer, 'JOB_COST', FromDate, ToDate, JobCost, 'Job cost', '', Enum::"CLR Metric Type"::Amount);
        InsertMetric(Buffer, 'JOB_ENTRY_COUNT', FromDate, ToDate, JobEntryCount, 'Job ledger entries', '', Enum::"CLR Metric Type"::Count);
    end;

    procedure GetFixedAssetMetrics(AsOfDate: Date; var Buffer: Record "CLR BI Metric Buffer" temporary)
    var
        FALedgerEntry: Record "FA Ledger Entry";
        FaEntryCount: Integer;
        FaNbv: Decimal;
    begin
        FALedgerEntry.Reset();
        FALedgerEntry.SetRange("Posting Date", 0D, AsOfDate);
        FaEntryCount := FALedgerEntry.Count();
        FALedgerEntry.CalcSums(Amount);
        FaNbv := Abs(FALedgerEntry.Amount);

        InsertMetric(Buffer, 'FA_NBV', AsOfDate, AsOfDate, FaNbv, 'Fixed asset net book value proxy', '', Enum::"CLR Metric Type"::Amount);
        InsertMetric(Buffer, 'FA_ENTRY_COUNT', AsOfDate, AsOfDate, FaEntryCount, 'FA ledger entries', '', Enum::"CLR Metric Type"::Count);
    end;

    procedure GetPayrollMetrics(FromDate: Date; ToDate: Date; var Buffer: Record "CLR BI Metric Buffer" temporary)
    var
        Setup: Record "CLR Data Provider Setup";
        PayrollAmount: Decimal;
    begin
        if EnsureSetup(Setup) then begin
            PayrollAmount := Abs(SumGLEntryAmount(FromDate, ToDate, Setup."Payroll GL Account Filter"));
            InsertMetric(Buffer, 'PAYROLL_TOTAL', FromDate, ToDate, PayrollAmount, 'Payroll amount', '', Enum::"CLR Metric Type"::Amount);
            exit;
        end;

        InsertMetric(Buffer, 'PAYROLL_TOTAL', FromDate, ToDate, 0, 'Payroll amount', '', Enum::"CLR Metric Type"::Amount);
    end;

    procedure GetServiceMetrics(FromDate: Date; ToDate: Date; var Buffer: Record "CLR BI Metric Buffer" temporary)
    var
        ServiceLedgerEntry: Record "Service Ledger Entry";
        ServiceEntryCount: Integer;
        ServiceRevenue: Decimal;
        ServiceCost: Decimal;
    begin
        ServiceLedgerEntry.Reset();
        ServiceLedgerEntry.SetRange("Posting Date", FromDate, ToDate);
        ServiceEntryCount := ServiceLedgerEntry.Count();
        ServiceLedgerEntry.CalcSums("Amount (LCY)", "Cost Amount");
        ServiceRevenue := Abs(ServiceLedgerEntry."Amount (LCY)");
        ServiceCost := Abs(ServiceLedgerEntry."Cost Amount");

        InsertMetric(Buffer, 'SERVICE_REVENUE', FromDate, ToDate, ServiceRevenue, 'Service revenue', '', Enum::"CLR Metric Type"::Amount);
        InsertMetric(Buffer, 'SERVICE_COST', FromDate, ToDate, ServiceCost, 'Service cost', '', Enum::"CLR Metric Type"::Amount);
        InsertMetric(Buffer, 'SERVICE_ENTRY_COUNT', FromDate, ToDate, ServiceEntryCount, 'Service ledger entries', '', Enum::"CLR Metric Type"::Count);
    end;

    procedure GetPurchaseMetrics(FromDate: Date; ToDate: Date; var Buffer: Record "CLR BI Metric Buffer" temporary)
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        PurchaseEntryCount: Integer;
        PurchaseSpend: Decimal;
    begin
        VendorLedgerEntry.Reset();
        VendorLedgerEntry.SetRange("Posting Date", FromDate, ToDate);
        PurchaseEntryCount := VendorLedgerEntry.Count();
        VendorLedgerEntry.CalcSums(Amount);
        PurchaseSpend := Abs(VendorLedgerEntry.Amount);

        InsertMetric(Buffer, 'PURCHASE_SPEND', FromDate, ToDate, PurchaseSpend, 'Purchasing spend', '', Enum::"CLR Metric Type"::Amount);
        InsertMetric(Buffer, 'PURCHASE_ENTRY_COUNT', FromDate, ToDate, PurchaseEntryCount, 'Purchasing entries', '', Enum::"CLR Metric Type"::Count);
    end;

    procedure GetManufacturingMetrics(FromDate: Date; ToDate: Date; var Buffer: Record "CLR BI Metric Buffer" temporary)
    var
        ValueEntry: Record "Value Entry";
        MfgEntryCount: Integer;
        MaterialCost: Decimal;
        OutputValue: Decimal;
    begin
        ValueEntry.Reset();
        ValueEntry.SetRange("Posting Date", FromDate, ToDate);
        MfgEntryCount := ValueEntry.Count();
        ValueEntry.CalcSums("Cost Amount (Actual)", "Sales Amount (Actual)");
        MaterialCost := Abs(ValueEntry."Cost Amount (Actual)");
        OutputValue := Abs(ValueEntry."Sales Amount (Actual)");

        InsertMetric(Buffer, 'MFG_MATERIAL_COST', FromDate, ToDate, MaterialCost, 'Manufacturing material cost', '', Enum::"CLR Metric Type"::Amount);
        InsertMetric(Buffer, 'MFG_OUTPUT_VALUE', FromDate, ToDate, OutputValue, 'Manufacturing output value', '', Enum::"CLR Metric Type"::Amount);
        InsertMetric(Buffer, 'MFG_ENTRY_COUNT', FromDate, ToDate, MfgEntryCount, 'Manufacturing/value entries', '', Enum::"CLR Metric Type"::Count);
    end;

    procedure HasSubscriptionData(): Boolean
    var
        Detector: Codeunit "CLR Module Detector";
    begin
        exit(Detector.IsRecur365Installed());
    end;

    procedure GetMRRMetrics(FromDate: Date; ToDate: Date; var Buffer: Record "CLR BI Metric Buffer" temporary)
    var
        Setup: Record "CLR Data Provider Setup";
        RevenueAmount: Decimal;
        MonthCount: Integer;
        MrrAmount: Decimal;
    begin
        if not EnsureSetup(Setup) then begin
            InsertMetric(Buffer, 'MRR', FromDate, ToDate, 0, 'Monthly Recurring Revenue', '', Enum::"CLR Metric Type"::Amount);
            InsertMetric(Buffer, 'MRR_TREND', FromDate, ToDate, 0, 'MRR Trend', '', Enum::"CLR Metric Type"::Percentage);
            exit;
        end;

        RevenueAmount := NormalizeRevenue(SumGLEntryAmount(FromDate, ToDate, Setup."Revenue GL Account Filter"));
        MonthCount := GetMonthCount(FromDate, ToDate);
        if MonthCount <= 0 then
            MonthCount := 1;

        MrrAmount := Round(RevenueAmount / MonthCount, 0.01);

        InsertMetric(Buffer, 'MRR', FromDate, ToDate, MrrAmount, 'Monthly Recurring Revenue', '', Enum::"CLR Metric Type"::Amount);
        InsertMetric(Buffer, 'MRR_TREND', FromDate, ToDate, 0, 'MRR Trend', '', Enum::"CLR Metric Type"::Percentage);
    end;

    local procedure EnsureSetup(var Setup: Record "CLR Data Provider Setup"): Boolean
    begin
        if Setup.Get('') then
            exit(true);

        exit(false);
    end;

    local procedure SumGLEntryAmount(FromDate: Date; ToDate: Date; AccountFilter: Text): Decimal
    var
        GLEntry: Record "G/L Entry";
    begin
        if AccountFilter = '' then
            exit(0);

        GLEntry.Reset();
        GLEntry.SetRange("Posting Date", FromDate, ToDate);
        GLEntry.SetFilter("G/L Account No.", AccountFilter);
        GLEntry.CalcSums(Amount);
        exit(GLEntry.Amount);
    end;

    local procedure NormalizeRevenue(RevenueRaw: Decimal): Decimal
    begin
        if RevenueRaw < 0 then
            exit(-RevenueRaw);

        exit(RevenueRaw);
    end;

    local procedure InsertMetric(var Buffer: Record "CLR BI Metric Buffer" temporary; MetricCode: Code[50]; PeriodFrom: Date; PeriodTo: Date; Amount: Decimal; MetricDescription: Text[100]; GroupCode: Code[20]; MetricType: Enum "CLR Metric Type")
    begin
        Buffer.Init();
        Buffer."Metric Code" := MetricCode;
        Buffer."Period From" := PeriodFrom;
        Buffer."Period To" := PeriodTo;
        Buffer.Amount := Amount;
        Buffer.Description := MetricDescription;
        Buffer."Group Code" := GroupCode;
        Buffer."Metric Type" := MetricType;
        Buffer.Insert();
    end;

    local procedure UpsertMetric(var Buffer: Record "CLR BI Metric Buffer" temporary; MetricCode: Code[50]; PeriodFrom: Date; PeriodTo: Date; Amount: Decimal; MetricDescription: Text[100]; GroupCode: Code[20]; MetricType: Enum "CLR Metric Type")
    begin
        Buffer.Reset();
        Buffer.SetRange("Metric Code", MetricCode);
        Buffer.SetRange("Period From", PeriodFrom);
        Buffer.SetRange("Group Code", GroupCode);
        if Buffer.FindFirst() then begin
            Buffer.Amount += Amount;
            Buffer.Modify();
            exit;
        end;

        InsertMetric(Buffer, MetricCode, PeriodFrom, PeriodTo, Amount, MetricDescription, GroupCode, MetricType);
    end;

    local procedure GetMonthCount(FromDate: Date; ToDate: Date): Integer
    var
        LoopDate: Date;
        Months: Integer;
    begin
        if (FromDate = 0D) or (ToDate = 0D) or (FromDate > ToDate) then
            exit(0);

        LoopDate := CalcDate('<CM>', FromDate);
        while LoopDate <= ToDate do begin
            Months += 1;
            LoopDate := CalcDate('<CM+1M>', LoopDate);
        end;

        exit(Months);
    end;
}
