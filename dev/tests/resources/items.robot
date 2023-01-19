*** Settings ***

Library     SeleniumLibrary
Library     Collections
Library     String


*** Variables ***

${xp.input.ellipsis}    //span[contains(@class, "ellipsis")]
${xp.input.options}     //div[@role="option"]
${xp.input.options.labels}     //div[@class="q-item__label"]
${xp.input.options.list}     //div[@role="listbox"]
${xp.frame.backdrop}     //div[@class="q-loading__backdrop"]

*** Keywords ***


Get List Of Selected Clouds
    [Arguments]    ${locator}

    ${selected}=    Create List

    ${elems}    Get WebElements          ${locator}${xp.input.ellipsis}
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
        ${length}=    Get Length    ${each}
        IF    ${length} == 0
            CONTINUE
        END
        IF    "${each}" not in ${items}
            Wait Until Element Is Visible    //*[text()="${each}"]      ${config.timeout.element}
            Click Element    //*[text()="${each}"]
        END
    END

    Press Keys      ${None}      ESCAPE
    Click Element     ${locator}

    FOR    ${each}     IN      @{items}
        IF    "${each}" not in ${selected}
            Wait Until Element Is Visible    //*[text()="${each}"]      ${config.timeout.element}
            Click Element    //*[text()="${each}"]
        END
    END

    Press Keys      ${None}      ESCAPE


Fill Editable QSelect
    [Arguments]    ${locator}    ${value}

    ${value}=    Strip String    ${value}

    Wait Until Element Is Visible    ${locator}      ${config.timeout.element}
    Input Text      ${locator}       ${value}
    ${is visible}=     run keyword and return status
                       ...    Wait Until Element Is Visible    ${xp.input.options}      ${config.timeout.element}
    IF    not ${is visible}
        Press Keys      ${None}      ARROW_DOWN
    END

    Scroll And Click    ${value}
#    ${options}=     Get WebElements    ${xp.input.options}
#    FOR     ${option}   IN     @{options}
#        ${option label}=    Get Child WebElement    ${option}     .${xp.input.options.labels}
#        ${option text}=    Get Text    ${option label}
#        ${option text}=    Strip String    ${option text}
#        IF      "${option text}" == "${value}"
#            Click Element        ${option}
#            BREAK
#        END
#    END
    Wait Until Element Is Not Visible    ${xp.input.options}      ${config.timeout.element}


Click Without Scroll
    [Arguments]    ${value}     ${options}

    FOR     ${option}   IN     @{options}
        ${option label}=    Get Child WebElement    ${option}     .${xp.input.options.labels}
        ${option text}=    Get Text    ${option label}
        ${option text}=    Strip String    ${option text}
        IF      "${option text}" == "${value}"
            Click Element        ${option}
            RETURN    True
        END
    END
    RETURN    False


Scroll And Click
    [Arguments]    ${value}
    [Timeout]    ${config.timeout.options}

    ${clicked}=     Set Variable    False

    WHILE  ${clicked} == False
        ${options}=     Get WebElements    ${xp.input.options}
        ${length}=    Get Length    ${options}
        ${clicked}=    Click Without Scroll    ${value}    ${options}

        IF      not ${clicked}
            FOR    ${index}    IN RANGE    ${length}
                Press Keys      ${None}      ARROW_DOWN
            END
        END
    END


Toggle Checkbox
    [Arguments]    ${locator}    ${value}

    ${value}=   Evaluate     "${value}".lower()
    Wait Until Element Is Visible    ${locator}      ${config.timeout.element}

    ${status}   Get Element Attribute     ${locator}     aria-checked

    IF     "${status}" != "${value}"
        Click Element    ${locator}
    END


Hide Loading Backdrop
    # <div class="q-loading__backdrop">

    Wait Until Element Is Not Visible    ${xp.frame.backdrop}      ${config.timeout.element}

    ${passed}    Run Keyword And Return Status
                 ...    Page Should Contain Element    ${xp.frame.backdrop}
    IF    not ${passed}
        Return From Keyword
    END

    ${elem}=    Get WebElement    ${xp.frame.backdrop}

    IF      ${elem} != ${None}
        Execute Javascript    arguments[0].style.visibility='hidden'    ${elem}
    END


Convert Python Dictionary Nested
    [Arguments]    ${python_dict}
    [Documentation]    Converts Python dictionary to Robot dictionary.

    @{keys}=    Get Dictionary Keys    ${python_dict}

    FOR    ${key}    IN    @{keys}
        ${is dict}=      Evaluate     isinstance(${value}, (ordereddict, dict,))

        IF    ${is dict}
            ${nested_dict}=    Convert Python Dictionary    ${value}
            Set To Dictionary    ${robot_dict}    ${key}=${python_dict['${key}']}
            robot_dict['${key}']
        END

    END


Convert Python Dictionary
    [Arguments]    ${python_dict}
    [Documentation]    Converts Python dictionary to Robot dictionary.

    @{keys}=    Get Dictionary Keys    ${python_dict}

    ${robot_dict}=    Create Dictionary
    FOR    ${key}    IN    @{keys}
        Set To Dictionary    ${robot_dict}    ${key}=${python_dict['${key}']}
    END

    RETURN   ${robot_dict}
