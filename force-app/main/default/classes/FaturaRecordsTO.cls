global with sharing class FaturaRecordsTO {
    public class Faturas {
        public SingleFatura[] SingleFatura;
    }
    
    public class SingleFatura {
        public String NumeroFatura;
        public String NumeroInstalacao;
        public String LinkFatura;
        public String MesReferencia;
        public String Status;
        public String CPFouCNPJConta;
        public String NumeroPropostaOportunidade;
        public String Usina;
        public Double ValorFatura;
        public String DataVencimento;
        public String DataPagamento;
        public String Origem;
        public Double kWhContratado;
        public Double Consumo;
        public Double ConsumoHP;
        public Double EnergiaCompensada;
        public Double EnergiaCompensadaHP;
        public Double kWhConcessionaria;
        public Double kWhConcessionariaHP;
        public Double IluminacaoPublica;
        public Double SaldoGeracao;
        public Double SaldoGeracaoHP;
        public Double Economia;
        public Double BonusIndicacao;
        public Double ReembolsoDistribuidora;
        public String DataEmissao;
        public Double ValorPago;
        public Double ValorPagoConcessionaria;
        public String TipoFaturamento;
    }
}