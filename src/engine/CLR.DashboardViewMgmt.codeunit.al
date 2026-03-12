codeunit 50307 "CLR Dashboard View Mgmt"
{
    procedure SaveView(ViewCode: Code[20]; Description: Text[100])
    var
        DashboardView: Record "CLR Dashboard View";
    begin
        if DashboardView.Get(ViewCode) then begin
            DashboardView.Description := Description;
            DashboardView.Modify(true);
            exit;
        end;

        DashboardView.Init();
        DashboardView.Code := ViewCode;
        DashboardView.Description := Description;
        DashboardView."User ID" := CopyStr(UserId(), 1, MaxStrLen(DashboardView."User ID"));
        DashboardView.Mode := 'bi';
        DashboardView."Created DateTime" := CurrentDateTime();
        DashboardView.Insert(true);
    end;
}
