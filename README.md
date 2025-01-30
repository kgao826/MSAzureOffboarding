# MS EntraID Onboarding & Offboarding (WIP!!)
_Automated Onboarding and Offboarding for Users in Entra ID._

This project focuses on employee onboarding and offboarding in an organisation that uses Microsoft Entra ID and Azure services. The main feature of this project is combining an HR SharePoint form with Azure Logic Apps and Azure Automation Runbooks to onboard or offboard users on a specific date and time, as created in the HR SharePoint form. I am constantly working on improving the number of automated scripts in the Runbook, allowing more features. All Powershell commands use the Microsoft Graph modules and no longer use depreciated MSOnline/AZ modules.

![alt text](https://github.com/kgao826/MSAzureOnboardingOffboarding/blob/main/Offboarding%20Resources%20Diagram.png)

The general layout of the process based on the diagram above is as follows:
- Create a resource group to deploy the other resources.
- Create a SharePoint form for HR or managers to fill out to offboard the employee.
- Create an Azure Logic App to look for changes from the SharePoint form.
- Create the PowerShell script in an Azure Automation Account Runbook so it called by the Logic App.
- Create a KeyVault to store API keys to connect with other services such as Atlassian Jira, JetBrains and other offboarding API requests.
- Create other Azure Logic Apps to be called by the primary Logic App. These Logic Apps can be for other services and can use API keys from the KeyVault.

As long as API methods are offered by other third party services, the offboarding processes such as license removals can be done by additional Logic Apps.
The basic flow of the entire process is shown below:

![alt text](https://github.com/kgao826/MSAzureOnboardingOffboarding/blob/main/Offboarding%20High%20Level%20Flow%20Diagram.png)

## SharePoint Form
Work in progress...updated soon!

## Logic Apps

## Automation Runbook
