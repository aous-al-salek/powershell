Import-Module ActiveDirectory# If an argument is given on script invocation it would be used as a path to import a csv file. Else the user will be asked to provide one.If ($args)
{
    $newusers = Import-Csv -Path $args -Delimiter ';' -Encoding UTF7 -EA Stop -EV x
} 
Else
{
    $file = Read-Host -Prompt "Please enter the path to the .CSV new users file!"    $newusers = Import-Csv -Path "$file" -Delimiter ';' -Encoding UTF7
}# Tries to test if a path exists, and if it does not then it will create a folder and let the user know.Try {    $temp = Test-Path "C:\SHARES\IT\Accounts"}Catch {}If (!($temp)) {    New-Item -Path "C:\SHARES\IT\" -Name "Accounts" -ItemType "directory"}# Gets all the OUs in the domain except for one and looks for the users in them, then gets the group memberships of these users except for one group and empties the groups from any memebers.ForEach ($ou in Get-ADOrganizationalUnit -Filter "*" | where {$_.Name -ne "Domain Controllers"}) {    ForEach ($user in Get-ADUser -Filter "*" -SearchBase $ou) {        $groups = Get-ADPrincipalGroupMembership -Identity $user | where {$_.Name -ne "Domain Users"}        if ($groups -ne $null) {            Remove-ADPrincipalGroupMembership -Identity $user -MemberOf $groups -Server "example.com" -Confirm:$false        }    }}# Adds the existing users to the role groups that correspond to thier OUs.ForEach ($ou in Get-ADOrganizationalUnit -Filter "*" | where {$_.Name -ne "Domain Controllers"}) {    ForEach ($user in Get-ADUser -Filter "*" -SearchBase $ou) {        Add-ADGroupMember -Identity $ou.Name -Members $user    }}    # A loop through the lines of the imported CSV file.ForEach ($line in $newusers) {    # Get a value from the "Name" column in the csv file.    $name = $line.Name    # Split that name.    $Names = $name.split(" ")    # Use the first part as a first name.    $firstname = $Names[0]    # Use the second part as a last name.    $lastname = $Names[1]    # Create a username and change (ä, ö, å) with (a, o, a).    $username = $firstname.substring(0,2).ToLower()+$lastname.substring(0,2).ToLower()    $username = $username -replace ("å", 'a')    $username = $username -replace ("ä", 'a')    $username = $username -replace ("ö", 'o')    # Generate a password.    $genedpasswd1 = ([char[]]([char]65..[char]90) + [char[]]([char]97..[char]122) | sort {Get-Random})[0..5] -join ''
    $genedpasswd2 = ([char[]]([char]63..[char]64) + [char[]]([char]33..[char]38) + [char[]]([char]42..[char]45) | sort {Get-Random})[0..2] -join ''
    $genedpasswd3 = (0..11 | sort {Get-Random})[0..2] -join ''
    $genedpasswd = $genedpasswd1 + $genedpasswd2 + $genedpasswd3    $department = $line.Department    $path = "OU="+$department+",DC=example,DC=com"        $email = $line.Email    $description = $line.Description    $passcardnumber = $line.PassCardNumber
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