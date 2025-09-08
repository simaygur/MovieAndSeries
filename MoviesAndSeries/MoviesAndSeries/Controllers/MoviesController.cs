using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MoviesAndSeries.Data;
using MoviesAndSeries.Dtos.Episode;
using MoviesAndSeries.Dtos.Genre;
using MoviesAndSeries.Dtos.Movies;
using MoviesAndSeries.Dtos.Platform;
using MoviesAndSeries.Models.Entities;

namespace MoviesAndSeries.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class MoviesController : ControllerBase
    {
        private readonly AppDbContext _context;

        public MoviesController(AppDbContext context)
        {
            _context = context;
        }

        // GET: api/movies
        [HttpGet]
        public async Task<ActionResult<IEnumerable<Movie>>> GetMovies()
        {
            var movies = await _context.Movies
       .Select(x => new  ListMovieDto
       {
           movie = new ListMovieDto
           {
               Id = x.Id,
               Name = x.Name,
               Description = x.Description,
               Duration = x.Duration,
               Poster = x.Poster,
               PublicationDate = x.PublicationDate,
               Genres = x.GenreMaps.Select(g => new ListGenreDto
               {
                   Id = g.Genre.Id,
                   Name = g.Genre.Name
               }).ToList(),

               Platform = x.PlatformMaps.Select(g => new ListPlatformDto
               {
                   Id = g.Platform.Id,
                   Name = g.Platform.Name
               }).ToList(),
               Episode = x.Episodes.Select(x => new ListEpisodeDto
               {
                   Id = x.Id,
                   Name = x.Name
               }).ToList()


           }

           })
       .ToListAsync();

            return Ok(movies);
            //return await _context.Movies
            //    .Include(m => m.Ratings)
            //    .Include(m => m.GenreMaps).ThenInclude(g => g.Genre)
            //    .Include(m => m.PlatformMaps).ThenInclude(p => p.Platform)
            //    .ToListAsync();
        }

        // GET: api/movies/5
        [HttpGet("{id}")]
        public async Task<ActionResult<Movie>> GetMovie(int id)
        {
            var movie = await _context.Movies
                .Include(m => m.Ratings)
                .Include(m => m.GenreMaps).ThenInclude(g => g.Genre)
                .Include(m => m.PlatformMaps).ThenInclude(p => p.Platform)
                .FirstOrDefaultAsync(m => m.Id == id);

            if (movie == null) return NotFound();
            return movie;
        }

        // POST: api/movies
        [HttpPost]
        public async Task<ActionResult<Movie>> CreateMovie([FromBody] CreateMovieDto request)
        {
            var movie = new Movie
            {
                Name = request.Name,
                PublicationDate = request.PublicationDate,
                Score = request.Score,
                Trailer = request.Trailer,
                Poster = request.Poster,
                Description = request.Description
            };
            _context.Movies.Add(movie);
            await _context.SaveChangesAsync();
            return CreatedAtAction(nameof(GetMovie), new { id = movie.Id }, movie);
        }

        // PUT: api/movies/5
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateMovie(int id, [FromBody] UpdateMovieDto request)
        {
            var movie = _context.Movies.Find(id);
            if (movie is null) return BadRequest();

            movie.Description = request.Description;
            movie.Score = request.Score;
            movie.Poster= request.Poster;

            _context.Entry(movie).State = EntityState.Modified;
            await _context.SaveChangesAsync();
            return NoContent();
        }

        // DELETE: api/movies/5
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteMovie(int id)
        {
            var movie = await _context.Movies.FindAsync(id);
            if (movie == null) return NotFound();

            _context.Movies.Remove(movie);
            await _context.SaveChangesAsync();
            return NoContent();
        }
    }
}
