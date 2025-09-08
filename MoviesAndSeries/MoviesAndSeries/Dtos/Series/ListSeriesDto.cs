using MoviesAndSeries.Dtos.Episode;
using MoviesAndSeries.Dtos.Genre;
using MoviesAndSeries.Dtos.Platform;

namespace MoviesAndSeries.Dtos.Series
{
    public class ListSeriesDto
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public string Description { get; set; }
        public int Score { get; set; }
        public string Trailer { get; set; }
        public string Poster { get; set; }
        public DateTime PublicationDate { get; set; }

        public ListSeriesDto Series { get; set; }

        public List<ListEpisodeDto> Episode { get; set; }
        public List<ListGenreDto> Genres { get; set; }
        public List<ListPlatformDto> Platform { get; set; }
    }
}
