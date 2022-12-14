*** Settings ***

Library           SeleniumLibrary

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

