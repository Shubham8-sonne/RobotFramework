*** Settings ***
Library           SeleniumLibrary
Library           Collections
Library           BuiltIn
Library           JSONLibrary
Test Setup         Open Browser With Dynamic Table URL
Test Teardown      Close Browser

*** Variables ***
${CHROME_DRIVER_PATH}    C:\Users\shubham.sonne\Downloads\chromedriver-win64 (1)\chromedriver-win64\chromedriver.exe
${DYNAMIC_TABLE_URL}     https://testpages.herokuapp.com/styled/tag/dynamic-table.html
${TITLE_XPATH}          //h1[normalize-space()='Dynamic HTML TABLE Tag']
${CLICK_TABLE}           (//summary[normalize-space()='Table Data'])[1]
${CLICK_JSONXPATH}      //textarea[@id='jsondata']
${CLICK_REFRESHED}      //button[@id='refreshtable']
${JsonData}             [{"name": "Bob", "age": 20, "gender": "male"}, {"name": "George", "age": 42, "gender": "male"}, {"name": "Sara", "age": 42, "gender": "female"}, {"name": "Conor", "age": 40, "gender": "male"}, {"name": "Jennifer", "age": 42, "gender": "female"}]

*** Test Cases ***
Open Dynamic Table Page
    [Documentation]    Open the browser with the dynamic table URL and wait for the title
    Wait Until Element Is Visible    ${TITLE_XPATH}    timeout=10
    Click Table Data
    Get Table Data




*** Keywords ***
Open Browser With Dynamic Table URL
    [Documentation]    Open the Chrome browser and navigate to the dynamic table URL
    Create Chrome Options
    Open Browser    ${DYNAMIC_TABLE_URL}    chrome    options=${chrome_options}

Create Chrome Options
    [Documentation]    Create Chrome options for the WebDriver
    ${options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
    Call Method    ${options}    add_argument    --start-maximized
    Set Suite Variable    ${chrome_options}    ${options}

Click Table Data
    [Documentation]    Click on the table data element after ensuring it's visible
    Wait Until Element Is Visible    ${CLICK_TABLE}    timeout=10
    Click Element    ${CLICK_TABLE}
    Click Element    ${CLICK_JSONXPATH}
    Clear Element Text    ${CLICK_JSONXPATH}
    Input Text    ${CLICK_JSONXPATH}    ${JsonData}
    Scroll Element Into View    ${CLICK_REFRESHED}
    Click Element    ${CLICK_REFRESHED}

Get Table Data
    Get Table Data
    [Documentation]    Extract data from the table and return it as a list of dictionaries
    Sleep    5s    # Extra delay to allow data to load if dynamic
    Wait Until Element Is Visible    xpath=//table[@id='dynamictable']//tr[position()>1]    timeout=10    # Adjust XPath as needed
    ${rows}=    Get WebElements    xpath=//table[@id='dynamictable']//tr[position()>1]
    Log    Found rows: ${rows}
    ${table_data}=    Create List
    FOR    ${row}    IN    @{rows}
        ${cells}=    Get WebElements    ${row}/td
        Log    Cells in row: ${cells}
        Run Keyword If    "${cells}" == "[]"    Continue For Loop
        ${row_data}=    Create Dictionary
        ${name}=    Get Text    ${cells}[0]
        ${age}=     Get Text    ${cells}[1]
        ${gender}=  Get Text    ${cells}[2]
        Log    Row Data: name=${name}, age=${age}, gender=${gender}
        Set To Dictionary    ${row_data}    name=${name}    age=${age}    gender=${gender}
        Append To List    ${table_data}    ${row_data}
        log        jsondata: ${table_data}

    END
    Log    Final table data: ${table_data}
    should be equal     ${JsonData}         ${table_data}


