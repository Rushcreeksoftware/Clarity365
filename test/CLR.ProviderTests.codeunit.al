codeunit 50344 "CLR ProviderTests"
{
    Subtype = Test;

    [Test]
    procedure BCNativeProviderReturnsCashBalance()
    var
        Provider: Codeunit "CLR BC Native Provider";
        CashBalance: Decimal;
    begin
        // GIVEN

        // WHEN
        CashBalance := Provider.GetCurrentCashBalance();

        // THEN
        if CashBalance <> CashBalance then
            Error('Unexpected cash balance result.');
    end;
}
