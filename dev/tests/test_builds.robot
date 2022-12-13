*** Settings ***

Resource          resources/vars.robot

Resource          pages/general.robot
Resource          pages/teams.robot
Resource          pages/build_planner.robot


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
#    Select Platforms     AlmaLinux-8     AlmaLinux-9
    Select Platforms     AlmaLinux-8
    Select Architectures     i686    x86_64    aarch64    ppc64le    s390x

