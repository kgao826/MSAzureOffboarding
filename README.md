# MS EntraID Onboarding & Offboarding (WIP!!)
_Automated Onboarding and Offboarding for Users in Entra ID._

This project focuses on employee onboarding and offboarding in an organisation that uses Microsoft Entra ID and Azure services. The main feature of this project is combining an HR SharePoint form with Azure Logic Apps and Azure Automation Runbooks to onboard or offboard users on a specific date and time, as created in the HR SharePoint form. I am constantly working on improving the number of automated scripts in the Runbook, allowing more features. All Powershell commands use the Microsoft Graph modules and no longer use depreciated MSOnline/AZ modules.

![alt text](https://github.com/kgao826/MSAzureOnboardingOffboarding/blob/main/Github%20Azure%20Diagrams.png)

The general layout of the process based on the diagram above is as follows:
- Create a resource group to deploy the other resources.
- Create a SharePoint form for HR or managers to fill out to offboard the employee.
- Create an Azure Logic App to look for changes from the SharePoint form.
- Create the PowerShell script in an Azure Automation Account Runbook so it called by the Logic App.
- Create a KeyVault to store API keys to connect with other services such as Atlassian Jira, JetBrains and other offboarding API requests.

## SharePoint Form
Work in progress...updated soon!

## Logic Apps

## Automation Runbook
