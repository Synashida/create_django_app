# このアプリケーションについて
uwsgiとnginxを使って動作させることを前提としたdjangoのアプリケーションの生成スクリプトです。

### 対応プラットフォーム
CentOS7
インストール済み要件 
1. logrotate (/etcにインストールされていること)
2. nginx     (/etcにインストールされていること)
3. pyenv

### 実行方法 (すぐ使いたい人向け）
create_django_app.shと.create_django_appディレクトリをdjangoプロジェクトを格納する一つ上のディレクトリに配置します。

ex) clone後のディレクトリの上位ディレクトリだとした場合
cp create_django_app.sh ../
cp -r .create_django_app ../

cd ..
./create_django_app.sh

## よく読みたい人向け

### 実行前に
sudoが可能なユーザで実行してください。
初期インストールパッケージは最小構成になっていて、


### 実行方法
create_django_app.shと.create_django_appディレクトリをdjangoプロジェクトを格納する一つ上のディレクトリに配置します。

ex) clone後のディレクトリの上位ディレクトリだとした場合
cp create_django_app.sh ../
cp -r .create_django_app ../

cd ..
./create_django_app.sh
