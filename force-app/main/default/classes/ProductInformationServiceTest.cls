/**
 * Test class for ProductInformationService
 * Tests all product/country combinations and edge cases
 */
@isTest
private class ProductInformationServiceTest {
    
    /**
     * Test Cost per Calendar Month for all product/country combinations
     */
    @isTest
    static void testGetCostPerMonth_AllCombinations() {
        // Test Standard product
        System.assertEquals('€ 0', ProductInformationService.getCostPerMonth('Standard', 'DE'), 'Standard DE should be € 0');
        System.assertEquals('€ 0', ProductInformationService.getCostPerMonth('Standard', 'FR'), 'Standard FR should be € 0');
        System.assertEquals('€ 0', ProductInformationService.getCostPerMonth('Standard', 'ES'), 'Standard ES should be € 0');
        System.assertEquals('€ 0', ProductInformationService.getCostPerMonth('Standard', 'IT'), 'Standard IT should be € 0');
        System.assertEquals('£ 0', ProductInformationService.getCostPerMonth('Standard', 'UK'), 'Standard UK should be £ 0');
        
        // Test Black product
        System.assertEquals('€ 9,90', ProductInformationService.getCostPerMonth('Black', 'DE'), 'Black DE should be € 9,90');
        System.assertEquals('€ 9,90', ProductInformationService.getCostPerMonth('Black', 'FR'), 'Black FR should be € 9,90');
        System.assertEquals('€ 9,90', ProductInformationService.getCostPerMonth('Black', 'ES'), 'Black ES should be € 9,90');
        System.assertEquals('€ 9,90', ProductInformationService.getCostPerMonth('Black', 'IT'), 'Black IT should be € 9,90');
        System.assertEquals('N/a', ProductInformationService.getCostPerMonth('Black', 'UK'), 'Black UK should be N/a');
        
        // Test Metal product
        System.assertEquals('€ 16,90', ProductInformationService.getCostPerMonth('Metal', 'DE'), 'Metal DE should be € 16,90');
        System.assertEquals('€ 16,90', ProductInformationService.getCostPerMonth('Metal', 'FR'), 'Metal FR should be € 16,90');
        System.assertEquals('€ 16,90', ProductInformationService.getCostPerMonth('Metal', 'ES'), 'Metal ES should be € 16,90');
        System.assertEquals('€ 16,90', ProductInformationService.getCostPerMonth('Metal', 'IT'), 'Metal IT should be € 16,90');
        System.assertEquals('N/a', ProductInformationService.getCostPerMonth('Metal', 'UK'), 'Metal UK should be N/a');
    }
    
    /**
     * Test ATM Fee for all product/country combinations
     */
    @isTest
    static void testGetAtmFee_AllCombinations() {
        // Test Standard product
        System.assertEquals('1.7%', ProductInformationService.getAtmFee('Standard', 'DE'), 'Standard DE ATM fee should be 1.7%');
        System.assertEquals('1.7%', ProductInformationService.getAtmFee('Standard', 'FR'), 'Standard FR ATM fee should be 1.7%');
        System.assertEquals('1.7%', ProductInformationService.getAtmFee('Standard', 'ES'), 'Standard ES ATM fee should be 1.7%');
        System.assertEquals('1.7%', ProductInformationService.getAtmFee('Standard', 'IT'), 'Standard IT ATM fee should be 1.7%');
        System.assertEquals('1.7%', ProductInformationService.getAtmFee('Standard', 'UK'), 'Standard UK ATM fee should be 1.7%');
        
        // Test Black product
        System.assertEquals('Free', ProductInformationService.getAtmFee('Black', 'DE'), 'Black DE ATM fee should be Free');
        System.assertEquals('Free', ProductInformationService.getAtmFee('Black', 'FR'), 'Black FR ATM fee should be Free');
        System.assertEquals('Free', ProductInformationService.getAtmFee('Black', 'ES'), 'Black ES ATM fee should be Free');
        System.assertEquals('Free', ProductInformationService.getAtmFee('Black', 'IT'), 'Black IT ATM fee should be Free');
        System.assertEquals('Free', ProductInformationService.getAtmFee('Black', 'UK'), 'Black UK ATM fee should be Free');
        
        // Test Metal product
        System.assertEquals('Free', ProductInformationService.getAtmFee('Metal', 'DE'), 'Metal DE ATM fee should be Free');
        System.assertEquals('Free', ProductInformationService.getAtmFee('Metal', 'FR'), 'Metal FR ATM fee should be Free');
        System.assertEquals('Free', ProductInformationService.getAtmFee('Metal', 'ES'), 'Metal ES ATM fee should be Free');
        System.assertEquals('Free', ProductInformationService.getAtmFee('Metal', 'IT'), 'Metal IT ATM fee should be Free');
        System.assertEquals('Free', ProductInformationService.getAtmFee('Metal', 'UK'), 'Metal UK ATM fee should be Free');
    }
    
    /**
     * Test Card Replacement Cost for all product/country combinations
     */
    @isTest
    static void testGetCardReplacementCost_AllCombinations() {
        // Test Standard product
        System.assertEquals('€ 6', ProductInformationService.getCardReplacementCost('Standard', 'DE'), 'Standard DE card replacement should be € 6');
        System.assertEquals('€ 6', ProductInformationService.getCardReplacementCost('Standard', 'FR'), 'Standard FR card replacement should be € 6');
        System.assertEquals('€ 6', ProductInformationService.getCardReplacementCost('Standard', 'ES'), 'Standard ES card replacement should be € 6');
        System.assertEquals('€ 6', ProductInformationService.getCardReplacementCost('Standard', 'IT'), 'Standard IT card replacement should be € 6');
        System.assertEquals('£ 6', ProductInformationService.getCardReplacementCost('Standard', 'UK'), 'Standard UK card replacement should be £ 6');
        
        // Test Black product
        System.assertEquals('€ 6', ProductInformationService.getCardReplacementCost('Black', 'DE'), 'Black DE card replacement should be € 6');
        System.assertEquals('€ 6', ProductInformationService.getCardReplacementCost('Black', 'FR'), 'Black FR card replacement should be € 6');
        System.assertEquals('€ 6', ProductInformationService.getCardReplacementCost('Black', 'ES'), 'Black ES card replacement should be € 6');
        System.assertEquals('€ 6', ProductInformationService.getCardReplacementCost('Black', 'IT'), 'Black IT card replacement should be € 6');
        System.assertEquals('£ 6', ProductInformationService.getCardReplacementCost('Black', 'UK'), 'Black UK card replacement should be £ 6');
        
        // Test Metal product
        System.assertEquals('€ 45', ProductInformationService.getCardReplacementCost('Metal', 'DE'), 'Metal DE card replacement should be € 45');
        System.assertEquals('€ 45', ProductInformationService.getCardReplacementCost('Metal', 'FR'), 'Metal FR card replacement should be € 45');
        System.assertEquals('€ 45', ProductInformationService.getCardReplacementCost('Metal', 'ES'), 'Metal ES card replacement should be € 45');
        System.assertEquals('€ 45', ProductInformationService.getCardReplacementCost('Metal', 'IT'), 'Metal IT card replacement should be € 45');
        System.assertEquals('£ 45', ProductInformationService.getCardReplacementCost('Metal', 'UK'), 'Metal UK card replacement should be £ 45');
    }
    
    /**
     * Test getProductInformation method returns all three values
     */
    @isTest
    static void testGetProductInformation_ReturnsAllValues() {
        Map<String, String> productInfo = ProductInformationService.getProductInformation('Standard', 'DE');
        
        System.assertNotEquals(null, productInfo, 'Product information should not be null');
        System.assertEquals('€ 0', productInfo.get('costPerMonth'), 'Cost per month should match');
        System.assertEquals('1.7%', productInfo.get('atmFee'), 'ATM fee should match');
        System.assertEquals('€ 6', productInfo.get('cardReplacementCost'), 'Card replacement cost should match');
    }
    
    /**
     * Test edge case: null product
     */
    @isTest
    static void testGetCostPerMonth_NullProduct() {
        System.assertEquals(null, ProductInformationService.getCostPerMonth(null, 'DE'), 'Null product should return null');
    }
    
    /**
     * Test edge case: null country
     */
    @isTest
    static void testGetCostPerMonth_NullCountry() {
        System.assertEquals(null, ProductInformationService.getCostPerMonth('Standard', null), 'Null country should return null');
    }
    
    /**
     * Test edge case: blank product
     */
    @isTest
    static void testGetCostPerMonth_BlankProduct() {
        System.assertEquals(null, ProductInformationService.getCostPerMonth('', 'DE'), 'Blank product should return null');
    }
    
    /**
     * Test edge case: blank country
     */
    @isTest
    static void testGetCostPerMonth_BlankCountry() {
        System.assertEquals(null, ProductInformationService.getCostPerMonth('Standard', ''), 'Blank country should return null');
    }
    
    /**
     * Test edge case: invalid product
     */
    @isTest
    static void testGetCostPerMonth_InvalidProduct() {
        System.assertEquals(null, ProductInformationService.getCostPerMonth('InvalidProduct', 'DE'), 'Invalid product should return null');
    }
    
    /**
     * Test edge case: invalid country
     */
    @isTest
    static void testGetCostPerMonth_InvalidCountry() {
        System.assertEquals(null, ProductInformationService.getCostPerMonth('Standard', 'XX'), 'Invalid country should return null');
    }
    
    /**
     * Test isValidProduct method
     */
    @isTest
    static void testIsValidProduct() {
        System.assertEquals(true, ProductInformationService.isValidProduct('Standard'), 'Standard should be valid');
        System.assertEquals(true, ProductInformationService.isValidProduct('Black'), 'Black should be valid');
        System.assertEquals(true, ProductInformationService.isValidProduct('Metal'), 'Metal should be valid');
        System.assertEquals(false, ProductInformationService.isValidProduct('Invalid'), 'Invalid product should be false');
        System.assertEquals(false, ProductInformationService.isValidProduct(null), 'Null product should be false');
    }
    
    /**
     * Test isValidCountry method
     */
    @isTest
    static void testIsValidCountry() {
        System.assertEquals(true, ProductInformationService.isValidCountry('DE'), 'DE should be valid');
        System.assertEquals(true, ProductInformationService.isValidCountry('FR'), 'FR should be valid');
        System.assertEquals(true, ProductInformationService.isValidCountry('ES'), 'ES should be valid');
        System.assertEquals(true, ProductInformationService.isValidCountry('IT'), 'IT should be valid');
        System.assertEquals(true, ProductInformationService.isValidCountry('UK'), 'UK should be valid');
        System.assertEquals(false, ProductInformationService.isValidCountry('XX'), 'Invalid country should be false');
        System.assertEquals(false, ProductInformationService.isValidCountry(null), 'Null country should be false');
        System.assertEquals(false, ProductInformationService.isValidCountry(''), 'Blank country should be false');
    }
    
    /**
     * Test N/a values are handled correctly (Black/Metal UK for cost per month)
     */
    @isTest
    static void testN_aValues() {
        System.assertEquals('N/a', ProductInformationService.getCostPerMonth('Black', 'UK'), 'Black UK should return N/a');
        System.assertEquals('N/a', ProductInformationService.getCostPerMonth('Metal', 'UK'), 'Metal UK should return N/a');
    }
}

