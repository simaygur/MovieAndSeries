namespace MoviesAndSeries.Models.Entities
{
    public class User
    {
       
            public int Id { get; set; }

            public string FirstName { get; set; }
            public string LastName { get; set; }

            public string Email { get; set; }
            public string Phone { get; set; }
            public int Gender { get; set; } // Enum olarak kullanılabilir
            public DateTime BirthDate { get; set; }
            public DateTime CreatedAt { get; set; }

            public string PasswordHash { get; set; }
            public string ProfileImage { get; set; }

            // Navigation
            public ICollection<WatchHistory> WatchHistories { get; set; }
            public ICollection<Rating> Ratings { get; set; }
            public ICollection<Favorite> Favorites { get; set; }
        }
    }

