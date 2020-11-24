function Copy-ModuleCommand {
    [CmdletBinding(SupportsShouldProcess=$True)]
    param(
        [Parameter()]
        [ValidateScript({ValidateModuleProjectExists $_})]
        [String]$SourceModuleProject,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ValidateModuleCommandExists $_})]
        [String]$CommandName,

        [Parameter()]
        [ValidateScript({ValidateModuleProjectExists $_})]
        [String]$DestinationModuleProject,

        [Parameter(Mandatory=$true)][String]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ValidateModuleCommandDoesNotExist $_})]
        $NewCommandName,

        [Parameter()][Switch]
        $Force
    )

    if ($SourceModuleProject) {
        ValidateCommandExistsInModule -ModuleProject $SourceModuleProject -CommandName $CommandName
    } else {
        $SourceModuleProject = (GetModuleProjectForCommand -CommandName $CommandName)
    }

    if (!$DestinationModuleProject) {
        $DestinationModuleProject = $SourceModuleProject
    }

    $CommandBlock = GetDefinitionForCommand -CommandName $CommandName -NewCommandName $NewCommandName
    $CommandType = GetModuleProjectTypeForCommand -CommandName $CommandName

    if ($CommandType -EQ 'Function') {
        if (!$Force) {
            ValidateCommandStartsWithApprovedVerb -Command $NewCommandName
        }
        
        New-ModuleProjectFunction -ModuleProject $DestinationModuleProject -CommandName $NewCommandName -Text $CommandBlock -Raw
        Edit-ModuleCommand -ModuleProject $DestinationModuleProject -CommandName $NewCommandName
    } elseif ($CommandType -EQ 'Alias') {
       New-ModuleProjectAlias -ModuleProject $DestinationModuleProject -Alias $NewCommandName -CommandName $CommandBlock
    }

    Update-ModuleProject -ModuleProject $DestinationModuleProject
    Import-Module $BaseModuleName -Force -Global
}
Register-ArgumentCompleter -CommandName Copy-ModuleCommand -ParameterName SourceModuleProject -ScriptBlock (Get-Command ModuleProjectArgumentCompleter).ScriptBlock
Register-ArgumentCompleter -CommandName Copy-ModuleCommand -ParameterName CommandName -ScriptBlock (Get-Command CommandFromOptionalModuleArgumentCompleter).ScriptBlock
Register-ArgumentCompleter -CommandName Copy-ModuleCommand -ParameterName DestinationModuleProject -ScriptBlock (Get-Command ModuleProjectArgumentCompleter).ScriptBlock
Register-ArgumentCompleter -CommandName Copy-ModuleCommand -ParameterName NewCommandName -ScriptBlock (Get-Command NewCommandFromModuleArgumentCompleter).ScriptBlock