namespace MoviesAndSeries.Models.Entities
{
    public class User
    {
        public int Id { get; set; }

        public string FirstName { get; set; }
        public string LastName { get; set; }

        public string Email { get; set; }
        public string Phone { get; set; }

        // DTO'da olmayan alanları nullable yapıyoruz
        public int? Gender { get; set; }
        public  DateTime? BirthDate { get; set; }
        
        public DateTime CreatedAt { get; set; }

        public string PasswordHash { get; set; }
        public string? ProfileImage { get; set; }

        // Navigation
        public ICollection<WatchHistory> WatchHistories { get; set; } = new List<WatchHistory>();
        public ICollection<Rating> Ratings { get; set; } = new List<Rating>();
        public ICollection<Favorite> Favorites { get; set; } = new List<Favorite>();
        
        public string? ResetToken { get; set; }
        public DateTime? ResetTokenExpiry { get; set; }
    }
    
}