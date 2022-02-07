# Git SSH Configurator for Powershell

Are you are tired of manually generating your SSH keys, and starting the ssh agent and adding the public key to it?

Then, this is the script you need.

It will:
1. Generate your SSH public and private keys.
2. Add the necessary OpenSSH commands in your `$profile.CurrentUserCurrentHost` profile file so that each time you start a new Powershell session, your SSH keys are automatically added to OpenSSH agent
3. It will copy your new SSH public key to the clipboard so that you can quickly paste it into your favorite Git registery SSH keys page.
4. And more importantly, you won't remember any of these steps.

You can get more information by invoking `Get-Help ./setup.ps1` in the script folder.

## Examples

`./setup.ps1 -e hello@world.com`

`./setup.ps1 -e hello@world.com -f github_key`

## Parameters

```powershell
param(
#Email address that is used in the SSH Key.
    [Parameter(Mandatory = $true)] [Alias("e")] [string] $Email,
#The SSH public and private key file name that is going be generated. The default is github.
    [Parameter()] [Alias("f")] [string] $KeyFileName = "github"
)
```

## Notes
1. Works in MacOS and Windows
2. Powershell 7.x+ must be installed on the computer.

Developed by [@tarikguney](https://github.com/tarikguney)