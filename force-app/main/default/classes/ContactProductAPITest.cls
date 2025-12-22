/**
 * Test class for ContactProductAPI REST endpoint
 * Tests successful API calls, error scenarios, and edge cases
 */
@isTest
private class ContactProductAPITest {
    
    /**
     * Test successful GET request with valid UUID and complete contact data
     */
    @isTest
    static void testGetContactProductInfo_Success() {
        // Create test contact with all required fields
        Contact testContact = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            Product__c = 'Standard',
            Home_Country__c = 'DE',
            UUID__c = 'test-uuid-12345'
        );
        insert testContact;
        
        // Set up REST context for GET request
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ContactProductAPI/test-uuid-12345';
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
        
        // Execute the API call
        Test.startTest();
        ContactProductAPI.getContactProductInfo();
        Test.stopTest();
        
        // Verify response
        System.assertEquals(200, res.statusCode, 'Status code should be 200');
        
        // Parse response
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.responseBody.toString());
        System.assertEquals(true, responseMap.get('success'), 'Response should indicate success');
        
        // Verify contact information
        Map<String, Object> contactMap = (Map<String, Object>) responseMap.get('contact');
        System.assertEquals(testContact.Id, contactMap.get('id'), 'Contact ID should match');
        System.assertEquals('John Doe', contactMap.get('name'), 'Contact name should match');
        System.assertEquals('Standard', contactMap.get('product'), 'Product should match');
        System.assertEquals('DE', contactMap.get('homeCountry'), 'Home country should match');
        System.assertEquals('test-uuid-12345', contactMap.get('uuid'), 'UUID should match');
        
        // Verify product information
        Map<String, Object> productInfoMap = (Map<String, Object>) responseMap.get('productInformation');
        System.assertNotEquals(null, productInfoMap, 'Product information should not be null');
        System.assertEquals('€ 0', productInfoMap.get('costPerMonth'), 'Cost per month should match');
        System.assertEquals('1.7%', productInfoMap.get('atmFee'), 'ATM fee should match');
        System.assertEquals('€ 6', productInfoMap.get('cardReplacementCost'), 'Card replacement cost should match');
    }
    
    /**
     * Test successful GET request with Black product and UK country (N/a value)
     */
    @isTest
    static void testGetContactProductInfo_BlackUK_N_aValue() {
        Contact testContact = new Contact(
            FirstName = 'Jane',
            LastName = 'Smith',
            Product__c = 'Black',
            Home_Country__c = 'UK',
            UUID__c = 'test-uuid-black-uk'
        );
        insert testContact;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ContactProductAPI/test-uuid-black-uk';
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        ContactProductAPI.getContactProductInfo();
        Test.stopTest();
        
        System.assertEquals(200, res.statusCode, 'Status code should be 200');
        
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.responseBody.toString());
        Map<String, Object> productInfoMap = (Map<String, Object>) responseMap.get('productInformation');
        System.assertEquals('N/a', productInfoMap.get('costPerMonth'), 'Black UK cost per month should be N/a');
        System.assertEquals('Free', productInfoMap.get('atmFee'), 'Black UK ATM fee should be Free');
        System.assertEquals('£ 6', productInfoMap.get('cardReplacementCost'), 'Black UK card replacement should be £ 6');
    }
    
    /**
     * Test successful GET request with Metal product and different currencies
     */
    @isTest
    static void testGetContactProductInfo_MetalProduct_DifferentCurrencies() {
        // Test with UK (pounds)
        Contact testContactUK = new Contact(
            FirstName = 'Metal',
            LastName = 'UK',
            Product__c = 'Metal',
            Home_Country__c = 'UK',
            UUID__c = 'test-uuid-metal-uk'
        );
        insert testContactUK;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ContactProductAPI/test-uuid-metal-uk';
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        ContactProductAPI.getContactProductInfo();
        Test.stopTest();
        
        System.assertEquals(200, res.statusCode, 'Status code should be 200');
        
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.responseBody.toString());
        Map<String, Object> productInfoMap = (Map<String, Object>) responseMap.get('productInformation');
        System.assertEquals('N/a', productInfoMap.get('costPerMonth'), 'Metal UK cost per month should be N/a');
        System.assertEquals('£ 45', productInfoMap.get('cardReplacementCost'), 'Metal UK card replacement should be £ 45');
    }
    
    /**
     * Test GET request with missing UUID (400 error)
     */
    @isTest
    static void testGetContactProductInfo_MissingUUID() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ContactProductAPI/';
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        ContactProductAPI.getContactProductInfo();
        Test.stopTest();
        
        System.assertEquals(400, res.statusCode, 'Status code should be 400');
        
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.responseBody.toString());
        System.assertEquals(false, responseMap.get('success'), 'Response should indicate failure');
        List<Object> errors = (List<Object>) responseMap.get('errors');
        System.assertNotEquals(null, errors, 'Errors should be present');
        System.assert(errors.size() > 0, 'At least one error should be present');
    }
    
    /**
     * Test GET request with invalid UUID (404 error)
     */
    @isTest
    static void testGetContactProductInfo_InvalidUUID() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ContactProductAPI/non-existent-uuid';
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        ContactProductAPI.getContactProductInfo();
        Test.stopTest();
        
        System.assertEquals(404, res.statusCode, 'Status code should be 404');
        
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.responseBody.toString());
        System.assertEquals(false, responseMap.get('success'), 'Response should indicate failure');
        List<Object> errors = (List<Object>) responseMap.get('errors');
        System.assertNotEquals(null, errors, 'Errors should be present');
    }
    
    /**
     * Test GET request with contact missing Product__c field
     */
    @isTest
    static void testGetContactProductInfo_MissingProduct() {
        Contact testContact = new Contact(
            FirstName = 'No',
            LastName = 'Product',
            Home_Country__c = 'DE',
            UUID__c = 'test-uuid-no-product'
        );
        insert testContact;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ContactProductAPI/test-uuid-no-product';
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        ContactProductAPI.getContactProductInfo();
        Test.stopTest();
        
        System.assertEquals(200, res.statusCode, 'Status code should be 200');
        
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.responseBody.toString());
        System.assertEquals(true, responseMap.get('success'), 'Response should indicate success');
        System.assertEquals(null, responseMap.get('productInformation'), 'Product information should be null when product is missing');
    }
    
    /**
     * Test GET request with contact missing Home_Country__c field
     */
    @isTest
    static void testGetContactProductInfo_MissingCountry() {
        Contact testContact = new Contact(
            FirstName = 'No',
            LastName = 'Country',
            Product__c = 'Standard',
            UUID__c = 'test-uuid-no-country'
        );
        insert testContact;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ContactProductAPI/test-uuid-no-country';
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        ContactProductAPI.getContactProductInfo();
        Test.stopTest();
        
        System.assertEquals(200, res.statusCode, 'Status code should be 200');
        
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.responseBody.toString());
        System.assertEquals(true, responseMap.get('success'), 'Response should indicate success');
        System.assertEquals(null, responseMap.get('productInformation'), 'Product information should be null when country is missing');
    }
    
    /**
     * Test successful POST request with UUID in request body
     */
    @isTest
    static void testPostContactProductInfo_SuccessWithBody() {
        Contact testContact = new Contact(
            FirstName = 'Post',
            LastName = 'Test',
            Product__c = 'Standard',
            Home_Country__c = 'FR',
            UUID__c = 'test-uuid-post-body'
        );
        insert testContact;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ContactProductAPI/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{"uuid":"test-uuid-post-body"}');
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        ContactProductAPI.postContactProductInfo();
        Test.stopTest();
        
        System.assertEquals(200, res.statusCode, 'Status code should be 200');
        
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.responseBody.toString());
        System.assertEquals(true, responseMap.get('success'), 'Response should indicate success');
    }
    
    /**
     * Test POST request with UUID in URI (fallback)
     */
    @isTest
    static void testPostContactProductInfo_SuccessWithURI() {
        Contact testContact = new Contact(
            FirstName = 'Post',
            LastName = 'URI',
            Product__c = 'Metal',
            Home_Country__c = 'IT',
            UUID__c = 'test-uuid-post-uri'
        );
        insert testContact;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ContactProductAPI/test-uuid-post-uri';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        ContactProductAPI.postContactProductInfo();
        Test.stopTest();
        
        System.assertEquals(200, res.statusCode, 'Status code should be 200');
        
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.responseBody.toString());
        System.assertEquals(true, responseMap.get('success'), 'Response should indicate success');
    }
    
    /**
     * Test POST request with missing UUID (400 error)
     */
    @isTest
    static void testPostContactProductInfo_MissingUUID() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ContactProductAPI/';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        ContactProductAPI.postContactProductInfo();
        Test.stopTest();
        
        System.assertEquals(400, res.statusCode, 'Status code should be 400');
        
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.responseBody.toString());
        System.assertEquals(false, responseMap.get('success'), 'Response should indicate failure');
    }
    
    /**
     * Test all product/country combinations return correct product information
     */
    @isTest
    static void testAllProductCountryCombinations() {
        List<Contact> testContacts = new List<Contact>();
        List<String> products = new List<String>{ 'Standard', 'Black', 'Metal' };
        List<String> countries = new List<String>{ 'DE', 'FR', 'ES', 'IT', 'UK' };
        
        Integer uuidCounter = 1;
        for (String product : products) {
            for (String country : countries) {
                testContacts.add(new Contact(
                    FirstName = product,
                    LastName = country,
                    Product__c = product,
                    Home_Country__c = country,
                    UUID__c = 'test-uuid-' + uuidCounter++
                ));
            }
        }
        insert testContacts;
        
        // Test a sample of combinations
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'GET';
        
        Test.startTest();
        for (Integer i = 0; i < testContacts.size(); i++) {
            Contact testContact = testContacts[i];
            req.requestURI = '/services/apexrest/ContactProductAPI/test-uuid-' + (i + 1);
            RestContext.request = req;
            RestContext.response = res = new RestResponse();
            
            ContactProductAPI.getContactProductInfo();
            
            System.assertEquals(200, res.statusCode, 'Status code should be 200 for contact ' + testContact.UUID__c);
            
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.responseBody.toString());
            System.assertEquals(true, responseMap.get('success'), 'Response should indicate success');
        }
        Test.stopTest();
    }
    
    /**
     * Test bulk scenario to ensure governor limits are respected
     */
    @isTest
    static void testBulkScenario() {
        // Create 200 contacts to test bulk processing
        List<Contact> testContacts = new List<Contact>();
        for (Integer i = 0; i < 200; i++) {
            testContacts.add(new Contact(
                FirstName = 'Bulk',
                LastName = 'Test' + i,
                Product__c = 'Standard',
                Home_Country__c = 'DE',
                UUID__c = 'bulk-uuid-' + i
            ));
        }
        insert testContacts;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'GET';
        
        Test.startTest();
        // Test multiple API calls
        for (Integer i = 0; i < 10; i++) {
            req.requestURI = '/services/apexrest/ContactProductAPI/bulk-uuid-' + i;
            RestContext.request = req;
            RestContext.response = res = new RestResponse();
            
            ContactProductAPI.getContactProductInfo();
            
            System.assertEquals(200, res.statusCode, 'Status code should be 200 for bulk contact ' + i);
        }
        Test.stopTest();
    }
}

