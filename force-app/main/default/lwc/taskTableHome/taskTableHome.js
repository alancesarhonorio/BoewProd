import { LightningElement, wire, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';

import getUserTasks from '@salesforce/apex/TaskController.getUserTasks';
import updateTaskStatus from '@salesforce/apex/TaskController.updateTaskStatus';

import cadencePermSet from '@salesforce/customPermission/acessoCadenciaLeads';
import motivoPerdaModal from "c/motivoPerdaModal";

import LEAD_OBJECT from '@salesforce/schema/Lead';
import MOTIVO_PERDA_FIELD from '@salesforce/schema/Lead.Motivo_de_Perda__c';
import SUBMOTIVO_PERDA_FIELD from '@salesforce/schema/Lead.Submotivo_da_perda__c';

export default class TaskTableHome extends NavigationMixin(LightningElement) {
    @track tasks = [];
    @track selectedTasks = [];
    @track isDialogVisible = false;
    @track approvalStatus = '';
    @track showLoadingSpinner = false;
    wiredTasksResult;
    defeaultLeadRecordTypeId;
    motivoPerda = '';
    submotivoPerda = '';
    pagamentoCaptacao = false;

    @wire(getUserTasks)
    wiredTasks(result) {
        this.wiredTasksResult = result;
        const { data, error } = result;

        this.showLoadingSpinner = true;

        if (data) {
            this.tasks = data.map(task => ({
                ...task,
                leadUrl: `/lightning/r/Lead/${task.whoId}/view`,
                taskUrl: `/lightning/r/Task/${task.id}/view`,
                isSelected: false, // Adiciona o campo isSelected para controle
            }));
            this.showLoadingSpinner = false;
            this.totalTasks = this.tasks.length;
            this.updateSelectedTasks();
        } else if (error) {
            console.error('Erro ao buscar tarefas: ', error);
            this.showToast('Erro', 'Erro ao carregar as tarefas: ' + error);
            this.showLoadingSpinner = false;
        }
    }

    @wire(getObjectInfo, { objectApiName: LEAD_OBJECT })
    objectInfo({ error, data }) {
        if (data) {
            // Find the Record Type ID based on the record type name (DeveloperName)
            const recordTypes = data.recordTypeInfos;
            const recordTypeInfo = Object.values(recordTypes).find(rt => rt.name === 'Captação');
            if (recordTypeInfo) {
                this.defeaultLeadRecordTypeId = recordTypeInfo.recordTypeId;
                console.log('Record Type ID:', this.defeaultLeadRecordTypeId);
            }
        } else if (error) {
            console.error('Error fetching object info:', error);
        }
    }

    updateSelectedTasks() {
        this.selectedTasks = this.tasks.filter(task => task.isSelected).map(task => task.id);
    }

    get isTaskSelected() {
        return this.tasks.map(task => ({
            ...task,
            isSelected: this.selectedTasks.includes(task.id),
        }));
    }

    get isAllSelected() {
        return this.tasks && this.tasks.length > 0 && this.selectedTasks.length === this.tasks.length;
    }

    get isApproveButtonDisabled() {
        return this.selectedTasks && this.selectedTasks.length === 0;
    }

    get hasAcessToCadence() {
        return cadencePermSet;
    }

    reloadRecords() {
        this.showLoadingSpinner = true;
        if (this.wiredTasksResult) {
            refreshApex(this.wiredTasksResult)
                .then(() => {
                    // Limpa a seleção de todas as tarefas ao atualizar
                    this.tasks = this.tasks.map(task => ({ ...task, isSelected: false }));
                    this.selectedTasks = [];
                })
                .catch((error) => {
                    console.error('Erro ao recarregar registros:', error);
                    this.showToast('Erro', 'Erro ao recarregar registros', 'error');
                })
                .finally(() => {
                    this.showLoadingSpinner = false;
                });
        } else {
            this.showLoadingSpinner = false;
        }
    }

    handleSelectAll(event) {
        const isChecked = event.target.checked;
        this.tasks = this.tasks.map(task => ({ ...task, isSelected: isChecked }));
        this.selectedTasks = isChecked ? this.tasks.map(task => task.id) : [];
    }

    handleSelectOne(event) {
        const taskId = event.target.dataset.id;
        const isChecked = event.target.checked;
        
        this.tasks = this.tasks.map(task =>
            task.id === taskId ? { ...task, isSelected: isChecked } : task
        );
        
        if (isChecked) {
            this.selectedTasks.push(taskId);
        } else {
            this.selectedTasks = this.selectedTasks.filter(selectedTaskId => selectedTaskId !== taskId);
        }
    }

    handleApproveTasks() {
        if (this.selectedTasks.length > 0) {
            this.isDialogVisible = true;
        } else {
            this.showToast('Atenção', 'Selecione pelo menos uma tarefa.', 'warning');
        }
    }

    closeModal() {
        this.isDialogVisible = false;
        this.approvalStatus = '';
        this.showLoadingSpinner = false;
    }

    handleRadioChange(event) {
        this.approvalStatus = event.target.value;
    }

    get desqualificadoRadioVisible(){
        return this.selectedTasks.length > 1
    }

    updateTasks(){
        console.log(this.approvalStatus);
        console.log(this.selectedTasks);
        updateTaskStatus({ taskIds: this.selectedTasks, newStatus: this.approvalStatus , motivoPerda: this.motivoPerda, submotivoPerda: this.submotivoPerda, pagamentoCaptacao:this.pagamentoCaptacao})
        .then(() => {
            this.showToast('Sucesso', 'Tarefas atualizadas com sucesso!', 'success');
            this.selectedTasks = [];
            this.motivoPerda = '';
            this.submotivoPerda = '';
            this.closeModal();
            this.showLoadingSpinner = false;
            return refreshApex(this.wiredTasksResult);
        })
        .catch(error => {
            console.error('Erro ao atualizar tarefas: ', error);
            this.showLoadingSpinner = false;
            this.showToast('Erro', 'Erro ao atualizar tarefas.', 'error');
            
        });
    }

    // getOriginSourceById(taskId) {
    //     const task = this.tasks.find(task => task.id === taskId);
    //     console.log(task);
    //     return task ? task.originSource : null; // Retorna originSource ou null se não for encontrado
    // }

    confirmApproval() {
        if (this.approvalStatus) {
            this.showLoadingSpinner = true;
            console.log(this.defeaultLeadRecordTypeId);
            if(this.approvalStatus == 'Desqualificado' && this.selectedTasks.length === 1){
                console.log('selected tasks origin: ',this.selectedTasks[0]);
                const source = this.tasks.find(rt => rt.id === this.selectedTasks[0]).originSource;
                motivoPerdaModal.open({
                    motivoPerdaField: MOTIVO_PERDA_FIELD,
                    submotivoPerdaField: SUBMOTIVO_PERDA_FIELD,
                    recordTypeId: this.defeaultLeadRecordTypeId,
                    leadSource: source
                }).then((result) => {
                    const {success, motivo, submotivo, pagamentoCaptacao} = result
                    console.log(success);
                    if(success){
                        this.pagamentoCaptacao = pagamentoCaptacao;
                        this.motivoPerda = motivo;
                        this.submotivoPerda = submotivo;
                        this.updateTasks();
                    }else{
                        this.showLoadingSpinner = false;
                    }
                }).catch((error) => {
                    console.log(error);
                    this.showLoadingSpinner = false;
                    // this.updateTasks();
                });
            }else{
                this.pagamentoCaptacao = false;
                this.updateTasks();
            }
        } else {
            this.showToast('Atenção', 'Selecione um status para aprovação.', 'warning');
        }
    }

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

    navigateToTask(event) {
        event.preventDefault();
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.target.dataset.id,
                objectApiName: 'Task',
                actionName: 'view'
            }
        });
    }

    navigateToLead(event) {
        event.preventDefault();
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.target.dataset.id,
                objectApiName: 'Lead',
                actionName: 'view'
            }
        });
    }
}