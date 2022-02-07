<#
.DESCRIPTION
    Author: Tarik Guney
    Date:   June 28, 2010    
#>
param(
#Email address that is used in the SSH Key.
    [Parameter(Mandatory = $true)] [Alias("e")] [string] $Email,
#The SSH public and private key file name that is going be generated. The default is github.
    [Parameter()] [Alias("f")] [string] $KeyFileName = "github"
)

$currentOs = [System.Environment]::OSVersion.Platform

function Generate-SSHKeys($homePath)
{
    Write-Host $homePath
    $sshKeyLocation = $homePath.SSHKeyLocation
    $sshKeyFilePath = $homePath.SSHKeyFilePath
    Write-Host $sshKeyFilePath
    
    Write-Host "SSH Keys location $sshKeyLocation" -ForegroundColor "Green"
    if ($( Test-Path "$sshKeyFilePath" ) -eq $true)
    {
        Write-Host "$sshKeyLocation does exist. Do you want to overwrite it? (Y/N)" -ForegroundColor "Red"
        $prompt = Read-Host
        if ($prompt.ToLower() -eq "y")
        {
            write-output "y" | ssh-keygen -t rsa -b 4096 -C "$Email" -f "$sshKeyFilePath" -N "" -P "" | Write-Host -ForegroundColor "Yellow"
        }
    }
    else
    {
        ssh-keygen -t rsa -b 4096 -C "$Email" -f "$sshKeyFilePath" -N "" -P "" | Write-Host -ForegroundColor "Yellow"
    }

    $pubContent = Get-Content -Path $sshKeyFilePath

    Write-Host "The new public key is copied to your clipboard. You can paste it to your Git registery's SSH key repository."`
        -ForegroundColor "Green"
    Set-Clipboard $pubContent
}

function Append-WindowsSSHConfig($filePath){
    $profile = @"
`nSet-Service ssh-agent -StartupType Automatic
Start-Service ssh-agent
ssh-add "$filePath" *> `$null 
"@
    
    Add-Content -Path $global:Profile.CurrentUserCurrentHost -Value ($profile)
    
    Write-Host "SSH Agent key addition is added to your profile at $($global:Profile.CurrentUserCurrentHost)"`
        -ForegroundColor "Cyan"
}

function Append-MacSShConfig($filePath){
    $profile = @"
`nssh-agent -s *> `$null
ssh-add -K "$filePath" *> `$null
"@
    Add-Content -Path $global:Profile.CurrentUserCurrentHost -Value ($profile)

    Write-Host "SSH Agent key addition is added to your profile at $($global:Profile.CurrentUserCurrentHost)"`
        -ForegroundColor "Cyan"
}

Write-Host "Detected OS is $currentOs"

if ($currentOs -eq "Unix")
{
    $paths = @{}
    $paths.SSHKeyLocation = $env:HOME + "/.ssh"
    $paths.SSHKeyFilePath = "$($paths.SSHKeyLocation)/$KeyFileName"
    Generate-SSHKeys($paths)
    Append-MacSShConfig($paths.SSHKeyFilePath)
}
elseif ($currentOs -eq "Win32NT")
{
    $paths = @{}
    $paths.SSHKeyLocation = $env:HOMEPATH + "/.ssh"
    $paths.SSHKeyFilePath = "$($paths.SSHKeyLocation)/$KeyFileName"
    Generate-SSHKeys($paths)
    Append-WindowsSSHConfig($paths.SSHKeyFilePath)
}
