param (
        [string]$machinesList,
        [string]$AdminUserName,
        [string]$AdminPassword,
        [string]$Path,
        [string]$Users,
        [string]$Control     
        )

Write-Output "Machine Name - $machinesList"
Write-Output "Admin User Name - $AdminUserName"
Write-Output "Folder Location - $Path"
Write-Output "User List - $Users"
Write-Output "Type of access - $Control"

$pass = ConvertTo-SecureString -AsPlainText $AdminPassword -Force

$credential = new-object -typename System.Management.Automation.PSCredential -argumentlist $AdminUserName,$pass

Invoke-Command -ComputerName $machinesList -credential $credential  -ScriptBlock {

param (
        [string]$Path,
        [string]$Users,
        [string]$Control          
        )

Write-Output "Folder Location - $Path"
Write-Output "User List - $Users"
Write-Output "Type of access - $Control"

$UserSplit = $Users -split ";"
$FolderSplit = $Path -split ";"

foreach ($Folder in $FolderSplit)
{
    ForEach ($User in $UserSplit)
    {
        $Acl = Get-Acl $Folder
        $Ar = New-Object  system.security.accesscontrol.filesystemaccessrule($User,$Control,"ContainerInherit,ObjectInherit","None","Allow")
        $Acl.SetAccessRule($Ar)
        Set-Acl $Folder $Acl
    }
}
} -ArgumentList ($Path, $Users, $Control)
