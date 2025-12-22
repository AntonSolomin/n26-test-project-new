/**
 * Service class to retrieve product pricing information based on Product__c and Country__c
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
    
    // Cache for product information metadata to avoid repeated queries for the same product and country
    private static Map<String, Product_Information__mdt> productInfoCache;
    
    /**
     * Validates field-level access permissions for Product Information metadata fields
     * 
     * @return True if all required fields are accessible, false otherwise
     */
    private static Boolean hasValidFieldPermissions() {
        Map<String, Schema.SObjectField> fieldMap = Schema.sObjectType.Product_Information__mdt.fields.getMap();
        return fieldMap.get('Product__c').getDescribe().isAccessible() &&
            fieldMap.get('Country__c').getDescribe().isAccessible() &&
            fieldMap.get('Cost_Per_Month__c').getDescribe().isAccessible() &&
            fieldMap.get('ATM_Fee__c').getDescribe().isAccessible() &&
            fieldMap.get('Card_Replacement_Cost__c').getDescribe().isAccessible();
    }
    
    /**
     * Retrieves a product information metadata record for the given product and country
     * Queries metadata directly by Country and Product instead of loading all records
     * 
     * @param product The product name (Standard, Black, Metal)
     * @param country The home country code (DE, FR, ES, IT, UK)
     * @return The Product_Information__mdt record, or null if not found
     */
    private static Product_Information__mdt getProductInfoRecord(String product, String country) {
        if (String.isBlank(product) || String.isBlank(country)) {
            return null;
        }
        
        // Create cache key
        String cacheKey = product + '_' + country;
        
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
        
        // Query metadata by Country and Product only
        List<Product_Information__mdt> productInfoList = [
            SELECT Product__c, Country__c, Cost_Per_Month__c, ATM_Fee__c, Card_Replacement_Cost__c
            FROM Product_Information__mdt
            WHERE Country__c = :country AND Product__c = :product
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
     * Formats a currency value based on the country code
     * 
     * @param value The numeric currency value
     * @param country The country code (DE, FR, ES, IT, UK)
     * @return Formatted currency string (e.g., "€ 9,90" or "£ 6.00")
     */
    private static String formatCurrency(Decimal value, String country) {
        if (value == null) {
            return 'N/a';
        }
        
        String currencySymbol = (country == 'UK') ? '£' : '€';
        String formattedValue;
        
        if (country == 'UK') {
            // UK uses period as decimal separator
            formattedValue = String.valueOf(value.setScale(2));
            // Remove trailing zeros if it's a whole number
            if (formattedValue.endsWith('.00')) {
                formattedValue = formattedValue.substring(0, formattedValue.length() - 3);
            }
            return currencySymbol + ' ' + formattedValue;
        } else {
            // European countries use comma as decimal separator
            formattedValue = String.valueOf(value.setScale(2));
            formattedValue = formattedValue.replace('.', ',');
            // Remove trailing zeros if it's a whole number
            if (formattedValue.endsWith(',00')) {
                formattedValue = formattedValue.substring(0, formattedValue.length() - 3);
            }
            return currencySymbol + ' ' + formattedValue;
        }
    }
    
    /**
     * Formats an ATM fee percentage value
     * 
     * @param value The numeric percentage value (e.g., 1.7 for 1.7%)
     * @return Formatted percentage string (e.g., "1.7%" or "Free" for 0)
     */
    private static String formatAtmFee(Decimal value) {
        if (value == null || value == 0) {
            return 'Free';
        }
        return String.valueOf(value.setScale(1)) + '%';
    }
    
    /**
     * Retrieves the cost per calendar month for a given product and country
     * 
     * @param product The product name (Standard, Black, Metal)
     * @param country The home country code (DE, FR, ES, IT, UK)
     * @return The cost per month as a string (e.g., "€ 9,90" or "N/a")
     */
    public static String getCostPerMonth(String product, String country) {
        Product_Information__mdt productInfo = getProductInfoRecord(product, country);
        if (productInfo == null) {
            return null;
        }
        return formatCurrency(productInfo.Cost_Per_Month__c, country);
    }
    
    /**
     * Retrieves the ATM fee in other currencies for a given product and country
     * 
     * @param product The product name (Standard, Black, Metal)
     * @param country The home country code (DE, FR, ES, IT, UK)
     * @return The ATM fee as a string (e.g., "1.7%" or "Free")
     */
    public static String getAtmFee(String product, String country) {
        Product_Information__mdt productInfo = getProductInfoRecord(product, country);
        if (productInfo == null) {
            return null;
        }
        return formatAtmFee(productInfo.ATM_Fee__c);
    }
    
    /**
     * Retrieves the card replacement cost for a given product and country
     * 
     * @param product The product name (Standard, Black, Metal)
     * @param country The home country code (DE, FR, ES, IT, UK)
     * @return The card replacement cost as a string (e.g., "€ 6" or "£ 45")
     */
    public static String getCardReplacementCost(String product, String country) {
        Product_Information__mdt productInfo = getProductInfoRecord(product, country);
        if (productInfo == null) {
            return null;
        }
        return formatCurrency(productInfo.Card_Replacement_Cost__c, country);
    }
    
    /**
     * Retrieves all product information for a given product and country
     * 
     * @param product The product name (Standard, Black, Metal)
     * @param country The home country code (DE, FR, ES, IT, UK)
     * @return A map containing all product information keys: costPerMonth, atmFee, cardReplacementCost
     */
    public static Map<String, String> getProductInformation(String product, String country) {
        Map<String, String> productInfo = new Map<String, String>();
        
        productInfo.put('costPerMonth', getCostPerMonth(product, country));
        productInfo.put('atmFee', getAtmFee(product, country));
        productInfo.put('cardReplacementCost', getCardReplacementCost(product, country));
        
        return productInfo;
    }
    
    /**
     * Validates if a product is supported by checking if any metadata record exists
     * 
     * @param product The product name to validate
     * @return True if the product is supported, false otherwise
     */
    public static Boolean isValidProduct(String product) {
        if (String.isBlank(product)) {
            return false;
        }
        
        // Validate CRUD permissions before querying
        if (!Schema.sObjectType.Product_Information__mdt.isAccessible()) {
            return false;
        }
        
        // Query to check if any record exists with this product
        List<Product_Information__mdt> productInfoList = [
            SELECT Id
            FROM Product_Information__mdt
            WHERE Product__c = :product
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

