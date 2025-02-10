# MS EntraID Onboarding & Offboarding (WIP!!)
_Automated Onboarding and Offboarding for Users in Entra ID._

This project focuses on employee onboarding and offboarding in an organisation that uses Microsoft Entra ID and Azure services. The main feature of this project is combining an HR SharePoint form with Azure Logic Apps and Azure Automation Runbooks to onboard or offboard users on a specific date and time, as created in the HR SharePoint form. I am constantly improving the number of automated scripts in the Runbook, allowing more features. All Powershell commands use the Microsoft Graph modules and no longer use depreciated MSOnline/AZ modules. It is recommended that the Managed Identity for the offboarding has a GA role so it can disable Privileged users. GA (Global Administrator) users should be removed from the GA role prior to offboarding.

The automation will perform the following actions on a leaving employee:
- Block sign-in (Issues with disabling GA still persist, solution is to remove the GA role from the user before termination)
- Disconnect existing sessions
- Remove calendar events
- Set out of office message
- Assign manager shared inbox
- Hide user email from global address list
- Remove the user from all groups as owner (groups that end up with no owners will send a notification to IT team)
- Remove the user from all groups as a member
- Remove the user from distribution groups
- Remove licenses
- Remove manager

All actions are run in order in the PowerShell script; should you wish to disable any, simply remove part of the script from the automation runbook.

![alt text](https://github.com/kgao826/MSAzureOnboardingOffboarding/blob/main/Offboarding%20Resources%20Diagram.png)

The general layout of the process based on the diagram above is as follows:
- Create a SharePoint form for HR or managers to fill out to offboard the employee.
- Create a resource group in Azure to deploy the Azure resources.
- Create an Azure Logic App to look for changes from the SharePoint form.
- Create the PowerShell script for offboarding in an Azure Automation Account Runbook to be called by the Logic App.
- Create a KeyVault to store API keys to connect with other services such as Atlassian Jira, JetBrains and other offboarding API requests.
- Create other Azure Logic Apps to be called by the primary Logic App. These Logic Apps can be for other services and can use API keys from the KeyVault.

As long as API methods are offered by other third-party services, the offboarding processes, such as license removals, can be done by additional Logic Apps. Apart from APIs, you can also use OAuth.
The basic flow of the entire process is shown below:

![alt text](https://github.com/kgao826/MSAzureOnboardingOffboarding/blob/main/Offboarding%20High%20Level%20Flow%20Diagram.png)

## SharePoint Form
Work in progress...updated soon!

## Logic Apps

## Automation Runbook
