namespace MoviesAndSeries.Models.Entities
{
    public class Genre
    {
        public int Id { get; set; }
        public string Name { get; set; }

        // Navigation
        public ICollection<GenreMap> GenreMaps { get; set; }
    }
}
