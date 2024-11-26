<a name="top"></a>

# Microsoft 365 テナント全体の利用状況可視化サンプル利用ガイド

Microsoft 365 テナント全体の利用状況可視化サンプルのPBITファイルのセットアップと利用方法を解説します。

## 目次

- [対象者](#-対象者)
- [概要](#-概要)
- [前提条件](#-前提条件)
- [事前準備](#-事前準備)
- [利用開始手順](#-利用開始手順)
- [取得データ期間の変更方法](#-取得データ期間の変更方法)
- [関連情報](#-関連情報)

## 👨‍💻👩‍💻 対象者

本ガイドは、Microsoft 365 テナント全体の利用状況可視化サンプルを閲覧するユーザーが対象です。  
主な利用者はシステム管理者を想定しています。

## 💻 概要

テナント全体のMicrosoft 365 の利用状況を可視化します。  
利用日数に応じて区分された利用人数および利用率を集計します。

**【システム構成図】**
|<img src="https://github.com/ntc-uchida-co-jp/giga-usage-report/blob/tachizawa_umeReadme20241107/010_%E3%83%86%E3%83%8A%E3%83%B3%E3%83%88%E3%81%AE%E5%88%A9%E7%94%A8%E7%8A%B6%E6%B3%81%E5%8F%AF%E8%A6%96%E5%8C%96%E3%82%B5%E3%83%B3%E3%83%97%E3%83%AB/images/System_Configuration_Diagram.jpg" width="1000">|
|---------|

**【レポート画面】**
|<img src="https://github.com/user-attachments/assets/ef67bcaa-eb5f-47bd-859e-0b65edd0ffe4" width="600">|
|---------|

## ✅ 前提条件

Microsoft 365 テナント全体の利用状況可視化サンプルを使用するには以下の前提条件を満たす必要があります。
 
1. **Microsoft 365 アカウント**  
   Power BI Desktop や Power BI サービスにサインインするための有効な Microsoft 365 アカウントが必要です。

2. **Microsoft 365 A1ライセンス**  
   本プロジェクトのレポートを活用するためには、最低でもMicrosoft 365 A1ライセンスが必要です。  

3. **インターネット接続**  
   Power BI Desktop からデータソースとなる SharePoint Online へのアクセスやPower BI サービスのアクセスにインターネット接続が必須です。

4. **Power BI Desktop のインストール**  
   PCに Power BI Desktop がインストールされていることを確認してください。  
   インストールにはPCの管理者権限が必要になる場合があります。  
   詳細は[こちら（Power BI Desktop の取得 - Power BI | Microsoft Learn）](https://learn.microsoft.com/ja-jp/power-bi/fundamentals/desktop-get-the-desktop)の手順に従ってください。
   
6. **データソースへのアクセス権**  
   SharePoint Online サイト上のデータソースへのアクセス権限を持っていることを確認してください。

## 📥 事前準備

### 1. GitHubからのPBITファイルのダウンロード

レポートを利用開始するために、以下の手順でテンプレートをダウンロードできます。

1. [本件のマスタリポジトリ](https://github.com/ntc-uchida-co-jp/giga-usage-report/tree/main/010_%E3%83%86%E3%83%8A%E3%83%B3%E3%83%88%E3%81%AE%E5%88%A9%E7%94%A8%E7%8A%B6%E6%B3%81%E5%8F%AF%E8%A6%96%E5%8C%96%E3%82%B5%E3%83%B3%E3%83%97%E3%83%AB/pbit) にアクセスし、対象のPBITファイルをダウンロードします。

### 2. Power BI サービスの初回利用設定

初回利用時には、Power BI サービスで「Microsoft Fabric Free」ライセンスを有効にする必要があります。

1. Power BI サービスにサインインします。
2. サービス画面上の指示に従い、「Microsoft Fabric Free」ライセンスを開始します。
   |<img src="https://github.com/user-attachments/assets/ab8c661a-f4e4-4b51-b655-56d98bb336b8" width="600">|
   |---------|

4. 設定完了後、Power BI サービスの機能を利用できるようになります。

## 📝 利用開始手順

### 1. PBITファイルの利用開始

以下の手順に従い、テンプレートをPower BI Desktop で開きます。

1. 事前準備でダウンロードしたPBITファイルをダブルクリックし、Power BI Desktop で開きます。
2. サインインを求められたら、自身のMicrosoft 365 アカウントでサインインします。
   |<img src="https://github.com/ntc-uchida-co-jp/giga-usage-report/blob/f965455312381d76114e2ed159be5217a0fe94b1/010_%E3%83%86%E3%83%8A%E3%83%B3%E3%83%88%E3%81%AE%E5%88%A9%E7%94%A8%E7%8A%B6%E6%B3%81%E5%8F%AF%E8%A6%96%E5%8C%96%E3%82%B5%E3%83%B3%E3%83%97%E3%83%AB/images/Power_BI_Desktop_SignIn.jpg" width="600">|
   |---------|

### 2. パラメータの設定とデータソースの設定

テンプレートを設定しデータソースに接続できるようにします。

1. PBITファイルを開くと、以下のパラメータ設定を求められます。以下の情報を入力してください。
   | パラメータ | 設定値 |
   |---------|---------|
   |SiteUrl|[https://{テナントドメイン}.sharepoint.com/sites/M365UsageRecords/](https://{テナントドメイン}.sharepoint.com/sites/M365UsageRecords/)|
   |SchoolYearRange|3|
   
   - **SiteUrl**：データソースファイルが格納されているSharePoint Online サイトのURLを入力します。  
   - **SchoolYearRange**：取得するデータ期間の年度数を1以上の整数で入力します。  
     ※本システム運用開始以前のデータは取得できません。  
     ※システムの性能の都合上、上限は 9 を目安に設定して下さい。
     |<img src="https://github.com/user-attachments/assets/2fd5b4ee-2db1-4867-bb79-17bffe8bfd75" width="600">|
     |---------|

### 3. マイワークスペースへの発行

ブラウザでレポートを閲覧するために、Power BI サービスのマイワークスペースにレポートを発行します。

1. Power BI Desktop でレポートが完成したら、レポートファイルを保存します。
2. 「発行」を選択し、マイワークスペースに発行します。

   |<img src="https://github.com/user-attachments/assets/3cd4f1b8-727d-4690-b26d-b5fe35cce803" width="600">|
   |---------|

### 4. データソース資格情報の設定

マイワークスペースに発行後、Power BI サービスでデータソースにアクセスするために資格情報を設定する必要があります。  
以下の手順に従って設定してください。

1. Power BI サービスにサインインし、マイワークスペースを開きます。
2. 発行したセマンティックモデルを選択します。
3. [・・・] > [設定] > [データソースの資格情報] セクションから設定を行い、設定を保存します。

   |<img src="https://github.com/user-attachments/assets/5e02ffd0-0174-4fda-81bf-78020d9f787d" width="600">|
   |---------|

   |<img src="https://github.com/user-attachments/assets/1a0adb9e-a311-4f32-98e0-1ae6675bc8c8" width="600">|
   |---------|

   |<img src="https://github.com/user-attachments/assets/1900c21f-c4d5-4798-acf8-663329a717b0" width="300">|
   |---------|

4. 資格情報が設定されると、Power BI サービスでの自動更新や手動更新が可能となります。

### 5. データ取得の動作確認

Power BI サービスでデータの手動更新を行い、データ取得の動作確認を実施します。  

1. マイワークスペースを開きます。
2. データソースの資格情報を設定したセマンティックモデルを選択します。
3. マウスオーバーすると名称の右に表示される更新マーク（🔄）から手動更新します。
4. 「最新の情報に更新済み」の日時が更新されたら完了です。  
   ※3年度分のデータを取得する場合、更新完了まで15分程度かかります。
   |<img src="https://github.com/user-attachments/assets/a4d7b6eb-a3a6-4f38-8167-3b592c7c7ebe" width="600">|
   |---------|

### 6. データの自動更新設定

レポートで最新の情報を確認するためにデータの自動更新を設定する必要があります。  
以下の手順に従って設定してください。

1. マイワークスペースを開きます。
2. データソースの資格情報を設定したセマンティックモデルを選択します。
3. [・・・] > [設定] > [最新の情報に更新] セクションからスケジュール設定を行います。設定値は以下を参照してください。
   | 設定項目 | 設定値 |
   |---------|---------|
   |タイムゾーン|(UTC+09:00)大阪、札幌、東京|
   |情報更新スケジュールを構成|オン|
   |更新の頻度|毎日|
   |時刻|12:00PM|

   ※データ蓄積機能で最新データを取得するタイミングに合わせたスケジュール設定になります。

   |<img src="https://github.com/user-attachments/assets/5e02ffd0-0174-4fda-81bf-78020d9f787d" width="600">|
   |---------|

   |<img src="https://github.com/user-attachments/assets/b3571550-f59a-4dfa-91f7-58323ec5c4ef" width="600">|
   |---------|

## 🔄 取得データ期間の変更方法

### 1. パラメータの変更

マイワークスペースに発行後、取得するデータ期間の年度数を変更する場合は、以下の手順に従って設定してください。

1. Power BI サービスにサインインし、マイワークスペースを開きます。
2. 発行したセマンティックモデルを選択します。
3. [・・・] > [設定] > [パラメーター] セクションを開きます。
4. SchoolYearRange を任意の値に変更し、適用して設定を保存します。
   |<img src="https://github.com/user-attachments/assets/5e02ffd0-0174-4fda-81bf-78020d9f787d" width="600">|
   |---------|
   
   |<img src="https://github.com/user-attachments/assets/12e1ee35-0784-4d11-be53-c59ce1ca4afe" width="600">|
   |---------|

5. 変更後のパラメータでデータを取得する場合は、上述の「利用開始手順 5. データ取得の動作確認」を実施してください。

## 📚 関連情報

本プロジェクトに関連するドキュメントはこちらです。

- [Power BI Desktop と Power BI サービスの比較 - Power BI | Microsoft Learn](https://learn.microsoft.com/ja-jp/power-bi/fundamentals/service-service-vs-desktop)
- [Power BI Desktop のインストールガイド（Power BI Desktop の取得 - Power BI | Microsoft Learn）](https://learn.microsoft.com/ja-jp/power-bi/fundamentals/desktop-get-the-desktop)

ご覧いただき、ありがとうございます。GIGAスクール構想で導入した端末の利用状況把握に少しでもお役立ていただければ幸いです。

[Back to top](#top)

# 以下、削除予定＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝

3. [ファイル] > [オプションと設定] > [データソース設定] から、SharePoint Online サイトの認証情報を設定してください。

   |<img src="https://github.com/user-attachments/assets/be1233cb-3e15-4e21-bd03-9ea185b25c3a" width="600">|
   |---------|

   |<img src="https://github.com/user-attachments/assets/32256b3d-37e3-4a86-ba23-a549ada29703" width="600">|
   |---------|

   |<img src="https://github.com/user-attachments/assets/debae3b3-f659-4fb7-893e-9c811bacc066" width="300">|
   |---------|

   |<img src="https://github.com/user-attachments/assets/3a3f2e7e-565b-428d-9a48-831fa429460c" width="600">|
   |---------|

4. [ホーム] > [更新]ボタンをクリックして最新データを取得します。  
