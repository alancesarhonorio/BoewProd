import { LightningElement, track, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { deleteRecord, createRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LightningConfirm from "lightning/confirm";
import { NavigationMixin } from "lightning/navigation";

import getScheduleList from '@salesforce/apex/ConfiguracaoRoteamentoService.getScheduleList';
import getAvailableSalesUsersList from '@salesforce/apex/UserService.getAvailableSalesUsersList';

import SCHEDULING_OBJECT from '@salesforce/schema/RoutingSettings__c.Data__c';
import DATE_FIELD from '@salesforce/schema/RoutingSettings__c.Data__c';
import USER_FIELD from '@salesforce/schema/RoutingSettings__c.Usuario__c';

// const schedulingCreationFields = [DATE_FIELD, USER_FIELD];

export default class SearchDaySchedule extends NavigationMixin(LightningElement) {
    @track selectedDate;
    @track schedule;
    todayDate = new Date().toISOString().split('T')[0];
    _wiredScheduleData;
    _wiredAvailableUserData;
    selectedUser;
    selectedUserToAdd;
    users;
    options=[];

    @wire(getAvailableSalesUsersList, { dtText: '$selectedDate' })
    wiredAvailableUsers(wireResult){
        const { error, data } = wireResult;
        this._wiredAvailableUserData = wireResult;
        if (data) {
            
            this.users = data;
            this.options = this.users.map(user => {
                return { label: user.Name, value: user.Id };
            });
            // console.log(this.options)
        } else if (error) {
            console.error('Error fetching schedule:', error);
            // Consider showing an error message to the user
        }
    }

    handleUserComboboxChange(event){
        this.selectedUserToAdd = event.detail.value;
    }

    async handleButtonClick(event){
        const fields = {};
        fields[DATE_FIELD.fieldApiName] = this.selectedDate;
        fields[USER_FIELD.fieldApiName] = this.selectedUserToAdd;
        const recordInput = { apiName: SCHEDULING_OBJECT.objectApiName, fields };
        try {
            const sch = await createRecord(recordInput);
            await refreshApex(this._wiredScheduleData);
            await refreshApex(this._wiredAvailableUserData);
            // this.accountId = account.id;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Successo',
                    message: 'Adicionado',
                    variant: 'success'
                })
            );
        } catch (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error creating record',
                    message: reduceErrors(error).join(', '),
                    variant: 'error'
                })
            );
        }
    }

    handleDateChange(event) {
        this.selectedDate = event.target.value;
        this.fetchData();
    }

    @wire(getScheduleList, { dtText: '$selectedDate' })
    wiredScheduleList(wireResult) {
        const { error, data } = wireResult;
        this._wiredScheduleData = wireResult;
        if (data) {
            this.schedule = data;
        } else if (error) {
            console.error('Error fetching schedule:', error);
            // Consider showing an error message to the user
        }
    }

    get disableAddSalespersonButton(){
        return !(this.selectedDate && (this.todayDate <= this.selectedDate));
    }

    // navigateToUserPage(recordId) {
    //     // Navegar para a página do Usuário.
    //     this[NavigationMixin.GenerateUrl]({
    //         type: "standard__recordPage",
    //         attributes: {
    //             recordId: recordId,
    //             objectApiName: "User"
    //         },
    //     }).then(url => {
    //         console.log(url);
    //         window.open(url, "_blank");
    //     });;
    // }

    handleSelect(event) {
        const userId = event.detail;
        this[NavigationMixin.Navigate]({
            type: "standard__recordPage",
            attributes: {
              recordId: userId,
              objectApiName: "User", // objectApiName is optional
              actionName: "view",
            },
          });
    }

    async handleDelete(event){
        const uid = event.target.dataset.id;
        try {
            // Abre um modal de confirmacao
            const result = await LightningConfirm.open({
                message: "Tem certeza que quer remover o usuário do dia?",
                variant: "default", // opcao de variacao no cebecalho. (default; headerless)
                label: "Confirmar"
            });
            if (result) {
                // Funcao de deletar registro via UI
                deleteRecord(uid).then(()=>{
                    // fetchData();
                    refreshApex(this._wiredScheduleData);
                    refreshApex(this._wiredAvailableUserData);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Successo',
                            message: 'Usuário removido',
                            variant: 'success'
                        })
                    );
                });
                
            }
        } catch(e) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Erro ao deletar registro',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        }
    }

    fetchData() {
        
        if (this.selectedDate) {
            getScheduleList({ dtText: this.selectedDate });
        } else {
            this.schedule = []; // Clear the list if the date is empty
        }
    }
}