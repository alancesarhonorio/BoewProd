public class Captacao {

	public String guid;
	public String FirstName;
	public String LastName;
	public String LeadSource;
	public String NomeParceiro;
	public String TipoParceria;

	public String Status;
	public String Phone;
	public String Email;
	public String EmailSDR;
	public Double ValorMedioConta;
	public String Rastreamento;
	public String MotivoPerda;
	public String Campanha;
	public List<ContasCaptacao> ContasCaptacao;

	public String guid_proposta;
	public String CPF;
	public String CNPJ;
	public String NumeroProposta;
	public String TipoRegistro;
	

	public class ContasCaptacao {
		public String guid;
		public String Id;
		public String LinkArquivo;
		public String Distribuidora;
		public Double ValorConta;
	}

	
	public static Captacao parse(String json) {
		return (Captacao) System.JSON.deserialize(json, Captacao.class);
	}
}