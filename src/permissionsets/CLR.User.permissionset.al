permissionset 50391 "CLR User"
{
    Assignable = true;
    Caption = 'Clarity User';

    Permissions =
        tabledata "CLR Data Provider Setup" = R,
        tabledata "CLR BI Metric Buffer" = R,
        tabledata "CLR Dashboard View" = RIMD,
        tabledata "CLR Dashboard View Filter" = RIMD,
        tabledata "CLR CF Scenario Header" = R,
        tabledata "CLR CF Scenario Assumption" = R,
        tabledata "CLR CF Projection Line" = R,
        tabledata "CLR Manual CF Entry" = R,
        tabledata "CLR Export Log" = R,
        table "CLR Data Provider Setup" = X,
        table "CLR BI Metric Buffer" = X,
        table "CLR Dashboard View" = X,
        table "CLR Dashboard View Filter" = X,
        table "CLR CF Scenario Header" = X,
        table "CLR CF Scenario Assumption" = X,
        table "CLR CF Projection Line" = X,
        table "CLR Manual CF Entry" = X,
        table "CLR Export Log" = X,
        page "CLR Dashboard" = X,
        page "CLR CF Scenario List" = X,
        page "CLR CF Scenario Card" = X,
        page "CLR CF Assumption List" = X,
        page "CLR Manual CF Entry List" = X,
        page "CLR Dashboard View List" = X,
        page "CLR Setup" = X,
        page "CLR Setup Wizard" = X,
        page "CLR Export Log List" = X,
        page "CLR BI Metrics API" = X,
        page "CLR CF Projection API" = X,
        page "CLR Module Status API" = X,
        codeunit "CLR BI Engine" = X,
        codeunit "CLR Export Mgmt" = X,
        codeunit "CLR Cf Forecast Engine" = X,
        report "CLR Dashboard Summary" = X,
        codeunit "CLR Dashboard View Mgmt" = X;
}
