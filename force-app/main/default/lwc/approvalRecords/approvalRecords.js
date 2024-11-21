import { LightningElement, track, api, wire } from 'lwc';
import getWrapperClassList from '@salesforce/apex/ItensAprovacaoController.getSubmittedRecords';
import processRecords from '@salesforce/apex/ItensAprovacaoController.processRecords';
import gettotalcount from '@salesforce/apex/ItensAprovacaoController.gettotalcount';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';

export default class ApprovalRecords extends LightningElement {
    searchKeyword = '';
    @api wrapperList = [];
    @api draftValues = [];
    @track isReassignModalVisible = false;
    @track searchTerm = '';
    @track showUserSearchModal = false;
    @track searchResults = [];
    @track selectedUserId = '';
    @track selectedCases = [];
    @track error;
    @track sortBy;
    @track sortDirection;
    @track bShowModal = false;
    @track selectedcommentrowno;
    @track icomments = '';
    @track record;
    @track queryOffset;
    @track queryLimit;
    @track totalRecordCount;
    @track showinfiniteLoadingSpinner = true;
    @track showLoadingSpinner = false;
    @track isDialogVisible = false;
    @track isApprove = false;
    @track isReject = false;
    @track originalMessage;
    @track originalTitle = '';
    @track wrapperListtrue = true;
    @track title;
    @api footertext;
    @track enable_app_rej = true;
    @track maiorQueUm = '';
    @track oppSelecionado = [];
    @track selectedRecordId;
    @track idsCasosSelecionados = [];
    @track columns = [
        {
            type: 'button-icon',
            fixedWidth: 40,
            typeAttributes: {
                iconName: 'utility:preview',
                name: 'view_record',
                title: 'Vizualizar Oportunidade',
                variant: 'border-filled',
                alternativeText: 'View Record',
                disabled: false
            }
        },
        {
            label: 'Nome',
            fieldName: 'recordName',
            type: 'text',
            initialWidth: 500,
            wrapText: true,
            sortable: true
        },
        {
            label: 'Número da Proposta',
            fieldName: 'relatedTo',
            type: 'text',
            initialWidth: 200,
            sortable: true
        },
        {
            label: 'Origem do LEAD',
            fieldName: 'origemLead',
            type: 'text',
            initialWidth: 200,
            sortable: true
        },
        {
            label: 'Status da Oportunidade',
            fieldName: 'stageName',
            type: 'text',
            initialWidth: 260,
            sortable: true
        },
        {
            label: 'Data da Oportunidade',
            fieldName: 'submittedDate',
            type: 'date',
            initialWidth: 230,
            typeAttributes: {
                day: 'numeric',
                month: 'short',
                year: 'numeric'
            },
            sortable: true
        }
    ];
    wiredcountResults;
    @wire(gettotalcount) totalcount(result) {
        console.log('result.data: ', result.data);
        this.wiredcountResults = result;
        if (result.data != undefined) {
            this.totalRecordCount = result.data;
            console.log('total: ' + this.totalRecordCount);
            this.title = 'Itens a Aprovar (' + this.totalRecordCount + ')';
            if (result.data > 0)
                this.wrapperListtrue = true;
            else {
                this.totalRecordCount = 0;
                this.title = 'Itens a Aprovar';
                this.wrapperListtrue = false;
                console.log('total: ' + this.totalRecordCount);
            }
        } else if (result.error) {
            this.error = result.error;
            this.totalRecordCount = 0;
            this.title = 'Itens a Aprovar (' + this.totalRecordCount + ')';
            this.wrapperListtrue = false;
            console.log('total: ' + this.totalRecordCount);
        }
    }
    constructor() {
        super();
        this.title = 'Itens a Aprovar';
        this.showinfiniteLoadingSpinner = true;
        this.wrapperList = [];
        this.queryOffset = 0;
        this.queryLimit = 20;
        this.loadRecords();
    }
    reloadrecords() {
        this.showLoadingSpinner = true;
        this.showinfiniteLoadingSpinner = true;
        this.queryOffset = 0;
        this.queryLimit = 20;
        let flatData;
        
        this.wrapperList = [];
        console.log(this.totalRecordCount);
        return getWrapperClassList({ queryLimit: this.queryLimit, queryOffset: this.queryOffset })
            .then(result => {
                console.log(result);
                console.log(this.totalRecordCount);
                flatData = result;
                if (flatData != undefined) {
                    for (var i = 0; i < flatData.length; i++) {
                        flatData[i].recordId = flatData[i].recordId;
                    }
                    this.wrapperList = flatData;
                }
                this.showLoadingSpinner = false;
                console.log(this.wrapperList);
                this.showLoadingSpinner = false;
                return refreshApex(this.wiredcountResults);
            }).catch(error => {
                console.log(error);
                this.showLoadingSpinner = false;
                this.error = error;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: result,
                        variant: 'info'
                    })
                );
                return refreshApex(this.wiredcountResults);
            })
    }
    loadRecords() { 
        this.showLoadingSpinner = true;
        let flatData;
        return getWrapperClassList({ queryLimit: this.queryLimit, queryOffset: this.queryOffset })
            .then(result => {
                console.log(result);
                flatData = result;
                if (flatData != undefined) {
                    for (var i = 0; i < flatData.length; i++) {
                        flatData[i].recordId = '/' + flatData[i].recordId;
                    }
                    let updatedRecords = [...this.wrapperList, ...flatData];
                    this.wrapperList = updatedRecords;
                }
                this.showLoadingSpinner = false;
                console.log(this.wrapperList);
                refreshApex(this.wiredcountResults);
                this.title = 'Itens a Aprovar (' + this.totalRecordCount + ')';
            }).catch(error => {
                console.log(error);
                this.showLoadingSpinner = false;
                this.error = error;
                refreshApex(this.wiredcountResults);
                this.title = 'Itens a Aprovar (' + this.totalRecordCount + ')';
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: result,
                        variant: 'info'
                    })
                );
            })
    }
    loadMoreData(event) {
        const { target } = event;
        this.showinfiniteLoadingSpinner = true;
        if (this.totalRecordCount < this.queryLimit) {
            console.log(this.wrapperList);
            this.showinfiniteLoadingSpinner = false;
            return refreshApex(this.wiredcountResults);
        }
        else if (this.totalRecordCount > this.queryOffset) {
            this.queryOffset = this.queryOffset + 5;
            console.log('lmir queryLimit' + this.queryLimit);
            console.log('lmir queryOffset' + this.queryOffset);
            let flatData;
            return getWrapperClassList({ queryLimit: this.queryLimit, queryOffset: this.queryOffset })
                .then(result => {
                    target.isLoading = false;
                    console.log(result);
                    console.log(this.totalRecordCount);
                    flatData = result;
                    if (flatData != undefined) {
                        for (var i = 0; i < flatData.length; i++) {
                            flatData[i].recordId = '/' + flatData[i].recordId;
                        }
                        let updatedRecords = [...this.wrapperList, ...flatData];
                        this.wrapperList = flatData;
                    }
                    target.isLoading = false;
                    console.log(this.wrapperList);
                    this.showinfiniteLoadingSpinner = false;
                    return refreshApex(this.wiredcountResults);
                }).catch(error => {
                    console.log(error);
                    this.showinfiniteLoadingSpinner = false;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: result,
                            variant: 'info'
                        })
                    );
                    return refreshApex(this.wiredcountResults);
                })
        } else {
            this.showinfiniteLoadingSpinner = false;
            target.isLoading = false;
            return refreshApex(this.wiredcountResults);
        }

    }

    handleSave(event) {
        this.showLoadingSpinner = true;
        console.log(event.detail.draftValues);
        console.log(this.wrapperList);
        var draftlst = [];
        draftlst = event.detail.draftValues;
        for (var i = 0; i < this.wrapperList.length; i++) {
            console.log(this.wrapperList[i].workItemId);
            for (var j = 0; j < draftlst.length; j++) {
                console.log(draftlst[j].workItemId);
                if (this.wrapperList[i].workItemId === draftlst[j].workItemId) {
                    this.wrapperList[i].comments = draftlst[j].comments;
                }
            }
        }
        for (var i = 0; i < this.wrapperList.length; i++) {
            console.log(this.wrapperList[i].comments);
        }
        this.draftValues = [];
        this.showLoadingSpinner = false;
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Approver comments Added.',
                variant: 'success'
            })
        );
    }
    enablebuttons(event)
    {
        const selectedRows = event.detail.selectedRows;
        const recordsCount = event.detail.selectedRows.length;
        this.oppSelecionado = selectedRows;

        const selectedCaseIds = [];

        for (const wrapperItem of this.oppSelecionado) {
            const caseId = wrapperItem.workItemId.split('/').pop();
            selectedCaseIds.push(caseId);
        }

        if(recordsCount > 0)
            this.enable_app_rej = false;
        else
            this.enable_app_rej = true;
         
        if(recordsCount > 1){
            console.log(selectedRows);
            console.log(recordsCount);
            console.log('Selecionados:', JSON.parse(JSON.stringify(this.oppSelecionado)));
            console.log('workItemId Selecionados:', selectedCaseIds);
        }else if(recordsCount <= 1){
            console.log(recordsCount);
            console.log(selectedRows);
            console.log('Selecionados:', JSON.parse(JSON.stringify(this.oppSelecionado)));
            console.log('workItemId Selecionado:', selectedCaseIds);
        }
    }


    inputHandleChange(event){
        this.txt = event.target.value;
      }

    processrec() {
        this.showLoadingSpinner = true;
        console.log('test');
        var el = this.template.querySelector('lightning-datatable');
        var selectedrows = el.getSelectedRows();
        console.log(selectedrows);
        var varprocessType = this.originalMessage;
        var processrows = [];
        for (var i = 0; i < selectedrows.length; i++) {
            processrows.push(selectedrows[i]);
        }
        if (processrows.length > 0) {
            var str = JSON.stringify(processrows);
            processRecords({ processType: varprocessType, strwraprecs: str })
                .then(result => {
                    this.showinfiniteLoadingSpinner = true;
                    this.queryOffset = 0;
                    this.queryLimit = 5;
                    let flatData;
                    this.wrapperList = [];
                    console.log(this.totalRecordCount);
                    return getWrapperClassList({ queryLimit: this.queryLimit, queryOffset: this.queryOffset })
                        .then(result => {
                            console.log(result);
                            console.log(this.totalRecordCount);
                            flatData = result;
                            if (flatData != undefined) {
                                for (var i = 0; i < flatData.length; i++) {
                                    flatData[i].recordId = '/' + flatData[i].recordId;
                                }
                                this.wrapperList = flatData;
                            }
                            this.showLoadingSpinner = false;
                            console.log(this.wrapperList);
                            this.showLoadingSpinner = false;
                            var messagetitle;
                            var ivariant;
                            if(varprocessType == 'Approve')
                            {
                                messagetitle = 'Os registros selecionados foram Aprovados. ';
                                ivariant = 'success';
                                this.isDialogVisible = false;
                            }
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: messagetitle,
                                    message: result,
                                    variant: ivariant
                                })
                            );
                            return refreshApex(this.wiredcountResults);
                        }).catch(error => {
                            console.log(error);
                            this.showLoadingSpinner = false;
                            this.error = error;
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Error',
                                    message: result,
                                    variant: 'info'
                                })
                            );
                            return refreshApex(this.wiredcountResults);
                        })
                })
                .catch(error => {
                    this.showLoadingSpinner = false;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: result,
                            variant: 'error'
                        })
                    );
                    return refreshApex(this.wiredcountResults);
                });
        }
        else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'No Records chosen.',
                    message: 'Please select records to proceed.',
                    variant: 'warning'
                })
            );
            this.showLoadingSpinner = false;
        }
    }

    handleSortdata(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(event.detail.fieldName, event.detail.sortDirection);
    }
    sortData(fieldname, direction) {
        this.showLoadingSpinner = true;
        let parseData = JSON.parse(JSON.stringify(this.wrapperList));
        let keyValue = (a) => {
            return a[fieldname];
        };
        let isReverse = direction === 'asc' ? 1 : -1;
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : '';
            y = keyValue(y) ? keyValue(y) : '';

            return isReverse * ((x > y) - (y > x));
        });
        this.wrapperList = parseData;
        this.showLoadingSpinner = false;
    }


    openModal() { this.bShowModal = true; }
    closeModal() { this.bShowModal = false; }
    handleRowAction(event) {
        const actionName = event.detail.action.name;
        var row = event.detail.row;
        console.log('Row selecionado: ' + row);
        switch (actionName) {
            case 'view_record':
                this.viewrecord(row);
                break;
            case 'submitter_comments':
                this.opencomment(row);
                break;
            default:
        }
    }

    viewrecord(row) {
        this.record = row;
        console.log(this.record.recordId);
        window.open(this.record.recordId, '_blank');

    }
    handleconformClick(event) {
        try {
        if (event.target.title === 'Approve') {
            console.log('Aprovar ' + event.target.title);
            this.originalMessage = event.target.title;
            this.originalTitle === 'Aprovar Casos';
            console.log(this.wrapperList);
            this.isDialogVisible = true;
            this.isApprove = true;
        }

        
        else if (event.target.name === 'confirmModal') {
            console.log(event.detail);
            if (event.detail !== 1) {
                console.log('status' + event.detail.status); 
                if (event.detail.status === 'confirm') {
                    this.processrec();
                    this.isDialogVisible = false;
                } else if (event.detail.status === 'cancel') {
                    this.isDialogVisible = false;
                }
            }
            
          }
        }
        catch(e) {
            console.log(e);
        }
    }

    handleApprove(event) {
        if(this.maiorQueUm === true){
            for (var i = 0; i < this.wrapperList.length; i++) {
                const recordId = this.wrapperList[i].recordId;
                const workItemId = this.wrapperList[i].workItemId;
                const aprovador = this.wrapperList[i].Aprovador;

                console.log('recordId: ' + recordId);
                console.log('workItemId: ' + workItemId);
                console.log('ActorName: ' + aprovador);
            }
        }else{
            
            const recordId = this.wrapperList[0].recordId;
            const workItemId = this.wrapperList[0].workItemId;
            const aprovador = this.wrapperList[0].aprovador;

            console.log('recordId: ' + recordId);
            console.log('workItemId: ' + workItemId);
            console.log('ActorName: ' + aprovador);
        }
    }

    openUserSearchModal() {
        this.showUserSearchModal = true;
      }
      
    closeUserSearchModal() {
        this.showUserSearchModal = false;
        this.isDialogVisible = false;
        this.searchResults = [];
        this.searchKeyword = '';
      }
    

    removeCaseFromList(caseId) {
        this.wrapperList = this.wrapperList.filter(item => item.recordId !== caseId);
    }
    

    showToast(title, message, variant) {
        const toastEvent = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(toastEvent);
    }
    
}