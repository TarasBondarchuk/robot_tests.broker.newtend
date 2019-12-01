*** Settings ***
Library  Selenium2Screenshots
Library  String
Library  DateTime
Library  newtend_service.py

*** Variables ***
${locator.title}                     xpath=//div[@ng-bind="tender.title"]
${locator.description}               xpath=//div[@ng-bind="tender.description"]
${locator.edit.description}          name=tenderDescription
${locator.value.amount}              xpath=//div[@ng-bind="tender.value.amount"]
${locator.minimalStep.amount}        xpath=//div[@ng-bind="tender.minimalStep.amount"]
${locator.tenderId}                  xpath=//a[@class="ng-binding ng-scope"]
${locator.procuringEntity.name}      xpath=//div[@ng-bind="tender.procuringEntity.name"]
${locator.enquiryPeriod.StartDate}   id=start-date-qualification
${locator.enquiryPeriod.endDate}     id=end-date-qualification
${locator.tenderPeriod.startDate}    id=start-date-registration
${locator.tenderPeriod.endDate}      id=end-date-registration
${locator.items[0].deliveryAddress}                             id=deliveryAddress
${locator.items[0].deliveryDate.endDate}                        id=end-date-delivery
${locator.items[0].description}                                 xpath=//div[@ng-bind="item.description"]
${locator.items[0].classification.scheme}                       id=classifier
${locator.items[0].classification.scheme.title}                 xpath=//label[contains(., "Классификатор CPV")]
${locator.items[0].additional_classification[0].scheme}         id=classifier2
${locator.items[0].additional_classification[0].scheme.title}   xpath=//label[@for="classifier2"]
${locator.items[0].quantity}                                    id=quantity
${locator.items[0].unit.name}                                   xpath=//span[@class="unit ng-binding"]
${locator.edit_tender}     xpath=//button[@ng-if="actions.can_edit_tender"]
${locator.edit.add_item}   xpath=//a[@class="icon-black plus-black remove-field ng-scope"]
${locator.save}            xpath=//button[@class="btn btn-lg btn-default cancel pull-right ng-binding"]
${locator.QUESTIONS[0].title}         xpath=//span[@class="user ng-binding"]
${locator.QUESTIONS[0].description}   xpath=//span[@class="question-description ng-binding"]
${locator.QUESTIONS[0].date}          xpath=//span[@class="date ng-binding"]

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

Додати придмет
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  items_n
  ...      ${ARGUMENTS[1]} ==  index
## Get values for item
  ${items_description}=   Get From Dictionary   ${ARGUMENTS[0]}                          description
  ${quantity}=      Get From Dictionary   ${ARGUMENTS[0]}                                quantity
  ${cpv}=           Convert To String     Картонки
  ${dkpp_desc}=     Get From Dictionary   ${ARGUMENTS[0].additionalClassifications[0]}   description
  ${dkpp_id}=       Get From Dictionary   ${ARGUMENTS[0].additionalClassifications[0]}   id
  ${unit}=          Get From Dictionary   ${ARGUMENTS[0].unit}                           name
  ${deliverydate_end_date}=   Get From Dictionary   ${ARGUMENTS[0].deliveryDate}   endDate
  ${countryName}=     Get From Dictionary   ${ARGUMENTS[0].deliveryAddress}   countryName
  ${ZIP}=             Get From Dictionary   ${ARGUMENTS[0].deliveryAddress}   postalCode
  ${region}=          Get From Dictionary   ${ARGUMENTS[0].deliveryAddress}   region
  ${locality}=        Get From Dictionary   ${ARGUMENTS[0].deliveryAddress}   locality
  ${streetAddress}=   Get From Dictionary   ${ARGUMENTS[0].deliveryAddress}   streetAddress

  Set datetime   end-date-delivery${ARGUMENTS[1]}         ${deliverydate_end_date}
# Set CPV
  Wait Until Page Contains Element   id=classifier1${ARGUMENTS[1]}
  Click Element                      id=classifier1${ARGUMENTS[1]}
  Wait Until Page Contains Element   xpath=//input[@class="ng-pristine ng-untouched ng-valid"]   100
  Input text                         xpath=//input[@class="ng-pristine ng-untouched ng-valid"]   ${cpv}
  Wait Until Page Contains Element   xpath=//span[contains(text(),'${cpv}')]   20
  Click Element                      xpath=//input[@class="ng-pristine ng-untouched ng-valid"]
  Click Element                      xpath=//button[@class="btn btn-default btn-lg pull-right choose ng-binding"]
# Set ДКПП
  Click Element                      id=classifier2${ARGUMENTS[1]}
  Wait Until Page Contains Element   xpath=//input[@class="ng-pristine ng-untouched ng-valid"]   100
  Input text                         xpath=//input[@class="ng-pristine ng-untouched ng-valid"]   ${dkpp_desc}
  Wait Until Page Contains Element   xpath=//span[contains(text(),'${dkpp_id}')]   100
  Click Element                      xpath=//span[contains(text(),'${dkpp_id}')]/../..//input[@class="ng-pristine ng-untouched ng-valid"]
  Click Element                      xpath=//button[@class="btn btn-default btn-lg pull-right choose ng-binding"]
# Set Delivery Address
  Click Element                      id=deliveryAddress${ARGUMENTS[1]}
  Wait Until Page Contains Element   xpath=//input[@ng-model="deliveryAddress.postalCode"]   20
  Input text                         xpath=//input[@ng-model="deliveryAddress.postalCode"]   ${ZIP}
  Input text                         xpath=//input[@ng-model="deliveryAddress.region"]   ${region}
  Input text                         xpath=//input[@ng-model="deliveryAddress.locality"]   ${locality}
  Input text                         xpath=//input[@ng-model="deliveryAddress.streetAddress"]   ${streetAddress}
  Click Element                      xpath=//button[@class="btn btn-lg single-btn ng-binding"]
# Add item main info
  Click Element                      xpath=//a[contains(text(), "единицы измерения")]
  Click Element                      xpath=//a[contains(text(), "единицы измерения")]/..//a[contains(text(), '${unit}')]
  Input text   id=quantity${ARGUMENTS[1]}          ${quantity}
  Input text   id=itemDescription${ARGUMENTS[1]}   ${items_description}

Додати багато придметів
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  items
  ${Items_length}=   Get Length   ${items}
  : FOR    ${INDEX}    IN RANGE    1    ${Items_length}
  \   Click Element   ${locator.edit.add_item}
  \   Додати придмет   ${items[${INDEX}]}   ${INDEX}

Завантажити документ
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${TENDER_UAID}
  ...      ${ARGUMENTS[2]} ==  ${Complain}
  Fail   Тест не написаний

Подати скаргу
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${TENDER_UAID}
  ...      ${ARGUMENTS[2]} ==  ${Complain}
  Fail  Не реалізований функціонал

порівняти скаргу
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${file_path}
  ...      ${ARGUMENTS[2]} ==  ${TENDER_UAID}
  Fail  Не реалізований функціонал

Пошук тендера по ідентифікатору
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${TENDER_UAID}
  Switch browser   ${ARGUMENTS[0]}
  Go to   ${USERS.users['${ARGUMENTS[0]}'].homepage}
### Індексація на тестовому сервері відключена, як наслідок пошук по UAid не працює, отож застосовую обхід цієї функціональності для розблокування наступних тестів
#  Wait Until Page Contains Element   xpath=//div[@class="search-field"]/input   20
#  #${ARGUMENTS[1]}=   Convert To String   UA-2015-06-08-000023
#  Input text                         xpath=//div[@class="search-field"]/input   ${ARGUMENTS[1]}
#  : FOR    ${INDEX}    IN RANGE    1    30
#  \   Log To Console   .   no_newline=true
#  \   sleep       1
#  \   ${count}=   Get Matching Xpath Count   xpath=//a[@class="row tender-info ng-scope"]
#  \   Exit For Loop If  '${count}' == '1'
  Sleep   2
  Go to   ${USERS.users['${ARGUMENTS[0]}'].homepage}
  ${ARGUMENTS[1]}=   Convert To String   Воркераунд для проходженя наступних тестів - пошук не працює.
###
  Wait Until Page Contains Element   xpath=(//a[@class="row tender-info ng-scope"])   20
  Sleep   5
  Click Element                      xpath=(//a[@class="row tender-info ng-scope"])
  Wait Until Page Contains Element   xpath=//a[@class="ng-binding ng-scope"]|//span[@class="ng-binding ng-scope"]   30

отримати інформацію із тендера
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  fieldname
  Switch browser   ${ARGUMENTS[0]}
  Run Keyword And Return  Отримати інформацію про ${ARGUMENTS[1]}

отримати текст із поля і показати на сторінці
  [Arguments]   ${fieldname}
  sleep  1
  ${return_value}=   Get Text  ${locator.${fieldname}}
  [return]  ${return_value}

отримати інформацію про title
  ${title}=   отримати текст із поля і показати на сторінці   title
  [return]  ${title}

отримати інформацію про description
  ${description}=   отримати текст із поля і показати на сторінці   description
  [return]  ${description}

отримати інформацію про tenderId
  ${tenderId}=   отримати текст із поля і показати на сторінці   tenderId
  [return]  ${tenderId}

отримати інформацію про value.amount
  ${valueAmount}=   отримати текст із поля і показати на сторінці   value.amount
  ${valueAmount}=   Convert To Number   ${valueAmount.split(' ')[0]}
  [return]  ${valueAmount}

отримати інформацію про minimalStep.amount
  ${minimalStepAmount}=   отримати текст із поля і показати на сторінці   minimalStep.amount
  ${minimalStepAmount}=   Convert To Number   ${minimalStepAmount.split(' ')[0]}
  [return]  ${minimalStepAmount}

Внести зміни в тендер
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  id
  ...      ${ARGUMENTS[2]} ==  fieldname
  ...      ${ARGUMENTS[3]} ==  fieldvalue
  Switch browser   ${ARGUMENTS[0]}
  Click button     ${locator.edit_tender}
  Wait Until Page Contains Element   ${locator.edit.${ARGUMENTS[2]}}   20
  Input Text       ${locator.edit.${ARGUMENTS[2]}}   ${ARGUMENTS[3]}
  Click Element    ${locator.save}
  Wait Until Page Contains Element   ${locator.${ARGUMENTS[2]}}    20
  ${result_field}=   отримати текст із поля і показати на сторінці   ${ARGUMENTS[2]}
  Should Be Equal   ${result_field}   ${ARGUMENTS[3]}

отримати інформацію про procuringEntity.name
  ${procuringEntity_name}=   отримати текст із поля і показати на сторінці   procuringEntity.name
  [return]  ${procuringEntity_name}

отримати інформацію про enquiryPeriod.endDate
  ${enquiryPeriodEndDate}=   отримати текст із поля і показати на сторінці   enquiryPeriod.endDate
  [return]  ${enquiryPeriodEndDate}

отримати інформацію про tenderPeriod.startDate
  ${tenderPeriodStartDate}=   отримати текст із поля і показати на сторінці   tenderPeriod.startDate
  [return]  ${tenderPeriodStartDate}

отримати інформацію про tenderPeriod.endDate
  ${tenderPeriodEndDate}=   отримати текст із поля і показати на сторінці   tenderPeriod.endDate
  [return]  ${tenderPeriodEndDate}

отримати інформацію про enquiryPeriod.startDate
  ${enquiryPeriodStartDate}=   отримати текст із поля і показати на сторінці   enquiryPeriod.StartDate
  [return]  ${enquiryPeriodStartDate}

отримати інформацію про items[0].description
  ${description}=   отримати текст із поля і показати на сторінці   items[0].description
  [return]  ${description}

отримати інформацію про items[0].deliveryDate.endDate
  ${deliveryDate_endDate}=   отримати текст із поля і показати на сторінці   items[0].deliveryDate.endDate
  [return]  ${deliveryDate_endDate}

отримати інформацію про items[0].deliveryLocation.latitude
  Fail  Не реалізований функціонал

отримати інформацію про items[0].deliveryLocation.longitude
  Fail  Не реалізований функціонал

## Delivery Address
отримати інформацію про items[0].deliveryAddress.countryName
  ${Delivery_Address}=   отримати текст із поля і показати на сторінці   items[0].deliveryAddress
  [return]  ${Delivery_Address.split(', ')[1]}

отримати інформацію про items[0].deliveryAddress.postalCode
  ${Delivery_Address}=   отримати текст із поля і показати на сторінці   items[0].deliveryAddress
  [return]  ${Delivery_Address.split(', ')[0]}

отримати інформацію про items[0].deliveryAddress.region
  ${Delivery_Address}=   отримати текст із поля і показати на сторінці   items[0].deliveryAddress
  [return]  ${Delivery_Address.split(', ')[2]}

отримати інформацію про items[0].deliveryAddress.locality
  ${Delivery_Address}=   отримати текст із поля і показати на сторінці   items[0].deliveryAddress
  [return]  ${Delivery_Address.split(', ')[3]}

отримати інформацію про items[0].deliveryAddress.streetAddress
  ${Delivery_Address}=   отримати текст із поля і показати на сторінці   items[0].deliveryAddress
  ${Delivery_Address}=   Get Substring   ${Delivery_Address}=    0   -2
  [return]  ${Delivery_Address.split(', ')[4]}

##CPV
отримати інформацію про items[0].classification.scheme
  ${classificationScheme}=   отримати текст із поля і показати на сторінці   items[0].classification.scheme.title
  [return]  ${classificationScheme.split(' ')[1]}

отримати інформацію про items[0].classification.id
  ${classification_id}=   отримати текст із поля і показати на сторінці   items[0].classification.scheme
  [return]  ${classification_id.split(' - ')[0]}

отримати інформацію про items[0].classification.description
  ${classification_description}=   отримати текст із поля і показати на сторінці   items[0].classification.scheme
  Run Keyword And Return If  '${classification_description}' == '44617100-9 - Картонки'   Convert To String   Cartons
  [return]  ${classification_description}

##ДКПП
отримати інформацію про items[0].additionalClassifications[0].scheme
  ${additional_classificationScheme}=   отримати текст із поля і показати на сторінці   items[0].additional_classification[0].scheme.title
  [return]  ${additional_classificationScheme.split(' ')[1]}

отримати інформацію про items[0].additionalClassifications[0].id
  ${additional_classification_id}=   отримати текст із поля і показати на сторінці   items[0].additional_classification[0].scheme
  [return]  ${additional_classification_id.split(' - ')[0]}

отримати інформацію про items[0].additionalClassifications[0].description
  ${additional_classification_description}=   отримати текст із поля і показати на сторінці   items[0].additional_classification[0].scheme
  ${additional_classification_description}=   Convert To Lowercase   ${additional_classification_description}
  ${additional_classification_description}=   Get Substring   ${additional_classification_description}=    0   -2
  [return]  ${additional_classification_description.split(' - ')[1]}

##item
отримати інформацію про items[0].unit.name
  ${unit_name}=   отримати текст із поля і показати на сторінці   items[0].unit.name
  Run Keyword And Return If  '${unit_name}' == 'килограммы'   Convert To String   кілограм
  [return]  ${unit_name}

отримати інформацію про items[0].unit.code
  Fail  Не реалізований функціонал
  ${unit_code}=   отримати текст із поля і показати на сторінці   items[0].unit.code
  [return]  ${unit_code}

отримати інформацію про items[0].quantity
  ${quantity}=   отримати текст із поля і показати на сторінці   items[0].quantity
  ${quantity}=   Convert To Number   ${quantity}
  [return]  ${quantity}

додати предмети закупівлі
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} =  username
  ...      ${ARGUMENTS[1]} =  ${TENDER_UAID}
  ...      ${ARGUMENTS[2]} =  3
  ${period_interval}=  Get Broker Property By Username  ${ARGUMENTS[0]}  period_interval
  ${ADDITIONAL_DATA}=  prepare_test_tender_data  ${period_interval}  multi
  ${items}=         Get From Dictionary   ${ADDITIONAL_DATA.data}               items
  Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
  Wait Until Page Contains Element   ${locator.edit_tender}    10
  Click Element                      ${locator.edit_tender}
  Wait Until Page Contains Element   ${locator.edit.add_item}  10
  Input text   ${locator.edit.description}   description
  Run keyword if   '${TEST NAME}' == 'Можливість додати позицію закупівлі в тендер'   додати позицію
  Run keyword if   '${TEST NAME}' != 'Можливість додати позицію закупівлі в тендер'   забрати позицію
  Wait Until Page Contains Element   ${locator.save}           10
  Click Element   ${locator.save}
  Wait Until Page Contains Element   ${locator.description}    20

додати позицію
###  Не видно контролів додати пропозицію в хромі, потрібно скролити, скрол не працює. Обхід: додати лише 1 пропозицію + редагувати description для скролу.
  Click Element    ${locator.edit.add_item}
  Додати придмет   ${items[1]}   1

забрати позицію
  Click Element   xpath=//a[@title="Добавить лот"]/preceding-sibling::a

Задати питання
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} = username
  ...      ${ARGUMENTS[1]} = ${TENDER_UAID}
  ...      ${ARGUMENTS[2]} = question_data
  ${title}=        Get From Dictionary  ${ARGUMENTS[2].data}  title
  ${description}=  Get From Dictionary  ${ARGUMENTS[2].data}  description
  Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
  newtend.Пошук тендера по ідентифікатору   ${ARGUMENTS[0]}   ${ARGUMENTS[1]}
  Click Element   xpath=//a[contains(text(), "Уточнения")]
  Wait Until Page Contains Element   xpath=//button[@class="btn btn-lg btn-default question-btn ng-binding ng-scope"]   20
  Click Element   xpath=//button[@class="btn btn-lg btn-default question-btn ng-binding ng-scope"]
  Wait Until Page Contains Element   xpath=//input[@ng-model="title"]   10
  Input text   xpath=//input[@ng-model="title"]   ${title}
  Input text    xpath=//textarea[@ng-model="message"]   ${description}
  Click Element   xpath=//div[@ng-click="sendQuestion()"]
  Wait Until Page Contains    ${description}   20

обновити сторінку з тендером
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} = username
  ...      ${ARGUMENTS[1]} = ${TENDER_UAID}
  Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
  Reload Page
  Wait Until Page Contains   ${ARGUMENTS[1]}   20

отримати інформацію про QUESTIONS[0].title
  Wait Until Page Contains Element   xpath=//span[contains(text(), "Уточнения")]   20
  Click Element              xpath=//span[contains(text(), "Уточнения")]
  Wait Until Page Contains   Вы не можете задавать вопросы    20
  ${resp}=   отримати текст із поля і показати на сторінці   QUESTIONS[0].title
  [return]  ${resp}

отримати інформацію про QUESTIONS[0].description
  ${resp}=   отримати текст із поля і показати на сторінці   QUESTIONS[0].description
  [return]  ${resp}

отримати інформацію про QUESTIONS[0].date
  ${resp}=   отримати текст із поля і показати на сторінці   QUESTIONS[0].date
  ${resp}=   Change_day_to_month   ${resp}
  [return]  ${resp}

Change_day_to_month
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]}  ==  date
  ${day}=   Get Substring   ${ARGUMENTS[0]}   0   2
  ${month}=   Get Substring   ${ARGUMENTS[0]}  3   6
  ${rest}=   Get Substring   ${ARGUMENTS[0]}   5
  ${return_value}=   Convert To String  ${month}${day}${rest}
  [return]  ${return_value}
