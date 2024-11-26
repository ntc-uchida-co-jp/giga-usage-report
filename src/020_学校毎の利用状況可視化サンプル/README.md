<a name="top"></a>

# Microsoft 365 学校毎の利用状況可視化サンプル利用ガイド
Microsoft 365 学校毎の利用状況可視化サンプルのPBITファイルのセットアップと利用方法を解説します。

## Microsoft 365 学校毎の利用状況可視化サンプルについて
学校毎のMicrosoft 365 の利用状況を可視化します。  
利用日数に応じた区分された利用人数および利用率を、学校毎に集計します。

|<img src="https://github.com/ntc-uchida-co-jp/giga-usage-report/blob/main/020_%E5%AD%A6%E6%A0%A1%E6%AF%8E%E3%81%AE%E5%88%A9%E7%94%A8%E7%8A%B6%E6%B3%81%E5%8F%AF%E8%A6%96%E5%8C%96%E3%82%B5%E3%83%B3%E3%83%97%E3%83%AB/images/020image_20241119.png" width="600">|
|---------|

## 目次

- [対象者](#-対象者)
- [利用システム](#-利用システム)
- [前提条件](#-前提条件)
- [事前準備](#-事前準備)
- [利用手順](#-利用手順)
- [関連情報](#-関連情報)

## 👨‍🏫👩‍🏫 対象者

本ガイドは、Microsoft 365 学校毎の利用状況可視化サンプルを閲覧するユーザーが対象です。  
Microsoft 365 学校毎の利用状況可視化サンプルでは、データ収集の対象となるユーザーの所属やIDなどの情報を匿名化せずに利用します。そのため、システム全体の管理者など、テナント全所属者に関する情報の閲覧権限を持ったユーザーのみの利用が推奨されます。

## 💻 利用システム

| システム名 | 動作環境 | 概要 |
|---------|---------|---------|
| Power BI Desktop | ローカルPC | テンプレートファイルの読み込みとPower BI サービスへの発行を行います。|
| Power BI サービス | クラウド | マイワークスペースでレポートの閲覧とデータ更新を行います。|

## ✅ 前提条件

Microsoft 365 学校毎の利用状況可視化サンプルを使用するには以下の条件が必要です。

1. **Microsoft 365 アカウント**  
   Power BI Desktop や Power BI サービスにサインインするための有効な Microsoft 365 アカウントが必要です。

2. **Power BI Desktop のインストール**  
   PCに Power BI Desktop がインストールされていることを確認してください。  
   インストールにはPCの管理者権限が必要になる場合があります。  
   詳細は[こちら（Power BI Desktop の取得 - Power BI | Microsoft Learn）](https://learn.microsoft.com/ja-jp/power-bi/fundamentals/desktop-get-the-desktop)の手順に従ってください。

4. **インターネット接続**  
   Power BI Desktop からデータソースとなる SharePoint Online へのアクセスにインターネット接続が必須です。

5. **データソースへのアクセス権**  
   SharePoint Online サイト上のデータソースへのアクセス権限を持っていることを確認してください。

## 📥 事前準備

### 1. 名簿ファイルの準備

端末の利用状況を学校毎に可視化するためには、各ユーザーのIDや所属情報を含む名簿ファイルが必要になります。  

1. [サンプルファイル](https://github.com/ntc-uchida-co-jp/giga-usage-report/tree/main/010_%E3%83%86%E3%83%8A%E3%83%B3%E3%83%88%E3%81%AE%E5%88%A9%E7%94%A8%E7%8A%B6%E6%B3%81%E5%8F%AF%E8%A6%96%E5%8C%96%E3%82%B5%E3%83%B3%E3%83%97%E3%83%AB/pbit)を参考に、以下の項目で構成されるxlsxファイルを作成します。ファイル名は「yyyy-mm-dd_M365名簿.xlsx」としてください。  
    - yyyy-mm-ddには名簿作成時の日付を入力します。2024年4月1日にファイルを作成した場合、ファイル名は「2024-04-01_M365名簿.xlsx」となります。
    
   | 列名 | 格納されるデータの内容 | 例 |
   |---|---|---|
   | **年度** | 所属の対象となる年度 | 2024 |
   | **所属名** | 所属する学校の名称 | ダミー小学校<br>教育委員会　など |
   | **M365ID** | 各ユーザーのMicrosoft 365 ID | aaaaa@bbb.onmicrosoft.com<br>xxx@yyy.ed.jp　など |
   | **氏名** | ユーザーの氏名 | 内田　洋子<br>youko-uchida　など |
   | **役割** | ユーザーの役割・肩書 | 児童生徒<br>教員<br>全体管理者　のいずれか |
   | **学年** | ユーザーの学年 | 1<br>※相当するものがなければ空欄でもよい |
   | **学級名** | ユーザーの所属する学級名 | 1年1組<br>※相当するものがなければ空欄でもよい |

2. 作成したファイルを Share Point Online の以下の場所に格納します。  

   [https://{テナントドメイン}.sharepoint.com/sites/Roster/M365名簿/school_year=yyyy/](https://{テナントドメイン}.sharepoint.com/sites/Roster/M365名簿/school_year=yyyy/)  

   - 「yyyy」には登録する名簿の年度が入ります。2024年度分の名簿ファイルを登録したい場合、「school_year=2024」という名前のフォルダになります。  
   - フォルダが無い場合は手動で作成してください。

> [!IMPORTANT]
> **名簿ファイルの更新について**  
> 名簿ファイルは、年度毎に最新のものを用意する必要があります。年度が切り替わる際には、Share Point Online 上に「school_year=yyyy」フォルダを追加し、新年度用の名簿を格納してください。  
> + **例）**  2025年度になったら、Share Point Online上に「school_year=2025」というフォルダを新規作成します。また、2025年度用の名簿ファイル「2025-04-01_M365名簿.xlsx」も新規作成し、Share Point Online上の「school_year=2025」フォルダに格納します。    
> 
> 転出入などにより、年度の途中で名簿ファイルの情報に変更が生じた場合も、新たに名簿ファイルを作成してShare Point Online 上の「school_year=yyyy」フォルダに格納してください。
> + **例）**  2024年4月1日に「2024-04-01_M365名簿.xlsx」を作成している状態で、2024年9月1日に児童生徒の転出入があった場合、別途「2024-09-01_M365名簿.xlsx」を作成し、Share Point Online上の「school_year=2024」フォルダに格納します。

### 2. GitHubからのPBITファイルのダウンロード

1. [GitHubリポジトリ](https://github.com/ntc-uchida-co-jp/giga-usage-report/tree/main/010_%E3%83%86%E3%83%8A%E3%83%B3%E3%83%88%E3%81%AE%E5%88%A9%E7%94%A8%E7%8A%B6%E6%B3%81%E5%8F%AF%E8%A6%96%E5%8C%96%E3%82%B5%E3%83%B3%E3%83%97%E3%83%AB/pbit) にアクセスし、対象のPBITファイルをダウンロードします。

### 3. Power BI サービスの初回利用設定

初回利用時には、Power BI サービスで「Microsoft Fabric Free」ライセンスを有効にする必要があります。

1. Power BI サービスにサインインします。
2. サービス画面上の指示に従い、「Microsoft Fabric Free」ライセンスを開始します。
   |<img src="https://github.com/user-attachments/assets/ab8c661a-f4e4-4b51-b655-56d98bb336b8" width="600">|
   |---------|

4. 設定完了後、Power BI サービスの機能を利用できるようになります。

## 📝 利用手順

利用開始や日々のデータ更新などに関する手順は、Microsoft 365 テナント全体の利用状況可視化サンプル利用ガイドの[利用開始手順](https://github.com/ntc-uchida-co-jp/giga-usage-report/blob/main/010_%E3%83%86%E3%83%8A%E3%83%B3%E3%83%88%E3%81%AE%E5%88%A9%E7%94%A8%E7%8A%B6%E6%B3%81%E5%8F%AF%E8%A6%96%E5%8C%96%E3%82%B5%E3%83%B3%E3%83%97%E3%83%AB/README.md#-%E5%88%A9%E7%94%A8%E9%96%8B%E5%A7%8B%E6%89%8B%E9%A0%86) 以降をご確認ください。

## 📚 関連情報

本プロジェクトに関連するドキュメントはこちらです。

- [Power BI Desktop と Power BI サービスの比較 - Power BI | Microsoft Learn](https://learn.microsoft.com/ja-jp/power-bi/fundamentals/service-service-vs-desktop)
- [Power BI Desktop のインストールガイド（Power BI Desktop の取得 - Power BI | Microsoft Learn）](https://learn.microsoft.com/ja-jp/power-bi/fundamentals/desktop-get-the-desktop)

ご覧いただき、ありがとうございます。Microsoft 365 の利用状況把握に少しでもお役立ていただければ幸いです。

[Back to top](#top)
