using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MoviesAndSeries.Data;
using MoviesAndSeries.Dtos.Genre;
using MoviesAndSeries.Models.Entities;
using Microsoft.AspNetCore.Authorization;
[Authorize]
[Route("api/[controller]")]
[ApiController]
public class GenresController : ControllerBase
{
    private readonly AppDbContext _context;

    public GenresController(AppDbContext context)
    {
        _context = context;
    }

    // GET: api/genres
    [HttpGet]
    public async Task<ActionResult<IEnumerable<Genre>>> GetGenres()
    {
        return await _context.Genres.ToListAsync();
    }

    // GET: api/genres/5
    [HttpGet("{id}")]
    public async Task<ActionResult<Genre>> GetGenre(int id)
    {
        var genre = await _context.Genres.FindAsync(id);
        if (genre == null)
            return NotFound();

        return genre;
    }

    // POST: api/genres
    [HttpPost]
    public async Task<ActionResult<Genre>> CreateGenre([FromBody] CreateGenreDto request)
    {

        var genre = new Genre
        {
            Name = request.Name,
            
        };
        _context.Genres.Add(genre);
        await _context.SaveChangesAsync();
        return CreatedAtAction(nameof(GetGenre), new { id = genre.Id }, genre);
    }

    // PUT: api/genres/5
    [HttpPut("{id}")]
    public async Task<IActionResult> UpdateGenre(int id,[FromBody] UpdateGenreDto request)
    {
        var genre =  _context.Genres.Find(id);
        if (genre is null)
            return BadRequest();

        
        genre.Name = request.Name;
        _context.Entry(genre).State = EntityState.Modified;
        await _context.SaveChangesAsync();

        return NoContent();
    }

    // DELETE: api/genres/5
    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteGenre(int id)
    {
        var genre = await _context.Genres.FindAsync(id);
        if (genre == null)
            return NotFound();

        _context.Genres.Remove(genre);
        await _context.SaveChangesAsync();

        return NoContent();
    }
}
