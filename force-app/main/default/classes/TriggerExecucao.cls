/**
* Interface que especifica um método para execução de ações disparadas por triggers.
* Cada objeto deverá ter somente uma Trigger, e para cada ação distinta, deverá ser criada
* uma classe que implemente essa interface.
*/
public interface TriggerExecucao 
{	
	/**
	* Executa uma ação disparada por uma trigger em uma deteminada operação.
	* As classes que implementarem essa interface deverão fazer o cast para o tipo correto do objeto que se quer trabalhar.
	* Ex: Se a trigger for no objeto account, para obter a lista de dados atuais é necessário colocar a instrução abaixo:
	* List<Account> lstAccount = (List<Account>) lstDadosAtuais. O mesmo vale para os mapas:
	* Map<Id, Account> mapAccount = (Map<Id, Account>) mapDadosAtuais.
	* @param lstDadosAtuais A lista de SObjects contendo os dados atuais (trigger.new).
	* @param lstaDadosAnteriores A lista de SObjects contendo os dados anteriores (trigger.old).
	* @param mapDadosAtuais O mapa contendo os dados atuais, tendo o id do objeto como chave e o próprio objeto como valor (trigge.newMap).
	* @param mapDadosAnteriores O mapa contendo os dados anteriores, tendo o id do objeto como chave e o próprio objeto como valor (trigge.newMap).
	*/
	void executar(List<SObject> lstDadosAtuais, List<SObject> lstDadosAnteriores, Map<Id, SObject> mapDadosAtuais, Map<Id, SObject> mapDadosAnteriores);
}