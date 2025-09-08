using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MoviesAndSeries.Data;
using MoviesAndSeries.Models.Entities;

namespace MoviesAndSeries.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class GenreMapController : ControllerBase
    {
        private readonly AppDbContext _context;

        public GenreMapController(AppDbContext context)
        {
            _context = context;
        }

        // GET: api/GenreMap
        [HttpGet]
        public async Task<ActionResult<IEnumerable<GenreMap>>> GetGenreMaps()
        {
            return await _context.GenreMaps
                .Include(g => g.Series)
                .Include(g => g.Movie)
                .Include(g => g.Genre)
                .ToListAsync();
        }

        // GET: api/GenreMap/5
        [HttpGet("{id}")]
        public async Task<ActionResult<GenreMap>> GetGenreMap(int id)
        {
            var map = await _context.GenreMaps
                .Include(g => g.Series)
                .Include(g => g.Movie)
                .Include(g => g.Genre)
                .FirstOrDefaultAsync(m => m.Id == id);

            if (map == null) return NotFound();

            return map;
        }

        // POST: api/GenreMap
        [HttpPost]
        public async Task<ActionResult<GenreMap>> PostGenreMap(GenreMap map)
        {
            _context.GenreMaps.Add(map);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetGenreMap), new { id = map.Id }, map);
        }

        // PUT: api/GenreMap/5
        [HttpPut("{id}")]
        public async Task<IActionResult> PutGenreMap(int id, GenreMap map)
        {
            if (id != map.Id) return BadRequest();

            _context.Entry(map).State = EntityState.Modified;

            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!_context.GenreMaps.Any(e => e.Id == id))
                    return NotFound();
                else
                    throw;
            }

            return NoContent();
        }

        // DELETE: api/GenreMap/5
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteGenreMap(int id)
        {
            var map = await _context.GenreMaps.FindAsync(id);
            if (map == null) return NotFound();

            _context.GenreMaps.Remove(map);
            await _context.SaveChangesAsync();

            return NoContent();
        }
    }
}
