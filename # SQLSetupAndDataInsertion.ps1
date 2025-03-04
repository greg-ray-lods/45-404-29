# SQLSetupAndDataInsertion.ps1

# Set up the SQL connection and create the table if it doesn't exist.
$connectionString = "Server=tcp:$sqlServerName.database.windows.net,1433;Database=$databaseName;User ID=$sqlAdminUser;Password=$sqlAdminPassword;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"

$createTableQuery = @"
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'walmart_product_details')
BEGIN
    CREATE TABLE walmart_product_details (
        id INT PRIMARY KEY,
        source_unique_id NVARCHAR(255),
        crawl_timestamp DATETIME,
        product_url NVARCHAR(500),
        product_name NVARCHAR(255),
        description NVARCHAR(MAX),
        list_price DECIMAL(10,2),
        sale_price DECIMAL(10,2),
        brand NVARCHAR(255),
        item_number NVARCHAR(255),
        gtin NVARCHAR(50),
        package_size NVARCHAR(255),
        category NVARCHAR(255),
        postal_code NVARCHAR(20),
        available BIT,
        embedding VARBINARY(MAX)
    )
END
"@

$tableCreated = $false
while (-not $tableCreated) {
    try {
        $sqlConnection = New-Object System.Data.SqlClient.SqlConnection($connectionString)
        $sqlConnection.Open()
        $command = $sqlConnection.CreateCommand()
        $command.CommandText = $createTableQuery
        $command.ExecuteNonQuery()
        Write-Output "SQL table verified/created in '$databaseName'."
        $tableCreated = $true
    } catch {
        Write-Output "Error creating table. Retrying..."
        Start-Sleep -Seconds 6
    } finally {
        $sqlConnection.Close()
    }
}

# Insert CSV data into the SQL table.
$dataInserted = $false
while (-not $dataInserted) {
    try {
        $csvData = Import-Csv -Path $LocalCsvFilePath
        Write-Output "CSV file imported. Inserting data..."

        $sqlConnection = New-Object System.Data.SqlClient.SqlConnection($connectionString)
        $sqlConnection.Open()

        foreach ($row in $csvData) {
            $ProductName = $row.ProductName -replace "'", "''"
            $Category = $row.Category -replace "'", "''"
            $Supplier = $row.Supplier -replace "'", "''"
            $Price = if ([string]::IsNullOrWhiteSpace($row.Price)) { 0.00 } else { [decimal]::Parse($row.Price) }
            $StockQuantity = if ([string]::IsNullOrWhiteSpace($row.StockQuantity)) { 0 } else { [int]::Parse($row.StockQuantity) }

            $query = "INSERT INTO Products (ProductName, Category, Price, StockQuantity, Supplier) 
                      VALUES ('$ProductName', '$Category', $Price, $StockQuantity, '$Supplier')"
            Write-Output "Executing query: $query"
            $command = $sqlConnection.CreateCommand()
            $command.CommandText = $query
            $command.ExecuteNonQuery()
        }
        Write-Output "Data insertion complete."
        $dataInserted = $true
    } catch {
        Write-Output "Error inserting data. Retrying..."
        Start-Sleep -Seconds 6
    } finally {
        $sqlConnection.Close()
    }
}
