using MoviesAndSeries.Dtos.Episode;
using MoviesAndSeries.Dtos.Series;
using MoviesAndSeries.Dtos.User;

namespace MoviesAndSeries.Dtos.WatchHistory
{
    public class ListWatchHistoryDto
    {
        public int EpisodeId { get; set; }
        public bool Completed { get; set; }
        public DateTime RemainingTime { get; set; }
        public int UserId { get; set; }

        public ListUserDto User { get; set; }
        public ListEpisodeDto Episode { get; set; }
        
        public ListSeriesDto Series { get; set; }

    }
}
