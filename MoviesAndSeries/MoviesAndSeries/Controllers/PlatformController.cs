using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MoviesAndSeries.Data;
using MoviesAndSeries.Dtos.Platform;
using MoviesAndSeries.Models.Entities;
using Microsoft.AspNetCore.Authorization;
[Authorize]
[Route("api/[controller]")]
[ApiController]
public class PlatformsController : ControllerBase
{
    private readonly AppDbContext _context;

    public PlatformsController(AppDbContext context)
    {
        _context = context;
    }

    // GET: api/platforms
    [HttpGet]
    public async Task<ActionResult<IEnumerable<object>>> GetPlatforms()
    {
        return await _context.Platforms.Select(x=> new ListPlatformDto {
            Id=x.Id,
            Name=x.Name
        }) .ToListAsync();
    }

    // GET: api/platforms/5
    [HttpGet("{id}")]
    public async Task<ActionResult<Platform>> GetPlatform(int id)
    {
        var platform = await _context.Platforms.FindAsync(id);
        if (platform == null)
            return NotFound();

        return platform;
    }

    // POST: api/platforms
    [HttpPost]
    public async Task<ActionResult<Platform>> CreatePlatform([FromBody] CreatePlatformDto request)
    {
        var platform = new Platform
        {
            Name = request.Name,
           
        };
        _context.Platforms.Add(platform);
        await _context.SaveChangesAsync();

        return CreatedAtAction(nameof(GetPlatform), new { id = platform.Id }, platform);
    }

    // PUT: api/platforms/5
    [HttpPut("{id}")]
    public async Task<IActionResult> UpdatePlatform(int id,[FromBody] UpdatePlatformDto request)
    {
        var platform = _context.Platforms.Find(id);
        if (platform is null)
            return BadRequest();
       
        platform.Name = request.Name;
        _context.Entry(platform).State = EntityState.Modified;
        await _context.SaveChangesAsync();

        return NoContent();
    }

    // DELETE: api/platforms/5
    [HttpDelete("{id}")]
    public async Task<IActionResult> DeletePlatform(int id)
    {
        var platform = await _context.Platforms.FindAsync(id);
        if (platform == null)
            return NotFound();

        _context.Platforms.Remove(platform);
        await _context.SaveChangesAsync();

        return NoContent();
    }
}
