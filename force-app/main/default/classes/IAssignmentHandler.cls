/**
 * Interface responsável por definir os métodos necessários para o gerenciamento de atribuição de registros.
 */
public interface IAssignmentHandler {
    /**
     * Atribui os registros fornecidos de acordo com o modo e tipo especificados.
     * 
     * @param records Os registros a serem atribuídos.
     * @param mode O modo de atribuição. (Ex: Round Robin)
     * @param type O tipo da fila que será atribuido. 
     * @return Uma lista de registros atribuídos.
     */
    List<SObject> assignRecords(List<SObject> records, String mode, String type);

    /**
     * Manipula a roteirização inicial dos registros fornecidos.
     * 
     * @param records Os registros a serem roteados inicialmente, sem DML.
     */
    void handleInitialRouting(List<SObject> records);

    /**
     * Manipula a roteirização de atualização dos registros fornecidos.
     * 
     * @param records Os registros a serem roteirizados na atualização, com DML.
     */
    void handleUpdateRouting(List<SObject> records);
}