import sys

import logging


def setup_logger(log_level: int) -> logging.Logger:
    logger = logging.getLogger('albs-lib')
    logger.setLevel(log_level)
    stdout_handler = logging.StreamHandler(sys.stdout)
    formatter = logging.Formatter(
        '%(asctime)s [%(name)s] (%(levelname)s): %(message)s',
        '%d.%m.%Y %H:%M:%S'
    )
    stdout_handler.setFormatter(formatter)
    logger.addHandler(stdout_handler)
    return logger


logger = setup_logger(logging.DEBUG)
