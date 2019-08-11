function Get-IPPDU {
    <#
    .NOTES
    Author: John Milner aka jfrmilner
    Blog  : https://jfrmilner.wordpress.com
    Post  : http://wp.me/pFqJZ-5l
    Requires: Powershell V3
    Legal: This script is provided "AS IS" with no warranties or guarantees, and confers no rights. You may use, modify, reproduce, and distribute this script file in any way provided that you agree to give the original author credit.
    Version: v1.0 - 06 Jan 2013
    #>
    param(
        [System.Management.Automation.PSCredential]$Credential,
        $URI = "http://digiboard"
    )
    try {
        $statusXML = Invoke-WebRequest -Uri ($URI + "/status.xml") -Credential $Credential
    }
    catch {
        $_.Exception.Message
        break
    }
    $statusXMLArray = $statusXML.Content.Substring(52, 15)
    #Status Report
    $outlet = 65
    $statusReport = @()
    foreach ($status in ($statusXMLArray -split ",") ) {
        $statusReport += @{$("Outlet" + [char]$outlet) = $status }
        $outlet++
    }
    $statusReport
}
