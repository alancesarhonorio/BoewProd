//
// Clase para armazenar funcoes utilitárias do dia-a-dia
//
public class Utils {
    //
    // Essa função recebe o nome de um objeto e extrai o 'Nome do campo', 'Nome de API' e o 'Tipo do campo' para um arquivo '.txt'
    // Caso o objeto seja personalizado, inclua o sufixo '__c' no nome do objeto.
    // O Arquivo gerado está disponível no objeto 'Arquivos'
    //
    public static void ExtrairNomesDeAPI(String NomeObjeto) {
        String fileName = NomeObjeto+'.txt';
        String fileContent = '';
        
        // Para cada campo do objeto, registra em uma linha os valores do rótulo de campo, nome de api e tipo do campo.
        Map<String, Schema.SObjectField> fieldsMap = Schema.getGlobalDescribe().get(NomeObjeto).getDescribe().fields.getMap(); // Mapeia todos os campos do objeto.
        for (String fieldName : fieldsMap.keySet()) {
            Schema.DescribeFieldResult fieldResult = fieldsMap.get(fieldName).getDescribe(); 
            String fieldType = String.valueOf(fieldResult.getType());
            String fieldLabel = fieldResult.getLabel();
            fileContent += fieldLabel + ',' + fieldName + ',' + fieldType + '\n';
        }

        // Cria um arquivo no salesforce e armazena os valores coletados anteriormente nele
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = fileName;
        contentVersion.PathOnClient = fileName;
        contentVersion.VersionData = Blob.valueOf(fileContent);
        contentVersion.FirstPublishLocationId = UserInfo.getUserId();

        insert contentVersion;
    }
    //
    // Essa função recebe o telefone de um contato e retorna no formato de Messaging para WhatsApp. Ex: 'whatsapp:+5599999999'
    // Formato: '+55' + DDD + Número sem o digito '9' inicial
    // Essa função assume que o número inicial possui o 9 
    //
    public static String createWhatsappPhoneNumber(String phoneNumber) {
        String formattedNumber = '';
        if (phoneNumber != null && phoneNumber.length() >= 10) {
            // Remove all non-digit characters from the phone number
            String digitsOnly = phoneNumber.replaceAll('[^0-9]', '');
            String DDD = '';
            System.debug(digitsOnly);
            // Verifica qual tipo de número é passado
            if(digitsOnly.length() <= 11){ //Numero sem o 55
                DDD = digitsOnly.substring(0, 2);  
            }
            else if(digitsOnly.length() <= 13){ //Numero com o 55
                DDD = digitsOnly.substring(2, 4);  
            }
            // Como o whatsapp identifica o número sem o '9' inicial, aqui também é retornado sem o 9.
            String lastEight = digitsOnly.substring(digitsOnly.length() - 8);
            formattedNumber = 'whatsapp:+55' + DDD + lastEight;
        }
        System.debug(formattedNumber);
        return formattedNumber;
    }

    //
    // Essa função recebe o telefone de um contato e retorna em um formato específico para integração da 55PBX
    // Formato: '+55' + DDD + Número
    //
    public static String formatPhoneNumber(String phoneNumber) {
        
        // Remove todos os caracteres não-numericos
        String digitsOnly = phoneNumber.replaceAll('[^0-9]', '');
        String formattedNumber = digitsOnly;
        if (digitsOnly != null && digitsOnly.length() >= 10) {
            if(!digitsOnly.startsWith('55')){
                formattedNumber = '+55' + digitsOnly;    
            }
            else{
                // Adiciona o + apenas se tiver DDD
                if(digitsOnly.substring(2).length() >= 10 ){
                    formattedNumber = '+' + digitsOnly;
                }
                
            }
        }
        //System.debug(formattedNumber);
        return formattedNumber;
    }


    // Método que extrai informações de texto longo dado duas strings
    public static String extractInformationFromLongText(String input, String startMarker, String endMarker) {
        String result = '';
        Integer startIndex = input.indexOf(startMarker);
        if (startIndex != -1) {
            startIndex += startMarker.length();
            Integer endIndex = input.indexOf(endMarker, startIndex);
            if (endIndex != -1) {
                result = input.substring(startIndex, endIndex).trim();
            }
        }
        return result;
    }

    //Função para transformar String em Datetime
    public static Datetime convertToDateTime(String input) {
        Datetime dateTimeValue;
        //String myDate = '06/08/2013 06:30:22';
        try {
            String stringDate = input.substring(6,10) + '-' + 
                                input.substring(3,5) + '-' +
                                input.substring(0,2) + ' ' +
                                input.substring(11,19);
            dateTimeValue = Datetime.valueOf(stringDate);
            System.debug(String.valueOfGmt(dateTimeValue));
        } catch (Exception e) {
            System.debug('Erro ao converter string para Data/hora: ' + e.getMessage());
            dateTimeValue = null;
        }
        
        return dateTimeValue;
    }

    public static Boolean validateEmail(String email) {
        if(email == null) return false;
        Boolean res = true;
        String emailRegex = '^[a-zA-Z0-9._|\\\\%⌗~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$'; 
        Pattern MyPattern = Pattern.compile(emailRegex);
        Matcher MyMatcher = MyPattern.matcher(email);
        if (!MyMatcher.matches()) 
            return false;
        return true;
    }


    /**
     * Cria uma versão mascarada de um CPF (número de identificação brasileiro).
     * 
     * @param cpf O CPF a ser mascarado.
     * @return O CPF mascarado.
     */
    public static String createCpfMask(String cpf){
        String cpfMask = cpf;
        String cpfOnlyDigits = cpf.replaceAll('[^0-9]', '');
        if(cpfOnlyDigits != null && cpfOnlyDigits.length() == 11){
            cpfMask = cpfOnlyDigits.substring(0,3) + '.' +
                cpfOnlyDigits.substring(3,6) + '.' + 
                cpfOnlyDigits.substring(6,9) + '-' + 
                cpfOnlyDigits.substring(9,11);
        }
        return cpfMask;
    }

    /**
     * Cria uma máscara formatada para CNPJ (Cadastro Nacional de Pessoa Jurídica).
     * 
     * @param cnpj O CNPJ a ser formatado.
     * @return O CNPJ formatado com a máscara aplicada.
     */
    public static String createCnpjMask(String cnpj){
        String cnpjMask = cnpj;
        String cnpjOnlyDigits = cnpj.replaceAll('[^0-9]', '');
        if(cnpjOnlyDigits != null && cnpjOnlyDigits.length() == 14){
            cnpjMask = cnpjOnlyDigits.substring(0,2) + '.' + 
                cnpjOnlyDigits.substring(2,5) + '.' +
                cnpjOnlyDigits.substring(5,8) + '/' + 
                cnpjOnlyDigits.substring(8,12) + '-' + 
                cnpjOnlyDigits.substring(12,14);
        }
        return cnpjMask;        
    }

    // private static Boolean isCaptacaoSource(Lead lead){
    //     return lead.LeadSource == 'Landing Page' || lead.LeadSource == 'Redes Sociais';
    // }
    
    public static Integer calcularDiasUteisEntreDatas(Date date1, Date date2, List<Holiday> feriados){
        Integer diasEntre = date1.daysBetween(date2);
        Integer diasUteis = 0;

        for(Integer k = 0; 
            k < diasEntre ;
            k++ )
        {
            if(verificaDiaUtil(date1.addDays(k), feriados))
            {
                diasUteis++;
            } 
           
        }
        

         return diasUteis + 1;
    }

    
    
    public static boolean verificaDiaUtil(Date dataAtual, List<Holiday> feriados){
        Date inicioSemana  = dataAtual.toStartofWeek();

        for(Holiday feriado : feriados)
        {
            if(dataAtual.daysBetween(feriado.ActivityDate) == 0)
            {
                return false;
            }
        }

        if(inicioSemana.daysBetween(dataAtual) == 0 || inicioSemana.daysBetween(dataAtual) == 6)
        {
            return false;
        } 
        else 
        {
            return true;
        }
    }

    public static DateTime getNextBusinessDatetime(String businessHoursName, DateTime dt){
        
        Boolean bh = CheckBusinessHours.checkSingleBusinessHoursByNameAndDate(businessHoursName,dt);
        Date dataAtual = dt.date();
        HolidayDAO holiday = (HolidayDAO) HolidayDAO.getInstance();
        List<Holiday> holidays = holiday.getHolidays();
        
        // Checar se está dentro do horário de funcionamento
        if(bh && verificaDiaUtil(dataAtual,holidays)){
            return dt;
        }
        // Se não está, buscar próxima data/hora de funcionamento
        Boolean dateFound = false;
        while (!dateFound) {
            dataAtual = dataAtual.addDays(1);
            if(verificaDiaUtil(dataAtual, holidays)){
                dateFound = true;
            }
        }
        return DateTime.newInstance(dataAtual, Time.newInstance(9, 0, 0, 0));
    }
    
      
    public static Date calcularProximoDiaUtil(Date dataCalcular, List<Holiday> lstFeriados)
    {
        Date dataCalculada = dataCalcular;

        if(!verificaDiaUtil(dataCalculada, lstFeriados))
        {
            if(verificaDiaUtil(dataCalculada.addDays(1), lstFeriados))
                dataCalculada = dataCalculada.addDays(1);
            else if(verificaDiaUtil(dataCalculada.addDays(2), lstFeriados))
                dataCalculada = dataCalculada.addDays(2);
            else if(verificaDiaUtil(dataCalculada.addDays(3), lstFeriados))
                dataCalculada = dataCalculada.addDays(3);
            else if(verificaDiaUtil(dataCalculada.addDays(4), lstFeriados))
                dataCalculada = dataCalculada.addDays(4);
        }

        return dataCalculada;
    }
        
    // public static Integer getNoOfBusinessDaysBetweenDates(Date startDate, Date endDate){

    //     Integer count = 0;
        
    //     BusinessHours bHours = [SELECT Id FROM BusinessHours WHERE IsDefault = true limit 1];
        
    //     while(startDate <= endDate){
    //         if(BusinessHours.isWithin(bHours.Id, startDate)){
    //             count++;
    //         }
    //         startDate = startDate.addDays(1);
    //     }
    //     return count;
    // }    
    
     public static Date calcularDesqualificar(Date dataCalcular, List<Holiday> lstFeriados)
    { 
        Integer prazo = 0;
        Date temp;
        
        if (!verificaDiaUtil(dataCalcular, lstFeriados)){
            prazo++;
            temp = dataCalcular.addDays(prazo + 6);
        }
        if (verificaDiaUtil(dataCalcular, lstFeriados)){
            prazo++;
            temp = dataCalcular.addDays(prazo + 6);
        }
         return temp;
    }

}