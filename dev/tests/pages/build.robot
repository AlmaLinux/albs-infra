*** Settings ***

Library           SeleniumLibrary
Library           String

Resource    ${EXECDIR}/resources/locators.robot
Resource    ${EXECDIR}/resources/items.robot
Resource    ${EXECDIR}/resources/vars.robot


*** Keywords ***


Wait For Build Appears
    [Arguments]    ${build id}
    [Timeout]    ${WAIT_ELEMENT_TIMEOUT}

    ${reload} =   Set Local Variable     ${False}
    WHILE    ${reload} != ${True}
        Click Menu Button   Feed
        ${reload}=  Run Keyword And Return Status
                    ...     Page Should Contain Element     id=bfi-qb-details-${build id}
    END


Go To Build
    [Arguments]    ${build id}

    Click Element   id=bfi-qb-details-${build id}
    Wait Until Element Is Visible      id=bui-qt-tab-menu       ${WAIT_ELEMENT_TIMEOUT}

