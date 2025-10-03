using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MoviesAndSeries.Data;
using MoviesAndSeries.Dtos.User;
using MoviesAndSeries.Models.Entities;
using MoviesAndSeries.Services;

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly AppDbContext _context;
    private readonly JwtService _jwtService;
    private readonly EmailService _emailService;
    


    public AuthController(AppDbContext context, JwtService jwtService,EmailService emailService)
    {
        _context = context;
        _jwtService = jwtService;
        _emailService = emailService;
    }
    [HttpPost("login")]
    public async Task<IActionResult> Login([FromBody] LoginDto loginDto)
    {
        var user = await _context.Users.SingleOrDefaultAsync(u => u.Email == loginDto.Email);
        if (user == null)
        {
            return Unauthorized("Email veya şifre yanlış.");
        }

        bool isPasswordValid = BCrypt.Net.BCrypt.Verify(loginDto.Password, user.PasswordHash);
        if (!isPasswordValid)
        {
            return Unauthorized("Email veya şifre yanlış.");
        }

        var token = _jwtService.GenerateToken(user.Email);

        // Burayı güncelledik:
        return Ok(new { Token = token, UserId = user.Id });
    }

    [HttpPost("register")]
    public async Task<IActionResult> Register([FromBody] RegisterDto registerDto)
    {
        var existingUser = await _context.Users.AnyAsync(u => u.Email == registerDto.Email);
        if (existingUser)
            return BadRequest("Bu email zaten kayıtlı.");

        var newUser = new User
        {
            Email = registerDto.Email,
            FirstName = registerDto.FirstName,
            LastName = registerDto.LastName,
            Phone = registerDto.Phone,
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(registerDto.Password),
            CreatedAt = DateTime.UtcNow,
            Gender = registerDto.Gender,
            BirthDate = registerDto.BirthDate.HasValue
                ? DateTime.SpecifyKind(registerDto.BirthDate.Value, DateTimeKind.Utc)
                : (DateTime?)null,
            ProfileImage = null,
        };

        _context.Users.Add(newUser);
        await _context.SaveChangesAsync();

        return Ok("Kullanıcı başarıyla kaydedildi.");
    }
    [HttpPost("forgot-password")]
    public async Task<IActionResult> ForgotPassword([FromBody] ForgotPasswordDto forgotPasswordDto)
    {
        var user = await _context.Users.SingleOrDefaultAsync(u => u.Email == forgotPasswordDto.Email);
        if (user == null)
        {
            return Ok("Parola sıfırlama talimatları e-posta adresinize gönderilmiştir.");
        }

        var resetToken = Guid.NewGuid().ToString();
        user.ResetToken = resetToken;
        user.ResetTokenExpiry = DateTime.UtcNow.AddMinutes(15);

        await _context.SaveChangesAsync();
        
        // ŞİMDİ E-POSTA GÖNDERME ZAMANI
        var resetLink = $"https://sizinuygulamaniz.com/reset-password?token={resetToken}"; // Flutter uygulamasına yönlendirecek URL
        var emailBody = $"Parolanızı sıfırlamak için aşağıdaki linke tıklayın: <a href='{resetLink}'>{resetLink}</a>";
        
        await _emailService.SendEmailAsync(user.Email, "Şifre Sıfırlama İsteği", emailBody);

        return Ok("Parola sıfırlama talimatları e-posta adresinize gönderilmiştir.");
    }
}