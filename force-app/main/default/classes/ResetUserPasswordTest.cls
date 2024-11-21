@isTest 
public class ResetUserPasswordTest {
    
    @TestVisible
    static User newUser;
    
    @TestSetup
    static void createTestData() {
        Profile profile1 = [Select Id from Profile where name = 'Administrador do sistema'];

        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now())
            .replace(' ', '')
            .replace(':', '')
            .replace('-', '');
        Integer randomInt = Integer.valueOf(math.rint(math.random() * 1000000));
        String uniqueName = orgId + dateString + randomInt;
        
        newUser = new User(
            ProfileId = profile1.Id,
            Username = uniqueName + '@test.' + orgId + '.org',
            Alias = 'batman',
            Email='bruce.wayne@wayneenterprises.com',
            EmailEncodingKey='UTF-8',
            Firstname='Bruce',
            Lastname='Wayne',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago'
            );
        insert newUser;
    }
    
    // This is the addtional method that we call at the start of every test to
    //   make sure that data is populated in our static variables.
    // Annoying, but querying is purported to be faster than inserting test records
    static void doSetup(){
        newUser = [SELECT Id FROM User WHERE Email = 'bruce.wayne@wayneenterprises.com' LIMIT 1];
    }
    
    @isTest
    public static void resetUserPasswordSingle()
    {
        doSetup();
        List<ResetUserPassword.ResetUserPasswordInput> requests = new List<ResetUserPassword.ResetUserPasswordInput>();
        
        ResetUserPassword.ResetUserPasswordInput req = new ResetUserPassword.ResetUserPasswordInput();
        req.userId = ResetUserPasswordTest.newUser.Id;
        requests.add(req);
        
        List<Boolean> results = ResetUserPassword.resetUserPassword(requests);
        
        System.assert(results.size() >= 1 && results[0]);
    }
    
    @isTest
    public static void resetUserPasswordList()
    {
        doSetup();
        List<ResetUserPassword.ResetUserPasswordInput> requests = new List<ResetUserPassword.ResetUserPasswordInput>();
        
        ResetUserPassword.ResetUserPasswordInput req = new ResetUserPassword.ResetUserPasswordInput();
        req.listOfUserIds = new List<String>();
        req.listOfUserIds.add(ResetUserPasswordTest.newUser.Id);
        requests.add(req);
        
        List<Boolean> results = ResetUserPassword.resetUserPassword(requests);
        
        System.assert(results.size() >= 1 && results[0]);
    }
    
    @isTest
    public static void resetUserPasswordFail()
    {
        List<ResetUserPassword.ResetUserPasswordInput> requests = new List<ResetUserPassword.ResetUserPasswordInput>();
        
        ResetUserPassword.ResetUserPasswordInput req = new ResetUserPassword.ResetUserPasswordInput();
        requests.add(req);
        
        List<Boolean> results = ResetUserPassword.resetUserPassword(requests);
        
        System.assert(results.size() >= 1 && !results[0]);
    }

}