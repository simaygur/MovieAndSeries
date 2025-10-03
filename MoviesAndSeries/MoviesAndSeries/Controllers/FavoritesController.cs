using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MoviesAndSeries.Data;
using MoviesAndSeries.Dtos.Favorite;
using MoviesAndSeries.Models.Entities;
using System.Linq;
using System.Threading.Tasks;
using System;
using System.Collections.Generic;

namespace MoviesAndSeries.Controllers
{
    [Authorize]
    [Route("api/[controller]")]
    [ApiController]
    public class FavoritesController : ControllerBase
    {
        private readonly AppDbContext _context;

        public FavoritesController(AppDbContext context)
        {
            _context = context;
        }

        // ❗️ GÜNCELLENDİ: Döngüsel referans hatasını çözmek için 'content' nesnesi yeniden yapılandırıldı.
        [HttpGet("{userId}")]
        public async Task<ActionResult<IEnumerable<object>>> GetFavorites(int userId)
        {
            try
            {
                var favorites = await _context.Favorites
                    .Where(f => f.UserId == userId)
                    .Include(f => f.Movie)
                    .Include(f => f.Series)
                    .OrderByDescending(f => f.Id) // En son eklenen favori en üstte görünsün
                    .ToListAsync();

                if (!favorites.Any())
                    return Ok(new List<object>()); // Boş liste döndürmek, 404'ten daha kullanıcı dostudur.

                // Veriyi Flutter'ın beklediği formata dönüştür
                var result = favorites.Select(f => new
                {
                    favoriteId = f.Id, // Silme işlemi için favorinin kendi ID'si
                    contentType = f.MovieId != null ? "Movie" : "Series",
                    // ❗️ DÜZELTİLDİ: Hata veren 'Rating' alanı kaldırıldı.
                    content = f.MovieId != null ?
                        (object)new { Id = f.Movie.Id, Title = f.Movie.Name, Overview = f.Movie.Description, poster_path = f.Movie.Poster } :
                        (object)new { Id = f.Series.Id, Name = f.Series.Name, Overview = f.Series.Description, poster_path = f.Series.Poster }
                }).ToList();

                return Ok(result);
            }
            catch (Exception ex)
            {
                // Hata durumunda daha anlamlı bir mesaj döndür
                return StatusCode(500, $"Internal server error: {ex.Message}");
            }
        }

        // POST: api/favorites
        [HttpPost]
        public async Task<ActionResult<Favorite>> AddFavorite([FromBody] CreateFavoriteDto request)
        {
            bool alreadyExists = false;
            if (request.MovieId.HasValue)
            {
                alreadyExists = await _context.Favorites
                    .AnyAsync(f => f.UserId == request.UserId && f.MovieId == request.MovieId);
            }
            else if (request.SeriesId.HasValue)
            {
                alreadyExists = await _context.Favorites
                    .AnyAsync(f => f.UserId == request.UserId && f.SeriesId == request.SeriesId);
            }

            if (alreadyExists)
            {
                return Conflict("Bu içerik zaten favorilerinize eklenmiş.");
            }

            var favorite = new Favorite()
            {
                MovieId = request.MovieId,
                SeriesId = request.SeriesId,
                UserId = request.UserId
            };
            _context.Favorites.Add(favorite);
            await _context.SaveChangesAsync();
            return CreatedAtAction(nameof(GetFavorites), new { userId = favorite.UserId }, favorite);
        }

        // DELETE: api/favorites/5 (favoriteId)
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteFavorite(int id)
        {
            var favorite = await _context.Favorites.FindAsync(id);
            if (favorite == null) return NotFound();

            _context.Favorites.Remove(favorite);
            await _context.SaveChangesAsync();
            return NoContent();
        }

        // DELETE: api/favorites/{userId}/movie/{movieId}
        [HttpDelete("{userId}/movie/{movieId}")]
        public async Task<IActionResult> DeleteFavoriteByMovieId(int userId, int movieId)
        {
            var favorite = await _context.Favorites.FirstOrDefaultAsync(f => f.UserId == userId && f.MovieId == movieId);
            if (favorite == null) return NotFound("Favori bulunamadı.");

            _context.Favorites.Remove(favorite);
            await _context.SaveChangesAsync();
            return NoContent();
        }

        // DELETE: api/favorites/{userId}/series/{seriesId}
        [HttpDelete("{userId}/series/{seriesId}")]
        public async Task<IActionResult> DeleteFavoriteBySeriesId(int userId, int seriesId)
        {
            var favorite = await _context.Favorites.FirstOrDefaultAsync(f => f.UserId == userId && f.SeriesId == seriesId);
            if (favorite == null) return NotFound("Favori bulunamadı.");

            _context.Favorites.Remove(favorite);
            await _context.SaveChangesAsync();
            return NoContent();
        }

        // GET: api/favorites/{userId}/check/movie/{movieId}
        [HttpGet("{userId}/check/movie/{movieId}")]
        public async Task<ActionResult<bool>> CheckIfMovieIsFavorite(int userId, int movieId)
        {
            bool isFavorite = await _context.Favorites.AnyAsync(f => f.UserId == userId && f.MovieId == movieId);
            return Ok(isFavorite);
        }

        // GET: api/favorites/{userId}/check/series/{seriesId}
        [HttpGet("{userId}/check/series/{seriesId}")]
        public async Task<ActionResult<bool>> CheckIfSeriesIsFavorite(int userId, int seriesId)
        {
            bool isFavorite = await _context.Favorites.AnyAsync(f => f.UserId == userId && f.SeriesId == seriesId);
            return Ok(isFavorite);
        }
    }
}

