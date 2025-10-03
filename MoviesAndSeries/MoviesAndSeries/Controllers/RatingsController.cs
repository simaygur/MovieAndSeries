using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MoviesAndSeries.Data;
using MoviesAndSeries.Dtos.Rating;
using MoviesAndSeries.Models.Entities;
using Microsoft.AspNetCore.Authorization;
namespace MoviesAndSeries.Controllers
{
    [Authorize]
    [Route("api/[controller]")]
    [ApiController]
    public class RatingsController : ControllerBase
    {
        private readonly AppDbContext _context;

        public RatingsController(AppDbContext context)
        {
            _context = context;
        }
      

            // GET: api/ratings/
            [HttpGet]
        public async Task<ActionResult<IEnumerable<object>>> GetMovieAndSeriesRatings(int? movieId, int? seriesId)
        {

            return await _context.Ratings.Where(x => x.SeriesId == seriesId || x.MovieId == movieId)
                .Select(x => new ListRatingDto
                {
                    
                     Score=   x.Score,
                     UserId = x.UserId,
                     Comment =  x.Comment,
                     CommentDate= x.CommentDate

                    
                })
                .ToListAsync();
        }


        // POST: api/ratings
        [HttpPost]
        public async Task<ActionResult<Rating>> AddRating([FromBody] CreateRatingDto request)
        {
            var rating = new Rating
            {
                //UserId = GetCurrentUserId(), // login kullanıcıdan alınabilir
                SeriesId = request.SeriesId,
                MovieId = request.MovieId,
                Score = request.Score,
                Comment = request.Comment
            };
            rating.CommentDate = DateTime.UtcNow;
            _context.Ratings.Add(rating);
            await _context.SaveChangesAsync();
            return CreatedAtAction(nameof(GetMovieAndSeriesRatings), new { movieId = rating.MovieId }, rating);
        }

        // PUT: api/ratings/5
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateRating(int id, [FromBody] UpdateRatingDto request)
        {
            var rating = _context.Ratings.Find(id);
            if (rating is null) return BadRequest();
            rating.Score = request.Score;
            rating.Comment = request.Comment;
            
            _context.Entry(rating).State = EntityState.Modified;
            await _context.SaveChangesAsync();
            return NoContent();
        }

        // DELETE: api/ratings/5
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteRating(int id)
        {
            var rating = await _context.Ratings.FindAsync(id);
            if (rating == null) return NotFound();

            _context.Ratings.Remove(rating);
            await _context.SaveChangesAsync();
            return NoContent();
        }
    }
}

