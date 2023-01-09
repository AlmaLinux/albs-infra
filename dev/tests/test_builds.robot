*** Settings ***

Library           ${EXECDIR}/resources/DynamicTestCases.py
Library           ${EXECDIR}/resources/UtilsLibrary.py

Resource          ${EXECDIR}/pages/general.robot
Resource          ${EXECDIR}/pages/teams.robot
Resource          ${EXECDIR}/pages/build_planner.robot
Resource          ${EXECDIR}/pages/build.robot


Suite Setup       Setup Builds
Suite Teardown    Teardown Builds


*** Keywords ***


Setup Builds
    Generate Build Cases
    Login


Teardown Builds
    Logout


Create Build
    [Arguments]    ${build}

    Go To Build Creation        ${build}
    Set Secure Boot             ${build}
    Set Parallel Mode           ${build}
    Select Product              ${build}
    Select Platforms            ${build}
    Select Architectures        ${build}
    Go To Projects Selection    ${build}
    Add Tasks                   ${build}
    Start Build                 ${build}
    Wait For Build Appears      ${build}
    Go To Build                 ${build}
    Build Should Be Successful  ${build}


Generate Build Cases
    ${count}=    Set Variable    0
    FOR    ${build}    IN    @{builds}
        ${build_name}=    Generate Build Name    ${build}    ${count}
        Add Test Case    ${build_name}   Create Build    ${build}
        ${count}=    Evaluate    ${count} + 1
    END



*** Test Cases ***

Valid Login
    User Successfully Authorized

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
