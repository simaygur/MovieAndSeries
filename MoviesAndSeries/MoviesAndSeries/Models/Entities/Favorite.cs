namespace MoviesAndSeries.Models.Entities
{
    public class Favorite
    {
        public int Id { get; set; }

        public int UserId { get; set; }
        public User User { get; set; }

        public int? SeriesId { get; set; }
        public Series Series { get; set; }

        public int? MovieId { get; set; }
        public Movie Movie { get; set; }

        public DateTime FavoriteDate { get; set; }
    }
}
