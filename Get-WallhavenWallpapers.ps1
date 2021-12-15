# Asking the user to specify a category of wall papers
clear-host
$category = Read-Host "Provide a wallpaper category"

<#
    Asking the user where to save the wallpaper
    This part of the script will also test the path and make sure the user has typed in a correct path. if the user did not
    type in a correct path, they will be asked to type in the path again.
#>
clear-host
do
{
    $saveLocation = Read-Host "Where would you like to save your files?`n **press ENTER to save in Pictures**`n"
    if($saveLocation.Length -eq 0)
    {
        $saveLocation = $env:USERPROFILE + "\Pictures"
    }
    $testPathResults = Test-Path $saveLocation
    if($testPathResults -eq $false)
    {   
        Clear-Host
        Write-Warning "There path you typed is invalid or does not exist. Please retype the path and try again `n"
    }
}
While($testPathResults -eq $false)
# This line will display to the user where the wallpapes will be saved
Write-Output "You selected to save your wallpapers in: $saveLocation"

#this part of the script will download the wallpapers until the user closes the script or the script reaches the last page
$pageNum = 1
do
{
    $url = "https://wallhaven.cc/search?q="+ $category + "&categories=110&purity=100&atleast=1920x1080&sorting=relevance&order=desc&page=" + $pageNum.toString()
    $urlReply = curl.exe $url
    Start-Sleep -Seconds 1
    $wallpaperLinks = (($urlReply -split "`/a" | Where-Object {$_ -like "*href=`"https://wallhaven.cc*"}) -split "href=`"" | Where-Object {$_ -like "https://wallhaven.cc/w/*"}) -replace '"  target="_blank"  ><'
    if($wallpaperLinks.Count -gt 0)
    {
        foreach($link in $wallpaperLinks)
        {   
            $fielName = $link -split "/w/" | Select-Object -Last 1
            Write-Output "Tring wallpaper url -- $link"
            $wallpaperHtmlReply = curl.exe $link
            Start-Sleep -Seconds 1
            $downloadUrl = ($wallpaperHtmlReply -split '<' | Where-Object{$_ -like "*https://w.wallhaven.cc/*$fielName*"}) -split '"' | Where-Object {$_ -like "*wallhaven-$fielName*"}
            Write-Output "trying download url::: $downloadUrl"
            curl.exe $downloadUrl --output $($saveLocation + "\wallhaven-" + $fielName + ".jpg") 
            Start-Sleep -Seconds 1
        }
         $pageNum++
    }
}while($wallpaperLinks.Count -gt 0)
Clear-Host
$insults = "You MONSTER!! ","How dare you?! ", "I cant belive you! "
Write-Output "$($insults | Get-Random)You have downloaded all wallapers from this category"
Write-Output "Your files are locaterd in $saveLocation"
