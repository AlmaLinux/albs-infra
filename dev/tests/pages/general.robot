*** Settings ***

Library           SeleniumLibrary
Library           DatabaseLibrary

Resource    ${EXECDIR}/resources/includes.robot
Resource    ${EXECDIR}/resources/locators.robot
Resource    ${EXECDIR}/resources/vars.robot


*** Keywords ***

Login
    Open Browser To Build System Page
    Authorize
#    Activate new user
#    Add user to team    AlmaLinux_team
#    Add user to team    almalinux


#Login
#    Add Cookie    albs      ${LOGIN TOKEN}      path=/      domain=${HOST}
#    Go To         ${LOGIN URL}
#    User Successfully Authorized

Authorize
    Click Menu Button   Log in
    click button    ${GITHUB LOGIN BUTTON}
    input text      id=login_field      ${GITHUB LOGIN}
    input text      id=password      ${GITHUB PASSWORD}
    click button    //*[@id="login"]/div[3]/form/div/input[11]
    wait until page contains    Feed
    User Successfully Authorized


User Successfully Authorized
    Wait Until Element Is Visible    ${SIDE MENU BUTTON}    ${WAIT_ELEMENT_TIMEOUT}
    Click Menu Button
    Wait Until Element Is Visible    ${SIDE LOGOUT BUTTON}    ${WAIT_ELEMENT_TIMEOUT}
    Element Text Should Be    ${SIDE LOGOUT BUTTON}     Logout


Activate new user
    Connect To Database    psycopg2     ${DBNAME}    ${DBUSER}    ${DBPASS}    ${HOST}    ${DBPORT}

    ${user} =    Query    SELECT id, username FROM public.users WHERE email = '${GITHUB LOGIN}';
    log    ${user}
    Execute SQL String    UPDATE public.users SET is_superuser = true::boolean, is_verified = true::boolean WHERE is_superuser = false::boolean AND is_verified = false::boolean AND id = ${user[0][0]};

    set Suite variable    ${GITHUB USERNAME}       ${user[0][1]}

    Disconnect From Database


Logout
    Click Menu Button   Logout
    Close Browser


Open Browser To Build System Page
    Open Browser    ${MAIN URL}    ${BROWSER}
    Maximize Browser Window
    Set Selenium Speed    ${DELAY}
    Build System Page Should Be Open


Build System Page Should Be Open
    Title Should Be    AlmaLinux Build System


Click Menu Button
    [Arguments]   ${button name}=${None}

    ${passed}    Run Keyword And Return Status
                 ...    Element Should Be Visible    ${SIDE FEED BUTTON}

    IF     not (${passed})
        Click Button     ${SIDE MENU BUTTON}
        Wait Until Element Is Not Visible    ${SIDE LOGOUT BUTTON}      1 min 30 s
    END

    IF      "${button name}" != "${None}"
        click element     //div[text()="${button name}"]/../..
    END


