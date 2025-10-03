using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MoviesAndSeries.Data;
using MoviesAndSeries.Models.Entities;
using Microsoft.AspNetCore.Authorization;
namespace MoviesAndSeries.Controllers
{
    [Authorize]
    [Route("api/[controller]")]
    [ApiController]
    public class PlatformMapsController : ControllerBase
    {
        private readonly AppDbContext _context;

        public PlatformMapsController(AppDbContext context)
        {
            _context = context;
        }

        // GET: api/platformmaps
        [HttpGet]
        public async Task<ActionResult<IEnumerable<PlatformMap>>> GetPlatformMaps()
        {
            var data = await _context.PlatformMaps 
          .Include(p => p.Movie)
          .Include(p => p.Series)
          .Include(p => p.Platform)
          .Select(x => new
          {
              x.Id,
              Movie = x.Movie != null ? new
              {
                  x.Movie.Id,
                  x.Movie.Name
              } : null,
              Series = x.Series != null ? new
              {
                  x.Series.Id,
                  x.Series.Name
              } : null,
              Platform = new
              {
                  x.Platform.Id,
                  x.Platform.Name
              }
          })
          .ToListAsync();

            return Ok(data);
        }

        // GET: api/platformmaps/5
        [HttpGet("{id}")]
        public async Task<ActionResult<PlatformMap>> GetPlatformMap(int id)
        {
            var map = await _context.PlatformMaps
                .Include(p => p.Movie)
                .Include(p => p.Series)
                .Include(p => p.Platform)

                .FirstOrDefaultAsync(p => p.Id == id);

            if (map == null)
                return NotFound();

            return map;
        }

        // POST: api/platformmaps
        [HttpPost]
        public async Task<ActionResult<PlatformMap>> PostPlatformMap(PlatformMap request)
        {
            _context.PlatformMaps.Add(request);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetPlatformMap), new { id = request.Id }, request);
        }

        // PUT: api/platformmaps/5
        [HttpPut("{id}")]
        public async Task<IActionResult> PutPlatformMap(int id, PlatformMap request)
        {
            if (id != request.Id)
                return BadRequest();

            _context.Entry(request).State = EntityState.Modified;

            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!_context.PlatformMaps.Any(e => e.Id == id))
                    return NotFound();
                else
                    throw;
            }

            return NoContent();
        }

        // DELETE: api/platformmaps/5
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeletePlatformMap(int id)
        {
            var map = await _context.PlatformMaps.FindAsync(id);
            if (map == null)
                return NotFound();

            _context.PlatformMaps.Remove(map);
            await _context.SaveChangesAsync();

            return NoContent();
        }
    }
}

