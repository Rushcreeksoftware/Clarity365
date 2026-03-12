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

    procedure SaveViewFromPayload(ViewCode: Code[20]; Description: Text[100]; ViewJson: Text)
    var
        DashboardViewFilter: Record "CLR Dashboard View Filter";
        Payload: JsonObject;
        Token: JsonToken;
        NextLineNo: Integer;
        RangeText: Text;
    begin
        SaveView(ViewCode, Description);

        DashboardViewFilter.SetRange("View Code", ViewCode);
        if not DashboardViewFilter.IsEmpty() then
            DashboardViewFilter.DeleteAll();

        if not Payload.ReadFrom(ViewJson) then
            exit;

        NextLineNo := 10000;

        if Payload.Get('range', Token) then begin
            RangeText := Token.AsValue().AsText();
            InsertFilterLine(ViewCode, NextLineNo, 'range', RangeText);
            NextLineNo += 10000;
        end;

        if Payload.Get('asOfDate', Token) then begin
            InsertFilterLine(ViewCode, NextLineNo, 'asOfDate', Token.AsValue().AsText());
            NextLineNo += 10000;
        end;

        if Payload.Get('glFilter', Token) then begin
            InsertFilterLine(ViewCode, NextLineNo, 'glFilter', Token.AsValue().AsText());
            NextLineNo += 10000;
        end;

        if Payload.Get('dimensionCode', Token) then begin
            InsertFilterLine(ViewCode, NextLineNo, 'dimensionCode', Token.AsValue().AsText());
            NextLineNo += 10000;
        end;
    end;

    procedure TryBuildFilterPayload(ViewCode: Code[20]; var FilterJson: Text): Boolean
    var
        DashboardView: Record "CLR Dashboard View";
        DashboardViewFilter: Record "CLR Dashboard View Filter";
        FilterObject: JsonObject;
    begin
        FilterJson := '';
        if not DashboardView.Get(ViewCode) then
            exit(false);

        if not CanUserAccessView(DashboardView) then
            exit(false);

        DashboardViewFilter.SetRange("View Code", ViewCode);
        if not DashboardViewFilter.FindSet() then
            exit(false);

        repeat
            AddOrReplaceJsonProperty(FilterObject, DashboardViewFilter."Field Name", DashboardViewFilter."Filter Value");
        until DashboardViewFilter.Next() = 0;

        FilterObject.WriteTo(FilterJson);
        exit(true);
    end;

    procedure CanCurrentUserAccessView(ViewCode: Code[20]): Boolean
    var
        DashboardView: Record "CLR Dashboard View";
    begin
        if not DashboardView.Get(ViewCode) then
            exit(false);

        exit(CanUserAccessView(DashboardView));
    end;

    procedure SetViewShared(ViewCode: Code[20]; IsShared: Boolean)
    var
        DashboardView: Record "CLR Dashboard View";
    begin
        if not DashboardView.Get(ViewCode) then
            exit;

        DashboardView."Is Shared" := IsShared;
        DashboardView.Modify(true);
    end;

    local procedure InsertFilterLine(ViewCode: Code[20]; LineNo: Integer; FieldName: Text[100]; FilterValue: Text)
    var
        DashboardViewFilter: Record "CLR Dashboard View Filter";
    begin
        DashboardViewFilter.Init();
        DashboardViewFilter."View Code" := ViewCode;
        DashboardViewFilter."Line No." := LineNo;
        DashboardViewFilter."Field Name" := FieldName;
        DashboardViewFilter."Filter Value" := CopyStr(FilterValue, 1, MaxStrLen(DashboardViewFilter."Filter Value"));
        DashboardViewFilter.Insert(true);
    end;

    local procedure AddOrReplaceJsonProperty(var JsonObj: JsonObject; PropertyName: Text; PropertyValue: Text)
    begin
        if JsonObj.Contains(PropertyName) then
            JsonObj.Replace(PropertyName, PropertyValue)
        else
            JsonObj.Add(PropertyName, PropertyValue);
    end;

    local procedure CanUserAccessView(var DashboardView: Record "CLR Dashboard View"): Boolean
    begin
        if DashboardView."Is Shared" then
            exit(true);

        exit(DashboardView."User ID" = CopyStr(UserId(), 1, MaxStrLen(DashboardView."User ID")));
    end;
}
