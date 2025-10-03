namespace MoviesAndSeries.Dtos.Favorite
{

    public class ListFavoriteDto
    {
        public int Id { get; set; }
        public string? SeriesName { get; set; }
        public string? MovieName { get; set; }
        public string? Name => MovieName ?? SeriesName; // Frontend'de title olarak kullanılıyor
      
       
    }
}