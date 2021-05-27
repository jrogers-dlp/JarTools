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
        [Parameter()]
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
        $awsprofile
    )

    if ($awsprofile -ne $null) {
        aws ssm start-session --target $instanceID --document-name AWS-StartPortForwardingSession --parameters "localPortNumber=$localport,portNumber=$remoteport" --profile $awsprofile
    }else {
        aws ssm start-session --target $instanceID --document-name AWS-StartPortForwardingSession --parameters "localPortNumber=$localport,portNumber=$remoteport"
    }

}

function Translate-ImmutableID {
    <#

        converts decimal value of ms-DS-ConsistencyGuid or ObjectGUID to HEX, ImmutableID, DN and GUID-format.

        Parts of this script is built upon blocks from these scripts:
        https://identitydude.com/2015/08/01/dn-value-in-aad-sync-aad-connect-the-new-format/
        https://gallery.technet.microsoft.com/office/Covert-DirSyncMS-Online-5f3563b1


    #>

    #Requires -Version 3

    [CmdletBinding()]

    param (
        [Parameter(Mandatory = $true)]
        [string]$Value
    )

    # identification helper functions

    function isGUID ($data) { 
        try { 	$guid = [GUID]$data 
            return 1 } 
        catch { return 0 } 
    }

    function isBase64 ($data) { 
        try { 	$decodedII = [system.convert]::frombase64string($data) 
                return 1 } 
        catch { return 0 } 
    }

    function isHEX ($data) { 
        try { 	$decodedHEX = "$data" -split ' ' | foreach-object { if ($_) {[System.Convert]::ToByte($_,16)}}
            return 1 } 
        catch { return 0 } 
    }

    function isDN ($data) { 
        If ($data.ToLower().StartsWith("cn=")) {
            return 1 }
        else {	return 0 }
    }

    # conversion functions

    function ConvertIItoDecimal ($data) {
        if (isBase64 $data) {
            $dec=([system.convert]::FromBase64String("$data") | ForEach-Object ToString) -join ' '
            return $dec
        }
    }

    function ConvertIIToHex ($data) {
        if (isBase64 $data) {
            $hex=([system.convert]::FromBase64String("$data") | ForEach-Object ToString X2) -join ' '
            return $hex
        }	
    }

    function ConvertIIToGuid ($data) {
        if (isBase64 $data) {
            $guid=[system.convert]::FromBase64String("$data")
            return [guid]$guid
        }
    }

    function ConvertHexToII ($data) {
        if (isHex $data) {
            $bytearray="$data" -split ' ' | foreach-object { if ($_) {[System.Convert]::ToByte($_,16)}}
            $ImmID=[system.convert]::ToBase64String($bytearray)
            return $ImmID
        }
    }

    function ConvertIIToDN ($data) {
        if (isBase64 $data) {
            $enc = [system.text.encoding]::utf8
            $result = $enc.getbytes($data)
            $dn=$result | foreach { ([convert]::ToString($_,16)) }
            $dn=$dn -join ''
            return $dn
        }
    }

    function ConvertDNtoII ($data) {
        if (isDN $data) {
            $hexstring = $data.replace("CN={","")
            $hexstring = $hexstring.replace("}","")
            $array = @{}
            $array = $hexstring -split "(..)" | ? {$_}
            $ImmID=$array | FOREACH { [CHAR][BYTE]([CONVERT]::ToInt16($_,16))}
            $ImmID=$ImmID -join ''
            return $ImmID
        }
    }

    function ConvertGUIDToII ($data) {
        if (isGUID $data) {
            $guid = [GUID]$data
                $bytearray = $guid.tobytearray()
                $ImmID=[system.convert]::ToBase64String($bytearray)
            return $ImmID
        }
    }

    # from byte string (converted to byte array)
    If ( ($value -replace ' ','') -match "^[\d\.]+$") {
        $bytearray=("$value" -split ' ' | foreach-object {[System.Convert]::ToByte($_)})
        $HEXID=($bytearray| ForEach-Object ToString X2) -join ' '

        $identified="1"
        Write-host ""

        $ImmID=ConvertHexToII $HEXID
        $dn=ConvertIIToDN $ImmID
        $GUIDImmutableID = ConvertIIToGuid $ImmID

        Write-Host "HEX: $HEXID" -foregroundColor Green
        Write-Host "ImmutableID: $ImmID" -foregroundColor Green
        Write-Host "DN: CN={$dn}" -foregroundColor Green
        Write-Host "GUID: $GUIDImmutableID " -foregroundColor Green
    }

    # from hex
    If ($value -match " ") {
        If ( ($value -replace ' ','') -match "^[\d\.]+$") {
            Return
        }
        $identified="1"
        Write-host ""

        $ImmID=ConvertHexToII $value
        $dec=ConvertIItoDecimal $ImmID
        $dn=ConvertIIToDN $ImmID
        $GUIDImmutableID = ConvertIIToGuid $ImmID

        Write-Host "Decimal: $dec" -foregroundColor Green
        Write-Host "ImmutableID: $ImmID" -foregroundColor Green
        Write-Host "DN: CN={$dn}" -foregroundColor Green
        Write-Host "GUID: $GUIDImmutableID " -foregroundColor Green
    }

    # from immutableid
    If ($value.EndsWith("==")) {
        $identified="1"
        Write-host ""

        $dn=ConvertIIToDn $Value	
        $HEXID=ConvertIIToHex $Value
        $GUIDImmutableID = ConvertIIToGuid $Value
        $dec=ConvertIItoDecimal $value

        Write-Host "Decimal: $dec" -foregroundColor Green
        Write-Host "HEX: $HEXID" -foregroundColor Green
        Write-Host "DN: CN={$dn}" -foregroundColor Green
        Write-Host "GUID: $GUIDImmutableID " -foregroundColor Green
    }

    # from  dn
    If ($value.ToLower().StartsWith("cn=")) {
        $identified="1"
        Write-host ""

        $ImmID=ConvertDNToII $Value
        $HEXID=ConvertIIToHex $ImmID
        $GUIDImmutableID = ConvertIIToGuid $ImmID
        $dec=ConvertIItoDecimal $ImmID

        Write-Host "Decimal: $dec" -foregroundColor Green
        Write-Host "ImmutableID: $ImmID" -foregroundColor Green
        Write-Host "HEX: $HEXID" -foregroundColor Green
        Write-Host "GUID: $GUIDImmutableID " -foregroundColor Green
    }

    # from guid
    if ( isGuid $Value) {
        $identified="1"
        Write-host ""

        $ImmID=ConvertGUIDToII $Value
        $dn=ConvertIIToDN $ImmID
        $HEXID=ConvertIIToHex $ImmID
        $dec=ConvertIItoDecimal $ImmID

        Write-Host "Decimal: $dec" -foregroundColor Green
        Write-Host "ImmutableID: $ImmID" -foregroundColor Green
        Write-Host "HEX: $HEXID" -foregroundColor Green
        Write-Host "DN: CN={$dn}" -foregroundColor Green	
    }

    If (-not($identified)) {
        Write-host -fore red "You provided a value that was neither an ImmutableID (ended with ==), a DN (started with CN=), a GUID, a HEX-value nor a Decimal-value, please try again."
    }


}