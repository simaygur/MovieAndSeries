namespace MoviesAndSeries.Dtos.User;

public class RegisterDto
{
    
        public string Email { get; set; }
        public string Password { get; set; }

        public string FirstName { get; set; }
        public string LastName { get; set; }
        public string Phone { get; set; }

        public int? Gender { get; set; }
        public DateTime? BirthDate { get; set; }
    }

