namespace MoviesAndSeries.Models.Entities
{
    public class Movie
    {
        public int Id { get; set; }

        public string Name { get; set; }
        public int Score { get; set; }
        public int Duration { get; set; } // dakika
        public string Trailer { get; set; }
        public string Poster { get; set; }
        public string Description { get; set; }
        public DateTime PublicationDate { get; set; }

        // Navigation
        public ICollection<Rating> Ratings { get; set; }
        public ICollection<Favorite> Favorites { get; set; }
        public ICollection<GenreMap> GenreMaps { get; set; }
        public ICollection<PlatformMap> PlatformMaps { get; set; }
        public ICollection<Episode> Episodes { get; set; }
    }
}
