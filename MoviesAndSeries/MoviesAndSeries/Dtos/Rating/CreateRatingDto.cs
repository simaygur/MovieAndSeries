namespace MoviesAndSeries.Dtos.Rating
{
    public class CreateRatingDto
    {
        public int? SeriesId { get; set; }
        public int? MovieId { get; set; }
        public int Score { get; set; }
        public string Comment { get; set; }
    }
}
