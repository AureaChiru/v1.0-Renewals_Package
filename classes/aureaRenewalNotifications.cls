/*
Organisation: Aurea PvtLtd
Created on: Feb 15 2022
Description: Helps to send email notification to aurea systems to initiate renewal opportunity operations
*/
global class aureaRenewalNotifications{
    
    //TSI Renewals Support custom settings
    global static map<string, v1AureaRenewals__TSI_Renewals_Support__c> mapTSIRenewals{
        get{
            if(mapTSIRenewals == null){
                mapTSIRenewals = v1AureaRenewals__TSI_Renewals_Support__c.getAll();
                mapTSIRenewals = (
                    (mapTSIRenewals == null && mapTSIRenewals.keyset() == null) ? 
                    new map<string, v1AureaRenewals__TSI_Renewals_Support__c>() : 
                    mapTSIRenewals
                );
            }
            return mapTSIRenewals;
        }
        set{
            mapTSIRenewals = value;
        }
    }
    
    //service invocable method to initiate callout operation
    @InvocableMethod(label='Initiate Renewals' description='Renewal opportunity trigger operation')
    global static List<String> initiateRenewals(list<id> AccountIds) {
        if(mapTSIRenewals.get('Run Renewal Operation').v1AureaRenewals__Operation_Info__c == 'TRUE'){
            sendNotification(AccountIds);
        }
        return null;
    }
    
    //request body class
    global class restCls{
        global string fieldLabel;
        global string fieldValue;
        global restCls(string fieldLabelVar, string fieldValueVar){
            fieldLabel = fieldLabelVar;
            fieldValue = fieldValueVar;
        }
    }
    
    //send email notification to aurea systems
    @Future(callout=true)
    global static void sendNotification(list<id> AccountIds){
                
        //service variables
        Http http;
        HTTPResponse res;
        HttpRequest request;
        
        //sandbox query check
        boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;

        //fill body elements
        list<restCls> restClsLst = new list<restCls>();
        for(sObject sObj:database.query(mapTSIRenewals.get('Renewals Query Support').v1AureaRenewals__Operation_Info__c)){
            if(
                mapTSIRenewals.get('Fields To Send').v1AureaRenewals__Operation_Info__c != '' && 
                mapTSIRenewals.get('Fields To Send').v1AureaRenewals__Operation_Info__c != null
            ){
                for(string fld:mapTSIRenewals.get('Fields To Send').v1AureaRenewals__Operation_Info__c.split(',')){
                    restClsLst.add(new restCls(fld, sObj.get(fld)+''));
                }
            }
        }
                
        //initiate callout request
        http = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint(
            (
                isSandbox ? 
                mapTSIRenewals.get('Sandbox Renewal Site Url').v1AureaRenewals__Operation_Info__c : 
                mapTSIRenewals.get('Production Renewal Site Url').v1AureaRenewals__Operation_Info__c
            ) + 
            '?dataCls=' + 
            JSON.serialize(restClsLst)
        );
        req.setHeader('Content-Type', 'application/json');
        res = http.send(req);
        
        //logs over the callout
        system.debug('TSI Renewals Response:'+res);
        system.debug('TSI Renewals Response Body:'+res.getBody());
    }
}