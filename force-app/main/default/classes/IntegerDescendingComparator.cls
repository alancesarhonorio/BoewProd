// Create a custom comparator class
public class IntegerDescendingComparator implements Comparator<Integer> {
    public Integer compare(Integer num1, Integer num2) {
        // Reverse the typical comparison for descending order
        if (num1 > num2) {
            return -1;
        } else if (num1 < num2) {
            return 1; 
        } else {
            return 0;
        }
    }
}