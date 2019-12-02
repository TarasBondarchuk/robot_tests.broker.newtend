#!/usr/bin/python
# -*- coding: utf-8 -*-
from datetime import datetime
import pytz
import urllib
import os


<<<<<<< .merge_file_a10884
tz = str(datetime.now(pytz.timezone('Europe/Kiev')))[26:]


def prepare_tender_data(role, data):
    if role == 'tender_owner':
        data['data']['procuringEntity']['name'] = u'Тестовый организатор "Банк Ликвидатор"'
    return data


def convert_date_from_item(date):
    date = datetime.strptime(date, '%d/%m/%Y %H:%M:%S').strftime('%Y-%m-%d')
    return '{}T00:00:00{}'.format(date, tz)


def adapt_paid_date(sign_date, date_paid):
    time = sign_date[-8:]
    date = datetime.strptime(date_paid, '%Y-%m-%d')
    return '{} {}'.format(datetime.strftime(date, '%d/%m/%Y'), time)


def convert_date(date):
    date = datetime.strptime(date, '%d/%m/%Y %H:%M:%S').strftime('%Y-%m-%dT%H:%M:%S.%f')
    return '{}{}'.format(date, tz)


def convert_date_for_item(date):
    date = datetime.strptime(date, '%Y-%m-%dT%H:%M:%S{}'.format(tz)).strftime('%d/%m/%Y %H:%M')
    return '{}'.format(date)


def convert_date_for_auction(date):
    date = datetime.strptime(date, '%Y-%m-%dT%H:%M:%S.%f{}'.format(tz)).strftime('%d/%m/%Y %H:%M')
    return '{}'.format(date)

def convert_date_for_datePaid(date):
    date = datetime.strptime(date, '%Y-%m-%dT%H:%M:%S.%f{}'.format(tz)).strftime('%d/%m/%Y %H:%M:%S')
    return date


def dgf_decision_date_from_site(date):
    return u'{}-{}-{}'.format(date[-4:], date[-7:-5], date[-10:-8])


def dgf_decision_date_for_site(date):
    return u'{}/{}/{}'.format(date[-2:], date[-5:-3], date[-10:-6])


def adapted_dictionary(value):
    return{
        u"з урахуванням ПДВ": True,
        u"без урахуванням ПДВ": False,
        u"True": "1",
        u"False": "0",
        u"Оголошення аукціону з продажу майна банків": "dgfOtherAssets",
        u'Класифікація згідно CAV': 'CAV',
        u'Класифікація згідно CAV-PS': 'CAV-PS',
        u'Класифікація згідно CPV': 'CPV',
        u'Очiкування пропозицiй': 'active.tendering',
        u'Перiод уточнень': 'active.enquires',
        u'Аукцiон': 'active.auction',
        u'Квалiфiкацiя переможця': 'active.qualification',
        u'Торги не відбулися': 'unsuccessful',
        u'Аукціон завершено. Договір підписано.': 'complete',
        u'Торги скасовано': 'cancelled',
        u'Торги були відмінені.': 'active',
        u'Очікується підписання договору': 'active',
        u'Очікується протокол': 'pending.verification',
        u'На черзі': 'pending.waiting',
        u'На розглядi': 'pending',
        u'Рiшення скасовано': 'cancelled',
        u'Оплачено, очікується підписання договору': 'active',
        u'Дискваліфіковано': 'unsuccessful',
        u'майна банків': 'dgfOtherAssets',
        u'прав вимоги за кредитами': 'dgfFinancialAssets',
        u'Голландський аукціон': 'dgfInsider',
        u'Юридична Інформація про Майданчики': 'x_dgfPlatformLegalDetails',
        u'Презентація': 'x_presentation',
        u'Договір NDA': 'x_nda',
        u'Паспорт торгів': 'tenderNotice',
        u'Публічний Паспорт Активу': 'technicalSpecifications',
        u'Ілюстрації': 'illustration',
        u'Кваліфікаційні вимоги': 'evaluationCriteria',
        u'Типовий договір': 'contractProforma',
        u'Погодження змін до опису лоту': 'clarifications',
        u'Посилання на Публічний Паспорт Активу': 'x_dgfPublicAssetCertificate',
        u'Інформація про деталі ознайомлення з майном у кімнаті даних': 'x_dgfAssetFamiliarization',
        u'Договір підписано та активовано': 'active',
        u'Оголошення аукціону з продажу прав вимоги за кредитами': 'dgfFinancialAssets',
        u'Оголошення з продажу на «голландському» аукціоні': 'dgfInsider',
        u'Торги відмінено': 'cancelled',
        u'Очікується опублікування протоколу': 'active.qualification',
        u'Відмова від очікування': 'cancelled'
    }.get(value, value)


def adapt_data(field, value):
    if field == 'tenderAttempts':
        value = int(value)
    elif 'dutchSteps' in field:
=======
def convert_time(date):
    date = datetime.strptime(date, "%d/%m/%Y %H:%M:%S")
    return timezone('Europe/Kiev').localize(date).strftime('%Y-%m-%dT%H:%M:%S.%f%z')


def convert_decision_date(date):
    date_obj = datetime.strptime(date, "%d/%m/%Y")
    return date_obj.strftime("%Y-%m-%d")

def convert_datetime_to_newtend_format(isodate):
    iso_dt = parse_date(isodate)
    day_string = iso_dt.strftime("%d/%m/%Y %H:%M")
    return day_string


def convert_date_to_template_format(date, template_in, template_out):
    return datetime.strptime(date, template_in).strftime(template_out)


def convert_string_from_dict_newtend(string):
    return {
        u"грн": u"UAH",
        u"True": u"1",
        u"False": u"0",
        u'Класифікація згідно CAV': u'CAV',
        u'Класифікація згідно CAV-PS': u'CAV-PS',
        u'Класифікація згідно CPV': u'CPV',
        u'з урахуванням ПДВ': True,
        u'без урахуванням ПДВ': False,
        u'очiкування пропозицiй': u'active.tendering',
        u'перiод уточнень': u'active.enquires',
        u'аукцiон': u'active.auction',
        u'квалiфiкацiя переможця': u'active.qualification',
        u'торги не відбулися': u'unsuccessful',
        u'продаж завершений': u'complete',
        u'торги скасовано': u'cancelled',
        u'торги були відмінені.': u'active',
        u'Юридична Інформація про Майданчики': u'x_dgfPlatformLegalDetails',
        u'Презентація': u'x_presentation',
        u'Договір про нерозголошення (NDA)': u'x_nda',
        u'Публічний Паспорт Активу': u'x_dgfPublicAssetCertificate',
        u'Технічні специфікації': u'x_technicalSpecifications',
        u'Паспорт торгів': u'x_tenderNotice',
        u'Повідомлення про аукціон': u'notice',
        u'Ілюстрації': u'illustration',
        u'Критерії оцінки': u'evaluationCriteria',
        u'Пояснення до питань заданих учасниками': u'clarifications',
        u'Інформація про учасників': u'bidders',
        u'майна замовника': u'dgfOtherAssets',
        u'очікується протокол': u'pending.verification',
        u'на черзі': u'pending.waiting',
        u'очікується підписання договору': u'pending.payment',
        u'оплачено, очікується підписання договору': u'active',
        u'рiшення скасовано': u'cancelled',
        u'дискваліфіковано': u'unsuccessful',
    }.get(string, string)


def adapt_procuringEntity(role_name, tender_data):
    if role_name == 'tender_owner':
        tender_data['data']['procuringEntity']['name'] = u"ТЕСТОВА КОМПАНІЯ"
    return tender_data


def adapt_view_data(value, field_name):
    if field_name == 'value.amount':
        value = float(value)
    elif field_name in ('minimalStep.amount', 'guarantee.amount'):
        value = float(value.split(' ')[0])
    elif field_name == 'tenderAttempts':
>>>>>>> .merge_file_a02308
        value = int(value)
    elif field == 'value.amount':
        value = float(value)
    elif field == 'minimalStep.amount':
        value = float(value.split(' ')[0])
<<<<<<< .merge_file_a10884
    elif field == 'guarantee.amount':
        value = float(value.split(' ')[0])
    elif field == 'quantity':
        value = float(value.replace(',', '.'))
    elif field == 'minNumberOfQualifiedBids':
        value = int(value)
    elif 'contractPeriod' in field:
        value = convert_date_from_item(value)
    elif 'tenderPeriod' in field or 'auctionPeriod' in field or 'datePaid' in field:
        value = convert_date(value)
    elif 'dgfDecisionDate' in field:
        value = dgf_decision_date_from_site(value)
    elif 'dgfDecisionID' in field:
        value = value[-6:]
    else:
        value = adapted_dictionary(value)
    return value
=======
    elif 'questions' in field_name and '.date' in field_name:
        value = convert_time(value.split(' - ')[0])
    elif field_name == 'dgfDecisionDate':
        return convert_decision_date(value.split(" ")[-1])
    elif field_name == 'dgfDecisionID':
        value = value.split(" ")[1]
    elif 'Date' in field_name:
        value = convert_time(value)
    elif field_name == 'minNumberOfQualifiedBids':
        value = int(value)
    return convert_string_from_dict_newtend(value)


def adapt_view_item_data(value, field_name):
    if 'quantity' in field_name:
        value = float(value.replace(",", "."))
    elif 'contractPeriod' in field_name:
        value = "{}T00:00:00+02:00".format(convert_date_to_template_format(value, "%d/%m/%Y %H:%M:%S", "%Y-%m-%d"))
    return convert_string_from_dict_newtend(value)
>>>>>>> .merge_file_a02308


def download_file(url, filename, folder):
    urllib.urlretrieve(url, ('{}/{}'.format(folder, filename)))


def my_file_path():
    return os.path.join(os.getcwd(), 'src', 'robot_tests.broker.newtend', 'Doc.pdf')