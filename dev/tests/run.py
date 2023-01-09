import random
import string
import ruamel.yaml

from multiprocess import Process
from robot.api import TestSuite, ResultWriter
from robot.running import TestCase


def generate_build_name(build: dict) -> tuple:
    build_number = ''.join(random.SystemRandom().choice(string.ascii_lowercase + string.digits) for _ in range(4))

    platforms_label = ''
    for platform, archs in build['platforms'].items():
        platforms_label += f'{platform}({",".join(archs)}) '

    tasks_label = ''
    for task in build['tasks']:
        task_label = f" / {task['repo']}({task['ref']})"
        tasks_label += task_label

    build_name = f"Build #{build_number} based on {platforms_label}//{tasks_label[2:]}"
    return build_name, build_number


def get_builds_config():
    yaml = ruamel.yaml.YAML()
    with open("builds/builds.yml") as file:
        data = yaml.load(file)
    return data['builds']


def create_suite(suite_name: str) -> TestSuite:
    suite = TestSuite(name=suite_name)

    suite.resource.imports.library('Collections')
    suite.resource.imports.resource('${EXECDIR}/pages/general.robot')
    suite.resource.imports.resource('${EXECDIR}/pages/teams.robot')
    suite.resource.imports.resource('${EXECDIR}/pages/build_planner.robot')
    suite.resource.imports.resource('${EXECDIR}/pages/build.robot')

    test: TestCase = suite.tests.create(f'Create Build')
    test.body.create_keyword('Convert Python Dictionary', args=[build], assign=['${build}'])
    test.body.create_keyword('Go To Build Creation', args=['${build}'])
    test.body.create_keyword('Set Secure Boot', args=['${build}'])
    test.body.create_keyword('Set Parallel Mode', args=['${build}'])
    test.body.create_keyword('Select Product', args=['${build}'])
    test.body.create_keyword('Select Platforms', args=['${build}'])
    # test.body.create_keyword('Select Architectures', args=['${build}'])
    # test.body.create_keyword('Go To Projects Selection', args=['${build}'])
    # test.body.create_keyword('Add Tasks', args=['${build}'])
    # test.body.create_keyword('Start Build', args=['${build}'])
    # test.body.create_keyword('Wait For Build Appears', args=['${build}'])
    # test.body.create_keyword('Go To Build', args=['${build}'])
    # test.body.create_keyword('Build Should Be Successful', args=['${build}'])

    suite.setup.name = 'Login'
    suite.teardown.name = 'Logout'

    return suite


def exec(suite: TestSuite, params: dict):
    return suite.run(**params)


if __name__ == '__main__':
    print(get_builds_config())

    builds = get_builds_config()
    procs = []
    for build in builds:
        suite_name, suite_number = generate_build_name(build)
        params = {
                'variablefile': ['builds/config.yml'],
                'output': f'output_{suite_number}.xml',
                'outputdir': f'out',
                # 'log': f'out/log_{suite_number}.html',
                # 'report': f'out/report_{suite_number}.html',
                'stdout': None
        }
        suite = create_suite(suite_name)
        proc = Process(target=exec, args=(suite, params,))
        proc.start()
        procs.append(proc)

    for proc in procs:
        proc.join()



    # stdout = StringIO()
    # result = suite.run(variable='EXAMPLE:value',
    #                    output='example.xml',
    #                    exitonfailure=True,
    #                    stdout=stdout)
    # print(result.return_code)
