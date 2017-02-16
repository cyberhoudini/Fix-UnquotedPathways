Function Fix-ServicePath ([System.IO.DirectoryInfo]$LogPath = "C:\temp") {
<#
	.SYNOPSIS
	    Microsoft Windows Unquoted Service Path Enumeration

	.DESCRIPTION
	    Use Fix-ServicePath to fix vulnerability "Unquoted Service Path Enumeration".
	    Took the original Technet "Unquoted Service Path Enumeration" and added more executables file extensions to an array. 
		
	    
	    ------------------------------------------------------------------
	    Author: Harry Thomas
		Version: 1.0
    
	.PARAMETER LogPath	
		You can set different path for log files
		Defaul path is c:\Temp
		Default log file: servicesfix.log
	
	.NOTES


	.EXAMPLE
		 Fix-Servicepath

	.EXAMPLE
		 Fix-ServicePath -LogPath C:\DifferentPath

	.LINK
		https://gallery.technet.microsoft.com/scriptcenter/Windows-Unquoted-Service-190f0341
		https://www.tenable.com/sc-report-templates/microsoft-windows-unquoted-service-path-enumeration
		http://www.commonexploits.com/unquoted-service-paths/
	#>

$ExecutableArray = @("exe","vbs","bat") # Initialized Array with Executable File Extensions.

if (-not (Test-Path $LogPath)){New-Item $LogPath -ItemType directory}

"**************************************************" | Out-File "$LogPath\servicesfix.log" -Append
"Computername: $($Env:COMPUTERNAME)" | Out-File "$LogPath\servicesfix.log" -Append
"Date: $(Get-date -Format "dd.MM.yyyy HH:mm")" | Out-File "$LogPath\servicesfix.log" -Append

    # Get all services
Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Services\" | foreach {
$OriginalPath = (Get-ItemProperty "$($($_).name.replace('HKEY_LOCAL_MACHINE', 'HKLM:'))")
$ImagePath = $OriginalPath.ImagePath
foreach ($x in $ExecutableArray){
    # Get all services with vulnerability
    If (($ImagePath -like "* *") -and ($ImagePath -notlike '"*"*') -and ($ImagePath -like "*.$x*")){ 
        $NewPath = ($ImagePath -split ".$x ")[0]
        $key = ($ImagePath -split ".$x ")[1]
        $triger = ($ImagePath -split ".$x ")[2]
        
        # Get all services with vulnerability with key in ImagePath
        If (-not ($triger | Measure-Object).count -ge 1){
            If (($NewPath -like "* *") -and ($NewPath -notlike "*.$x")){
            
                " ***** Old Value $ImagePath" | Out-File "$LogPath\servicesfix.log" -Append
                "$($OriginalPath.PSChildName) `"$NewPath.exe`" $key" | Out-File "$LogPath\servicesfix.log" -Append
                Set-ItemProperty -Path $OriginalPath.PSPath -Name "ImagePath" -Value "`"$NewPath.exe`" $key"
            }
            }

        # Get all services with vulnerability with out key in ImagePath
        If (-not ($triger | Measure-Object).count -ge 1){
            If (($NewPath -like "* *") -and ($NewPath -like "*.$x")){
            
                " ***** Old Value $ImagePath" | Out-File "$LogPath\servicesfix.log" -Append
                "$($OriginalPath.PSChildName) `"$NewPath`"" | Out-File "$LogPath\servicesfix.log" -Append
                Set-ItemProperty -Path $OriginalPath.PSPath -Name "ImagePath" -Value "`"$NewPath`""
            }
            }
        }
        If (($triger | Measure-Object).count -ge 1) { "----- Error Cant parse  $($OriginalPath.ImagePath) in registry  $($OriginalPath.PSPath -replace 'Microsoft\.PowerShell\.Core\\Registry\:\:') " | Out-File $LogPath\servicesfix.log -Append}
    }
}
}
Function Find-ServicePaths{

<#
    .SYNOPSIS
        Find Microsoft Windows Unquoted Service Path 

    .DESCRIPTION
        Use Find-ServicePaths to identify any service set to "auto" that has unquoted pathways.  
        
        
        ------------------------------------------------------------------
        Author: Harry Thomas
        Version: 1.0
    
    .PARAMETER LogPath  
        You can set different path for log files
        Defaul path is c:\Temp
        Default log file: servicesfix.log

    .EXAMPLE
         Find-Servicepath

#>

cmd /c 'wmic service get name,displayname,pathname,startmode |findstr /i "auto" |findstr /i /v "c:\windows\\" |findstr /i /v """'

}