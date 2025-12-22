/**
 * Service class to retrieve product pricing information based on Plan_Type__c and Country__c
 * 
 * This service provides centralized access to product pricing data including:
 * - Cost per Calendar Month
 * - ATM Fee in Other Currencies
 * - Card Replacement Cost
 * 
 * Designed to be easily extensible for future products, countries, and factors
 * such as contract length or special packages.
 * 
 * Product information is stored in Custom Metadata Type: Product_Information__mdt
 * This allows for easy updates without code changes.
 */
public with sharing class ProductInformationService {
    
    // Cache for product information metadata to avoid repeated queries for the same plan type and country
    private static Map<String, Product_Information__mdt> productInfoCache;
    
    /**
     * Validates field-level access permissions for Product Information metadata fields
     * 
     * @return True if all required fields are accessible, false otherwise
     */
    private static Boolean hasValidFieldPermissions() {
        Map<String, Schema.SObjectField> fieldMap = Schema.sObjectType.Product_Information__mdt.fields.getMap();
        return fieldMap.get('Plan_Type__c').getDescribe().isAccessible() &&
            fieldMap.get('Country__c').getDescribe().isAccessible() &&
            fieldMap.get('Cost_Per_Month__c').getDescribe().isAccessible() &&
            fieldMap.get('ATM_Fee__c').getDescribe().isAccessible() &&
            fieldMap.get('Card_Replacement_Cost__c').getDescribe().isAccessible();
    }
    
    /**
     * Retrieves a product information metadata record for the given plan type and country
     * Queries metadata directly by Country and Plan Type instead of loading all records
     * 
     * @param planType The plan type (Standard, Black, Metal)
     * @param country The home country code (DE, FR, ES, IT, UK)
     * @return The Product_Information__mdt record, or null if not found
     */
    private static Product_Information__mdt getProductInfoRecord(String planType, String country) {
        if (String.isBlank(planType) || String.isBlank(country)) {
            return null;
        }
        
        // Create cache key
        String cacheKey = planType + '_' + country;
        
        // Check cache first
        if (productInfoCache == null) {
            productInfoCache = new Map<String, Product_Information__mdt>();
        } else if (productInfoCache.containsKey(cacheKey)) {
            return productInfoCache.get(cacheKey);
        }
        
        // Validate CRUD permissions before querying
        if (!Schema.sObjectType.Product_Information__mdt.isAccessible()) {
            throw new SecurityException('Insufficient permissions to access Product Information metadata');
        }
        
        // Validate field-level access
        if (!hasValidFieldPermissions()) {
            throw new SecurityException('Insufficient field-level permissions to access Product Information metadata fields');
        }
        
        // Query metadata by Country and Plan Type only
        List<Product_Information__mdt> productInfoList = [
            SELECT Plan_Type__c, Country__c, Cost_Per_Month__c, ATM_Fee__c, Card_Replacement_Cost__c
            FROM Product_Information__mdt
            WHERE Country__c = :country AND Plan_Type__c = :planType
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        
        Product_Information__mdt productInfo = productInfoList.isEmpty() ? null : productInfoList[0];
        
        // Cache the result
        if (productInfo != null) {
            productInfoCache.put(cacheKey, productInfo);
        }
        
        return productInfo;
    }
    
    /**
     * Retrieves the cost per calendar month for a given plan type and country
     * 
     * @param planType The plan type (Standard, Black, Metal)
     * @param country The home country code (DE, FR, ES, IT, UK)
     * @return The cost per month as a string (e.g., "€ 9,90" or "N/a")
     */
    public static String getCostPerMonth(String planType, String country) {
        Product_Information__mdt productInfo = getProductInfoRecord(planType, country);
        return productInfo != null ? productInfo.Cost_Per_Month__c : null;
    }
    
    /**
     * Retrieves the ATM fee in other currencies for a given plan type and country
     * 
     * @param planType The plan type (Standard, Black, Metal)
     * @param country The home country code (DE, FR, ES, IT, UK)
     * @return The ATM fee as a string (e.g., "1.7%" or "Free")
     */
    public static String getAtmFee(String planType, String country) {
        Product_Information__mdt productInfo = getProductInfoRecord(planType, country);
        return productInfo != null ? productInfo.ATM_Fee__c : null;
    }
    
    /**
     * Retrieves the card replacement cost for a given plan type and country
     * 
     * @param planType The plan type (Standard, Black, Metal)
     * @param country The home country code (DE, FR, ES, IT, UK)
     * @return The card replacement cost as a string (e.g., "€ 6" or "£ 45")
     */
    public static String getCardReplacementCost(String planType, String country) {
        Product_Information__mdt productInfo = getProductInfoRecord(planType, country);
        return productInfo != null ? productInfo.Card_Replacement_Cost__c : null;
    }
    
    /**
     * Retrieves all product information for a given plan type and country
     * 
     * @param planType The plan type (Standard, Black, Metal)
     * @param country The home country code (DE, FR, ES, IT, UK)
     * @return A map containing all product information keys: costPerMonth, atmFee, cardReplacementCost
     */
    public static Map<String, String> getProductInformation(String planType, String country) {
        Map<String, String> productInfo = new Map<String, String>();
        
        productInfo.put('costPerMonth', getCostPerMonth(planType, country));
        productInfo.put('atmFee', getAtmFee(planType, country));
        productInfo.put('cardReplacementCost', getCardReplacementCost(planType, country));
        
        return productInfo;
    }
    
    /**
     * Validates if a plan type is supported by checking if any metadata record exists
     * 
     * @param planType The plan type to validate
     * @return True if the plan type is supported, false otherwise
     */
    public static Boolean isValidPlanType(String planType) {
        if (String.isBlank(planType)) {
            return false;
        }
        
        // Validate CRUD permissions before querying
        if (!Schema.sObjectType.Product_Information__mdt.isAccessible()) {
            return false;
        }
        
        // Query to check if any record exists with this plan type
        List<Product_Information__mdt> productInfoList = [
            SELECT Id
            FROM Product_Information__mdt
            WHERE Plan_Type__c = :planType
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        
        return !productInfoList.isEmpty();
    }
    
    /**
     * Validates if a country code is supported by checking if any metadata record exists
     * 
     * @param country The country code to validate
     * @return True if the country is supported, false otherwise
     */
    public static Boolean isValidCountry(String country) {
        if (String.isBlank(country)) {
            return false;
        }
        
        // Validate CRUD permissions before querying
        if (!Schema.sObjectType.Product_Information__mdt.isAccessible()) {
            return false;
        }
        
        // Query to check if any record exists with this country
        List<Product_Information__mdt> productInfoList = [
            SELECT Id
            FROM Product_Information__mdt
            WHERE Country__c = :country
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        
        return !productInfoList.isEmpty();
    }
}

