#! /usr/bin/env python
# -*- coding: utf-8 -*-
import os
from os.path import join, dirname, abspath, isfile, isdir
import shutil
import argparse

dir_scr = dirname(abspath(__file__))
import helper as fn

def main(_args):
    print("----- mysql setting start.")
    env_dst = join(dir_scr, '.env')
    env_org = join(dir_scr, "_org", '.env')

    if not isfile(env_dst):
        shutil.copyfile(env_org, env_dst)
    params = fn.getenv(env_dst)

    if params['MYSQL_ROOT_PASSWORD'] == "":
        params['MYSQL_ROOT_PASSWORD'] = fn.randstr(30)
    if params['MYSQL_REP_PASSWORD'] == "":
        params['MYSQL_REP_PASSWORD'] = fn.randstr(30)
    if params['MYSQL_USER_PASSWORD'] == "":
        params['MYSQL_USER_PASSWORD'] = fn.randstr(30)
    req_keys = [
        'TZ',
        'MYSQL_ROOT_PASSWORD',
        'MYSQL_REP_PASSWORD',
        'MYSQL_USER_PASSWORD',
        'MEM',
    ]
    if _args.node == 'master':
        req_keys.append('MASTER_PORT')
        req_keys.append('MASTER_SERVER_ID')
        params['MASTER_HOST'] = fn.local_ip()
    elif _args.node == 'slave':
        req_keys.append('SLAVE_PORT')
        req_keys.append('SLAVE_SERVER_ID')
        req_keys.append('MASTER_HOST')
        req_keys.append('MASTER_PORT')
    fn.setparams(params, req_keys)

    params['NODE'] = _args.node
    fn.setenv(params, env_dst)

    # confのコピー
    conf_org = join(dir_scr, '_org', 'conf', _args.node, 'rep.cnf')
    dir_conf = join(dir_scr, 'mnt', 'conf', _args.node)
    if not isdir(dir_conf):
        os.makedirs(dir_conf)
    conf_dst = join(dir_conf, 'rep.cnf')
    fn.update_file(params, conf_org, '___', conf_dst)

    # mysqlのログイン用ファイルコピー
    users = ["root", "rep", "user"]
    dir_opt_org = join(dir_scr, '_org', 'opt')
    dir_opt = join(dir_scr, 'mnt', 'common', 'opt')
    if not isdir(dir_opt):
        os.makedirs(dir_opt)
    for user in users:
        opt_org = join(dir_opt_org, f".opt{user}")
        opt_dst = join(dir_opt, f".opt{user}")
        fn.update_file(params, opt_org, '___', opt_dst)

    for k,v in params.items():
        print(f"{k}={v}")

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='set env params')
    parser.add_argument('node', help="(option) force node type 'master' or 'slave' or 'all'")
    args = parser.parse_args()

    if not args.node in ["master", "slave"]:
        print("[info] args error.")

    main(args)
