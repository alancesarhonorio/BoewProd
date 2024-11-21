import { LightningElement, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getWeekdayScheduleList from '@salesforce/apex/ConfiguracaoRoteamentoService.getWeekdayScheduleList';
import updateSchedulingData from '@salesforce/apex/ConfiguracaoRoteamentoService.updateSchedulingData';
import removeNextSchedulingData from '@salesforce/apex/ConfiguracaoRoteamentoService.removeNextSchedulingData';
import autoCreateNextDays from '@salesforce/apex/AutoCreateRoutingSettings.autoCreateNextDaysLWC';

const columns = [
    { label: 'Usuário', fieldName: 'userName', type:'text'},
    { label: 'Segunda-feira', fieldName: 'Monday', type: 'boolean', editable: true },
    { label: 'Terça-feira', fieldName: 'Tuesday', type: 'boolean', editable: true },
    { label: 'Quarta-feira', fieldName: 'Wednesday', type: 'boolean', editable: true },
    { label: 'Quinta-feira', fieldName: 'Thursday', type: 'boolean', editable: true },
    { label: 'Sexta-feira', fieldName: 'Friday', type: 'boolean', editable: true },
    { label: 'Sábado', fieldName: 'Saturday', type: 'boolean', editable: true },
    { label: 'Domingo', fieldName: 'Sunday', type: 'boolean', editable: true }
];

export default class WeekdaySchedulerManager extends LightningElement {
    columns = columns;
    routingSettingsData;
    _wiredScheduleData;
    draftValues = [];

    @wire(getWeekdayScheduleList)
    wiredWeekdayScheduleList(wireResult) {
        const { error, data } = wireResult;
        this._wiredScheduleData = wireResult;
        console.log(data);
        if (data) {
            this.routingSettingsData = this.mapData(data);
        } else if (error) {
            console.error(error);
        }
    }

    mapData(data) {
        let mappedData = [];
        let userMap = new Map();
        
        data.forEach(setting => {
            let userId = setting.Usuario__r.Id;
            if (!userMap.has(userId)) {
                userMap.set(userId, {
                    Id: userId,
                    userName: setting.Usuario__r.Name,
                    Monday: false,
                    Tuesday: false,
                    Wednesday: false,
                    Thursday: false,
                    Friday: false,
                    Saturday: false,
                    Sunday: false
                });
            }
            
            let userRow = userMap.get(userId);
            switch (setting.weekdayRouting__c) {
                case 'Segunda-feira':
                    userRow.Monday = true;
                    break;
                case 'Terça-feira':
                    userRow.Tuesday = true;
                    break;
                case 'Quarta-feira':
                    userRow.Wednesday = true;
                    break;
                case 'Quinta-feira':
                    userRow.Thursday = true;
                    break;
                case 'Sexta-feira':
                    userRow.Friday = true;
                    break;
                case 'Sábado':
                    userRow.Saturday = true;
                    break;
                case 'Domingo':
                    userRow.Sunday = true;
                    break;
                default:
                    break;
            }
        });
        mappedData = Array.from(userMap.values());
        return mappedData;
    }


    async handleSave(event) {
        const updatedFields = event.detail.draftValues;
        console.log(updatedFields);
        // Limpa valores de rascunho
        this.draftValues = [];

        let dataToRemove = [];
        let dataToAdd = [];

        updatedFields.forEach(ele=>{
            if(ele.Monday != null){
                ele.Monday == true ? dataToAdd.push('Segunda-feira'+'_'+ele.Id) : dataToRemove.push('Segunda-feira'+'_'+ele.Id);
            }
            if(ele.Tuesday != null){
                ele.Tuesday == true ? dataToAdd.push('Terça-feira'+'_'+ele.Id) : dataToRemove.push('Terça-feira'+'_'+ele.Id);
            }
            if(ele.Wednesday != null){
                ele.Wednesday == true ? dataToAdd.push('Quarta-feira'+'_'+ele.Id) : dataToRemove.push('Quarta-feira'+'_'+ele.Id);
            }
            if(ele.Thursday != null){
                ele.Thursday == true ? dataToAdd.push('Quinta-feira'+'_'+ele.Id) : dataToRemove.push('Quinta-feira'+'_'+ele.Id);
            }
            if(ele.Friday != null){
                ele.Friday == true ? dataToAdd.push('Sexta-feira'+'_'+ele.Id) : dataToRemove.push('Sexta-feira'+'_'+ele.Id);
            }
            if(ele.Saturday != null){
                ele.Saturday == true ? dataToAdd.push('Sábado'+'_'+ele.Id) : dataToRemove.push('Sábado'+'_'+ele.Id);
            }
            if(ele.Sunday != null){
                ele.Sunday == true ? dataToAdd.push('Domingo'+'_'+ele.Id) : dataToRemove.push('Domingo'+'_'+ele.Id);
            }
            
        })

        try {
            // Chama a classe auxiliar de servico apex para atualizar o scheduler
            console.log(dataToRemove);
            await updateSchedulingData({ usersToAdd: dataToAdd , usersToRemove: dataToRemove});
            await autoCreateNextDays();
            await removeNextSchedulingData({ usersToRemove: dataToRemove });

            // Caso seja atualizada, indica sucesso com um toast
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Successo',
                    message: 'Calendário semanal atualizado com sucesso',
                    variant: 'success'
                })
            );

            // Atualiza tabela com novos valores
            await refreshApex(this._wiredScheduleData);
        } catch (error) {
            // Em caso de erro, indica o erro em um toast
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Erro ao atualizar ou recarregar registros',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        }
    }

    async handleCancel(event) {
        this.data = JSON.parse(JSON.stringify(this.lastSavedData));
        this.draftValues = [];
    }

}