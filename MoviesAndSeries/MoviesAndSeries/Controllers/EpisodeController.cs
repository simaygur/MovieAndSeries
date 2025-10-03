using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MoviesAndSeries.Data;
using MoviesAndSeries.Dtos.Episode;
using MoviesAndSeries.Dtos.User;
using MoviesAndSeries.Models.Entities;
using Microsoft.AspNetCore.Authorization;

namespace MoviesAndSeries.Controllers
{
    [Authorize]
    [Route("api/[controller]")]
    [ApiController]
    public class EpisodesController : ControllerBase
    {
        private readonly AppDbContext _context;

        public EpisodesController(AppDbContext context)
        {
            _context = context;
        }

        // GET: api/episodes/by-movie/{movieId}
        [HttpGet("by-movie/{movieId}")]
        public async Task<ActionResult<IEnumerable<object>>> GetEpisodesByMovie(int movieId)
        {
            return await _context.Episodes
                .Where(x => x.MovieId == movieId)
                .Select(y => new ListEpisodeDto
                {
                    Id = y.Id,
                    Name = y.Name,
                    SeasonNo = y.SeasonNo,
                    EpisodeNo = y.EpisodeNo
                })
                .ToListAsync();
        }
// GET: api/episodes/by-series/{seriesId}
        [HttpGet("by-series/{seriesId}")]
        public async Task<ActionResult<IEnumerable<ListEpisodeDto>>> GetEpisodesBySeries(int seriesId)
        {
            // Improvement 1: The return type is now specific.
            // Improvement 2: Added OrderBy and ThenBy for consistent results.
            return await _context.Episodes
                .Where(episode => episode.SeriesId == seriesId)
                .OrderBy(episode => episode.SeasonNo)
                .ThenBy(episode => episode.EpisodeNo)
                .Select(episode => new ListEpisodeDto
                {
                    Id = episode.Id,
                    Name = episode.Name,
                    SeasonNo = episode.SeasonNo,
                    EpisodeNo = episode.EpisodeNo,
                    SeriesId = episode.SeriesId
                })
                .ToListAsync();
        }
        // GET: api/episodes/{id}
        [HttpGet("{id}")]
        public async Task<ActionResult<IEnumerable<object>>> GetIdEpisodes(int? id)
        {
            return await _context.Episodes
                .Where(x => x.Id == id)
                .Select(y => new ListEpisodeDto
                {
                    Id = y.Id,
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
            return CreatedAtAction(nameof(GetEpisodesByMovie), new { movieId = episode.MovieId }, episode);
        }

        // PUT: api/episodes/5
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateEpisode(int id, [FromBody] UpdateEpisodeDto request)
        {
            var episode = await _context.Episodes.FindAsync(id);
            if (episode == null) return NotFound();

            episode.EpisodeNo = request.EpisodeNo;
            episode.SeasonNo = request.SeasonNo;
            episode.Name = request.Name;

            await _context.SaveChangesAsync();
            return NoContent();
        }

        // DELETE: api/episodes/5
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteEpisode(int id)
        {
            var episode = await _context.Episodes.FindAsync(id);
            if (episode == null) return NotFound();

            _context.Episodes.Remove(episode);
            await _context.SaveChangesAsync();
            return NoContent();
        }
    }
}