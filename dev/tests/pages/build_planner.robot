*** Settings ***

Library           SeleniumLibrary

Resource    ${EXECDIR}/resources/locators.robot
Resource    ${EXECDIR}/resources/items.robot
Resource    ${EXECDIR}/resources/vars.robot


*** Keywords ***


Set Secure Boot
    [Arguments]    ${value}

    Toggle Checkbox       //div[@id="build-planner-q-checkbox-secure-boot"]       ${value}


Set Parallel Mode
    [Arguments]    ${value}

    Toggle Checkbox       //div[@id="build-planner-q-checkbox-parallel-mode"]       ${value}


Select Product
    [Arguments]    ${product}

    Fill Editable QSelect    //div[@id="build-planner-q-select-select-product"]/input     ${product}


Select Platforms
    [Arguments]    @{platforms}

    Fill QSelect    //div[@id="build-planner-q-select-select-platforms"]     @{platforms}


Select Architectures
    [Arguments]    ${platform}     @{archs}

    ${platform}=   Evaluate     "${platform}".lower()

    Fill QSelect    //div[@id="build-planner-q-select-arch-${platform}"]     @{archs}


Go To Projects Selection
    Click Button    id=build-planner-q-btn-create-build
