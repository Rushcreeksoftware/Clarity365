codeunit 1000213 "Clarity Work Mgt."
{
    procedure SeedSampleData()
    begin
        EnsureWorkItem('WK-0001', 'Kickoff and requirements alignment', Enum::"Clarity Work Status"::Open, 7);
        EnsureWorkItem('WK-0002', 'Data mapping and validation', Enum::"Clarity Work Status"::"In Progress", 14);
        EnsureWorkItem('WK-0003', 'UAT readiness checklist', Enum::"Clarity Work Status"::Blocked, 21);
        EnsureWorkItem('WK-0004', 'Go-live readiness review', Enum::"Clarity Work Status"::Done, -1);

        Message('Sample work items are ready.');
    end;

    local procedure EnsureWorkItem(ItemNo: Code[20]; ItemDescription: Text[100]; ItemStatus: Enum "Clarity Work Status"; DueDateOffsetDays: Integer)
    var
        WorkItem: Record "Clarity Work Item";
        ClaritySetup: Record "Clarity Setup";
    begin
        if WorkItem.Get(ItemNo) then
            exit;

        WorkItem.Init();
        WorkItem."No." := ItemNo;
        WorkItem.Description := ItemDescription;
        WorkItem.Status := ItemStatus;
        WorkItem."Due Date" := CalcDate(StrSubstNo('<%1D>', DueDateOffsetDays), Today());

        if ClaritySetup.Get('SETUP') then begin
            WorkItem.Priority := ClaritySetup."Default Priority";
            WorkItem."Owner User ID" := ClaritySetup."Default Owner User ID";
        end else
            WorkItem.Priority := WorkItem.Priority::Normal;

        WorkItem.Insert(true);
    end;
}
