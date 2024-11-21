@isTest
private class RateioParserTest {

	static testMethod void testParse() {
		String json = '{'+
		'    \"UCRateio\":'+
		'    {'+
		'        \"idUnidadeConsumidora\": \"350\",'+
		'        \"idRateio\": \"370\",'+
		'        \"numeroInstacao\" : \"485200\",'+
		'        \"numeroInstacaoUsina\": \"\",'+
		'        \"dtEnvioRateio\":\"2024-01-01\",'+
		'        \"dtAceiteRateio\": \"2024-01-05\",'+
		'        \"dtLeituraUsina\":\"2024-01-15\",'+
		'        \"mesReferenciaRateio\":\"01/2024\",'+
		'        \"dtLeituraCliente\":\"2024-01-18\",'+
		'    	 \"dtCompensacaoCliente\":\"2024-02-18\",'+
		'        \"clienteRejeitado\":false'+
		'    }'+
		'}';
		RateioParser obj = RateioParser.parse(json);
		System.assert(obj != null);
	}
}