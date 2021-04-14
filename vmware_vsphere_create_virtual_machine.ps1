# Script for ceating a virtual machine in vmware vsphere with various parameters.

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
param ([string] $VMName, [string] $VMHost, [string] $Datastore='NFS-SERVER', `
[int] $CPU=1, [int] $RAM=4, [int] $Disk=20, [string] $Network="VM Network", `
[string] $RP = "Resources", [switch] $Usage, [string] $Server = '10.10.10.10', `
[string] $User = 'administrator@example.com', [switch] $Man, `
[string] $Password = 'Password1234!')

# If the use infokes the switch parameter "Usage" then instructions will be printed out.
If ($Usage) {
    Write-Host `
    "
    Usage:
        create-vm -VMName <string> [-VMHost] [<string>] [-Datastore] [<string>]
        [-CPU] [<int>] [-RAM] [<int>] [-Disk] [<int>] [-Network] [<string>]
        [-RP] [<string>] [-Server] [<string>] [-User] [<string>]
        [-Password] [<string>] [-Usage] [-Man]
        "
    exit
}

# If the invokes the switch parameter "Man" then a manual will be printed out.
If ($Man) {
    Write-Host -ForegroundColor White -BackgroundColor Black `
    "                                                                                                                                    
                                                                                                                                    
    Name                                                                                                                            
            create-vm - create virtual machines on a vCenter server.                                                                
                                                                                                                                    
    Syntax                                                                                                                          
            create-vm -VMName <string> [-VMHost] [<string>] [-Datastore] [<string>]                                                 
            [-CPU] [<int>] [-RAM] [<int>] [-Disk] [<int>] [-Network] [<string>]                                                     
            [-RP] [<string>] [-Server] [<string>] [-User] [<string>]                                                                
            [-Password] [<string>] [-Usage] [-Man]                                                                                  
                                                                                                                                    
    Options                                                                                                                         
            -VMName <string>            Specify the name of the VM.                                                                 
                                                                                                                                    
            -VMHost <string>            Specify the ESXI host the VM should be created on.                                          
                                                                                                                                    
            -Datastore <string>         Specify the datastore the VM should reside on.                                              
                                                                                                                                    
            -CPU <int>                  Specify the number of CPU cpres to be assigned to the VM.                                   
                                                                                                                                    
            -RAM <int>                  Specify the amount of RAM in GB to be assigned to the VM.                                   
                                                                                                                                    
            -Disk <int>                 Specify the disk capacity in GB to be assigned to the VM.                                   
                                                                                                                                    
            -Network <string>           Specify the network that the VM should be connected to.                                     
                                                                                                                                    
            -RP <string>                Specify the resource pool the VM should go under.                                           
                                                                                                                                    
            -Server <string>            Specify the vCenter server's hostname or IP-address.                                        
                                                                                                                                    
            -User <string>              Specify the user to use when connecting to the vCenter server 'user@example.com'.           
                                                                                                                                    
            -Password <string>          Specify the password to use when connecting to the vCenter server 'user@example.com'.       
                                                                                                                                    
            -Usage                      View the usage of this script.                                                              
                                                                                                                                    
            -Man                        View this page.                                                                             
                                                                                                                                    
                                                                                                                                    "
    exit
}

# The parameter VMName is required so this the If-statement 
# handels the potential error of a missing VMName.
# This could have been handeled at the parameter definition stage,
# but this way givs more flexibility.
If ($VMName -like $null) {
    Write-Error "The -Name parameter must be provided! Line:83"
    Write-Host -ForegroundColor Red "Use '-Usage' to see how the script works."
    exit
}

# The required module is imported with error handling.
Try {
    Import-Module VMware.VimAutomation.Core
}
Catch {
    Write-Error "The module 'VMware.VimAutomation.Core' couldn't be imported. Line:93
    Vistit https://www.vmware.com/support/developer/PowerCLI for more information."
    Write-Host -ForegroundColor Red -BackgroundColor Yellow `
    "The creation of the switch was not successful due to the issue(s) stated above!"
    Write-Host -ForegroundColor Red "If the error presists, contact the administrator."
    exit
}

# A connection to the vCenter server is initiated with error handling.
Try {
    $Connection = Connect-VIServer $Server -User $User -Password $Password
}
Catch {
    Write-Error "Couldn't connect to server '$Server'. Line:106
    Vistit https://www.vmware.com/support/developer/PowerCLI for more information."
    Write-Host -ForegroundColor Red -BackgroundColor Yellow `
    "The connection to the vCenter server was not successful due to the issue(s) stated above!"
    Write-Host -ForegroundColor Red "If the error presists, contact the administrator."
    exit
}

# Another parameter that is required is the VMHost, however instead
# of forcing the user to re-invoke the script with said parameter
# the problem is handeled by checking which host in the cluster in
# not overcommitted and if both aren't then the last one in the list
# will be chosen.
# Over committment is decided based on the ration of virtual hardware
# to physical, and the accepted ration is less than 3.
# This step is done for both RAM and CPU cores, and it givs the
# user the ability to override the overcomittment ration threshold.
If ($VMHost -like $null) {
    Foreach($esx in Get-VMHost){
        $vCPU = Get-VM -Location $esx | Measure-Object -Property NumCpu -Sum | select -ExpandProperty Sum
        $COCR = $esx | Select Name,@{N='pCPU';E={$_.NumCpu}},
            @{N='vCPU';E={$vCPU}},
            @{N='Ratio';E={[math]::Round(($vCPU+$CPU)/$_.NumCpu,1)}}
        
        If ($COCR.Ratio -lt 3) {
            $VMHost = $COCR.Name
            $VMHostCPU = $VMHost
            Break
        }
        Else {
            $VMHostCPU = $null
        }
    }

    Foreach($esx in Get-VMHost){
        $vRAM = Get-VM -Location $esx | Measure-Object -Property MemoryGB -Sum | select -ExpandProperty Sum
        $ROCR = $esx | Select Name,@{N='pRAM';E={$_.MemoryTotalGB}},
            @{N='vRAM';E={$vRAM}},
            @{N='Ratio';E={[math]::Round(($vRAM+$Ram)/$_.MemoryTotalGB,1)}}
        
        If ($ROCR.Ratio -lt 3) {
            $VMHost = $ROCR.Name
            $VMHostRAM = $VMHost
            Break
        }
        Else {
                $VMHostRAM = $null
        }
    }


}

$exit = $false

# The next 10 If-statements check either default parameter values
# or values entered by the user against the available resources
# both in the cluster on any other resource pool.
# The program isn't exited at the first discovered issue so that the
# user gets to discover all potential issues with one invokation of the script.
if ($VMHostRAM -like $null) {
    Write-Error `
    "The resouce pool '$RP' doesn't contain '$RAM GB' RAM or you are maby making a huge overcommitment. Line:167"
    $exit = $true
}

if (($VMHostCPU -lt $CPU) -or ($cpu -gt 16)) {
    Write-Error `
    "The resouce pool '$RP' doesn't contain '$CPU' CPUs or you are maby making a huge overcommitmen. Line:173"
    $exit = $true
}

If (Get-VM -Name $VMName -ErrorAction SilentlyContinue -WarningAction SilentlyContinue) {
    Write-Error "There is already a VM with the name '$VMName'! Line:179"
    $exit = $true
}

If (!(Get-VMHost -Name $VMHost)) {
    Write-Error "The host '$VMHost' doesn't exist! Line:184"
    $exit = $true
}

If ( -not (Get-Datastore -Name $Datastore)) {
    Write-Error "The datastore '$Datastore' doesn't exist! Line:189"
    $exit = $true
}

If ((Get-Datastore -Name $Datastore | Select-Object -ExpandProperty FreeSpaceGB) -lt $Disk) {
    Write-Error "The datastore '$Datastore' doesn't have '$Disk GB' of free space! Line:194"
    $exit = $true
}

If ((Get-VirtualNetwork | Select-Object -ExpandProperty Name) -notcontains $Network) {
    Write-Error "The network '$Network' doesn't exist! Line:199"
    $exit = $true
}

If ((Get-ResourcePool | Select-Object -ExpandProperty Name) -notcontains $RP) {
    Write-Error "The resouce pool '$RP' doesn't exist! Line:204"
    $exit = $true
}


# As mentioned before, the script doesn't exit at the
# first encoutered unsatisfied requirement. The script
# discoveres all potential issues and prints them out
# to the user at as they are discovered. The Boolean
# variabel "exit" is used to store the unmet requirement
# state, and based on its value the script may decied to
# exit with an error message as a means of error handling.
If ($exit -eq $true) {
    Write-Host -ForegroundColor Red -BackgroundColor Yellow `
    "The creation of the VM was not successful due to the issue(s) stated above! Line:217"
    Disconnect-VIServer -Server $Server -Confirm:$false
    exit
}

# In the following Try-Catch statement pair the script adds
# a virtual machine with the desired settings with error handling.
Try {
    $VM = New-VM -Name $VMName -Datastore $Datastore -NumCpu $CPU `
    -MemoryGB $RAM -DiskGB $Disk -NetworkName $Network -Confirm:$false `
    -ResourcePool $RP -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
}
Catch{
    Write-Error "Unknown error! Line:231"
    Write-Host -ForegroundColor Red -BackgroundColor Yellow `
    "The creation of the VM was not successful due to the issue(s) stated above!"
    Write-Host -ForegroundColor Red "If the error presists, contact the administrator."
}

# The connection to the vCenter server is terminated with error handling.
Disconnect-VIServer -Server $Server -Confirm:$false `
-ErrorAction SilentlyContinue -WarningAction SilentlyContinue
