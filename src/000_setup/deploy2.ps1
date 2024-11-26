<#
    .SYNOPSIS
        GitHub Actionsを用いたM365テナントデータ取得のための環境構築: 2

    .DESCRIPTION
        「params.json」の値に従って環境構築を行うため、事前に設定しておく

    .EXAMPLE
        PS> deploy2.ps1
#>

# ログファイルの生成とフォルダの確認
$date = (Get-Date).ToString("yyyyMMdd")
$logFolder = ".\log"
$logFile = "$logFolder\$date`_log.txt"
$paramsFilePath = ".\params.json"
$outputsFilePath = ".\outputs.json"
$runningScript = ""


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

# logフォルダが存在しない場合は作成
if (!(Test-Path -Path $logFolder)) {
    New-Item -ItemType Directory -Path $logFolder | Out-Null
}

try{
    # outputsの読み込み
    $outputs = Get-Content -Path $outputsFilePath | ConvertFrom-Json
    # JSONファイルを読み込み、オブジェクトに変換
    Write-Log -Message "Loading the JSON file and converting it to an object."
    $params = Get-Content -Path $paramsFilePath | ConvertFrom-Json

    # GitHubのフォーク
    $runningScript = "02_Copy-GitHub\Copy-GitHub.ps1"
    if($outputs.deployProgress."02" -ne "completed") {
        Write-Log -Message "Forking GitHub repository."
        .\02_Copy-GitHub\Copy-GitHub.ps1 -githubOrganizationName $params.githubOrganizationName -githubRepositoryName $params.githubRepositoryName -githubAccountName $params.githubAccountName -githubAccountMail $params.githubAccountMail
    }

    # Entra ID アプリケーション作成
    $runningScript = "03_Create-EntraIDApplication\Create-EntraIdApplication.ps1"
    if($outputs.deployProgress."03" -ne "completed") {
        Write-Log -Message "Creating Entra ID application."
        .\03_Create-EntraIDApplication\Create-EntraIdApplication.ps1 -githubOrganizationName $params.githubOrganizationName -githubRepositoryName $params.githubRepositoryName
    }
    
    # Entra ID グループ作成
    $runningScript = "04_Create-EntraIDGroup\Create-EntraIdGroup.ps1"
    if($outputs.deployProgress."04" -ne "completed") {
        Write-Log -Message "Creating Entra ID group."
        .\04_Create-EntraIDGroup\Create-EntraIdGroup.ps1
    }
    
    # outputsの再読み込み
    $outputs = Get-Content -Path $outputsFilePath | ConvertFrom-Json
    
    # SharePointサイト作成
    $runningScript = "05_Create-SharePointSite\Create-SharepointSite.ps1"
    if($outputs.deployProgress."02" -eq "completed" -and $outputs.deployProgress."03" -eq "completed" -and $outputs.deployProgress."04" -eq "completed" -and $outputs.deployProgress."05" -ne "completed") {
        Write-Log -Message "Creating SharePoint site."
        .\05_Create-SharePointSite\Create-SharepointSite.ps1 -applicationId $outputs.appId -securityGroupObjectId $outputs.securityGroupObjectId
    }

    # outputsの再読み込み
    $outputs = Get-Content -Path $outputsFilePath | ConvertFrom-Json

    # シークレットの作成とワークフローの実行
    $runningScript = "06_Exec-GitHubActions\Exec-GitHubActions.ps1"
    if($outputs.deployProgress."05" -eq "completed" -and $outputs.deployProgress."06" -ne "completed") {
        Write-Log -Message "Adding GitHub secret and executing GitHubActions."
        .\06_Exec-GitHubActions.ps1 -tenantId $outputs.tenantId -tenantDomain $outputs.tenantDomain -applicationId $outputs.appId -githubOrganizationName $params.githubOrganizationName -githubRepositoryName $params.githubRepositoryName
    }

    Write-Log -Message "Deployment is complete."
    Write-Log -Message "---------------------------------------------"
}
catch{
    # エラーが発生した場合
    Write-Log -Message "An error has occurred while running $runningScript." -Level "Error"
    Write-Log -Message "Please retry deploy2.ps1 script." -Level "Error"
}

