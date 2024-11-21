@IsTest
private class SingletonFactoryTest {
    
    private class SampleClass{}
    private class SampleClassWithVariable{
        private String name;
    }

    // Teste do método get
    @IsTest
    static void testGetMethod() {
        // Configuração
        Type testType = SampleClass.class;
        
        // Execução
        Object instance1 = SingletonFactory.get(testType);
        Object instance2 = SingletonFactory.get(testType);
        
        // Verificação: Verificar se é o mesmo objeto (singleton)
        System.assertEquals(instance1, instance2, 'The get method should return the same singleton instance');
    }
    
    // Teste do método getStandaloneInstance
    @IsTest
    static void testGetStandaloneInstance() {
        // Configuração
        Type testType = SampleClass.class;
        
        // Execução
        Object standaloneInstance1 = SingletonFactory.getStandaloneInstance(testType);
        Object standaloneInstance2 = SingletonFactory.getStandaloneInstance(testType);
        
        // Verificação: Verificar se são instâncias diferentes (não singleton)
        System.assertNotEquals(standaloneInstance1, standaloneInstance2, 'The getStandaloneInstance method should return a new instance each time');
    }
    
    @IsTest
    static void testSetTypeOverride() {
        // Configuração
        Type actualType = SampleClass.class;
        Type overrideType = SampleClassWithVariable.class;
        
        // Definir o override de tipo
        SingletonFactory.setTypeOverride(actualType, overrideType);
        
        // Execução
        Object instance = SingletonFactory.get(actualType);
        // System.debug(instance instanceof SampleClassWithVariable);
        
        // Verificação: Verificar se a instância é do tipo override
        System.assert(instance instanceof SampleClassWithVariable, 'The get method should return an instance of the override type');
    }
    
    
    
    // // Teste do método setStubProvider
    // @IsTest
    // static void testSetStubProvider() {
    //     // Configuração
    //     Type testType = SampleClass.class;
    //     StubProvider mockStubProvider = new MockProvider();
        
    //     // Definir o stub provider
    //     SingletonFactory.setStubProvider(testType, mockStubProvider);
        
    //     // Execução
    //     Object instance = SingletonFactory.get(testType);
        
    //     // Verificação: Verificar se o stub provider foi utilizado
    //     System.assert(instance instanceof SampleClass, 'The get method should return a stubbed instance');
    // }
}