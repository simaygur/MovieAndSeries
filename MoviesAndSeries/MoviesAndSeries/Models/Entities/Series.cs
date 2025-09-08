namespace MoviesAndSeries.Models.Entities
{
    public class Series
    {
        public int Id { get; set; }

        public string Name { get; set; }
        public int Score { get; set; }
        public string Trailer { get; set; }
        public string Poster { get; set; }
        public string Description { get; set; }
        public DateTime PublicationDate { get; set; }

        // Navigation
        public ICollection<Episode> Episodes { get; set; }
        public ICollection<Rating> Ratings { get; set; }
        public ICollection<Favorite> Favorites { get; set; }
        public ICollection<GenreMap> GenreMaps { get; set; }
        public ICollection<PlatformMap> PlatformMaps { get; set; }
    }
}
