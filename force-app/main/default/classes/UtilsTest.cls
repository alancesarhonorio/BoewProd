@isTest
public class UtilsTest {
    @TestSetup
    static void makeData(){
        
    }
    // Teste para a função de extrair nomes de api dos campos
    // Usamos um objeto Accout para fazer os testes. Testamos se foi criado um arquivo no sistema
    @isTest
    public static void ExtrairNomesDeAPITest() {
        String obj = 'Account';
        String fileName = 'Account.txt';
        Utils.ExtrairNomesDeAPI(obj);
        List<ContentVersion> Files = new List<ContentVersion>();
        for(ContentVersion file : [
            SELECT ContentVersion.title
            FROM ContentVersion
            WHERE ContentVersion.title = : fileName
        ]){
            Files.add(file);
        }

        System.assertEquals(1, Files.size());
        System.assert(!Files.isEmpty());
    }
    
    // Teste para a função de formatar números para serem reconhecidos pelo messaging
    @isTest
    public static void createWhatsappPhoneNumberTest() {
        System.assertEquals('whatsapp:+553186551353', Utils.createWhatsappPhoneNumber('+5531986551353'));
        System.assertEquals('whatsapp:+553186551353', Utils.createWhatsappPhoneNumber('31986551353'));
        System.assertEquals('whatsapp:+553186551353', Utils.createWhatsappPhoneNumber('+55 (31) 98655-1353'));
        System.assertEquals('whatsapp:+553186551353', Utils.createWhatsappPhoneNumber('(31) 98655-1353'));
        System.assertEquals('whatsapp:+553186551353', Utils.createWhatsappPhoneNumber('(31) 986551353'));
        System.assertEquals('whatsapp:+553186551353', Utils.createWhatsappPhoneNumber('(31) 98655 1353'));
        System.assertEquals('whatsapp:+553186551353', Utils.createWhatsappPhoneNumber('31 98655 1353'));
        System.assertEquals('whatsapp:+553186551353', Utils.createWhatsappPhoneNumber('5531986551353'));
        System.assertEquals('whatsapp:+553186551353', Utils.createWhatsappPhoneNumber('55 3198655 1353'));
        System.assertEquals('whatsapp:+553134861064', Utils.createWhatsappPhoneNumber('553134861064'));
        System.assertEquals('whatsapp:+553134861064', Utils.createWhatsappPhoneNumber('55 31 3486 1064'));
        System.assertEquals('whatsapp:+553134861064', Utils.createWhatsappPhoneNumber('3134861064'));
        System.assertEquals('whatsapp:+553134861064', Utils.createWhatsappPhoneNumber('(31)3486-1064'));
    }

    // Teste para a função de formatar números para serem reconhecidos pelo messaging
    @isTest
    public static void formatPhoneNumberTest() {
        // Telefone celular
        System.assertEquals('+5531986551353', Utils.formatPhoneNumber('+5531986551353'));
        System.assertEquals('+5531986551353', Utils.formatPhoneNumber('31986551353'));
        System.assertEquals('+5531986551353', Utils.formatPhoneNumber('+55 (31) 98655-1353'));
        System.assertEquals('+5531986551353', Utils.formatPhoneNumber('(31) 98655-1353'));
        System.assertEquals('+5531986551353', Utils.formatPhoneNumber('(31) 986551353'));
        System.assertEquals('+5531986551353', Utils.formatPhoneNumber('(31) 98655 1353'));
        System.assertEquals('+5531986551353', Utils.formatPhoneNumber('31 98655 1353'));
        System.assertEquals('+5531986551353', Utils.formatPhoneNumber('5531986551353'));
        System.assertEquals('+5531986551353', Utils.formatPhoneNumber('55 3198655 1353'));
        
        // Telefone Fixo
        System.assertEquals('+553134861064', Utils.formatPhoneNumber('553134861064'));
        System.assertEquals('+553134861064', Utils.formatPhoneNumber('+553134861064'));
        System.assertEquals('+553134861064', Utils.formatPhoneNumber('55 31 3486 1064'));
        System.assertEquals('+553134861064', Utils.formatPhoneNumber('3134861064'));
        System.assertEquals('+553134861064', Utils.formatPhoneNumber('(31)3486-1064'));

        //Casos que nada deve ser feito (Não é possivel identificar o ddd)
        System.assertEquals('5534861064', Utils.formatPhoneNumber('5534861064'));
        System.assertEquals('55986551353', Utils.formatPhoneNumber('55986551353'));
        System.assertEquals('34861064', Utils.formatPhoneNumber('34861064'));
        System.assertEquals('934861064', Utils.formatPhoneNumber('934861064'));
        System.assertEquals('34861064', Utils.formatPhoneNumber('34 86 10 64'));
        System.assertEquals('934861064', Utils.formatPhoneNumber('9 34 86 10 64'));
    }

    // Teste para a função de formatar números para serem reconhecidos pelo messaging
    @isTest
    public static void extractInformationFromLongTextTest() {
        // Telefone celular
        System.assertEquals('06/07/2023', Utils.extractInformationFromLongText('Data da ligação: 06/07/2023 Tipo de Chamada: Ativo Duração: 00h 02m 50s Fila:2687','Data da ligação:','Tipo de Chamada:'));
        System.assertEquals('Ativo', Utils.extractInformationFromLongText('Data da ligação: 06/07/2023 Tipo de Chamada: Ativo Duração: 00h 02m 50s Fila:2687','Tipo de Chamada:','Duração'));
    }

    // Teste para a função de converter string em DateTime
    @isTest
    public static void convertToDateTimeTest() {
        // Test case 1: Valid date/time string
        String inputString1 = '26/11/2023 10:30:00';
        Datetime expectedDatetime1 = Datetime.newInstance(2023, 11, 26, 10, 30, 0);
        Datetime actualDatetime1 = Utils.convertToDateTime(inputString1);
        System.assertEquals(expectedDatetime1, actualDatetime1, 'Test case 1 failed');
        
        // Test case 2: Invalid date/time string
        String inputString2 = '10/13/2023';
        Datetime expectedDatetime2 = null;
        Datetime actualDatetime2 = Utils.convertToDateTime(inputString2);
        System.assertEquals(expectedDatetime2, actualDatetime2, 'Test case 2 failed');
        
    }
    // Teste para validação de email usando regex
    @isTest
    public static void validateEmailTest(){
        //Válidos
        System.assertEquals(true, Utils.validateEmail('testewender@gmail.com'));
        System.assertEquals(true, Utils.validateEmail('teste.wender@gmail.com'));
        System.assertEquals(true, Utils.validateEmail('testewender@gmail.com.br'));
        System.assertEquals(true, Utils.validateEmail('teste-wender233@gov.mg.com'));

        //Inválidos
        System.assertEquals(false, Utils.validateEmail('teste@wender233@ggmail.com'));
        System.assertEquals(false, Utils.validateEmail('teste-wender233@gov'));
        System.assertEquals(false, Utils.validateEmail('teste-wender233@gmail.com xyz'));
        System.assertEquals(false, Utils.validateEmail('teste-wender233gmail.com'));

    }
    
    @isTest
    static void testCreateCpfMask(){
        System.assertEquals('123.456.789-01', Utils.createCpfMask('12345678901'), 'CPF não tratado corretamente');
        System.assertEquals('123.456.789-01', Utils.createCpfMask('123.45678901'), 'CPF não tratado corretamente');
        System.assertEquals('123.456.789-01', Utils.createCpfMask('123.456.78901'), 'CPF não tratado corretamente');
        System.assertEquals('123.456.789-01', Utils.createCpfMask('123.456.789-01'), 'CPF não tratado corretamente');
        System.assertEquals('123.456.789-01', Utils.createCpfMask('123-456-789-01'), 'CPF não tratado corretamente');
        System.assertEquals('1234567891', Utils.createCpfMask('1234567891'), 'CPF não tratado corretamente');
    }

    @isTest
    static void testCreateCnpjMask(){
        System.assertEquals('73.802.534/0001-05', Utils.createCnpjMask('73802534000105'), 'CNPJ não tratado corretamente');
        System.assertEquals('73.802.534/0001-05', Utils.createCnpjMask('73802534/0001-05'), 'CNPJ não tratado corretamente');
        System.assertEquals('73.802.534/0001-05', Utils.createCnpjMask('73.802.534/0001-05'), 'CNPJ não tratado corretamente');
        System.assertEquals('73.802.534/0001-05', Utils.createCnpjMask('73802-534/0001-05'), 'CNPJ não tratado corretamente');
        System.assertEquals('73.802.534/0001-05', Utils.createCnpjMask('73-802-534/0001-05'), 'CNPJ não tratado corretamente');
        System.assertEquals('7380253400010', Utils.createCnpjMask('7380253400010'), 'CNPJ não tratado corretamente');
    }
@isTest
    private static void testCalcularDiasUteisEntreDatas() {
        Date dataInicio = Date.newInstance(2023, 09, 12);
        Date dataFim = Date.newInstance(2023, 09, 25);
        List<Holiday> feriados = new List<Holiday>();

        Test.startTest();
        Integer resultado = Utils.calcularDiasUteisEntreDatas(dataInicio, dataFim, feriados);
        Test.stopTest();

        System.assertEquals(10, resultado, 'Dias entre datas devem ser 10');
    }
@isTest
    static void testVerificaDiaUtil() {
        
        Holiday feriado = new Holiday(Name = 'Test Holiday', ActivityDate = Date.newInstance(2024, 10, 10), isAllDay = true);
        insert feriado;

        List<Holiday> feriados = new List<Holiday>();
        feriados.add(feriado);

        Test.startTest();
        Boolean diaUtil = Utils.verificaDiaUtil(Date.newInstance(2024, 10, 11), feriados);
        Boolean diaNaoUtil = Utils.verificaDiaUtil(Date.newInstance(2024, 10, 12), feriados);
        Boolean diaNaoUtilFeriado = Utils.verificaDiaUtil(Date.newInstance(2024, 10, 10), feriados);
        Test.stopTest();

        System.assertEquals(true, diaUtil, 'Dia útil esperado');
        System.assertEquals(false, diaNaoUtil, 'Dia não útil esperado');
        System.assertEquals(false, diaNaoUtilFeriado, 'Dia de feriado esperado');
    }

    @isTest
    private static void testGetNextBusinessDatetime(){
        Holiday h1 = new Holiday(Name = 'Teste Feriado Prolongado', ActivityDate = Date.newInstance(2024, 11, 08), isAllDay = true);
        insert h1;
        Holiday h2 = new Holiday(Name = 'Teste Feriado', ActivityDate = Date.newInstance(2024, 11, 07), isAllDay = true);
        insert h2;
        // Cenário 1: Data dentro do horário comercial em um dia útil
        DateTime dt1 = DateTime.newInstance(2024, 10, 29, 10, 0, 0);
        DateTime expected = DateTime.newInstance(2024, 10, 29, 10, 0, 0);

        DateTime dt2 = DateTime.newInstance(2024, 11, 07, 10, 0, 0);
        DateTime expected2 = DateTime.newInstance(2024, 11, 11, 9, 0, 0);

        System.assertEquals(expected, Utils.getNextBusinessDatetime('default',dt1));
        System.assertEquals(expected2, Utils.getNextBusinessDatetime('default',dt2));
    }


@isTest
    private static void testCalcularProximoDiaUtil()
    {
        Holiday feriado = new Holiday(Name = 'Test Holiday', ActivityDate = Date.newInstance(2024, 10, 11), isAllDay = true);
        insert feriado;
        
        Test.startTest();
        Date data1 = Date.newInstance(2024, 10, 11);
        Date dataCalculada1 = Utils.calcularProximoDiaUtil(data1, new List<Holiday>{feriado});
        Test.stopTest();
        System.assertEquals(Date.newInstance(2024, 10, 14), dataCalculada1, 'Data errada para data1');
    }
@isTest
    static void testCalcularDesqualificar() {

        
        Test.startTest();
        Date resultado = Utils.calcularDesqualificar(Date.newInstance(2024, 10, 11), new List<Holiday>());
        Test.stopTest();   
        
        Date expectedResult = Date.newInstance(2024, 10, 18);
        
        System.assertEquals(expectedResult, resultado, 'Data não correta');
    }
}