<#
    .SYNOPSIS
        マスタリポジトリの内容を構築先GitHubリポジトリにコピー

    .DESCRIPTION
        マスタリポジトリ内の「.github」フォルダの内容を構築先のGitHubリポジトリにコピー

    .PARAMETER githubOrganizationName
        [必須] 構築先GitHubの組織名

    .PARAMETER githubRepositoryName
        [必須] 構築先GitHubのプライベートリポジトリ名

    .EXAMPLE
        PS> Github-Copy.ps1 -githubOrganizationName "your-organization-name" -githubRepositoryName "your-repository-name" -githubAccountName "your-github-account-name"  -githubAccountMail "your-github-account-email"
#>

Param(
    [Parameter(Mandatory=$true)]
    [String]$githubOrganizationName,

    [Parameter(Mandatory=$true)]
    [String]$githubRepositoryName,

    [Parameter(Mandatory=$true)]
    [String]$githubAccountName,

    [Parameter(Mandatory=$true)]
    [String]$githubAccountMail
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
    Write-Log -Message "Start Copying the content from GitHub to our private repository.."
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

    # 構築先GitHubプライベートリポジトリをクローン
    Write-Host "Cloning the target GitHub private repository."
    git clone https://github.com/$githubOrganizationName/$githubRepositoryName.git
    Set-Location $githubRepositoryName
    
    # マスタリポジトリの".github"フォルダをローカルのブランチにコピー
    Write-Host "Creating a new branch 'copy-dir' and copying the '.github' folder from the master repository."
    # ブランチの存在確認
    $branchName = "copy-dir"
    $branchExists = git branch --list $branchName
    if (-not $branchExists) {
        # ブランチが存在しない場合、新しいブランチを作成してチェックアウト
        git checkout -b $branchName
        Write-Output "Created and switched to branch '$branchName'"
    } else {
        # ブランチが既に存在する場合、そのブランチにチェックアウト
        git checkout $branchName
        Write-Output "Switched to existing branch '$branchName'"
    }

    # ソースとコピー先のパスを確認
    $sourcePath = Resolve-Path -Path "..\..\.github"
    $destinationPath = (Get-Location).Path

    Write-Host "Copying from '$sourcePath' to '$destinationPath'"

    # .github フォルダをコピー
    Copy-Item -Path $sourcePath.Path -Destination $destinationPath -Recurse -Force

    # コピー後の確認
    if (Test-Path -Path "$destinationPath\.github") {
        Write-Host "'.github' folder copied successfully to '$destinationPath'."
    } else {
        Write-Error "Failed to copy '.github' folder to '$destinationPath'."
        exit 1
    }

    git add .github
    git config --global user.name $githubAccountName
    git config --global user.email $githubAccountMail
    git commit -m "Copy .github to private repo"
    
    # 構築先GitHubプライベートリポジトリにプッシュする
    Write-Host "Pushing changes to the remote repository."
    git push origin copy-dir:main
    
    # ログアウト
    gh auth logout
    Set-Location ..
    Write-Log -Message "Work completed on GitHub."
    Write-Log -Message "Logging out from GitHub."
    
    # データを変更
    Write-Log -Message "Writing updated data to outputs.json file."
    $outputs.deployProgress."02" = "completed"
    $outputs | ConvertTo-Json | Set-Content -Path ".\outputs.json"
    
    Write-Log -Message "Execution of Copy-Github.ps1 is complete."
    Write-Log -Message "---------------------------------------------"
}
catch{
    # エラーが発生した場合
    $outputs.deployProgress."02" = "failed"
    $outputs | ConvertTo-Json | Set-Content -Path ".\outputs.json"

    Write-Log -Message "An error has occurred: $_" -Level "Error"
    Write-Log -Message "---------------------------------------------"
}