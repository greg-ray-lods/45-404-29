# CsvUploadAndDownload.ps1

# Download CSV from GitHub if blob is missing and then download it from Azure Storage locally.
$blobExists = $false
while (-not $blobExists) {
    try {
        $blob = Get-AzStorageBlob -Container $containerName -Context $ctx -Blob $blobName -ErrorAction SilentlyContinue
        if ($blob) {
            Write-Output "Blob '$blobName' found. Proceeding to download."
            $blobExists = $true
        } else {
            Write-Output "Blob '$blobName' not found. Downloading CSV from GitHub..."
            Invoke-WebRequest -Uri $GitHubCsvUrl -OutFile $LocalCsvFilePath -ErrorAction Stop
            Set-AzStorageBlobContent -Container $containerName -Context $ctx -File $LocalCsvFilePath -Blob $blobName -Force
            Write-Output "CSV file uploaded to Azure Storage."
            $blobExists = $true
        }
    } catch {
        Write-Output "Error processing CSV blob. Retrying in 6 seconds..."
    }
    Start-Sleep -Seconds 6
}

$fileDownloaded = $false
while (-not $fileDownloaded) {
    try {
        Get-AzStorageBlobContent -Container $containerName -Context $ctx -Blob $blobName -Destination $LocalCsvFilePath -Force
        Write-Output "CSV file downloaded to '$LocalCsvFilePath'."
        $fileDownloaded = $true
    } catch {
        Write-Output "Error downloading CSV file. Retrying..."
        Start-Sleep -Seconds 6
    }
}
