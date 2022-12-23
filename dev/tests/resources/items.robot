*** Settings ***

Library     SeleniumLibrary
Library     Collections
Library     String

Resource    ${EXECDIR}/resources/locators.robot
Resource    ${EXECDIR}/resources/vars.robot


*** Keywords ***


Get List Of Selected Clouds
    [Arguments]    ${locator}

    ${selected}=    Create List

    ${elems}    Get WebElements          ${locator}//span[contains(@class, "ellipsis")]
    FOR    ${each}      IN      @{elems}
        ${each text}=    Get Text    ${each}
        Append To List     ${selected}     ${each text}
    END

    RETURN    ${selected}


Get List Of Selected Words
    [Arguments]    ${locator}

    ${selected}=    Create List
    ${text}=    Get Text          ${locator}/span
    ${words}=    Split String    ${text}      ,
    FOR    ${each}      IN      @{words}
        ${word}=    Strip String    ${each}
        Append To List     ${selected}     ${word}
    END

    RETURN    ${selected}


Fill Clouds QSelect
    [Arguments]    ${locator}   ${items}

    ${selected}=    Get List Of Selected Clouds     ${locator}

    Fill QSelect    ${locator}      ${selected}     ${items}


Fill Words QSelect
    [Arguments]    ${locator}   ${items}

    ${selected}=    Get List Of Selected Words     ${locator}

    Fill QSelect    ${locator}      ${selected}     ${items}


Fill QSelect
    [Arguments]    ${locator}   ${selected}   ${items}

    Click Element     ${locator}

    FOR    ${each}     IN      @{selected}
        IF    "${each}" not in ${items}
            Wait Until Element Is Visible    //*[text()="${each}"]      ${WAIT_ELEMENT_TIMEOUT}
            Click Element    //*[text()="${each}"]
        END
    END

    Press Keys      ${None}      ESCAPE
    Click Element     ${locator}

    FOR    ${each}     IN      @{items}
        IF    "${each}" not in ${selected}
            Wait Until Element Is Visible    //*[text()="${each}"]      ${WAIT_ELEMENT_TIMEOUT}
            Click Element    //*[text()="${each}"]
        END
    END

    Press Keys      ${None}      ESCAPE


Fill Editable QSelect
    [Arguments]    ${locator}    ${value}

    ${value}=    Strip String    ${value}

    Wait Until Element Is Visible    ${locator}      ${WAIT_ELEMENT_TIMEOUT}
    Input Text      ${locator}       ${value}
    Wait Until Element Is Visible    //div[@role="option"]      ${WAIT_ELEMENT_TIMEOUT}

    ${options}=     Get WebElements    //div[@role="option"]
    FOR     ${option}   IN     @{options}
        ${option label}=    Get Child WebElement    ${option}     .//div[@class="q-item__label"]
        ${option text}=    Get Text    ${option label}
        ${option text}=    Strip String    ${option text}
        IF      "${option text}" == "${value}"
            Click Element        ${option}
            BREAK
        END
    END
    Wait Until Element Is Not Visible    //div[@role="option"]      ${WAIT_ELEMENT_TIMEOUT}


Toggle Checkbox
    [Arguments]    ${locator}  ${value}

    ${value}=   Evaluate     "${value}".lower()
    Wait Until Element Is Visible    ${locator}      ${WAIT_ELEMENT_TIMEOUT}

    ${status}   Get Element Attribute     ${locator}     aria-checked

    IF     "${status}" != "${value}"
        Click Element    ${locator}
    END
