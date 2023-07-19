*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images.

Library             RPA.Browser.Selenium    auto_close=${FALSE}
Library             RPA.HTTP
Library             RPA
Library             RPA.Tables
Library             RPA.PDF
Library             RPA.Archive


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    Download the CSV file
    Read it as a table
    Creating a ZIP archive
    [Teardown]    Close the browser


*** Keywords ***
Open the robot order website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order

Click pop-up OK button
    Click Button    OK

Fill order
    [Arguments]    ${order}
    Click pop-up OK button
    Select From List By Value    head    ${order}[Head]
    Select Radio Button    body    ${order}[Body]
    Click Button    Show model info
    Click Button    Hide model info
    Input Text    xpath://input[@placeholder='Enter the part number for the legs']    ${order}[Legs]
    Input Text    address    ${order}[Address]
    Click Button    preview
    Click Button    order
    ${element_visible}=    Is Element Visible    css:.alert-danger
    IF    ${element_visible}
        ${error_message}=    Get_Text    css:.alert-danger
        WHILE    ${element_visible}
            Click Button    order
            ${element_visible}=    Is Element Visible    css:.alert-danger
        END
    END
    Export the receipt as a PDF    ${order}[Order number]
    Wait Until Element Is Visible    order-another
    Click Button    order-another

Download the CSV file
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True

Read it as a table
    ${file_path}=    Set Variable    orders.csv
    ${orders}=    Read table from CSV    ${file_path}    header=True
    FOR    ${order}    IN    @{orders}
        Fill order    ${order}
    END

Export the receipt as a PDF
    [Arguments]    ${Order number}
    Wait Until Element Is Visible    order-completion
    ${pdf}=    Get Element Attribute    id:order-completion    outerHTML
    Html To Pdf    ${pdf}    ${OUTPUT_DIR}${/}tasks${/}${Order number}receipts.pdf
    ${screenshot_path}=    Screenshot    id:robot-preview-image    None
    ${img}=    Create List    ${screenshot_path}
    Add Files To Pdf    ${img}    ${OUTPUT_DIR}${/}tasks${/}${Order number}receipts.pdf    append=${True}

Creating a ZIP archive
    Archive Folder With ZIP
    ...    ${OUTPUT_DIR}${/}tasks
    ...    tasks_zip.zip
    ...    recursive=True

Close the browser
    Close Browser
