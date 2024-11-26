<#
    .SYNOPSIS
        SharePointサイトの作成

    .DESCRIPTION
        M365テナントデータを蓄積するためのSharePointサイトの作成
        及び、Entra ID アプリケーションへの権限付与

    .PARAMETER applicationId
        [必須] Entra ID アプリケーションID

    .PARAMETER securityGroupObjectId
        [必須] SharePointサイトに対してアクセス権を付与するためのEntra ID セキュリティグループのObject ID

    .EXAMPLE
        PS> Create-SharepointSite.ps1 -applicationId "your-application-id" -securityGroupObjectId "your-security-group-object-id"
#>

Param(
    [Parameter(Mandatory=$true)]
    [String]$applicationId,

    [Parameter(Mandatory=$true)]
    [String]$securityGroupObjectId
)

# ログファイルの生成とフォルダの確認
$date = (Get-Date).ToString("yyyyMMdd")
$logFolder = ".\log"
$logFile = "$logFolder\$date`_log.txt"
$outputs = Get-Content -Path ".\outputs.json" | ConvertFrom-Json

# logフォルダが存在しない場合は作成
if (!(Test-Path -Path $logFolder)) {
    New-Item -ItemType Directory -Path $logFolder | Out-Null
}

# ログ出力関数
function Write-Log {
    param (
        [string]$Message,
        [ValidateSet("Info", "Warning", "Error")]
        [string]$Level = "Info"
    )
        
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    switch ($Level) {
        "Info" {
            Write-Host "[INFO] $Message" -ForegroundColor White
            $logMessage = "$timestamp - [INFO] $Message"
        }
        "Warning" {
            Write-Host "[WARNING] $Message" -ForegroundColor Yellow
            $logMessage = "$timestamp - [WARNING] $Message"
        }
        "Error" {
            Write-Host "[ERROR] $Message" -ForegroundColor Red
            $logMessage = "$timestamp - [ERROR] $Message"
        }
    }
    # ログファイルに出力
    $logMessage | Out-File -FilePath $logFile -Append
}

try {
    # Azure CLIにログイン
    Write-Log -Message "Logging into Azure CLI."
    az login --allow-no-subscriptions

    # ログインに成功したかを判定
    $exitCode = $LASTEXITCODE
    if ($exitCode -ne 0) {
        throw "Azure CLI login failed with exit code $exitCode"
    } else {
        Write-Log -Message "Azure CLI login succeeded."
    }

    # 必要な情報を取得
    ## Azure CLIを使って現在サインインしているユーザー情報を取得
    Write-Log -Message "Get information of the currently signed-in user."

    $userMail = az ad signed-in-user show --query userPrincipalName --output tsv
    # 取得できたかの判定
    if ([string]::IsNullOrEmpty($userMail)) {
        Write-Log -Message "Failed to get signed-in user's email address."
        throw "Failed to get signed-in user information"
    } else {
        Write-Log -Message "Signed-in user email got successfully: $userMail"
    }

    # Microsoft Graphに接続
    Connect-AzAccount

    $tenantInfo = Get-AzTenant
    # 取得できたかの判定
    if (-not $tenantInfo) {
        Write-Log -Message "Failed to get tenant information."
        throw "Failed to get Tenant information"
    } else {
        Write-Log -Message "Tenant information got successfully."
    }

    ## テナント情報を取得
    Write-Log -Message "Get tenant information."
    $fullDomain = $tenantInfo.Domains[0]
    $tenantId = $tenantInfo.Id
    $domainParts = $fullDomain -split '\.'
    $tenantDomain = $domainParts[0]

    # SharePointサイト設定値
    Write-Log -Message "Defining SharePoint site settings."
    $siteName = "M365UsageRecords"
    $siteUrl = "https://$tenantDomain.sharepoint.com/sites/$siteName"
    $adminUrl = "https://$tenantDomain-admin.sharepoint.com"
    $template = "STS#3"  # チームサイトのテンプレート
    $localeId = 1041     # 日本語 (1041)
    $storageQuota = 1024 # 1GBのストレージ

    # SharePoint Online管理シェルに接続
    Write-Log -Message "Connecting to SharePoint Online Management Shell."
    Import-Module Microsoft.Online.SharePoint.PowerShell -DisableNameChecking
    Connect-SPOService -Url $adminUrl
    # 接続成功の判定
    if ($LASTEXITCODE -ne 0) {
        Write-Log -Message "Failed to connect to SharePoint Online Management Shell."
        throw "SharePoint Online Management Shell connection failed."
    } else {
        Write-Log -Message "Connected to SharePoint Online Management Shell successfully."
    }

    # サイトの存在確認
    Write-Log -Message "Checking if the SharePoint site already exists."
    try {
        # サイトが存在しない場合エラーが発生する
        Get-SPOSite -Identity $siteUrl -ErrorAction SilentlyContinue
        Write-Log -Message "SharePoint site already exists. No action taken."
    }
    catch {
        Write-Log -Message "No existing SharePoint site found. Creating a new site."
        New-SPOSite -Url $siteUrl -Owner $userMail -StorageQuota $storageQuota -Template $template -LocaleId $localeId -Title $siteName
        if ($LASTEXITCODE -ne 0) {
            Write-Log -Message "Failed to create SharePoint site."
            throw "SharePoint site creation failed."
        } else {
            Write-Log -Message "SharePoint site created successfully."
        }
    }

    # セキュリティグループのLoginNameを作成
    Write-Log -Message "Creating LoginName for the security group."
    $securityGroupLoginName = "c:0t.c|tenant|$securityGroupObjectId"

    # 作成したサイトにセキュリティグループをサイトコレクション管理者として追加
    Write-Log -Message "Adding the security group as a site collection administrator."
    New-SPOSiteGroup -Site $siteUrl -Group "Access Permission Group for M365 Usage Report" -PermissionLevels "Full Control"
    Add-SPOUser -Site $siteUrl -LoginName $securityGroupLoginName -Group "Access Permission Group for M365 Usage Report"

    # Microsoft Graphに接続
    Write-Log -Message "Connecting to Microsoft Graph."
    try {
        Connect-MgGraph -Scopes "Application.ReadWrite.All", "Sites.Read.All", "Sites.FullControl.All"
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to connect to Microsoft Graph."
        }
        Write-Log -Message "Connected to Microsoft Graph successfully."
    } 
    catch {
        throw "Microsoft Graph connection failed. : $_"
    }


    # サービスプリンシパルの作成
    Write-Log -Message "Creating a service principal."
    New-MgServicePrincipal -AppId $applicationId -ErrorAction SilentlyContinue

    # アプリケーションIDを使用してサービスプリンシパルを取得
    Write-Log -Message "Getting the service principal."
    $servicePrincipal = Get-MgServicePrincipal -Filter "AppId eq '$applicationId'"

    # サービスプリンシパルIDの表示
    Write-Log -Message "Service Principal ID: $($servicePrincipal.Id)"

    # サイト情報の取得
    Write-Log -Message "Getting site information."
    $siteInfo = Get-MgSite -SiteId "$tenantDomain.sharepoint.com:/sites/$siteName"
    # 取得できたかの判定
    if (-not $siteInfo) {
        Write-Log -Message "Failed to retrieve site information for '$siteName'."
        throw "Site information retrieval failed."
    } else {
        Write-Log -Message "Site information retrieved successfully for '$siteName'."
    }
    $siteId = $siteInfo.Id

    # サイトIDの表示
    Write-Log -Message "Site ID: $siteId"

    # アプリの権限付与用のパラメータ設定
    $params = @{
        roles = @("write")
        grantedToIdentities = @(
            @{
                application = @{
                    id = $applicationId
                    displayName = $servicePrincipal.DisplayName
                }
            }
        )
    }

    # サイトに対するアプリの権限を付与
    Write-Log -Message "Granting the application permissions to the site."
    New-MgSitePermission -SiteId $siteId -BodyParameter $params
    
    # 接続を切断
    Write-Log -Message "Logging out from Azure CLI."
    az logout
    Write-Log -Message "Logging out from Microsoft Graph."
    Disconnect-MgGraph
    Write-Log -Message "Logging out from SharePoint Online Management Shell."
    Disconnect-SPOService
    
    # データを変更
    Write-Log -Message "Writing updated data to outputs.json file."
    $outputs.tenantId = $tenantId
    $outputs.tenantDomain = $tenantDomain
    $outputs.siteUrl = $siteUrl
    $outputs.deployProgress."05" = "completed"
    $outputs | ConvertTo-Json | Set-Content -Path ".\outputs.json"
    
    Write-Log -Message "Execution of Create-SharepointSite.ps1 is complete."
    Write-Log -Message "---------------------------------------------"
}
catch{
    # エラーが発生した場合
    $outputs.deployProgress."05" = "failed"
    $outputs | ConvertTo-Json | Set-Content -Path ".\outputs.json"

    Write-Log -Message "An error has occurred: $_" -Level "Error"
    Write-Log -Message "---------------------------------------------"
}
