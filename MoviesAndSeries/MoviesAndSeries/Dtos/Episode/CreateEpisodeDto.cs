namespace MoviesAndSeries.Dtos.Episode
{
    public class CreateEpisodeDto
    {
        public int? SeriesId { get; set; }

        public int? MovieId { get; set; }

        public int SeasonNo { get; set; }

        public string Name { get; set; }

        public int EpisodeNo { get; set; }
    }
}
