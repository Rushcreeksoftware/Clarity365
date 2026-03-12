codeunit 50300 "CLR BC Native Provider" implements "CLR IDataProvider"
{
    procedure GetGLMetrics(FromDate: Date; ToDate: Date; GLAccountFilter: Text; var Buffer: Record "CLR BI Metric Buffer" temporary)
    begin
    end;

    procedure GetARSummary(AsOfDate: Date; var Buffer: Record "CLR BI Metric Buffer" temporary)
    begin
    end;

    procedure GetAPSummary(AsOfDate: Date; var Buffer: Record "CLR BI Metric Buffer" temporary)
    begin
    end;

    procedure GetCurrentCashBalance(): Decimal
    begin
        exit(0);
    end;

    procedure GetDimensionBreakdown(DimensionCode: Code[20]; FromDate: Date; ToDate: Date; GLAccountFilter: Text; var Buffer: Record "CLR BI Metric Buffer" temporary)
    begin
    end;

    procedure GetInventoryValuation(AsOfDate: Date; var Buffer: Record "CLR BI Metric Buffer" temporary)
    begin
    end;

    procedure GetJobMetrics(FromDate: Date; ToDate: Date; var Buffer: Record "CLR BI Metric Buffer" temporary)
    begin
    end;

    procedure GetFixedAssetMetrics(AsOfDate: Date; var Buffer: Record "CLR BI Metric Buffer" temporary)
    begin
    end;

    procedure GetPayrollMetrics(FromDate: Date; ToDate: Date; var Buffer: Record "CLR BI Metric Buffer" temporary)
    begin
    end;

    procedure GetServiceMetrics(FromDate: Date; ToDate: Date; var Buffer: Record "CLR BI Metric Buffer" temporary)
    begin
    end;

    procedure GetPurchaseMetrics(FromDate: Date; ToDate: Date; var Buffer: Record "CLR BI Metric Buffer" temporary)
    begin
    end;

    procedure GetManufacturingMetrics(FromDate: Date; ToDate: Date; var Buffer: Record "CLR BI Metric Buffer" temporary)
    begin
    end;

    procedure HasSubscriptionData(): Boolean
    begin
        exit(false);
    end;

    procedure GetMRRMetrics(FromDate: Date; ToDate: Date; var Buffer: Record "CLR BI Metric Buffer" temporary)
    begin
    end;
}
