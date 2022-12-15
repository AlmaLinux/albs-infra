*** Settings ***

Library           SeleniumLibrary
Library           String

Resource    ${EXECDIR}/resources/locators.robot
Resource    ${EXECDIR}/resources/items.robot
Resource    ${EXECDIR}/resources/vars.robot


*** Keywords ***


Set Secure Boot
    [Arguments]    ${value}

    Toggle Checkbox       //div[@id="bpl-qc-secure-boot"]       ${value}


Set Parallel Mode
    [Arguments]    ${value}

    Toggle Checkbox       //div[@id="bpl-qc-parallel-mode"]       ${value}


Select Product
    [Arguments]    ${product}

    Fill Editable QSelect    //div[@id="bpl-qs-select-product"]/input     ${product}


Select Platforms
    [Arguments]    @{platforms}

    Fill QSelect    //div[@id="bpl-qs-select-platforms"]     @{platforms}


Select Architectures
    [Arguments]    ${platform}     @{archs}

    ${platform}=   Evaluate     "${platform}".lower()

    Fill QSelect    //div[@id="bpl-qs-arch-${platform}"]     @{archs}


Go To Projects Selection
    Click Button    id=bpl-qb-create-build


Add Project
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


Start Build
    Click Button    id=bpl-qb-create-build
    Wait Until Element Is Visible    //div[@id="q-notify"]/div/div[6]/div/div/div[1]/div      ${WAIT_ELEMENT_TIMEOUT}
    ${field text}=   Get Text    //div[@id="q-notify"]/div/div[6]/div/div/div[1]/div
    ${build id}=    Get Regexp Matches    ${field text}    Build.(\\d+).created      1
    Capture Page Screenshot     Embed
    RETURN    ${build id[0]}
