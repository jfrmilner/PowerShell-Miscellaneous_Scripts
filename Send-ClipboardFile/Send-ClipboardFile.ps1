function Send-ClipboardFile {
    <#
    .SYNOPSIS
    Send a File using the Clipboard as transport.
    .EXAMPLE
    #Send a File Test.zip using the Clipboard at 150KB increments
    Send-ClipboardFile -FilePath Test.zip -BufferSize 150KB

    Send a File Test.zip using the Clipboard at 150KB increments
    .NOTES
    Author: jfrmilner
    Web  : https://github.com/jfrmilner/PowerShell-Miscellaneous_Scripts/blob/master/Send-ClipboardFile/Send-ClipboardFile.ps1
    File Name: Send-ClipboardFile.ps1
    Requires: Powershell V2
    Legal: This script is provided "AS IS" with no warranties or guarantees, and confers no rights. You may use, modify, reproduce, and distribute this script file in any way provided that you agree to give the original author credit.
    Version: v0.4 - 2022-03-24 - Github Release Version
    #>
    [CmdletBinding()]
    param (
        [parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateScript({ Test-Path $_ -PathType 'Leaf' })]
        $FilePath,
        [Int]
        $BufferSize = 150KB
    )

    begin {
        $filePath = Get-ChildItem -Path $FilePath
        $hash = Get-FileHash -LiteralPath $FilePath
        Write-Host -Object $('Sending File ' + $FilePath + ' - Size(MB):' + [Math]::Round(($filePath.Length / 1MB),2) + ' - Hash ' + $hash.Hash) -ForegroundColor Green
    }#begin
    process {
        $file = [io.file]::OpenRead($filePath.FullName)
        $buff = New-Object Byte[] $BufferSize
        $parts = [math]::Ceiling($file.Length / $BufferSize)
        $i = 1
        do {
            $part = ($i.ToString() + "/" + $parts.ToString())
            Write-Host -Object $part
            $i++
            #do {
            Start-Sleep -Seconds 2
            Write-Host "Sleeping.."
            # } until ((Get-Clipboard) -eq "ready")
            $position = $file.Position
            if (($file.Position + $buff.Length) -lt $file.Length) {
                $read = $buff.Length
                $file.Read($buff, 0, $read) | Out-Null
                $data = [System.Convert]::ToBase64String($buff[0..($read - 1)])
                $data | Out-File -LiteralPath "$env:TEMP\tmp.tmp" -Encoding utf8
                $hashSHA256 = Get-FileHash -LiteralPath "$env:TEMP\tmp.tmp" -Algorithm SHA256
                $dataHT = @{
                    "FileName"   = $filePath.Name
                    "Position"   = $position
                    "Part"       = $part
                    "HashSHA256" = $hashSHA256.Hash
                    "Data"       = $data
                }
            }
            else {
                $read = $file.Length - $file.Position
                $file.Read($buff, 0, $read) | Out-Null
                $data = [System.Convert]::ToBase64String($buff[0..($read - 1)])
                $data | Out-File -LiteralPath "$env:TEMP\tmp.tmp" -Encoding utf8
                $hashSHA256 = Get-FileHash -LiteralPath "$env:TEMP\tmp.tmp" -Algorithm SHA256
                $dataHT = @{
                    "FileName"   = $filePath.Name
                    "Position"   = $position
                    "Part"       = $part
                    "HashSHA256" = $hashSHA256.Hash
                    "Data"       = $data
                }
            }
            $dataJSON = $dataHT | ConvertTo-Json -Compress
            Set-Clipboard $dataJSON

        } until ($file.Position -eq $file.Length)
        $file.Close()

    }#process
    end {
        #do {
        Start-Sleep -Seconds 3
        Write-Host "Sleeping.."
        #} until ((Get-Clipboard) -eq "ready")
        Set-Clipboard -Value "end"
        Write-Host -Object "Send Complete"
    }#end
}

