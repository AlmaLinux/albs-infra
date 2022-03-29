#!/usr/bin/env python3

import sys
import json
import typing
import pprint
import pathlib
import argparse
import dataclasses
import urllib.parse

import requests


@dataclasses.dataclass
class Config:

    hostname: str = 'https://build.almalinux.org'
    jwt_token: str = ''
    arch_list: typing.List[str] = dataclasses.field(
        default_factory=lambda: list(('x86_64', )))


def parse_args():
    parser = argparse.ArgumentParser()
    subparsers = parser.add_subparsers()

    build_parser = subparsers.add_parser('build')
    build_parser.set_defaults(command='build')
    build_parser.add_argument('--rpm')
    build_parser.add_argument('--ref')
    build_parser.add_argument('--module')
    build_parser.add_argument('--module-version', default=None)
    build_parser.add_argument('--module-platform', default=None)

    check_parser = subparsers.add_parser('check')
    check_parser.set_defaults(command='check')
    check_parser.add_argument('build_id')

    return parser.parse_args()


def load_config() -> Config:
    config_file = pathlib.Path('~/.albs.json').expanduser()
    config_json = {}
    if config_file.exists():
        config_json = json.loads(config_file.read_text())
    config = Config(**config_json)
    return config


class AlbsCLI:

    def __init__(self, config: Config):
        self._platform_name = 'AlmaLinux-8'
        self._hostname = config.hostname
        self._jwt_token = config.jwt_token
        self._arch_list = config.arch_list

    def make_request(self, request: requests.Request):
        request.headers = {'authorization': f'Bearer {self._jwt_token}'}
        with requests.Session() as s:
            return s.send(request.prepare())

    def make_full_url(self, endpoint):
        return urllib.parse.urljoin(self._hostname, endpoint)

    def check_build(self, build_id: int):
        request = requests.Request(
            'get',
            self.make_full_url(f'/api/v1/builds/{build_id}')
        )
        response = self.make_request(request)
        try:
            response.raise_for_status()
        except Exception:
            print(
                '\033[0;31mThere is an exception, please contact cli '
                'maintainers, here is a response:'
            )
            print(response.status_code, response.text)
            print('\033[0m')
            sys.exit(1)
        return response.json()

    def create_build(
                self,
                git_ref,
                rpm_name=None,
                module_name=None,
                ref_type='git_branch',
                module_version=None,
                module_platform=None
            ):
        is_module = bool(module_name)
        git_project_type = 'modules' if is_module else 'rpms'
        git_name = module_name or rpm_name
        project_url = (
            f'https://git.almalinux.org/{git_project_type}/{git_name}.git'
        )
        tasks = [{
            'ref_type': ref_type,
            'url': project_url,
            'git_ref': git_ref,
            'is_module': is_module,
        }]
        if module_platform is not None:
            tasks[0]['module_platform_version'] = module_platform
        if module_version is not None:
            tasks[0]['module_version'] = module_version
        payload = {
            'is_secure_boot': False,
            'platforms': [
                {
                    'name': self._platform_name,
                    'arch_list': self._arch_list,
                }
            ],
            'tasks': tasks
        }
        request = requests.Request(
            'post',
            self.make_full_url('/api/v1/builds/'),
            json=payload
        )
        print(
            f'\033[0;32mTrying to create new build: '
            f'{project_url} "{git_ref}"\033[0m'
        )
        response = self.make_request(request)
        try:
            response.raise_for_status()
        except Exception:
            print(
                '\033[0;31mThere is an exception, please contact cli '
                'maintainers, here is a response:'
            )
            print(response.status_code, response.text)
            print('\033[0m')
            sys.exit(1)
        json = response.json()
        url = self.make_full_url(f'build/{json["id"]}')
        print(f'\033[0;32mSuccess: {url}\033[0m')
        return json


def main():
    args = parse_args()
    config = load_config()
    cli = AlbsCLI(config)
    if args.command == 'build':
        cli.create_build(
            args.ref,
            rpm_name=args.rpm,
            module_name=args.module,
            module_version=args.module_version,
            module_platform=args.module_platform
        )
    elif args.command == 'check':
        pprint.pprint(cli.check_build(args.build_id))


if __name__ == '__main__':
    main()
