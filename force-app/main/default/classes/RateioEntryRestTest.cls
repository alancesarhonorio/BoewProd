/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class RateioEntryRestTest {

    @isTest
    static void testMakePost() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/RateioEntry/';
        req.httpMethod = 'POST';
        String json = '{'+
            '\"EntradaRateio\":'+
            '{'+
            '	\"idUnidadeConsumidora\":\"456\",'+
            '        \"idRateio\": \"236\",'+
            '        \"numeroInstacao\" : \"123456\",'+
            '	\"dtEnvioRateio\":\"2024-01-01\",'+
            '	\"dtAceiteRateio\":\"2024-01-10\",'+
            '	\"dtLeituraUsina\":\"2024-01-15\",'+
            '	\"dtLeituraCliente\":\"2024-01-18\",'+
            '	\"dtCompensacaoCliente\":\"2024-02-18\",'+
            '	\"primeiraFatura\":\"false\",'+
            '	\"clienteRejeitado\":\"false\",'+
            '	\"syncAtiva\":\"true\"'+
            '}'+
            '}';
        req.requestBody = Blob.valueOf(json);
        RestContext.request = req;
        RestContext.response = res;

        RateioEntryRest.makePost();
    }
}