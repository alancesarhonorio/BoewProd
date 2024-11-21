public class RateioParser {
    public UCRateio UCRateio;

    public class UCRateio {
        // Identificadores
        public String idUnidadeConsumidora;     // Id único do objeto de UCRateio -> Podemos usar uma combinação de idRateio+instalação tbm
        public String idRateio;                 // Id do rateio que a unidade foi alocada
        public String numeroInstacao;           // Número de instalação da Unidade
        public String numeroInstacaoUsina;      // Número de instalação da Usina

        // Dados Referentes a UC e ao Rateio
        public String dtEnvioRateio;            // Data de envio do rateio
        public String dtAceiteRateio;           // Data de aceite do rateio
        public String dtLeituraUsina;           // Data de leitura da Usina
        public String mesReferenciaRateio;      // Mês de referência do rateio
        
        // Dados referentes somente a UC
        public String dtLeituraCliente;         // Data de próxima leitura do cliente
        public String dtCompensacaoCliente;     // Data de compensação do cliente
        public Boolean clienteRejeitado;        // Flag de cliente rejeitado
        
    }


    public static RateioParser parse(String json) {
        return (RateioParser) System.JSON.deserialize(json, RateioParser.class);
    }
}