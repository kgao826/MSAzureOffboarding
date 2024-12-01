#The parameters are going to be from the logic app. In the logic app we can specify the user and the manager
param (
    [Parameter (Mandatory = $true)] 
    [String]$Username,
    [Parameter (Mandatory = $true)] 
    [String]$Manager #Manager Email
)
$CustomerDefaultDomainname = "examplecompany.onmicrosoft.com" #Put your organisation domain here

Write-Output $Username

#Connecting to Exchange Online, permissions for this are documented
Write-Output "Connecting to Exchange Online"
Connect-ExchangeOnline -ManagedIdentity -Organization examplecompany.com 

$Mailbox = Get-Mailbox | Where {$_.PrimarySmtpAddress -eq $Username} #Get the offboarding employee's mailbox

#Write your own default out-of-office auto-reply. 
$OutOfOfficeBody = @"
Hello,

Thank you for your email. I am no longer with ExampleCompany. Please direct all future inquiries to $Manager. 
He/she will be happy to assist you. Just so you know, your email will not be forwarded automatically.

Thanks!
"@

#Connecting to Microsoft Graph
Connect-MgGraph -Identity
Write-Output "Connected to Microsoft Graph"
$User = Get-MgUser -UserId $Username

#Set Sign in Blocked
Write-Output "Block Sign In"
Update-MgUser -UserId $User.Id -AccountEnabled $false 

#Disconnect Existing Sessions
Write-Output "Revoke Sessions"
Revoke-MgUserSignInSession -UserId $User.Id

#Remove Calendar Events
Remove-CalendarEvents -Identity $Username -CancelOrganizedMeetings -QueryWindowInDays 1000
Write-Output "Cancelled Calendar Events"

#Set Out Of Office
Set-MailboxAutoReplyConfiguration -Identity $Mailbox.Alias -ExternalMessage $OutOfOfficeBody -InternalMessage $OutOfOfficeBody -AutoReplyState Enabled -ExternalAudience All -AutoDeclineFutureRequestsWhenOOF $true

#Setting mailbox to Shared Mailbox
Write-Output "Setting mailbox to Shared Mailbox"
Set-Mailbox $Username -Type Shared

#Assign Manager to Shared Mailbox
Write-Output "Assign Manager to Shared Mailbox"
Add-MailboxPermission -Identity $Username -User $Manager -AccessRights FullAccess -InheritanceType All

#Hiding user from GAL
Write-Output "Hiding user from GAL"
Set-Mailbox $Username -HiddenFromAddressListsEnabled $true

#Remove user from all groups (owner)
Write-Output "Removing user from Office365 Groups with Owner Role"

$OwnerInGroups = Get-MgGroup | Where-Object {(Get-MgGroupOwner -GroupId $_.Id | foreach {$_.Id}) -contains $User.Id}
foreach ($Group in $OwnerInGroups){
    Remove-MgGroupOwnerByRef -DirectoryObjectId $User.Id -GroupId $Group.Id
    Write-Output "Removing user from $($Group.DisplayName) as owner"
}

#Remove user from all groups (member)
Write-Output "Removing user from Office365 Groups with Member Role"

$MemberInGroups = Get-MgUserMemberOf -UserId $User.Id
foreach ($Group in $MemberInGroups){
    Remove-MgGroupMemberByRef -DirectoryObjectId $User.Id -GroupId $Group.Id
    Write-Output "Removing user from $((Get-MgGroup -GroupId $Group.Id).DisplayName) as member"
}

#Removing users from Distribution Groups
Write-Output "Removing users from Distribution Groups"
$OffboardingDN = (get-mailbox -Identity $Username -IncludeInactiveMailbox).DistinguishedName
Get-Recipient -Filter "Members -eq '$OffboardingDN'" | foreach-object { 
    Write-Output "Removing user from $($_.name)"
    Remove-DistributionGroupMember -Identity $_.ExternalDirectoryObjectId -Member $OffboardingDN -BypassSecurityGroupManagerCheck -Confirm:$false }

#Remove Licenses
Write-Output "Remove License Details"
$LicenseList = Get-MgUserLicenseDetail -UserId $User.Id
foreach ($License in $LicenseList){
    Set-MgUserLicense -UserId $user.id -AddLicenses @() -RemoveLicenses $License.skuId
    Write-Output "Removing license $($License.SkuPartNumber) from user"
}

#Remove Manager
Write-Output "Removed Manager"
Remove-MgUserManagerByRef -UserId $User.Id

#Disconnect
Disconnect-ExchangeOnline
Disconnect-MgGraph
Write-Output "Disconnected"
