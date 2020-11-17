# docker-mysql-cluster

## 📚 概要
私用で作ったmysqlのクラスタノード作成用docker-composeとその他諸々  
基本pythonでコンテナの外から制御したい  

## 🌏 検証済み環境
- ubuntu :16.*, 18.*

## ⚙ 使用法
1. 必要モジュール
- python-dotenv  
`pip install python-dotenv`
1. config.pyで必要情報を.envに書き出したり情報を付与したマウント用ファイルを生成する
- masterを作る場合  
`python3 config.py master`  
- slaveを作る場合  
`python3 config.py slave`  
- master/slaveを１ホストで作る場合は上記コマンドを両方実施
1. イメージ作成
`docker-compose build`
1. コンテナ生成
  - configで設定したnodeが作られる(master or slave)
  - 1ホストでmaster/slave構成したい場合
    `python3 init.py -n all`  
  - 1ホストでmaster/slave構成したい場合
    `python3 init.py -n all`  
