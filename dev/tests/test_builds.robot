*** Settings ***

Resource          ${EXECDIR}/resources/vars.robot

Resource          ${EXECDIR}/pages/general.robot
Resource          ${EXECDIR}/pages/teams.robot
Resource          ${EXECDIR}/pages/build_planner.robot


Suite Setup       Login
Suite Teardown    Logout


*** Test Cases ***

Valid Login
    User Successfully Authorized


Build Creation
    Click Menu Button   New build
    Set Secure Boot     False
    Set Parallel Mode     True
    Select Product    AlmaLinux
    Select Platforms     AlmaLinux-8     AlmaLinux-9
    Select Architectures     AlmaLinux-8     i686    x86_64    aarch64    ppc64le    s390x
    Select Architectures     AlmaLinux-9     i686    x86_64    aarch64    ppc64le    s390x
    Go To Projects Selection
    Add Project     cmake       c8s-stream-rhel8        Module
    Start Build
    Capture Page Screenshot     Embed

