@isTest
global class TSIMockHttpResponseGenerator implements HttpCalloutMock{
       
     // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setBody('{"netSuiteIdsStr": "Id:0015j00000Xj2AsAAJ,NetSuite_ID__c:1234567891122"}');
        res.setStatusCode(200);     
        return res;
    }
}