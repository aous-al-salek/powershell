# Script for ceating a switch in vmware vsphere with various parameters.

# This script includes a usage switch, which displays short information on how the script
# can be used.

# This script includes a man switch which displays a detailed view of what the script
# does and which areguments can be used during invokation with their respective functions.

# Defining infokation input parameters with data typs, some of
# which have defaults so that the user doesn't have to unse them 
# in case they are not necessary to customize.
# Error handling is done by leverging the built in error handling
# function in param(), which detects worg data typs depending on
# pre-defined data types and prints out an error to the user.
param ([string] $VSName, [string] $PortGroup,  [string] $VMHost2, [int] $NumPorts = 8, `
[string] $Nic = '', [int] $Mtu = '1500', [switch] $Usage, `
[string] $Server = '10.10.10.10', [string] $User = 'administrator@example.com', `
[switch] $Man, [string] $Password = 'Password1234!', [int] $VLAN = 0)

# If the use infokes the switch parameter "Usage" then instructions will be printed out.
If ($Usage) {
    Write-Host `
    "
    Usage:
        create-switch -VSName <string> [PortGroup] [<string>] [-NumPorts] [<int>] 
        [-Nic] [<string>] [-Mtu] [<int>] [-Server] [<string>] [-User] [<string>]
        [-Password] [<string>][-Usage] [-Man] [-VLAN] [<int>]
        "
    exit
}

# If the invokes the switch parameter "Man" then a manual will be printed out.
If ($Man) {
    Write-Host -ForegroundColor White -BackgroundColor Black `
    "                                                                                                                                    
                                                                                                                                    
    Name                                                                                                                            
            create-switch - create virtual switch on a vCenter server.                                                              
                                                                                                                                    
    Syntax                                                                                                                          
            create-switch -VSName <string> [-VMHost1] [<string>] [-VMHost2] [<string>] [-NumPorts] [<int>]                          
            [-Nic] [<string>] [-Mtu] [<int>] [-Server] [<string>] [-User] [<string>]                                                
            [-Password] [<string>][-Usage] [-Man]                                                                                   
                                                                                                                                    
    Options                                                                                                                         
            -VSName <string>            Specify the name of the switch.                                                             
                                                                                                                                    
            -PortGroup <string>         Specify the name of the port group. If not specified the switch name will be used.          
                                                                                                                                    
            -NumPorts <int>             Specify the number of port on the switch.                                                   
                                                                                                                                    
            -Nic <string>               Specify the name of physical NIC the switch should be connected to.                         
                                                                                                                                    
            -Mtu <int>                  Specify the MTU of the switch.                                                              
                                                                                                                                    
            -Server <string>            Specify the vCenter server's hostname or IP-address.                                        
                                                                                                                                    
            -User <string>              Specify the user to use when connecting to the vCenter server 'user@example.com'.           
                                                                                                                                    
            -Password <string>          Specify the password to use when connecting to the vCenter server 'user@example.com'.       
                                                                                                                                    
            -Usage                      View the usage of this script.                                                              
                                                                                                                                    
            -Man                        View this page.                                                                             
                                                                                                                                    
                                                                                                                                    "
    exit
}

# The parameter VSName is required so this the If-statement
# handels the potential error of a missing VSName.
# This could have been handeled at the parameter definition
# stage, but this way givs more flexibility.
If (-not $VSName) {
    Write-Error "The -Name parameter must be provided! Line:74"
    Write-Host -ForegroundColor Red "Use '-Usage' to see how the script works."
    exit
}

If (-not $PortGroup) {
    $PortGroup = $VSName
}

# The parameter Mtu can only be in the range 1500-9000.
# This If-statement handels teh potential error of an out-of-range Mtu.
If (($Mtu -lt 1500) -or ($Mtu -gt 9000)) {
    Write-Error "The -Mtu parameter must be between 1500 and 9000! Line:86"
    Write-Host -ForegroundColor Red "Use '-Usage' to see how the script works."
    exit
}

# If the VLAN variabel is given by the user it should be in the raange 0-4094.
# This If-statement handles the potential error of out-of-range VLANID.
If (($VLAN -lt 0) -or ($Mtu -gt 4094)) {
    Write-Error "The -VLAN parameter must be between 0 and 4094! Line:94"
    Write-Host -ForegroundColor Red "Use '-Usage' to see how the script works."
    exit
}

# The required module is imported with error handling.
Try {
    Import-Module VMware.VimAutomation.Core
}
Catch {
    Write-Error "The module 'VMware.VimAutomation.Core' couldn't be imported. Line:104
    Vistit https://www.vmware.com/support/developer/PowerCLI for more information."
    Write-Host -ForegroundColor Red -BackgroundColor Yellow `
    "The creation of the switch was not successful due to the issue(s) stated above!"
    Write-Host -ForegroundColor Red "If the error presists, contact the administrator."
    exit
}

# A connection to the vCented server is initiated with error handling.
Try {
    $Connection = Connect-VIServer $Server -User $User -Password $Password
}
Catch {
    Write-Error "Couldn't connect to server '$Server'. Line:117
    Vistit https://www.vmware.com/support/developer/PowerCLI for more information."
    Write-Host -ForegroundColor Red -BackgroundColor Yellow `
    "The connection to the vCenter server was not successful due to the issue(s) stated above!"
    Write-Host -ForegroundColor Red "If the error presists, contact the administrator."
    exit
}

$exit = $false

# The next 2 If-statements check the parameter values entered by the user
# against the available resources on hte ESXI hosts.
# The program isn't exited at the first discovered issue so that the user
# gets to discover all potential issues with one invokation of the script.
ForEach ($VMHost in Get-VMHost){
    If (Get-VirtualSwitch -Name $VSName -VMHost $VMHost.Name -ErrorAction SilentlyContinue -WarningAction SilentlyContinue) {
        Write-Error "There is already a switch with the name '$VSName' on host '$VMHost.Name'! Line:133"
        $exit = $true
    }
}

If (Get-VirtualSwitch -Name $VSName -VMHost $VMHost2 -ErrorAction SilentlyContinue -WarningAction SilentlyContinue) {
    Write-Error "There is already a switch with the name '$VSName' on host '$VMHost2'! Line:139"
    $exit = $true
}

# As mentioned before, the script doesn't exit at the first encoutered
# unsatisfied requirement. The script discoveres all potential issues
# and prints them out to the user at as they are discovered.
#The Boolean variabel "exit" is used to store the unmet requirement state,
# and based on its value the script may decied to exit with an error
# message as a means of error handling.
If ($exit -eq $true) {
    Write-Host -ForegroundColor Red -BackgroundColor Yellow `
    "The creation of the switch was not successful due to the issue(s) stated above! Line:150"
    Disconnect-VIServer -Server $Server -Confirm:$false
    exit
}

# Loop through all ESXI hosts
ForEach ($VMHost in Get-VMHost){
    ## In the following Try-Catch statement pair the script adds
    ## a virtual switch with the desired settings with error handling.
    Try {
        $Switch = New-VirtualSwitch -VMHost $VMHost.Name -Name $VSName -NumPorts $NumPorts -Nic $Nic -Mtu $Mtu `
        -Server $Server -Confirm:$false -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
    }
    Catch{
        Write-Error "Unknown error! The switch couldn't be created on host $VMHost1. Line:165"
        Write-Host -ForegroundColor Red -BackgroundColor Yellow `
        "The creation of the switch was not successful due to the issue(s) stated above!"
        Write-Host -ForegroundColor Red "If the error presists, contact the administrator."
    }
    
    # In the following Try-Catch statement pair the script adds a virtual port group
    # on the newly added switch with the desired settings and error handling.
    Try {
        $PG = New-VirtualPortGroup -Name $PortGroup -VirtualSwitch $Switch -VLanId $VLAN `
        -Confirm:$false -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
    }
    Catch{
        Write-Error "Unknown error! A port group couldn't be created on $VMHost1. Line:179"
        Write-Host -ForegroundColor Red -BackgroundColor Yellow `
        "The creation of a port group was not successful due to the issue(s) stated above!"
        Write-Host -ForegroundColor Red "If the error presists, contact the administrator."
    }
}

# The connection to the vCenter server is terminated with error handling.
Disconnect-VIServer -Server $Server -Confirm:$false `
-ErrorAction SilentlyContinue -WarningAction SilentlyContinue
