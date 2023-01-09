*** Settings ***

Library     SeleniumLibrary

Resource    ${EXECDIR}/resources/items.robot
Resource    ${EXECDIR}/pages/general.robot

*** Variables ***

${id.btn.addmember}         tin-qb-add-new-member
${id.btn.addselmember}      tin-qb-add-member-add
${xp.input.member}          //div[@id="tin-qs-add-member"]/input


*** Keywords ***

Add User To Team
    [Arguments]     ${team name}

    Hide Loading Backdrop
    Click Menu Button   Teams
    Wait Until Element Is Visible    //td[text()="${team name}"]/../td/a   ${config.timeout.element}
    Click Element    //td[text()="${team name}"]/../td/a
    Wait Until Element Is Visible    id=${id.btn.addmember}   ${config.timeout.element}

    ${passed}    Run Keyword And Return Status
                 ...    Page Should Contain Element    //a[text()="${config.albs.email}"]
    IF    ${passed}
        Return From Keyword
    END

    Click Button    id=${id.btn.addmember}
    Wait Until Element Is Visible    id=${id.btn.addselmember}   ${config.timeout.element}
    Fill Editable QSelect    ${xp.input.member}   ${config.albs.username}
    Click Element    id=${id.btn.addselmember}
