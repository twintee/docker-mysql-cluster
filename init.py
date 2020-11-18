#! /usr/bin/env python
# -*- coding: utf-8 -*-

import os
import sys
import time
from os.path import join, dirname, abspath, isfile, isdir
import argparse

from dotenv import load_dotenv

dir_scr = os.path.abspath(os.path.dirname(__file__))
import helper as fn

os.chdir(dir_scr)
file_env = os.path.join(dir_scr, ".env")

def main(_args):
    """
    initialize container
    """

    # コンテナ削除
    cmd_down = "docker-compose down -v"
    for line in fn.cmdlines(_cmd=cmd_down):
        sys.stdout.write(line)

    fn.rmdir(join(dir_scr, "vol", "master", "data"))
    fn.rmdir(join(dir_scr, "vol", "master", "log"))
    fn.rmdir(join(dir_scr, "vol", "slave", "data"))
    fn.rmdir(join(dir_scr, "vol", "slave", "log"))
    fn.rmdir(join(dir_scr, "vol", "master", "dump"))
    fn.rmdir(join(dir_scr, "vol", "slave", "dump"))

    envs = fn.getenv(file_env)
    node = envs['NODE']
    if not _args.node is None:
        node = _args.node
    if node == "":
        print(f"[error] node type not set.")
        sys.exit()

    print(f"[info] run {node} node.")

    target = ""
    if node != "all":
        target = f"db-{node}"

    # サービス作成
    for line in fn.cmdlines(_cmd=f"docker-compose up -d {target}", _encode="utf8"):
        sys.stdout.write(line)

    # パーミッション調整(windows未検証)
    if os.name == "nt":
        nodes = ["node-mysql-master", "node-mysql-slave"]
        if node != "all":
            nodes = [f"node-mysql-{node}"]
        for ref in nodes:
            for line in fn.cmdlines(_cmd=f"docker exec -it {ref} chmod -R 664 /etc/mysql/conf.d"):
                sys.stdout.write(line)
            for line in fn.cmdlines(_cmd=f"docker exec -it {ref} chmod -R 664 /tmp/common/opt"):
                sys.stdout.write(line)
            fn.rmdir(join(dir_scr, "vol", node, "data"), True)
        # サービス作成
        for line in fn.cmdlines(_cmd=f"docker-compose restart {target}"):
            sys.stdout.write(line)


if __name__ == "__main__":

    parser = argparse.ArgumentParser(description='set env params')
    parser.add_argument('--node', '-n', help="(option) set generate node type. 'master' or 'slave' or 'all'")
    args = parser.parse_args()

    if not args.node is None:
        if not args.node in ["master", "slave", "all"]:
            print("[info] args error.")

    _input = input("initialize container. ok? (y/*) :").lower()
    if not _input in ["y", "yes"]:
        print("[info] initialize canceled.")
        sys.exit()

    print("[info] initialize start.")
    main(args)
    print("[info] initialize end.")
