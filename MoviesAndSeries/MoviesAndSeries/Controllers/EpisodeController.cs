using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MoviesAndSeries.Data;
using MoviesAndSeries.Dtos.Episode;
using MoviesAndSeries.Dtos.User;
using MoviesAndSeries.Models.Entities;

namespace MoviesAndSeries.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class EpisodesController : ControllerBase
    {
        private readonly AppDbContext _context;

        public EpisodesController(AppDbContext context)
        {
            _context = context;
        }

        // GET: api/episodes/5 (userId)
        [HttpGet]
        public async Task<ActionResult<IEnumerable<object>>> GetEpisodes(int? movieId, int? seriesId)
        {
            return await _context.Episodes.Where(x => x.SeriesId == seriesId || x.MovieId == movieId)
                .Select(y => new ListEpisodeDto
                {

                    Name = y.Name,
                    SeasonNo = y.SeasonNo,
                    EpisodeNo = y.EpisodeNo

                })
                .ToListAsync();


            //return await _context.WatchHistories
            //    .Include(w => w.Episode)
            //    .ThenInclude(e => e.Series)
            //    .Where(w => w.UserId == userId)

            //.Select(x => new
            // {
            //     Series = new
            //     {
            //        Id= x.Id,
            //        SeriesName=  x.Episode.Series.Name,
            //        x.Episode,
            //        x.Episode.Name



            //     }




            // })

            //.ToListAsync();
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<IEnumerable<object>>> GetIdEpisodes(int? id)
        {
            return await _context.Episodes.Where(x => x.Id == id)
                .Select(y => new ListEpisodeDto
                {

                    Name = y.Name,
                    SeasonNo = y.SeasonNo,
                    EpisodeNo = y.EpisodeNo

                })
                .ToListAsync();
        }
        // POST: api/episodes
        [HttpPost]
        public async Task<ActionResult<Episode>> AddEpisode([FromBody] CreateEpisodeDto request)
        {
            var episode = new Episode
            {
                SeriesId = request.SeriesId,
                MovieId = request.MovieId,
                SeasonNo = request.SeasonNo,
                Name = request.Name,
                EpisodeNo = request.EpisodeNo
            };

            _context.Episodes.Add(episode);
            await _context.SaveChangesAsync();
            //sor getuserepisode 
            return CreatedAtAction(nameof(GetEpisodes), new { id = episode.Id }, episode);
        }



        // PUT: api/episodes/5
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateEpisode(int id, [FromBody] UpdateEpisodeDto request)
        {

            var episode = _context.Episodes.Find(id);
            if (episode is null) return BadRequest();
            episode.EpisodeNo = request.EpisodeNo;
            episode.SeasonNo = request.SeasonNo;
            episode.Name = request.Name;

            _context.Entry(request).State = EntityState.Modified;
            await _context.SaveChangesAsync();
            return NoContent();
        }

        // DELETE: api/episodes/5
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteEpisode(int id)
        {
            var watchHistory = await _context.WatchHistories.FindAsync(id);
            if (watchHistory == null) return NotFound();

            _context.WatchHistories.Remove(watchHistory);
            await _context.SaveChangesAsync();
            return NoContent();
        }
    }
}
