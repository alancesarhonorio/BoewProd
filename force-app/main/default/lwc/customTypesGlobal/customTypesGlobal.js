import LightningDatatable from "lightning/datatable";
import picklistColumn from './customPicklistColumn.html';
import pickliststatic from './customPicklistStatic.html'
 
export default class LWCCustomDatatableType extends LightningDatatable {
    static customTypes = {
        picklistColumn: {
            template: pickliststatic,
            editTemplate: picklistColumn,
            standardCellLayout: true,
            typeAttributes: ['label', 'placeholder', 'options', 'value', 'context', 'variant','name']
        }
    };
}