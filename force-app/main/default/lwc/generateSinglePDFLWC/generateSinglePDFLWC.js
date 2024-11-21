import { api, LightningElement  } from 'lwc';
import executarArquivo from '@salesforce/apex/GenerateSinglePDF.executarArquivo';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';


export default class GenerateSinglePDFLWC extends LightningElement {

    @api recordId;
    
    showSpinner = true;
    message;

    pdfLink;

    @api invoke() {

      if (this.recordId) {
        this.generatePDF();
      }
    }
  
    async generatePDF() {
        this.showSpinner = true;

        try {
            const pdfUrl = await executarArquivo({ objectId: this.recordId });
            console.log('pdfUrl:', pdfUrl);

            if (pdfUrl) {
                const link = document.createElement('a');
                link.href = pdfUrl;
                link.download = "Conta_captacao.pdf";
                link.click();

                this.showToast(
                    'PDF gerado com sucesso!',
                    'Sucesso!',
                    'success'
                );
            } else {
                this.showToast('Ocorreu um erro ao gerar o PDF', 'Erro!', 'error');
            }
        } catch (error) {
            console.error(error);
            this.showToast('Ocorreu um erro inesperado', 'Erro!', 'error');
        } finally {
            this.showSpinner = false;
        }
    }


    showToast(msg, title, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: msg,
                variant: variant,
            })
        );
    }

    refreshPage() {
        getRecordNotifyChange([{recordId: this.recordId}]);
    }


}