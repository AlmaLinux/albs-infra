*** Settings ***

Library           SeleniumLibrary
Library           OperatingSystem
Library           String
Library           ${EXECDIR}/resources/UtilsLibrary.py

Resource    ${EXECDIR}/resources/locators.robot
Resource    ${EXECDIR}/resources/items.robot
Resource    ${EXECDIR}/resources/vars.robot


*** Keywords ***


Wait For Build Appears
    [Arguments]    ${build}
    [Timeout]    ${WAIT_ELEMENT_TIMEOUT}

    ${reload} =   Set Local Variable     ${False}
    WHILE    ${reload} != ${True}
        Click Menu Button   Feed
        ${reload}=  Run Keyword And Return Status
                    ...     Page Should Contain Element     id=bfi-qb-details-${build.id}
    END


Go To Build
    [Arguments]    ${build}

    Click Element   id=bfi-qb-details-${build.id}
    Wait Until Element Is Visible      id=bui-qt-tab-menu       ${WAIT_ELEMENT_TIMEOUT}


Through Build Tasks
    [Arguments]    ${build}    ${keywords}

    ${tasks}=   Get WebElements    //td[starts-with(@id, "bui-tm-task-")]/..
    FOR    ${task}   IN    @{tasks}
        Run Keywords With Two Arguments    ${build}    ${task}    @{keywords}
    END


Through Build Tabs
    [Arguments]    ${build}    @{keywords}

    ${tabs}=   Get WebElements    //*[@id="bui-qt-tab-menu"]//*[@role="tab"]//*[not(contains(text(), "Summary")) and text()]
    FOR    ${tab}   IN    @{tabs}
        Click Element    ${tab}
        Through Build Tasks     ${build}    ${keywords}
    END


Wait For Task Completion
    [Arguments]    ${build}    ${task}

    ${markers}=     Create List     tests started     build completed
    ${status}=     Set Variable    ${None}
    WHILE    "${status}" not in @{markers}
        ${status elem}=    Get Child WebElement    ${task}     //td[starts-with(@id, "bui-tm-task-")]
        ${status}=    Get Text    ${status elem}
        Sleep   60
    END


Build Should Be Successful
    [Arguments]    ${build}
    [Timeout]    12 hours 30 minutes

    Through Build Tabs    ${build}
    ...     Wait For Task Completion
    ...     Validate Source
    ...     Validate Packages
    ...     Validate Repositories


Validate Packages
    [Arguments]    ${build}    ${task}

    Create Directory    ${config.tmpdir}

    ${link elems}=    Get Child WebElements    ${task}     ./td[3]/.//a
    FOR    ${elem}    IN    @{link elems}
        ${link}=    Get Element Attribute    ${elem}    href
        ${filepath}=    Download    ${link}     ${config.tmpdir}
        Should Be Package     ${filepath}
    END


Validate Source
    [Arguments]    ${build}    ${task}

    ${expected}=    Create Dictionary
    FOR    ${each}    IN    @{build.tasks}
        Set To Dictionary   ${expected}     ${each.repo}    ${each.ref}
    END

    ${repo elem}=    Get Child WebElement    ${task}     .//td[1]/span/span[1]
    ${actual repo}=     Get Text    ${repo elem}
    ${actual repo}=     Split String    ${actual repo}      ${\n}
    Dictionary Should Contain Key     ${expected}    ${actual repo[0]}

    ${expected ref}=    Get From Dictionary     ${expected}     ${actual repo[0]}
    ${ref elem}=    Get Child WebElement    ${task}     .//td[1]/span/a[1]
    ${ref link}=    Get Element Attribute    ${ref elem}    href
    ${actual ref}=    Split String    ${ref link}     /
    Should Be Equal As Strings      ${expected ref}      ${actual ref[7]}


Validate Repositories
    [Arguments]    ${build}    ${task}
    log many    ${build}
