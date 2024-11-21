import { LightningElement, wire, api, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LightningConfirm from "lightning/confirm";
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';


import getUsinas from '@salesforce/apex/ContratoUsinaService.getUsinasContrato';
import updateUsinasData from '@salesforce/apex/ContratoUsinaService.updateUsinasData';


// Importacao de campos de Picklist
import USINA_OBJECT from '@salesforce/schema/Usina__c';
import DIST_FIELD from '@salesforce/schema/Usina__c.Distribuidora__c';
import MODELO_USINA_FIELD from '@salesforce/schema/Usina__c.Modelo_de_Usina__c';
import FONTE_FIELD from '@salesforce/schema/Usina__c.Fonte__c';
import PAG_ESCALONADO_FIELD from '@salesforce/schema/Usina__c.Pagamento_escalonado__c';


// Definicao de actions da tabela
const actions = [
    { label: "Excluir", name: "remove" },
];


/**
 * Definicao de conjuntos de colunas para 'cada tabela' na pagina
 */
const setDefault = [
    { 
        label: 'Id',
        fieldName: 'usinaId',  
        type: 'url', 
        typeAttributes: 
        {
            label: { fieldName: 'Name' }, 
            target: '_self'
        },
        sortable: true 
    },
    { label: 'Nome', fieldName: 'NomeUsina__c', type: 'text', editable: true},
    { label: 'Potência', fieldName: 'PotenciaUsina__c', type: 'number', editable: true},
    {
        label: 'Distribuidora', fieldName: 'Distribuidora__c', type: 'picklistColumn', editable: true, typeAttributes: {
            placeholder: 'Selecione...', options: { fieldName: 'listDistribuidoras' }, 
            value: { fieldName: 'Distribuidora__c' }, // default value for picklist,
            context: { fieldName: 'Id' } // binding account Id with context variable to be returned back
        }
    },
    { 
        label: 'Data da Conexão', 
        fieldName: 'Data_da_Conexao__c', 
        type: 'date-local', 
        typeAttributes: {
            day: "numeric",
            month: "numeric",
            year: "numeric"
        },
        editable: true
    },
    { label: 'Geração Preenchida', fieldName: 'GeracaoPreenchida__c', type: 'boolean' },
    {
        type: 'action',
        typeAttributes: {rowActions : actions}
    }
];

const setMinuta = [
    { 
        label: 'Id',
        fieldName: 'usinaId',  
        type: 'url', 
        typeAttributes: 
        {
            label: { fieldName: 'Name' }, 
            target: '_blank'
        },
        sortable: true 
    },
    { label: 'Nome', fieldName: 'NomeUsina__c', type: 'text', editable: true },
    { label: 'CNPJ da Usina', fieldName: 'CNPJ_da_Usina__c', type: 'text', editable: true},
    { label: 'Número de Instalação', fieldName: 'Numero_de_instalacao__c', type: 'text', editable: true},
    {
        label: 'Distribuidora', fieldName: 'Distribuidora__c', type: 'picklistColumn', editable: true, typeAttributes: {
            placeholder: 'Selecione...', options: { fieldName: 'listDistribuidoras' }, 
            value: { fieldName: 'Distribuidora__c' }, // default value for picklist,
            context: { fieldName: 'Id' } // binding usinaId with context variable to be returned back
        }
    },
    {
        label: 'Modelo de Usina', fieldName: 'Modelo_de_Usina__c', type: 'picklistColumn', editable: true, typeAttributes: {
            placeholder: 'Selecione...', options: { fieldName: 'listModelosUsinas' }, 
            value: { fieldName: 'Modelo_de_Usina__c' }, // default value for picklist,
            context: { fieldName: 'Id' } // binding usinaId with context variable to be returned back
        }
    },
    { label: 'Link DataRoom', fieldName: 'Link_DataRoom__c', type: 'url', editable: true},
    {
        type: 'action',
        typeAttributes: {rowActions : actions}
    }
];

const setAguardandoAssinatura = [
    { 
        label: 'Id',
        fieldName: 'usinaId',  
        type: 'url', 
        typeAttributes: 
        {
            label: { fieldName: 'Name' }, 
            target: '_blank'
        },
        sortable: true 
    },
    { label: 'Nome', fieldName: 'NomeUsina__c', type: 'text', editable: true },
    {
        label: 'Pagamento Escalonado', fieldName: 'Pagamento_escalonado__c', type: 'picklistColumn', editable: true, typeAttributes: {
            placeholder: 'Selecione...', options: { fieldName: 'listPagamentoEscalonado' }, 
            value: { fieldName: 'Pagamento_escalonado__c' }, // default value for picklist,
            context: { fieldName: 'Id' } // binding usinaId with context variable to be returned back
        }
    },
    { label: 'Deságio na tarifa vigente', fieldName: 'Des_gio_na_tarifa_vigente__c', type: 'number', editable: true},
    { label: 'Prazo do contrato', fieldName: 'Prazo_do_contrato__c', type: 'text', editable: true},
    { label: 'Valor Aluguel Equipamento', fieldName: 'ValorAluguelEquipamento__c', type: 'currency', editable: true},
    { label: 'Valor Aluguel Imóvel', fieldName: 'ValorAluguelImovel__c', type: 'currency', editable: true},
    { label: 'Link DataRoom', fieldName: 'Link_DataRoom__c', type: 'url', editable: true},
    { 
        label: 'Data COD (em contrato)', 
        fieldName: 'DataCOD__c', 
        type: 'date-local', 
        typeAttributes: {
            day: "numeric",
            month: "numeric",
            year: "numeric"
        },
        editable: true
    },

    {
        type: 'action',
        typeAttributes: {rowActions : actions}
    }
];

const setAssinado = [
    { 
        label: 'Id',
        fieldName: 'usinaId',  
        type: 'url', 
        typeAttributes: 
        {
            label: { fieldName: 'Name' }, 
            target: '_blank'
        },
        sortable: true 
    },
    { label: 'Nome', fieldName: 'NomeUsina__c', type: 'text', editable: true },
    {
        label: 'Fonte', fieldName: 'Fonte__c', type: 'picklistColumn', editable: true, typeAttributes: {
            placeholder: 'Selecione...', options: { fieldName: 'listFontesUsinas' }, 
            value: { fieldName: 'Fonte__c' }, // default value for picklist,
            context: { fieldName: 'Id' } // binding usinaId with context variable to be returned back
        }
    },
    { label: 'Potência da Usina', fieldName: 'PotenciaUsina__c', type: 'number', editable: true},
    { label: 'Geração Preenchida', fieldName: 'GeracaoPreenchida__c', type: 'boolean' },
    {
        type: 'action',
        typeAttributes: {rowActions : actions}
    }
];

export default class EditUsinasDatatable extends LightningElement {
    usinas;
    error;
    
    // variaveis de controle da picklist
    @track modelosUsinas;
    @track fontesUsinas;
    @track pagamentoEscalonado;
    @track distribuidoras;
   
    // variaveis de ocntrole da lista de usinas
    @track columns = [];
    @track draftValues = [];
    lastSavedData = [];
    
    // variáveis de api
    @api recordId;
    @api status; // status do contrato
    @api tableTitle;

    wiredUsinasResults;


    // Definir colunas a a serem exibidas a depender do status do contrato
    connectedCallback(){
        switch (this.status) {
            case 'Minuta':
                // console.log('Entrou')
                this.columns=setMinuta;
                break;
            case 'AguardandoAssinatura':
                // console.log('Entrou')
                this.columns=setAguardandoAssinatura;
                break;
            case 'Assinado':
                // console.log('Entrou')
                this.columns=setAssinado;
                break;
            default:
                this.columns=setDefault;
                // console.log('Não entrou Entrou')
                break;
        }
    }

    /**
     * 
     * Conjunto de metodos que visam obter os valores disponiveis nas picklists
     * 
     */
    @wire(getObjectInfo, { objectApiName: USINA_OBJECT})
    usinaObjectMetadata;

    @wire(getPicklistValues, {recordTypeId: '$usinaObjectMetadata.data.defaultRecordTypeId', fieldApiName: DIST_FIELD})
    wiredDistribuidoraPicklist({data,error}){

        if (data) {
            this.distribuidoras = data.values;
        } else if (error) {
            console.log(error);
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$usinaObjectMetadata.data.defaultRecordTypeId', 
        fieldApiName: MODELO_USINA_FIELD
    })
    wiredModeloUsinasPicklist({data,error}){
        if (data) {
            this.modelosUsinas = data.values;
        } else if (error) {
            console.log(error);
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$usinaObjectMetadata.data.defaultRecordTypeId', 
        fieldApiName: FONTE_FIELD
    })
    wiredFontesUsinasPicklist({data,error}){
        if (data) {
            this.fontesUsinas = data.values;
        } else if (error) {
            console.log(error);
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$usinaObjectMetadata.data.defaultRecordTypeId', 
        fieldApiName: PAG_ESCALONADO_FIELD
    })
    wiredPagamentoEscalonadoPicklist({data,error}){
        if (data) {
            this.pagamentoEscalonado = data.values;
        } else if (error) {
            console.log(error);
        }
    }
    /**
     * Metodo wire para buscar e popular campos das usinas
     */
    @wire(getUsinas, {
        contratoId                  : '$recordId', 
        pickListDistribuidoras      : '$distribuidoras', 
        pickListModelosUsinas       : '$modelosUsinas',
        pickListFontesUsinas        : '$fontesUsinas',
        pickListPagamentoEscalonado : '$pagamentoEscalonado'
    })
    wiredUsinas(result) {
        this.wiredUsinasResult = result;
        if (result.data) {
            
            // loops para pupular arrays de options de picklists
            let optionsDist = []
            for(var key in this.distribuidoras){
                optionsDist.push({label: this.distribuidoras[key].label, value: this.distribuidoras[key].value})
            }

            let optionsModelos = [];
            for(var key in this.modelosUsinas){
                optionsModelos.push({label: this.modelosUsinas[key].label, value: this.modelosUsinas[key].value})
            }

            let optionsFontes = [];
            for(var key in this.fontesUsinas){
                optionsFontes.push({label: this.fontesUsinas[key].label, value: this.fontesUsinas[key].value})
            }

            let optionsPagEscalonado = [];
            for(var key in this.pagamentoEscalonado){
                optionsPagEscalonado.push({label: this.pagamentoEscalonado[key].label, value: this.pagamentoEscalonado[key].value})
            }

            // map para definir variaveis da tabela
            this.usinas = result.data.map(row=>{
                return{
                    ...row, // todas as vairaveis pre-existentes em result.data
                    usinaId: '/' + row.Id, // responsável por gerar link na coluna id
                    'listDistribuidoras': optionsDist, // lista de Distribuidoras disponiveis no objeto usina (Ex: CEMIG; CPFL Paulista)
                    'listModelosUsinas': optionsModelos, // lista de Modelos de Usina disponiveis no objeto usina (Ex: GDI; GDII)
                    'listFontesUsinas': optionsFontes,// lista de Fontes disponiveis no objeto usina (Ex: Solar; Eolica)
                    'listPagamentoEscalonado': optionsPagEscalonado // lista de Opcoes de pagamento escalonado disponiveis no objeto usina (Ex: 33/66/100; 25/50/75/100)
                }
            });
            this.lastSavedData = JSON.parse(JSON.stringify(this.usinas));
            this.error = undefined;
        } else if (result.error) {
            this.error = result.error;
            this.usinas = undefined;
        }
    }

    /**
     * Funções de acoes na tabela
     * 
     */
    // Acoes ao salvar a edicao na tabela
    async handleSave(event) {
        const updatedFields = event.detail.draftValues;

        // Limpa valores de rascunho
        this.draftValues = [];

        try {
            // Chama a classe auxiliar de servico apex para atualizar as usinas 
            await updateUsinasData({ usinasForUpdate: updatedFields });

            // Caso seja atualizada, indica sucesso com um toast
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Successo',
                    message: 'Atualização de usinas concluidas',
                    variant: 'success'
                })
            );

            // Atualiza tabela com novos valores
            await refreshApex(this.wiredUsinasResult);
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

    // Funcao para lidar com a mudanca de valores na picklist e salvar nos valores de rascunho
    async handleCellChange(event) {
        let draftValues = event.detail.draftValues;
        draftValues.forEach(ele=>{
            this.updateDraftValues(ele);
        })
    }

    // Remove valores de rascunho e reverte as mundacas de dados
    async handleCancel(event) {
        this.data = JSON.parse(JSON.stringify(this.lastSavedData));
        this.draftValues = [];
    }

    // lidar com acoes da tabela
    async handleRowAction(event) {
        const actionName = event.detail.action.name
        const row = event.detail.row;

        // Caso tenha acionado o botao de deletar usina
        if(actionName == 'remove'){
            try {
                // Abre um modal de confirmacao
                const result = await LightningConfirm.open({
                    message: "Tem certeza que quer excluir a usina "+row.Name+" ?",
                    variant: "default", // opcao de variacao no cebecalho. (default; headerless)
                    label: "Excluir Usina"
                });
                if (result) {
                    // Funcao de deletar registro via UI
                    await deleteRecord(row.Id);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Usina Excluida',
                            variant: 'success'
                        })
                    );
                    await refreshApex(this.wiredUsinasResult);
                }
            } catch(e) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Erro ao deletar registro',
                        message: reduceErrors(error).join(', '),
                        variant: 'error'
                    })
                );
            }
        }

    }
    // Atualizar registros na tabela ao pressionar o icone de atualizar
    async handleRefresh(event){
        try {
            await refreshApex(this.wiredUsinasResult);
        } catch (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Erro ao atualizar ou recarregar registros',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        }
    }
}