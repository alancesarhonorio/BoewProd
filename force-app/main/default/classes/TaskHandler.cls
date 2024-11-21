public class TaskHandler implements TriggerExecucao
{
	public void executar(List<SObject> lstDadosAtuais, List<SObject> lstDadosAnteriores, Map<Id, SObject> mapDadosAtuais, Map<Id, SObject> mapDadosAnteriores) 
	{
		List<Task> lstSObjTaskAtuais = (List<Task>) lstDadosAtuais;
		Map<Id, Task> mapSObjTaskAnteriores = (Map<Id, Task>) mapDadosAnteriores;
        TaskBO.getInstance().updateLeadonTask(lstSObjTaskAtuais, mapSObjTaskAnteriores);
 	}
    
}