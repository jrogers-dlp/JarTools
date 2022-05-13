# JarTools
Useful commands I've put together for automating tasks I do all the time


## New-SecurePassword

### SYNOPSIS
Just a quick simple script to generate a new secure password.

### SYNTAX

```
New-SecurePassword [-Length] <String> [<CommonParameters>]
```

### DESCRIPTION
Simple script to generate a new secure password where you only need to specify the length.
The password will be shown using write-host and automatically copied to the clipboard.

### EXAMPLES

#### EXAMPLE 1
```
New-SecurePassword.ps1 -Length 16
```

### PARAMETERS

#### -Length
Enter the password length required.
For example: 16

## New-SSMSession

### SYNOPSIS
Starts a new aws SSM session

### SYNTAX

```
New-SSMSession [-instanceID] <String> [[-localport] <String>] [[-remoteport] <String>] [[-awsprofile] <String>]
 [<CommonParameters>]
```

### DESCRIPTION
Starts a new AWS SSM session from an instanceID

### EXAMPLES

#### Example 1
```powershell
PS C:\> New-SSMSession -instanceID $instanceID -awsprofile $awsprofile
```

### PARAMETERS

#### -instanceID
The ID of the EC2 instance to connect to

#### -localPort
The local port to use for the RDP ssm session. Defaults to 55678

#### -remotePort
The remote port to use for the RDP ssm session. Defaults to 3389

#### -awsprofile
aws cli profile to use. defaults to default

## Connect-EC2Instance

### SYNOPSIS
Wrapper around New-SSMSession to connect using only an instance name

### SYNTAX

```
Connect-EC2Instance [-Name] <String> [[-awsprofile] <String>] [<CommonParameters>]
```

### DESCRIPTION
Wrapper around New-SSMSession to connect using only an instance name. Runs a command to determine instance ID from name, then starts an RDP session.

### EXAMPLES

#### Example 1
```powershell
PS C:\> Connect-EC2Instance -name "PWM" -awsprofile "doubleline"
```

### PARAMETERS

#### -Name
The Name of the EC2 instance to connect to

#### -awsprofile
aws cli profile to use. defaults to default


## Test-IsGitInstalled

### SYNOPSIS
Quick test if git is installed.

### SYNTAX

```
Test-IsGitInstalled [<CommonParameters>]
```

### DESCRIPTION
Quick test if git is installed. Returns true if it is, false if it's not.

### EXAMPLES

#### Example 1
```powershell
PS C:\> Test-IsGitInstalled
```

## Invoke-GitClone

### SYNOPSIS
Wrapper around `git clone` that changes into the directory after cloning.

### SYNTAX

```
Invoke-GitClone [-url] <String> [<CommonParameters>]
```

### DESCRIPTION
Wrapper around `git clone` that changes into the directory after cloning. Also makes sure URL is a valid git repo.

### EXAMPLES

#### Example 1
```powershell
PS C:\> Invoke-GitClone -url "https://github.com/jrogers-dlp/JarTools.git"
```

## Edit-JarTools

### SYNOPSIS
Quickly open code to edit this module

### SYNTAX

```
Edit-JarTools [-file]
```

### DESCRIPTION
Quickly open code to edit this module. You can specify `-file` to only open the module and not the directory.

### EXAMPLES

#### Example 1
```powershell
PS C:\> Edit-JarTools
```

#### Example 2
```powershell
PS C:\> Edit-JarTools -file
```

## Get-MyInvocation

### SYNOPSIS
return the $MyInvocation variable in a function.

### SYNTAX

```
Get-MyInvocation
```

### DESCRIPTION
return the $MyInvocation variable in a function.

### EXAMPLES

#### Example 1
```powershell
PS C:\> Get-MyInvocation
```