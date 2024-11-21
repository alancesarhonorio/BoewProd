import { LightningElement, api, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { RefreshEvent } from 'lightning/refresh';


import getLeadStatus from '@salesforce/apex/LeadService.getLeadStatus';


import {
    subscribe,
    unsubscribe,
    onError,
    setDebugFlag,
    isEmpEnabled,
} from 'lightning/empApi';

export default class LeadStatusComponent extends LightningElement {
    channelName = '/event/Cadastro_no_sistema_Bow_e__e';
    
    @api recordId; // ID do Lead no Salesforce
    proposalNumber;
    isRegistered = false;
    errorMessage = '';
    showDetails = false;
    status = '';
    _wiredLead;
    subscription = {};

    get statusIconName() {
        if(this.status == 'Cadastrando'){
            return 'utility:sync'
        }else if(this.status == 'Cadastrado'){
            return 'utility:check'
        }else{
            return 'utility:error'
        }
    }

    get statusIconAltText() {
        if(this.status == 'Cadastrando'){
            return 'Em processo de sincronização'
        }else if(this.status == 'Cadastrado'){
            return 'Sincronizado com sucesso'
        }else{
            return 'Erro na sincronização'
        }
    }

    @wire(getLeadStatus, { leadId: '$recordId' })
    wiredLeadStatus(wireResult) {
        const { error, data } = wireResult;
        this._wiredLead = wireResult;
        if (data) {
            this.proposalNumber = data.proposalNumber;
            this.isRegistered = data.isRegistered;
            this.status = data.isRegistered ? 'Cadastrado' : 'Erro na sincronização';
            this.errorMessage = data.errorMessage;
            this.proposalLink = 'https://bow-e.com/propostas/'+data.guid;
        } else if (error) {
            console.error('Error fetching lead status:', error);
        }
    }

    handleShowDetails() {
        this.showDetails = !this.showDetails;
    }



    // Initializes the component
    connectedCallback() {
        this.handleSubscribe();
        // Register error listener
        this.registerErrorListener();
    }

    // Handles subscribe button click
    handleSubscribe() {
        // Callback invoked whenever a new event message is received
        const messageCallback = (response) => {
            this.handleEventResponse(response);
            // Response contains the payload of the new message received
        };

        // Invoke subscribe method of empApi. Pass reference to messageCallback
        subscribe(this.channelName, -1, messageCallback).then((response) => {
            // Response contains the subscription information on subscribe call
            console.log(
                'Subscription request sent to: ',
                JSON.stringify(response.channel)
            );
            this.subscription = response;
            // this.toggleSubscribeButton(true);
        });
    }

    async handleEventResponse(response){
        console.log('New message received: ', JSON.stringify(response));
        if(response.hasOwnProperty("data")){
            let jsonObj = response.data;
            if(jsonObj.hasOwnProperty("payload")){
                let recordId = response.data.payload.Record_Id__c;
                let leadStatus = response.data.payload.Status__c;
                let error = response.data.payload.Log_de_erro__c;
                if(recordId == this.recordId){
                    console.log('recordId matched');
                    this.status=leadStatus;
                    this.errorMessage = error;
                    await refreshApex(this._wiredLead);
                    this.dispatchEvent(new RefreshEvent());
                }
            }
        }
    }

    disconnectedCallback(){
        
        // Invoke unsubscribe method of empApi
        unsubscribe(this.subscription, (response) => {
            console.log('unsubscribe() response: ', JSON.stringify(response));
            // Response is true for successful unsubscribe
        });
    }

    registerErrorListener() {
        // Invoke onError empApi method
        onError((error) => {
            console.log('Received error from server: ', JSON.stringify(error));
            // Error contains the server-side error
        });
    }
}