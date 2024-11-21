public class SchedulingQueryBuilder {
    private String baseQuery;
    private List<String> whereClauses;
    private Map<String, Object> params;

    public SchedulingQueryBuilder() {
        this.baseQuery = 'SELECT Id, Usuario__c, Data__c FROM RoutingSettings__c WHERE isActiveUser__c = true';
        this.whereClauses = new List<String>();
        this.params = new Map<String, Object>();
    }

    public SchedulingQueryBuilder withDate(Date dt) {
        this.whereClauses.add('Data__c = :dt');
        this.params.put('dt', dt);
        return this;
    }

    public SchedulingQueryBuilder withSDR(Boolean isSDR) {
        this.whereClauses.add('Usuario__r.SDR__c = :isSDR');
        this.params.put('isSDR', isSDR);
        return this;
    }

    public String buildQuery() {
        if (!whereClauses.isEmpty()) {
            return baseQuery + ' AND ' + String.join(whereClauses, ' AND ');
        } else {
            return baseQuery;
        }
    }

    public Map<String, Object> getParams() {
        return params;
    }

    public List<RoutingSettings__c> execute() {
        String soql = buildQuery();
        system.debug(soql);
        return Database.queryWithBinds(soql, params,AccessLevel.SYSTEM_MODE);
        // return Database.query(soql);
    }
}