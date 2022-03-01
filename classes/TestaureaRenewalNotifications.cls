@isTest(SeeAllData=false)
public with sharing class TestaureaRenewalNotifications {
    
    //setup test data
    static testMethod void initiateRenewals() {
        test.startTest();
        list<v1AureaRenewals__TSI_Renewals_Support__c> csRec = new list<v1AureaRenewals__TSI_Renewals_Support__c>();
        csRec.add(
            new v1AureaRenewals__TSI_Renewals_Support__c(
                name='Fields To Send', 
                v1AureaRenewals__Operation_Info__c = 'Id,NetSuite_ID__c'
            )
        );
        csRec.add(
            new v1AureaRenewals__TSI_Renewals_Support__c(
                name='Production Renewal Site Url', 
                v1AureaRenewals__Operation_Info__c = 'https://aurea.secure.force.com/services/apexrest/TSISupport'
            )
        );
        csRec.add(
            new v1AureaRenewals__TSI_Renewals_Support__c(
                name='Renewals Query Support', 
                v1AureaRenewals__Operation_Info__c = 'select Id,NetSuite_ID__c,Name from account where Id IN : AccountIds'
            )
        );
        csRec.add(
            new v1AureaRenewals__TSI_Renewals_Support__c(
                name='Run Renewal Operation', 
                v1AureaRenewals__Operation_Info__c = 'TRUE'
            )
        );
        csRec.add(
            new v1AureaRenewals__TSI_Renewals_Support__c(
                name='Sandbox Renewal Site Url', 
                v1AureaRenewals__Operation_Info__c = 'https://sfdev-aurea.cs203.force.com/services/apexrest/TSISupport'
            )
        );
        insert csRec;
        
        Account acct = new Account(Name = 'Test Account');
        insert acct;
        
        //Opportunity without Type and without NetSuiteId, should not create if validation rules are active
        Opportunity opp = new Opportunity(
            Name = 'Opportunity',
            StageName = 'Pending',
            CloseDate = System.today().addMonths(1),
            AccountId = acct.Id
        );
        insert opp;
        
        // Set mock callout class 
        TSIMockHttpResponseGenerator mockHttp = new TSIMockHttpResponseGenerator();
        Test.setMock(HttpCalloutMock.class, mockHttp);
        
        //trigger opportunity flow
        update opp;
        aureaRenewalNotifications.initiateRenewals(new list<id>{acct.id});
        test.stopTest();
    }    
    
}