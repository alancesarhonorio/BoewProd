public class SiteStatusMapper {
    private static final Map<String, String> statusMap = new Map<String, String>{
        'Contato Iniciado'  => 'CONTATO_INICIADO',
        'Em Qualificação'   => 'EM_ANALISE',
        'Aguardando Fatura' => 'AGUARDANDO_FATURA',
        'Desqualificado'    => 'DESQUALIFICADO'
    };

    // Recebe o status interno como String e retorna o status externo
    public static String mapToExternalStatus(String internalStatus) {
        return statusMap.get(internalStatus);
    }
}