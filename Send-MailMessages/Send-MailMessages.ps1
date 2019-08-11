Add-PSSnapin Microsoft.Exchange.Management.PowerShell.Admin -ErrorAction SilentlyContinue
function Send-MailMessages {
    <#
 
.SYNOPSIS
Generate a constant flow of messages for diagnostic purposes.
 
.DESCRIPTION
This script is designed to assist in generating email messages for testing external message flow to and from your messaging infrastructure.
The ability to quickly send a batch of messages with an attachment on a schedule can help track flow issues or to simply be used to confirm mail routing.
 
.EXAMPLE
Send-MailMessages -To Test@Test.com -From Admin@Contoso.com -MessageCount 10 -SecondsDelay 10 -AttachmentSizeMB 1
 
Send 10 emails to Test@Test.com every 10 seconds with a 1MB Attachment
 
.EXAMPLE
Send-MailMessages -MessageCount 48 -SecondsDelay 1800
 
Send an email every 30 minutes for 24 hours.
 
.LINK
https://jfrmilner.wordpress.com/2010/08/26/send-mailmessages
 
.NOTES
File Name: Send-MailMessages.ps1
Author: jfrmilner
Requires: Powershell V2
Requires: Exchange Managemnent Shell (Only used to auto find the smtpServer)
Legal: This script is provided "AS IS" with no warranties or guarantees, and confers no rights. You may use, modify, reproduce, and distribute this script file in any way provided that you agree to give the original author credit.
Version: v1.0 - 2010 Aug 08 - First Version http://poshcode.org/*
Version: v1.1 - 2012 April 26 - Fixed when only a single HT Server is available. Added check for existing file. Fixed attachment parameter to use varible.
 
#>
 
    param ( [Parameter(Mandatory = $false)] $To = "Test@WingtipToys.com", [Parameter(Mandatory = $false)] $From = "Postmaster@contoso.com", $AttachmentSizeMB = $null, $MessageCount = 2, $SecondsDelay = 10 )
 
    $messageParameters = @{
        Body       = $null | ConvertTo-Html -Body "<H2> Test Message, Please ignore </H2>" | Out-String
        From       = $from
        To         = $to
        SmtpServer = @(Get-TransportServer)[0].Name.ToString()
    }
    if ($AttachmentSizeMB) {
 
        if ((Test-Path $Env:TMP\$($AttachmentSizeMB)mbfile.txt) -ne $true) {
            fsutil file createnew $Env:TMP\$($AttachmentSizeMB)mbfile.txt $($AttachmentSizeMB * 1MB)
        }
        $messageParameters.Add("attachment", "$Env:TMP\$($AttachmentSizeMB)mbfile.txt") 
    }
 
    1..$MessageCount | % { sleep -Seconds $secondsDelay ; Send-MailMessage @messageParameters -Subject ("Mailflow Test Email - " + (Get-Date).ToLongTimeString() + " Message " + $_ + " / $MessageCount") -BodyAsHtml }
 
}