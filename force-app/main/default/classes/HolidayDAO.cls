public class HolidayDAO {

	public static HolidayDAO instance = new HolidayDAO();

	public static HolidayDAO getInstance() {
		return instance;
	}

	public List<Holiday> getHolidays() {
		return [
			SELECT
				Id,
				Name,
				Description,
				ActivityDate
			FROM
				Holiday
		];
	}
}