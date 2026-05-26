# PowerShell script to create GAAS Windows App ZIP
# Run this script to create a distributable ZIP file

$sourceFolder = "GAAS_Windows_App"
$zipFile = "GAAS_Windows_App_v1.0.zip"

if (Test-Path $zipFile) {
    Remove-Item $zipFile -Force
}

# Create ZIP archive
Add-Type -AssemblyName "System.IO.Compression.FileSystem"
[System.IO.Compression.ZipFile]::CreateFromDirectory($sourceFolder, $zipFile)

Write-Host "✅ GAAS Windows App ZIP created successfully!"
Write-Host "📁 Location: $zipFile"
Write-Host "📏 Size: $((Get-Item $zipFile).Length / 1MB) MB"
Write-Host ""
Write-Host "🚀 To distribute:"
Write-Host "1. Share the ZIP file"
Write-Host "2. Users extract all files to a folder"
Write-Host "3. Run 'Run_GAAS.bat' or 'GAAS_Windows_App.exe'"
Write-Host ""
Write-Host "Happy Learning! Emojis"