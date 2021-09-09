##############################################################
####                                                      ####
####          AWS Powershell Cross-Account Auth           ####
####               Authored by: Ryan Payne                ####
####                                                      ####
####    This function allows user to authenticate w/      ####
####      a central Jump Account, then switch roles       ####
####           into a list of target accounts.            ####
####                                                      ####
##############################################################

function Get-Credentials {

    Param ()

    # Set Vars
    $jumpAccount = ""
    $region = ""
    $userName = ""
    $profile = ""
    $roleName = ""
    $accounts =@(
        ""
        ""
    )

    # Authenticate with Stored Profile and MFA
    Set-AWSCredentials -ProfileName $profile
    Set-DefaultAWSRegion -Region $region
    $mfaArn = "arn:aws-us-gov:iam::" + $jumpAccount + ":mfa/" + $userName
    $mfaToken = Read-Host "Please enter your MFA Token"
    $tempCredentials = Get-STSSessionToken -DurationInSeconds 3600 -ProfileName $profile -SerialNumber $mfaArn -TokenCode $mfaToken

    # Build Credential and Invoke Next-Function Per Account
    foreach ($i in $accounts){

        $roleArn = "arn:aws-us-gov:iam::"+ $i + ":role/" + $roleName   
        $credential = (Use-STSRole -RoleArn $roleArn -DurationInSeconds 3600 -RoleSessionName "CAA" -Credential $tempCredentials).Credentials
    
        Next-Function -credential $credential
    }
}

function Next-Function {

    Param (
        $credential
    )

    Set-AWSCredentials -AccessKey $credential.AccessKeyId -SecretKey $credential.SecretAccessKey -SessionToken $credential.SessionToken
    
    <# Insert Code #>
}

Get-Credentials
