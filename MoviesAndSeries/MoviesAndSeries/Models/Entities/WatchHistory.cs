namespace MoviesAndSeries.Models.Entities
{
    public class WatchHistory
    {

        public int Id { get; set; }

        public int UserId { get; set; }
        public virtual User User { get; set; }

        public int EpisodeId { get; set; }
        public virtual Episode Episode { get; set; }

        public bool Completed { get; set; }
        public DateTime? CompletedDate { get; set; }
        public int RemainingTime { get; set; } // saniye/dakika
    }
}
