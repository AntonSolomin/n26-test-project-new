/**
 * Exposes product information for the Case's Contact.
 * Uses ProductInformationService for core values (cost, ATM fee, replacement)
 * and dynamically includes additional Product_Information__mdt fields so new
 * metadata columns surface without UI changes.
 */
public with sharing class ProductInfoController {
    public class ProductInfoResult {
        @AuraEnabled public Boolean success;
        @AuraEnabled public List<FieldValue> fields;
        @AuraEnabled public String product;
        @AuraEnabled public String country;
        @AuraEnabled public List<String> errors;
        public ProductInfoResult() {
            success = false;
            fields = new List<FieldValue>();
            errors = new List<String>();
        }
    }
    public class FieldValue {
        @AuraEnabled public String apiName;
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        public FieldValue(String apiName, String label, String value) {
            this.apiName = apiName;
            this.label = label;
            this.value = value;
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static ProductInfoResult getProductInfoByCase(Id caseId) {
        ProductInfoResult result = new ProductInfoResult();
        if (caseId == null || caseId.getSObjectType() != Case.SObjectType) {
            result.errors.add('Valid Case Id is required');
            return result;
        }
        try {
            Case c = [
                SELECT ContactId
                FROM Case
                WHERE Id = :caseId
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];
            if (c.ContactId == null) {
                result.errors.add('Case has no related Contact');
                return result;
            }
            return buildResultForContact(c.ContactId);
        } catch (Exception e) {
            result.errors.add('Unable to retrieve product information');
            return result;
        }
    }

    @AuraEnabled(cacheable=true)
    public static ProductInfoResult getProductInfoByContact(Id contactId) {
        ProductInfoResult result = new ProductInfoResult();
        if (contactId == null || contactId.getSObjectType() != Contact.SObjectType) {
            result.errors.add('Valid Contact Id is required');
            return result;
        }
        try {
            return buildResultForContact(contactId);
        } catch (Exception e) {
            result.errors.add('Unable to retrieve product information');
            return result;
        }
    }

    private static ProductInfoResult buildResultForContact(Id contactId) {
        ProductInfoResult result = new ProductInfoResult();
        Contact con = [
            SELECT Product__c, Home_Country__c
            FROM Contact
            WHERE Id = :contactId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        result.product = con.Product__c;
        result.country = con.Home_Country__c;

        String validationError = validateContactInfo(con);
        if (validationError != null) {
            result.errors.add(validationError);
            return result;
        }
        // Core fields from service (cost, replacement, ATM) - ordered
        Map<String, String> core = ProductInformationService.getProductInformation(con.Product__c, con.Home_Country__c);
        List<String> coreOrder = new List<String>{ 'costPerMonth', 'cardReplacementCost', 'atmFee' };
        for (String key : coreOrder) {
            if (core.containsKey(key)) {
                result.fields.add(new FieldValue(key, formatLabel(key), core.get(key)));
            }
        }
        // Dynamic metadata fields: load the row once to surface any new metadata columns
        List<Product_Information__mdt> rows = [
            SELECT Product__c, Country__c, Plan_Type__c, Cost_Per_Month__c, ATM_Fee__c, Card_Replacement_Cost__c
            FROM Product_Information__mdt
            WHERE Product__c = :con.Product__c AND Country__c = :con.Home_Country__c
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        if (!rows.isEmpty()) {
            Product_Information__mdt row = rows[0];
            Map<String, Schema.SObjectField> fmap = Schema.sObjectType.Product_Information__mdt.fields.getMap();
            for (String api : fmap.keySet()) {
                if (api.endsWith('__c') &&
                    api != 'Plan_Type__c' &&
                    api != 'Card_Replacement_Cost__c' &&
                    api != 'Cost_Per_Month__c' &&
                    api != 'ATM_Fee__c' &&
                    !resultFieldExists(result.fields, api)) {
                    Schema.DescribeFieldResult d = fmap.get(api).getDescribe();
                    Object raw = row.get(api);
                    String val = raw == null ? null : String.valueOf(raw);
                    result.fields.add(new FieldValue(api, d.getLabel(), val));
                }
            }
        }
        result.success = true;
        return result;
    }

    private static String validateContactInfo(Contact con) {
        if (String.isBlank(con.Product__c) || String.isBlank(con.Home_Country__c)) {
            return 'Contact missing Product or Home Country';
        }
        if (!ProductInformationService.isValidProduct(con.Product__c)) {
            return 'Unsupported product: ' + con.Product__c;
        }
        if (!ProductInformationService.isValidCountry(con.Home_Country__c)) {
            return 'Unsupported country: ' + con.Home_Country__c;
        }
        return null;
    }
    
    private static Boolean resultFieldExists(List<FieldValue> fieldList, String apiName) {
        for (FieldValue fv : fieldList) {
            if (fv.apiName == apiName) {
                return true;
            }
        }
        return false;
    }
    
    private static String formatLabel(String apiName) {
        Map<String, String> labels = new Map<String, String>{
            'costPerMonth' => 'Cost per Month',
            'atmFee' => 'ATM Fee',
            'cardReplacementCost' => 'Card Replacement'
        };
        return labels.containsKey(apiName) ? labels.get(apiName) : apiName;
    }
}

