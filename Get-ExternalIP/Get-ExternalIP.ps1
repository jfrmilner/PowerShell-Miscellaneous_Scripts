function Get-ExternalIP {
    (Invoke-WebRequest ifconfig.me/ip).Content
}
