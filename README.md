# MS EntraID Offboarding (WIP!!)
_Automated Offboarding for Users in Entra ID using a SharePoint form._

## Table of Contents:
1. Overview
2. SharePoint Form
3. Logic Apps
4. Automation Runbook

## 1. Overview
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

## 2. SharePoint Form
Work in progress...updated soon!

## 3. Logic Apps

## 4. Automation Runbook
### Create the Automation Account
Create an Automation Runbook to run PowerShell scripts in Azure. This allows the logic app to call the script on demand quickly. 
1. Go to Azure > Create an Automation Account
2. Put it in the right resource group and the same region as all other resources.
3. Ensure it is set to System Assigned Identity, and you can put everything else to default.

### Create Runbook
Create a new Runbook with an appropriate name with the PowerShell script offboarding.ps1, modify the script as you wish, but test it to suit your organisation. We will deal with the permissions later.

|  | Value |
| ------------- | ------------- |
| Runbook Type  | PowerShell  |
| Runtime Version  | 7.2  |

Since version 7.1 is being depreciated, make sure to use 7.2.

Change to the following placeholder and the out of office message:
- Line 13: ```$CustomerDefaultDomainname = "examplecompany.onmicrosoft.com"```
- Line 19: ```Connect-ExchangeOnline -ManagedIdentity -Organization examplecompany.com```
- Lines 24-32: ```$OutOfOfficeBody```

Publish the Runbook

### Import Modules
On the left pane, go to **Shared Resources** > **Modules**

**Add a Module** > **Browse from gallery** > Search and select the module > Version 7.2

You will need to import the following modules to run the PowerShell script:
- ExchangeOnlineManagement
- Microsoft.Graph.Authentication
- Microsoft.Graph.Groups
- Microsoft.Graph.Users
- Microsoft.Graph.Users.Actions
- Microsoft.Graph.Mail
- PackageManagement
- PowerShellGet

### Managed Identity Permissions
Note that we need to sort out the permissions for 
- ```Connect-ExchangeOnline -ManagedIdentity```
- ```Connect-MgGraph -Identity```

To give the right access for the runbook to perform actions you need to give it several permissions. You can assign GA or you can assign more granular permissions such as the following:

| Role | Env (App ID) | Role ID |
| ------------- | ------------- | ------------- |
| User Administrator | RBAC |  |
| Privileged User Administrator | RBAC |  |
| Directory Reader | RBAC |  |
| Privileged Authentication Administrator| RBAC |  |
| Exchange.ManageAsApp | Exchange (00000002-0000-0ff1-ce00-000000000000)| dc50a0fb-09a3-484d-be87-e023b12c6440 |
| Exchange Administrator | RBAC |  |
| Directory.Read.All | MS Graph (00000003-0000-0000-c000-000000000000) | 7ab1d382-f21e-4acd-a863-ba3e13f7da61 |

For Azure RBAC roles, you simply assign the role in Entra ID. For the other permissions, you need to use PowerShell.
# Logic App System Managed Identity
## PowerShell Script to Assign Permissions to System Managed Identity
To find the Role ID of the permission go [here](https://developer.microsoft.com/en-us/graph/graph-explorer)

Run the following request and search for the role name (GET):
```
https://graph.microsoft.com/v1.0/servicePrincipals(appId='00000003-0000-0000-c000-000000000000')?$select=id,appId,displayName,appRoles,oauth2PermissionScopes,resourceSpecificApplicationPermissions
```

Then use the following script in any PowerShell terminal (e.g. PowerShell ISE or CloudShell):
```
Connect-MgGraph -TenantId <TENANT ID> -Scopes AppRoleAssignment.ReadWrite.All,Application.Read.All
$MI_ID = "<APP ID>"
$AppRoleID = "<ROLE ID>"
$ResourceID = (Get-MgServicePrincipal -Filter "AppId eq '00000003-0000-0000-c000-000000000000'").Id
New-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $MI_ID -PrincipalId $MI_ID -AppRoleId $AppRoleID -ResourceId $ResourceID
```

If module not recognised
```
Install-Module Microsoft.Graph -Scope AllUsers  
```
**EXAMPLE** for logic-aue-LifecycleWorkflowToAA-offboarding

```
Connect-MgGraph -TenantId <TENANT ID> -Scopes AppRoleAssignment.ReadWrite.All,Application.Read.All
$MI_ID = "b116ef4a-bbcc-4e59-9850-65548573d912"
$AppRoleID = "c529cfca-c91b-489c-af2b-d92990b66ce6"
$ResourceID = (Get-MgServicePrincipal -Filter "AppId eq '00000003-0000-0000-c000-000000000000'").Id
New-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $MI_ID -PrincipalId $MI_ID -AppRoleId $AppRoleID -ResourceId $ResourceID
```

First, double-check that the App ID and Role ID are still correct in [Graph Explorer](https://developer.microsoft.com/en-us/graph/graph-explorer).

You can check successful permissions assignments in the Roles and Administrators section of the Entreprise App.

### Monitor
Create a log search alert rule to monitor the automation account in case of any failures and send an email to your IT team.
