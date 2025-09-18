using MoviesAndSeries.Dtos.Series;

namespace MoviesAndSeries.Dtos.Episode
{
    public class ListEpisodeDto
    {
        public int Id { get; set; }
        public int SeriesId { get; set; }
        public int? MovieId { get; set; }
        public int SeasonNo { get; set; }
        public string Name { get; set; }
        public int EpisodeNo { get; set; }
        public bool Completed { get; set; }
        public int RemainingTime { get; set; }

        public ListSeriesDto? Series { get; set; }
        }
}
