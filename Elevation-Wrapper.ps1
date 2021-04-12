### Elevation Wrapper ###

if ( ! $( New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator ) ) {
    try {
        Start-Process "powershell" -Verb runAs -ErrorAction SilentlyContinue -ArgumentList " -ExecutionPolicy Bypass -file $($MyInvocation.MyCommand.Source)"
    } catch {
        Remove-Item "$($MyInvocation.MyCommand.Source)"; exit
    }
} else {
    main
    Remove-Item "$($MyInvocation.MyCommand.Source)"; exit
}