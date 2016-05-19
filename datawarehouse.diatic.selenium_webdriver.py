# -*- coding: utf-8 -*-

# setup
# sudo pip install selenium
# sudo aptitude install chromedriver

from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.ui import Select
from selenium.common.exceptions import NoSuchElementException
from selenium.common.exceptions import NoAlertPresentException
import unittest, time, re

from selenium.webdriver.support.ui import WebDriverWait # available since 2.4.0
from selenium.webdriver.support import expected_conditions as EC # available since 2.26.0
from os.path import expanduser
import os

# settings - modifica questo e scarichi :)
username = "username"
password = "password"
nome_coorte = "2014/2015"
corso_di_laurea = "INGEGNERIA PER L'AMBIENTE E IL TERRITORIO:0701"
webdriver_path = 'chromedriver_amd64/chromedriver'
target   = expanduser("~")+'/Scaricati/Main.aspx'
if os.path.exists(target):
    os.remove(target)
#

class DatawarehouseDiatic(unittest.TestCase):
    def setUp(self):
        self.driver = webdriver.Chrome(webdriver_path)
        self.driver.implicitly_wait(30)
        self.base_url = "http://datawarehouse.unical.it/microstrategy/asp/"
        self.verificationErrors = []
        self.accept_next_alert = True
    
    def test_datawarehouse_diatic14feb2016(self):
        driver = self.driver
        driver.get(self.base_url)
        driver.find_element_by_link_text("UNICAL 2.1.0").click()
        driver.find_element_by_id("Uid").clear()
        driver.find_element_by_id("Uid").send_keys(username)
        driver.find_element_by_id("Pwd").clear()
        driver.find_element_by_id("Pwd").send_keys(password)
        driver.find_element_by_id("3054").click()
        driver.find_element_by_css_selector("div.name > a.mstr-link").click()
        driver.find_element_by_link_text("REPORT ASTISS").click()
        driver.find_element_by_link_text("Riesame").click()
        driver.find_element_by_link_text("Esami per coorte di immatricolazione e studente con anno accademico sostenimento").click()

        time.sleep(1)
        select_co_im = Select(driver.find_element_by_id("unitsToAdd"))
        select_co_im.deselect_all()
        print 'Coorti di immatricolazione disponibili:'
        for i in select_co_im.options:
            print i.text
        
        select_co_im.select_by_visible_text(nome_coorte)
        
        # clicco per selezionare
        #driver.find_elements(By.CLASS_NAME, "cheese")
        driver.find_element_by_id("addUnitsButton").click()
        select_cdl = Select(driver.find_element_by_id("unitsToAdd_1"))
        select_cdl.deselect_all()
        time.sleep(1)
        print 'Corsi di laurea disponibili:'
        for i in select_cdl.options:
            print i.text
        select_cdl.select_by_visible_text(corso_di_laurea)
        time.sleep(1)
        driver.find_element_by_id("addUnitsButton_1").click()
        
        driver.find_element_by_id("answerButton").click()
        
        element = WebDriverWait(driver, 120).until(EC.presence_of_element_located((By.ID, "tbExport")))
        element.click()
        #driver.find_element_by_id("tbExport").click()
        time.sleep(9)
        driver.get(self.base_url+'/Main.aspx?evt=3008&src=Main.aspx.3008')

    def is_element_present(self, how, what):
        try: self.driver.find_element(by=how, value=what)
        except NoSuchElementException as e: return False
        return True
    
    def is_alert_present(self):
        try: self.driver.switch_to_alert()
        except NoAlertPresentException as e: return False
        return True
    
    def close_alert_and_get_its_text(self):
        try:
            alert = self.driver.switch_to_alert()
            alert_text = alert.text
            if self.accept_next_alert:
                alert.accept()
            else:
                alert.dismiss()
            return alert_text
        finally: self.accept_next_alert = True
    
    def tearDown(self):
        self.driver.quit()
        self.assertEqual([], self.verificationErrors)

if __name__ == "__main__":
    unittest.main()
