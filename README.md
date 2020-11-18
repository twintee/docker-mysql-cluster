# docker-mysql-cluster

## 📚 概要
私用で作ったmysql8系のクラスタノード作成用docker-composeとその他諸々  
基本pythonでコンテナの外から制御したい  

## 🌏 検証済み環境
- ubuntu :16.*, 18.*
    windowsも問題ないと思うが以下注意  
    - sudo コマンドはwindowsの管理者権限に置き換えて実施  
    - `git config --global core.autocrlf input`で改行設定変えてからこのリポジトリをclone

## ⚙ 使用法
- ノード生成
    1. 必要モジュール
        - python-dotenv  
        `pip install python-dotenv`
    1. `config.py`を実行。応答で必要情報を.envに書き出したり情報を付与したマウント用ファイルを生成する。  
        - masterを作る場合  
        `python3 config.py master`  
        - slaveを作る場合  
        `python3 config.py slave`  
        - master/slaveを個別設定（１ホストクラスタ等）の場合はmaster・slaveの両方実行
    1. (初回のみ)イメージ作成  
        `docker-compose build`
    1. (任意)sqlの初期データの追加  
        - `./mnt/sh_init/`の`masetr`と`slave`にdumpその他データを入れておけばコンテナ生成時にデータが追加される。  
        (ファイル名昇順で実施されるため注意。基本はナンバリングで管理が無難)  
    1. コンテナ生成
        `sudo python3 init.py`  
        - 応答は基本'y'でボリュームやlogの削除は都度判断。dumpはスクリプトから制御しない。
        - nodeの種類を切り替えたい場合config.pyをサイド実施してコンテナ生成スクリプトを再実行。
        - 1ホストでmaster/slave構成したい場合  
        `sudo python3 init.py -n all`  

- ダンプ・リストア
    - ダンプ作成  
        `python3 rep/dump.py`  
        - 1ホストクラスタの場合は下記のようにオプションでnode強制  
            `python3 rep/dump.py -n master`  
            その他オプション  
            - `--all` or `-a`: `--all-databases`でdump作成  
            - `--compress` or `-c`: 作成されたdumpのzip圧縮ファイルも作成  
    - リストア(レプリケーションのデタッチ・アタッチ処理兼用)  
        `python3 rep/restore.py`  
        - 1ホストクラスタの場合は下記のようにオプションでnode強制  
            `python3 rep/restore.py -n master`  
        - slaveノードで実施した場合のみデタッチとアタッチリストアの前後に実施される  
    - (slave限定)デタッチ  
        `python3 rep/detach.py`  
        - 1ホストクラスタの場合は下記のようにオプションで強制  
            `python3 rep/detach.py -f`  
    - (slave限定)アタッチ  
        `python3 rep/attach.py`  
        - 1ホストクラスタの場合は下記のようにオプションで強制  
            `python3 rep/attach.py -f`  
