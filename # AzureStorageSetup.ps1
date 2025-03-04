# AzureStorageSetup.ps1

# Ensure Az.Storage is installed
if (-not (Get-Module -Name Az.Storage -ListAvailable)) {
    Install-Module -Name Az.Storage -AllowClobber -Force
}

# Retrieve Storage Account Context
$ctx = $null
while (-not $ctx) {
    try {
        $storageAccount = Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName -ErrorAction SilentlyContinue
        if ($storageAccount) {
            $ctx = $storageAccount.Context
            Write-Output "Storage account context retrieved successfully."
        } else {
            Write-Output "Storage account not found. Retrying in 6 seconds..."
            Start-Sleep -Seconds 6
        }
    } catch {
        Write-Output "Error retrieving storage account context. Retrying..."
        Start-Sleep -Seconds 6
    }
}

# Ensure the container exists
$containerExists = $false
while (-not $containerExists) {
    try {
        $container = Get-AzStorageContainer -Context $ctx -Name $containerName -ErrorAction SilentlyContinue
        if ($container) {
            Write-Output "Container '$containerName' exists."
            $containerExists = $true
        } else {
            Write-Output "Container '$containerName' not found. Creating it..."
            New-AzStorageContainer -Context $ctx -Name $containerName -Permission Off
            Start-Sleep -Seconds 5
            $container = Get-AzStorageContainer -Context $ctx -Name $containerName -ErrorAction SilentlyContinue
            if ($container) {
                Write-Output "Container '$containerName' created successfully."
                $containerExists = $true
            } else {
                Write-Output "Failed to verify container creation. Retrying..."
            }
        }
    } catch {
        Write-Output "Error checking/creating container. Retrying in 6 seconds..."
    }
    Start-Sleep -Seconds 6
}
