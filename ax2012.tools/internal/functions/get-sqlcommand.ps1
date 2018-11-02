﻿
<#
    .SYNOPSIS
        Get a SqlCommand object
        
    .DESCRIPTION
        Get a SqlCommand object initialized with the passed parameters
        
    .PARAMETER DatabaseServer
        The name of the database server
        
    .PARAMETER DatabaseName
        The name of the database
        
    .PARAMETER SqlUser
        The login name for the SQL Server instance
        
    .PARAMETER SqlPwd
        The password for the SQL Server user.
        
    .PARAMETER TrustedConnection
        Should the connection use a Trusted Connection or not
        
    .EXAMPLE
        PS C:\> Get-SqlCommand -DatabaseServer localhost -DatabaseName MicrosoftDynamicsAx_model -SqlUser User123 -SqlPwd "Password123" -TrustedConnection $false
        
        This will initialize a new SqlCommand object (.NET type) with localhost as the server name, AxDB as the database and the User123 sql credentials.
        
    .EXAMPLE
        PS C:\> Get-SqlCommand -DatabaseServer localhost -DatabaseName MicrosoftDynamicsAx_model -TrustedConnection $true
        
        This will initialize a new SqlCommand object (.NET type) with localhost as the server name, AxDB as the database and use the current windows credentials (trusted connection).
        
    .NOTES
        Author: Rasmus Andersen (@ITRasmus)
        Author: Mötz Jensen (@Splaxi)
        
#>
function Get-SQLCommand {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $DatabaseServer,

        [Parameter(Mandatory = $true)]
        [string] $DatabaseName,

        [Parameter(Mandatory = $false)]
        [string] $SqlUser,

        [Parameter(Mandatory = $false)]
        [string] $SqlPwd,

        [Parameter(Mandatory = $false)]
        [boolean] $TrustedConnection
    )

    Write-PSFMessage -Level Debug -Message "Writing the bound parameters" -Target $PsBoundParameters
    [System.Collections.ArrayList]$Params = New-Object -TypeName "System.Collections.ArrayList"

    $null = $Params.Add("Server='$DatabaseServer';")
    $null = $Params.Add("Database='$DatabaseName';")

    if ($null -eq $TrustedConnection -or (-not $TrustedConnection)) {
        $null = $Params.Add("User='$SqlUser';")
        $null = $Params.Add("Password='$SqlPwd';")
    }
    else {
        $null = $Params.Add("Integrated Security='SSPI';")
    }

    $null = $Params.Add("Application Name='ax2012.tools'")
    
    Write-PSFMessage -Level Verbose -Message "Building the SQL connection string." -Target ($Params.ToArray() -join ",")
    $sqlConnection = New-Object System.Data.SqlClient.SqlConnection

    try {
        $sqlConnection.ConnectionString = ($Params -join "")

        $sqlCommand = New-Object System.Data.SqlClient.SqlCommand
        $sqlCommand.Connection = $sqlConnection
        $sqlCommand.CommandTimeout = 0
    }
    catch {
        Write-PSFMessage -Level Host -Message "Something went wrong while working with the sql server connection objects" -Exception $PSItem.Exception
        Stop-PSFFunction -Message "Stopping because of errors"
        return
    }
    
    $sqlCommand
}