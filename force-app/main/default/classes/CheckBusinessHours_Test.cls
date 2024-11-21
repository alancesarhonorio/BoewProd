@isTest
public class CheckBusinessHours_Test {
	
    static BusinessHours bh;
    
    @testSetup
    static void setup() {
		CheckBusinessHours_Test.bh = [SELECT Name from BusinessHours where isDefault = true];
    }
    
    static testMethod void checkBusinessHoursByName() {
        // Becase we can't insert our own BusinessHours object (DML prevented by SF), we can't reliably test that this
        // is correctly returning if we are or aren't within business hours. Best we can do is try load the default
        // and at least call some of the code
        List<String> input = new List<String>();
        if (CheckBusinessHours_Test.bh != null) {
            input.add(CheckBusinessHours_Test.bh.Name);
        }
        else {
	        input.add('default');
        }
        Boolean result = CheckBusinessHours.checkBusinessHoursByName(input)[0];
        System.assert(result, 'No results returned.');
        result = CheckBusinessHours.checkSingleBusinessHoursByNameAndDate(input[0],System.now());
        System.assert(result, 'No results returned.');
    }
}