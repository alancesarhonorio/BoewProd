import { api, wire } from 'lwc';
import LightningModal from 'lightning/modal';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';

export default class MotivoPerdaModal extends LightningModal {
    
    // formData is utilized for saving current form values
    @api motivoPerdaField;
    @api submotivoPerdaField;
    @api recordTypeId;
    @api leadSource
    
    
    motivoPerda = [];
    subMotivoPerda = [];
    motivoSelected;
    submotivoSelected;
    
    formData = {};
    failureType = null;
    saveStatus = {};
    saveInProcess = false;
    pagamentoCaptacaoSelected = false;

    @wire(getPicklistValues, {recordTypeId: '$recordTypeId', fieldApiName: '$motivoPerdaField' })
    motivoPerdaFieldInfo({ data, error }) {
        console.log(data);
        if (data) {
            this.motivoPerda = data.values;
        } else if (error) {
            console.error('Error fetching lead motivo de perda:', error);
        }
    }

    @wire(getPicklistValues, {recordTypeId: '$recordTypeId', fieldApiName: '$submotivoPerdaField' })
    submotivoPerdaFieldInfo({ data, error }) {
        console.log(data);
        if (data) {
            this.subMotivoPerda = data;
        } else if (error) {
            console.error('Error fetching lead submotivo de perda:', error);
        }
    }



    handleMotivoChange(event) {
        this.motivoSelected = event.target.value;
        this.submotivoSelected = undefined;
    }

    get submotivoOptions(){
        if (this.subMotivoPerda && this.motivoSelected) {
            return this.setDependentPicklist(this.subMotivoPerda, this.motivoSelected);
        }
    }

    setDependentPicklist(data, controllerValue) {
        const key = data.controllerValues[controllerValue];
        return data.values.filter((opt) => opt.validFor.includes(key));
    }

    get submotivoOptionsIsEmpty() {
        const options = this.submotivoOptions;
        console.log(options);
        return !options || options.length === 0;
    }

    get isCaptacaoParceiro(){
        return this.leadSource === 'Captação Parceiro';
    }

    toggleCaptacaoParceiro(event) {
        this.pagamentoCaptacaoSelected = event.target.checked;
    }

    handleSubmotivoChange(event){
       this.submotivoSelected = event.target.value;
       this[event.target.name] = event.target.value;
    }
    closeModal() {
        this.close('success');
    }

    handleSaveClick(event) {
        let eventdetail = {success: true, motivo: this.motivoSelected, submotivo: this.submotivoSelected, pagamentoCaptacao: this.pagamentoCaptacaoSelected}
        this.close(eventdetail);
    }

    handleCloseClick() {
        let eventdetail = {success: false}
        this.close(eventdetail);
    }
}