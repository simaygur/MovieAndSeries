namespace MoviesAndSeries.Models.Entities
{
    public class PlatformMap
    {
        public int Id { get; set; }

        public int? MovieId { get; set; }
        public Movie Movie { get; set; }

        public int? SeriesId { get; set; }
        public Series Series { get; set; }

        public int PlatformId { get; set; }
        public Platform Platform { get; set; }
    }
}
