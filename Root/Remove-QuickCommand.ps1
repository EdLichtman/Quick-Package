function global:Remove-QuickCommand {
    param(
        [string]$commandName,
        [string]$QuickModule
    )

    . $PSScriptRoot\Reserved\Get-QuickEnvironment.ps1
    . $QuickReservedHelpersRoot\Test-QuickFunctionVariable.ps1

    $commandName = Test-QuickFunctionVariable $PSBoundParameters 'commandName' 'Please enter the function/alias to remove'
    $QuickModule = Test-QuickFunctionVariable $PSBoundParameters 'QuickModule' 'Please enter the name of the Module'

    if(Test-Path "$QuickPackageModuleContainerPath\$QuickModule\Functions\$commandName.ps1") {
        Remove-Item -Path "$QuickPackageModuleContainerPath\$QuickModule\Functions\$commandName.ps1"    

        if (Test-Path function:\$commandName) {
            Remove-Item function:\$commandName
        }

        # #Remove Exported Member from Module
        # $psd1Location = "$(Split-Path (Get-Module $QuickPackageModuleName).Path)\$QuickPackageModuleName.psd1"
        # $psd1Content = (Get-Content $psd1Location | Out-String)
        # $psd1 = (Invoke-Expression $psd1Content)
        # $NewFunctionsToExport = New-Object System.Collections.ArrayList($null)
        # $NewFunctionsToExport.AddRange($psd1.FunctionsToExport)
        # $NewFunctionsToExport.Remove($commandName) | Out-Null
        # $psd1.FunctionsToExport = $NewFunctionsToExport;
        # Set-Content $psd1Location (ConvertTo-PowershellEncodedString $psd1)
    }
    elseif(Test-Path "$QuickPackageModuleContainerPath\$QuickModule\Aliases\$commandName.ps1") {
        Remove-Item -Path "$QuickPackageModuleContainerPath\$QuickModule\Aliases\$commandName.ps1"
        
        if (Test-Path alias:\$commandName) {
            Remove-Item alias:\$commandName
        }

        # #Remove Exported Member from Module
        # $psd1Location = "$(Split-Path (Get-Module $QuickPackageModuleName).Path)\$QuickPackageModuleName.psd1"
        # $psd1Content = (Get-Content $psd1Location | Out-String)
        # $psd1 = (Invoke-Expression $psd1Content)
        # $NewAliasesToExport = New-Object System.Collections.ArrayList($null)
        # $NewAliasesToExport.AddRange($psd1.AliasesToExport)
        # $NewAliasesToExport.Remove($commandName) | Out-Null
        # $psd1.AliasesToExport = $NewAliasesToExport;
        # Set-Content $psd1Location (ConvertTo-PowershellEncodedString $psd1)
    } else {
        Write-Output "Command '$commandName' not found."
        return;
    }
}