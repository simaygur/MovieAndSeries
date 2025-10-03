namespace MoviesAndSeries.Dtos.Favorite
{
    public class CreateFavoriteDto
    {
        public int? SeriesId { get; set; }
        public int? MovieId { get; set; }
        public int UserId { get; set; }
    }
}
