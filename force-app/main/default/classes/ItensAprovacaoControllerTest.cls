@IsTest
public class ItensAprovacaoControllerTest {

    @TestSetup
    static void setup(){ 
        
        Account conta1      = new Account();
        conta1.Name         = 'MIRLA SILVA MIRANDA DE HOLANDA';
        conta1.CPF__c      = '026.921.681-27';
        conta1.Email__c = 'sidneisantanamirlatest@gmail.com';
        conta1.Phone = '+556599348899';
        insert conta1;
        
        
        Contact ctt = new Contact();
        ctt.LastName = 'Conta 1';
        ctt.FirstName = 'TESTE';
        ctt.AccountId = conta1.Id;
        insert ctt;
        
        Date dataFechamento = Date.newInstance(2024, 6, 30);
        Opportunity opp = new Opportunity();
        opp.Name = 'MIRLA SILVA MIRANDA DE HOLANDA';
        opp.Aprovado_pelo_SDR__c = false;
        opp.CPF__c = '026.921.681-27';
        opp.Profissao__c = 'Autônoma';
        opp.RG__c = '20008201';
        opp.NumeroCliente__c = '645061165';
        opp.AccountId = conta1.Id;
        opp.StageName = 'Qualificado';
        opp.LeadSource = 'Site';
        opp.CloseDate = dataFechamento;
        insert opp;

    }
    
    @IsTest 
    public static void ItensAprovarTest() {
        
        List<Opportunity> lstProcessInstanceWorkItem =  [SELECT Id, Aprovado_pelo_SDR__c, name, NumeroProposta__c, OwnerId, CreatedDate
                                                         FROM Opportunity
                                                         WHERE Aprovado_pelo_SDR__c = false];
        
        ItensAprovacaoController.ItensAprovar(lstProcessInstanceWorkItem[0].OwnerId);
    }
    
    @IsTest
    public static void testGetTotalCount() {
        Integer totalCount = ItensAprovacaoController.gettotalcount();
        System.assertEquals(1, totalCount);
    }
    
     @IsTest
    public static void testGetSubmittedRecords() {
        List<ItensAprovacaoController.SubmittedRecordsWrapper> records = ItensAprovacaoController.getSubmittedRecords(null, null);
        System.assertEquals(true, records != null);
        Integer expectedCount = 1; 
        System.assertEquals(expectedCount, records.size());
        List<Opportunity> filteredOpps = [SELECT Id FROM Opportunity WHERE Aprovado_pelo_SDR__c = false];
        System.assertEquals(expectedCount, filteredOpps.size());
    }    
    
    
    
    @IsTest
    public static void processRecordsTest() {
        List<Opportunity> filteredOpps = [SELECT Id, name, LeadSource, NumeroProposta__c, StageName FROM Opportunity WHERE Aprovado_pelo_SDR__c = false];
        
        List<ItensAprovacaoController.SubmittedRecordsWrapper> wraprecs = new List<ItensAprovacaoController.SubmittedRecordsWrapper>();
        
        
        for (Opportunity ps : filteredOpps) {
                    ItensAprovacaoController.SubmittedRecordsWrapper objSubmittedRecordsWrapper = new ItensAprovacaoController.SubmittedRecordsWrapper(); 
                                  objSubmittedRecordsWrapper.workItemId = ps.Id;
                                  objSubmittedRecordsWrapper.recordId = ps.Id;
                                  objSubmittedRecordsWrapper.recordName = ps.Name;
                                  objSubmittedRecordsWrapper.origemLead = ps.LeadSource;
                                  objSubmittedRecordsWrapper.relatedTo = ps.NumeroProposta__c;
                                  objSubmittedRecordsWrapper.stageName = ps.StageName;
                                  wraprecs.add(objSubmittedRecordsWrapper);
        }
        
        String strwraprecs = System.JSON.serialize(wraprecs);
        String message = ItensAprovacaoController.processRecords('Approve', strwraprecs);
        System.assert(message.contains('Todos os registros forão atualizados com sucesso.'));
    }

}