global with sharing class ContactRecordsTO {
    public class Contacts {
        public SingleContact[] SingleContact;
    }
    
    public class SingleContact {
        public String        Cargo;
        public String        Department;
        public String        EstadoCivil;
        public String        FirstName;
        public String        LastName;
        public String        Title;
        public String        RegimeCasamento;
        public String        RG;
        public String        Phone;
        public String        OrgaoEmissor;
        public String        Email;
        public Client        Client;
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
        public String  Type;
        public String  RecordTypeId;
    }

}