function New-SecurePassword {

<# 
.SYNOPSIS
 Just a quick simple script to generate a new secure password.

.DESCRIPTION
 Simple script to generate a new secure password where you only need to specify the length.
 The password will be shown using write-host and automatically copied to the clipboard.

.PARAMETER Length
 Enter the password length required.
 For example: 16

.EXAMPLE
 New-SecurePassword.ps1 -Length 16


#>

    param(
        [Parameter(mandatory=$true)]
        [string] $Length
    )

    try{
        $Password = ([char[]]([char]33..[char]95) + ([char[]]([char]97..[char]126)) | Sort-Object {Get-Random})[0..($Length-1)] -join ''
        write-host "The password $($Password) has been copied to the clipboard" -ForegroundColor Green
        Set-Clipboard -Value $Password
    }
    catch{
        write-host "Error occurred: $($_.Exception.Message)" -foregroundcolor red
    }
}

function New-SSMSession {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $instanceID,

        [Parameter()]
        [string]
        $localport = "55678",
        [Parameter()]
        [string]
        $remoteport = "3389",
        [Parameter()]
        [string]
        $awsprofile = "default"
    )

    aws ssm start-session --target $instanceID --document-name AWS-StartPortForwardingSession --parameters "localPortNumber=$localport,portNumber=$remoteport" --profile $awsprofile

}

function Connect-EC2Instance {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $Name,

        [Parameter()]
        [string]
        $awsprofile = "default"
    )
    $instanceID = (Get-EC2Tag -Filter @{Name="tag:Name";Values="$Name"} -profileName $awsprofile).ResourceId | Where {$_ -like "i-*"}
    mstsc /v:localhost:55678
    New-SSMSession -instanceID $instanceID -awsprofile $awsprofile
}

function Test-IsGitInstalled {
    try
    {
        git | Out-Null
    return $true
    }
    catch [System.Management.Automation.CommandNotFoundException]
    {
        return $false
    }
    
}

function Invoke-GitClone {
    param(
        [Parameter(Mandatory = $true)]
        [string]
        $url
    )
    $gitExt = $url.substring($url.length - 4, 4)
    if($gitExt -eq ".git"){
        $splits = $url -Split "/"
        $repo = $splits[$splits.Count-1].Replace(".git","")
        if (Test-IsGitInstalled) {
            git clone $url
            if (Test-Path "./$repo") {
                Set-Location "./$repo"
            }else{
                Write-Error "Repository was not cloned correctly."
            }
        }
        
        
    }else{
        Write-Error "$url is not a valid git URL"
    }
}

function Edit-JarTools {
    param(
        [switch]$file
    )
    if(!$jartools){
        $module = Get-Module JarTools
        $moduleFile = $module.Path
        $moduleDir = $moduleFile.replace("\$($module.Name).psm1","")
    }
    if($file){
        code $moduleFile
    }else{
        code $moduleDir
    }
}

function Get-MyInvocation {
    #$name = $MyInvocation.MyCommand.Name
    $name = $MyInvocation
    return $name
}

Set-Alias -Name igc -Value Invoke-GitClone
Set-Alias -Name newssm -Value New-SSMSession
Set-Alias -Name ejt -Value Edit-JarTools
Export-ModuleMember -Alias * -Function *
