using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MoviesAndSeries.Data; // Projenizin DbContext'ini içerir
using MoviesAndSeries.Models; // Model sınıflarınızı içerir
using System.Linq;
using System.Threading.Tasks;
using System.Collections.Generic;

namespace MoviesAndSeries.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class SearchController : ControllerBase
    {
        private readonly  AppDbContext _context;

        public SearchController(AppDbContext context)
        {
            _context = context;
        }

        /// <summary>
        /// Filmler ve diziler arasında arama yapar.
        /// Örnek URL: /api/search?query=breaking
        /// </summary>
        /// <param name="query">Arama yapılacak metin.</param>
        /// <returns>Arama sonuçlarının listesi.</returns>
        [HttpGet]
        public async Task<ActionResult<IEnumerable<object>>> Search([FromQuery] string query)
        {
            // Eğer sorgu metni boşsa, 400 Bad Request döndür.
            if (string.IsNullOrWhiteSpace(query))
            {
                return BadRequest("Arama sorgusu boş olamaz.");
            }

            var normalizedQuery = query.Trim().ToLower();

            // Filmler tablosunda arama yap
            var movies = await _context.Movies
                                       .Where(m => m.Name.ToLower().Contains(normalizedQuery))
                                       .ToListAsync();

            // Diziler tablosunda arama yap
            var series = await _context.Series
                                       .Where(s => s.Name.ToLower().Contains(normalizedQuery))
                                       .ToListAsync();

            // Filmleri ve dizileri tek bir listede birleştir
            var results = new List<object>();
            results.AddRange(movies);
            results.AddRange(series);

            // Eğer hiç sonuç bulunamazsa 404 Not Found döndür
            if (!results.Any())
            {
                return NotFound("Aradığınız kriterlere uygun sonuç bulunamadı.");
            }

            // Başarılı olursa 200 OK ve sonuçları döndür
            return Ok(results);
        }
    }
}