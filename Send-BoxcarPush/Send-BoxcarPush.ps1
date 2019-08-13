function Send-BoxcarPush {
    <#
    .SYNOPSIS
    A function to send Boxcar Push messages.
    .DESCRIPTION
    An example of using PowerShell to send Universal Push Notification messages. Typically the target device is a mobile running iOS (https://boxcar.io/client) or Andriod.
    .PARAMETER notificationTitle
    Message Title/Subject. 140 Character Maximum.
    .PARAMETER notificationLongMessage
    Message body text. 1000 Character Maximum.
    .PARAMETER notificationSound
    Notification Sound played on receiving device. Default is ‘bird-1’, see the Available sounds list for options - https://boxcar.uservoice.com/knowledgebase/articles/306788-how-to-send-your-boxcar-account-a-notification
    .PARAMETER hostURI
    Default is usually fine.
    .PARAMETER user_credentials
    Boxcar Access Token. Its recommended you change this value in the Param section of this function else it will need to be specified each time. The access token is available from the general "Settings" screen of Boxcar Client app.
    .EXAMPLE
    Send-BoxcarPush -notificationTitle "Test Title" -notificationLongMessage "Body message text"
    .NOTES
    Author: John Milner
    Blog  : http://jfrmilner.wordpress.com
    File Name: Send-BoxcarPush.ps1
    Author: jfrmilner
    Email: jfrmilner@googlemail.com
    Requires: Powershell v4 (May work on older versions but untested)
    Legal: This script is provided "AS IS" with no warranties or guarantees, and confers no rights. You may use, modify, reproduce, and distribute this script file in any way provided that you agree to give the original author credit.
    Version: v1.0 - 2014 March 1st - First Version
    Version: v1.1 - 2014 March 2nd - Added URL Encoding
    .LINK
    http://jfrmilner.wordpress.com/2014/03/01/powershell-pus…ered-by-boxcar/
    #>
    Param(
        [String]
        [parameter(Mandatory = $true)]
        [ValidateLength(1, 140)]
        $notificationTitle = "test"
        ,
        [String]
        [parameter(Mandatory = $true)]
        [ValidateLength(1, 1000)] #Max is 4kb so 1000 is playing safe.
        $notificationLongMessage = "text here"
        ,
        [String]
        $notificationSound = 'bird-1'
        ,
        [String]
        $hostURI = 'https://new.boxcar.io/api/notifications' #HOST: This is the server to use to send HTTPS API calls.
        ,
        [String]
        $user_credentials = 'Put Your Access Token Here' #Access Token. Change this value to your own here or specify here.
    )
    
    BEGIN {
        Add-Type -AssemblyName System.Web
    }#begin
    PROCESS {
    
        try {
            $message = Invoke-WebRequest -Uri $hostURI -Method POST -Body "user_credentials=$($user_credentials)&notification[title]=$([System.Web.HttpUtility]::UrlEncode($notificationTitle))&notification[long_message]=$([System.Web.HttpUtility]::UrlEncode($notificationLongMessage))&notification[sound]=$($notificationSound)"
            if ($message.StatusCode -eq 201) {
                "Message Sent:"
                $message.Content | ConvertFrom-Json
            }
        }
    
        catch [System.Net.WebException] {
            Write-Host  -ForegroundColor Red $_.Exception.Message
            switch -regex ($_.Exception.Message) {
                "401" { Write-Host  -ForegroundColor Red "Failure: Check Access Token" }
                "404" { Write-Host  -ForegroundColor Red "Failure: No associated device" }
                "422" { Write-Host  -ForegroundColor Red "Failure: Unprocessable Entity - All non UTF-8 encoding are rejected" }
                default { Write-Host  -ForegroundColor Red $_.Exception.Message }
            }
    
        }
    
        finally {
    
        }
    }#process
    END { }#end
    
}