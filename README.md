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
  `python3 config.py master`  
  - slaveを作る場合はargsをslaveに切り替え