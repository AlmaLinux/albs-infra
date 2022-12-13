*** Settings ***

Library           SeleniumLibrary

Resource    ${EXECDIR}/resources/locators.robot
Resource    ${EXECDIR}/resources/vars.robot


*** Keywords ***

Fill QSelect
    [Arguments]    ${locator}   @{items}

    ${field text}=   Get Text    ${locator}
    Click Element     ${locator}

    FOR    ${each}     IN      @{items}
        IF    "${each}" not in "${field text}"
            Click Element    //*[text()="${each}"]
        END
    END

    Press Keys      ${None}      ESCAPE


Fill Editable QSelect
    [Arguments]    ${locator}    ${value}

    Wait Until Element Is Visible    ${locator}      ${WAIT_ELEMENT_TIMEOUT}
    Input Text      ${locator}       ${value}
    Press Keys      ${locator}      ARROW_DOWN      ARROW_DOWN      ENTER       ESCAPE


Toggle Checkbox
    [Arguments]    ${locator}  ${value}

    ${value}=   Evaluate     "${value}".lower()
    Wait Until Element Is Visible    ${locator}      ${WAIT_ELEMENT_TIMEOUT}

    ${status}   Get Element Attribute     ${locator}     aria-checked

    IF     "${status}" != "${value}"
        Click Element    ${locator}
    END
