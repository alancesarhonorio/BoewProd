/**
 * Essa classe é responsável pela comunicação entre o trigger e a chamada Http de callout
 * O motivo dessa classe é o fato de que não podemos chamar síncronamente um callout no trigger, portanto precisamos de uma classe assincrona
 * O decorador @future define que é uma função assíncrona
 * 
 */
public class leadCalloutHandler {
    @future(callout = true)
    public static void sendOutbound(List<String> CustomersBody){
        for(String body : CustomersBody){
            HttpResponse res = truoraCallouts.sendOutboundMessage(body);
            if(res.getStatusCode() == 200){
                System.debug('Sucesso!');
            }
        }
    }
}