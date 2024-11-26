<#
    .SYNOPSIS
        GitHubシークレットの設定とワークフローの実行 

    .DESCRIPTION
        GitHubシークレットを設定したのちに、GitHubActionsのワークフローを実行

    .PARAMETER tenantId
        [必須] AzureテナントのテナントID

    .PARAMETER tenantDomain
        [必須] Azureテナントのサブドメイン
        ex. ドメイン名がexample.onmicrosoft.comの場合、サブドメインはexample

    .PARAMETER applicationId
        [必須] Entra ID アプリケーションID

    .PARAMETER githubOrganizationName
        [必須] 構築先GitHubの組織名

    .PARAMETER githubRepositoryName
        [必須] 構築先GitHubのプライベートリポジトリ名

    .EXAMPLE
        PS> Exec-GitHubActions.ps1 -tenantId "your-tenant-id" -tenantDomain "your-tenant-domain" -applicationId "your-application-id" -githubOrganizationName "your-organization-name" -githubRepositoryName "your-repository-name"
#>

Param(
    [Parameter(Mandatory=$true)]
    [String]$tenantId,

    [Parameter(Mandatory=$true)]
    [String]$tenantDomain,

    [Parameter(Mandatory=$true)]
    [String]$applicationId,

    [Parameter(Mandatory=$true)]
    [String]$githubOrganizationName,

    [Parameter(Mandatory=$true)]
    [String]$githubRepositoryName
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

try{
    # GitHubアカウントにログイン
    Write-Log -Message "Logging into GitHub account."
    Write-Log -Message "Start adding GitHub Secret and executing GitHubActions.."
    Write-Host "Please follow the instructions to log in."
    gh auth login --web --git-protocol https
    
    # ログインに成功したかを判定
    $exitCode = $LASTEXITCODE
    if ($exitCode -ne 0) {
        throw "GitHub CLI login failed with exit code $exitCode"
    }
    else {
        Write-Log -Message "GitHub CLI login succeeded."
    }

    # GitHubシークレットの追加
    Write-Log -Message "Adding GitHub Sercret."
    gh secret set AZURE_TENANT_ID --body $tenantId --repo $githubOrganizationName/$githubRepositoryName
    gh secret set AZURE_TENANT_NAME --body $tenantDomain --repo $githubOrganizationName/$githubRepositoryName
    gh secret set AZURE_CLIENT_ID --body $applicationId --repo $githubOrganizationName/$githubRepositoryName

    # ワークフローの実行
    Write-Log -Message "Executing GitHubActions."
    gh workflow run daily_workflow.yml --repo $githubOrganizationName/$githubRepositoryName
    
    # ログアウト
    gh auth logout
    Write-Log -Message "Work completed on GitHub."
    Write-Log -Message "Logging out from GitHub."

    # データを変更
    Write-Log -Message "Writing updated data to outputs.json file."
    $outputs.deployProgress."06" = "completed"
    $outputs | ConvertTo-Json | Set-Content -Path ".\outputs.json"
 
    Write-Log "Execution of Exec-GitHubActions.ps1 is complete."
    Write-Log "---------------------------------------------"
}
catch{
    # エラーが発生した場合
    $outputs.deployProgress."06" = "failed"
    $outputs | ConvertTo-Json | Set-Content -Path ".\outputs.json"

    Write-Log -Message "An error has occurred: $_" -Level "Error"
    Write-Log -Message "---------------------------------------------"
}





