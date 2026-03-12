interface "CLR IDataProvider"
{
    procedure GetGLMetrics(FromDate: Date; ToDate: Date; GLAccountFilter: Text; var Buffer: Record "CLR BI Metric Buffer" temporary);
    procedure GetARSummary(AsOfDate: Date; var Buffer: Record "CLR BI Metric Buffer" temporary);
    procedure GetAPSummary(AsOfDate: Date; var Buffer: Record "CLR BI Metric Buffer" temporary);
    procedure GetCurrentCashBalance(): Decimal;
    procedure GetDimensionBreakdown(DimensionCode: Code[20]; FromDate: Date; ToDate: Date; GLAccountFilter: Text; var Buffer: Record "CLR BI Metric Buffer" temporary);
    procedure GetInventoryValuation(AsOfDate: Date; var Buffer: Record "CLR BI Metric Buffer" temporary);
    procedure GetJobMetrics(FromDate: Date; ToDate: Date; var Buffer: Record "CLR BI Metric Buffer" temporary);
    procedure GetFixedAssetMetrics(AsOfDate: Date; var Buffer: Record "CLR BI Metric Buffer" temporary);
    procedure GetPayrollMetrics(FromDate: Date; ToDate: Date; var Buffer: Record "CLR BI Metric Buffer" temporary);
    procedure GetServiceMetrics(FromDate: Date; ToDate: Date; var Buffer: Record "CLR BI Metric Buffer" temporary);
    procedure GetPurchaseMetrics(FromDate: Date; ToDate: Date; var Buffer: Record "CLR BI Metric Buffer" temporary);
    procedure GetManufacturingMetrics(FromDate: Date; ToDate: Date; var Buffer: Record "CLR BI Metric Buffer" temporary);
    procedure HasSubscriptionData(): Boolean;
    procedure GetMRRMetrics(FromDate: Date; ToDate: Date; var Buffer: Record "CLR BI Metric Buffer" temporary);
}
