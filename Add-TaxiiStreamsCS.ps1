# Login (Cloud Shell handles authentication, no explicit login required)

# Variables
$SubscriptionId = "your-subscription-id"
$ResourceGroupName = "your-resource-group-name"
$WorkspaceName = "your-sentinel-workspace-name"

# Get Access Token
$accessToken = (Get-AzAccessToken -ResourceUrl "https://management.azure.com").Token

# Define TAXII Streams
$taxiiStreams = @(
    @{
        name       = "TAXIIStream1"
        description = "Stream 1 Description"
        serverUrl  = "https://taxii.server1.com"
        collection = "Collection1"
        username   = "taxii-user1"
        password   = "taxii-password1"
    },
    @{
        name       = "TAXIIStream2"
        description = "Stream 2 Description"
        serverUrl  = "https://taxii.server2.com"
        collection = "Collection2"
        username   = "taxii-user2"
        password   = "taxii-password2"
    }
)

# Add TAXII Streams
foreach ($stream in $taxiiStreams) {
    $uri = "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.OperationalInsights/workspaces/$WorkspaceName/providers/Microsoft.SecurityInsights/dataConnectors/$($stream.name)?api-version=2023-01-01-preview"

    $body = @{
        properties = @{
            dataTypes = @{
                indicators = @{
                    state = "Enabled"
                }
            }
            config = @{
                taxiiServerUrl  = $stream.serverUrl
                taxiiCollection = $stream.collection
                username        = $stream.username
                password        = $stream.password
            }
            connectorUiConfig = @{
                title       = $stream.name
                description = $stream.description
            }
        }
    }

    $jsonBody = $body | ConvertTo-Json -Depth 10 -Compress

    try {
        $response = Invoke-RestMethod -Method Put -Uri $uri -Headers @{
            Authorization = "Bearer $accessToken"
        } -ContentType "application/json" -Body $jsonBody

        Write-Host "Successfully added TAXII Stream: $($stream.name)"
    } catch {
        Write-Host "Failed to add TAXII Stream: $($stream.name)"
        Write-Host "Error: $($_.Exception.Message)"
    }
}