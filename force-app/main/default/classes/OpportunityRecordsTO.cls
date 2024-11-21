global with sharing class OpportunityRecordsTO {
    public class Opportunities {
        public SingleOpportunity[] SingleOpportunity;
    }
    
    public class SingleOpportunity {
        public String        OpportunityGuid;
        public String        NumeroProposta;
        public String        AvisoPrevioRescisao;
        public Boolean       BudgetConfirmed;
        public String        ForecastCategoryName;
        public String        Campanha;
        public String        Contrato;
        public String        CPF;
        public String        CloseDate;
        public String        DataNascimento;
        public String        Description;
        public Boolean       DiscoveryCompleted;
        public String        DocumentoIndicador;
        public String        EstadoCivil;
        public String        Faturamento;
        public String        FimContrato;
        public String        InicioContrato;
        public String        IdPropostaIndicador;
        public String        LossReason;
        public String        MotivoCancelamento;
        public String        MotivoPerda;
        public String        Name;
        public String        NomeParceiro;
        public String        NumeroCliente;
        public String        LeadSource;
        public String        LinkProposta;
        public String        Plano;
        public Integer       Probability;
        public String        Profissao;
        public String        Rastreamento;
        public String        RegimeCasamento;
        public String        RepresentanteVendas;
        public String        RepresentanteLegal;
        public String        RG;
        public Boolean       ROIAnalysisCompleted;
        public String        SituacaoContrato;
        public String        StageName;
        public String        SubmotivoPerda;
        public String        TempoPermanencia;
        public String        TipoParceria;
        public String        Type;
        public String        OrgaoEmissor;
        public Client        Client;
        public Instalation[] Instalations;
        public ResponsavelFinanceiro ResponsavelFinanceiro;
    }

    public class ResponsavelFinanceiro {
        public String  Nome;
        public String  Email;
        public String  Telefone;
    }

    public class Client {
        public Double  BonusResidual;
        public Double  BonusIndicacao;
        public String  Categoria;
        public String  Jigsaw;
        public String  CNPJ;
        public String  CNPJFormatado;
        public String  CPF;
        public String  DataPrimeiroContrato;
        public String  Description;
        public String  Email;
        public String  EmailNotificacao;
        public String  SicDesc;
        public Integer NumberOfEmployees;
        public String  Name;
        public String  NumeroCliente;
        public String  AccountSource;
        public String  Industry;
        public String  Website;
        public String  SituacaoConta;
        public String  Subsegmento;
        public String  Phone;
        public String  TelefoneSecundario;
        public String  Type;
        public String  RecordTypeId;
    }

    public class Instalation {
        public String guid;
        public String NumeroInstalacao;
        public String NumeroCliente;
        public String CEP;
        public String Cidade;
        public String DataInstalacao;
        public String EmailRecebimentoFatura;
        public String EstadoProvincia;
        public String Pais;
        public String Rua;
        public String Status;
        public String UFDistribuidora;
        public String DistribuidoraEnergia;
        public String SiglaDistribuidora;
        public String ModalidadeTarifaria;
        public String MediaRealConsumoKWh;
        public String TipoConexao;
        public String UsinaCadastrada;
        public Double ValorKwh;
        public Double Amount;
        public Double VolumeContratado;
        public String Desconto;
        public Boolean InstalacaoAlocada;
        public Boolean RateioAprovadoIntalacao;
        public Boolean syncAtiva;
        public String DataAtualLeitura;
        public String DataProximaLeitura; 
        public Boolean AutoconsumoRemoto;
        public String[] EmailsAlternativos;
    }
}