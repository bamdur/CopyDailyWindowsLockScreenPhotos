# Brandon Amdur | https://github.com/bamdur | 06/13/2021
add-type -AssemblyName System.Drawing #load module for image
$curDir = $pwd

$contentDir = $env:LOCALAPPDATA + '\Packages\Microsoft.Windows.ContentDeliveryManager_cw5n1h2txyewy\LocalState\Assets'
cd $contentDir

$targetDir = $args[0]
$targetDirVertical = "$targetDir\vertical"
$targetDirHorizontal = "$targetDir\horizontal"

# Create target dirs if they dont exist
md -Force $targetDirHorizontal | Out-Null
md -Force $targetDirVertical | Out-Null

# Get items in the assets folder greater than 400kb that were created today as a list
$dailyPhotos = Get-ChildItem . | where-object {$_.length -gt 400000 -and $_.CreationTime -gt (Get-Date).Date } |  Foreach-Object { $_.Name } #Select-Object -ExpandProperty Name | Format-Table name -HideTableHeaders | out-string

$hi = 1;
$vi = 1;
$date = Get-Date -Format "MM-dd-yyyy" 

foreach ($imageFile in $dailyPhotos) {
  
  $renamedImage = "$date-($hi)-horizontal.jpg"
  $destination = $targetDirHorizontal
  
  #$fileAsImage = New-Object System.Drawing.Bitmap $imageFile #get file as image
  $imageFileAbsolutePath = $contentDir + "\" + $imageFile

  $fileAsImage = [System.Drawing.Image]::FromFile($imageFileAbsolutePath)

  $imageWidth = $fileAsImage.Width 
  $imageHeight = $fileAsImage.Height
  # check image dimensions to move to correct folder
  # typical dimensions:
  #   Horizontal: 1028x1920
  #   Vertical:   1920x1028
  # add range in case dimensions change
  
  If ( ($imageWidth -gt 800) -and ($imageWidth -lt 1400)) { #image is vertical?
	$renamedImage = "$date-($vi)-vertical.jpg"
	$destination = $targetDirVertical
    $vi++;
  } Else {
    $hi++;
  }
  echo "Copying [$imageFile] to $renamedImage"
  cp $imageFile $renamedImage #copy asset and rename
  cp $renamedImage $destination #move asset to our horizontal/vertical folder
  rm $renamedImage #cleanup temp file
}
echo ""
Write-Output "Windows Lock Screen Copy Job copied $($vi + $hi - 2) photo(s) to $targetDir"
exit 0