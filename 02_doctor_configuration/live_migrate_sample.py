
import argparse
from datetime import datetime
import json
import os
import requests
import socket
import sys
import time

from keystoneauth1 import session
from congressclient.v1 import client
from keystoneauth1.identity import v2
from keystoneauth1.identity import v3

def get_identity_auth():
    auth_url = os.environ['OS_AUTH_URL']
    username = os.environ['OS_USERNAME']
    password = os.environ['OS_PASSWORD']
    user_domain_name = os.environ.get('OS_USER_DOMAIN_NAME')
    project_name = os.environ.get('OS_PROJECT_NAME') or os.environ.get('OS_TENANT_NAME')
    project_domain_name = os.environ.get('OS_PROJECT_DOMAIN_NAME')
    if auth_url.endswith('v3'):
        return v3.Password(auth_url=auth_url,
                           username=username,
                           password=password,
                           user_domain_name=user_domain_name,
                           project_name=project_name,
                           project_domain_name=project_domain_name)
    else:
        return v2.Password(auth_url=auth_url,
                           username=username,
                           password=password,
                           tenant_name=project_name)

class Migrate(object):

    def __init__(self,args):

        auth=get_identity_auth()
        self.sess=session.Session(auth=auth)
        self.report_url = 'http://192.168.32.163:8774/v2.1'
        print ("report url:",self.report_url)

    def live_migrate(self):
        payload = [
            {
                "os-migrateLive": {
                "host": "01c0cadef72d47e28a672a76060d492c",
                "block_migration": "auto",
                "force": false
            },
        ]
        data = json.dumps(payload)

        headers = {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'X-Auth-Token':self.sess.get_token(),
        }
        print ("token:",self.sess.get_token())
        requests.put(self.inspector_url, data=data, headers=headers)
        print ("live-migrate instruction has been sent")

def get_args():
    parser = argparse.ArgumentParser(description='Live Migrate Sample')
    parser.add_argument('vmid', metavar='HOSTID', type=str, nargs='?',
                           help='ID of a VM to be migrated')
    return parser.parse_args()

def main():
    args=get_args()
    migrate = Migrate(args)
    migrate.report_error()

if __name__ == '__main__':
    main()