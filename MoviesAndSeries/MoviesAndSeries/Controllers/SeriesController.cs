using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MoviesAndSeries.Data;
using MoviesAndSeries.Dtos;
using MoviesAndSeries.Dtos.Episode;
using MoviesAndSeries.Dtos.Genre;
using MoviesAndSeries.Dtos.Platform;
using MoviesAndSeries.Dtos.Series;
using MoviesAndSeries.Models.Entities;

namespace MoviesAndSeries.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class SeriesController : ControllerBase
    {
        private readonly AppDbContext _context;

        public SeriesController(AppDbContext context)
        {
            _context = context;
        }

        // GET: api/series
        [HttpGet]
        public async Task<ActionResult<IEnumerable<object>>> GetSeries()
        {
            var data = await _context.Series

                .Include(s => s.Episodes)
                .Include(s => s.Ratings)
                .Include(s => s.GenreMaps).ThenInclude(g => g.Genre)
                .Include(s => s.PlatformMaps).ThenInclude(p => p.Platform)
                .Select(x => new ListSeriesDto
                {
                    Series = new ListSeriesDto
                    {
                        Id = x.Id,
                        Name = x.Name,
                        Score = x.Score,
                        Description = x.Description,
                        Poster = x.Poster,
                        Trailer = x.Trailer,
                        PublicationDate = x.PublicationDate,

                        Episode = x.Episodes.Select(x => new ListEpisodeDto
                        {
                           Id= x.Id,
                           Name= x.Name
                        }).ToList(),

                        Genres = x.GenreMaps.Select(g => new ListGenreDto
                        {
                           Id =g.Genre.Id,
                          Name = g.Genre.Name
                        }).ToList(),

                        Platform = x.PlatformMaps.Select(g => new ListPlatformDto
                        {
                           Id= g.Platform.Id,
                           Name= g.Platform.Name
                        }).ToList()

                    }




                })

                .ToListAsync();

            return data;
        }

        // GET: api/series/5
        [HttpGet("{id}")]
        public async Task<ActionResult<Series>> GetSeries(int id)
        {
            var series = await _context.Series
                .Include(s => s.Episodes)
                .Include(s => s.Ratings)
                .Include(s => s.GenreMaps).ThenInclude(g => g.Genre)
                .Include(s => s.PlatformMaps).ThenInclude(p => p.Platform)
                .FirstOrDefaultAsync(s => s.Id == id);

            if (series == null) return NotFound();
            return series;
        }

        // POST: api/series
        [HttpPost]
        public async Task<ActionResult<Series>> CreateSeries([FromBody] CreateSeriesDto request)
        {
            var series = new Series
            {

                Name = request.Name,
                PublicationDate = request.PublicationDate,
                Score = request.Score,
                Trailer = request.Trailer,
                Poster = request.Poster,
                Description = request.Description

            };
            _context.Series.Add(series);
            await _context.SaveChangesAsync();
            return CreatedAtAction(nameof(GetSeries), new { id = series.Id }, series);
        }

        // PUT: api/series/5
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateSeries(int id, [FromBody] UpdateSeriesDto request)
        {
            var series = _context.Series.Find(id);
            if (series is null) return BadRequest();

            series.Trailer = request.Trailer;
            series.Poster = request.Poster;
            series.Description = request.Description;
            series.Score = request.Score;

            _context.Entry(series).State = EntityState.Modified;
            await _context.SaveChangesAsync();
            return NoContent();
        }

        // DELETE: api/series/5
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteSeries(int id)
        {
            var series = await _context.Series.FindAsync(id);
            if (series == null) return NotFound();

            _context.Series.Remove(series);
            await _context.SaveChangesAsync();
            return NoContent();
        }
    }
}
