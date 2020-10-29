using namespace System.Management.Automation;

class ValidateModuleProjectExistsAttribute : ValidateArgumentsAttribute 
{
    [void]  Validate([object]$arguments, [EngineIntrinsics]$engineIntrinsics)
    {
        $moduleProject = $arguments

        $Choices = Get-ValidModuleProjectNames
        if (!$Choices) {
            throw [ItemNotFoundException]'No viable Modules. Please create one with New-ModuleProject!'
        }
    
        if (!($moduleProject -in ($Choices))) {
            throw [ArgumentException] "Parameter must be one of the following choices: $Choices"
        }
    }
}

class ValidateModuleProjectDoesNotExistAttribute : ValidateArgumentsAttribute 
{
    [void]  Validate([object]$arguments, [EngineIntrinsics]$engineIntrinsics)
    {
        $moduleProject = $arguments

        $Choices = Get-ValidModuleProjectNames
        if ($Choices -and ($moduleProject -in ($Choices))) {
            throw [ArgumentException] "Parameter must not be one of the following choices: $Choices"
        }
    }
}

class ValidateModuleDoesNotExistAttribute : ValidateArgumentsAttribute 
{
    [void]  Validate([object]$arguments, [EngineIntrinsics]$engineIntrinsics)
    {
        $moduleProject = $arguments

        if (Get-Module $moduleProject) {
            throw [ArgumentException] "Module already exists by the name '$moduleProject'"
        }
    }
}

<#Internal#>
function Test-CommandExistsInModule {
    param(
        [String] $ModuleProject,
        [String] $CommandName
    )

    $Functions = Get-ModuleProjectFunctions -ModuleProject $ModuleProject
    if (($Functions | Where-Object { $_.BaseName -eq $CommandName})) {
        return $True
    } else {
        $Aliases = Get-ModuleProjectAliases -ModuleProject $ModuleProject
        if (($Aliases | Where-Object { $_.BaseName -eq $CommandName})) {
            return $True
        } 
    } 

    return $False
}
<#/Internal#>

function Assert-CommandExistsInModule {
    param(
        [String] $ModuleProject,
        [String] $CommandName
    )

    if (!(Test-CommandExistsInModule -ModuleProject $ModuleProject -CommandName $CommandName)) {
        throw [ItemNotFoundException]"'$CommandName' does not exist as a command in $ModuleProject!"
    }
}

function Test-ModuleCommandExists {
    $ModuleProjects = Get-ValidModuleProjectNames;
    foreach($ModuleProject in $ModuleProjects) {
        if (Test-CommandExistsInModule -ModuleProject $ModuleProject -CommandName $CommandName) {
            return $true;
        }
    }

    return $false;
}
class ValidateModuleCommandExistsAttribute : ValidateArgumentsAttribute 
{
    [void] Validate([object]$arguments, [EngineIntrinsics]$engineIntrinsics) 
    {
        $CommandName = $arguments;
        $ModuleProjects = Get-ValidModuleProjectNames;
        foreach($ModuleProject in $ModuleProjects) {
           if (Test-CommandExistsInModule -ModuleProject $ModuleProject -CommandName $CommandName) {
               return;
           }
        }

        throw [ItemNotFoundException]"'$CommandName' does not exist as a command in any ModuleProject!"
    }
}

function Test-CommandExists {
    param([String]$CommandName)
    $oldPreference = $ErrorActionPreference;
    $ErrorActionPreference = 'stop'
    try {if(Get-Command $CommandName){return $true;}}
    Catch {return $false;}
    Finally {$ErrorActionPreference=$oldPreference}
}
class ValidateCommandExistsAttribute : ValidateArgumentsAttribute 
{
    [void] Validate([object]$arguments, [EngineIntrinsics]$engineIntrinsics) 
    {
        $CommandName = $arguments;   

        $ModuleProjects = Get-ValidModuleProjectNames;
        foreach($ModuleProject in $ModuleProjects) {
           if (Test-CommandExistsInModule -ModuleProject $ModuleProject -CommandName $CommandName) {
               return;
           }
        }

        if (!(Test-CommandExists -CommandName $CommandName)) {
            throw [ArgumentException]"'$CommandName' does not exist"
        }
    }
}


class ValidateModuleCommandDoesNotExistAttribute : ValidateArgumentsAttribute 
{
    [void] Validate([object]$arguments, [EngineIntrinsics]$engineIntrinsics) 
    {
        $CommandName = $arguments;
        $ModuleProjects = Get-ValidModuleProjectNames;
        foreach($ModuleProject in $ModuleProjects) {
            $Functions = Get-ModuleProjectFunctions -ModuleProject $ModuleProject
            $FunctionExists = ($Functions | Where-Object { $_.BaseName -eq $CommandName});

            $Aliases = Get-ModuleProjectAliases -ModuleProject $ModuleProject
            $AliasExists = ($Aliases | Where-Object { $_.BaseName -eq $CommandName})
            
            if ($FunctionExists -or $AliasExists) {
                throw [ItemNotFoundException]"'$CommandName' already exists as a command in '$ModuleProject'!"
            }
        }
    }
}

# https://powershellexplained.com/2017-02-20-Powershell-creating-parameter-validators-and-transforms/
class ValidateParameterStartsWithApprovedVerbAttribute : ValidateArgumentsAttribute 
{
    [void]  Validate([object]$arguments, [EngineIntrinsics]$engineIntrinsics)
    {
        $commandName = $arguments
        if(![string]::IsNullOrWhiteSpace($commandName))
        {
            $chosenVerb = $commandName.Split('-')[0]
            $ApprovedVerbs = Get-ApprovedVerbs;
            if (!$ApprovedVerbs.Contains($chosenVerb)) {
                throw [System.ArgumentException] "$chosenVerb is not a common accepted verb. Please find an appropriate verb by using the command 'Get-Verb'." 
            }
        }
    }
}