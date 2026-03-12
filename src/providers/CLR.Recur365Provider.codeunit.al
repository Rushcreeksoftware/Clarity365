codeunit 50301 "CLR Recur365 Provider" implements "CLR IDataProvider"
{
    procedure GetGLMetrics(FromDate: Date; ToDate: Date; GLAccountFilter: Text; var Buffer: Record "CLR BI Metric Buffer" temporary)
    var
        NativeProvider: Codeunit "CLR BC Native Provider";
    begin
        NativeProvider.GetGLMetrics(FromDate, ToDate, GLAccountFilter, Buffer);
    end;

    procedure GetARSummary(AsOfDate: Date; var Buffer: Record "CLR BI Metric Buffer" temporary)
    var
        NativeProvider: Codeunit "CLR BC Native Provider";
    begin
        NativeProvider.GetARSummary(AsOfDate, Buffer);
    end;

    procedure GetAPSummary(AsOfDate: Date; var Buffer: Record "CLR BI Metric Buffer" temporary)
    var
        NativeProvider: Codeunit "CLR BC Native Provider";
    begin
        NativeProvider.GetAPSummary(AsOfDate, Buffer);
    end;

    procedure GetCurrentCashBalance(): Decimal
    var
        NativeProvider: Codeunit "CLR BC Native Provider";
    begin
        exit(NativeProvider.GetCurrentCashBalance());
    end;

    procedure GetDimensionBreakdown(DimensionCode: Code[20]; FromDate: Date; ToDate: Date; GLAccountFilter: Text; var Buffer: Record "CLR BI Metric Buffer" temporary)
    var
        NativeProvider: Codeunit "CLR BC Native Provider";
    begin
        NativeProvider.GetDimensionBreakdown(DimensionCode, FromDate, ToDate, GLAccountFilter, Buffer);
    end;

    procedure GetInventoryValuation(AsOfDate: Date; var Buffer: Record "CLR BI Metric Buffer" temporary)
    var
        NativeProvider: Codeunit "CLR BC Native Provider";
    begin
        NativeProvider.GetInventoryValuation(AsOfDate, Buffer);
    end;

    procedure GetJobMetrics(FromDate: Date; ToDate: Date; var Buffer: Record "CLR BI Metric Buffer" temporary)
    var
        NativeProvider: Codeunit "CLR BC Native Provider";
    begin
        NativeProvider.GetJobMetrics(FromDate, ToDate, Buffer);
    end;

    procedure GetFixedAssetMetrics(AsOfDate: Date; var Buffer: Record "CLR BI Metric Buffer" temporary)
    var
        NativeProvider: Codeunit "CLR BC Native Provider";
    begin
        NativeProvider.GetFixedAssetMetrics(AsOfDate, Buffer);
    end;

    procedure GetPayrollMetrics(FromDate: Date; ToDate: Date; var Buffer: Record "CLR BI Metric Buffer" temporary)
    var
        NativeProvider: Codeunit "CLR BC Native Provider";
    begin
        NativeProvider.GetPayrollMetrics(FromDate, ToDate, Buffer);
    end;

    procedure GetServiceMetrics(FromDate: Date; ToDate: Date; var Buffer: Record "CLR BI Metric Buffer" temporary)
    var
        NativeProvider: Codeunit "CLR BC Native Provider";
    begin
        NativeProvider.GetServiceMetrics(FromDate, ToDate, Buffer);
    end;

    procedure GetPurchaseMetrics(FromDate: Date; ToDate: Date; var Buffer: Record "CLR BI Metric Buffer" temporary)
    var
        NativeProvider: Codeunit "CLR BC Native Provider";
    begin
        NativeProvider.GetPurchaseMetrics(FromDate, ToDate, Buffer);
    end;

    procedure GetManufacturingMetrics(FromDate: Date; ToDate: Date; var Buffer: Record "CLR BI Metric Buffer" temporary)
    var
        NativeProvider: Codeunit "CLR BC Native Provider";
    begin
        NativeProvider.GetManufacturingMetrics(FromDate, ToDate, Buffer);
    end;

    procedure HasSubscriptionData(): Boolean
    var
        Detector: Codeunit "CLR Module Detector";
    begin
        exit(Detector.IsRecur365Installed());
    end;

    procedure GetMRRMetrics(FromDate: Date; ToDate: Date; var Buffer: Record "CLR BI Metric Buffer" temporary)
    var
        NativeProvider: Codeunit "CLR BC Native Provider";
    begin
        NativeProvider.GetMRRMetrics(FromDate, ToDate, Buffer);
    end;
}
