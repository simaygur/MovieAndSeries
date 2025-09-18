using MoviesAndSeries.Dtos;

namespace MoviesAndSeries.Dtos.Series
{
    public class CreateSeriesDto
    {
  
        public string Name { get; set; }
        public int Score { get; set; }
        public string Trailer { get; set; }
        public string Poster { get; set; }
        public string Description { get; set; }
        public DateTime PublicationDate { get; set; }
    }
}
