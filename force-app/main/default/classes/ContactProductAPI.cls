/**
 * REST API endpoint to retrieve contact information and product pricing data by UUID
 * 
 * Endpoint: /services/apexrest/ContactProductAPI/{uuid}
 * Method: GET
 * 
 * This API allows external systems to retrieve contact data and associated
 * product pricing information by providing a UUID identifier.
 */
@RestResource(urlMapping='/ContactProductAPI/*')
global with sharing class ContactProductAPI {
    
    /**
     * GET endpoint handler
     * Retrieves contact and product information by UUID from the URL path
     */
    @HttpGet
    global static void getContactProductInfo() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        // Extract UUID from the request URI
        String uuid = extractUuidFromRequest(req);
        
        if (String.isBlank(uuid)) {
            sendErrorResponse(res, 400, 'UUID parameter is required');
            return;
        }
        
        // Query contact by UUID
        Contact contact = queryContactByUuid(uuid);
        
        if (contact == null) {
            sendErrorResponse(res, 404, 'Contact not found for UUID: ' + uuid);
            return;
        }
        
        // Build and send success response
        ContactProductResponse response = buildResponse(contact);
        sendSuccessResponse(res, response);
    }
    
    /**
     * Extracts UUID from the request URI
     * Expected format: /services/apexrest/ContactProductAPI/{uuid}
     */
    private static String extractUuidFromRequest(RestRequest req) {
        String requestUri = req.requestURI;
        String baseUrl = '/services/apexrest/ContactProductAPI/';
        
        if (requestUri.startsWith(baseUrl)) {
            String uuid = requestUri.substring(baseUrl.length());
            // Remove any trailing slashes or query parameters
            if (uuid.contains('?')) {
                uuid = uuid.substring(0, uuid.indexOf('?'));
            }
            return uuid.trim();
        }
        
        return null;
    }
    
    /**
     * Queries Contact record by UUID__c field
     * Uses external ID field for efficient lookup
     * 
     * Security measures:
     * - Validates UUID format to prevent injection attacks
     * - Checks Field-Level Security (FLS) for all queried fields
     * - Uses bind variables to prevent SOQL injection
     * - Validates object-level access permissions
     */
    private static Contact queryContactByUuid(String uuid) {
        // Validate and sanitize UUID input
        if (!isValidUuid(uuid)) {
            System.debug(LoggingLevel.WARN, 'Invalid UUID format provided: ' + uuid);
            return null;
        }
        
        // Check object-level security - verify user can read Contact records
        if (!Schema.sObjectType.Contact.isAccessible()) {
            System.debug(LoggingLevel.ERROR, 'User does not have access to Contact object');
            return null;
        }
        
        // Check Field-Level Security (FLS) for all fields being queried
        Map<String, Schema.SObjectField> contactFields = Schema.sObjectType.Contact.fields.getMap();
        String[] requiredFields = new String[]{ 'Id', 'Name', 'Product__c', 'Home_Country__c', 'UUID__c' };
        
        for (String fieldName : requiredFields) {
            // Standard fields use lowercase API name, custom fields use exact name
            String apiName = fieldName.contains('__c') ? fieldName : fieldName.toLowerCase();
            Schema.SObjectField field = contactFields.get(apiName);
            
            if (field == null) {
                System.debug(LoggingLevel.ERROR, 'Field not found: ' + fieldName);
                return null;
            }
            
            Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
            if (!fieldDescribe.isAccessible()) {
                System.debug(LoggingLevel.ERROR, 'User does not have access to field: ' + fieldName);
                return null;
            }
        }
        
        try {
            // Use bind variable to prevent SOQL injection
            // UUID is already validated and sanitized
            List<Contact> contacts = [
                SELECT Id, Name, Product__c, Home_Country__c, UUID__c
                FROM Contact
                WHERE UUID__c = :uuid
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];
            
            return contacts.isEmpty() ? null : contacts[0];
        } catch (System.QueryException e) {
            // Security or access violation - don't expose details
            System.debug(LoggingLevel.ERROR, 'Security violation or access denied when querying contact');
            return null;
        } catch (Exception e) {
            // Log error without exposing internal details
            System.debug(LoggingLevel.ERROR, 'Error querying contact by UUID');
            return null;
        }
    }
    
    /**
     * Validates UUID format to prevent injection attacks
     * Accepts standard UUID format: alphanumeric characters, hyphens, and underscores
     * Maximum length: 255 characters (matching field definition)
     * 
     * @param uuid The UUID string to validate
     * @return True if UUID format is valid, false otherwise
     */
    private static Boolean isValidUuid(String uuid) {
        if (String.isBlank(uuid)) {
            return false;
        }
        
        // Check length (UUID__c field is 255 characters max)
        if (uuid.length() > 255) {
            return false;
        }
        
        // Validate format: alphanumeric, hyphens, underscores, and dots only
        // This prevents SOQL injection and other malicious input
        String uuidPattern = '^[a-zA-Z0-9\\-_\\.,]+$';
        Pattern pattern = Pattern.compile(uuidPattern);
        Matcher matcher = pattern.matcher(uuid);
        
        return matcher.matches();
    }
    
    /**
     * Builds the response object with contact and product information
     */
    private static ContactProductResponse buildResponse(Contact contact) {
        ContactProductResponse response = new ContactProductResponse();
        response.success = true;
        
        // Build contact information
        ContactInfo contactInfo = new ContactInfo();
        contactInfo.id = contact.Id;
        contactInfo.name = contact.Name;
        contactInfo.product = contact.Product__c;
        contactInfo.homeCountry = contact.Home_Country__c;
        contactInfo.uuid = contact.UUID__c;
        response.contact = contactInfo;
        
        // Build product information if product and country are available
        if (String.isNotBlank(contact.Product__c) && String.isNotBlank(contact.Home_Country__c)) {
            Map<String, String> productInfo = ProductInformationService.getProductInformation(
                contact.Product__c,
                contact.Home_Country__c
            );
            
            ProductInformation prodInfo = new ProductInformation();
            prodInfo.costPerMonth = productInfo.get('costPerMonth');
            prodInfo.atmFee = productInfo.get('atmFee');
            prodInfo.cardReplacementCost = productInfo.get('cardReplacementCost');
            response.productInformation = prodInfo;
        } else {
            // If product or country is missing, set product information to null
            response.productInformation = null;
        }
        
        return response;
    }
    
    /**
     * Sends a successful response with HTTP 200 status
     */
    private static void sendSuccessResponse(RestResponse res, ContactProductResponse response) {
        res.statusCode = 200;
        res.responseBody = Blob.valueOf(JSON.serializePretty(response));
    }
    
    /**
     * Sends an error response with specified status code and message
     */
    private static void sendErrorResponse(RestResponse res, Integer statusCode, String errorMessage) {
        res.statusCode = statusCode;
        ContactProductResponse errorResponse = new ContactProductResponse();
        errorResponse.success = false;
        errorResponse.errors = new List<String>{ errorMessage };
        res.responseBody = Blob.valueOf(JSON.serializePretty(errorResponse));
    }
    
    /**
     * Response wrapper class for API responses
     * Structures the JSON response in a clean, consistent format
     */
    global class ContactProductResponse {
        public Boolean success;
        public ContactInfo contact;
        public ProductInformation productInformation;
        public List<String> errors;
        
        public ContactProductResponse() {
            this.success = false;
            this.errors = new List<String>();
        }
    }
    
    /**
     * Inner class to represent contact information in the response
     */
    global class ContactInfo {
        public String id;
        public String name;
        public String product;
        public String homeCountry;
        public String uuid;
    }
    
    /**
     * Inner class to represent product information in the response
     */
    global class ProductInformation {
        public String costPerMonth;
        public String atmFee;
        public String cardReplacementCost;
    }
}

