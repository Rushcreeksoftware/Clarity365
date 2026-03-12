codeunit 50304 "CLR BI Engine"
{
    procedure BuildPayloadJson(): Text
    var
        Detector: Codeunit "CLR Module Detector";
        Payload: JsonObject;
        Kpis: JsonObject;
        Revenue: JsonArray;
        EmptyArr: JsonArray;
    begin
        Payload.Add('activeModules', Detector.GetActiveModulesCsv());
        Payload.Add('hasRecur365', Detector.IsRecur365Installed());
        Payload.Add('currencyCode', '');
        Payload.Add('reportingDate', Format(Today(), 0, 9));

        Kpis.Add('revenueMtd', 0);
        Kpis.Add('revenueYtd', 0);
        Kpis.Add('openAR', 0);
        Kpis.Add('openAP', 0);
        Kpis.Add('cashBalance', 0);
        Kpis.Add('grossMarginPct', 0);
        Kpis.Add('mrr', 0);
        Kpis.Add('mrrTrend', 0);

        Payload.Add('kpis', Kpis);
        Payload.Add('revenue', Revenue);
        Payload.Add('arAging', EmptyArr);
        Payload.Add('apAging', EmptyArr);
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

        exit(Format(Payload));
    end;
}
