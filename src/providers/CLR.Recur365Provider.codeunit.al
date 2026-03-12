codeunit 50301 "CLR Recur365 Provider" implements "CLR IDataProvider"
{
    procedure GetGLMetrics(FromDate: Date; ToDate: Date; GLAccountFilter: Text; var Buffer: Record "CLR BI Metric Buffer" temporary)
    begin
        exit;
    end;

    procedure GetARSummary(AsOfDate: Date; var Buffer: Record "CLR BI Metric Buffer" temporary)
    begin
        exit;
    end;

    procedure GetAPSummary(AsOfDate: Date; var Buffer: Record "CLR BI Metric Buffer" temporary)
    begin
        exit;
    end;

    procedure GetCurrentCashBalance(): Decimal
    begin
        exit(0);
    end;

    procedure GetDimensionBreakdown(DimensionCode: Code[20]; FromDate: Date; ToDate: Date; GLAccountFilter: Text; var Buffer: Record "CLR BI Metric Buffer" temporary)
    begin
        exit;
    end;

    procedure GetInventoryValuation(AsOfDate: Date; var Buffer: Record "CLR BI Metric Buffer" temporary)
    begin
        exit;
    end;

    procedure GetJobMetrics(FromDate: Date; ToDate: Date; var Buffer: Record "CLR BI Metric Buffer" temporary)
    begin
        exit;
    end;

    procedure GetFixedAssetMetrics(AsOfDate: Date; var Buffer: Record "CLR BI Metric Buffer" temporary)
    begin
        exit;
    end;

    procedure GetPayrollMetrics(FromDate: Date; ToDate: Date; var Buffer: Record "CLR BI Metric Buffer" temporary)
    begin
        exit;
    end;

    procedure GetServiceMetrics(FromDate: Date; ToDate: Date; var Buffer: Record "CLR BI Metric Buffer" temporary)
    begin
        exit;
    end;

    procedure GetPurchaseMetrics(FromDate: Date; ToDate: Date; var Buffer: Record "CLR BI Metric Buffer" temporary)
    begin
        exit;
    end;

    procedure GetManufacturingMetrics(FromDate: Date; ToDate: Date; var Buffer: Record "CLR BI Metric Buffer" temporary)
    begin
        exit;
    end;

    procedure HasSubscriptionData(): Boolean
    begin
        exit(false);
    end;

    procedure GetMRRMetrics(FromDate: Date; ToDate: Date; var Buffer: Record "CLR BI Metric Buffer" temporary)
    begin
        exit;
    end;
}
