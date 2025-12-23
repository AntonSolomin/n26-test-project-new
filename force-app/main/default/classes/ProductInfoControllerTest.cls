@isTest
private class ProductInfoControllerTest {
    private static Contact createContact(String product, String country) {
        Contact c = new Contact(
            FirstName = 'Test',
            LastName = 'User',
            Product__c = product,
            Home_Country__c = country,
            UUID__c = String.valueOf(Crypto.getRandomLong())
        );
        insert c;
        return c;
    }
    
    private static Case createCase(Contact contact) {
        Case cs = new Case(
            Subject = 'Test Case',
            Status = 'New',
            Origin = 'Phone',
            ContactId = contact != null ? contact.Id : null
        );
        insert cs;
        return cs;
    }
    
    @isTest
    static void returnsFields_success_forCase() {
        Contact c = createContact('Standard', 'DE');
        Case cs = createCase(c);
        
        Test.startTest();
        ProductInfoController.ProductInfoResult res = ProductInfoController.getProductInfoByCase(cs.Id);
        Test.stopTest();
        
        System.assertEquals(true, res.success, 'Should succeed');
        System.assertEquals('Standard', res.product);
        System.assertEquals('DE', res.country);
        System.assert(res.fields.size() > 0, 'Should return dynamic fields');
    }
    
    @isTest
    static void failsWhenNoContact() {
        Case cs = createCase(null);
        Test.startTest();
        ProductInfoController.ProductInfoResult res = ProductInfoController.getProductInfoByCase(cs.Id);
        Test.stopTest();
        System.assertEquals(false, res.success);
        System.assert(res.errors.contains('Case has no related Contact'));
    }
    
    @isTest
    static void failsWhenMissingProductOrCountry() {
        Contact c = new Contact(
            FirstName = 'No',
            LastName = 'Product',
            Home_Country__c = 'DE',
            UUID__c = String.valueOf(Crypto.getRandomLong())
        );
        insert c;
        Case cs = createCase(c);
        Test.startTest();
        ProductInfoController.ProductInfoResult res = ProductInfoController.getProductInfoByCase(cs.Id);
        Test.stopTest();
        System.assertEquals(false, res.success);
        System.assert(res.errors.size() > 0);
    }
    

    @isTest
    static void rejectsNonCaseId() {
        Contact c = createContact('Standard', 'DE');
        Test.startTest();
        ProductInfoController.ProductInfoResult res = ProductInfoController.getProductInfoByCase(c.Id);
        Test.stopTest();
        System.assertEquals(false, res.success);
        System.assert(res.errors.contains('Valid Case Id is required'));
    }

    @isTest
    static void returnsFields_success_forContact() {
        Contact c = createContact('Standard', 'DE');
        Test.startTest();
        ProductInfoController.ProductInfoResult res = ProductInfoController.getProductInfoByContact(c.Id);
        Test.stopTest();

        System.assertEquals(true, res.success, 'Should succeed');
        System.assertEquals('Standard', res.product);
        System.assertEquals('DE', res.country);
        System.assert(res.fields.size() > 0, 'Should return dynamic fields');
    }

    @isTest
    static void rejectsNonContactId() {
        Case cs = createCase(createContact('Standard', 'DE'));
        Test.startTest();
        ProductInfoController.ProductInfoResult res = ProductInfoController.getProductInfoByContact(cs.Id);
        Test.stopTest();
        System.assertEquals(false, res.success);
        System.assert(res.errors.contains('Valid Contact Id is required'));
    }
}

