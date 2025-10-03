using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MoviesAndSeries.Data;
using MoviesAndSeries.Dtos.User;
using System;
using System.Security.Claims;
using System.Threading.Tasks;

namespace MoviesAndSeries.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class UsersController : ControllerBase
    {
        private readonly AppDbContext _context;

        public UsersController(AppDbContext context)
        {
            _context = context;
        }

        // GET api/users/{id}
        [HttpGet("{id}")]
        public async Task<IActionResult> GetUserById(int id)
        {
            try
            {
                var userEmailFromToken = User.Claims.FirstOrDefault(c => c.Type == ClaimTypes.NameIdentifier)?.Value;
                if (string.IsNullOrEmpty(userEmailFromToken))
                {
                    return Unauthorized("Token'dan kullanıcı kimliği alınamadı.");
                }

                var userFromDb = await _context.Users.AsNoTracking().FirstOrDefaultAsync(u => u.Email == userEmailFromToken);

                if (userFromDb == null || userFromDb.Id != id)
                {
                    return Forbid("Bu profile erişim yetkiniz yok.");
                }

                var userDto = new UsersDto
                {
                    Id = userFromDb.Id,
                    Email = userFromDb.Email,
                    FirstName = userFromDb.FirstName,
                    LastName = userFromDb.LastName,
                    Phone = userFromDb.Phone,
                    Gender = userFromDb.Gender?.ToString(),
                    BirthDate = userFromDb.BirthDate
                };

                return Ok(userDto);
            }
            catch (Exception ex)
            {
                // HATA YAKALAMA EKLENDİ: Sunucudaki hatanın detayını Flutter'a gönderiyoruz.
                return StatusCode(500, $"Internal server error: {ex.Message}");
            }
        }

        // PUT api/users/{id}
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateUser(int id, [FromBody] UserUpdateDto userUpdateDto)
        {
            try
            {
                var userEmailFromToken = User.Claims.FirstOrDefault(c => c.Type == ClaimTypes.NameIdentifier)?.Value;
                var userToUpdate = await _context.Users.FirstOrDefaultAsync(u => u.Email == userEmailFromToken);

                if (userToUpdate == null || userToUpdate.Id != id)
                {
                    return Forbid("Bu profili güncelleme yetkiniz yok.");
                }

                userToUpdate.FirstName = userUpdateDto.FirstName;
                userToUpdate.LastName = userUpdateDto.LastName;
                userToUpdate.Phone = userUpdateDto.Phone;

                if (!string.IsNullOrEmpty(userUpdateDto.Gender) && int.TryParse(userUpdateDto.Gender, out int genderValue))
                {
                    userToUpdate.Gender = genderValue;
                }
                else
                {
                    userToUpdate.Gender = null;
                }

                userToUpdate.BirthDate = userUpdateDto.BirthDate;

                await _context.SaveChangesAsync();

                return NoContent();
            }
            catch (Exception ex)
            {
                // HATA YAKALAMA EKLENDİ: Sunucudaki hatanın detayını Flutter'a gönderiyoruz.
                return StatusCode(500, $"Internal server error: {ex.Message}");
            }
        }
    }
}

