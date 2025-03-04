# Cleanup.ps1

if ($IsWindows) {
    $TempDir = "C:\Temp"
} else {
    $TempDir = "/tmp"
}
$LocalCsvFilePath = "$TempDir/walmart-product-with-embeddings-dataset-usa.csv"

Remove-Item -Path $LocalCsvFilePath -Force
Write-Output "Cleaned up local CSV file at '$LocalCsvFilePath'."
