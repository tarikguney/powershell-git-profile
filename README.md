# Git SSH Configurator for Powershell

![](./git-ssh-configurator-banner.jpg)

Are you are tired of manually generating your public and private keys and starting the ssh agent and adding the private key to it each time you use remote Git repositories with SSH authentication?

Then, this is the script you need.

It will:
1. Generate your SSH public and private keys.
2. Add the necessary OpenSSH commands in your `$profile.CurrentUserCurrentHost` profile file so that each time you start a new Powershell session, your private SSH key are automatically added to OpenSSH agent.
3. It will copy your new SSH public key to the clipboard so that you can quickly paste it into your favorite Git registry SSH keys page (e.g. Github).
4. And more importantly, you won't have to remember any of these steps.

You can get more information by invoking `Get-Help ./setup.ps1` in the script folder.

## Examples

`./setup.ps1 -e hello@world.com`

`./setup.ps1 -e hello@world.com -f github_key`

For all examples, run:

`Get-Help ./setup.ps1 -Examples`

## Parameters

```
-Email <String> (Alias: -e)
Email address that is used in the SSH Key.

-KeyFileName <String> (Alias: -f)
The SSH public and private key file name that is going be generated. The default is github.

<CommonParameters>
This cmdlet supports the common parameters: Verbose, Debug,
ErrorAction, ErrorVariable, WarningAction, WarningVariable,
OutBuffer, PipelineVariable, and OutVariable. For more information, see
about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).
```

To see the parameter information, run:

`Get-Help ./setup.ps1 -Detailed`

## Notes
1. Works in MacOS and Windows
2. Powershell 7.x+ must be installed on the computer.

## Troubleshooting

If you are getting the following error even though you added your public key to your Git registery's SSH Keys:

```
Cloning into 'repository-name'...
Warning: Identity file /c/Users/Tarik Guney/.ssh/github not accessible: No such file or directory.
Warning: Permanently added 'bitbucket.org' (RSA) to the list of known hosts.
git@bitbucket.org: Permission denied (publickey).
fatal: Could not read from remote repository.

Please make sure you have the correct access rights
and the repository exists.
```

Then you are most likely using more than one keys. Follow the steps below:

1. If not exist, create a `config` file in `~/.ssh` folder.
2. Add the following code (adjust for your own needs):

```
Host github.com
    Hostname github.com
    IdentityFile ~/.ssh/github_beast
    IdentitiesOnly yes

Host bitbucket.org
    Hostname bitbucket.org
    IdentityFile ~/.ssh/atlassian
    IdentitiesOnly yes
```

If you want to see which public and private key are used for which host (bitbucket.org or github.com, etc.), then run the following commands:

```
$env:GIT_SSH_COMMAND = "ssh -vvv"
git clone your-remote-repo
```

Developed by [@tarikguney](https://github.com/tarikguney)