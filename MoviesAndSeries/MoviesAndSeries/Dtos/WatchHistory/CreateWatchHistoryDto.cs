namespace MoviesAndSeries.Dtos.User
{
    public class CreateWatchHistoryDto
    {
        public int UserId { get; set; }
        public int EpisodeId { get; set; }
        public int RemainingTime { get; set; }
    }
}
