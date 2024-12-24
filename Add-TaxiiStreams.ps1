# Variables
$TenantId = "your-tenant-id"
$ClientId = "your-client-id"
$ClientSecret = "your-client-secret"
$SubscriptionId = "your-subscription-id"
$ResourceGroupName = "your-resource-group-name"
$WorkspaceName = "your-sentinel-workspace-name"

# Authentication: Get OAuth Token
$body = @{
    grant_type    = "client_credentials"
    client_id     = $ClientId
    client_secret = $ClientSecret
    scope         = "https://management.azure.com/.default"
}
$authResponse = Invoke-RestMethod -Method Post -Uri "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token" -ContentType "application/x-www-form-urlencoded" -Body $body
$accessToken = $authResponse.access_token

# Define TAXII Streams
$taxiiStreams = @(
    @{
        name       = "TAXIIStream1"
        description = "Stream 1 Description"
        serverUrl  = "https://taxii.server1.com"
        collection = "Collection1"
        username   = "user1"
        password   = "password1"
    },
    @{
        name       = "TAXIIStream2"
        description = "Stream 2 Description"
        serverUrl  = "https://taxii.server2.com"
        collection = "Collection2"
        username   = "user2"
        password   = "password2"
    }
)

# Add TAXII Streams
foreach ($stream in $taxiiStreams) {
    $uri = "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.OperationalInsights/workspaces/$WorkspaceName/providers/Microsoft.SecurityInsights/dataConnectors?api-version=2023-01-01-preview"

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

    Invoke-RestMethod -Method Put -Uri $uri -Headers @{
        Authorization = "Bearer $accessToken"
    } -ContentType "application/json" -Body $jsonBody

    Write-Host "Added TAXII Stream: $($stream.name)"
}