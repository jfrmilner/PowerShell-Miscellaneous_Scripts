function Send-ArduinoSerial {
    param ( [parameter(Mandatory = $true, ValueFromPipeline = $true)] [int[]] $byte )
    #Find Arduino COM Port
    $PortName = (Get-WmiObject Win32_SerialPort | Where-Object { $_.Name -match "Arduino" }).DeviceID
    if ( $PortName -eq $null ) { throw "Arduino Not Found" }
    #Create SerialPort and Configure
    $port = New-Object System.IO.Ports.SerialPort
    $port.PortName = $PortName
    $port.BaudRate = "9600"
    $port.Parity = "None"
    $port.DataBits = 8
    $port.StopBits = 1
    $port.ReadTimeout = 2000 #Milliseconds
    $port.open() #open serial connection
    Start-Sleep -Milliseconds 100 #wait 0.1 seconds
    $port.Write($byte) #write $byte parameter content to the serial connection
    try {
        #Check for response
        if (($response = $port.ReadLine()) -gt 0)
        { $response }
    }
    catch [TimeoutException] {
        "Time Out"
    }
    finally {
        $port.Close() #close serial connection
    }
}
