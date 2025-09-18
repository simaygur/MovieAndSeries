using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MoviesAndSeries.Data;
using MoviesAndSeries.Dtos.Episode;
using MoviesAndSeries.Dtos.User;
using MoviesAndSeries.Dtos.WatchHistory;
using MoviesAndSeries.Models.Entities;

namespace MoviesAndSeries.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class WatchHistoryController : ControllerBase
    {
        private readonly AppDbContext _context;

        public WatchHistoryController(AppDbContext context)
        {
            _context = context;
        }

        // GET: api/watchhistory/5 (userId)
        [HttpGet("{userId}")]
        public async Task<ActionResult<IEnumerable<object>>> GetWatchHistory(int userId)
        {
            var data = await _context.WatchHistories
                .Include(w => w.Episode)
                .ThenInclude(e => e.Series)
                .Select(x => new ListWatchHistoryDto
                {

                     User = new ListUserDto
                    {
                        Id = x.UserId,
                        FirstName = x.User.FirstName,
                        LastName = x.User.LastName
                    },

                    Episode = new ListEpisodeDto
                    {
                        Id = x.EpisodeId,
                        Name = x.Episode.Name,
                        EpisodeNo = x.Episode.EpisodeNo,
                        Completed = x.Completed,
                        RemainingTime = x.RemainingTime,

                        Series = x.Episode.Series == null ? null : new Dtos.Series.ListSeriesDto
                        {
                            Name = x.Episode.Series.Name,
                            Description = x.Episode.Series.Description,
                            Poster = x.Episode.Series.Poster,

                        }

                    },

                })
                .Where(w => w.User.Id == userId)
                .ToListAsync();



            return data;
        }



        // POST: api/watchhistory
        [HttpPost]
        public async Task<ActionResult<WatchHistory>> AddWatchHistory([FromBody] CreateWatchHistoryDto request)
        {
            var watchHistory = new WatchHistory()
            {
                EpisodeId = request.EpisodeId,
                UserId = request.UserId,
                RemainingTime = request.RemainingTime,
            };
            _context.WatchHistories.Add(watchHistory);
            await _context.SaveChangesAsync();
            return CreatedAtAction(nameof(GetWatchHistory), new { userId = watchHistory.UserId }, watchHistory);
        }

        // PUT: api/watchhistory/5
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateWatchHistory(int id, [FromBody] UpdateWatchHistoryDto request)
        {
            var watchHistory = _context.WatchHistories.Find(id);
            if (watchHistory is null) return BadRequest();
            watchHistory.RemainingTime = request.RemainingTime;
            watchHistory.EpisodeId = request.EpisodeId;
            _context.Entry(watchHistory).State = EntityState.Modified;
            await _context.SaveChangesAsync();
            return NoContent();
        }

        // DELETE: api/watchhistory/5
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteWatchHistory(int id)
        {
            var watchHistory = await _context.WatchHistories.FindAsync(id);
            if (watchHistory == null) return NotFound();

            _context.WatchHistories.Remove(watchHistory);
            await _context.SaveChangesAsync();
            return NoContent();
        }
    }
}
