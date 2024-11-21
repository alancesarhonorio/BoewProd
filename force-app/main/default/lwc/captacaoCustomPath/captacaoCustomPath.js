import { LightningElement, api, wire } from 'lwc';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';


import getLeadStatus from '@salesforce/apex/LeadService.getLeadStatus';
import motivoPerdaModal from "c/motivoPerdaModal";


import LEAD_OBJECT from '@salesforce/schema/Lead';
import STATUS_FIELD from "@salesforce/schema/Lead.Status";
import ID_FIELD from "@salesforce/schema/Lead.Id";
import MOTIVO_PERDA_FIELD from '@salesforce/schema/Lead.Motivo_de_Perda__c';
import SUBMOTIVO_PERDA_FIELD from '@salesforce/schema/Lead.Submotivo_da_perda__c';
import PAGAMENTO_CAPTACAO_FIELD from '@salesforce/schema/Lead.PagamentoCaptacaoParceiro__c';

export default class CaptacaoCustomPath extends LightningElement {
    
    
    steps = [
        { label: 'Lead Novo', value: 'Lead Novo' },
        { label: 'Contato Iniciado', value: 'Contato Iniciado' },
        { label: 'Em Análise', value: 'Em Qualificação' },
        { label: 'Aguardando Fatura', value: 'Aguardando Fatura' },
        { label: 'Desqualificado', value: 'Desqualificado' },
        { label: 'Convertido', value: 'Convertido' },
    ];

    @api recordId; // ID do Lead no Salesforce
    _wiredLead;
    currentValue;
    selectedStage;
    showCurrentStage = false;
    showCompleteStage = true;
    motivoPerdaOptions;
    submotivoPerdaOptions;
    leadRecordType;
    motivoPerda = '';
    submotivoPerda = '';
    pagamentoCaptacao;
    leadSource;

    @wire(getLeadStatus, { leadId: '$recordId' })
    wiredLeadStatus(wireResult) {
        const { error, data } = wireResult;
        console.log(data);
        this._wiredLead = wireResult;
        if (data) {
            this.currentValue = data.Status;
            this.selectedStage = data.Status;
            this.leadRecordType = data.RecordTypeId;
            this.pagamentoCaptacao = data.pagamentoCaptacao;
            this.leadSource = data.leadSource;
            this.setButtonVisibility(data.Status);
        } else if (error) {
            console.error('Error fetching lead status:', error);
        }
    }

    setButtonVisibility(stepname){
        console.log(stepname);
        if(stepname === 'Convertido' || stepname === 'Aguardando Fatura'){
            this.showCompleteStage = false;
            this.showCurrentStage = false;
            this.selectedStage = undefined;
        }
        else if (this.currentValue === stepname) {
            if(stepname === 'Em Qualificação'){
                this.showCompleteStage = false;
                this.showCurrentStage = false;    
            }else{
                this.showCompleteStage = true
                this.showCurrentStage = false;
            }
        }
        else {
            this.showCompleteStage = false;
            this.showCurrentStage = true;
            this.selectedStage = stepname;
        }
    }


    
    handleStepClick(event) {

        const stepname = event.target.value;
        this.setButtonVisibility(stepname);
    }

    updateRecord(){
        console.log('Selected stage: ',this.selectedStage);
        // console.log(this.selectedStage)
        const fields = {};
        fields[ID_FIELD.fieldApiName] = this.recordId;
        fields[STATUS_FIELD.fieldApiName] = this.selectedStage;
        fields[MOTIVO_PERDA_FIELD.fieldApiName] = this.motivoPerda;
        fields[SUBMOTIVO_PERDA_FIELD.fieldApiName] = this.submotivoPerda;
        fields[PAGAMENTO_CAPTACAO_FIELD.fieldApiName] = this.pagamentoCaptacao;
        console.log(fields);
        const recordInput = { fields };
        updateRecord(recordInput)
        .then(() => {
            this.showCurrentStage = false;
            this.showCompleteStage = true;
            this.motivoPerda = '';
            this.submotivoPerda = '';
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Successo',
                    message: 'Status do lead atualizado',
                    variant: 'success',
                }),
            );
        })
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Erro ao salvar',
                    message: 'Erro ao atualizar lead',
                    variant: 'error',
                }),
            );
        });
    }
    
    handleCurrentUpdate(){
        if(this.currentValue === this.selectedStage){
            return ;
        }
        if(this.selectedStage === 'Desqualificado'){
            console.log('lead source: ',this.leadSource);
            motivoPerdaModal.open({
                motivoPerdaField: MOTIVO_PERDA_FIELD,
                submotivoPerdaField: SUBMOTIVO_PERDA_FIELD,
                recordTypeId: this.leadRecordType,
                leadSource: this.leadSource
            }).then((result) => {
                const {success,motivo, submotivo,pagamentoCaptacao} = result
                if(success){
                    console.log(motivo);
                    this.motivoPerda = motivo;
                    this.submotivoPerda = submotivo;
                    this.pagamentoCaptacao = pagamentoCaptacao;
                    this.updateRecord();
                }
                
            });
        }else{
            this.updateRecord();
        }
    }

    isInLastStep() {
        const [lastElement] = this.steps.slice(-1);
        return this.selectedStage === lastElement.value
    }

    getNextStep() {
        console.log('Função Next Step');
        // Encontra o índice do elemento atual com o valor especificado
        const currentIndex = this.steps.findIndex(step => step.value === this.currentValue);
        console.log('currentIndex: ',currentIndex);
        
        // Verifica se o índice existe e se não é o último elemento
        if (currentIndex !== -1 && currentIndex < this.steps.length - 1) {
            // Retorna o próximo elemento
            console.log('nextStep elemtn: ',this.steps[currentIndex + 1]);
            return this.steps[currentIndex + 1];
        } else {
            // Retorna null se não houver próximo ou se o valor não for encontrado
            return null;
        }
    }


    handleCompleteUpdate(){
        console.log('Current stage: ',this.currentValue);
        const nextStep = this.getNextStep();
        console.log('Next Step: ',nextStep);
        if(nextStep == null){
            return ;
        }
        this.selectedStage = nextStep.value;
        this.currentValue = nextStep.value;
        console.log('Selected next stage: ',this.selectedStage);
        if(this.selectedStage === 'Desqualificado'){
            motivoPerdaModal.open({
                motivoPerdaField: MOTIVO_PERDA_FIELD,
                submotivoPerdaField: SUBMOTIVO_PERDA_FIELD,
                recordTypeId: this.leadRecordType,
                leadSource: this.leadSource,
                size: 'medium'
            }).then((result) => {
                const {success,motivo, submotivo,pagamentoCaptacao} = result
                if(success){
                    console.log(motivo);
                    this.motivoPerda = motivo;
                    this.submotivoPerda = submotivo;
                    this.pagamentoCaptacao = pagamentoCaptacao;
                    this.updateRecord();
                }
            });
        }else{
            this.updateRecord();
        }
        
        this.updateRecord();
    }
}