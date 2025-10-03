namespace MoviesAndSeries.Dtos.Movies
{
    public class CreateMovieDto
    {
        public string Name { get; set; }
        public int Score { get; set; }
        public int Duration { get; set; }
        public string Trailer { get; set; }
        public string Poster { get; set; }
        public string Description { get; set; }
        public DateTime PublicationDate { get; set; }
        public List<int>GenreIds { get; set; }
        public List<int> PlatformIds { get; set; }
    }
}
