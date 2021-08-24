# +
*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.

Library         RPA.Tables
Library         RPA.PDF
Library         RPA.Archive
library         RPA.Dialogs
library         RPA.JSON
Library         RPA.Robocloud.Secrets
Library         RPA.Browser.Selenium
Library         RPA.HTTP
# -


*** Keywords ***
Open The Intranet Website
    ${secret}=    Get Secret    URL
    ${file_path}=  Convert To String    ${secret}[file_url]
    Open Available Browser  ${secret}[file_url] 
    #Open Available Browser  https://robotsparebinindustries.com

*** Keywords ***
Log In
    Input Text    username    maria
    Input Password    password    thoushallnotpass
    Submit Form
    
    Wait Until Page Contains Element    id:sales-form


*** Keywords ***
Click on link to order robot
    log Many    Get All Links
    Wait Until Page Contains Element    id:sales-form
    Click Link  xpath://div/ul/li[2]/a
    Wait Until Page Contains Element    css:.modal-dialog
    
    Click Button    xpath://div/div[2]/div/div/div/div/div/button[@class="btn btn-dark"]

*** Keywords ***
Download Order File
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True

*** Keywords ***
Fill The Form Using The Data From The CSV File
    ${selected_file}=   Add file input    label=Please enter file    name=multiple     file_type=csv files (*.csv)  multiple=True
    ${result}=    Run dialog    title=File Input
    Log    ${result.multiple[0]} 
    ${orders}=  Read table from CSV     ${result.multiple[0]}      header=True
    #${orders}=    Convert To String    ${orders}
    FOR    ${orders}    IN    @{orders}
        Log Many  ${orders}
        #${orders}=    Convert To String    ${orders}
        Run Keyword And Continue On Failure    Fill And Submit The Form For Order    ${orders}
        #Fill And Submit The Form For Order    ${orders}
    END

*** Keywords ***
Store the receipt as a PDF file
    #[Arguments]    ${pdf}
    #Wait Until Element Is Visible    id:receipt    
    #${receipt_html}=    Get Element Attribute    id:receipt    outerHTML
    #${receipt_file}=    Html To Pdf    ${receipt_html}    ${CURDIR}${/}output${/}order_robot_${pdf}.pdf


*** Keywords ***
Take a screenshot of the robot
    
    #[Arguments]    ${screenshot}    
    #Wait Until Element Is Visible    id:robot-preview-image  
    #${robo_image}=   Screenshot    id:robot-preview-image    ${CURDIR}${/}output${/}order_robot_${screenshot}.png


*** Keywords ***
#Embed the robot screenshot to the receipt PDF file
 
 #[Arguments]    ${receipt_file}    ${robo_image}
  
  #${files}=    Create List
   # ...    ${receipt_file}
    #...    ${robo_image}
    #Add Files To PDF    ${files}    ${receipt_file}

# +

*** Keywords ***
Fill And Submit The Form For Order 
    [Arguments]    ${orders}
    ${target_as_string}=    Convert To String    ${orders}[Head]
    Select From List By Value    head    ${target_as_string}
    Select Radio Button     body    ${orders}[Body]  
    Input Text    xpath://div/div/div/div/div/form/div[3]/input  ${orders}[Legs] 
    Input Text    address    ${orders}[Address]
    Click Button    preview
    Click Button    order
    
    #${pdf}=    Store the receipt as a PDF file    ${orders}[Order number]
    #${screenshot}=    Take a screenshot of the robot    ${orders}[Order number]     
    Run Keyword And Continue On Failure    Fill And Submit The Form For Order   ${orders}
    Wait Until Element Is Visible    id:receipt     1 min
    
    ${receipt_html}=    Get Element Attribute    id:receipt    outerHTML
    ${receipt_file}=    Html To Pdf    ${receipt_html}    ${CURDIR}${/}output${/}order_robot_${orders}[Order number].pdf
    Wait Until Element Is Visible    id:robot-preview-image 
    ${robo_image}=   Screenshot    id:robot-preview-image    ${CURDIR}${/}output${/}order_robot_${orders}[Order number].png
    ${files}=    Create List
    ...    ${CURDIR}${/}output${/}order_robot_${orders}[Order number].pdf
    ...    ${CURDIR}${/}output${/}order_robot_${orders}[Order number].png:align=center
    Add Files To PDF    ${files}    ${CURDIR}${/}output${/}PDFs${/}order_robot_${orders}[Order number].pdf
    #Embed the robot screenshot to the receipt PDF file    ${receipt_file}    ${robo_image}
    
    Click Button    order-another
    Wait Until Page Contains Element    css:.modal-dialog
    
    Click Button    xpath://div/div[2]/div/div/div/div/div/button[@class="btn btn-dark"]

# +

*** Keywords ***
Log Out And Close The Browser
    Click Button    Log out
    Close Browser
# -

*** Keywords ***
Create ZIP package from PDF files
    #${zip_file_name}=    Set Variable   ${CURDIR}${/}output${/}PDFs.zip
    Archive Folder With Zip
    ...    ${CURDIR}${/}output${/}PDFs${/}
    ...    ${CURDIR}${/}output${/}PDFs.zip

*** Tasks ***
Minimal task
    Open The Intranet Website
    Log In
    Click on link to order robot
    Download Order File
    Fill The Form Using The Data From The CSV File
    Log Out And Close The Browser
    Create ZIP package from PDF files


