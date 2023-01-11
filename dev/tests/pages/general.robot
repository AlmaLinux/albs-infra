*** Settings ***

Library           SeleniumLibrary
Library           DatabaseLibrary
Library           RequestsLibrary
Library           String

Resource    ${EXECDIR}/pages/teams.robot
Resource    ${EXECDIR}/resources/items.robot


*** Variables ***

${id.btn.openmenu}     mla-qb-menu
${xp.btn.logout}       //div[@id="mla-li-logout"]/div[3]/div
${xp.btn.feed}         //a[@id="mla-li-feed"]
${xp.btn.ghlogin}      //*[@id="q-app"]/div/button
${url.token}      ${config.selenium.url}/api/v1/auth/login
${url.login}      ${config.selenium.url}/auth/login/github


*** Keywords ***


Get Child WebElement
    [Arguments]    ${element}    ${locator}

    ${children}     Call Method
    ...                ${element}
    ...                find_element
    ...                  by=xpath    value=${locator}

    RETURN     ${children}


Get Child WebElements
    [Arguments]    ${element}    ${locator}

    ${children}     Call Method
    ...                ${element}
    ...                find_elements
    ...                  by=xpath    value=${locator}

    RETURN     ${children}


Login
    Open Browser To Build System Page
    Activate new user
    Authorize
    Add User To Team    AlmaLinux_team
    Add User To Team    almalinux


Authorize
    ${data}=    Create Dictionary       username=${config.albs.email}       password=${config.albs.password}
    ${response}=    POST    ${url.token}    data=${data}
    Log Many    ${response.json()['access_token']}
    Add Cookie    albs      ${response.json()['access_token']}
    Go To    ${url.login}
    User Successfully Authorized

#Authorize
#    Click Menu Button   Log in
#    Wait Until Element Is Visible    ${xp.btn.ghlogin}   ${config.timeout.element}
#    Click Button    ${xp.btn.ghlogin}
#    Wait Until Element Is Visible    id=login_field    ${config.timeout.element}
#    Input Text      id=login_field      ${config.github.email}
#    Input Password      id=password      ${config.github.password}
#    Click Button    //*[@id="login"]/div[3]/form/div/input[11]
#    Wait Until Page Contains    Feed
#    User Successfully Authorized


User Successfully Authorized
    Wait Until Element Is Visible    id=${id.btn.openmenu}    ${config.timeout.element}
    Click Menu Button
    Wait Until Element Is Visible    ${xp.btn.logout}    ${config.timeout.element}
    Element Text Should Be    ${xp.btn.logout}     Logout


Activate new user
    ${hash}=    Bcrypt Password     ${config.albs.password}

    Connect To Database    psycopg2
    ...     ${config.db.name}
    ...     ${config.db.username}
    ...     ${config.db.password}
    ...     ${config.db.host}
    ...     ${config.db.port}

    ${user} =    Query    SELECT id, username FROM public.users WHERE email = '${config.albs.email}';
    Log    ${user}
    Execute SQL String    UPDATE public.users SET is_superuser = true::boolean, is_verified = true::boolean, hashed_password = '${hash}' WHERE id = ${user[0][0]};

    Set Suite variable    ${config.albs.username}       ${user[0][1]}

    Disconnect From Database


Logout
#    Click Menu Button   Logout
    Close Browser


Open Browser To Build System Page
    Open Browser    ${config.selenium.url}    ${config.selenium.browser}
    Maximize Browser Window
    Set Selenium Speed    ${config.selenium.delay}
    Build System Page Should Be Open


Build System Page Should Be Open
    Title Should Be    AlmaLinux Build System


Click Menu Button
    [Arguments]   ${button name}=${None}

    Hide Loading Backdrop
    ${passed}    Run Keyword And Return Status
                 ...    Element Should Be Visible    ${xp.btn.feed}

    IF     not (${passed})
        Click Button     id=${id.btn.openmenu}
        Wait Until Element Is Visible      ${xp.btn.feed}       ${config.timeout.element}
    END

    IF      "${button name}" != "${None}"
        Wait Until Element Is Visible    ${xp.btn.feed}       ${config.timeout.element}
        Click Element     //div[text()="${button name}"]/../..
    END
    Hide Loading Backdrop


Run Keywords With Argument
    [Arguments]    ${arg}   @{keywords}

    FOR    ${keyword}   IN    @{keywords}
        Run Keyword     ${keyword}    ${arg}
    END


Run Keywords With Two Arguments
    [Arguments]    ${one}    ${two}   @{keywords}

    FOR    ${keyword}   IN    @{keywords}
        Run Keyword     ${keyword}    ${one}    ${two}
    END
