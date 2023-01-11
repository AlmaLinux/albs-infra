*** Settings ***

Library     SeleniumLibrary
Library     OperatingSystem
Library     String

Library     ${EXECDIR}/resources/UtilsLibrary.py

Resource    ${EXECDIR}/resources/items.robot


*** Variables ***

${id.button.details.prefix}     bfi-qb-details-
${id.tabs.menu}                 bui-qt-tab-menu
${xp.tabs}                      //*[@id="bui-qt-tab-menu"]//*[@role="tab"]//*[not(contains(text(), "Summary")) and text()]
${xp.tasks}                     //td[starts-with(@id, "bui-tm-task-")]/..
${xp.task.status}               //td[starts-with(@id, "bui-tm-task-")]
${xp.task.packages}             /td[3]/.//a
${xp.task.packages.notary}             /td[3]/.//i
${xp.task.repo}                 //td[1]/span/span[1]
${xp.task.repo.notary}          //td[1]/span/span[1]/div/i
${xp.task.ref}                  //td[1]/span/a[1]

*** Keywords ***


Wait For Build Appears
    [Arguments]    ${build}
    [Timeout]    ${config.timeout.build}

    ${reload} =   Set Local Variable     ${False}
    WHILE    ${reload} != ${True}
        Click Menu Button   Feed
        Sleep    30 seconds
        Hide Loading Backdrop
        ${reload}=  Run Keyword And Return Status
                    ...     Page Should Contain Element      id=${id.button.details.prefix}${build.id}
    END


Go To Build
    [Arguments]    ${build}

    Click Element    id=${id.button.details.prefix}${build.id}
    Wait Until Element Is Visible      id=${id.tabs.menu}       ${config.timeout.element}


Through Build Tasks
    [Arguments]    ${build}    ${keywords}

    ${tasks}=   Get WebElements    ${xp.tasks}
    FOR    ${task}   IN    @{tasks}
        Run Keywords With Two Arguments    ${build}    ${task}    @{keywords}
    END


Through Build Tabs
    [Arguments]    ${build}    @{keywords}

    ${tabs}=   Get WebElements    ${xp.tabs}
    FOR    ${tab}   IN    @{tabs}
        Click Element    ${tab}
        Through Build Tasks     ${build}    ${keywords}
    END


Wait For Task Completion
    [Arguments]    ${build}    ${task}

    ${markers}=     Create List     tests started     build done     excluded
    ${fail markers}=     Create List     build failed
    ${status}=     Set Variable    ${None}
    WHILE    "${status}" not in @{markers}
        ${status elem}=    Get Child WebElement    ${task}     .${xp.task.status}
        ${status}=    Get Text    ${status elem}
        IF    "${status}" in @{fail markers}
            Fail    Build ${build.id} failed
        END
        Sleep   60
    END


Build Should Be Successful
    [Arguments]    ${build}
    [Timeout]    ${config.timeout.building}

    Through Build Tabs    ${build}
    ...     Wait For Task Completion
    ...     Validate Source
    ...     Validate Packages
    ...     Validate Repositories
    ...     Validate Packages Notary
    ...     Validate Source Notary


Validate Packages
    [Arguments]    ${build}    ${task}

    ${count}=    Set Variable    0
    Create Directory    ${config.tmpdir}

    ${link elems}=    Get Child WebElements    ${task}     .${xp.task.packages}
    FOR    ${elem}    IN    @{link elems}
        ${link}=    Get Element Attribute    ${elem}    href
        ${filepath}=    Download    ${link}     ${config.tmpdir}
        Should Be Package     ${filepath}
        ${count}=    Evaluate    ${count} + 1
    END

    Remove Directory    ${config.tmpdir}    recursive=True

    IF   ${count} < 0
        Fail    No packages found for build ${build.id}
    END


Should Be Notarized
    [Arguments]    ${elem}

    ${status}=    Get Text    ${elem}
    Should Be Equal As Strings    ${status}     key


Validate Packages Notary
    [Arguments]    ${build}    ${task}

    ${icons}=    Get Child WebElements    ${task}     .${xp.task.packages.notary}
    FOR    ${elem}    IN    @{icons}
        Should Be Notarized    ${elem}
    END


Validate Source
    [Arguments]    ${build}    ${task}

    ${expected}=    Create Dictionary
    FOR    ${each}    IN    @{build.tasks}
        Set To Dictionary   ${expected}     ${each.repo}    ${each.ref}
    END

    ${repo elem}=    Get Child WebElement    ${task}     .${xp.task.repo}
    ${actual repo}=     Get Text    ${repo elem}
    ${actual repo}=     Split String    ${actual repo}      ${\n}
    Dictionary Should Contain Key     ${expected}    ${actual repo[0]}

    ${expected ref}=    Get From Dictionary     ${expected}     ${actual repo[0]}
    ${ref elem}=    Get Child WebElement    ${task}     .${xp.task.ref}
    ${ref link}=    Get Element Attribute    ${ref elem}    href
    ${actual ref}=    Split String    ${ref link}     /
    Should Be Equal As Strings      ${expected ref}      ${actual ref[7]}


Validate Source Notary
    [Arguments]    ${build}    ${task}

    ${elem}=    Get Child WebElement    ${task}     .${xp.task.repo.notary}
    Should Be Notarized    ${elem}


Validate Repositories
    [Arguments]    ${build}    ${task}
    Log Many    ${build}
