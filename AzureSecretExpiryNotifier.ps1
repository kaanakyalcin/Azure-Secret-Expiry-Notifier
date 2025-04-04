# Azure AD App Registration details
$clientId = "your-client-id"
$tenantId = "your-tenant-id"
$clientSecret = "your-client-secret"

# Notification details
$notificationEmails = @("admin@example.com", "security@example.com")  # List of recipients
$senderEmail = "noreply@example.com"  # Sender's email
$expirationThresholdDays = 30
$today = Get-Date
$emailSubject = "App Registration Client Secret Expiration Alert"

# Step 1: Get an access token
$tokenUri = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"
$body = @{
    client_id     = $clientId
    scope         = "https://graph.microsoft.com/.default"
    client_secret = $clientSecret
    grant_type    = "client_credentials"
}
$response = Invoke-RestMethod -Method Post -Uri $tokenUri -Body $body
$token = $response.access_token
if (-not $token) {
    Write-Output "Failed to retrieve access token. Check your Azure AD credentials."
    exit 1
}
Write-Output "Access token retrieved."

# Fetch App Registrations
$uri = "https://graph.microsoft.com/v1.0/applications"
$headers = @{ Authorization = "Bearer $token" }
$appRegistrations = Invoke-RestMethod -Uri $uri -Headers $headers

# Initialize the email body
$emailBody = "The following App Registration client secrets are about to expire:`n`n"

foreach ($app in $appRegistrations.value) {
    # Fetch password credentials for each app
    $passwordUri = "https://graph.microsoft.com/v1.0/applications/$($app.id)/passwordCredentials"
    $passwordCredentials = Invoke-RestMethod -Uri $passwordUri -Headers $headers
    foreach ($secret in $passwordCredentials.value) {
        $endDate = [datetime]$secret.endDateTime
        $daysRemaining = ($endDate - $today).Days
        if ($daysRemaining -le $expirationThresholdDays) {
            $emailBody += "App: $($app.displayName) - Expiration Date: $($secret.endDateTime) - Days Remaining: $daysRemaining`n"
        }
    }
}

# Send email if any secrets are expiring
if ($emailBody -ne "The following App Registration client secrets are about to expire:`n`n") {
    $recipients = @()
    foreach ($email in $notificationEmails) {
        $recipients += @{ EmailAddress = @{ Address = $email } }
    }
    $emailMessage = @{
        Message = @{
            Subject = $emailSubject
            Body = @{
                ContentType = "Text"
                Content = $emailBody
            }
            ToRecipients = $recipients
        }
        SaveToSentItems = "false"
    }
    $sendEmailUri = "https://graph.microsoft.com/v1.0/users/$senderEmail/sendMail"
    Invoke-RestMethod -Uri $sendEmailUri -Method POST -Headers @{ Authorization = "Bearer $token" } -Body ($emailMessage | ConvertTo-Json -Depth 10) -ContentType "application/json"
    Write-Output "Notification email sent."
} else {
    Write-Output "No expiring client secrets found."
}

Write-Output "Script execution complete."
