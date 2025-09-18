using MoviesAndSeries.Dtos.Episode;
using MoviesAndSeries.Dtos.Genre;
using MoviesAndSeries.Dtos.Platform;

namespace MoviesAndSeries.Dtos.Movies
{
    public class ListMovieDto
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public int Score { get; set; }
        public int Duration { get; set; } // dakika
        public string Trailer { get; set; }
        public string Poster { get; set; }
        public string Description { get; set; }
        public DateTime PublicationDate { get; set; }
        public ListMovieDto movie { get; set; }
        public List< ListPlatformDto> Platform { get; set; }
        public List <ListGenreDto> Genres { get; set; }
        public List<ListEpisodeDto> Episode { get; set; }

    }
}
