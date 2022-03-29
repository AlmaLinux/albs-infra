import json
import pathlib
import dataclasses
from typing import List


@dataclasses.dataclass
class Config:

    hostname: str = 'https://build.almalinux.org'
    jwt_token: str = ''
    arch_list: List[str] = dataclasses.field(
        default_factory=lambda: list(('x86_64', )))


def load_config() -> Config:
    config_file = pathlib.Path(__file__).absolute().parent.parent
    config_file = config_file / 'albs.json'
    config_json = {}
    if config_file.exists():
        config_json = json.loads(config_file.read_text())
    config = Config(**config_json)
    return config
