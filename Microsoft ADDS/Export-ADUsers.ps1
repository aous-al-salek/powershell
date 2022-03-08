<#
    .SYNOPSIS
    Gets the names, email addresses, and statuses of members of a supplied AD group or OU.
    
    .DESCRIPTION
    Gets the names, email addresses, and statuses of members of a supplied AD group or OU.
    Interactive menus take the choice of acition and name of the target group or OU.
    Any arguments simplied during invocation are ignored.
    If an input contains whitespaces (e.g. Research and Development) use quotation marks "" (i.e. "Research and Development").
    Outputs a CSV file contaiing the names, email addresses, and statuses of all users in the target group or OU.

    .INPUTS
    None during invocation.
    However, interactive menues during runtime will ask for choices.
    
    .OUTPUTS
    Outputs a CSV file contaiing the names, email addresses, and statuses of all users in the target group or OU.
    
    .EXAMPLE
    PS> Export-ADUsers
#>

# Asks for action choice
$Menu = Read-Host "What do you want to do?
1- Export the users of a group
2- Export the users of an OU
Type in a number please"

If ($Menu -eq 1) {
    #$Group = "testgroup"
    $Group = Read-Host "Please input the name of the group"
    # Graps members of the target group
    $ADUsers = Get-ADGroupMember -Identity $Group
}

ElseIf ($Menu -eq 2) {
    #$OU = "OU=Users,OU=KEPOU,DC=test,DC=local"
    $OU = Read-Host "Please input the absolut path of the OU"
    # Graps members of the target group OU
    $ADUsers = Get-ADUser -Filter * -SearchBase $OU
}

Else {
    # Inform the user about the error and exists
    Write-Host -ForegroundColor Red -BackgroundColor Black "Something went wrong. Check your input!"
    Break Script
}

#$OutFile = "C:\Users\Administrator\Desktop\users.csv"
$OutFile = Read-Host "Please input the name and absolute path of the output file (int this format 'C:\users.csv')"

# Create a file CSV with column names
"Name,Email,Enabled" | Out-File -Append $OutFile

# Get the email of earch group member and then append it together with the name to the CSV file
ForEach ($ADUser in $ADUsers) {
    $ADUserEmailAddress = Get-ADUser -Filter {SamAccountName -eq $ADUser.SamAccountName} -Properties EmailAddress
    $ADUserEmailAddress.Name+","+$ADUserEmailAddress.EmailAddress+","+$ADUserEmailAddress.Enabled | Out-File -Append $OutFile
}

# Inform the user about the output
Write-Host -ForegroundColor Green -BackgroundColor Black "The output information can be found in" $OutFile
