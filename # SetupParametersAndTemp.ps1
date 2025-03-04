# SetupParametersAndTemp.ps1

# Define common parameters and set up the temporary directory.
$GitHubCsvUrl = "https://raw.githubusercontent.com/greg-ray-lods/45-404-29/main/walmart-product-with-embeddings-dataset-usa.csv"

if ($IsWindows) {
    $TempDir = "C:\Temp"
} else {
    $TempDir = "/tmp"
}

if (!(Test-Path -Path $TempDir)) {
    New-Item -ItemType Directory -Path $TempDir -Force
}

$LocalCsvFilePath = "$TempDir/walmart-product-with-embeddings-dataset-usa.csv"

# Define Azure Storage and SQL parameters.
$resourceGroupName = "@lab.CloudResourceGroup(RG1).Name"
$storageAccountName = "sa@lab.LabInstance.Id"
$containerName = "backup"
$blobName = "walmart-product-with-embeddings-dataset-usa.csv"

$sqlServerName = "sql@lab.LabInstance.Id"
$databaseName = "freeDB"
$sqlAdminUser = "azureadmin"
$sqlAdminPassword = "QWERTqwert12345"
$tableName = "walmart_product_details"

Write-Output "Parameters set and temporary directory is '$TempDir'."
