import { LightningElement, api } from 'lwc';
export default class ClaimTileLwc extends LightningElement {
 // @api decorator exposes this property to the parent component
 @api claimData;
 // Helper property to determine the correct icon based on Policy Type
 get policyIcon() {
 if (this.claimData && this.claimData.policyType) {
 const type = this.claimData.policyType.toLowerCase();
 if (type === 'auto') return 'utility:truck';
 if (type === 'property') return 'utility:home';
 if (type === 'life') return 'utility:connected_apps';
 }
 return 'utility:help';
 }
}