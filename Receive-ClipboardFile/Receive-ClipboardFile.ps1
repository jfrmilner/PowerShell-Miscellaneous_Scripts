
function Receive-ClipboardFile {
    <#
    .SYNOPSIS
    Receive a File using the Clipboard as transport.
    .EXAMPLE
    #Receive a File using the Clipboard
    Receive-ClipboardFile -Path "C:\Support\ClipboardDemo"

    Receive a File using the Clipboard
    .NOTES
    Author: jfrmilner
    Web  : github.com/jfrmilner
    File Name: Receive-ClipboardFile.ps1
    Requires: Powershell V2
    Legal: This script is provided "AS IS" with no warranties or guarantees, and confers no rights. You may use, modify, reproduce, and distribute this script file in any way provided that you agree to give the original author credit.
    Version: v0.4 - 2022-03-24 - Github Release Version
    #>
    [CmdletBinding()]
    param (
        [parameter(Mandatory, ValueFromPipelineByPropertyName)]
        $Path = $PWD.Path
    )

    begin {
        Write-Host -Object "Receiver Start. Waiting for data Clipboard" -ForegroundColor Yellow
    }#begin
    process {
        $cbArray = @()
        Set-Clipboard "ready"
        do {
            $cb = Get-Clipboard -Raw
            if ($cb -eq "ready") {
                Write-Host "Waiting.."
                Start-Sleep -Seconds 2
            }

            try {
                $dataJSON = ConvertFrom-Json -InputObject $cb -ErrorAction SilentlyContinue

                if ($dataJSON.FileName) {
                    $cbArray += $dataJSON
                    Write-Host $dataJSON.Part -ForegroundColor Cyan
                    Set-Clipboard "ready"
                }
                else {
                    #Write-Error -Message "Non-JSON"
                }
            }
            catch {}
        } until ($cb -eq "end")
    }#process
    end {

        try {
            #Remove Duplicates
            $cbArray = $cbArray | Sort-Object -Property Position -Unique
            #Basic Checks
            $cbArray | Select-Object -Property * -ExcludeProperty Data
            $parts = $cbArray[-1].Part -split "\/" | Select-Object -Skip 1
            if ($cbArray.Count -ne $parts) {
                Write-Error -Message "Missing Parts. Aborting"
            }

            #Part checksum validation with SHA256
            foreach ($part in $cbArray) {
                $part.Data | Out-File -LiteralPath "$env:TEMP\tmp.tmp" -Encoding utf8
                $hashSHA256 = Get-FileHash -LiteralPath "$env:TEMP\tmp.tmp" -Algorithm SHA256
                if ($part.HashSHA256 -ne $hashSHA256.Hash) {
                    Write-Error -Message "Part Checksum Error. Aborting"
                }
            }

            #Rebuild File
            $base64New = New-Object -TypeName System.Text.StringBuilder
            foreach ($part in $cbArray) {
                $base64New.Append($part.Data)
            }
            #Save to Disk
            Set-Content -Value $([System.Convert]::FromBase64String($base64New)) -Encoding Byte -Path $($path + '\' + $dataJSON.FileName)

            #Create SHA256 Hash of saved file
            $hash = Get-FileHash -LiteralPath $($path + '\' + $dataJSON.FileName)
            Write-Host -Object $('Saving File ' + $path + '\' + $dataJSON.FileName + ' - Hash ' + $hash.Hash)
        }
        catch {}

    }#end
}
