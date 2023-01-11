import argparse
import random
import string
import ruamel.yaml

from multiprocess import Process, Pool
from io import StringIO
from robot.api import TestSuite
from robot.running import TestCase
from robot.utils import DotDict, is_dict_like


def generate_build_name(build: dict) -> tuple:
    build_number = ''.join(random.SystemRandom().choice(string.ascii_lowercase + string.digits) for _ in range(5))

    platforms_label = ''
    for platform, archs in build['platforms'].items():
        platforms_label += f'{platform}({",".join(archs)}) '

    tasks_label = ''
    for task in build['tasks']:
        task_label = f" / {task['repo']}({task['ref']})"
        tasks_label += task_label

    build_name = f"Build #{build_number} based on {platforms_label}//{tasks_label[2:]}"
    return build_name, build_number


def get_builds_config(path: str):
    yaml = ruamel.yaml.YAML()
    with open(path) as file:
        data = yaml.load(file)
    return data['builds']

# def to_dotdict(data: dict) -> DotDict:
#     for key in data.keys():
#         if is_dict_like(data[key]) and not isinstance(data[key], DotDict):
#             return DotDict(data[key])


def create_suite(suite_name: str, build: dict) -> TestSuite:
    build = DotDict(build)
    suite = TestSuite(name=suite_name)

    suite.resource.imports.library('Collections')
    suite.resource.imports.resource('${EXECDIR}/pages/general.robot')
    suite.resource.imports.resource('${EXECDIR}/pages/teams.robot')
    suite.resource.imports.resource('${EXECDIR}/pages/build_planner.robot')
    suite.resource.imports.resource('${EXECDIR}/pages/build.robot')

    test: TestCase = suite.tests.create(f'Create Build')
    test.body.create_keyword('Set Variable', args=[build], assign=['${build}'])
    test.body.create_keyword('Log Many', args=['${build}'])
    test.body.create_keyword('Go To Build Creation', args=['${build}'])
    test.body.create_keyword('Set Secure Boot', args=['${build}'])
    test.body.create_keyword('Set Parallel Mode', args=['${build}'])
    test.body.create_keyword('Select Product', args=['${build}'])
    test.body.create_keyword('Select Platforms', args=['${build}'])
    test.body.create_keyword('Select Architectures', args=['${build}'])
    test.body.create_keyword('Go To Projects Selection', args=['${build}'])
    test.body.create_keyword('Add Tasks', args=['${build}'])
    test.body.create_keyword('Start Build', args=['${build}'])
    test.body.create_keyword('Wait For Build Appears', args=['${build}'])
    test.body.create_keyword('Go To Build', args=['${build}'])
    test.body.create_keyword('Build Should Be Successful', args=['${build}'])

    suite.setup.name = 'Login'
    suite.teardown.name = 'Logout'

    return suite


def exec(item: tuple):
    suite, params = item
    return suite.run(**params)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(prog='Robot Parallel Runner')
    parser.add_argument('output_dir', default='out')
    parser.add_argument('-c', '--config', default='config.yml')
    parser.add_argument('-b', '--builds', default='builds.yml')
    parser.add_argument('-p', '--processes', default=5)
    parser.add_argument('-v', '--verbose', action='store_true')
    args = parser.parse_args()

    builds = get_builds_config(args.builds)
    suites = []
    for build in builds:
        suite_name, suite_number = generate_build_name(build)

        params = {
                'variablefile': [args.config],
                'output': f'output_{suite_number}.xml',
                'outputdir': args.output_dir,
                # 'log': f'out/log_{suite_number}.html',
                # 'report': f'out/report_{suite_number}.html',
                'stdout': None if args.verbose else StringIO(),
                'stderr': None if args.verbose else StringIO()
        }
        suite = create_suite(suite_name, build)
        suites.append((suite, params))

    with Pool(args.processes) as pool:
        pool.map(exec, suites)
