using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MoviesAndSeries.Data;
using MoviesAndSeries.Dtos.Favorite;
using MoviesAndSeries.Models.Entities;

namespace MoviesAndSeries.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class FavoritesController : ControllerBase
    {
        private readonly AppDbContext _context;

        public FavoritesController(AppDbContext context)
        {
            _context = context;
        }

        // GET: api/favorites/5 (userId)
        [HttpGet("{userId}")]
        public async Task<ActionResult<IEnumerable<object>>> GetFavorites(int userId)
        {
            var data = await _context.Favorites
            .Include(f => f.Movie)
            .Include(f => f.Series)
            .Where(f => f.UserId == userId)
            .Select(x => new ListFavoriteDto
            {

                Id = x.Id,
                SeriesName = x.Series.Name,
                MovieName = x.Movie.Name



            })
                .ToListAsync();
            return data;

        }

        // POST: api/favorites
        [HttpPost]
        public async Task<ActionResult<Favorite>> AddFavorite([FromBody] CreateFavoriteDto request)
        {
            var favorite = new Favorite()
            {
                MovieId = request.MovieId,
                SeriesId = request.SeriesId
            };
            _context.Favorites.Add(favorite);
            await _context.SaveChangesAsync();
            return CreatedAtAction(nameof(GetFavorites), new { userId = favorite.UserId }, favorite);
        }

        // DELETE: api/favorites/5
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteFavorite(int id)
        {
            var favorite = await _context.Favorites.FindAsync(id);
            if (favorite == null) return NotFound();

            _context.Favorites.Remove(favorite);
            await _context.SaveChangesAsync();
            return NoContent();
        }
    }
}
