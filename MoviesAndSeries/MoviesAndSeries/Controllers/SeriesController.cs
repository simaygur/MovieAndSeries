using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MoviesAndSeries.Data;
using MoviesAndSeries.Dtos;
using MoviesAndSeries.Dtos.Episode;
using MoviesAndSeries.Dtos.Genre;
using MoviesAndSeries.Dtos.Platform;
using MoviesAndSeries.Dtos.Series;
using MoviesAndSeries.Models.Entities;
using Microsoft.AspNetCore.Authorization;
namespace MoviesAndSeries.Controllers
{
   
    [Route("api/[controller]")]
    [ApiController] 
    [Authorize]
    public class SeriesController : ControllerBase
    {
        private readonly AppDbContext _context;

        public SeriesController(AppDbContext context)
        {
            _context = context;
        }


        [HttpPost]
        public async Task<IActionResult> Create([FromBody] CreateSeriesDto request)
        {
            var series = new Series()
            {
                Name = request.Name,
                PublicationDate = request.PublicationDate,
                Score = request.Score,
                Trailer = request.Trailer,
                Poster = request.Poster,
                Description = request.Description,
            };

            await _context.Series.AddAsync(series);
            await _context.SaveChangesAsync();
            
            request.GenreIds.ForEach(f =>
            {
                _context.GenreMaps.Add(new GenreMap
                {
                    SeriesId = series.Id,
                    MovieId = null,
                    GenreId = f 
                });
            });
            
            request.PlatformIds.ForEach(p =>
            {
                _context.PlatformMaps.Add(new PlatformMap()
                {
                    SeriesId = series.Id,
                    MovieId = null,
                    PlatformId = p
                });
            });
            await _context.SaveChangesAsync();
            
            return Ok();
            //return NotFound();
        }
        
        
        

        // GET: api/series
        [HttpGet]
        public async Task<ActionResult> GetSeries()
        {
            var data = await _context.Series

                .Include(s => s.Episodes)
                .Include(s => s.Ratings)
                .Include(s => s.GenreMaps).ThenInclude(g => g.Genre)
                .Include(s => s.PlatformMaps).ThenInclude(p => p.Platform)
                .Select(x => new ListSeriesDto
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



                })

                .ToListAsync();

            return Ok(data);
        }

        // GET: api/series/5
        [HttpGet("{id}")]
        public async Task<ActionResult> GetSeries(int id)
        {
            var series = await _context.Series
                .Include(s => s.Episodes)
                .Include(s => s.Ratings)
                .Include(s => s.GenreMaps).ThenInclude(g => g.Genre)
                .Include(s => s.PlatformMaps).ThenInclude(p => p.Platform)
                .FirstOrDefaultAsync(s => s.Id == id);

            if (series == null) return NotFound();
            return Ok(series);
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
            return Ok();
        }

        // DELETE: api/series/5
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteSeries(int id)
        {
            // İlişkili tüm verileri Include metodu ile yükle
            var series = await _context.Series
                .Include(s => s.Episodes)
                .Include(s => s.PlatformMaps)
                .Include(s => s.GenreMaps)
                .FirstOrDefaultAsync(s => s.Id == id);
                               
            if (series == null) return NotFound();

            // Context'ten ana nesneyi (Series) kaldır.
            // İlişkili nesneler (Episodes, PlatformLocations, Genres) de bellekte takip edildiği için,
            // SaveChangesAsync çağrıldığında otomatik olarak silinecektir.
            _context.Series.Remove(series);
    
            await _context.SaveChangesAsync();
            return Ok();
        }
    }
}
