# Azure Secret Expiry Notifier

This script checks Azure App Registration client secrets and sends email notifications before they expire.  
It helps prevent authentication issues due to expired secrets in applications integrating with Azure.

## Features
- Retrieves all App Registrations in Azure AD
- Checks client secret expiration dates
- Sends notification emails if any secrets are close to expiration
- Uses Microsoft Graph API for authentication and data retrieval

## Setup & Usage
1. **Create an Azure App Registration**  
   - Go to **Azure Portal** → **Azure AD** → **App registrations** → **New registration**  
   - Note down the **Client ID**, **Tenant ID**, and **Client Secret**  
   
2. **Grant Required API Permissions**  
   - Under **Manage**, go to **API permissions**  
   - Select **Microsoft Graph**, then add the following **Application permissions**:  
     - `Mail.Read`
     - `Mail.Send`  
   - Click **Grant admin consent**  

3. **Set Up Azure Automation**  
   - Create an **Automation Account** in Azure  
   - Add a **Runbook** and paste the script  
   - Configure a **Schedule** to run it daily  

For a detailed step-by-step guide, check out the [Detailed Blog Post](https://wiseservices.co.uk/post/a3a10db6-02b5-4162-9773-cc3e2c618a47).
