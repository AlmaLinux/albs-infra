*** Settings ***

Resource          ${EXECDIR}/resources/vars.robot
Resource          ${EXECDIR}/pages/general.robot
Resource          ${EXECDIR}/pages/teams.robot
Resource          ${EXECDIR}/pages/build_planner.robot
Resource          ${EXECDIR}/pages/build.robot


Suite Setup       Login
Suite Teardown    Logout


*** Test Cases ***

Valid Login
    User Successfully Authorized


Builds Creation

    For Each Build
    ...     Go To Build Creation
    ...     Set Secure Boot
    ...     Set Parallel Mode
    ...     Select Product
    ...     Select Platforms
    ...     Select Architectures
    ...     Go To Projects Selection
    ...     Add Tasks
    ...     Start Build
    ...     Wait For Build Appears
    ...     Go To Build
    ...     Build Should Be Successful
