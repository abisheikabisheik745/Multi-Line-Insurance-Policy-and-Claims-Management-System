public class ClaimsAdjusterController {
 public class ClaimWrapper {
 @AuraEnabled public Id claimId;
 @AuraEnabled public String claimNumber;
 @AuraEnabled public Decimal claimAmount;
 @AuraEnabled public String status;
 @AuraEnabled public String policyType;
 @AuraEnabled public String policyHolderName;
 @AuraEnabled public Integer daysOpen;
 public ClaimWrapper(Claim__c c, Policy__c p, Contact customerRec) {
 this.claimId = c.Id;
 this.claimNumber = c.Name;
 this.claimAmount = c.Claim_Amount__c;
 this.status = c.Approval_Status__c;

 Policy__c policyRecord = (Policy__c)p;
 if (policyRecord != null && policyRecord.RecordType != null) {
 this.policyType = policyRecord.RecordType.Name;
 } else {
 this.policyType = 'Unknown';
 }
 this.policyHolderName = (customerRec != null) ? customerRec.Name : '';

 this.daysOpen = (c.Date_of_Loss__c != null)
 ? (Date.today().daysBetween(c.Date_of_Loss__c.date()))
 : 0;
 }
 }
 @AuraEnabled(cacheable=true)
 public static List<ClaimWrapper> getAssignedClaims() {

 List<ClaimWrapper> results = new List<ClaimWrapper>();

 List<Claim__c> claims = [
 SELECT
 Id, Name, Claim_Amount__c, Approval_Status__c, Date_of_Loss__c,
 Policy__r.Name,
 Policy__r.RecordType.DeveloperName,
 Policy__r.Customer__r.FirstName,
 Policy__r.Customer__r.LastName
 FROM Claim__c
 WHERE OwnerId = :UserInfo.getUserId()
 ORDER BY Date_of_Loss__c DESC
 ];
 for (Claim__c claim : claims) {

 Policy__c policy = claim.Policy__r;

 Contact customer = (policy != null && policy.Customer__r != null)
 ? (Contact)policy.Customer__r
 : new Contact();

 results.add(new ClaimWrapper(claim, policy, customer));
 }
 return results;
 }
}