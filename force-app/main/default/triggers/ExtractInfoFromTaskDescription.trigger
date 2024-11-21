trigger ExtractInfoFromTaskDescription on Task (before insert) {
    for (Task task: Trigger.new){
        if(task.description != null){
            try{
                task.TipoLigacao__c = Utils.extractInformationFromLongText(task.description,'Tipo de ligação:','Número');
            }catch(Exception e){
                System.debug('Erro ao encontrar Tipo de ligação : ' + e.getMessage());
            }
            
            
            String InicioLigacao  = Utils.extractInformationFromLongText(task.description,'Data da ligação:','Data de término');
            // System.debug(InicioLigacao);
            task.InicioLigacao__c = Utils.convertToDateTime(InicioLigacao);
            
            String TerminoLigacao = Utils.extractInformationFromLongText(task.description,'Data de término:','Duração');
            // System.debug(TerminoLigacao);
            task.TerminoLigacao__c = Utils.convertToDateTime(TerminoLigacao);
            // System.debug(duracao);
            try{
                String duracao = Utils.extractInformationFromLongText(task.description,'Duração:','Call ID');
                String[] duracaoPartes = duracao.split(' ');
                task.CallInHours__c = Integer.valueOf(duracaoPartes[0].split('h')[0]);
                task.CallInMinutes__c = Integer.valueOf(duracaoPartes[1].split('m')[0]);
                task.CallInSeconds__c = Integer.valueOf(duracaoPartes[2].split('s')[0]); 
            }catch(Exception e){
                System.debug('Erro ao duração da ligação : ' + e.getMessage());
            }
        
        }
    }
}