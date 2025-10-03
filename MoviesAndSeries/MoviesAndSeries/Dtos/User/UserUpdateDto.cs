namespace MoviesAndSeries.Dtos.User;

public class UserUpdateDto
{
    public string FirstName { get; set; }
    public string LastName { get; set; }
    public string? Phone { get; set; }
    public string? Gender { get; set; }
    public DateTime? BirthDate { get; set; }
}