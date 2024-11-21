public with sharing class OpportunityAssignmentHandler extends AbstractAssignmentHandler {
    // protected List<String> NOT_DESIRED_STATUS = new List<String>{'Convertido', 'Desqualificado','Reunião Agendada','Em Espera'};
    protected Set<String> NOT_DESIRED_ORIGINS = new Set<String>{''};
    protected List<String> DISTR_PAP = new List<String>{'CPFL-PAULISTA'};
    protected List<String> ORIGINS_PAP = new List<String>{'Prisma'};
    protected Double BILL_VALUE_LIMIT = 400;
    protected Map<Id,String> instalationMap;
    protected Map<String,List<String>> ORIGINS_PAP_DISTR_MAP;


    /**
     * Método responsável por mapear as instalações relacionadas às oportunidades.
     * 
     * @param records Uma lista de registros SObject contendo as oportunidades.
     */
    private void mapInstalations(List<SObject> records){
        this.instalationMap = new Map<Id,String>();
        List<Instalacao__c> instalations = [SELECT Id, Sigla_Distribuidora__c,Oportunidade__c FROM Instalacao__c WHERE Oportunidade__c IN :records];
        for(Instalacao__c inst : instalations){
            this.instalationMap.put(inst.Oportunidade__c,inst.Sigla_Distribuidora__c);
        }
    }

    /**
     * Método responsável por popular o mapa ORIGINS_PAP_DISTR_MAP com as origens e distribuidoras correspondentes.
     */
    private void populateOriginsDistrPAP(){
        ORIGINS_PAP_DISTR_MAP = new Map<String,List<String>>{
            'Prisma' => new List<String>{'CPFL-PAULISTA'},
            'Zaz' => new List<String>{'CPFL-PAULISTA'}
        };
    }

    protected override List<SObject> routeRecords(List<SObject> records) {
        mapInstalations(records);
        populateOriginsDistrPAP();
        List<Opportunity> opportunitiesDefault = new List<Opportunity>();
        List<Opportunity> opportunitiesSDR = new List<Opportunity>();
        List<SObject> opportunitiesToUpdate = new List<SObject>();

        for (SObject record : records) {
            Opportunity opportunity = (Opportunity) record;
            if (isRecordEligibleForRouting(opportunity)) {
                system.debug('Opportunity Eligible for routing ');
                system.debug(opportunity);
                // String distr = instalationMap.get(opportunity.Id);
                if(opportunity.Aprovado_pelo_SDR__c == true){
                    system.debug('Opportunity approved by sdr ');
                    opportunitiesDefault.add(opportunity);
                }else if(opportunity.Primeira_atribuicao__c == false && isHybridDTD(opportunity)){
                    system.debug('Hybrid DTD');
                    opportunitiesSDR.add(opportunity);
                }
            }
        }
        system.debug(opportunitiesSDR);

        if (!opportunitiesDefault.isEmpty()) {
            List<SObject> updatedOpportunities = assignRecords((List<SObject>)(opportunitiesDefault), 'RoundRobin', 'IS PAP');
            opportunitiesToUpdate.addAll(updatedOpportunities);
        }
        if (!opportunitiesSDR.isEmpty()) {
            List<SObject> updatedOpportunitiesSDR = assignRecords((List<SObject>)(opportunitiesSDR), 'RoundRobin', 'SDR');
            opportunitiesToUpdate.addAll(updatedOpportunitiesSDR);
        }

        return opportunitiesToUpdate;
    }

    protected override Boolean isRecordEligibleForRouting(SObject record) {
        Opportunity opportunity = (Opportunity) record;
        return opportunity.IsClosed == false;
    }

    /**
     * Verifica se uma oportunidade representa um porta a porta híbrido.
     * 
     * @param opportunity A oportunidade a ser verificada.
     * @return Retorna true se a oportunidade for porta a porta híbrida, caso contrário retorna false.
     */
    private Boolean isHybridDTD(Opportunity opportunity){
        String distr = instalationMap.get(opportunity.Id);
        List<String> distrList = this.ORIGINS_PAP_DISTR_MAP.get(opportunity.Nome_do_Parceiro__c);
        Boolean expr =  
            (
                distrList != null && 
                !distrList.isEmpty() 
            ) &&
            (
                distrList.contains(distr)
            );
        system.debug(expr);
        return expr;
    }
}