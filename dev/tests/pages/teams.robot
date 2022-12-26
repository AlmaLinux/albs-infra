*** Settings ***

Library           SeleniumLibrary

Resource    ${EXECDIR}/resources/items.robot
Resource    ${EXECDIR}/pages/general.robot

*** Variables ***

${id.btn.addmember}         tin-qb-add-new-member
${id.btn.addselmember}      tin-qb-add-member-add
${xp.input.member}          //div[@id="tin-qs-add-member"]/input


*** Keywords ***

Add User To Team
    [Arguments]     ${team name}
    Click Menu Button   Teams
    Click Element    //td[text()="${team name}"]/../td/a
    Wait Until Element Is Visible    id=${id.btn.addmember}

    ${passed}    Run Keyword And Return Status
                 ...    Page Should Contain Element    //a[text()="${config.github.email}"]
    IF    ${passed}
        Return From Keyword
    END

    Click Button    id=${id.btn.addmember}
    Wait Until Element Is Visible    id=${id.btn.addselmember}
    Fill Editable QSelect    ${xp.input.member}   ${config.github.username}
    Click Element    id=${id.btn.addselmember}
