page 50250 "CLR Dashboard"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    Caption = 'Clarity Dashboard';

    layout
    {
        area(Content)
        {
            usercontrol(Dashboard; "CLR Dashboard")
            {
                ApplicationArea = All;

                trigger ControlAddInReady()
                var
                    BiEngine: Codeunit "CLR BI Engine";
                begin
                    CurrPage.Dashboard.SendData(BiEngine.BuildPayloadJson());
                    CurrPage.Dashboard.SetMode('bi');
                end;

                trigger SetupRequested()
                begin
                    Page.Run(Page::"CLR Setup Wizard");
                end;
            }
        }
    }
}
