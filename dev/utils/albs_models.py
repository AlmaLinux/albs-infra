import json
import typing
import datetime

from pydantic import BaseModel, Field, validator

from utils.constants import BuildTaskStatus


class BuildTaskRef(BaseModel):

    url: str
    git_ref: typing.Optional[str]
    ref_type: typing.Optional[typing.Union[int, str]]
    is_module: typing.Optional[bool] = False
    module_platform_version: typing.Optional[str] = None
    module_version: typing.Optional[str] = None


class BuildPlatform(BaseModel):

    id: int
    type: str
    name: str
    arch_list: typing.List[str]


class BuildTaskArtifact(BaseModel):

    id: int
    name: str
    type: str
    href: str


class BuildTaskTestTask(BaseModel):

    status: int


class BuildSignTask(BaseModel):

    status: int


class BuildTask(BaseModel):

    id: int
    ts: typing.Optional[datetime.datetime]
    status: int
    index: int
    arch: str
    platform: BuildPlatform
    ref: BuildTaskRef
    artifacts: typing.List[BuildTaskArtifact]
    is_secure_boot: typing.Optional[bool]
    test_tasks: typing.List[BuildTaskTestTask]


class BuildOwner(BaseModel):

    id: int
    username: str
    email: str


class CreatedBuild(BaseModel):

    id: int


class Build(BaseModel):

    id: int
    created_at: datetime.datetime
    tasks: typing.List[BuildTask]
    owner: BuildOwner
    sign_tasks: typing.List[BuildSignTask]
    linked_builds: typing.Optional[typing.List[int]] = Field(default_factory=list)
    mock_options: typing.Optional[typing.Dict[str, typing.Any]]

    @validator('linked_builds', pre=True)
    def linked_builds_validator(cls, v):
        return [item if isinstance(item, int) else item.id for item in v]

    @property
    def failed(self):
        return any(
            task.status == BuildTaskStatus.FAILED
            for task in self.tasks
        )

    @property
    def completed(self):
        allowed_status_list = [
            BuildTaskStatus.COMPLETED,
            BuildTaskStatus.EXCLUDED
        ]
        return all(task.status in allowed_status_list for task in self.tasks)
