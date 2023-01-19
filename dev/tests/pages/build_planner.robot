*** Settings ***

Library     SeleniumLibrary
Library     String

Resource    ${EXECDIR}/resources/items.robot

*** Variables ***

${id.input.archs.pref}    bpl-qs-arch-
${id.btn.create}    bpl-qb-create-build
${id.btn.addpoject}    pse-qb-add-project
${id.btn.modular}    psw-qt-modularity
${id.btn.submitpoject}     psw-qb-submit
${xp.chbox.boot}       //div[@id="bpl-qc-secure-boot"]
${xp.chbox.mode}       //div[@id="bpl-qc-parallel-mode"]
${xp.input.product}       //div[@id="bpl-qs-select-product"]/input
${xp.input.platforms}       //div[@id="bpl-qs-select-platforms"]
${xp.input.repo}       //div[@id="psw-qs-repo"]/input
${xp.input.ref}        //div[@id="psw-qs-repo-tag-branches"]/input
${xp.notify.created}   //div[@id="q-notify"]/div/div[6]/div/div/div[1]/div

*** Keywords ***


Go To Build Creation
    [Arguments]    ${build}

    Click Menu Button   New build


Set Secure Boot
    [Arguments]    ${build}

    Toggle Checkbox       ${xp.chbox.boot}       ${build.secure_boot}


Set Parallel Mode
    [Arguments]    ${build}

    Toggle Checkbox       ${xp.chbox.mode}       ${build.parallel_mode}


Select Product
    [Arguments]    ${build}

    Fill Editable QSelect    ${xp.input.product}     ${build.product}


Select Platforms
    [Arguments]    ${build}

    @{platforms}=   Get Dictionary Keys     ${build.platforms}
    Fill Clouds QSelect    ${xp.input.platforms}     ${platforms}


Select Architectures
    [Arguments]    ${build}

    FOR    ${platform}    ${archs}    IN    &{build.platforms}
        ${platform}=   Evaluate     "${platform}".lower()
        Fill Words QSelect    //div[@id="${id.input.archs.pref}${platform}"]     ${archs}
    END


Go To Projects Selection
    [Arguments]    ${build}

    Wait Until Element Is Visible    id=${id.btn.create}      ${config.timeout.element}
    Click Button    id=${id.btn.create}


Add Task
    [Arguments]         ${repo}     ${branch}     ${type}="Project"     ${src}=git.almalinux.org

    Click Button    id=${id.btn.addpoject}
    Click Element    //div[text()="${src}"]

    ${field text}=   Get Text    id=${id.btn.modular}
    IF    "${type}" not in "${field text}"
        Click Element     id=${id.btn.modular}
    END

    Fill Editable QSelect    ${xp.input.repo}     ${repo}
    Fill Editable QSelect    ${xp.input.ref}     ${branch}

    Click Button    id=${id.btn.submitpoject}
    Wait Until Element Is Not Visible    id=${id.btn.submitpoject}      ${config.timeout.element}


Add Tasks
    [Arguments]     ${build}

    FOR    ${task}    IN    @{build.tasks}
        Add Task    ${task.repo}    ${task.ref}    ${task.type}    ${task.source}
    END


Start Build
    [Arguments]     ${build}

    Wait Until Element Is Visible    id=${id.btn.create}      ${config.timeout.element}
    Click Button    id=${id.btn.create}
    Wait Until Element Is Visible    ${xp.notify.created}      ${config.timeout.element}
    ${field text}=   Get Text    ${xp.notify.created}
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
