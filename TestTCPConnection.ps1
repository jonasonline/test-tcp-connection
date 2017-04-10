[CmdletBinding()]
Param(
    [string]$ServerName,
    $Port = 135,
    $Timeout = 3000,
    $Count = 0,
    $WaitFor = 1000
)

function TestTcpConnection {
    $Error.Clear()
    $response = [pscustomobject]@{Timestamp = $(Get-Date); Timeout = $false; Success = $true; ResponseTimeInMilliseconds = $null}
    $response.Timeout = $false
    $response.Success = $true
    $tcpclient = New-Object system.Net.Sockets.TcpClient
    $stopwatch = New-Object System.Diagnostics.Stopwatch
    $stopwatch.Start()
    $tcpConnection = $tcpclient.BeginConnect($ServerName, $Port, $null, $null)
    $ConnectionSucceeded = $tcpConnection.AsyncWaitHandle.WaitOne($Timeout, $false)
    $stopwatch.Stop()
    $response.ResponseTimeInMilliseconds = $stopwatch.Elapsed.TotalMilliseconds
    if (!$ConnectionSucceeded) {
        $tcpclient.Close()
        $response.Timeout = $true
        $response.Success = $false
        $response.Timestamp = $(Get-Date)
    }
    else {
        $tcpclient.EndConnect($tcpConnection) | out-Null
        $tcpclient.Close()
        $response.Timestamp = $(Get-Date)
    }
    If ($Error) {
        Return
    }
    Return $response
}
if ($Count -eq 0) {
    while (1 -eq 1) {
        TestTcpConnection
        Start-Sleep -m $WaitFor
    }
}
else {
    for ($i = 0; $i -le $Count; $i++) {
        TestTcpConnection
        Start-Sleep -m $WaitFor
    }
}