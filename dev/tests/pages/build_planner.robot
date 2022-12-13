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
    [Arguments]    @{archs}

    Fill QSelect    //div[@id="build-planner-q-select-select-arch"]     @{archs}
