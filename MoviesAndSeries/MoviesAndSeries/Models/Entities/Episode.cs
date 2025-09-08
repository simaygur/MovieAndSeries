namespace MoviesAndSeries.Models.Entities
{
    public class Episode
    {

        public int Id { get; set; }

        public int? SeriesId { get; set; }
        public virtual Series? Series { get; set; }

        public int? MovieId { get; set; } // Eğer film sahnesi/part bölümü için kullanılırsa
        public virtual Movie? Movie { get; set; }

        public int SeasonNo { get; set; }
        public string Name { get; set; }
        public int EpisodeNo { get; set; }

        // Navigation
        public ICollection<WatchHistory> WatchHistories { get; set; }
    }
}
