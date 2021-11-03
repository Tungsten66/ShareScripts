<##############################################################################
LEGAL DISCLAIMER
This Sample Code is provided for the purpose of illustration only and is not
intended to be used in a production environment.  THIS SAMPLE CODE AND ANY
RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF
MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.  We grant You a
nonexclusive, royalty-free right to use and modify the Sample Code and to
reproduce and distribute the object code form of the Sample Code, provided
that You agree: (i) to not use Our name, logo, or trademarks to market Your
software product in which the Sample Code is embedded; (ii) to include a valid
copyright notice on Your software product in which the Sample Code is embedded;
and (iii) to indemnify, hold harmless, and defend Us and Our suppliers from and
against any claims or lawsuits, including attorneys’ fees, that arise or result
from the use or distribution of the Sample Code.
 
This posting is provided "AS IS" with no warranties, and confers no rights. Use
of included script samples are subject to the terms specified
at https://www.microsoft.com/en-us/legal/copyright.
##############################################################################>

<#
.SYNOPSIS
    This script will download and notify any new version of Office 2019 from the Office CDN and can be used in a scheduled task
.DESCRIPTION
	Steps to setup this process:
	Download the Office Deployment Tool (https://www.microsoft.com/en-us/download/details.aspx?id=49117)
	Create configuration file to download Office 2019
	Download the installation files for Microsoft (setup.exe /download configuration-Office2019Enterprise.xml)  Example in Folder
	Transfer to disconnected network and place on share
	Create a GPO to point clients to file share to pull updates - Computer Configuration\Administrative Templates\Microsoft Office 2016 (Machine)\Updates\Update Path
	Setup a scheduled task to check for the latest version of Office 2019 on the CDN on the internet, download it, and notify admins via e-mail to transfer
   
.INPUTS
   
.OUTPUTS
   
.NOTES
    Name: Check-NewOfficeVersion.ps1
    Authors/Contributors: Nick OConnor
    DateCreated: 8/12/2021
    Revisions:
#>

#Download New Office Version if it exists
Set-Location "F:\Packages\Office2019Updates"
.\setup.exe /download .\configuration-Office2019Enterprise.xml


#Mail Message Variables 
$from = "Active Directory Administration <noreply@contoso.com>"
$bcc = "name@contoso.com"
$to = "@"
$subject = "<ACTION REQUIRED> Office 2019 Updates Downloaded"
$smtpServer = "smtp.contoso.com"

#Body of Mail Message
$body = 
"
THIS IS AN AUTOMATED MESSAGE GENERATED BY VIA SCRIPT PROCESSED BY SCHEDULEDTASK
`n
A new version of Office 2019 has been downloaded and needs to be transferred
`n
"


#Check for new files and send e-mail
$DownloadPath = "F:\Packages\Office2019Updates\Office\Data"
$files = Get-Item $DownloadPath\*.*

foreach ($file in $files) {
    $CreationTime = $file.CreationTime
    $CurrentTime = Get-Date
    if (($CurrentTime - $CreationTime).totalhours -le 24) {        
        $NewFiles += 1
        Write-Host "New File"
    }
    Else {
        #$NewFiles="False"
        Write-Host "Old File"
    }

}

#Send e-mail if new files have been downloaded
if ($NewFiles -ge 1) {
    Write-Host "Sending E-mail"
    Send-MailMessage -to $to -Bcc $bcc -from $from -Subject $subject -Body $body -SmtpServer $smtpServer -ErrorAction SilentlyContinue
} 
