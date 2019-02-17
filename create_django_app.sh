#!/bin/sh

if [ $# -eq 2 ]; then
  if [ $1 = 'clear' ]; then
    echo -n "アプリケーション ${2} を削除しますか？[y/N]:"
    read ok_goto
    case $ok_goto in
      y)
        rm -rf $2
        pyenv uninstall $2
        sudo rm -f /etc/logrotate.d/django_app_${2}
        sudo rm -f /etc/nginx/conf.d/django_app_${2}.conf

        echo "環境の削除が完了しました"
        ;;
      *)
        echo "削除がキャンセルされました"
        ;;
    esac
  fi
  exit
fi

###
# 環境変数設定
###
HOME=$(cd $(dirname $0); pwd)
resource_dir=$HOME/.create_django_app_resources
source_uwsgi=$resource_dir/uwsgi.ini
source_nginx=$resource_dir/nginx.conf
source_logrotate=$resource_dir/logrotate.conf
source_bin=$resource_dir/bin/*
source_port=$resource_dir/used_port
source_gitignore=$resource_dir/.gitignore
default_port=`cat $source_port`
default_port=$((default_port + 1))
log_user=$(whoami)
log_group=$(whoami)

###
# 環境情報入力
###
echo -n "プロジェクト名: "
read project_name

echo "利用するpythonのバージョンを指定してください"
pyenv versions | grep -E "[1-9].[0-9].[0-9]$"

# python の最新バージョンを取得
DEFAULT_PYTHNO_VER=`pyenv versions | grep -E "[1-9].[0-9].[0-9]$" | tail -n 1 | xargs`

echo -n "user Python version [${DEFAULT_PYTHNO_VER}]:"
read py_version

if [ -n $py_version ]; then
  py_version=$DEFAULT_PYTHNO_VER
fi

# port
echo -n "use port [${default_port}]:"
read use_port
if [ -n $default_port ]; then
  use_port=$default_port
fi

echo -n "ドメイン名 [${project_name}.local]:"
read domain_name
if [ -n $domain_name ]; then
  domain_name=${project_name}.local
fi


###
# 環境構築開始
###
mkdir $project_name

# 環境構築
cd $project_name
cp $source_gitignore .gitignore

echo "virtualenv作成 pyenv virtualenv $py_version $project_name"
pyenv virtualenv $py_version $project_name

echo "activate ${project_name}"
pyenv local $project_name
pip install --upgrade pip

echo "初期パッケージインストール"
echo "django django-filter djangorestframework Markdown pysqlite3 uWSGI uwsgitop"
pip install django django-filter djangorestframework Markdown pysqlite3 uWSGI uwsgitop

echo "djangoプロジェクト作成"
django-admin startproject webapp .

echo "依存ディレクトリの作成"
mkdir -p logs/web
mkdir -p bridge_data/bin
mkdir -p bridge_data/conf/logrotate.d
mkdir -p bridge_data/conf/nginx
mkdir -p bridge_data/conf/uwsgi
mkdir -p bridge_data/run

echo "uwsgi起動スクリプトのコピー"
cp $source_bin bridge_data/bin/

###
# 設定ファイルを環境に合わせて置換する
###

echo "設定ファイルの生成"

# uwsgi.ini
echo "uwsgi.iniの作成"
out_file="bridge_data/conf/uwsgi/uwsgi.ini"
project_dir=$HOME/$project_name
replace_var=${project_dir//\//\\/}
replace_var="s/___project_dir___/${replace_var}/g"
cat ${source_uwsgi} | sed $replace_var > $out_file
sed -i -e "s/___project_name___/${project_name}/g" $out_file
sed -i -e "s/___port___/${use_port}/g" $out_file

# nginxの設定ファイル
echo "nginxファイルの作成 ${replace_var} ${source_nginx}"
out_file="bridge_data/conf/nginx/${project_name}.conf"
cat ${source_nginx} | sed $replace_var > $out_file
sed -i -e "s/___port___/${use_port}/g" $out_file
sed -i -e "s/___server_name___/${domain_name}/g" $out_file

echo "/etc/nginx/conf.d/にシンボリック作成"
sudo ln -s ${project_dir}/${out_file} /etc/nginx/conf.d/django_app_${project_name}.conf

# logrotateの設定ファイル
echo "logrotateファイルの作成 ${replace_var} ${source_logrotate}"
out_file="/etc/logrotate.d/django_app_${project_name}"
link_file="${project_dir}/bridge_data/conf/logrotate.d/${project_name}.conf"
sudo sed -e $replace_var $source_logrotate | sudo tee $out_file
sudo sed -i -e "s/___user___/${log_user}/g" $out_file
sudo sed -i -e "s/___group___/${log_group}/g" $out_file
sudo chown root.root $out_file
sudo ln -s $out_file $link_file

echo $use_port > $source_port

echo "----- 設定状況確認 -----"
sudo nginx -t
sudo logrotate -dv /etc/logrotate.conf
