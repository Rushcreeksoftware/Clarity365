controladdin "CLR Dashboard"
{
    RequestedHeight = 700;
    MinimumHeight = 500;
    RequestedWidth = 1200;
    MinimumWidth = 800;
    VerticalStretch = true;
    HorizontalStretch = true;

    Scripts = 'controladdin/CLR.Dashboard/dist/clarity365.js';
    StyleSheets = 'controladdin/CLR.Dashboard/dist/clarity365.css';

    procedure SendData(PayloadJson: Text);
    procedure SetMode(Mode: Text);

    event ControlAddInReady();
    event FilterChanged(FilterJson: Text);
    event ModeChanged(Mode: Text);
    event ScenarioRequested(ScenarioCode: Text);
    event SaveViewRequested(ViewJson: Text);
    event LoadViewRequested(ViewCode: Text);
    event ExportRequested(ExportType: Text);
    event SetupRequested();
}
