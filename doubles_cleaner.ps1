[CmdletBinding()]
param (
    [Parameter()]
    [bool]
    $silent,
    [Parameter()]
    [string]
    $folderLocation,
    [Parameter()]
    [string]
    $logLocation
)

Write-Host "DoublesCleaner made by TD3V"
Write-Host "https://github.com/T-D3V/doublesCleaner"
Write-Host "---------------------------------------"
[Scanner]$scanner = [Scanner]::new()

$scanner.scanDirectory($folderLocation)

if(!$silent){
  Write-Host "Scanned Documents"
  Write-Host "---------------------------------------"
  $scanner.scan | Format-Table -Property Name, Value
  Write-Host "---------------------------------------"
  Write-Host "All Duplicate Files"
  Write-Host "---------------------------------------"
  $scanner.duplicates | Format-Table -Property Name, Value
  Write-Host "---------------------------------------"
}

if(!($logLocation -eq "")){
  if(!(Test-Path $logLocation)){
    New-Item -path $logLocation -type "file" -Force
  }
  Add-Content -path $logLocation -value (($scanner.duplicates | ConvertTo-Json)+ ",")
}else{
  if(!(Test-Path $env:APPDATA\\doubles_cleaner\\doubles.json)){
    New-Item -path $env:APPDATA\\doubles_cleaner\\doubles.json -type "file" -Force
  }
  Add-Content -path $env:APPDATA\\doubles_cleaner\\doubles.json -value (($scanner.duplicates | ConvertTo-Json)+ ",")
}



class Scanner {
  [hashtable]$scan = [hashtable]::new()
  [hashtable]$duplicates = [hashtable]::new()

  [void] scanDirectory($path){
    foreach($element in Get-ChildItem $path -Recurse -Force) {
      if(!($element -is [System.IO.DirectoryInfo])){
        $currPath = $element.FullName
        $currHash = (Get-FileHash $currPath).Hash
        if($this.scan.ContainsValue($currHash)){
          $this.duplicates.Add($currPath, $currHash)
        }
        $this.scan.Add($currPath, $currHash)
      }
    }
  }
}