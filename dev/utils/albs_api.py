import time
import urllib.parse

import requests

from utils.log import logger
from utils.albs_models import Build, CreatedBuild


class AlbsAPI:

    def __init__(self, config):
        self._platform_name = 'AlmaLinux-8'
        self._hostname = config.hostname
        self._jwt_token = config.jwt_token
        self._arch_list = config.arch_list

    def make_request(self, request: requests.Request):
        request.headers = {'authorization': f'Bearer {self._jwt_token}'}
        logger.debug(
            'Making request: %s, %s, params=%s, data=%s, json=%s',
            request.method.upper(),
            request.url,
            request.params,
            request.data,
            request.json
        )
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
        response.raise_for_status()
        return Build(**response.json())

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
        logger.debug(f'Request payload: {payload}')
        response = self.make_request(request)
        response.raise_for_status()
        # Right now albs builds api returns 404 for created builds
        # until task queue is done with it, so we're sleeping for
        # 1 minute here, before passing build results to user
        # TODO: fix albs api and remove this sleep
        time.sleep(60) 
        return CreatedBuild(id=response.json()['id'])
    
    def wait_for_build(self, build: Build, timeout: int = 60):
        for _ in range(timeout):
            build = self.check_build(build.id)
            if build.failed or build.completed:
                return build
            logger.debug('Not all build items finished, waiting one more minute')
            time.sleep(60)
        else:
            raise Exception(f'Build {build.id} is not completed after 1 hour')
