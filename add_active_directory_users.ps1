﻿Import-Module ActiveDirectory
{
    $newusers = Import-Csv -Path $args -Delimiter ';' -Encoding UTF7 -EA Stop -EV x
} 
Else
{
    $file = Read-Host -Prompt "Please enter the path to the .CSV new users file!"
}
    $genedpasswd2 = ([char[]]([char]63..[char]64) + [char[]]([char]33..[char]38) + [char[]]([char]42..[char]45) | sort {Get-Random})[0..2] -join ''
    $genedpasswd3 = (0..11 | sort {Get-Random})[0..2] -join ''
    $genedpasswd = $genedpasswd1 + $genedpasswd2 + $genedpasswd3
    # Initiate a variable of the type intiger.
    $n = 1
    $sam = $username
    $nam = $name

    # Makes sure that the username is not already taken.
    While (Get-ADUser -F {SamAccountName -eq $sam})
    {
        $n++
        $sam = $username + $n
        $nam = $name + $n
    }
    
    # Create files with users credentiales.
    Add-Content C:\SHARES\IT\Accounts\$sam.txt "Login credentials for $name", "The usename is $sam.", "The password is $genedpasswd"

    # Ensures that the required OUs exist.
    If (Get-ADOrganizationalUnit -Filter {Name -eq $department}) {
        Set-ADOrganizationalUnit -Identity $path -ProtectedFromAccidentalDeletion $false
    }
    Else {
        New-ADOrganizationalUnit -Name $department -Path "DC=example,DC=com" -ProtectedFromAccidentalDeletion $false
    }

    # Add the user.
    New-ADUser -Name $nam -DisplayName $nam -GivenName $firstname -Surname $lastname -UserPrincipalName $sam"@example.com" `
    -SamAccountName $sam -Department $department -EmailAddress $email -Description $description -Path $path `
    -AccountPassword (ConvertTo-SecureString -AsPlainText $genedpasswd -Force) `
    -PasswordNeverExpires $false -ChangePasswordAtLogon $true -Enabled $true
    
    # Set the pass catd number under the attribute comment.
    Set-ADUser $sam -replace @{Comment = "Pass Card Number: " + $passcardnumber}
    
    # Ensure that the required role groups exist.
    Try {
        $temp = Get-ADGroup -Identity $department
    }
    Catch {
        New-ADGroup -GroupScope "Global" -Name $department -Path "OU=RoleGroups,DC=example,DC=com"
    }
    # Add users to role groups.
    Add-ADGroupMember -Identity $department -Members $sam
}