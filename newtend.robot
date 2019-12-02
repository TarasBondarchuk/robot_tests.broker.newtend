*** Settings ***
Library  Selenium2Screenshots
Library  String
Library  DateTime
Library  newtend_service.py

*** Variables ***
${acceleration}=  70

*** Keywords ***


Підготувати клієнт для користувача
    [Arguments]  ${username}
    Set Suite Variable  ${my_alias}  my_${username}
    ${chrome_options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys
    Run Keyword If  '${USERS.users['${username}'].browser}' in 'Chrome chrome'  Run Keywords
    ...  Call Method  ${chrome_options}  add_argument  --headless
    ...  AND  Create Webdriver  Chrome  alias=${my_alias}  chrome_options=${chrome_options}
    ...  AND  Go To  ${USERS.users['${username}'].homepage}
    ...  ELSE  Open Browser  ${USERS.users['${username}'].homepage}  ${USERS.users['${username}'].browser}  alias=${my_alias}
    Set Window Size  ${USERS.users['${username}'].size[0]}  ${USERS.users['${username}'].size[1]}
    Run Keyword If  'Viewer' not in '${username}'  Run Keywords
    ...  Авторизація  ${username}
    ...  AND  Run Keyword And Ignore Error  Закрити Модалку


Підготувати дані для оголошення тендера
    [Arguments]  ${username}  ${initial_tender_data}  ${role}
    ${tender_data}=  prepare_tender_data  ${role}  ${initial_tender_data}
    [Return]  ${tender_data}


Оновити сторінку з тендером
    [Arguments]  ${username}  ${tender_uaid}
    Switch Browser  ${my_alias}
    centrex.Пошук Тендера По Ідентифікатору  ${username}  ${tender_uaid}


Авторизація
    [Arguments]  ${username}
    Click Element  xpath=//*[contains(@href, "/login")]
    Wait Until Element Is Visible  xpath=//button[@name="login-button"]
    Input Text  xpath=//input[@id="loginform-username"]  ${USERS.users['${username}'].login}
    Input Text  xpath=//input[@id="loginform-password"]  ${USERS.users['${username}'].password}
    Click Element  xpath=//button[@name="login-button"]


Створити тендер
<<<<<<< .merge_file_a18660
    [Arguments]  ${tender_owner}  ${tender_data}
    Run Keyword And Ignore Error  Закрити Модалку
    ${data}=  Set Variable  ${tender_data.data}
    ${items}=  Get From Dictionary  ${tender_data.data}  items
    Click Element  xpath=//li[@class="dropdown"]/descendant::*[@class="dropdown-toggle"][contains(@href, "tenders")]
    Click Element  xpath=//*[@class="dropdown-menu"]/descendant::*[contains(@href, "/tenders/index")]
    Click Element  xpath=//button[@id='create_auction_modal_btn']
    Wait Until Element Is Visible  xpath=//button[@id="disqualification"]
    Select From List By Value  xpath=//select[@id="tenders-tender_method"]  open_${data.procurementMethodType}
    Click Element  xpath=//button[@id="disqualification"]
    Wait Until Element Is Visible  xpath=//input[@id="value-amount"]
    Convert Input Data To String  xpath=//input[@id="value-amount"]  ${tender_data.data.value.amount}
    Adapt And Select By Value  xpath=//select[@id="value-valueaddedtaxincluded"]  ${tender_data.data.value.valueAddedTaxIncluded}
    Convert Input Data To String  //input[@id="minimalstepvalue-amount"]  ${tender_data.data.minimalStep.amount}
    Convert Input Data To String  //input[@id="guarantee-amount"]  ${tender_data.data.guarantee.amount}
    Input Text  xpath=//*[@id="tender-title"]  ${tender_data.data.title}
    Input Text  xpath=//*[@id="tender-description"]  ${tender_data.data.description}
    Input Text  xpath=//*[@id="tender-dgfid"]  ${tender_data.data.dgfID}
    ${decision_date}=  dgf_decision_date_for_site  ${data.dgfDecisionDate}
    Input Text  xpath=//*[@id="dgf-decision-date"]  ${decision_date}
    Input Text  xpath=//*[@id="tender-dgfdecisionid"]  ${data.dgfDecisionID}
    ${tenderAttempts}=  Convert To String  ${tender_data.data.tenderAttempts}
    Select From List By Value  xpath=//*[@id="tender-tenderattempts"]  ${tenderAttempts}
    ${items_length}=  Get Length  ${items}
    :FOR  ${item}  IN RANGE  ${items_length}
    \  Log  ${items[${item}]}
    \  Run Keyword If  ${item} > 0  Scroll To And Click Element  xpath=//button[@id="add-item"]
    \  centrex.Додати Предмет   ${item}  ${items[${item}]}
    ${auction_date}=  convert_date_for_auction  ${data.auctionPeriod.startDate}
    Execute Javascript  $('#auction-start-date').val('${auction_date}');
    Input Text  //*[@id="contactpoint-name"]  ${data.procuringEntity.contactPoint.name}
    Input Text  //*[@id="contactpoint-email"]  ${data.procuringEntity.contactPoint.email}
    Input Text  //*[@id="contactpoint-telephone"]  '000${data.procuringEntity.contactPoint.telephone}'
    Execute Javascript  $('#procurementMethodDetails_accelerator').val('quick, accelerator=${acceleration}');
    Click Element  //*[@name="simple_submit"]
    Wait Until Element Is Visible  xpath=//div[@data-test-id="tenderID"]  20
    ${auction_id}=  Get Text  xpath=//div[@data-test-id="tenderID"]
    [Return]  ${auction_id}


Додати Предмет
    [Arguments]  ${item}  ${item_data}
    Input Text  xpath=//*[@id="item-${item}-description"]  ${item_data.description}
    Convert Input Data To String  xpath=//*[@id="item-${item}-quantity"]  ${item_data.quantity}
    Click Element  xpath=//*[@id="classification-${item}-description"]
    Wait Until Element Is Visible  xpath=//*[@class="modal-title"]
    Input Text  xpath=//*[@placeholder="Пошук по коду"]  ${item_data.classification.id}
    Wait Until Element Is Visible  xpath=//*[@id="${item_data.classification.id}"]
    Scroll To And Click Element  xpath=//*[@id="${item_data.classification.id}"]
    Wait Until Element Is Enabled  xpath=//button[@id="btn-ok"]
    Click Element  xpath=//button[@id="btn-ok"]
    Wait Until Element Is Not Visible  xpath=//*[@class="fade modal"]
    Wait Until Element Is Visible  xpath=//*[@id="unit-${item}-code"]
    Select From List By Value  xpath=//*[@id="unit-${item}-code"]  ${item_data.unit.code}
    Select From List By Value  xpath=//*[@id="deliveryaddress-${item}-countryname"]  ${item_data.deliveryAddress.countryName}
    Scroll To  xpath=//*[@id="deliveryaddress-${item}-region"]
    Wait Until Element Is Visible  xpath=//option[contains(text(), "Регіон")]
    Select From List By Label  xpath=//*[@id="deliveryaddress-${item}-region"]  ${item_data.deliveryAddress.region}
    Input Text  xpath=//*[@id="deliveryaddress-${item}-locality"]  ${item_data.deliveryAddress.locality}
    Input Text  xpath=//*[@id="deliveryaddress-${item}-streetaddress"]  ${item_data.deliveryAddress.streetAddress}
    Input Text  xpath=//*[@id="deliveryaddress-${item}-postalcode"]  ${item_data.deliveryAddress.postalCode}

=======
  [Arguments]  ${username}  ${tender_data}
  ${items}=  Get From Dictionary  ${tender_data.data}  items
  ${number_of_items}=  Get Length  ${items}
  ${tenderAttempts}=  Convert To String  ${tender_data.data.tenderAttempts}
  ${minNumberOfQualifiedBids}=  Convert To String  ${tender_data.data.minNumberOfQualifiedBids}
  ${guarantee}=  Convert To String  ${tender_data.data.guarantee.amount}
  Switch Browser  ${my_alias}
  Wait Until Page Contains Element  xpath=//a[@href="http://centrex.byustudio.in.ua/tenders"]  10
  Click Element  xpath=//a[@href="http://centrex.byustudio.in.ua/tenders"]
  Click Element  xpath=//a[@href="http://centrex.byustudio.in.ua/tenders/index"]
  Click Element  xpath=//a[contains(@href,"buyer/tender/create")]
  Select From List By Value  name=tender_method  open_${tender_data.data.procurementMethodType}_2
  Select From List By Value  id=tender-rent-select  rent
  Conv And Select From List By Value  name=Tender[value][valueAddedTaxIncluded]  ${tender_data.data.value.valueAddedTaxIncluded}
  ConvToStr And Input Text  name=Tender[value][amount]  ${tender_data.data.value.amount}
  ConvToStr And Input Text  name=Tender[minimalStep][amount]  ${tender_data.data.minimalStep.amount}
  ConvToStr And Input Text  name=Tender[guarantee][amount]  ${guarantee}
  Input text  name=Tender[title]  ${tender_data.data.title}
  Input text  name=Tender[dgfID]  ${tender_data.data.dgfID}
  Input text  name=Tender[description]  ${tender_data.data.description}
  Select From List By Value  name=Tender[tenderAttempts]  ${tenderAttempts}
  Select From List By Value  id=tender-minnumberofqualifiedbids  ${minNumberOfQualifiedBids}
  Input Date  name=Tender[auctionPeriod][startDate]  ${tender_data.data.auctionPeriod.startDate}
  :FOR  ${index}  IN RANGE  ${number_of_items}
  \  Run Keyword If  ${index} != 0  Scroll And Click  xpath=(//button[@id="add-item"])[last()]
  \  Додати предмет  ${items[${index}]}  ${index}
  Select From List By Index  id=contact-point-select  1
  Scroll And Click  id=btn-submit-form
  Wait Until Page Contains Element  xpath=//*[@data-test-id="tenderID"]  10
  ${tender_uaid}=  Get Text  xpath=//*[@data-test-id="tenderID"]
  [return]  ${tender_uaid}

Додати предмет
  [Arguments]  ${item}  ${index}
  ${index}=  Convert To Integer  ${index}
  ${quantity}=  Convert To String  ${item.quantity}
  Input text  name=Tender[items][${index}][description]  ${item.description}
  Input text  name=Tender[items][${index}][quantity]  ${quantity}
  Select From List By Label  xpath=(//*[@id="classification-scheme"])[last()]  ${item.classification.scheme}
  Scroll And Click  name=Tender[items][${index}][classification][description]
  Wait Until Element Is Visible  id=search_code   30
  Input text  id=search_code  ${item.classification.id}
  Wait Until Page Contains  ${item.classification.id}
  Scroll And Click  xpath=//span[contains(text(),'${item.classification.id}')]
  Scroll And Click  id=btn-ok
  Run Keyword And Ignore Error  Wait Until Element Is Not Visible  xpath=//div[@class="modal-backdrop fade"]  10
  Select From List By Value  name=Tender[items][${index}][unit][code]  ${item.unit.code}
  Select From List By Label  name=Tender[items][${index}][address][countryName]  ${item.deliveryAddress.countryName}
  Wait Until Keyword Succeeds  5 x  1 s  Page Should Contain Element  xpath=//select[@name="Tender[items][${index}][address][region]"]/option[contains(text(),"${item.deliveryAddress.region}")]
  Select From List By Label  name=Tender[items][${index}][address][region]  ${item.deliveryAddress.region}
  Input text  name=Tender[items][${index}][address][locality]  ${item.deliveryAddress.locality}
  Input text  name=Tender[items][${index}][address][streetAddress]  ${item.deliveryAddress.streetAddress}
  Input text  name=Tender[items][${index}][address][postalCode]  ${item.deliveryAddress.postalCode}
  Input Date  name=Tender[items][${index}][contractPeriod][startDate]  ${item.contractPeriod.startDate}
  Input Date  name=Tender[items][${index}][contractPeriod][endDate]  ${item.contractPeriod.endDate}
>>>>>>> .merge_file_a20448

Додати предмет закупівлі
    [Arguments]  ${tender_owner}  ${tender_uaid}  ${item_data}
    centrex.Пошук Тендера По Ідентифікатору  ${tender_owner}  ${tender_uaid}
    Wait For Document Upload
    Scroll To And Click Element  xpath=//button[@id="add-item"]
    ${item_number}=  Get Element Attribute  xpath=(//input[contains(@class, "item-id")])[last()]@id
    ${item_number}=  Set Variable  ${item_number.split('-')[-2]}
    centrex.Додати Предмет  ${item_number}  ${item_data}
    Scroll To  xpath=//*[@action="/tender/fileupload"]/input
    ${file}=  my_file_path
    Choose File  xpath=(//*[@action="/tender/fileupload"]/input)[last()]  ${file}
    Wait Until Element Is Visible  xpath=(//*[@class="document-title"])[last()]
    Input Text  xpath=(//*[@class="document-title"])[last()]  Погодження змін до опису лоту
    Select From List By Value  xpath=(//*[@class="document-type"])[last()]  clarifications
    Встановити тип документу
    Click Element  //*[@name="simple_submit"]
    Wait Until Element Is Visible  xpath=//div[@data-test-id="tenderID"]  20
    Wait Until Keyword Succeeds  30 x  20 s  Run Keywords
    ...  Синхронізуватися із ЦБД
    ...  AND  Wait Until Page Does Not Contain   Документ завантажується...  10


Видалити предмет закупівлі
    [Arguments]  ${tender_owner}  ${tender_uaid}  ${item_id}
    centrex.Пошук Тендера По Ідентифікатору  ${tender_owner}  ${tender_uaid}
    Click Element  xpath=//*[@data-test-id="sidebar.edit"]
    Wait Until Element Is Visible  xpath=//*[@id="auction-form"]
    Run Keyword And Ignore Error  Click Element  xpath=(//button[@class="remove-item"])[last()]


Скасувати закупівлю
    [Arguments]  ${tender_owner}  ${tender_uaid}  ${cancellation_reason}  ${file_path}  ${cancellation_description}
    centrex.Пошук Тендера По Ідентифікатору  ${tender_owner}  ${tender_uaid}
    Click Element  xpath=//*[@data-test-id="sidebar.cancell"]
    Select From List By Value  //*[@id="cancellation-relatedlot"]  tender
    Select From List By Label  //*[@id="cancellation-reason"]  ${cancellation_reason}
    Choose File  xpath=//*[@action="/tender/fileupload"]/input  ${file_path}
    Wait Until Element Is Visible  xpath=(//input[@class="file_name"])[last()]
    Input Text  xpath=(//input[@class="file_name"])[last()]  ${file_path.split('/')[-1]}
    Click Element  xpath=//button[@id="submit-cancel-auction"]
    Wait Until Element Is Visible  xpath=//*[@data-test-id="sidebar.cancell"]
    Wait Until Keyword Succeeds  30 x  20 s  Run Keywords
    ...  Синхронізуватися із ЦБД
    ...  AND  Page Should Contain Element  xpath=//*[@data-test-id-cancellation-status="active"]


Внести зміни в тендер
    [Arguments]  ${tender_owner}  ${tender_uaid}  ${field_name}  ${field_value}
    centrex.Пошук Тендера По Ідентифікатору  ${tender_owner}  ${tender_uaid}
    Run Keyword And Ignore Error  Wait For Document Upload
    Run Keyword If
    ...  '${field_name}' == 'value.amount'  Convert Input Data To String  xpath=//input[@id="value-amount"]  ${field_value}
    ...  ELSE IF  '${field_name}' == 'minimalStep.amount'  Convert Input Data To String  xpath=//input[@id="minimalstepvalue-amount"]  ${field_value}
    ...  ELSE IF  '${field_name}' == 'guarantee.amount'  Convert Input Data To String  xpath=//input[@id="guarantee-amount"]  ${field_value}
    ...  ELSE IF  '${field_name}' == 'tenderPeriod.startDate'  Input Text  xpath=//*[@id="auction-start-date"]  ${field_value}
    ...  ELSE IF  '${field_name}' == 'title'  Input Text  xpath=//*[@id="tender-title"]  ${field_value}
    ...  ELSE IF  '${field_name}' == 'description'  Input Text  xpath=//*[@id="tender-description"]  ${field_value}
    ...  ELSE IF  '${field_name}' == 'dgfDecisionDate'  Change DGF Date  ${field_name}  ${field_value}
    ...  ELSE IF  '${field_name}' == 'tenderAttempts'  Change Attempts  ${field_value}
    ...  ELSE  Input text  name=Tender[${field_name}]  ${field_value}
    Scroll To  xpath=//*[@action="/tender/fileupload"]/input
    ${file}=  my_file_path
    Choose File  xpath=(//*[@action="/tender/fileupload"]/input)[last()]  ${file}
    Wait Until Element Is Visible  xpath=(//*[@class="document-title"])[last()]
    Input Text  xpath=(//*[@class="document-title"])[last()]  Погодження змін до опису лоту
    Select From List By Value  xpath=(//*[@class="document-type"])[last()]  clarifications
    Встановити тип документу
    #Select From List By Value  xpath=(//*[@class="document-related-item"])[last()]  tender
    Scroll To And Click Element  xpath=//*[@name="simple_submit"]
    Wait Until Keyword Succeeds  20 x  1 s  Element Should Be Visible  xpath=//div[contains(@class,'alert-success')]


Встановити тип документу
    ${doc_count}=  Get Matching Xpath Count  xpath=(//*[@class="document-related-item"])
    ${doc_count}=  Convert To Integer  ${doc_count}
    :FOR  ${index}  IN RANGE  ${doc_count - 1}
    \  Select From List By Value  xpath=(//*[@class="document-related-item"])[${index + 2}]  tender


Завантажити документ
<<<<<<< .merge_file_a18660
    [Arguments]  ${tender_owner}  ${file_path}  ${tender_uaid}
    centrex.Завантажити документ в тендер з типом  ${tender_owner}  ${tender_uaid}  ${file_path}  clarifications
=======
  [Arguments]  ${username}  ${filepath}  ${tender_uaid}  ${illustration}=False
  Switch Browser  ${my_alias}
  centrex.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Click Element  xpath=//a[contains(text(),'Редагувати')]
  Wait Until Element Is Visible  id=btn-submit-form
  Choose File  xpath=(//input[@type="file"])[last()]  ${filepath}
  Wait Until Keyword Succeeds  10 x  1 s  Element Should Be Visible  xpath=(//option[text()="Оберіть тип документа"]/..)[last()]
  Select From List By Value   xpath=(//select[@class="document-type"])[last()]   illustration
  Select From List By Value   xpath=(//select[@class="document-related-item"])[last()]   tender
  Clear Element Text  xpath=(//input[@class="document-title"])[last()]
  Input Text  xpath=(//input[@class="document-title"])[last()]   ${filepath.split('/')[-1]}
  Click Button  id=btn-submit-form
  Wait Until Keyword Succeeds  10 x  1 s  Element Should Not Be Visible  id=btn-submit-form
  Дочекатися завантаження документу
>>>>>>> .merge_file_a20448


Завантажити ілюстрацію
    [Arguments]  ${tender_owner}  ${tender_uaid}  ${file_path}
    centrex.Завантажити документ в тендер з типом  ${tender_owner}  ${tender_uaid}  ${file_path}  illustration


Завантажити документ в тендер з типом
<<<<<<< .merge_file_a18660
    [Arguments]  ${tender_owner}  ${tender_uaid}  ${file_path}  ${doc_type}
    Wait For Document Upload
    Scroll To  xpath=//*[@action="/tender/fileupload"]/input
    Choose File  xpath=(//*[@action="/tender/fileupload"]/input)[last()]  ${file_path}
    Wait Until Element Is Visible  xpath=(//*[@class="document-title"])[last()]
    Input Text  xpath=(//*[@class="document-title"])[last()]  ${file_path.split('/')[-1]}
    Select From List By Value  xpath=(//*[@class="document-type"])[last()]  ${doc_type}
    #Select From List By Value  xpath=(//*[@class="document-related-item"])[last()]  tender
    Встановити тип документу
    Scroll To And Click Element  xpath=//*[@name="simple_submit"]
    Wait Until Element Is Visible  xpath=//*[@data-test-id="sidebar.edit"]
    Wait Until Keyword Succeeds  30 x  20 s  Run Keywords
    ...  Синхронізуватися із ЦБД
    ...  AND  Wait Until Page Does Not Contain   Документ завантажується...  10
=======
  [Arguments]  ${username}  ${tender_uaid}  ${filepath}  ${documentType}
  Switch Browser  ${my_alias}
  centrex.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Click Element  xpath=//a[contains(text(),'Редагувати')]
  Wait Until Element Is Visible  id=btn-submit-form
  Choose File  xpath=(//*[@name="FileUpload[file]"])[last()]  ${filepath}
  Wait Until Keyword Succeeds  10 x  1 s  Element Should Be Visible  xpath=(//option[text()="Оберіть тип документа"]/..)[last()]
  Select From List By Value   xpath=(//select[@class="document-type"])[last()]   ${documentType}
  Select From List By Value   xpath=(//select[@class="document-related-item"])[last()]   tender
  Clear Element Text  xpath=(//input[@class="document-title"])[last()]
  Input Text  xpath=(//input[@class="document-title"])[last()]   ${filepath.split('/')[-1]}
  Click Button  id=btn-submit-form
  Wait Until Keyword Succeeds  20 x  1 s  Element Should Not Be Visible  id=btn-submit-form
  Дочекатися завантаження документу
>>>>>>> .merge_file_a20448


Додати офлайн документ
<<<<<<< .merge_file_a18660
    [Arguments]  ${tender_owner}  ${TENDER['TENDER_UAID']}  ${accessDetails}
    Wait For Document Upload
    Scroll To  xpath=//*[@data-type="x_dgfAssetFamiliarization"]
    Click Element  xpath=//*[@data-type="x_dgfAssetFamiliarization"]
    Input Text  xpath=(//*[@class="document-title"])[last()]  ${accessDetails}
    Input Text  xpath=(//*[@class="document-access-details"])[last()]  ${accessDetails}
    Встановити тип документу
    Scroll To And Click Element  xpath=//*[@name="simple_submit"]
    Wait Until Element Is Visible  xpath=//*[@data-test-id="sidebar.edit"]
    Wait Until Keyword Succeeds  30 x  20 s  Run Keywords
    ...  Синхронізуватися із ЦБД
    ...  AND  Wait Until Page Does Not Contain   Документ завантажується...  10

=======
  [Arguments]  ${username}  ${tender_uaid}  ${accessDetails}  ${title}=Familiarization with bank asset
  centrex.Пошук тендера по ідентифікатору   ${username}   ${tender_uaid}
  Click Element  xpath=//a[contains(text(),'Редагувати')]
  Scroll And Click  xpath=//button[@data-type="x_dgfAssetFamiliarization"]
  Wait Until Element Is Visible  xpath=(//input[@class="document-access-details"])[last()]
  Input Text  xpath=(//input[@class="document-access-details"])[last()]  ${accessDetails}
  Input Text  xpath=(//input[@class="document-title"])[last()]  ${title}
  Click Button  id=btn-submit-form

Пошук тендера по ідентифікатору
  [Arguments]  ${username}  ${tender_uaid}
  Switch Browser  ${my_alias}
  Go To  http://centrex.byustudio.in.ua/tenders/index
  Sleep  3
  ${is_events_visible}=  Run Keyword And Return Status  Element Should Be Visible  xpath=//button[contains(@id,"-read-all")]
  Run Keyword If  ${is_events_visible}  Click Element  id=buyer-read-all
  Click Element  id=more-filter
  Дочекатися Анімації  id=tenderssearch-tender_cbd_id
  Wait Until Element Is Visible  name=TendersSearch[tender_cbd_id]  10
  Input text  name=TendersSearch[tender_cbd_id]  ${tender_uaid}
  Wait Until Keyword Succeeds  6x  20s  Run Keywords
  ...  Дочекатися І Клікнути  xpath=//button[text()='Шукати']
  ...  AND  Wait Until Element Is Visible  xpath=//*[contains(@class, "btn-search_cancel")]  10
  ...  AND  Wait Until Element Is Visible  xpath=//*[contains(text(),'${tender_uaid}')]/ancestor::div[@class="search-result"]/descendant::a[1]  10
  Click Element  xpath=//*[contains(text(),'${tender_uaid}')]/ancestor::div[@class="search-result"]/descendant::a[1]
  Wait Until Element Is Visible  xpath=//*[@data-test-id="tenderID"]  10

Перейти на сторінку з інформацією про тендер
  [Arguments]  ${tender_uaid}
  Click Element  xpath=//button[@data-test-id="search"]
  Wait Until Element Is Visible  xpath=//*[contains(text(),'${tender_uaid}') and contains('${tender_uaid}', normalize-space(text()))]/ancestor::div[@class="search-result"]/descendant::a[contains(@href,"/view/")]  10
  Wait Until Keyword Succeeds  5 x  1 s  Click Element  xpath=//*[contains(text(),'${tender_uaid}') and contains('${tender_uaid}', normalize-space(text()))]/ancestor::div[@class="search-result"]/descendant::a[contains(@href,"/view/")]
  Wait Until Keyword Succeeds  10 x  1 s  Element Should Be Visible  xpath=//*[@data-test-id="tenderID"]
>>>>>>> .merge_file_a20448

Додати публічний паспорт активу
    [Arguments]  ${tender_owner}  ${tender_uaid}  ${certificate_url}
    Wait For Document Upload
    Scroll To  xpath=//button[@data-type="x_dgfPublicAssetCertificate"]
    Click Element  xpath=//button[@data-type="x_dgfPublicAssetCertificate"]
    Wait Until Element Is Visible  xpath=//div[contains(@class, "panel-heading")]/span[contains(text(), "Посилання на публічний паспорт активу")]
    Input Text  xpath=(//*[@class="document-title"])[last()]  Посилання на публічний паспорт активу
    Input Text  xpath=(//*[@class="document-url"])[last()]  ${certificate_url}
    Встановити тип документу
    Scroll To And Click Element  xpath=//*[@name="simple_submit"]
    Wait Until Element Is Visible  xpath=//*[@data-test-id="sidebar.edit"]
    Wait Until Keyword Succeeds  30 x  20 s  Run Keywords
    ...  Синхронізуватися із ЦБД
    ...  AND  Wait Until Page Does Not Contain   Документ завантажується...  10

<<<<<<< .merge_file_a18660
=======
Внести зміни в тендер
  [Arguments]  ${username}  ${tender_uaid}  ${field_name}  ${field_value}
  ${field_value}=  Convert To String  ${field_value}
  centrex.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Click Element  xpath=//a[contains(text(),'Редагувати')]
  ${guarantee}=  Get Value  id=guarantee-amount
  Input text  name=Tender[${field_name.replace(".", "][")}]  ${field_value}
  Run Keyword If  "${field_name}" == "value.amount"  Run Keywords
  ...  Clear Element Text  id=guarantee-amount
  ...  AND  Input Text  id=guarantee-amount  ${guarantee}
  Click Element  id=btn-submit-form
  Wait Until Element Is Visible  xpath=//div[contains(@class,'alert-success')]  10
  Wait Until Keyword Succeeds  10 x  30 s  Run Keywords
  ...  Reload Page
  ...  AND  Page Should Contain  ${field_value}
>>>>>>> .merge_file_a20448

Додати Virtual Data Room
    [Arguments]  ${tender_owner}  ${tender_uaid}  ${vdr_url}
    Wait For Document Upload
    Scroll To  xpath=//button[@data-type="virtualDataRoom"]
    Click Element  xpath=//button[@data-type="virtualDataRoom"]
    Wait Until Element Is Visible  xpath=//div[contains(@class, "panel-heading")]/span[contains(text(), "Посилання на VDR")]
    Input Text  xpath=(//*[@class="document-title"])[last()]  Посилання на VDR
    Input Text  xpath=(//*[@class="document-url"])[last()]  ${vdr_url}
    Встановити тип документу
    Scroll To And Click Element  xpath=//*[@name="simple_submit"]
    Wait Until Element Is Visible  xpath=//*[@data-test-id="sidebar.edit"]
    Wait Until Keyword Succeeds  30 x  20 s  Run Keywords
    ...  Синхронізуватися із ЦБД
    ...  AND  Wait Until Page Does Not Contain   Документ завантажується...  10


Відповісти на запитання
    [Arguments]  ${username}  ${tender_uaid}  ${answer}  ${question_id}
    centrex.Пошук Тендера По Ідентифікатору  ${username}  ${tender_uaid}
    Click Element  xpath=//*[@data-test-id="sidebar.questions"]
    Wait Until Element Is Not Visible  xpath=//*[@data-test-id="sidebar.questions"]
    centrex.Закрити Модалку
    Click Element  xpath=//*[@id="slidePanelToggle"]
    Input Text  //*[@data-test-id="question.title"][contains(text(), "${question_id}")]/following-sibling::form[contains(@action, "tender/questions")]/descendant::textarea  ${answer.data.answer}
    Scroll To And Click Element  //*[@data-test-id="question.title"][contains(text(), "${question_id}")]/../descendant::button[@name="answer_question_submit"]
    Wait Until Keyword Succeeds  20 x  1 s  Wait Until Element Is Not Visible  xpath=//*[@data-test-id="question.title"][contains(text(), "${question_id}")]/following-sibling::form[contains(@action, "tender/questions")]/descendant::textarea

<<<<<<< .merge_file_a18660
=======
Скасувати закупівлю
  [Arguments]  ${username}  ${tender_uaid}  ${cancellation_reason}  ${document}  ${new_description}
  centrex.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Click Element  xpath=//a[contains(@href,'/tender/cancel/')]
  Select From List By Value  id=cancellation-relatedlot  tender
  Select From List By Value  id=cancellation-reason  ${cancellation_reason}
  Choose File  xpath=//input[@type="file"]  ${document}
  Wait Until Element Is Visible  name=Tender[cancellations][documents][0][title]
  Input Text  name=Tender[cancellations][documents][0][title]  ${document.replace('/tmp/', '')}
  Click Element  id=submit-cancel-auction
  Wait Until Element Is Visible  xpath=//div[contains(@class,'alert-success')]
  Wait Until Keyword Succeeds  30 x  1 m  Звірити статус тендера  ${username}  ${tender_uaid}  cancelled

###############################################################################################################
############################################    ПИТАННЯ    ####################################################
###############################################################################################################

Задати питання
  [Arguments]  ${username}  ${tender_uaid}  ${question}  ${item_id}=False
  centrex.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Wait Until Element Is Enabled  xpath=//a[@data-test-id="sidebar.questions"]
  Click Element  xpath=//a[@data-test-id="sidebar.questions"]
  ${status}  ${item_option}=   Run Keyword And Ignore Error   Get Text   //option[contains(text(), '${item_id}')]
  Run Keyword If  '${status}' == 'PASS'   Select From List By Label  name=Question[questionOf]  ${item_option}
  Input Text  name=Question[title]  ${question.data.title}
  Input Text  name=Question[description]  ${question.data.description}
  Click Element  name=question_submit
  Wait Until Page Contains Element  xpath=//div[contains(@class,'alert-success')]  30
>>>>>>> .merge_file_a20448

Задати запитання на тендер
    [Arguments]  ${username}  ${tender_uaid}  ${question}
    centrex.Пошук Тендера По Ідентифікатору  ${username}  ${tender_uaid}
    Wait Until Element Is Visible  xpath=//*[@data-test-id="sidebar.questions"]
    Click Element  xpath=//*[@data-test-id="sidebar.questions"]
    Input Text  xpath=//input[@id="question-title"]  ${question.data.title}
    Input Text  xpath=//textarea[@id="question-description"]  ${question.data.description}
    Select From List By Value  //select[@id="question-questionof"]  tender
    Click Element  //button[@name="question_submit"]
    Wait Until Page Contains  ${question.data.title}


Задати запитання на предмет
    [Arguments]  ${username}  ${tender_uaid}  ${item_id}  ${question}
    centrex.Пошук Тендера По Ідентифікатору  ${username}  ${tender_uaid}
    Wait Until Element Is Visible  xpath=//*[@data-test-id="sidebar.questions"]
    Click Element  xpath=//*[@data-test-id="sidebar.questions"]
    Input Text  xpath=//input[@id="question-title"]  ${question.data.title}
    Input Text  xpath=//textarea[@id="question-description"]  ${question.data.description}
    ${item_name}=  Get Text  xpath=//*[@id="question-questionof"]/descendant::*[contains(text(), "${item_id}")]
    Select From List By Label  xpath=//select[@id="question-questionof"]  ${item_name}
    Click Element  //button[@name="question_submit"]
    Wait Until Keyword Succeeds  20 x  1 s  Element Should Be Visible  xpath=//div[contains(@class,'alert-success')]

<<<<<<< .merge_file_a18660

Подати цінову пропозицію
    [Arguments]   ${username}  ${tender_uaid}  ${bid}
    centrex.Пошук Тендера По Ідентифікатору  ${username}  ${tender_uaid}
    Run Keyword If  '${MODE}' != 'dgfInsider'  Run Keywords
    ...  Wait Until Element Is Visible  //input[@id="value-amount"]
    ...  AND  Convert Input Data To String  xpath=//input[@id="value-amount"]  ${bid.data.value.amount}
    ...  ELSE  Click Element  xpath=//input[@id="bid-participate"]//..
    Wait Until Keyword Succeeds  30 x  5 s  Run Keywords
    ...  Run Keyword And Ignore Error  Click Element  //button[@id="submit_bid"]
    ...  AND  Wait Until Page Contains  очікує модерації
    ${qualified}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${bid.data}  qualified
    Run Keyword If  ${qualified}
    ...  Proposition  ${username}  ${bid.data}
    centrex.Пошук Тендера По Ідентифікатору  ${username}  ${tender_uaid}
    Page Should Contain Element  //*[contains(@class, "label-success")][contains(text(), "опубліковано")]

=======
Відповісти на запитання
  [Arguments]  ${username}  ${tender_uaid}  ${answer_data}  ${question_id}
  centrex.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Wait Until Element Is Enabled  xpath=//a[@data-test-id="sidebar.questions"]
  Click Element  xpath=//a[@data-test-id="sidebar.questions"]
  Toggle Sidebar
  Wait Until Element Is Visible  xpath=//*[contains(text(),'${question_id}')]/../descendant::textarea[contains(@name,'[answer]')]
  Input text  xpath=//*[contains(text(),'${question_id}')]/../descendant::textarea[contains(@name,'[answer]')]  ${answer_data.data.answer}
  Scroll And Click  xpath=//*[contains(text(),'${question_id}')]/../descendant::button[@name="answer_question_submit"]
  Wait Until Page Contains Element  xpath=//div[contains(@class,'alert-success')]  30

###############################################################################################################
###################################    ВІДОБРАЖЕННЯ ІНФОРМАЦІЇ    #############################################
###############################################################################################################

Отримати інформацію із тендера
  [Arguments]  ${username}  ${tender_uaid}  ${field_name}
  ${red}=  Evaluate  "\\033[1;31m"
  Run Keyword If  'title' in '${field_name}'  Execute Javascript  $("[data-test-id|='title']").css("text-transform", "unset")
  ${value}=  Run Keyword If
  ...  'awards' in '${field_name}'  Отримати інформацію про авард  ${username}  ${tender_uaid}  ${field_name}
  ...  ELSE IF  'status' in '${field_name}'  Отримати інформацію про статус  ${field_name}
  ...  ELSE IF  '${field_name}' == 'auctionPeriod.startDate'  Get Text  xpath=//*[@data-test-id="auctionPeriod.startDate"]
  ...  ELSE IF  '${field_name}' == 'tenderAttempts'  Get Element Attribute  xpath=//*[@data-test-id="tenderAttempts"]@data-test-value
  ...  ELSE IF  'cancellations' in '${field_name}'  Get Text  xpath=//*[@data-test-id="${field_name.replace('[0]','')}"]
  ...  ELSE IF  '${field_name}' == 'guarantee.amount'  Get Text  xpath=//*[@data-test-id="guarantee"]
  ...  ELSE  Get Text  xpath=//*[@data-test-id="${field_name.replace('auction', 'tender')}"]
  ${value}=  adapt_view_data  ${value}  ${field_name}
  [return]  ${value}

Отримати інформацію про статус
  [Arguments]  ${field_name}
  Run Keyword And Ignore Error  Click Element   xpath=//a[text()='Інформація про аукціон']
  Reload Page
  ${value}=  Run Keyword If  'cancellations' in '${field_name}'
  ...  Get Element Attribute  //*[contains(text(), "Причина скасування")]@data-test-id-cancellation-status
  ...  ELSE  Get Text  xpath=//*[@data-test-id="${field_name.split('.')[-1]}"]
  [return]  ${value.lower()}

Отримати інформацію із предмету
  [Arguments]  ${username}  ${tender_uaid}  ${item_id}  ${field_name}
  ${red}=  Evaluate  "\\033[1;31m"
  ${field_name}=  Set Variable If  '[' in '${field_name}'  ${field_name.split('[')[0]}${field_name.split(']')[1]}  ${field_name}
  ${value}=  Run Keyword If
  ...  'unit.code' in '${field_name}'  Log To Console   ${red}\n\t\t\t Це поле не виводиться на centrex
  ...  ELSE IF  'deliveryLocation' in '${field_name}'  Log To Console  ${red}\n\t\t\t Це поле не виводиться на centrex
  ...  ELSE IF  '${field_name}' == 'additionalClassifications.description'  Get Text  xpath=//*[contains(text(), '${item_id}')]/ancestor::div[contains(@class,"item-inf_txt")]/descendant::*[text()="PA01-7"]/following-sibling::span
  ...  ELSE IF  '${field_name}' == 'contractPeriod.startDate'  Get Text  xpath=//*[contains(text(), '${item_id}')]/ancestor::div[contains(@class,"item-inf_txt")]/descendant::*[contains(text(),"Дата початку договору оренди")]/following-sibling::div
  ...  ELSE IF  '${field_name}' == 'contractPeriod.endDate'  Get Text  xpath=//*[contains(text(), '${item_id}')]/ancestor::div[contains(@class,"item-inf_txt")]/descendant::*[contains(text(),"Дата кiнця договору оренди")]/following-sibling::div
  ...  ELSE  Get Text  xpath=//*[contains(text(), '${item_id}')]/ancestor::div[contains(@class,"item-inf_txt")]/descendant::*[@data-test-id='item.${field_name}']
  ${value}=  adapt_view_item_data  ${value}  ${field_name}
  [return]  ${value}
>>>>>>> .merge_file_a20448

Завантажити фінансову ліцензію
    [Arguments]  ${username}  ${tender_uaid}  ${file_path}
    centrex.Пошук Тендера По Ідентифікатору  ${username}  ${tender_uaid}
    Scroll To  xpath=(//*[@action="/tender/fileupload"]/input)[last()]
    Choose File  xpath=(//*[@action="/tender/fileupload"]/input)[last()]  ${file_path}
    Wait Until Element Is Visible  xpath=(//input[@class="file_name"])[last()]
    Input Text  xpath=(//input[@class="file_name"])[last()]  ${file_path.split('/')[-1]}
    Select From List By Value  xpath=(//select[@class="select_document_type"])[last()]  financialLicense
    Click Element  //button[@id="submit_bid"]
    Wait Until Keyword Succeeds  10 x  1 s  Element Should Be Visible  xpath=//div[contains(@class,'alert-success')]


Змінити цінову пропозицію
    [Arguments]  ${username}  ${tender_uaid}  ${field}  ${value}
    centrex.Пошук Тендера По Ідентифікатору  ${username}  ${tender_uaid}
    Wait Until Element Is Visible  //input[@id="value-amount"]
    Convert Input Data To String  xpath=//input[@id="value-amount"]  ${value}
    Click Element  //button[@id="submit_bid"]
    Page Should Contain Element  //*[contains(@class, "label-success")][contains(text(), "опубліковано")]


Скасувати цінову пропозицію
    [Arguments]  ${username}  ${tender_uaid}
    centrex.Пошук Тендера По Ідентифікатору  ${username}  ${tender_uaid}
    Scroll To And Click Element  //button[@name="delete_bids"]
    Wait Until Element Is Visible  //*[@class="bootbox-body"][contains(text(), "Видалити ставку?")]
    Click Element  //button[contains(text(), "Видалити") and not(contains(@name,"delete_bids"))]
    Wait Until Element Is Not Visible  //*[@class="bootbox-body"][contains(text(), "Видалити ставку?")]


Proposition
    [Arguments]  ${username}  ${status}
    ${url}=  Get Location
    Run Keyword If  ${status.qualified}
    ...  Go To  ${USERS.users['${username}'].homepage}/bids/send/${url.split('/')[-1]}?token=465
    ...  ELSE  Go To  ${USERS.users['${username}'].homepage}/bids/decline/${url.split('/')[-1]}?token=465
    Go To  ${USERS.users['${username}'].homepage}


Завантажити документ в ставку
    [Arguments]  ${username}  ${file_path}  ${tender_uaid}
    centrex.Пошук Тендера По Ідентифікатору  ${username}  ${tender_uaid}
    Scroll To  //*[@action="/tender/fileupload"]/input
    Choose File  xpath=//*[@action="/tender/fileupload"]/input  ${file_path}
    Input Text  xpath=(//input[@class="file_name"])[last()]  ${file_path.split('/')[-1]}
    Select From List By Value  xpath=(//select[@class="select_document_type"])[last()]  qualificationDocuments
    Click Element  //button[@id="submit_bid"]
    Wait Until Keyword Succeeds  10 x  1 s  Element Should Be Visible  xpath=//div[contains(@class,'alert-success')]


Змінити документ в ставці
    [Arguments]  ${username}  ${tender_uaid}  ${file_path}  ${docid}
    centrex.Пошук Тендера По Ідентифікатору  ${username}  ${tender_uaid}
    Scroll  //*[@action="/tender/fileupload"]/input
    Choose File  xpath=(//input[@name="FileUpload[file]"])[last()]  ${file_path}


Отримати інформацію із пропозиції
<<<<<<< .merge_file_a18660
    [Arguments]  ${username}  ${tender_uaid}  ${field}
    centrex.Пошук Тендера По Ідентифікатору  ${username}  ${tender_uaid}
    Scroll  xpath=//input[@id="value-amount"]
    ${value}=  Get Value  xpath=//input[@id="value-amount"]
    ${value}=  adapt_data  ${field}  ${value}
    [Return]  ${value}
=======
  [Arguments]  ${username}  ${tender_uaid}  ${field}
  ${bid_value}=   Get Value   id=value-amount
  ${bid_value}=   Convert To Number   ${bid_value}
  [return]  ${bid_value}
>>>>>>> .merge_file_a20448


Пошук тендера по ідентифікатору
    [Arguments]  ${username}  ${tender_uaid}
    Switch Browser  ${my_alias}
    Go To  ${USERS.users['${username}'].homepage}
    Sleep  3
    Закрити Модалку
    Scroll To And Click Element  xpath=//li[@class="dropdown"]/descendant::*[@class="dropdown-toggle"][contains(@href, "tenders")]
    Click Element  xpath=//*[@class="dropdown-menu"]/descendant::*[contains(@href, "/tenders/index")]
    Wait Until Element Is Visible  xpath=//button[contains(text(), "Шукати")]
    Закрити Модалку
    Click Element  xpath=//*[starts-with(@id,"more-filter")]
    Wait Until Element Is Visible  xpath=//*[starts-with(@id,"tenderssearch-tender_cbd_id")]
    Input Text  xpath=//*[starts-with(@id,"tenderssearch-tender_cbd_id")]  ${tender_uaid}
    Click Element  xpath=//button[@data-test-id="search"]
    # Waiting Element
    Wait Until Keyword Succeeds  30 x  1 s  Run Keywords
    ...  Click Element  xpath=//button[@data-test-id="search"]
    ...  AND  Wait Until Element Is Visible  xpath=//div[@class="search-result"]/descendant::div[contains(text(), "${tender_uaid}")]
    Run Keyword And Ignore Error  Wait Until Keyword Succeeds  20 x  1 s  Run Keywords
    ...  Click Element  xpath=//div[@class="search-result"]/descendant::div[contains(text(), "${tender_uaid}")]/../following-sibling::div/a
    ...  AND  Wait Until Element Is Not Visible  xpath=//button[contains(text(), "Шукати")]  20
    Закрити Модалку
    Wait Until Element Is Visible  xpath=//div[@data-test-id="tenderID"]  20
    Синхронізуватися із ЦБД


Отримати інформацію із тендера
    [Arguments]  ${username}  ${tender_uaid}  ${field}
    Switch Browser  ${my_alias}
    Синхронізуватися із ЦБД
    Run Keyword If  'title' in '${field}'  Execute Javascript  $("[data-test-id|='title']").css("text-transform", "unset")
    ${value}=  Run Keyword If
    ...  '${field}' == 'title'  Get Text  xpath=//*[@data-test-id="title"]
    ...  ELSE IF  'procurementMethodType' in '${field}'  Get Text  xpath=//div[@class='item-inf_ad']
    ...  ELSE IF  'awards' in '${field}'  Статус Аварду  ${username}  ${tender_uaid}  ${field}
    ...  ELSE IF  'status' == '${field}'  Отримати Статус  ${field}
    ...  ELSE IF  'cancellations' in '${field}' and 'status' in '${field}'  Get Element Attribute  xpath=//div[@data-test-id-cancellation-status]@data-test-id-cancellation-status
    ...  ELSE IF  'cancellations' in '${field}' and 'reason' in '${field}'  Get Text  xpath=//*[@data-test-id='${field.replace('[0]', '')}']
    ...  ELSE IF  'dutchSteps' in '${field}'  Get Text  xpath=//*[@data-test-id='tenderParameters.dutchSteps']
    ...  ELSE IF  '${field}' == 'description'  Get Text  xpath=//*[@data-test-id="description"]
    ...  ELSE IF  'tenderAttempts' in '${field}'  Get Element Attribute  xpath=//*[@data-test-id="tenderAttempts"]@data-test-value
    ...  ELSE IF  '${field}' == 'guarantee.amount'  Get Text  xpath=//*[@data-test-id="guarantee"]
    ...  ELSE IF  '${field}' == 'auctionPeriod.startDate'  Get Text  xpath=//div[@data-test-id="auctionPeriod.startDate"]
    ...  ELSE IF  'contracts' in '${field}'  Отримати інформацію з контракту  ${username}  ${tender_uaid}  ${field}
    ...  ELSE  Get Text  xpath=//*[@data-test-id='${field.replace('auction', 'tender')}']
    ${value}=  adapt_data  ${field}  ${value}
    [Return]  ${value}


Отримати інформацію з контракту
    [Arguments]  ${username}  ${tender_uaid}  ${field}
    centrex.Пошук Тендера По Ідентифікатору  ${username}  ${tender_uaid}
    centrex.Перейти на сторінку кваліфікації
    Click Element  xpath=//button[@class="mk-btn mk-btn_default"][contains(text(), 'Договір')]
    Wait Until Element Is Visible  xpath=//div[contains(text(),"Дата пiдписання договору")]
    ${value}=  Run Keyword If
    ...  'datePaid' in '${field}'  Get Text  xpath=//div[contains(text(),"Дата сплати")]/following-sibling::div[1]
    ...  ELSE IF  'status' in '${field}'  Get Text  xpath=//div[contains(text(),"Статус договору")]/following-sibling::div[1]
    [Return]  ${value}


Отримати інформацію із предмету
    [Arguments]  ${username}  ${tender_uaid}  ${object_id}  ${field}
    ${red}=  Evaluate  "\\033[1;31m"
    ${field}=  Set Variable If  '[' in '${field}'  ${field.split('[')[0]}${field.split(']')[1]}  ${field}
    ${value}=  Run Keyword If
    ...  '${field}' == 'classification.scheme'  Get Text  //*[contains(text(),'${object_id}')]/ancestor::div[2]/descendant::div[@data-test-id="item.classification.scheme"]
    ...  ELSE IF  '${field}' == 'unit.code'  Log To Console  ${red}\n\t\t\t Це поле не виводиться на centrex
    ...  ELSE IF  '${field}' == 'additionalClassifications.description'  Get Text  xpath=//*[contains(text(),'${object_id}')]/ancestor::div[2]/descendant::*[text()='PA01-7']/following-sibling::span
    ...  ELSE IF  '${field}' == 'contractPeriod.startDate'  Get Text  //*[contains(text(),'${object_id}')]/ancestor::div[2]/descendant::*[contains(text(), 'Дата початку договору оренди')]/following-sibling::*
    ...  ELSE IF  '${field}' == 'contractPeriod.endDate'  Get Text  //*[contains(text(),'${object_id}')]/ancestor::div[2]/descendant::*[contains(text(), 'Дата кiнця договору оренди')]/following-sibling::*
    ...  ELSE  Get Text  //div[contains(text(),'${object_id}')]/ancestor::div[contains(@class, "item-inf_txt")]/descendant::*[@data-test-id="item.${field}"]
    ${value}=  adapt_data  ${field}  ${value}
    [Return]  ${value}


Отримати кількість документів в тендері
    [Arguments]  ${username}  ${tender_uaid}
    centrex.Пошук Тендера По Ідентифікатору  ${username}  ${tender_uaid}
    ${documents}=  Get Matching Xpath Count  xpath=//div[@class="item-inf_t"][contains(text(), "Документи")]/../descendant::div[@data-test-id="document.title"]
    ${n_documents}=  Convert To Integer  ${documents}
    [Return]  ${n_documents}


<<<<<<< .merge_file_a18660
Отримати кількість предметів в тендері
    [Arguments]  ${username}  ${tender_uaid}
    ${items}=  Get Matching Xpath Count  xpath=//div[@data-test-id="item.description"]
    ${n_items}=  Convert To Integer  ${items}
    [Return]  ${n_items}


Отримати інформацію із документа
    [Arguments]  ${username}  ${tender_uaid}  ${doc_id}  ${field}
    ${value}=  Get Text  //a[contains(text(), '${doc_id}')]
    [Return]  ${value}
=======
Подати цінову пропозицію
  [Arguments]  ${username}  ${tender_uaid}  ${bid}
  ${status}=  Get From Dictionary  ${bid['data']}  qualified
  Switch Browser  ${my_alias}
  centrex.Пошук тендера по ідентифікатору   ${username}  ${tender_uaid}
  Run Keyword And Ignore Error  centrex.Скасувати цінову пропозицію  ${username}  ${tender_uaid}
  ConvToStr And Input Text  xpath=//input[contains(@name, '[value][amount]')]  ${bid.data.value.amount}
  Scroll To Element  xpath=//label[@for="rules_accept"]
  Click Element  xpath=//label[@for="rules_accept"]
  Click Element  xpath=//button[contains(text(), 'Відправити')]
  Toggle Sidebar
  Wait Until Page Contains Element  xpath=//div[contains(@class,'alert-success')]
  Run Keyword If  '${MODE}' != 'dgfInsider'  Опублікувати Пропозицію  ${status}

Опублікувати Пропозицію
  [Arguments]  ${status}
  ${url}=  Log Location
  Run Keyword If  ${status}
  ...  Go To  http://centrex.byustudio.in.ua/bids/send/${url.split('?')[0].split('/')[-1]}?token=465
  ...  ELSE  Go To  http://centrex.byustudio.in.ua/bids/decline/${url.split('?')[0].split('/')[-1]}?token=465
  Go To  ${url}
  Wait Until Keyword Succeeds  6 x  30 s  Run Keywords
  ...  Reload Page
  ...  AND  Page Should Contain  опубліковано

Скасувати цінову пропозицію
  [Arguments]  ${username}  ${tender_uaid}
  centrex.Пошук тендера по ідентифікатору   ${username}  ${tender_uaid}
  Click Element  xpath=//button[@name="delete_bids"]
  Wait Until Element Is Visible  xpath=//button[@data-bb-handler="confirm"]
  Click Element  xpath=//button[@data-bb-handler="confirm"]
  Wait Until Keyword Succeeds  10 x  1 s  Element Should Be Visible  xpath=//input[contains(@name, '[value][amount]')]

Змінити цінову пропозицію
  [Arguments]  ${username}  ${tender_uaid}  ${fieldname}  ${fieldvalue}
  centrex.Пошук тендера по ідентифікатору   ${username}  ${tender_uaid}
  centrex.Скасувати цінову пропозицію  ${username}  ${tender_uaid}
  Wait Until Keyword Succeeds  20 x  400 ms  Run Keywords
  ...  Element Should Be Visible  xpath=//input[contains(@name, '[value][amount]')]
  ...  AND  ConvToStr And Input Text  xpath=//input[contains(@name, '[value][amount]')]  ${fieldvalue}
  Scroll To Element  xpath=//label[@for="rules_accept"]
  Click Element  xpath=//label[@for="rules_accept"]
  Click Element  xpath=//button[contains(text(), 'Відправити')]
  Toggle Sidebar
  Wait Until Keyword Succeeds  10 x  1 s  Element Should Be Visible  xpath=//div[contains(@class,'alert-success')]
  Опублікувати Пропозицію  ${True}
>>>>>>> .merge_file_a20448


Отримати інформацію із документа по індексу
    [Arguments]  ${username}  ${tender_uaid}  ${document_index}  ${field}
    ${value}=  Get Text  xpath=(//*[@data-test-id="documentType"])[${document_index + 1}]
    ${value}=  adapted_dictionary  ${value}
    [Return]  ${value}


Отримати документ
    [Arguments]  ${username}  ${TENDER['TENDER_UAID']}  ${doc_id}
    ${file_name}=  Get Text  xpath=//*[@data-test-id='document.title']/a[contains(text(), '${doc_id}')]
    ${url}=  Get Element Attribute  xpath=//a[contains(text(), '${doc_id}')]@href
    download_file  ${url}  ${file_name}  ${OUTPUT_DIR}
    [Return]  ${file_name}

<<<<<<< .merge_file_a18660
=======
Отримати посилання на аукціон для глядача
  [Arguments]  ${username}  ${tender_uaid}  ${lot_id}=${Empty}
  Switch Browser  ${my_alias}
  centrex.Пошук тендера по ідентифікатору   ${username}  ${tender_uaid}
  ${auction_url}  Get Element Attribute  xpath=(//a[contains(@href, "openprocurement.auction/")])[1]@href
  [return]  ${auction_url}
>>>>>>> .merge_file_a20448

Отримати інформацію із запитання
    [Arguments]  ${username}  ${tender_uaid}  ${object_id}  ${field}
    centrex.Пошук Тендера По Ідентифікатору  ${username}  ${tender_uaid}
    Click Element  xpath=//*[@data-test-id="sidebar.questions"]
    Wait Until Element Is Not Visible  xpath=//*[@data-test-id="sidebar.questions"]
    centrex.Закрити Модалку
    ${value}=  Get Text  //*[contains(text(), '${object_id}')]/../descendant::*[@data-test-id='question.${field}']
    [Return]  ${value}


Отримати посилання на аукціон для глядача
    [Arguments]  ${viewer}  ${tender_uaid}  ${lot_id}=${Empty}
    Switch Browser  ${my_alias}
    centrex.Пошук Тендера По Ідентифікатору  ${viewer}  ${tender_uaid}
    ${link}=  Get Element Attribute  xpath=//*[contains(text(), "Посилання")]/../descendant::*[@class="h4"]/a@href
    [Return]  ${link}


Отримати посилання на аукціон для учасника
    [Arguments]  ${username}  ${tender_uaid}  ${lot_id}=${Empty}
    Switch Browser  ${my_alias}
    centrex.Пошук Тендера По Ідентифікатору  ${username}  ${tender_uaid}
    Reload Page
    Wait Until Element Is Visible  //a[@class="auction_seller_url"]
    ${current_url}=  Get Location
    Capture Page Screenshot
    Execute Javascript  window['url'] = null; $.get( "${USERS.users['${username}'].homepage}/seller/tender/updatebid", { id: "${current_url.split("/")[-1]}"}, function(data){ window['url'] = data.data.participationUrl },'json');
    Capture Page Screenshot
    Wait Until Keyword Succeeds  20 x  1 s  JQuery Ajax Should Complete
    Capture Page Screenshot
    ${link}=  Execute Javascript  return window['url'];
    Capture Page Screenshot
    [Return]  ${link}


Статус Аварду
    [Arguments]  ${username}  ${tender_uaid}  ${field}
    Wait Until Keyword Succeeds  30 x  20 s  Run Keywords
    ...  centrex.Пошук Тендера По Ідентифікатору  ${username}  ${tender_uaid}
    ...  AND  Run Keyword And Ignore Error  Click Element  xpath=//*[contains(text(), "Таблиця квалiфiкацiї")]
    ...  AND  Run Keyword And Ignore Error  Click Element  xpath=//*[contains(text(), "Протокол розкриття пропозицiй")]
    ...  AND  Page Should Contain  Квалiфiкацiя учасникiв
    Page Should Not Contain Element  xpath=//*[contains(text(), "Таблиця квалiфiкацiї")]
    ${award}=  Convert To Integer  ${field[7:8]}
    ${status}=  Get Text  xpath=(//div[@data-mtitle="Статус:"])[${award + 1}]
    [Return]  ${status}

<<<<<<< .merge_file_a18660

Завантажити протокол аукціону
    [Arguments]  ${username}  ${tender_uaid}  ${file_path}  ${award_index}
    centrex.Перейти на сторінку кваліфікації
    Wait Until Element Is Visible  //button[contains(text(), "Завантаження протоколу")]
    Click Element  xpath=//button[contains(text(), "Завантаження протоколу")]
    Wait Until Element Is Visible  //div[contains(text(), "Завантаження протоколу")]
    Choose File  //div[@id="verification-form-upload-file"]/descendant::input[@name="FileUpload[file][]"]  ${file_path}
    Wait Until Element Is Visible  //button[contains(@class, "delete-file-verification")]
    Click Element  //button[contains(text(), "Завантажити протокол")]
    Wait Until Element Is Not Visible  //button[contains(text(), "Завантажити протокол")]
    Wait Until Keyword Succeeds  30 x  20 s  Run Keywords
    ...  Синхронізуватися із ЦБД
    ...  AND  Page Should Not Contain Element  //button[@onclick="window.location.reload();"]

=======
Підтвердити постачальника
  [Arguments]  ${username}  ${tender_uaid}  ${award_num}
  centrex.Пошук тендера по ідентифікатору   ${username}  ${tender_uaid}
  Wait Until Keyword Succeeds   30 x   30 s  Run Keywords
  ...  Reload Page
  ...  AND  Click Element  xpath=//a[text()='Таблиця квалiфiкацiї']
  Wait Until Element Is Visible  xpath=//button[text()='Підтвердити отримання оплати']
  Click Element  xpath=//button[text()='Підтвердити отримання оплати']
  Wait Until Keyword Succeeds  10 x  1 s  Element Should Be Visible  xpath=//button[@data-bb-handler="confirm"]
  Click Element  xpath=//button[@data-bb-handler="confirm"]
  Wait Until Element Is Visible   xpath=//button[text()="Контракт"]

Отримати кількість документів в ставці
  [Arguments]  ${username}  ${tender_uaid}  ${bid_index}
  centrex.Пошук тендера по ідентифікатору   ${username}  ${tender_uaid}
  Wait Until Element Is Visible  xpath=//a[text()='Таблиця квалiфiкацiї']
  Click Element  xpath=//a[text()='Таблиця квалiфiкацiї']
  ${disqualification_status}=  Run Keyword And Return Status  Wait Until Page Does Not Contain Element  xpath=//*[contains(text(),'Дисквалiфiковано')]  10
  Run Keyword If  ${disqualification_status}  Wait Until Keyword Succeeds  15 x  1 m  Run Keywords
  ...    Reload Page
  ...    AND  Wait Until Page Contains  auctionProtocol
  ...  ELSE  Wait Until Keyword Succeeds  15 x  1 m  Run Keywords
  ...    Reload Page
  ...    AND  Xpath Should Match X Times  //*[contains(text(),'auctionProtocol')]  2
  ${bid_doc_number}=   Get Matching Xpath Count   //td[contains(text(),'На розглядi ')]/../following-sibling::tr[2]/descendant::div[@class="bid_document_block"]/table/tbody/tr
  [return]  ${bid_doc_number}

Отримати дані із документу пропозиції
  [Arguments]  ${username}  ${tender_uaid}  ${bid_index}  ${document_index}  ${field}
  ${doc_value}=  Get Text  xpath=//div[@class="bid_document_block"]/table/tbody/tr[${document_index + 1}]/td[2]/span
  [return]  ${doc_value}

Завантажити протокол аукціону
  [Arguments]  ${username}  ${tender_uaid}  ${filepath}  ${award_index}
  Перейти на сторінку кваліфікації учасників  ${username}  ${tender_uaid}
  Choose File  name=FileUpload[file]  ${filepath}
  Wait Until Element Is Visible  xpath=//*[contains(@name,'[documentType]')]
  Select From List By Value  xpath=(//*[contains(@name,'[documentType]')])[last()]  auctionProtocol
  Click Element  id=submit_winner_files
  Wait Until Element Is Visible  xpath=//div[contains(@class,'alert-success')]
  Wait Until Keyword Succeeds  15 x  1 m  Дочекатися завантаження файлу  ${filepath.split('/')[-1]}

Завантажити протокол аукціону в авард
  [Arguments]  ${username}  ${tender_uaid}  ${filepath}  ${award_index}
  Run Keyword If  """Відображення статусу 'оплачено, очікується підписання договору'""" not in """${PREV TEST NAME}"""
  ...  Wait Until Keyword Succeeds  10 x  60 s  Звірити статус тендера  ${username}  ${tender_uaid}  active.qualification
  Перейти на сторінку кваліфікації учасників  ${username}  ${tender_uaid}
  Click Element  xpath=//*[contains(@id,"modal-verification")]
  Choose File  xpath=//*[@id="verification-form-upload-file"]/descendant::input[@type="file"]  ${filepath}
  Click Element  name=protokol_ok
  Wait Until Element Is Visible  xpath=//div[contains(@class,'alert-success')]
  Wait Until Keyword Succeeds  10 x  30 s  Run Keywords
  ...  Reload Page
  ...  AND  Element Should Not Be Visible  xpath=//button[@onclick="window.location.reload();"]
>>>>>>> .merge_file_a20448

Підтвердити наявність протоколу аукціону
    [Arguments]  ${username}  ${tender_uaid}  ${award_number}
    centrex.Перейти на сторінку кваліфікації
    Wait Until Page Contains  Очікується підписання договору


Підтвердити постачальника
    [Arguments]  ${username}  ${tender_uaid}  ${number}
    centrex.Перейти на сторінку кваліфікації
    Синхронізуватися із ЦБД
    Page Should Contain Element  xpath=//button[contains(text(), "Договір")]
    Log  Необхідні дії було виконано у "Завантажити протокол аукціону в авард"


Скасування рішення кваліфікаційної комісії
    [Arguments]  ${username}  ${tender_uaid}  ${number}
    centrex.Пошук Тендера По Ідентифікатору  ${username}  ${tender_uaid}
    centrex.Перейти на сторінку кваліфікації
    Wait Until Element Is Visible  //button[contains(text(), "Відмовитись від очікування")]
    Click Element  //button[contains(text(), "Відмовитись від очікування")]
    Wait Until Element Is Visible  //div[contains(text(), "Подальшу участь буде скасовано")]
    Click Element  //*[@class="modal-footer"]/button[contains(text(), "Застосувати")]
    Wait Until Element Is Not Visible  //*[@class="modal-footer"]/button[contains(text(), "Застосувати")]
    Wait Until Keyword Succeeds  30 x  20 s  Run Keywords
    ...  Синхронізуватися із ЦБД
    ...  AND  Wait Until Page Contains  Відмова від очікування

<<<<<<< .merge_file_a18660

Завантажити угоду до тендера
    [Arguments]  ${username}  ${tender_uaid}  ${number}  ${file_path}
    centrex.Пошук Тендера По Ідентифікатору  ${username}  ${tender_uaid}
    centrex.Перейти на сторінку кваліфікації
    Wait Until Element Is Visible  xpath=//button[contains(text(), "Договір")]
    Click Element  xpath=//button[contains(text(), "Договір")]
    Wait Until Element Is Visible  //div[contains(@class, "h2")][contains(text(), "Договір")]
    Choose File  //div[@id="uploadcontract"]/descendant::input  ${file_path}
    Wait Until Element Is Visible  xpath=//select[@name='documents[0][documentType]']
    Select From List By Value  xpath=//select[@name='documents[0][documentType]']  contractSigned
    Input Text  //input[@id="contract-contractnumber"]  1234567890
    Click Element  //button[@id="contract-fill-data"]
    Wait Until Element Is Not Visible  //button[@id="contract-fill-data"]
    Wait Until Keyword Succeeds  30 x  20 s  Run Keywords
    ...  Синхронізуватися із ЦБД
    ...  AND  Page Should Contain Element  xpath=//input[@id="contract-activate"]


Вказати дату отримання оплати
    [Arguments]  ${username}  ${tender_uaid}  ${contract_number}  ${datePaid}
    centrex.Перейти на сторінку кваліфікації
    Click Element  xpath=//button[contains(text(), "Договір")]
    Wait Until Element Is Visible  //div[contains(@class, "h2")][contains(text(), "Договір")]
    ${file}=  my_file_path
    Choose File  //div[@id="uploadcontract"]/descendant::input  ${file}
    ${paid_date}=  convert_date_for_datePaid  ${datePaid}
    Input Text  xpath=//input[@name="Contract[datePaid]"]  ${paid_date}
    Input text  xpath=//input[@name='Contract[dateSigned]']  ${paid_date}
    Input Text  //input[@id="contract-contractnumber"]  1234567890
    Click Element  //button[@id="contract-fill-data"]
    Wait Until Element Is Visible  xpath=//*[@class="text-success"]
    Wait Until Keyword Succeeds  30 x  20 s  Run Keywords
    ...  Синхронізуватися із ЦБД
    ...  AND  Page Should Not Contain Element  xpath=//*[@class="text-success"]


Підтвердити підписання контракту
    [Arguments]  ${username}  ${tender_uaid}  ${number}
    centrex.Перейти на сторінку кваліфікації
    Click Element  xpath=//input[@id="contract-activate"]
    Wait Until Element Is Visible  xpath=//button[@data-bb-handler="confirm"]
    Click Element  xpath=//button[@data-bb-handler="confirm"]
    Wait Until Keyword Succeeds  30 x  20 s  Run Keywords
    ...  Синхронізуватися із ЦБД
    ...  AND  Page Should Contain Element  //div[@data-test-id="status"][contains(text(), "Аукціон завершено. Договір підписано")]


Дискваліфікувати постачальника
    [Arguments]  ${username}  ${tender_uaid}  ${number}  ${description}
    centrex.Перейти на сторінку кваліфікації
    Закрити Модалку
    ${file}=  my_file_path
    Wait Until Element Is Visible  xpath=//button[@data-toggle="modal"][contains(text(), "Дисквалiфiкувати")]
    Click Element  //button[@data-toggle="modal"][contains(text(), "Дисквалiфiкувати")]
    Wait Until Element Is Visible  //div[contains(@class, "h2")][contains(text(), "Дискваліфікація")]
    Wait Until Element Is Visible  xpath=(//*[@name="Award[cause][]"])[1]/..
    Click Element  xpath=(//*[@name="Award[cause][]"])[1]/..
    Choose File  //div[@id="disqualification-form-upload-file"]/descendant::input[@name="FileUpload[file][]"]  ${file}
    Input Text  //textarea[@id="award-description"]  ${description}
    Wait Until Keyword Succeeds  10 x  2 s  Run Keywords
    ...  Click Element  //button[@id="disqualification"]
    ...  AND  Wait Until Keyword Succeeds  10 x  1 s  Element Should Be Visible  xpath=//div[contains(@class,'alert-success')]
    Wait Until Keyword Succeeds  30 x  20 s  Run Keywords
    ...  Reload Page
    ...  AND  Page Should Not Contain Element  xpath=//button[@onclick="window.location.reload();"]


Scroll
    [Arguments]  ${locator}
    Execute JavaScript    window.scrollTo(0,0)


Scroll To
    [Arguments]  ${locator}
    ${y}=  Get Vertical Position  ${locator}
    Execute JavaScript    window.scrollTo(0,${y-100})


Scroll To And Click Element
    [Arguments]  ${locator}
    ${y}=  Get Vertical Position  ${locator}
    Execute JavaScript    window.scrollTo(0,${y-100})
    Click Element  ${locator}


Отримати Статус
    [Arguments]  ${field}
    Синхронізуватися із ЦБД
    ${status}=  Run Keyword If
    ...  'cancellations' in '${field}'  Get Element Attribute  //*[contains(text(), "Причина скасування")]@data-test-id-cancellation-status
    ...  ELSE  Get Text  xpath=//*[@data-test-id="status"]
    ${status}=  adapt_data  ${field}  ${status}
    [Return]  ${status}


Закрити Модалку
    ${status}=  Run Keyword And Return Status  Wait Until Element Is Visible  xpath=//button[@data-dismiss="modal"]  5
    Run Keyword If  ${status}  Run Keyword And Ignore Error  Wait Until Keyword Succeeds  5 x  1 s  Run Keywords
    ...  Click Element  xpath=//button[@data-dismiss="modal"]
    ...  AND  Wait Until Element Is Not Visible  xpath=//*[contains(@class, "modal-backdrop")]


Adapt And Select By Value
    [Arguments]  ${locator}  ${value}
    ${value}=  Convert To String  ${value}
    ${value}=  adapted_dictionary  ${value}
    Select From List By Value  ${locator}  ${value}


Convert Input Data To String
    [Arguments]  ${locator}  ${value}
    ${value}=  Convert To String  ${value}
    Input Text  ${locator}  ${value}


Wait For Document Upload
    Wait Until Keyword Succeeds  30 x  20 s  Run Keywords
    ...  Синхронізуватися із ЦБД
    ...  AND  Run Keyword And Ignore Error  Click Element  xpath=//*[@data-test-id="sidebar.edit"]
    ...  AND  Wait Until Element Is Visible  xpath=//*[@id="auction-form"]


Change DGF Date
    [Arguments]  ${field_name}  ${field_value}
    ${dgf_date}=  dgf_decision_date_for_site  ${field_value}
    Input text  name=Tender[${field_name}]  ${dgf_date}


Change Attempts
    [Arguments]  ${value}
    ${value}=  Convert To String  ${value}
    Scroll To    xpath=//*[@id="tender-tenderattempts"]
    Select From List By Value    xpath=//*[@id="tender-tenderattempts"]  ${value}


Перейти на сторінку кваліфікації
    ${status_q}=  Run Keyword And Return Status  Page Should Contain Element  xpath=//a[contains(text(), "Таблиця квалiфiкацiї")]  3
    ${status_p}=  Run Keyword And Return Status  Page Should Contain Element  xpath=//a[contains(text(), "Протокол розкриття пропозицiй")]  2
    Run Keyword If  ${status_q}  Click Element  xpath=//a[contains(text(), "Таблиця квалiфiкацiї")]
    ...  ELSE IF  ${status_p}  Click Element  xpath=//a[contains(text(), "Протокол розкриття пропозицiй")]
    Закрити Модалку
    Sleep  4
    Wait Until Element Is Visible  xpath=//h1[contains(text(), "Квалiфiкацiя учасникiв")]

=======
Дискваліфікувати постачальника
  [Arguments]  ${username}  ${tender_uaid}  ${award_num}  ${description}
  ${document}=  get_upload_file_path
  Run Keyword If  """Відображення статусу 'оплачено, очікується підписання договору'""" not in """${PREV TEST NAME}"""
  ...  Wait Until Keyword Succeeds  10 x  60 s  Звірити статус тендера  ${username}  ${tender_uaid}  active.qualification
  Перейти на сторінку кваліфікації учасників  ${username}  ${tender_uaid}
  Click Element  xpath=//*[contains(@id, "modal-disqualification")]
  Дочекатися І Клікнути  xpath=(//input[@name="Award[cause][]"])[1]/..
  Choose File  xpath=//*[@id="disqualification-form-upload-file"]/descendant::input[@type="file"]  ${document}
  Click Element  id=disqualification
  Wait Until Keyword Succeeds  10 x  1 s  Element Should Be Visible  xpath=//div[contains(@class,'alert-success')]

Завантажити документ рішення кваліфікаційної комісії
  [Arguments]  ${username}  ${document}  ${tender_uaid}  ${award_num}
  Перейти на сторінку кваліфікації учасників  ${username}  ${tender_uaid}
  Choose File  name=FileUpload[file]  ${document}

Завантажити угоду до тендера
  [Arguments]  ${username}  ${tender_uaid}  ${contract_num}  ${filepath}
  Перейти на сторінку кваліфікації учасників   ${username}  ${tender_uaid}
  Click Element  xpath=//button[text()="Контракт"]
  Choose File  xpath=//*[@id="uploadcontract"]/descendant::input[@type="file"]  ${filepath}

Підтвердити підписання контракту
  [Arguments]  ${username}  ${tender_uaid}  ${contract_num}
  ${filepath}=  get_upload_file_path
  Перейти на сторінку кваліфікації учасників   ${username}  ${tender_uaid}
  Wait Until Keyword Succeeds  5 x  0.5 s  Click Element  xpath=//button[text()="Контракт"]
  Wait Until Element Is Visible  xpath=//*[text()="Додати документ"]
  Choose File  xpath=//*[@id="uploadcontract"]/descendant::input[@type="file"]  ${filepath}
  Wait Until Keyword Succeeds  10 x  1 s  Element Should Be Visible  xpath=//button[contains(@class, "delete_file")]
  Input Text  id=contract-contractnumber  777
  Click Element  id=contract-fill-data
  Wait Until Keyword Succeeds  10 x  1 s  Page Should Contain  Кнопка "Завершити електронні торги" з'явиться після закінчення завантаження даних та оновлення сторінки
  Wait Until Keyword Succeeds  10 x  60 s  Run Keywords
  ...  Reload Page
  ...  AND  Element Should Be Visible  id=contract-activate
  Choose Ok On Next Confirmation
  Click Element  id=contract-activate
  Confirm Action

###############################################################################################################

ConvToStr And Input Text
  [Arguments]  ${elem_locator}  ${smth_to_input}
  ${smth_to_input}=  Convert To String  ${smth_to_input}
  Input Text  ${elem_locator}  ${smth_to_input}

Conv And Select From List By Value
  [Arguments]  ${elem_locator}  ${smth_to_select}
  ${smth_to_select}=  Convert To String  ${smth_to_select}
  ${smth_to_select}=  convert_string_from_dict_centrex  ${smth_to_select}
  Select From List By Value  ${elem_locator}  ${smth_to_select}

Input Date
  [Arguments]  ${elem_locator}  ${date}
  ${date}=  convert_datetime_to_centrex_format  ${date}
  Input Text  ${elem_locator}  ${date}

Дочекатися завантаження файлу
  [Arguments]  ${doc_name}
  Reload Page
  Wait Until Page Contains  ${doc_name}  10

Перейти на сторінку кваліфікації учасників
  [Arguments]  ${username}  ${tender_uaid}
  centrex.Пошук тендера по ідентифікатору   ${username}  ${tender_uaid}
  Wait Until Element Is Visible  xpath=//a[text()='Таблиця квалiфiкацiї']
  Click Element  xpath=//a[text()='Таблиця квалiфiкацiї']

Дочекатися Анімації
  [Arguments]  ${locator}
  Set Test Variable  ${prev_vert_pos}  0
  Wait Until Keyword Succeeds  20 x  500 ms  Position Should Equals  ${locator}

Position Should Equals
  [Arguments]  ${locator}
  ${current_vert_pos}=  Get Vertical Position  ${locator}
  ${status}=  Run Keyword And Return Status  Should Be Equal  ${prev_vert_pos}  ${current_vert_pos}
  Set Test Variable  ${prev_vert_pos}  ${current_vert_pos}
  Should Be True  ${status}

Scroll To Element
  [Arguments]  ${locator}
  ${elem_vert_pos}=  Get Vertical Position  ${locator}
  Execute Javascript  window.scrollTo(0,${elem_vert_pos - 200});

Scroll And Click
  [Arguments]  ${locator}
  Scroll To Element  ${locator}
  Click Element  ${locator}

Scroll And Select From List By Value
  [Arguments]  ${locator}  ${value}
  Scroll To Element  ${locator}
  Select From List By Value  ${locator}  ${value}
>>>>>>> .merge_file_a20448

JQuery Ajax Should Complete
  ${active}=  Execute Javascript  return jQuery.active
  Should Be Equal  "${active}"  "0"

<<<<<<< .merge_file_a18660

Синхронізуватися із ЦБД
    ${url}=  Get Location
    Run Keyword If  'view' not in '${url}'  Click Element  xpath=//a[@data-test-id="sidebar.info"]
    Go To  ${url.replace('view', 'json').replace('award', 'json').replace('buyer/', '').replace('seller/', '')}
    Go To  ${url}
=======
Toggle Sidebar
  ${is_sidebar_visible}=  Run Keyword And Return Status  Element Should Be Visible  xpath=//div[contains(@class,"mk-slide-panel_body")]
  Run Keyword If  ${is_sidebar_visible}  Run Keywords
  ...  Wait Until Keyword Succeeds  5 x  1 s  Click Element  id=slidePanelToggle
  ...  AND  Дочекатися Анімації  xpath=//div[@class="title"]

Дочекатися і Клікнути
  [Arguments]  ${locator}
  Wait Until Element Is Visible  ${locator}
  Scroll To Element  ${locator}
  Click Element  ${locator}
>>>>>>> .merge_file_a20448
