<#
.DESCRIPTION
    This script will:
    1.Generate your SSH public and private keys.
    2. Add the necessary OpenSSH commands in your $profile.CurrentUserCurrentHost profile file so that each time you start a new Powershell session, your private SSH key are automatically added to OpenSSH agent.
    3. It will copy your new SSH public key to the clipboard so that you can quickly paste it into your favorite Git registry SSH keys page (e.g. Github).
    4. And more importantly, you won't have to remember any of these steps.
    
    Author: Tarik Guney
    Date:   June 28, 2010 
.EXAMPLE
     ./setup.ps1 -e hello@world.com
     The default value for -f is github
 .EXAMPLE
     ./setup.ps1 -e hello@world.com -f my_key
 .LINK
    For more and up-to-date help: https://github.com/tarikguney/powershell-git-profile#readme
#>
param(
#Email address that is used in the SSH Key. Alias: -e
    [Parameter(Mandatory = $true)] [Alias("e")] [string] $Email,
#The SSH public and private key file name that is going be generated. The default is github. Alias: -f
    [Parameter()] [Alias("f")] [string] $KeyFileName = "github"
)

$currentOs = [System.Environment]::OSVersion.Platform

function Generate-SSHKeys($homePath)
{
    Write-Host $homePath
    $sshKeyLocation = $homePath.SSHKeyLocation
    $sshKeyFilePath = $homePath.SSHKeyFilePath
    $sshKeyPubFilePath = $sshKeyFilePath + ".pub"
    Write-Host $sshKeyFilePath

    Write-Host "SSH Keys location $sshKeyLocation" -ForegroundColor "Green"
    if ($( Test-Path "$sshKeyFilePath" ) -eq $true)
    {
        Write-Host "$sshKeyLocation does exist. Do you want to overwrite it? (Y/N)" -ForegroundColor "Red"
        $prompt = Read-Host
        if ($prompt.ToLower() -eq "y")
        {
            write-output "y" | ssh-keygen -t rsa -b 4096 -C "$Email" -f "$sshKeyFilePath" -N '""' | Write-Host -ForegroundColor "Yellow"
        }
    }
    else
    {
        ssh-keygen -t rsa -b 4096 -C "$Email" -f "$sshKeyFilePath" -N '""' | Write-Host -ForegroundColor "Yellow"
    }

    $pubContent = Get-Content -Path $sshKeyPubFilePath

    Write-Host "The new public key ($sshKeyPubFilePath) is copied to your clipboard. You can paste it to your Git registery's SSH key repository."`
        -ForegroundColor "Green"
    Set-Clipboard $pubContent
}

function Append-WindowsSSHConfig($filePath)
{
    $profileContent = Get-Content $global:Profile.CurrentUserCurrentHost -Raw
    $profile = ""
    if ( $profileContent.Contains("Set-Service ssh-agent"))
    {
        $profile = @"
ssh-add "$filePath" *> `$null
"@
    }
    else
    {
        $profile = @"
`nSet-Service ssh-agent -StartupType Automatic
Start-Service ssh-agent
ssh-add "$filePath" *> `$null 
"@
    }

    Add-Content -Path $global:Profile.CurrentUserCurrentHost -Value ($profile)

    Write-Host "SSH Agent key addition is added to your profile at $( $global:Profile.CurrentUserCurrentHost )"`
        -ForegroundColor "Cyan"
}

function Append-MacSShConfig($filePath)
{
    $profileContent = Get-Content $global:Profile.CurrentUserCurrentHost -Raw
    $profile = ""
    if ($profileContent.Contains("ssh-agent -s"))
    {
        $profile = @"
ssh-add -K "$filePath" *> `$null
"@
    }
    else
    {
        $profile = @"
`nssh-agent -s *> `$null
ssh-add -K "$filePath" *> `$null
"@
    }

    Add-Content -Path $global:Profile.CurrentUserCurrentHost -Value ($profile)

    Write-Host "SSH Agent key addition is added to your profile at $( $global:Profile.CurrentUserCurrentHost )"`
        -ForegroundColor "Cyan"
}

Write-Host "Detected OS is $currentOs"

if ($currentOs -eq "Unix")
{
    $paths = @{ }
    $paths.SSHKeyLocation = $env:HOME + "/.ssh"
    $paths.SSHKeyFilePath = "$( $paths.SSHKeyLocation )/$KeyFileName"
    Generate-SSHKeys($paths)
    Append-MacSShConfig($paths.SSHKeyFilePath)
}
elseif ($currentOs -eq "Win32NT")
{
    $paths = @{ }
    $paths.SSHKeyLocation = $env:HOMEPATH + "/.ssh"
    $paths.SSHKeyFilePath = "$( $paths.SSHKeyLocation )/$KeyFileName"
    Generate-SSHKeys($paths)
    Append-WindowsSSHConfig($paths.SSHKeyFilePath)
}
