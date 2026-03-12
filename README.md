# Clarity365

Clarity365 is a Microsoft Dynamics 365 Business Central extension that provides self-service BI dashboards and multi-scenario cash flow forecasting.

## Implemented Baseline
1. Full AL object scaffold aligned to Clarity365 object ranges (`50200..50399`)
2. Data model for setup, BI metric buffer, dashboard views, CF scenarios, assumptions, projections, manual entries, and error log
3. `CLR IDataProvider` interface with BC native and Recur365 provider implementations
4. Provider factory, module detector, BI engine, cash flow engine, scenario management, and setup wizard management codeunits
5. API pages for BI metrics, CF projection lines, and module status
6. Dashboard, setup, setup wizard, and cash flow scenario pages
7. Admin/User permission sets and install codeunit bootstrap
8. Control add-in declaration and dashboard web scaffold with committed `dist` placeholders
9. GitHub workflows for CI validation and manual tag/release

## Getting Started
1. Open this folder in VS Code.
2. Download symbols from the AL extension command palette.
3. Build and publish to your Business Central sandbox.
4. Assign permission set `CLR Admin` for admins and `CLR User` for standard users.
5. Open `Clarity Dashboard` and run `Clarity Setup Wizard`.
