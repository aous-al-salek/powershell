<#
    .SYNOPSIS
    Gets the names and email addresses of members of a supplied AD group.
    
    .DESCRIPTION
    Gets the names and email addresses of members of a supplied AD group.
    Takes the name of the target groups as a one-word argument.
    Any other arguments are simply ignored.
    If the target group is has a multi-word name (e.g. Research and Development) use "" (i.e. "Research and Development").
    Outputs a CSV file "C:\user_emails.csv" contaiing the name and email address of all users in the target group.

    .INPUTS
    Takes the name of the target groups as a one-word argument.
    Any other arguments are simply ignored.
    If the target group is has a multi-word name (e.g. Research and Development) use "" (i.e. "Research and Development").
    
    .OUTPUTS
    Outputs a CSV file "C:\user_emails.csv" contaiing the name and email address of all users in the target group.
    
    .EXAMPLE
    PS> Get-ADUserEmailAddress example_group
    
    .EXAMPLE
    PS> Get-ADUserEmailAddress Finance
    
    .EXAMPLE
    PS> Get-ADUserEmailAddress
#>

If ($args) {
    # Name of the target group
    $group = $args[0]
}
Else {
    $group = Read-Host "Please enter the name of the target group"
}

# Create a file CSV with column names
"Name,Email" | Out-File -Append C:\user_emails.csv

# Graps members of the target group
$ADUsers = Get-ADGroupMember -Identity $group

# Get the email of earch group member and then append it together with the name to the CSV file
ForEach ($ADUser in $ADUsers) {
    $ADUserEmailAddress = Get-ADUser -Filter {SamAccountName -eq $ADUser.SamAccountName} -Properties EmailAddress
    $ADUserEmailAddress.Name+","+$ADUserEmailAddress.EmailAddress | Out-File -Append C:\user_emails.csv
}

# Inform the user about the output
Write-Host -ForegroundColor Green -BackgroundColor Black "The output information can be found in C:\user_emails.csv"
