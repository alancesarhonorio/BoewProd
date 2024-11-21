public class CaptacaoService {

    public class NotFoundException extends Exception {}
    public class ConvertedLeadException extends Exception {}

    /**
     * Método responsável por processar a criação de uma captacao.
     * 
     * @param singleCaptacao A captacao a ser processada.
     */
    public static void processCaptacaoCreation(Captacao singleCaptacao){
        
        // Determina Pessoa fisica como o tipo de registro padrão 
        // String recordTypeName = singleCaptacao.TipoRegistro != null ? singleCaptacao.TipoRegistro : 'Pessoa_Fisica';
        String recordTypeName = 'Captacao';
        
        Id recordTypeId = SObjectType.Lead.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
        // Definição da criação do lead
        Lead leadToCreate = new Lead(
            guid__c             = singleCaptacao.guid,
            guid_captacao__c    = singleCaptacao.guid,
            FirstName           = singleCaptacao.FirstName,
            LastName            = singleCaptacao.LastName,
            LeadSource          = singleCaptacao.LeadSource,
            Status              = singleCaptacao.Status != null ? singleCaptacao.Status : 'Lead Novo',
            RecordTypeId        = recordTypeId,
            Phone               = singleCaptacao.Phone,
            Email               = singleCaptacao.Email,
            CNPJ__c             = singleCaptacao.CNPJ != null ? singleCaptacao.CNPJ : '',
            CPF__c              = singleCaptacao.CPF != null ? singleCaptacao.CPF : '',
            Nome_do_Parceiro__c = singleCaptacao.NomeParceiro,
            Tipo_do_Parceiro__c = singleCaptacao.TipoParceria,
            Motivo_de_Perda__c  = singleCaptacao.MotivoPerda,
            IsCaptacao__c	    = true,
            Rastreamento__c     = singleCaptacao.Rastreamento,
            Campanha__c         = singleCaptacao.Campanha,
            Valor_Da_Conta__c   = singleCaptacao.ValorMedioConta
        );

        // Busca e atribui sdr ao lead, se existir
        if(singleCaptacao.EmailSDR != null){
            List<User> user = [SELECT Id FROM User WHERE Username = :singleCaptacao.EmailSDR LIMIT 1]; 
            if(user.isEmpty() || user == null){
                throw new NotFoundException('SDR não encontrado');
            }
            leadToCreate.OwnerId = user[0].Id;
            leadToCreate.DesconsiderarAtribuicao__c = true;
        }
        
        // DML de Criação/atualização do lead
        upsert leadToCreate guid__c;
        
        if(singleCaptacao.ContasCaptacao == null || singleCaptacao.ContasCaptacao.isEmpty()){
            return ;
        }
        
        // Criação das contas de captação relacionadas ao lead
        List<Conta_de_captacao__c> contasToCreate = new List<Conta_de_captacao__c>();
        for(Captacao.ContasCaptacao singleConta : singleCaptacao.ContasCaptacao){
            
            Conta_de_captacao__c conta = new Conta_de_captacao__c(
                guid__c = singleConta.guid,
                Id__c = singleConta.Id,
                Lead__c = leadToCreate.Id,
                Link_Arquivo__c = singleConta.LinkArquivo,
                Distribuidora__c = singleConta.Distribuidora,
                Valor_da_conta__c = singleConta.ValorConta
            );
            contasToCreate.add(conta);
        }
        upsert contasToCreate Id__c;
    }

    /**
     * Processa a criação de contas de captação com base em uma única captação.
     * 
     * @param singleCaptacao A captação utilizada como base para criar as contas de captação.
     * @throws NotFoundException Se nenhum lead for encontrado com o guid especificado na captação.
     */
    public static void processContaCaptacaoCreation(Captacao singleCaptacao){
        List<Lead> existingLeads = [SELECT Id FROM Lead WHERE guid__c = :singleCaptacao.guid LIMIT 1];
        
        // Se não encontrar lead com o guid especificado, lança exceção
        if(existingLeads.isEmpty() || existingLeads == null){
            throw new NotFoundException('Lead não encontrado');
        }

        // Se não houver contas de captação na captação, lança exceção
        if(singleCaptacao.ContasCaptacao == null || singleCaptacao.ContasCaptacao.isEmpty()){
            throw new NotFoundException('Contas de captação não recebidas');
        }
        // Guid da captação
        Lead existingLead = existingLeads[0];
        
        // Se foi passado uma nova média do valor das contas de captação, atualiza valor em lead
        if(singleCaptacao.ValorMedioConta != null){
            existingLead.Valor_Da_Conta__c = singleCaptacao.ValorMedioConta;
            update existingLead;
        }

        // Criação das contas de captação relacionadas ao lead
        List<Conta_de_captacao__c> contasToCreate = new List<Conta_de_captacao__c>();
        for(Captacao.ContasCaptacao singleConta : singleCaptacao.ContasCaptacao){
            
            Conta_de_captacao__c conta = new Conta_de_captacao__c(
                guid__c = singleConta.guid,
                Id__c = singleConta.Id,
                Lead__c = existingLead.Id,
                Link_Arquivo__c = singleConta.LinkArquivo,
                Distribuidora__c = singleConta.Distribuidora,
                Valor_da_conta__c = singleConta.ValorConta
            );
            contasToCreate.add(conta);
        }
        upsert contasToCreate Id__c;
    }

    /**
     * Método responsável por processar a qualificação de uma captação de lead.
     * Ao qualificar um lead, uma oportunidade é criada, em conjunto com uma conta "dummy"
     * Além disso, todas as contas de captação de lead também são vinculadas a oportunidade criada
     * 
     * @param singleCaptacao A captação de lead a ser qualificada.
     * @throws NotFoundException Se o lead não for encontrado.
     * @throws ConvertedLeadException Se o lead já estiver convertido.
     */
    public static void processCaptacaoQualify(Captacao singleCaptacao){

        // Busca lead a ser qualificado
        List<Lead> existingLeads = [
            SELECT Id,IsConverted,CPF_Formatado__c,CNPJ_Formatado__c,CPF__c,CNPJ__c, IsCaptacao__c, OwnerId, Valor_Da_Conta__c 
            FROM Lead 
            WHERE guid__c = :singleCaptacao.guid LIMIT 1
            ];
        // Se não encontrar lead com o guid especificado, lança exceção
        if(existingLeads.isEmpty() || existingLeads == null){
            throw new NotFoundException('Lead não encontrado');
        }
        Lead existingLead = existingLeads[0];
        // Se o lead já estiver convertido, lança exceção
        if(existingLead.IsConverted){
            throw new ConvertedLeadException('Lead já convertido');
        }
        // Se não for um lead de captação
        if(!existingLead.IsCaptacao__c){
            throw new ConvertedLeadException('Não sinalizado como lead de captação');
        }
        String cpf = existingLead.CPF__c;
        String cnpj = existingLead.CNPJ__c;
        Id sdr = existingLead.OwnerId;
        Double valorConta = existingLead.Valor_Da_Conta__c;

        Lead leadToUpdate = new Lead( Id = existingLead.Id, CPF__c = null, CNPJ__c = null, CPF_CNPJ__c = null);
        update leadToUpdate;
        
        system.debug(existingLead);
        system.debug(leadToUpdate);
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(existingLead.Id);
        
        // LeadStatus cLeadStatus = [Select Id,MasterLabel from LeadStatus where isConverted=true limit 1]; // Busca o status padrão de converter lead
        // lc.setConvertedStatus(cLeadStatus.MasterLabel);
        String cLeadStatusName = 'Qualificado';
        lc.setConvertedStatus(cLeadStatusName);

        Database.LeadConvertResult lcr = Database.convertLead(lc);
        if(!lcr.isSuccess()){
            throw new ConvertedLeadException(lcr.getErrors()[0].getMessage()); // Lança exceção com a mensagem de erro caso não seja possível converter o lead
        }
        // Se a conversão do lead foi bem sucedida, vincula contas de captação com a oportunidade criada
        Id oppId = lcr.getOpportunityId();
        List<Conta_de_captacao__c> contasCapLead = [SELECT Id FROM Conta_de_captacao__c WHERE Lead__c = :existingLead.Id];
        for(Conta_de_captacao__c conta_cap : contasCapLead){
            conta_cap.Oportunidade__c = oppId;
        }
        if(!contasCapLead.isEmpty() && contasCapLead != null) update contasCapLead;
        update new Opportunity( Id = oppId, Aprovado_pelo_SDR__c = true ,CPF__c = cpf, CNPJ__c = cnpj, Valor_conta_lead__c = valorConta, Nome_Do_SDR__c=sdr);
    }

    /**
     * Método responsável por processar a conversão de uma captacao em uma proposta.
     * O propósito é vincular o guid o lead ao guid e a oportunidade da proposta
     * Além disso, o CPF/CNPJ é utilizado para mergear com uma conta existente ou adicionar na conta "dummy", que se torna a oficial
     * 
     * @param singleCaptacao A captacao a ser convertida em proposta.
     * @throws NotFoundException Se o CPF/CNPJ não for informado ou se a oportunidade não for encontrada.
     */
    public static void processCaptacaoConvert(Captacao singleCaptacao){
        // Busca chave externa do body
        String externalKey = singleCaptacao.CPF != null ? singleCaptacao.CPF : singleCaptacao.CNPJ;

        // Se não encontrou, lança exceção
        if(externalKey == null){
            throw new NotFoundException('CPF/CNPJ não informado');
        }

        // Formatar external key para remover a máscara
        externalKey = externalKey.replaceAll('[^0-9]', ''); 
        
        // Busca oportunidade baseada no lead da captação
        List<Opportunity> existingOppsByLeadGuid = [
            SELECT  
                Id,guid_lead__c,guid__c,NumeroProposta__c, 
                AccountId, Account.CPFformatado__c, Account.CNPJ_formatado__c, Account.RecordTypeId, Account.CPF__c, Account.CNPJ__c
            FROM    
                Opportunity 
            WHERE   
                guid_lead__c = :singleCaptacao.guid 
            LIMIT 1
        ];
        
        if(existingOppsByLeadGuid.isEmpty() || existingOppsByLeadGuid == null){
            throw new NotFoundException('Oportunidade não encontrada');
        }

        Opportunity existingOpp = existingOppsByLeadGuid[0];

        // Altera o tipo de registro da conta para pessoa física ou jurídica
        String recordTypeName = singleCaptacao.CPF != null ? 'PersonAccount' : 'ContaPJ';
        Id recordTypeId = SObjectType.Account.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId(); 

        // Conta relacionada a oportunidade inicial
        Account oppAccount = existingOpp.Account;
        
        Account acct = new Account( Id = oppAccount.Id );
        // Atualiza o tipo de registro da conta
        if(oppAccount.RecordTypeId != recordTypeId){
            acct.recordTypeId = recordTypeId;
            update acct;
        }


        // Busca conta pré existente com CPF/CNPJ
        List<Account> existingAcct = [
            SELECT 
                Id,CPF__c,CNPJ__c 
            FROM 
                Account 
            WHERE 
                ((CPFformatado__c = :externalKey AND CPFformatado__c != null)  OR 
                (CNPJ_formatado__c = :externalKey AND CNPJ_formatado__c != null)) 
                // Id != :oppAccount.Id
            LIMIT 1
        ];

        system.debug(oppAccount);
        system.debug(acct);
        
        // Definição de atualização da oportunidade
        Opportunity oppToUpdate = new Opportunity(
            Id                              = existingOpp.Id,
            StageName                       = 'Reunião Agendada',
            guid__c                         = singleCaptacao.guid_proposta,
            NumeroProposta__c               = singleCaptacao.NumeroProposta,
            IsCaptacaoProposalCreated__c    = true
        );

        // Se encontrou oportunidade existente, faz o merge
        if(!existingAcct.isEmpty() && existingAcct != null){
            oppToUpdate.CPF__c = existingAcct[0].CPF__c;
            oppToUpdate.CNPJ__c = existingAcct[0].CNPJ__c;
            merge existingAcct[0] oppAccount;
            update oppToUpdate;
            return ;
        }
        
        // Sobrescreve valores de CPF e CNPJ nas contas
        acct.CPF__c          = singleCaptacao.CPF;
        acct.CNPJ__c         = singleCaptacao.CNPJ;
        
        update acct;
        update oppToUpdate;
    }

}