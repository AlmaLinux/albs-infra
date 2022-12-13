*** Settings ***

Library           SeleniumLibrary

Resource    ${EXECDIR}/resources/locators.robot
Resource    ${EXECDIR}/resources/items.robot
Resource    ${EXECDIR}/resources/vars.robot

Resource    ${EXECDIR}/pages/general.robot


*** Keywords ***

Add user to team
    [Arguments]     ${team name}
    Click Menu Button   Teams
    click element    //td[text()="${team name}"]/../td/a
    wait until element is visible    id=team-info-q-btn-add-new-member

    ${passed}    Run Keyword And Return Status
                 ...    Page Should Contain Element    //a[text()="${GITHUB LOGIN}"]
    IF    ${passed}
        return from keyword
    END

    click button    id=team-info-q-btn-add-new-member
    wait until element is visible    id=team-info-q-select-add-new-member
    Fill Editable QSelect   //div[@id="team-info-q-select-add-new-member"]/input    ${GITHUB USERNAME}
#    input text      //div[@id="team-info-q-select-add-new-member"]/input       ${GITHUB USERNAME}
#    press keys    id=team-info-q-select-add-new-member      ARROW_DOWN      ARROW_DOWN      ENTER       ESCAPE
    click element    id=team-info-q-btn-add-member-add
