# Gets all IPv4 leases in all scopes.
ForEach ($scope in Get-DHCPServerv4scope | Select ScopeId) {
    echo "Here are all the active leses in the scope $scope"
    Get-DhcpServerv4Lease -ScopeId $scope.ScopeId | Where {$_.AddressState -eq "Active"} `
    | Select-Object IPAddress, ScopeID, HostName, LeaseExpiryTime | Sort-Object LeaseExpiryTime –Descending
}

echo `n

# Lists all free IPv4 addresses in all scopes.
ForEach ($scope in Get-DHCPServerv4scope | Select ScopeId) {
    echo "Here are all the free IPv4 addresses in the scope $scope"
    Get-DhcpServerv4FreeIPAddress -ScopeId $scope.ScopeId -NumAddress 1024 -WarningAction SilentlyContinue
}

echo `n

# Ask the user to convert an active lease into a static reservatio.
$uanswer = Read-Host "Do you want to convert an active leases into a static reservation? (yes/no)"
# Ensures that the user types in one of the allowed answers.
While ("yes", "no" -notcontains $uanswer) {
    $uanswer = Read-Host "Enter a valid answer, please. (yes/no)"
}

If ($uanswer -eq "yes") { # If the user wants to convert a lease.
    Do { # Do-While loop to do the conversion.
        # Ask the users for parameters.
        $uscopeid = Read-Host "Type in the scope ID in which the IP-address exests. (000.000.000.000)"
        $uipaddress = Read-Host "Type in the IP-address. (000.000.000.000)"
        $uclientid = Read-Host "Type in the client ID to be assigned the reservation. (A0-A0-A0-A0-A0-A0)"
        $udescription = Read-Host "Type in a description. (free text)"
        # Tries to convert the lease.
        Try {
            Add-DhcpServerv4Reservation -ScopeId $uscopeid -IPAddress $uipaddress -ClientId $uclientid `
            -Description $udescription
        }
        # If the conversion fails, it tells the user and asks them again.
        Catch {
            $uanswer2 = Read-Host "Something went wrong! Do you want to try again? (yes/no)"
            While ("yes", "no" -notcontains $uanswer2) {
                $uanswer2 = Read-Host "Enter a valid answer, please. (yes/no)"
            }
        }
    } While ($uanswer2 -eq "yes")
}

# Excludes all the reserved IP-addresses from all scopes.
ForEach ($scope in Get-DHCPServerv4scope | Select ScopeId) {
    Get-DhcpServerv4Reservation -ScopeId $scope.ScopeId | ForEach-Object {
        Add-DhcpServerv4ExclusionRange -ScopeId $scope.ScopeId -StartRange $_.IPAddress -EndRange $_.IPAddress
    }
}
