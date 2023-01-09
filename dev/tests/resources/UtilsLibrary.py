import base64
import hashlib
import os

import bcrypt
import rpmfile

from urllib.parse import urlparse
from urllib.request import urlopen


class UtilsLibrary:

    ROBOT_LIBRARY_SCOPE = 'SUITE'

    def download(self, url: str, path: str) -> str:
        url = urlparse(url)
        if not os.path.exists(path):
            raise FileNotFoundError()

        filename = url.path.split('/')[-1]
        filepath = os.path.join(path, filename)
        with urlopen(url.geturl()) as stream:
            with open(filepath, 'wb') as file:
                file.write(stream.read())

        return filepath

    def should_be_package(self, path: str) -> None:
        if not os.path.exists(path):
            raise FileNotFoundError()

        with rpmfile.open(path) as rpm:
            print(rpm.headers.keys())
            # for member in rpm.getmembers():
            #     print(member)

    def arch_should_be_in(self, path: str, archs: list) -> None:
        if not os.path.exists(path):
            raise FileNotFoundError()

    def bcrypt_password(self, password: str):
        hashed = bcrypt.hashpw(
            password.encode('utf8'),
            bcrypt.gensalt()
        )
        return hashed

    def generate_build_name(self, build: dict, count: int) -> str:
        platforms_label = ''
        for platform, archs in build['platforms'].items():
            platforms_label += f'{platform}({",".join(archs)}) '

        tasks_label = ''
        for task in build['tasks']:
            task_label = f" / {task['repo']}({task['ref']})"
            tasks_label += task_label

        build_name = f"Build #{count} based on {platforms_label}//{tasks_label[2:]}"
        return build_name
