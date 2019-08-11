function Set-IPPDU {
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
        [Parameter(Mandatory = $true)]
        [ValidatePattern("[A-H]{1,8}")]
        [array]$Outlets,
        [ValidateSet("On", "Off")] $PowerState,
        $URI = "http://digiboard",
        [System.Management.Automation.PSCredential]$Credential
    )
    $outletKeys = [PSCustomObject][Ordered]@{A = 0; B = 1; C = 2; D = 3; E = 4; F = 5; G = 6; H = 7 }
    $statusKeys = [PSCustomObject][Ordered]@{ON = 1; OFF = 0 }
     
    $charArray = ("00000000").ToCharArray()
    foreach ($request in $outlets ) {
        $charArray[($outletKeys.($request))] = "1"
        "Turn {0} {1}" -f $request, $powerState
    }
    $stateString = -join $charArray
    $URI = ($URI + "/" + $powerState.ToLower() + "s.cgi?led=" + $stateString + "0000000000000000")
    Invoke-WebRequest $URI -Credential $Credential | Out-Null
}
