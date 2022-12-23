*** Settings ***

Library           SeleniumLibrary
Library           String

Resource    ${EXECDIR}/resources/locators.robot
Resource    ${EXECDIR}/resources/items.robot
Resource    ${EXECDIR}/resources/vars.robot


*** Keywords ***


Go To Build Creation
    [Arguments]    ${build}

    Click Menu Button   New build


Set Secure Boot
    [Arguments]    ${build}

    Toggle Checkbox       //div[@id="bpl-qc-secure-boot"]       ${build.secure_boot}


Set Parallel Mode
    [Arguments]    ${build}

    Toggle Checkbox       //div[@id="bpl-qc-parallel-mode"]       ${build.parallel_mode}


Select Product
    [Arguments]    ${build}

    Fill Editable QSelect    //div[@id="bpl-qs-select-product"]/input     ${build.product}


Select Platforms
    [Arguments]    ${build}

    @{platforms}=   Get Dictionary Keys     ${build.platforms}
    Fill Clouds QSelect    //div[@id="bpl-qs-select-platforms"]     ${platforms}


Select Architectures
    [Arguments]    ${build}

    FOR    ${platform}    ${archs}    IN    &{build.platforms}
        ${platform}=   Evaluate     "${platform}".lower()
        Fill Words QSelect    //div[@id="bpl-qs-arch-${platform}"]     ${archs}
    END


Go To Projects Selection
    [Arguments]    ${build}

    Wait Until Element Is Visible    id=bpl-qb-create-build      ${WAIT_ELEMENT_TIMEOUT}
    Click Button    id=bpl-qb-create-build


Add Task
    [Arguments]         ${repo}     ${branch}     ${type}="Project"     ${src}=git.almalinux.org

    Click Button    id=pse-qb-add-project
    Click Element    //div[text()="${src}"]

    ${field text}=   Get Text    id=psw-qt-modularity
    IF    "${type}" not in "${field text}"
        Click Element     id=psw-qt-modularity
    END

    Fill Editable QSelect    //div[@id="psw-qs-repo"]/input     ${repo}
    Fill Editable QSelect    //div[@id="psw-qs-repo-tag-branches"]/input     ${branch}

    Click Button    id=psw-qb-submit
    Wait Until Element Is Not Visible    id=psw-qb-submit      ${WAIT_ELEMENT_TIMEOUT}


Add Tasks
    [Arguments]     ${build}

    FOR    ${task}    IN    @{build.tasks}
        Add Task    ${task.repo}    ${task.ref}    ${task.type}    ${task.source}
    END


Start Build
    [Arguments]     ${build}

    Wait Until Element Is Visible    id=bpl-qb-create-build      ${WAIT_ELEMENT_TIMEOUT}
    Click Button    id=bpl-qb-create-build
    Wait Until Element Is Visible    //div[@id="q-notify"]/div/div[6]/div/div/div[1]/div      ${WAIT_ELEMENT_TIMEOUT}
    ${field text}=   Get Text    //div[@id="q-notify"]/div/div[6]/div/div/div[1]/div
    ${build id}=    Get Regexp Matches    ${field text}    Build.(\\d+).created      1
    Capture Page Screenshot     Embed
    Log     Build id is ${build id[0]}
    Set To Dictionary   ${build}    id     ${build id[0]}


For Each Build
    [Arguments]    @{keywords}

    FOR    ${build}   IN    @{builds}
        Log Many    ${build}
        Run Keywords With Argument    ${build}      @{keywords}
    END
