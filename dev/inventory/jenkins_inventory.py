#!/usr/bin/env python
import os
import sys
import time
import json
import pathlib
import subprocess

import jwt


def main(argv):

    terraform_dir = pathlib.Path(__file__).absolute().parent.parent / 'terraform/nebula'
    stdout = subprocess.check_output(
        ['terraform', 'output', '-raw', 'vm_ip'],
        cwd=str(terraform_dir.absolute())
    )
    host = stdout.decode('utf-8').strip()

    albs_jwt_secret = 'secret'
    alts_jwt_secret = 'alts-secret'
    albs_jwt_token = jwt.encode(
        {
            'user_id': '1',
            'aud': [
                'fastapi-users:auth'
            ],
            'exp': int(time.time() + 99999999999999999999),
        },
        albs_jwt_secret,
        algorithm='HS256'
    )
    alts_jwt_token = jwt.encode(
        {'email': 'base_user@almalinux.org'},
        alts_jwt_secret,
        algorithm='HS256'
    )

    rabbitmq_pass = 'testy_test_test'

    github_client = os.environ.get('ALBS_GITHUB_CLIENT')
    github_client_secret = os.environ.get('ALBS_GITHUB_CLIENT_SECRET')
    albs_ssh_key = os.environ.get('TF_VAR_albs_ssh_key')

    albs_web_server = os.environ.get('ALBS_WEB_SERVER', 'master')
    albs_node = os.environ.get('ALBS_NODE', 'master')
    albs_frontend = os.environ.get('ALBS_FRONTEND', 'master')
    albs_sign_node = os.environ.get('ALBS_SIGN_NODE', 'master')
    alts = os.environ.get('ALTS', 'master')

    response = {
        'all': {
            'hosts': [host],
            'vars': {
                'local_connection': False,
                'pre_deploy': True,
                'install_docker': True,
                'load_platforms': True,
                'sources_root': '~/albs',
                'git_protocol': 'https',
                'postgres_password': 'password',
                'postgres_database': 'almalinux-bs',
                'github_client': github_client,
                'github_client_secret': github_client_secret,
                'frontend_baseurl': f'http://albs:8080',
                'albs_jwt_token': albs_jwt_token,
                'alts_jwt_token': alts_jwt_token,
                'albs_jwt_secret': albs_jwt_secret,
                'alts_jwt_secret': alts_jwt_secret,
                'pulp_user': 'admin',
                'pulp_password': 'admin',
                'rabbitmq_user': 'test-system',
                'rabbitmq_pass': rabbitmq_pass,
                'rabbitmq_vhost': 'test_system',
                'alts_result_backend': '',  # This is deprecated option
                'pgp_password': '32167',
                'pgp_keyid': '002D64E3C7827BD1',
                'pgp_fingerprint': '8E0EF28BB3DF0A9FCA18408B002D64E3C7827BD1',
                'albs_user': 'albs',
                'docker_user': 'albs',
                'albs_ssh_key': albs_ssh_key,
                'albs_web_server': albs_web_server,
                'albs_node': albs_node,
                'albs_frontend': albs_frontend,
                'albs_sign_node': albs_sign_node,
                'alts': alts
            }
        }
    }

    if argv == '--albs-config':
        response = {
            'hostname': f'http://{host}:8088',
            'jwt_token': albs_jwt_token
        }
    print(json.dumps(response))


if __name__ == '__main__':
    main(sys.argv[-1])