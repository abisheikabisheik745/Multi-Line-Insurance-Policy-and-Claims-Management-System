@isTest
private class ClaimsAdjusterControllerTest {
 @testSetup
 static void setupTestData() {
 // Create a real active test user
 Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard
User' LIMIT 1];
 User u = new User(
 FirstName = 'Test',
 LastName = 'User',
 Alias = 'tuser',
 Username = 'testuser1234343@example.com.test',
 Email = 'testuser123@example.com',
 TimeZoneSidKey = 'America/Los_Angeles',
 LocaleSidKey = 'en_US',
 EmailEncodingKey = 'UTF-8',
 LanguageLocaleKey = 'en_US',
 ProfileId = p.Id
 );
 insert u;
 // Query Policy__c RecordType
 Id policyRT =
Schema.SObjectType.Policy__c.getRecordTypeInfosByDeveloperName()
 .get('Auto')
 .getRecordTypeId();
 Id claimRT =
Schema.SObjectType.Claim__c.getRecordTypeInfosByDeveloperName()
 .get('Accident')
 .getRecordTypeId();
 // Create Contact owned by same user
 Contact con = new Contact(
 FirstName = 'John',
 LastName = 'Doe',
 OwnerId = u.Id
 );
 insert con;
 // Create Policy owned by same user
 Policy__c policy = new Policy__c(
 Customer__c = con.Id,
 RecordTypeId = policyRT,
 OwnerId = u.Id,
 VIN__c = '1A903284375893532'
 );
 insert policy;
 // Create Claim owned by same user
 Claim__c claim = new Claim__c(
 Policy__c = policy.Id,
 RecordTypeId = claimRT,
 Claim_Amount__c = 5000,
 Date_of_Loss__c = Date.today().addDays(-10),
 OwnerId = u.Id
 );
 insert claim;
 System.debug('Claim inserted: '+claim.Id);
 }
 @isTest
 static void testGetAssignedClaims() {
 User u = [SELECT Id FROM User WHERE Alias = 'tuser' LIMIT 1];
 System.runAs(u) {
 Test.startTest();
 List<ClaimsAdjusterController.ClaimWrapper> results =
 ClaimsAdjusterController.getAssignedClaims();
 System.debug('Result is: '+results);
 Test.stopTest();
 //System.assert(results.size() > 0,
 //'Expected at least one wrapper returned');
 ClaimsAdjusterController.ClaimWrapper wrap = results[0];
 System.assertNotEquals(null, wrap.claimId);
 System.assertNotEquals(null, wrap.claimNumber);
 System.assertEquals('New', wrap.status);
 System.assertEquals(5000, wrap.claimAmount);
 System.assert(wrap.policyHolderName.contains('John'));
 System.assertNotEquals('Unknown', wrap.policyType);
 }
 }
}