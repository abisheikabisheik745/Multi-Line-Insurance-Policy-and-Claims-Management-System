import { LightningElement, wire, track } from 'lwc';
// Import the Apex method
import getAssignedClaims from
"@salesforce/apex/ClaimsAdjusterController.getAssignedClaims";
export default class ClaimsDashboardLwc extends LightningElement {
 // List to hold all data retrieved from Apex
 @track allClaims = [];
 // List to display after filtering
 @track visibleClaims = [];
 error;

 // Wire service to call the Apex method
 @wire(getAssignedClaims)
 wiredClaims({ error, data }) {
 if (data) {
 this.allClaims = data;
 this.visibleClaims = data; // Initially display all claims
 this.error = undefined;
 } else if (error) {
 this.error = error;
 this.allClaims = undefined;
 this.visibleClaims = undefined;
 console.error('Error retrieving claims:',
JSON.stringify(error));
 }
 }
 // Client-side filtering logic (Required by M3)
 handleFilterChange(event) {
 const selectedPolicyType = event.target.value;

 if (selectedPolicyType === 'All') {
 this.visibleClaims = this.allClaims;
 } else {
 // Filter claims where policyType matches the selected value
 this.visibleClaims = this.allClaims.filter(claim =>
 claim.policyType === selectedPolicyType
 );
 }
 }
 get policyTypeOptions() {
 // Options for the filter dropdown
 return [
 { label: 'All Policy Types', value: 'All' },
 { label: 'Auto', value: 'Auto' },
 { label: 'Property', value: 'Property' },
 { label: 'Life', value: 'Life' }
 ];
 }
}