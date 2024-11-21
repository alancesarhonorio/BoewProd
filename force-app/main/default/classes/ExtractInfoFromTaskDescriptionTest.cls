@isTest
public class ExtractInfoFromTaskDescriptionTest {
    @isTest
    public static void ExtractInfoFromTaskDescriptionTest() {
        // Test case 1: tudo correto
        // Task task = new Task(
        //     Subject = 'Ligação',
        //     Description = 'CPF: informação não encontrada\nCNPJ: informação não encontrada\nTipo de ligação: Ativo\nNúmero: +5533998119314\nRamal: 269016\nDDD: 33\nData da ligação: 06/07/2023 12:44:58\nData de término: 06/07/2023 12:45:05\nDuração: 01h 05m 10s\nCall ID: 1688658285.275749\nURA: informação não encontrada\nFila: 2690-ativo\nOrder: informação não encontrada\nCusto da ligação: 0.07\nURL de Áudio: https://vsa14.55pbx.com/webphone/webphone-2690/2023/07/06/audio-2023-07-06_12-44-45-269016-5533998119314-1688658285.275749.WAV'
        // );
        // insert task;

        // task = [SELECT TipoLigacao__c,InicioLigacao__c,TerminoLigacao__c,CallInHours__c,CallInMinutes__c,CallInSeconds__c FROM Task WHERE Id = :task.Id];
        // System.assertEquals('Ativo', task.TipoLigacao__c);

        // Datetime expectedDatetime1 = Datetime.newInstance(2023, 07, 06, 12, 44, 58);
        // System.assertEquals(expectedDatetime1, task.InicioLigacao__c);
        
        // Datetime expectedDatetime2 = Datetime.newInstance(2023, 07, 06, 12, 45, 05);
        // System.assertEquals(expectedDatetime2, task.TerminoLigacao__c);
        
        // System.assertEquals(01, task.CallInHours__c);
        // System.assertEquals(05, task.CallInMinutes__c);
        // System.assertEquals(10, task.CallInSeconds__c);

        // // Test case 2: dados faltantes ou elementos importantes faltantes
        // Task task2 = new Task(
        //     Subject = 'Ligação',
        //     Description = 'CPF: informação não encontrada\nCNPJ: informação não encontrada\nTipo de ligação: Ativo\nRamal: 269016\nDDD: 33\nData da ligação: 06/07/2023 12:44:58\nData de término: 06/07/2023 12:45:05\nCall ID: 1688658285.275749\nURA: informação não encontrada\nFila: 2690-ativo\nOrder: informação não encontrada\nCusto da ligação: 0.07\nURL de Áudio: https://vsa14.55pbx.com/webphone/webphone-2690/2023/07/06/audio-2023-07-06_12-44-45-269016-5533998119314-1688658285.275749.WAV'
        // );
        // insert task2;

        // task2 = [SELECT TipoLigacao__c,InicioLigacao__c,TerminoLigacao__c,CallInHours__c,CallInMinutes__c,CallInSeconds__c FROM Task WHERE Id = :task2.Id];
        // System.assertEquals(null, task2.TipoLigacao__c);

        // Datetime expectedDatetime3 = Datetime.newInstance(2023, 07, 06, 12, 44, 58);
        // System.assertEquals(expectedDatetime3, task2.InicioLigacao__c);
        
        // //Datetime expectedDatetime2 = Datetime.newInstance(2023, 07, 06, 12, 45, 05);
        // System.assertEquals(null, task2.TerminoLigacao__c);
        
        // System.assertEquals(null, task2.CallInHours__c);
        // System.assertEquals(null, task2.CallInMinutes__c);
        // System.assertEquals(null, task2.CallInSeconds__c);

    }
}