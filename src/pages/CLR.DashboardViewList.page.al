page 50255 "CLR Dashboard View List"
{
    PageType = List;
    SourceTable = "CLR Dashboard View";
    ApplicationArea = All;
    UsageCategory = Lists;
    Caption = 'Clarity Dashboard Views';

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Code; Rec.Code) { ApplicationArea = All; }
                field("User ID"; Rec."User ID") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field(Mode; Rec.Mode) { ApplicationArea = All; }
                field("Is Shared"; Rec."Is Shared") { ApplicationArea = All; }
                field("Created DateTime"; Rec."Created DateTime") { ApplicationArea = All; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ShareView)
            {
                ApplicationArea = All;
                Caption = 'Share View';
                Image = Share;

                trigger OnAction()
                var
                    ViewMgt: Codeunit "CLR Dashboard View Mgmt";
                begin
                    ViewMgt.SetViewShared(Rec.Code, true);
                    CurrPage.Update(false);
                end;
            }

            action(UnshareView)
            {
                ApplicationArea = All;
                Caption = 'Unshare View';
                Image = UnShare;

                trigger OnAction()
                var
                    ViewMgt: Codeunit "CLR Dashboard View Mgmt";
                begin
                    ViewMgt.SetViewShared(Rec.Code, false);
                    CurrPage.Update(false);
                end;
            }
        }
    }

}
