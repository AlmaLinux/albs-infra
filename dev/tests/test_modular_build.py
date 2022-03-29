from utils.log import logger

from tests.base_test_case import ALBSTestCase


class TestModularBuild(ALBSTestCase):

    def test(self):
        build = self.api.create_build('c8-stream-rhel8', module_name='go-toolset')
        build = self.api.wait_for_build(build, timeout=60)
        if build.failed:
            raise Exception(f'Build {build.id} is failed: {build}')
        if build.completed:
            logger.debug('Build %s is done, test completed', build.id)
        # TODO: tests are not working right now, but we should wait for them too