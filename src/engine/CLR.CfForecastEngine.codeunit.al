codeunit 50305 "CLR Cf Forecast Engine"
{
    procedure BuildScenario(ScenarioCode: Code[20])
    var
        Setup: Record "CLR Data Provider Setup";
        ProviderFactory: Codeunit "CLR Provider Factory";
        Provider: Interface "CLR IDataProvider";
        MetricBuffer: Record "CLR BI Metric Buffer" temporary;
        ManualEntry: Record "CLR Manual CF Entry";
        Assumption: Record "CLR CF Scenario Assumption";
        ProjectionLine: Record "CLR CF Projection Line";
        Scenario: Record "CLR CF Scenario Header";
        MonthDate: Date;
        MonthEndDate: Date;
        CumulativeCash: Decimal;
        OpeningCash: Decimal;
        InvoiceRevenueBase: Decimal;
        InvoiceRevenue: Decimal;
        SubscriptionRevenue: Decimal;
        ArCollection: Decimal;
        ApPayment: Decimal;
        PayrollAmount: Decimal;
        GrowthRatePct: Decimal;
        ChurnRatePct: Decimal;
        ArWriteOffRatePct: Decimal;
        CollectionDays: Integer;
        PaymentDays: Integer;
        PayrollAdditionAmount: Decimal;
        HiringCount: Decimal;
        AverageSalary: Decimal;
        CurrentPayrollAmount: Decimal;
        ForecastMonths: Integer;
        ApOpenAmount: Decimal;
        HasSubscriptionData: Boolean;
    begin
        if not Scenario.Get(ScenarioCode) then
            exit;

        if not Setup.Get('') then begin
            Setup.Init();
            Setup."CF Forecast Months" := 12;
            Setup."Default AR Collection Days" := 30;
            Setup."Default AP Payment Days" := 30;
        end;

        Provider := ProviderFactory.GetProvider();
        HasSubscriptionData := Provider.HasSubscriptionData();

        ProjectionLine.SetRange("Scenario Code", ScenarioCode);
        ProjectionLine.SetRange("Is Actual", false);
        if not ProjectionLine.IsEmpty() then
            ProjectionLine.DeleteAll();

        OpeningCash := Provider.GetCurrentCashBalance();
        CumulativeCash := OpeningCash;

        InsertProjectionLine(ScenarioCode, Scenario."Forecast Start", Enum::"CLR CF Line Category"::OpeningBalance, OpeningCash, CumulativeCash, true, 'Opening cash balance');

        MetricBuffer.DeleteAll();
        Provider.GetGLMetrics(CalcDate('<CM>', Today()), Today(), Setup."Revenue GL Account Filter", MetricBuffer);
        InvoiceRevenueBase := GetMetricAmount(MetricBuffer, 'REVENUE');
        if InvoiceRevenueBase = 0 then
            InvoiceRevenueBase := 10000;

        MetricBuffer.DeleteAll();
        Provider.GetGLMetrics(CalcDate('<CM>', Today()), Today(), Setup."Payroll GL Account Filter", MetricBuffer);
        PayrollAmount := GetMetricAmount(MetricBuffer, 'FILTER_TOTAL');
        PayrollAmount := Abs(PayrollAmount);

        MetricBuffer.DeleteAll();
        Provider.GetAPSummary(Today(), MetricBuffer);
        ApOpenAmount := GetMetricAmount(MetricBuffer, 'AP_TOTAL');

        ForecastMonths := GetForecastMonths(Scenario."Forecast Start", Scenario."Forecast End");
        if ForecastMonths = 0 then
            ForecastMonths := 1;

        MonthDate := CalcDate('<CM>', Scenario."Forecast Start");
        while MonthDate <= Scenario."Forecast End" do begin
            MonthEndDate := CalcDate('<CM+1M-1D>', MonthDate);

            GrowthRatePct := GetAssumptionValue(ScenarioCode, Enum::"CLR CF Category"::RevenueGrowthRate, MonthDate, MonthEndDate);
            ChurnRatePct := GetAssumptionValue(ScenarioCode, Enum::"CLR CF Category"::ChurnRate, MonthDate, MonthEndDate);
            ArWriteOffRatePct := GetAssumptionValue(ScenarioCode, Enum::"CLR CF Category"::ARWriteOffRate, MonthDate, MonthEndDate);
            CollectionDays := Round(GetAssumptionValue(ScenarioCode, Enum::"CLR CF Category"::CollectionDays, MonthDate, MonthEndDate), 1, '=');
            PaymentDays := Round(GetAssumptionValue(ScenarioCode, Enum::"CLR CF Category"::PaymentDays, MonthDate, MonthEndDate), 1, '=');
            PayrollAdditionAmount := GetAssumptionValue(ScenarioCode, Enum::"CLR CF Category"::PayrollAddition, MonthDate, MonthEndDate);
            HiringCount := GetAssumptionValue(ScenarioCode, Enum::"CLR CF Category"::HiringCount, MonthDate, MonthEndDate);
            AverageSalary := GetAssumptionValue(ScenarioCode, Enum::"CLR CF Category"::AverageSalary, MonthDate, MonthEndDate);

            if CollectionDays = 0 then
                CollectionDays := Setup."Default AR Collection Days";
            if PaymentDays = 0 then
                PaymentDays := Setup."Default AP Payment Days";

            InvoiceRevenue := ApplyGrowthAndChurn(InvoiceRevenueBase, GrowthRatePct, ChurnRatePct);
            SubscriptionRevenue := 0;
            if HasSubscriptionData then begin
                MetricBuffer.DeleteAll();
                Provider.GetMRRMetrics(MonthDate, MonthEndDate, MetricBuffer);
                SubscriptionRevenue := ApplyGrowthAndChurn(GetMetricAmount(MetricBuffer, 'MRR'), GrowthRatePct, ChurnRatePct);
            end;

            ArCollection := ApplyCollectionFactor(InvoiceRevenue, CollectionDays);
            if ArWriteOffRatePct <> 0 then
                ArCollection := Round(ArCollection * (1 - (ArWriteOffRatePct / 100)), 0.01);
            ApPayment := ApplyPaymentFactor(ApOpenAmount / ForecastMonths, PaymentDays);
            CurrentPayrollAmount := PayrollAmount + PayrollAdditionAmount + (HiringCount * AverageSalary);

            InsertProjectionLine(ScenarioCode, MonthDate, Enum::"CLR CF Line Category"::SubscriptionRevenue, SubscriptionRevenue, CumulativeCash, true, 'Projected subscription revenue');
            InsertProjectionLine(ScenarioCode, MonthDate, Enum::"CLR CF Line Category"::InvoiceRevenue, InvoiceRevenue, CumulativeCash, true, 'Projected invoice revenue');
            InsertProjectionLine(ScenarioCode, MonthDate, Enum::"CLR CF Line Category"::ARCollection, ArCollection, CumulativeCash, true, 'Projected AR collection');
            InsertProjectionLine(ScenarioCode, MonthDate, Enum::"CLR CF Line Category"::APPayment, ApPayment, CumulativeCash, false, 'Projected AP payment');
            InsertProjectionLine(ScenarioCode, MonthDate, Enum::"CLR CF Line Category"::Payroll, CurrentPayrollAmount, CumulativeCash, false, 'Projected payroll');

            ApplyOneOffScenarioAssumptions(ScenarioCode, MonthDate, MonthEndDate, CumulativeCash);

            ManualEntry.Reset();
            ManualEntry.SetRange("Scenario Code", ScenarioCode);
            ManualEntry.SetRange("Posting Date", MonthDate, MonthEndDate);
            if ManualEntry.FindSet() then
                repeat
                    if ManualEntry."Is Receipt" then begin
                        InsertProjectionLine(ScenarioCode, ManualEntry."Posting Date", Enum::"CLR CF Line Category"::OneOffReceipt, ManualEntry.Amount, CumulativeCash, true, ManualEntry.Description);
                        continue;
                    end;

                    InsertProjectionLine(ScenarioCode, ManualEntry."Posting Date", Enum::"CLR CF Line Category"::OneOffPayment, Abs(ManualEntry.Amount), CumulativeCash, false, ManualEntry.Description);
                until ManualEntry.Next() = 0;

            ManualEntry.Reset();
            ManualEntry.SetRange("Scenario Code", '');
            ManualEntry.SetRange("Posting Date", MonthDate, MonthEndDate);
            if ManualEntry.FindSet() then
                repeat
                    if ManualEntry."Is Receipt" then begin
                        InsertProjectionLine(ScenarioCode, ManualEntry."Posting Date", Enum::"CLR CF Line Category"::OneOffReceipt, ManualEntry.Amount, CumulativeCash, true, ManualEntry.Description);
                        continue;
                    end;

                    InsertProjectionLine(ScenarioCode, ManualEntry."Posting Date", Enum::"CLR CF Line Category"::OneOffPayment, Abs(ManualEntry.Amount), CumulativeCash, false, ManualEntry.Description);
                until ManualEntry.Next() = 0;

            MonthDate := CalcDate('<CM+1M>', MonthDate);
        end;

        Scenario."Last Built" := CurrentDateTime();
        Scenario.Modify(true);
    end;

    local procedure InsertProjectionLine(ScenarioCode: Code[20]; ProjectionDate: Date; LineCategory: Enum "CLR CF Line Category"; Amount: Decimal; var CumulativeCash: Decimal; IsInflow: Boolean; SourceText: Text[100])
    var
        ProjectionLine: Record "CLR CF Projection Line";
        SignedAmount: Decimal;
    begin
        if Amount = 0 then
            exit;

        if ProjectionLine.Get(ScenarioCode, ProjectionDate, LineCategory) then begin
            CumulativeCash := ProjectionLine."Cumulative Cash";
            exit;
        end;

        SignedAmount := Amount;
        if not IsInflow then
            SignedAmount := -Abs(Amount);

        CumulativeCash += SignedAmount;

        ProjectionLine.Init();
        ProjectionLine."Scenario Code" := ScenarioCode;
        ProjectionLine."Projection Date" := ProjectionDate;
        ProjectionLine.Category := LineCategory;
        ProjectionLine.Amount := Abs(Amount);
        ProjectionLine."Cumulative Cash" := CumulativeCash;
        ProjectionLine.Source := CopyStr(SourceText, 1, MaxStrLen(ProjectionLine.Source));
        ProjectionLine."Is Actual" := ProjectionDate <= Today();
        ProjectionLine.Insert();
    end;

    local procedure GetMetricAmount(var Buffer: Record "CLR BI Metric Buffer" temporary; MetricCode: Code[50]): Decimal
    begin
        Buffer.Reset();
        Buffer.SetRange("Metric Code", MetricCode);
        if Buffer.FindLast() then
            exit(Buffer.Amount);

        exit(0);
    end;

    local procedure GetAssumptionValue(ScenarioCode: Code[20]; Category: Enum "CLR CF Category"; MonthStart: Date; MonthEnd: Date): Decimal
    var
        Assumption: Record "CLR CF Scenario Assumption";
    begin
        Assumption.SetRange("Scenario Code", ScenarioCode);
        Assumption.SetRange(Category, Category);
        Assumption.SetFilter("Apply From", '<=%1', MonthEnd);
        Assumption.SetFilter("Apply To", '>=%1|=%2', MonthStart, 0D);
        if Assumption.FindLast() then
            exit(Assumption.Value);

        exit(0);
    end;

    local procedure ApplyGrowthAndChurn(BaseAmount: Decimal; GrowthRatePct: Decimal; ChurnRatePct: Decimal): Decimal
    var
        ResultAmount: Decimal;
    begin
        ResultAmount := BaseAmount;
        if GrowthRatePct <> 0 then
            ResultAmount := ResultAmount * (1 + (GrowthRatePct / 100));
        if ChurnRatePct <> 0 then
            ResultAmount := ResultAmount * (1 - (ChurnRatePct / 100));

        exit(Round(ResultAmount, 0.01));
    end;

    local procedure ApplyCollectionFactor(InvoiceRevenue: Decimal; CollectionDays: Integer): Decimal
    begin
        if CollectionDays > 45 then
            exit(Round(InvoiceRevenue * 0.70, 0.01));
        if CollectionDays > 30 then
            exit(Round(InvoiceRevenue * 0.85, 0.01));

        exit(Round(InvoiceRevenue * 0.95, 0.01));
    end;

    local procedure ApplyPaymentFactor(BasePayment: Decimal; PaymentDays: Integer): Decimal
    begin
        if PaymentDays > 45 then
            exit(Round(BasePayment * 0.80, 0.01));
        if PaymentDays > 30 then
            exit(Round(BasePayment * 0.90, 0.01));

        exit(Round(BasePayment, 0.01));
    end;

    local procedure GetForecastMonths(StartDate: Date; EndDate: Date): Integer
    var
        LoopDate: Date;
        MonthCount: Integer;
    begin
        if (StartDate = 0D) or (EndDate = 0D) or (StartDate > EndDate) then
            exit(0);

        LoopDate := CalcDate('<CM>', StartDate);
        while LoopDate <= EndDate do begin
            MonthCount += 1;
            LoopDate := CalcDate('<CM+1M>', LoopDate);
        end;

        exit(MonthCount);
    end;

    local procedure ApplyOneOffScenarioAssumptions(ScenarioCode: Code[20]; MonthStartDate: Date; MonthEndDate: Date; var CumulativeCash: Decimal)
    var
        Assumption: Record "CLR CF Scenario Assumption";
        AssumptionDate: Date;
    begin
        Assumption.SetRange("Scenario Code", ScenarioCode);
        Assumption.SetFilter(Category, '%1|%2|%3',
            Enum::"CLR CF Category"::CapExItem,
            Enum::"CLR CF Category"::OneOffReceipt,
            Enum::"CLR CF Category"::OneOffPayment);
        Assumption.SetRange("Apply From", MonthStartDate, MonthEndDate);

        if not Assumption.FindSet() then
            exit;

        repeat
            AssumptionDate := Assumption."Apply From";
            if AssumptionDate = 0D then
                AssumptionDate := MonthStartDate;

            case Assumption.Category of
                Enum::"CLR CF Category"::CapExItem:
                    InsertProjectionLine(ScenarioCode, AssumptionDate, Enum::"CLR CF Line Category"::CapEx, Abs(Assumption.Value), CumulativeCash, false, CopyStr(Assumption.Description, 1, 100));
                Enum::"CLR CF Category"::OneOffReceipt:
                    InsertProjectionLine(ScenarioCode, AssumptionDate, Enum::"CLR CF Line Category"::OneOffReceipt, Abs(Assumption.Value), CumulativeCash, true, CopyStr(Assumption.Description, 1, 100));
                Enum::"CLR CF Category"::OneOffPayment:
                    InsertProjectionLine(ScenarioCode, AssumptionDate, Enum::"CLR CF Line Category"::OneOffPayment, Abs(Assumption.Value), CumulativeCash, false, CopyStr(Assumption.Description, 1, 100));
            end;
        until Assumption.Next() = 0;
    end;
}
