﻿
<#
    .SYNOPSIS
        Set the active AX 2012 AOS configuration
        
    .DESCRIPTION
        Set the active AX 2012 AOS details and store it into the configuration storage
        
    .PARAMETER ComputerName
        The name of the computer / server that AOS resides on
        
    .PARAMETER BinDirectory
        The full path to the bin directory where the AOS instance is physical installed
        
    .PARAMETER InstanceNumber
        The 2 digit ([0-9][0-9]) number that the AOS instance has on the server
        
    .PARAMETER InstanceName
        The instance name the AOS server is registered with
        
    .PARAMETER DatabaseServer
        The name of the server running SQL Server
        
    .PARAMETER DatabaseName
        The name of the AX 2012 business data database
        
    .PARAMETER ModelstoreDatabase
        The name of the AX 2012 modelstore database
        
    .PARAMETER AosPort
        The TCP port that the AX 2012 AOS server is communicating with the AX clients on
        
    .PARAMETER WsdlPort
        The TCP port that the AX 2012 AOS server is communicating with all WSDL consuming applications on
        
    .PARAMETER NetTcpPort
        The TCP port that the AX 2012 AOS server is communicating with all NetTcp consuming applications on
        
    .PARAMETER ConfigStorageLocation
        Parameter used to instruct where to store the configuration objects
        
        The default value is "User" and this will store all configuration for the active user
        
        Valid options are:
        "User"
        "System"
        
        "System" will store the configuration so all users can access the configuration objects
        
    .PARAMETER Temporary
        Instruct the cmdlet to only temporarily override the persisted settings in the configuration storage
        
    .PARAMETER Clear
        Instruct the cmdlet to clear out all the stored configuration values
        
    .EXAMPLE
        PS C:\> Get-AxAosInstance | Select-Object -First 1 | Set-AxActiveAosConfig
        
        This will get all the AX 2012 AOS instances from the local machine and only select the first output.
        The output from the first AOS instance is saved into the configuration store.
        
    .EXAMPLE
        PS C:\> Set-AxActiveAosConfig -ComputerName AX2012PROD -DatabaseServer SQLSERVER -DatabaseName AX2012R3_PROD -ModelstoreDatabase AX2012R3_PROD_model -AosPort 2712
        
        This will update the active AOS configuration store settings.
        The computer name will be registered to: AX2012PROD
        The database server will be registered to: SQLSERVER
        The database name will be registered to: AX2012R3_PROD
        The model store database will be registered to: AX2012R3_PROD_model
        The AOS port will be registered to: 2712
        
    .EXAMPLE
        PS C:\> Set-AxActiveAosConfig -Clear
        
        This will clear out all the stored configuration values.
        It updates all the internal configuration variables, so all aos default values across the module will be empty.
        
    .NOTES
        Author: Mötz Jensen (@Splaxi)
        
#>
function Set-AxActiveAosConfig {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    [CmdletBinding()]
    param (

        [Parameter(ValueFromPipelineByPropertyName = $true, Position = 1)]
        [string[]] $ComputerName = @($env:computername),

        [Parameter(ValueFromPipelineByPropertyName = $true, Position = 2)]
        [string] $BinDirectory,

        [Parameter(ValueFromPipelineByPropertyName = $true, Position = 3)]
        [string] $InstanceNumber,
        
        [Parameter(ValueFromPipelineByPropertyName = $true, Position = 4)]
        [string] $InstanceName,
        
        [Parameter(ValueFromPipelineByPropertyName = $true, Position = 5)]
        [string] $DatabaseServer,
                
        [Parameter(ValueFromPipelineByPropertyName = $true, Position = 6)]
        [string] $DatabaseName,
        
        [Parameter(ValueFromPipelineByPropertyName = $true, Position = 7)]
        [string] $ModelstoreDatabase,

        [Parameter(ValueFromPipelineByPropertyName = $true, Position = 8)]
        [string] $AosPort,

        [Parameter(ValueFromPipelineByPropertyName = $true, Position = 9)]
        [string] $WsdlPort,

        [Parameter(ValueFromPipelineByPropertyName = $true, Position = 10)]
        [string] $NetTcpPort,
        
        [ValidateSet('User', 'System')]
        [string] $ConfigStorageLocation = "User",

        [switch] $Temporary,

        [switch] $Clear
    )

    $configScope = Test-ConfigStorageLocation -ConfigStorageLocation $ConfigStorageLocation

    if (Test-PSFFunctionInterrupt) { return }
    
    if ($Clear) {

        Write-PSFMessage -Level Verbose -Message "Clearing all the ax2012.tools.active.aos configurations."

        foreach ($item in (Get-PSFConfig -FullName ax2012.tools.active.aos*)) {
            Set-PSFConfig -Fullname $item.FullName -Value ""
            if (-not $Temporary) { Register-PSFConfig -FullName $item.FullName -Scope $configScope }
        }
    }
    else {
        foreach ($key in $PSBoundParameters.Keys) {
            $value = $PSBoundParameters.Item($key)

            Write-PSFMessage -Level Verbose -Message "Working on $key with $value" -Target $value

            switch ($key) {
                "ComputerName" {
                    Set-PSFConfig -Module 'ax2012.tools' -Name 'active.aos.computername' -Value $value
                    if (-not $Temporary) { Register-PSFConfig -Module 'ax2012.tools' -Name 'active.aos.computername' -Scope $configScope }
                }

                "BinDirectory" {
                    Set-PSFConfig -Module 'ax2012.tools' -Name 'active.aos.bindirectory' -Value $value
                    if (-not $Temporary) { Register-PSFConfig -Module 'ax2012.tools' -Name 'active.aos.bindirectory' -Scope $configScope }
                }

                "InstanceNumber" {
                    Set-PSFConfig -Module 'ax2012.tools' -Name 'active.aos.instance.number' -Value $value
                    if (-not $Temporary) { Register-PSFConfig -Module 'ax2012.tools' -Name 'active.aos.instance.number' -Scope $configScope }
                }

                "InstanceName" {
                    Set-PSFConfig -Module 'ax2012.tools' -Name 'active.aos.instancename' -Value $value
                    if (-not $Temporary) { Register-PSFConfig -Module 'ax2012.tools' -Name 'active.aos.instancename' -Scope $configScope }
                }

                "DatabaseServer" {
                    Set-PSFConfig -Module 'ax2012.tools' -Name 'active.aos.databaseserver' -Value $value
                    if (-not $Temporary) { Register-PSFConfig -Module 'ax2012.tools' -Name 'active.aos.databaseserver' -Scope $configScope }
                }
		
                "DatabaseName" {
                    Set-PSFConfig -Module 'ax2012.tools' -Name 'active.aos.database' -Value $value
                    if (-not $Temporary) { Register-PSFConfig -Module 'ax2012.tools' -Name 'active.aos.database' -Scope $configScope }
                }

                "ModelstoreDatabase" {
                    Set-PSFConfig -Module 'ax2012.tools' -Name 'active.aos.modelstoredatabase' -Value $value
                    if (-not $Temporary) { Register-PSFConfig -Module 'ax2012.tools' -Name 'active.aos.modelstoredatabase' -Scope $configScope }
                }

                "AosPort" {
                    Set-PSFConfig -Module 'ax2012.tools' -Name 'active.aos.aos.port' -Value $value
                    if (-not $Temporary) { Register-PSFConfig -Module 'ax2012.tools' -Name 'active.aos.aos.port' -Scope $configScope }
                }

                "WsdlPort" {
                    Set-PSFConfig -Module 'ax2012.tools' -Name 'active.aos.wsdl.port' -Value $value
                    if (-not $Temporary) { Register-PSFConfig -Module 'ax2012.tools' -Name 'active.aos.wsdl.port' -Scope $configScope }
                }

                "NetTcpPort" {
                    Set-PSFConfig -Module 'ax2012.tools' -Name 'active.aos.nettcp.port' -Value $value
                    if (-not $Temporary) { Register-PSFConfig -Module 'ax2012.tools' -Name 'active.aos.nettcp.port' -Scope $configScope }
                }

                Default {}
            }
       
        }
    }

    Update-ActiveVariables
}