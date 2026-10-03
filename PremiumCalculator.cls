public class PremiumCalculator {
    public class PremiumInputWrapper {
        @InvocableVariable(required=true)
        public Id policyId;
    }

    @InvocableMethod(label='Calculate Policy Premium' description='Calculates premium based on policy fields (VIN, Model Year, State).')
    public static List<Decimal> calculatePremium(List<PremiumInputWrapper> inputs) {

        List<Decimal> premiumResults = new List<Decimal>();
        Set<Id> policyIds = new Set<Id>();

        for (PremiumInputWrapper input : inputs) {
            if (input.policyId != null) {
                policyIds.add(input.policyId);
            }
        }

        List<Policy__c> policiesToRate = [
            SELECT Id, VIN__c, Model_Year__c, Policy_State__c
            FROM Policy__c
            WHERE Id IN :policyIds
        ];

        for (Policy__c policy : policiesToRate) {
            Decimal basePremium = 1000.00;

            if (policy.Policy_State__c == 'CA') {
                basePremium *= 1.15;
            } else if (policy.Policy_State__c == 'TX') {
                basePremium *= 1.05;
            }

            if (policy.Model_Year__c != null && Integer.valueOf(policy.Model_Year__c) < 2018) {
                basePremium += 100;
            }

            premiumResults.add(basePremium);
        }

        return premiumResults;
    }
}