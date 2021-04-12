<#
.Synopsis
Wraps PowerShell scripts into a easily clickable Batch file.

.Description
Takes a single PowerShell script and wraps it up in a Batch file that will 
copy itself into the user's Appdata, create & run a ps1 file, then delete 
itself.


#>

function Batchify-PSScript( $ps1File ) {
    $utf8NoBom = New-Object System.Text.UTF8Encoding $False
    $ps1Code = Get-Content "$ps1File"
    $batFile = $ps1File -replace '.ps1','.bat'
    
    $batCode = "@echo off
if `"%username%`"==`"%computername%$`" ( goto :main )
if `"%~dp0`"==`"%localappdata%\`" ( goto :main )
robocopy `"%~dp0 `" `"%localappdata% `" `"%~nx0`" /NFL /NDL /NJH /NJS /NC /NS /NP
C:
cd `"%localappdata%`"
`"%~nx0`"
exit /B
:main
set psscript=$( Split-Path $ps1File -Leaf )
(
"

    for ( $i = 0; $i -lt $ps1Code.Length; $i++ ) {
        if ( $ps1Code[$i] ) {
            $tmp = $ps1Code[$i] -replace '\)','^)'
            $tmp = $tmp -replace '\^\)\"',')"'
            $tmp = $tmp -replace '\|','^|'
            $batCode += "    @echo $tmp`n"
        } else {
            $batCode += "    @echo:`n"
        }
    }

    $batCode += ") > %psscript%
set here=%~dp0
set here=%here:~0,-1%
powershell -ExecutionPolicy Bypass -File ^`"%here%\%psscript% %*^`"
if `"%username%`"==`"%computername%$`" ( goto :EXIT )
start /b `"`" cmd /c del `"%~f0`"&exit /b
:EXIT
exit /B
:EOF"

    [System.IO.File]::WriteAllLines($batFile, $batCode, $utf8NoBom )
}