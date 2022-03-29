from unittest import TestCase

from utils.albs_api import AlbsAPI
from utils.config import load_config


class ALBSTestCase(TestCase):

    def setUp(self) -> None:
        self.albs_config = load_config()
        self.api = AlbsAPI(self.albs_config)
        return super().setUp()