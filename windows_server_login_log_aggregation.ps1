﻿# Gets all users in the active directory.
ForEach ($ou in Get-ADOrganizationalUnit -Filter "*" | where {$_.Name -ne "Domain Controllers"}) {

# Initiates a hashtable.
$succeeded = @{}
# Graps all the security events with the id 4768.
$events = Get-WinEvent -FilterHashtable @{Logname='Security'; id=4768}
# Loops through the events.
ForEach ($event in $events) {
    # Gets the raw XML of each event.
    $eventxml = [xml]$event[0].ToXml()
    # Selects the username from the event's content.
    $eventxml.SelectSingleNode("//*[@Name='TargetUserName']").'#text' | Where-Object {$adusers -ccontains $_} | `
        Try {
            $succeeded[$_]++
        } 
        Catch {
            $succeeded.Add($_,1)
        }
    }
}
# Prints out the contents of the hashtable.
echo "Number of successful authentications per user: `n"
$succeeded
echo ""


# Initiates a hashtable.
$failed = @{}
    # Loops through the filtered events.
    ForEach-Object{ 
        # Gets the raw XML of each event.
        $eventxml = [xml]$_[0].ToXml()
echo ""


# Gets the users who only sucseeded.
$onlysucceeded = @{}
ForEach ($sk in $succeeded.Keys) {
    If ($failed.Keys -notcontains $sk) {
        $onlysucceeded.Add($sk,$succeeded[$sk])
    }
}
echo "Users who have had only successful authentications: `n"
$onlysucceeded.Keys
echo ""


# Gets the users who only failed.
$onlyfailed = @{}
ForEach ($fk in $failed.Keys) {
    If ($succeeded.Keys -notcontains $fk) {
        $onlyfailed.Add($fk,$failed[$fk])
    }
}
echo "Users who have had only failed authentications: `n"
$onlyfailed.Keys
echo ""


# Gets the percentage of failed logins per user.
ForEach ($k in $failed.Keys) {
    If ($onlyfailed.Keys -notcontains $k) {
        $total = $succeeded[$k] + $failed[$k]
        $percentage = $failed[$k] * 100 / $total
        $rounded = [math]::Round($percentage,2)
        echo "The user $k have tried to authenticate $total times and failed $rounded% of the time. `n"
    }
}